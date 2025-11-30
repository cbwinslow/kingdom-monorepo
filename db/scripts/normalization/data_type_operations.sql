-- PostgreSQL Data Type Operations
-- Scripts for data type standardization and conversions

-- Function: Analyze data types in tables
CREATE OR REPLACE FUNCTION analyze_data_types(
    p_schema_name TEXT DEFAULT 'public'
)
RETURNS TABLE (
    schema_name TEXT,
    table_name TEXT,
    column_name TEXT,
    data_type TEXT,
    is_nullable TEXT,
    column_default TEXT,
    character_maximum_length INTEGER,
    numeric_precision INTEGER,
    numeric_scale INTEGER,
    recommendation TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.table_schema::TEXT,
        c.table_name::TEXT,
        c.column_name::TEXT,
        c.data_type::TEXT,
        c.is_nullable::TEXT,
        c.column_default::TEXT,
        c.character_maximum_length::INTEGER,
        c.numeric_precision::INTEGER,
        c.numeric_scale::INTEGER,
        CASE 
            -- Suggest using TEXT over VARCHAR without length
            WHEN c.data_type = 'character varying' AND c.character_maximum_length IS NULL 
                THEN 'Consider using TEXT instead of VARCHAR'
            -- Suggest appropriate numeric types
            WHEN c.data_type = 'numeric' AND c.numeric_precision > 15 
                THEN 'Consider if BIGINT or specialized type would be more appropriate'
            -- Check for storing booleans as integers
            WHEN c.data_type IN ('integer', 'smallint') AND c.column_name ~* '(is_|has_|can_|should_)'
                THEN 'Consider using BOOLEAN type for flag columns'
            -- Timestamps without timezone
            WHEN c.data_type = 'timestamp without time zone'
                THEN 'Consider using TIMESTAMP WITH TIME ZONE for better timezone handling'
            -- Using CHAR instead of VARCHAR
            WHEN c.data_type = 'character' 
                THEN 'Consider using VARCHAR or TEXT unless fixed length is required'
            ELSE 'Type appears appropriate'
        END::TEXT
    FROM information_schema.columns c
    WHERE c.table_schema = p_schema_name
      AND c.table_schema NOT IN ('pg_catalog', 'information_schema')
    ORDER BY c.table_name, c.ordinal_position;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION analyze_data_types IS 
'Analyzes data types across tables and provides recommendations for optimization';

-- Function: Find inconsistent data types across tables
CREATE OR REPLACE FUNCTION find_inconsistent_data_types()
RETURNS TABLE (
    column_name TEXT,
    data_types TEXT[],
    table_count INTEGER,
    tables TEXT[],
    recommendation TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.column_name::TEXT,
        array_agg(DISTINCT c.data_type ORDER BY c.data_type)::TEXT[],
        COUNT(DISTINCT c.table_name)::INTEGER,
        array_agg(c.table_name ORDER BY c.table_name)::TEXT[],
        'Standardize data type across tables for consistency'::TEXT
    FROM information_schema.columns c
    WHERE c.table_schema NOT IN ('pg_catalog', 'information_schema')
    GROUP BY c.column_name
    HAVING COUNT(DISTINCT c.data_type) > 1
    ORDER BY COUNT(DISTINCT c.table_name) DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION find_inconsistent_data_types IS 
'Finds columns with the same name but different data types across tables';

-- Function: Generate data type conversion commands
CREATE OR REPLACE FUNCTION generate_type_conversion_commands(
    p_schema_name TEXT,
    p_table_name TEXT,
    p_column_name TEXT,
    p_target_type TEXT,
    p_using_expression TEXT DEFAULT NULL
)
RETURNS TABLE (
    step INTEGER,
    description TEXT,
    sql_command TEXT,
    is_safe BOOLEAN,
    warning TEXT
) AS $$
DECLARE
    current_type TEXT;
    has_not_null BOOLEAN;
    has_default BOOLEAN;
BEGIN
    -- Get current column information
    SELECT 
        c.data_type,
        c.is_nullable = 'NO',
        c.column_default IS NOT NULL
    INTO current_type, has_not_null, has_default
    FROM information_schema.columns c
    WHERE c.table_schema = p_schema_name
      AND c.table_name = p_table_name
      AND c.column_name = p_column_name;
    
    IF current_type IS NULL THEN
        RETURN QUERY SELECT 
            1::INTEGER,
            'Error'::TEXT,
            'Column not found'::TEXT,
            false::BOOLEAN,
            'Verify schema, table, and column names'::TEXT;
        RETURN;
    END IF;
    
    -- Step 1: Backup recommendation
    RETURN QUERY SELECT 
        1::INTEGER,
        'Backup table'::TEXT,
        format('CREATE TABLE %I.%I_backup AS SELECT * FROM %I.%I;',
               p_schema_name, p_table_name, p_schema_name, p_table_name)::TEXT,
        true::BOOLEAN,
        'Always create a backup before data type changes'::TEXT;
    
    -- Step 2: Drop constraints if necessary
    IF has_not_null THEN
        RETURN QUERY SELECT 
            2::INTEGER,
            'Drop NOT NULL constraint (if needed)'::TEXT,
            format('ALTER TABLE %I.%I ALTER COLUMN %I DROP NOT NULL;',
                   p_schema_name, p_table_name, p_column_name)::TEXT,
            true::BOOLEAN,
            'May be needed for safe conversion'::TEXT;
    END IF;
    
    -- Step 3: Perform conversion
    RETURN QUERY SELECT 
        3::INTEGER,
        'Convert data type'::TEXT,
        format('ALTER TABLE %I.%I ALTER COLUMN %I TYPE %s%s;',
               p_schema_name, 
               p_table_name, 
               p_column_name, 
               p_target_type,
               CASE 
                   WHEN p_using_expression IS NOT NULL 
                   THEN format(' USING %s', p_using_expression)
                   ELSE ''
               END)::TEXT,
        CASE 
            WHEN current_type IN ('text', 'character varying') AND p_target_type IN ('integer', 'numeric')
            THEN false
            ELSE true
        END::BOOLEAN,
        CASE 
            WHEN current_type IN ('text', 'character varying') AND p_target_type IN ('integer', 'numeric')
            THEN 'Conversion may fail if data contains non-numeric values'
            ELSE 'Conversion should be safe'
        END::TEXT;
    
    -- Step 4: Restore constraints
    IF has_not_null THEN
        RETURN QUERY SELECT 
            4::INTEGER,
            'Restore NOT NULL constraint'::TEXT,
            format('ALTER TABLE %I.%I ALTER COLUMN %I SET NOT NULL;',
                   p_schema_name, p_table_name, p_column_name)::TEXT,
            false::BOOLEAN,
            'Verify all values are non-null before applying'::TEXT;
    END IF;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generate_type_conversion_commands IS 
'Generates safe data type conversion commands with warnings and recommendations';

-- Function: Safe data type conversion with validation
CREATE OR REPLACE FUNCTION safe_convert_column_type(
    p_schema_name TEXT,
    p_table_name TEXT,
    p_column_name TEXT,
    p_target_type TEXT,
    p_dry_run BOOLEAN DEFAULT true
)
RETURNS TABLE (
    step TEXT,
    status TEXT,
    message TEXT
) AS $$
DECLARE
    current_type TEXT;
    null_count INTEGER;
    total_count INTEGER;
    sample_values TEXT[];
BEGIN
    -- Step 1: Verify column exists
    SELECT data_type INTO current_type
    FROM information_schema.columns
    WHERE table_schema = p_schema_name
      AND table_name = p_table_name
      AND column_name = p_column_name;
    
    IF current_type IS NULL THEN
        RETURN QUERY SELECT 
            'validation'::TEXT, 
            'error'::TEXT, 
            'Column does not exist'::TEXT;
        RETURN;
    END IF;
    
    RETURN QUERY SELECT 
        'validation'::TEXT, 
        'success'::TEXT, 
        format('Current type: %s, Target type: %s', current_type, p_target_type)::TEXT;
    
    -- Step 2: Analyze data
    EXECUTE format('SELECT COUNT(*) FROM %I.%I WHERE %I IS NULL', 
                   p_schema_name, p_table_name, p_column_name) 
    INTO null_count;
    
    EXECUTE format('SELECT COUNT(*) FROM %I.%I', 
                   p_schema_name, p_table_name) 
    INTO total_count;
    
    RETURN QUERY SELECT 
        'analysis'::TEXT, 
        'info'::TEXT, 
        format('Total rows: %s, NULL values: %s (%s%%)', 
               total_count, null_count, 
               ROUND(100.0 * null_count / NULLIF(total_count, 0), 2))::TEXT;
    
    -- Step 3: Sample values
    EXECUTE format('SELECT array_agg(DISTINCT %I::TEXT) FROM (SELECT %I FROM %I.%I WHERE %I IS NOT NULL LIMIT 5) t',
                   p_column_name, p_column_name, p_schema_name, p_table_name, p_column_name)
    INTO sample_values;
    
    RETURN QUERY SELECT 
        'sample_values'::TEXT, 
        'info'::TEXT, 
        format('Sample values: %s', array_to_string(sample_values, ', '))::TEXT;
    
    -- Step 4: Execute or report
    IF p_dry_run THEN
        RETURN QUERY SELECT 
            'execution'::TEXT, 
            'dry_run'::TEXT, 
            'Would execute: ALTER TABLE ... (dry run mode)'::TEXT;
    ELSE
        BEGIN
            EXECUTE format('ALTER TABLE %I.%I ALTER COLUMN %I TYPE %s',
                          p_schema_name, p_table_name, p_column_name, p_target_type);
            
            RETURN QUERY SELECT 
                'execution'::TEXT, 
                'success'::TEXT, 
                'Column type successfully converted'::TEXT;
        EXCEPTION WHEN OTHERS THEN
            RETURN QUERY SELECT 
                'execution'::TEXT, 
                'error'::TEXT, 
                SQLERRM::TEXT;
        END;
    END IF;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION safe_convert_column_type IS 
'Safely converts a column type with validation and dry-run support';

-- Function: Standardize timestamp columns to TIMESTAMPTZ
CREATE OR REPLACE FUNCTION standardize_timestamps_to_timestamptz(
    p_schema_name TEXT DEFAULT 'public',
    p_dry_run BOOLEAN DEFAULT true
)
RETURNS TABLE (
    table_name TEXT,
    column_name TEXT,
    current_type TEXT,
    conversion_sql TEXT,
    status TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.table_name::TEXT,
        c.column_name::TEXT,
        c.data_type::TEXT,
        format('ALTER TABLE %I.%I ALTER COLUMN %I TYPE TIMESTAMPTZ USING %I AT TIME ZONE ''UTC'';',
               c.table_schema, c.table_name, c.column_name, c.column_name)::TEXT,
        CASE WHEN p_dry_run THEN 'dry_run' ELSE 'pending' END::TEXT
    FROM information_schema.columns c
    WHERE c.table_schema = p_schema_name
      AND c.data_type = 'timestamp without time zone'
    ORDER BY c.table_name, c.column_name;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION standardize_timestamps_to_timestamptz IS 
'Identifies and generates commands to convert TIMESTAMP columns to TIMESTAMPTZ';

-- Function: Optimize numeric types
CREATE OR REPLACE FUNCTION optimize_numeric_types(
    p_schema_name TEXT DEFAULT 'public'
)
RETURNS TABLE (
    table_name TEXT,
    column_name TEXT,
    current_type TEXT,
    suggested_type TEXT,
    reason TEXT,
    conversion_sql TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.table_name::TEXT,
        c.column_name::TEXT,
        format('%s(%s,%s)', c.data_type, c.numeric_precision, c.numeric_scale)::TEXT,
        CASE 
            WHEN c.numeric_precision <= 4 AND c.numeric_scale = 0 THEN 'SMALLINT'
            WHEN c.numeric_precision <= 9 AND c.numeric_scale = 0 THEN 'INTEGER'
            WHEN c.numeric_precision <= 18 AND c.numeric_scale = 0 THEN 'BIGINT'
            WHEN c.numeric_precision <= 6 AND c.numeric_scale <= 2 THEN 'REAL'
            WHEN c.numeric_precision <= 15 AND c.numeric_scale <= 6 THEN 'DOUBLE PRECISION'
            ELSE c.data_type
        END::TEXT,
        CASE 
            WHEN c.numeric_precision <= 9 AND c.numeric_scale = 0 
                THEN 'Integer types are faster and use less space'
            WHEN c.numeric_precision <= 15 AND c.numeric_scale <= 6 
                THEN 'Floating point types may be more efficient'
            ELSE 'NUMERIC is appropriate for this precision/scale'
        END::TEXT,
        format('ALTER TABLE %I.%I ALTER COLUMN %I TYPE %s;',
               c.table_schema, 
               c.table_name, 
               c.column_name,
               CASE 
                   WHEN c.numeric_precision <= 4 AND c.numeric_scale = 0 THEN 'SMALLINT'
                   WHEN c.numeric_precision <= 9 AND c.numeric_scale = 0 THEN 'INTEGER'
                   WHEN c.numeric_precision <= 18 AND c.numeric_scale = 0 THEN 'BIGINT'
                   WHEN c.numeric_precision <= 6 AND c.numeric_scale <= 2 THEN 'REAL'
                   WHEN c.numeric_precision <= 15 AND c.numeric_scale <= 6 THEN 'DOUBLE PRECISION'
                   ELSE c.data_type
               END)::TEXT
    FROM information_schema.columns c
    WHERE c.table_schema = p_schema_name
      AND c.data_type = 'numeric'
      AND c.numeric_precision IS NOT NULL
    ORDER BY c.table_name, c.column_name;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION optimize_numeric_types IS 
'Suggests optimizations for NUMERIC columns that could use simpler types';
