-- PostgreSQL Vacuum and Analyze Operations
-- Scripts for database optimization and maintenance

-- Function: Get tables that need vacuuming
CREATE OR REPLACE FUNCTION get_tables_needing_vacuum(
    dead_tuple_threshold INTEGER DEFAULT 1000
)
RETURNS TABLE (
    schema_name NAME,
    table_name NAME,
    n_live_tup BIGINT,
    n_dead_tup BIGINT,
    dead_tuple_percent NUMERIC,
    last_vacuum TIMESTAMP WITH TIME ZONE,
    last_autovacuum TIMESTAMP WITH TIME ZONE,
    days_since_vacuum NUMERIC,
    priority TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        schemaname::NAME,
        relname::NAME,
        pg_stat_user_tables.n_live_tup::BIGINT,
        pg_stat_user_tables.n_dead_tup::BIGINT,
        CASE 
            WHEN pg_stat_user_tables.n_live_tup > 0 
            THEN ROUND(100.0 * pg_stat_user_tables.n_dead_tup / pg_stat_user_tables.n_live_tup, 2)
            ELSE 0
        END::NUMERIC AS dead_tuple_percent,
        last_vacuum,
        last_autovacuum,
        ROUND(EXTRACT(EPOCH FROM (NOW() - GREATEST(last_vacuum, last_autovacuum))) / 86400.0, 2)::NUMERIC,
        CASE 
            WHEN pg_stat_user_tables.n_dead_tup > dead_tuple_threshold * 10 THEN 'HIGH'
            WHEN pg_stat_user_tables.n_dead_tup > dead_tuple_threshold THEN 'MEDIUM'
            ELSE 'LOW'
        END::TEXT
    FROM pg_stat_user_tables
    WHERE pg_stat_user_tables.n_dead_tup > dead_tuple_threshold
    ORDER BY pg_stat_user_tables.n_dead_tup DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_tables_needing_vacuum IS 
'Identifies tables that need vacuuming based on dead tuple count';

-- Function: Get tables that need analyzing
CREATE OR REPLACE FUNCTION get_tables_needing_analyze(
    days_threshold INTEGER DEFAULT 7
)
RETURNS TABLE (
    schema_name NAME,
    table_name NAME,
    n_live_tup BIGINT,
    n_mod_since_analyze BIGINT,
    mod_percent NUMERIC,
    last_analyze TIMESTAMP WITH TIME ZONE,
    last_autoanalyze TIMESTAMP WITH TIME ZONE,
    days_since_analyze NUMERIC,
    priority TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        schemaname::NAME,
        relname::NAME,
        pg_stat_user_tables.n_live_tup::BIGINT,
        pg_stat_user_tables.n_mod_since_analyze::BIGINT,
        CASE 
            WHEN pg_stat_user_tables.n_live_tup > 0 
            THEN ROUND(100.0 * pg_stat_user_tables.n_mod_since_analyze / pg_stat_user_tables.n_live_tup, 2)
            ELSE 0
        END::NUMERIC AS mod_percent,
        last_analyze,
        last_autoanalyze,
        ROUND(EXTRACT(EPOCH FROM (NOW() - GREATEST(last_analyze, last_autoanalyze))) / 86400.0, 2)::NUMERIC,
        CASE 
            WHEN EXTRACT(EPOCH FROM (NOW() - GREATEST(last_analyze, last_autoanalyze))) / 86400.0 > days_threshold * 2 THEN 'HIGH'
            WHEN EXTRACT(EPOCH FROM (NOW() - GREATEST(last_analyze, last_autoanalyze))) / 86400.0 > days_threshold THEN 'MEDIUM'
            ELSE 'LOW'
        END::TEXT
    FROM pg_stat_user_tables
    WHERE last_analyze IS NULL 
       OR last_autoanalyze IS NULL
       OR EXTRACT(EPOCH FROM (NOW() - GREATEST(last_analyze, last_autoanalyze))) / 86400.0 > days_threshold
    ORDER BY EXTRACT(EPOCH FROM (NOW() - GREATEST(last_analyze, last_autoanalyze))) DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_tables_needing_analyze IS 
'Identifies tables that need analyzing based on modification count and time since last analyze';

-- Function: Generate vacuum commands for tables
CREATE OR REPLACE FUNCTION generate_vacuum_commands(
    p_schema_name TEXT DEFAULT 'public',
    vacuum_full BOOLEAN DEFAULT false,
    vacuum_analyze BOOLEAN DEFAULT true
)
RETURNS TABLE (
    table_fqn TEXT,
    vacuum_command TEXT,
    estimated_time TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        quote_ident(schemaname) || '.' || quote_ident(tablename)::TEXT,
        CASE 
            WHEN vacuum_full THEN 'VACUUM FULL ' || 
                CASE WHEN vacuum_analyze THEN 'ANALYZE ' ELSE '' END ||
                quote_ident(schemaname) || '.' || quote_ident(tablename) || ';'
            ELSE 'VACUUM ' || 
                CASE WHEN vacuum_analyze THEN 'ANALYZE ' ELSE '' END ||
                quote_ident(schemaname) || '.' || quote_ident(tablename) || ';'
        END::TEXT,
        CASE 
            WHEN pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)) > 10737418240 
                THEN '> 30 minutes'
            WHEN pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)) > 1073741824 
                THEN '5-30 minutes'
            WHEN pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)) > 104857600 
                THEN '1-5 minutes'
            ELSE '< 1 minute'
        END::TEXT
    FROM pg_stat_user_tables
    WHERE schemaname = p_schema_name
    ORDER BY pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)) DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generate_vacuum_commands IS 
'Generates vacuum commands for tables with estimated execution time';

