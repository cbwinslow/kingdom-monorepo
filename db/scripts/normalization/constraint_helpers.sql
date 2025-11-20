-- PostgreSQL Constraint Helper Functions
-- Scripts for analyzing and managing database constraints

-- Function: Analyze foreign key relationships
CREATE OR REPLACE FUNCTION analyze_foreign_keys(
    p_schema_name TEXT DEFAULT 'public'
)
RETURNS TABLE (
    constraint_name TEXT,
    from_table TEXT,
    from_columns TEXT,
    to_table TEXT,
    to_columns TEXT,
    on_delete_action TEXT,
    on_update_action TEXT,
    is_deferrable TEXT,
    initially_deferred TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        tc.constraint_name::TEXT,
        tc.table_name::TEXT AS from_table,
        string_agg(kcu.column_name, ', ' ORDER BY kcu.ordinal_position)::TEXT AS from_columns,
        ccu.table_name::TEXT AS to_table,
        string_agg(ccu.column_name, ', ' ORDER BY kcu.ordinal_position)::TEXT AS to_columns,
        rc.delete_rule::TEXT,
        rc.update_rule::TEXT,
        tc.is_deferrable::TEXT,
        tc.initially_deferred::TEXT
    FROM information_schema.table_constraints tc
    JOIN information_schema.key_column_usage kcu 
        ON tc.constraint_name = kcu.constraint_name
        AND tc.table_schema = kcu.table_schema
    JOIN information_schema.referential_constraints rc 
        ON tc.constraint_name = rc.constraint_name
        AND tc.table_schema = rc.constraint_schema
    JOIN information_schema.constraint_column_usage ccu 
        ON rc.unique_constraint_name = ccu.constraint_name
        AND rc.unique_constraint_schema = ccu.constraint_schema
    WHERE tc.constraint_type = 'FOREIGN KEY'
      AND tc.table_schema = p_schema_name
    GROUP BY 
        tc.constraint_name, tc.table_name, ccu.table_name,
        rc.delete_rule, rc.update_rule, tc.is_deferrable, tc.initially_deferred
    ORDER BY tc.table_name, tc.constraint_name;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION analyze_foreign_keys IS 
'Provides detailed analysis of foreign key relationships in the database';

-- Function: Find missing foreign key indexes
CREATE OR REPLACE FUNCTION find_missing_fk_indexes(
    p_schema_name TEXT DEFAULT 'public'
)
RETURNS TABLE (
    table_name TEXT,
    constraint_name TEXT,
    columns TEXT,
    referenced_table TEXT,
    impact TEXT,
    create_index_sql TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        tc.table_name::TEXT,
        tc.constraint_name::TEXT,
        string_agg(kcu.column_name, ', ' ORDER BY kcu.ordinal_position)::TEXT,
        ccu.table_name::TEXT AS referenced_table,
        'Missing index may cause slow DELETE/UPDATE on referenced table'::TEXT,
        format('CREATE INDEX idx_%s_%s ON %I.%I (%s);',
               tc.table_name,
               array_to_string(array_agg(kcu.column_name ORDER BY kcu.ordinal_position), '_'),
               p_schema_name,
               tc.table_name,
               string_agg(quote_ident(kcu.column_name), ', ' ORDER BY kcu.ordinal_position))::TEXT
    FROM information_schema.table_constraints tc
    JOIN information_schema.key_column_usage kcu 
        ON tc.constraint_name = kcu.constraint_name
        AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage ccu 
        ON tc.constraint_name = ccu.constraint_name
        AND tc.table_schema = ccu.constraint_schema
    WHERE tc.constraint_type = 'FOREIGN KEY'
      AND tc.table_schema = p_schema_name
      AND NOT EXISTS (
          SELECT 1
          FROM pg_index i
          JOIN pg_class c ON i.indexrelid = c.oid
          JOIN pg_namespace n ON c.relnamespace = n.oid
          WHERE n.nspname = p_schema_name
            AND i.indrelid = (p_schema_name || '.' || tc.table_name)::regclass
            AND array_to_string(array_agg(kcu.column_name ORDER BY kcu.ordinal_position), ',') = 
                array_to_string(
                    ARRAY(
                        SELECT a.attname
                        FROM pg_attribute a
                        WHERE a.attrelid = i.indrelid
                          AND a.attnum = ANY(i.indkey)
                        ORDER BY a.attnum
                    ), ','
                )
      )
    GROUP BY tc.constraint_name, tc.table_name, ccu.table_name
    ORDER BY tc.table_name;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION find_missing_fk_indexes IS 
'Identifies foreign key columns that lack supporting indexes';

-- Function: Analyze check constraints
CREATE OR REPLACE FUNCTION analyze_check_constraints(
    p_schema_name TEXT DEFAULT 'public'
)
RETURNS TABLE (
    table_name TEXT,
    constraint_name TEXT,
    check_clause TEXT,
    is_deferrable TEXT,
    initially_deferred TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        tc.table_name::TEXT,
        tc.constraint_name::TEXT,
        cc.check_clause::TEXT,
        tc.is_deferrable::TEXT,
        tc.initially_deferred::TEXT
    FROM information_schema.table_constraints tc
    JOIN information_schema.check_constraints cc
        ON tc.constraint_name = cc.constraint_name
        AND tc.constraint_schema = cc.constraint_schema
    WHERE tc.constraint_type = 'CHECK'
      AND tc.table_schema = p_schema_name
    ORDER BY tc.table_name, tc.constraint_name;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION analyze_check_constraints IS 
'Lists all check constraints with their definitions';

-- Function: Find tables without primary keys
CREATE OR REPLACE FUNCTION find_tables_without_primary_keys(
    p_schema_name TEXT DEFAULT 'public'
)
RETURNS TABLE (
    table_name TEXT,
    row_count BIGINT,
    table_size TEXT,
    recommendation TEXT,
    suggested_sql TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.table_name::TEXT,
        COALESCE(s.n_live_tup, 0)::BIGINT,
        COALESCE(pg_size_pretty(pg_total_relation_size(quote_ident(p_schema_name) || '.' || quote_ident(t.table_name))), '0 bytes')::TEXT,
        'Tables should have a primary key for data integrity and performance'::TEXT,
        format('ALTER TABLE %I.%I ADD COLUMN id SERIAL PRIMARY KEY;', p_schema_name, t.table_name)::TEXT
    FROM information_schema.tables t
    LEFT JOIN pg_stat_user_tables s 
        ON s.schemaname = t.table_schema 
        AND s.tablename = t.table_name
    WHERE t.table_schema = p_schema_name
      AND t.table_type = 'BASE TABLE'
      AND NOT EXISTS (
          SELECT 1
          FROM information_schema.table_constraints tc
          WHERE tc.table_schema = t.table_schema
            AND tc.table_name = t.table_name
            AND tc.constraint_type = 'PRIMARY KEY'
      )
    ORDER BY COALESCE(s.n_live_tup, 0) DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION find_tables_without_primary_keys IS 
'Identifies tables that lack primary keys';

-- Function: Generate constraint validation commands
CREATE OR REPLACE FUNCTION generate_constraint_validation_commands(
    p_schema_name TEXT DEFAULT 'public',
    p_table_name TEXT DEFAULT NULL
)
RETURNS TABLE (
    table_name TEXT,
    constraint_name TEXT,
    constraint_type TEXT,
    validation_sql TEXT,
    estimated_rows BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        tc.table_name::TEXT,
        tc.constraint_name::TEXT,
        tc.constraint_type::TEXT,
        CASE tc.constraint_type
            WHEN 'FOREIGN KEY' THEN
                format('SELECT COUNT(*) FROM %I.%I WHERE NOT EXISTS (SELECT 1 FROM %I.%I WHERE ...);',
                       p_schema_name, tc.table_name, p_schema_name, 'referenced_table')
            WHEN 'CHECK' THEN
                format('SELECT * FROM %I.%I WHERE NOT (%s) LIMIT 10;',
                       p_schema_name, tc.table_name, 
                       COALESCE((SELECT check_clause FROM information_schema.check_constraints cc 
                                WHERE cc.constraint_name = tc.constraint_name), 'true'))
            WHEN 'UNIQUE' THEN
                format('SELECT %s, COUNT(*) FROM %I.%I GROUP BY %s HAVING COUNT(*) > 1;',
                       string_agg(kcu.column_name, ', '),
                       p_schema_name, tc.table_name,
                       string_agg(kcu.column_name, ', '))
            ELSE 'N/A'
        END::TEXT,
        COALESCE(s.n_live_tup, 0)::BIGINT
    FROM information_schema.table_constraints tc
    LEFT JOIN information_schema.key_column_usage kcu
        ON tc.constraint_name = kcu.constraint_name
        AND tc.table_schema = kcu.table_schema
    LEFT JOIN pg_stat_user_tables s
        ON s.schemaname = tc.table_schema
        AND s.tablename = tc.table_name
    WHERE tc.table_schema = p_schema_name
      AND (p_table_name IS NULL OR tc.table_name = p_table_name)
      AND tc.constraint_type IN ('FOREIGN KEY', 'CHECK', 'UNIQUE')
    GROUP BY 
        tc.table_name, tc.constraint_name, tc.constraint_type, s.n_live_tup
    ORDER BY tc.table_name, tc.constraint_type, tc.constraint_name;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generate_constraint_validation_commands IS 
'Generates SQL commands to validate existing constraints';

-- Function: Safe constraint addition with validation
CREATE OR REPLACE FUNCTION safe_add_foreign_key(
    p_schema_name TEXT,
    p_table_name TEXT,
    p_column_name TEXT,
    p_ref_table TEXT,
    p_ref_column TEXT,
    p_constraint_name TEXT DEFAULT NULL,
    p_on_delete TEXT DEFAULT 'NO ACTION',
    p_on_update TEXT DEFAULT 'NO ACTION',
    p_dry_run BOOLEAN DEFAULT true
)
RETURNS TABLE (
    step TEXT,
    status TEXT,
    message TEXT
) AS $$
DECLARE
    constraint_name TEXT;
    orphan_count INTEGER;
BEGIN
    -- Generate constraint name if not provided
    constraint_name := COALESCE(
        p_constraint_name,
        format('fk_%s_%s_%s', p_table_name, p_ref_table, p_column_name)
    );
    
    -- Step 1: Check for orphaned records
    EXECUTE format(
        'SELECT COUNT(*) FROM %I.%I t WHERE t.%I IS NOT NULL AND NOT EXISTS (SELECT 1 FROM %I.%I r WHERE r.%I = t.%I)',
        p_schema_name, p_table_name, p_column_name,
        p_schema_name, p_ref_table, p_ref_column, p_column_name
    ) INTO orphan_count;
    
    IF orphan_count > 0 THEN
        RETURN QUERY SELECT 
            'validation'::TEXT,
            'error'::TEXT,
            format('Found %s orphaned records. Clean up data before adding constraint.', orphan_count)::TEXT;
        RETURN;
    END IF;
    
    RETURN QUERY SELECT 
        'validation'::TEXT,
        'success'::TEXT,
        'No orphaned records found'::TEXT;
    
    -- Step 2: Check if constraint already exists
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE table_schema = p_schema_name
          AND table_name = p_table_name
          AND constraint_name = constraint_name
    ) THEN
        RETURN QUERY SELECT 
            'check_existing'::TEXT,
            'warning'::TEXT,
            'Constraint already exists'::TEXT;
        RETURN;
    END IF;
    
    RETURN QUERY SELECT 
        'check_existing'::TEXT,
        'success'::TEXT,
        'Constraint name is available'::TEXT;
    
    -- Step 3: Execute or report
    IF p_dry_run THEN
        RETURN QUERY SELECT 
            'execution'::TEXT,
            'dry_run'::TEXT,
            format('Would execute: ALTER TABLE %I.%I ADD CONSTRAINT %I FOREIGN KEY (%I) REFERENCES %I.%I(%I) ON DELETE %s ON UPDATE %s;',
                   p_schema_name, p_table_name, constraint_name, p_column_name,
                   p_schema_name, p_ref_table, p_ref_column,
                   p_on_delete, p_on_update)::TEXT;
    ELSE
        BEGIN
            EXECUTE format(
                'ALTER TABLE %I.%I ADD CONSTRAINT %I FOREIGN KEY (%I) REFERENCES %I.%I(%I) ON DELETE %s ON UPDATE %s',
                p_schema_name, p_table_name, constraint_name, p_column_name,
                p_schema_name, p_ref_table, p_ref_column,
                p_on_delete, p_on_update
            );
            
            RETURN QUERY SELECT 
                'execution'::TEXT,
                'success'::TEXT,
                'Foreign key constraint added successfully'::TEXT;
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

COMMENT ON FUNCTION safe_add_foreign_key IS 
'Safely adds a foreign key constraint with validation and dry-run support';

-- Function: Validate constraint naming conventions
CREATE OR REPLACE FUNCTION validate_constraint_naming(
    p_schema_name TEXT DEFAULT 'public'
)
RETURNS TABLE (
    table_name TEXT,
    constraint_name TEXT,
    constraint_type TEXT,
    current_name TEXT,
    suggested_name TEXT,
    is_compliant BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        tc.table_name::TEXT,
        tc.constraint_name::TEXT,
        tc.constraint_type::TEXT,
        tc.constraint_name::TEXT AS current_name,
        CASE tc.constraint_type
            WHEN 'PRIMARY KEY' THEN format('pk_%s', tc.table_name)
            WHEN 'FOREIGN KEY' THEN format('fk_%s_%s', tc.table_name, 
                (SELECT ccu.table_name 
                 FROM information_schema.constraint_column_usage ccu 
                 WHERE ccu.constraint_name = tc.constraint_name LIMIT 1))
            WHEN 'UNIQUE' THEN format('uk_%s_%s', tc.table_name,
                (SELECT string_agg(kcu.column_name, '_') 
                 FROM information_schema.key_column_usage kcu 
                 WHERE kcu.constraint_name = tc.constraint_name))
            WHEN 'CHECK' THEN format('ck_%s_%s', tc.table_name, 
                substring(tc.constraint_name from '[a-z_]+$'))
            ELSE tc.constraint_name
        END::TEXT AS suggested_name,
        CASE tc.constraint_type
            WHEN 'PRIMARY KEY' THEN tc.constraint_name ~ format('^pk_%s', tc.table_name)
            WHEN 'FOREIGN KEY' THEN tc.constraint_name ~ '^fk_'
            WHEN 'UNIQUE' THEN tc.constraint_name ~ '^uk_'
            WHEN 'CHECK' THEN tc.constraint_name ~ '^ck_'
            ELSE true
        END::BOOLEAN
    FROM information_schema.table_constraints tc
    WHERE tc.table_schema = p_schema_name
      AND tc.constraint_type IN ('PRIMARY KEY', 'FOREIGN KEY', 'UNIQUE', 'CHECK')
    ORDER BY 
        CASE 
            WHEN tc.constraint_name !~ '^(pk_|fk_|uk_|ck_)' THEN 1
            ELSE 2
        END,
        tc.table_name, tc.constraint_type;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION validate_constraint_naming IS 
'Validates constraint naming conventions and suggests improvements';