-- Function: Safe vacuum with monitoring
CREATE OR REPLACE FUNCTION safe_vacuum_table(
    p_schema_name TEXT,
    p_table_name TEXT,
    p_full BOOLEAN DEFAULT false,
    p_analyze BOOLEAN DEFAULT true,
    p_verbose BOOLEAN DEFAULT false
)
RETURNS TABLE (
    step TEXT,
    status TEXT,
    message TEXT
) AS $$
DECLARE
    table_fqn TEXT;
    table_size TEXT;
    dead_tuples BIGINT;
    start_time TIMESTAMP;
    end_time TIMESTAMP;
BEGIN
    table_fqn := quote_ident(p_schema_name) || '.' || quote_ident(p_table_name);
    start_time := clock_timestamp();
    
    -- Step 1: Verify table exists
    IF NOT EXISTS (
        SELECT 1 FROM pg_tables 
        WHERE schemaname = p_schema_name AND tablename = p_table_name
    ) THEN
        RETURN QUERY SELECT 
            'verify_table'::TEXT, 
            'error'::TEXT, 
            'Table does not exist'::TEXT;
        RETURN;
    END IF;
    
    RETURN QUERY SELECT 
        'verify_table'::TEXT, 
        'success'::TEXT, 
        'Table exists'::TEXT;
    
    -- Step 2: Get table info
    SELECT 
        pg_size_pretty(pg_total_relation_size(table_fqn::regclass)),
        n_dead_tup
    INTO table_size, dead_tuples
    FROM pg_stat_user_tables
    WHERE schemaname = p_schema_name AND tablename = p_table_name;
    
    RETURN QUERY SELECT 
        'table_info'::TEXT, 
        'info'::TEXT, 
        format('Size: %s, Dead tuples: %s', table_size, dead_tuples)::TEXT;
    
    -- Step 3: Execute vacuum
    BEGIN
        EXECUTE format('VACUUM %s %s %s',
            CASE WHEN p_full THEN 'FULL' ELSE '' END,
            CASE WHEN p_analyze THEN 'ANALYZE' ELSE '' END,
            table_fqn
        );
        
        end_time := clock_timestamp();
        
        RETURN QUERY SELECT 
            'vacuum_execution'::TEXT, 
            'success'::TEXT, 
            format('Completed in %s', end_time - start_time)::TEXT;
    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY SELECT 
            'vacuum_execution'::TEXT, 
            'error'::TEXT, 
            SQLERRM::TEXT;
    END;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION safe_vacuum_table IS 
'Safely vacuums a table with pre-checks and monitoring';

-- Function: Get bloat estimate for tables
CREATE OR REPLACE FUNCTION get_table_bloat()
RETURNS TABLE (
    schema_name NAME,
    table_name NAME,
    actual_size TEXT,
    estimated_size TEXT,
    bloat_size TEXT,
    bloat_percent NUMERIC,
    priority TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        schemaname::NAME,
        tablename::NAME,
        pg_size_pretty(pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)))::TEXT,
        pg_size_pretty(
            (n_live_tup * 
             (SELECT current_setting('block_size')::INTEGER * 
              (SELECT relpages FROM pg_class WHERE oid = (quote_ident(schemaname) || '.' || quote_ident(tablename))::regclass) / 
              NULLIF(n_live_tup + n_dead_tup, 0)))::BIGINT
        )::TEXT,
        pg_size_pretty(
            pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)) -
            (n_live_tup * 
             (SELECT current_setting('block_size')::INTEGER * 
              (SELECT relpages FROM pg_class WHERE oid = (quote_ident(schemaname) || '.' || quote_ident(tablename))::regclass) / 
              NULLIF(n_live_tup + n_dead_tup, 0)))::BIGINT
        )::TEXT,
        ROUND(
            100.0 * (1 - (n_live_tup::NUMERIC / NULLIF(n_live_tup + n_dead_tup, 0))),
            2
        )::NUMERIC,
        CASE 
            WHEN (1 - (n_live_tup::NUMERIC / NULLIF(n_live_tup + n_dead_tup, 0))) > 0.3 THEN 'HIGH'
            WHEN (1 - (n_live_tup::NUMERIC / NULLIF(n_live_tup + n_dead_tup, 0))) > 0.2 THEN 'MEDIUM'
            ELSE 'LOW'
        END::TEXT
    FROM pg_stat_user_tables
    WHERE n_live_tup > 0
    ORDER BY pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)) DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_table_bloat IS 
'Estimates table bloat and suggests vacuum operations';

-- Function: Schedule maintenance window analysis
CREATE OR REPLACE FUNCTION analyze_maintenance_window(
    p_schema_name TEXT DEFAULT 'public'
)
RETURNS TABLE (
    operation TEXT,
    table_count INTEGER,
    estimated_total_time TEXT,
    recommended_order TEXT[]
) AS $$
BEGIN
    RETURN QUERY
    WITH table_stats AS (
        SELECT 
            schemaname,
            tablename,
            n_dead_tup,
            pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)) as table_size
        FROM pg_stat_user_tables
        WHERE schemaname = p_schema_name
    )
    SELECT 
        'VACUUM'::TEXT,
        COUNT(*)::INTEGER,
        format('%s hours', ROUND(SUM(table_size) / 1073741824.0 / 2.0, 2))::TEXT, -- Rough estimate: 2GB per hour
        array_agg(quote_ident(schemaname) || '.' || quote_ident(tablename) ORDER BY table_size DESC)::TEXT[]
    FROM table_stats
    WHERE n_dead_tup > 1000;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION analyze_maintenance_window IS 
'Analyzes tables and provides maintenance window recommendations';
