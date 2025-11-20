-- PostgreSQL Performance Helper Utilities
-- Common utilities for performance monitoring and optimization

-- Function: Estimate query execution time
CREATE OR REPLACE FUNCTION estimate_query_cost(
    query_text TEXT
)
RETURNS TABLE (
    total_cost NUMERIC,
    startup_cost NUMERIC,
    plan_rows BIGINT,
    plan_width INTEGER,
    execution_plan TEXT
) AS $$
DECLARE
    plan_result TEXT;
BEGIN
    -- Get EXPLAIN output
    EXECUTE 'EXPLAIN ' || query_text INTO plan_result;
    
    RETURN QUERY
    SELECT 
        NULL::NUMERIC,
        NULL::NUMERIC,
        NULL::BIGINT,
        NULL::INTEGER,
        plan_result::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION estimate_query_cost IS 
'Estimates query execution cost using EXPLAIN (requires valid SQL query)';

-- Function: Find long-running queries
CREATE OR REPLACE FUNCTION find_long_running_queries(
    min_duration_seconds INTEGER DEFAULT 60
)
RETURNS TABLE (
    pid INTEGER,
    duration INTERVAL,
    username NAME,
    database_name NAME,
    state TEXT,
    query TEXT,
    wait_event_type TEXT,
    wait_event TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        pg_stat_activity.pid::INTEGER,
        (NOW() - pg_stat_activity.query_start)::INTERVAL,
        usename::NAME,
        datname::NAME,
        state::TEXT,
        query::TEXT,
        wait_event_type::TEXT,
        wait_event::TEXT
    FROM pg_stat_activity
    WHERE state = 'active'
      AND (NOW() - pg_stat_activity.query_start) > (min_duration_seconds || ' seconds')::INTERVAL
      AND pid <> pg_backend_pid()
    ORDER BY (NOW() - pg_stat_activity.query_start) DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION find_long_running_queries IS 
'Identifies queries that have been running longer than specified duration';

-- Function: Analyze table and report statistics
CREATE OR REPLACE FUNCTION analyze_table_detailed(
    p_schema_name TEXT,
    p_table_name TEXT
)
RETURNS TABLE (
    metric TEXT,
    value TEXT,
    category TEXT
) AS $$
DECLARE
    table_fqn TEXT;
BEGIN
    table_fqn := quote_ident(p_schema_name) || '.' || quote_ident(p_table_name);
    
    -- Run ANALYZE
    EXECUTE format('ANALYZE %s', table_fqn);
    
    RETURN QUERY
    -- Table size metrics
    SELECT 
        'Total Size'::TEXT,
        pg_size_pretty(pg_total_relation_size(table_fqn::regclass))::TEXT,
        'size'::TEXT
    UNION ALL
    SELECT 
        'Table Size'::TEXT,
        pg_size_pretty(pg_relation_size(table_fqn::regclass))::TEXT,
        'size'::TEXT
    UNION ALL
    SELECT 
        'Index Size'::TEXT,
        pg_size_pretty(pg_total_relation_size(table_fqn::regclass) - pg_relation_size(table_fqn::regclass))::TEXT,
        'size'::TEXT
    UNION ALL
    -- Row statistics
    SELECT 
        'Live Rows'::TEXT,
        n_live_tup::TEXT,
        'rows'::TEXT
    FROM pg_stat_user_tables
    WHERE schemaname = p_schema_name AND tablename = p_table_name
    UNION ALL
    SELECT 
        'Dead Rows'::TEXT,
        n_dead_tup::TEXT,
        'rows'::TEXT
    FROM pg_stat_user_tables
    WHERE schemaname = p_schema_name AND tablename = p_table_name
    UNION ALL
    -- Operation statistics
    SELECT 
        'Sequential Scans'::TEXT,
        seq_scan::TEXT,
        'operations'::TEXT
    FROM pg_stat_user_tables
    WHERE schemaname = p_schema_name AND tablename = p_table_name
    UNION ALL
    SELECT 
        'Index Scans'::TEXT,
        COALESCE(SUM(idx_scan), 0)::TEXT,
        'operations'::TEXT
    FROM pg_stat_user_indexes
    WHERE schemaname = p_schema_name AND tablename = p_table_name;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION analyze_table_detailed IS 
'Runs ANALYZE on a table and returns detailed statistics';

-- Function: Get table fragmentation estimate
CREATE OR REPLACE FUNCTION get_table_fragmentation(
    p_schema_name TEXT DEFAULT 'public'
)
RETURNS TABLE (
    schema_name TEXT,
    table_name TEXT,
    total_pages BIGINT,
    empty_pages BIGINT,
    free_space_percent NUMERIC,
    fragmentation_status TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        schemaname::TEXT,
        tablename::TEXT,
        relpages::BIGINT AS total_pages,
        0::BIGINT AS empty_pages, -- Simplified; full calculation requires pg_freespacemap
        ROUND(
            CASE 
                WHEN n_live_tup + n_dead_tup > 0 
                THEN 100.0 * n_dead_tup / (n_live_tup + n_dead_tup)
                ELSE 0
            END,
            2
        )::NUMERIC AS free_space_percent,
        CASE 
            WHEN n_dead_tup::NUMERIC / NULLIF(n_live_tup + n_dead_tup, 0) > 0.2 THEN 'HIGH'
            WHEN n_dead_tup::NUMERIC / NULLIF(n_live_tup + n_dead_tup, 0) > 0.1 THEN 'MEDIUM'
            ELSE 'LOW'
        END::TEXT AS fragmentation_status
    FROM pg_stat_user_tables
    JOIN pg_class ON pg_class.relname = pg_stat_user_tables.tablename
    WHERE schemaname = p_schema_name
      AND pg_class.relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = p_schema_name)
    ORDER BY n_dead_tup DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_table_fragmentation IS 
'Estimates table fragmentation based on dead tuple ratio';

-- Function: Generate performance report
CREATE OR REPLACE FUNCTION generate_performance_report()
RETURNS TABLE (
    section TEXT,
    metric TEXT,
    value TEXT,
    status TEXT
) AS $$
BEGIN
    RETURN QUERY
    -- Cache hit ratios
    SELECT 
        'Cache Performance'::TEXT,
        'Table Cache Hit Ratio'::TEXT,
        ROUND(100.0 * SUM(heap_blks_hit) / NULLIF(SUM(heap_blks_hit) + SUM(heap_blks_read), 0), 2)::TEXT || '%',
        CASE 
            WHEN ROUND(100.0 * SUM(heap_blks_hit) / NULLIF(SUM(heap_blks_hit) + SUM(heap_blks_read), 0), 2) >= 95 THEN 'GOOD'
            WHEN ROUND(100.0 * SUM(heap_blks_hit) / NULLIF(SUM(heap_blks_hit) + SUM(heap_blks_read), 0), 2) >= 85 THEN 'FAIR'
            ELSE 'POOR'
        END::TEXT
    FROM pg_statio_user_tables
    
    UNION ALL
    
    -- Connection stats
    SELECT 
        'Connections'::TEXT,
        'Active Connections'::TEXT,
        COUNT(*)::TEXT,
        CASE 
            WHEN COUNT(*) < 50 THEN 'GOOD'
            WHEN COUNT(*) < 100 THEN 'FAIR'
            ELSE 'HIGH'
        END::TEXT
    FROM pg_stat_activity
    WHERE state = 'active'
    
    UNION ALL
    
    -- Transaction stats
    SELECT 
        'Transactions'::TEXT,
        'Commit Rate'::TEXT,
        ROUND(100.0 * SUM(xact_commit) / NULLIF(SUM(xact_commit) + SUM(xact_rollback), 0), 2)::TEXT || '%',
        CASE 
            WHEN ROUND(100.0 * SUM(xact_commit) / NULLIF(SUM(xact_commit) + SUM(xact_rollback), 0), 2) >= 95 THEN 'GOOD'
            WHEN ROUND(100.0 * SUM(xact_commit) / NULLIF(SUM(xact_commit) + SUM(xact_rollback), 0), 2) >= 85 THEN 'FAIR'
            ELSE 'POOR'
        END::TEXT
    FROM pg_stat_database
    WHERE datname = current_database()
    
    UNION ALL
    
    -- Vacuum stats
    SELECT 
        'Maintenance'::TEXT,
        'Tables Needing Vacuum'::TEXT,
        COUNT(*)::TEXT,
        CASE 
            WHEN COUNT(*) = 0 THEN 'GOOD'
            WHEN COUNT(*) < 5 THEN 'FAIR'
            ELSE 'ACTION NEEDED'
        END::TEXT
    FROM pg_stat_user_tables
    WHERE n_dead_tup > 1000
    
    ORDER BY section, metric;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generate_performance_report IS 
'Generates a comprehensive performance report with status indicators';

-- Function: Kill idle transactions
CREATE OR REPLACE FUNCTION kill_idle_transactions(
    idle_threshold_minutes INTEGER DEFAULT 30,
    dry_run BOOLEAN DEFAULT true
)
RETURNS TABLE (
    pid INTEGER,
    username NAME,
    database_name NAME,
    idle_duration INTERVAL,
    action TEXT
) AS $$
DECLARE
    killed_count INTEGER := 0;
BEGIN
    IF dry_run THEN
        RETURN QUERY
        SELECT 
            pg_stat_activity.pid::INTEGER,
            usename::NAME,
            datname::NAME,
            (NOW() - state_change)::INTERVAL,
            'WOULD TERMINATE'::TEXT
        FROM pg_stat_activity
        WHERE state = 'idle in transaction'
          AND (NOW() - state_change) > (idle_threshold_minutes || ' minutes')::INTERVAL
          AND pid <> pg_backend_pid()
        ORDER BY (NOW() - state_change) DESC;
    ELSE
        FOR r IN 
            SELECT pg_stat_activity.pid, usename, datname, (NOW() - state_change) AS idle_time
            FROM pg_stat_activity
            WHERE state = 'idle in transaction'
              AND (NOW() - state_change) > (idle_threshold_minutes || ' minutes')::INTERVAL
              AND pid <> pg_backend_pid()
        LOOP
            PERFORM pg_terminate_backend(r.pid);
            killed_count := killed_count + 1;
            
            RETURN QUERY
            SELECT 
                r.pid::INTEGER,
                r.usename::NAME,
                r.datname::NAME,
                r.idle_time::INTERVAL,
                'TERMINATED'::TEXT;
        END LOOP;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION kill_idle_transactions IS 
'Terminates idle transactions that have been idle longer than threshold';

-- Function: Recommend configuration changes
CREATE OR REPLACE FUNCTION recommend_config_changes()
RETURNS TABLE (
    setting_name TEXT,
    current_value TEXT,
    recommended_value TEXT,
    reason TEXT,
    impact TEXT
) AS $$
BEGIN
    RETURN QUERY
    -- shared_buffers recommendation
    SELECT 
        'shared_buffers'::TEXT,
        current_setting('shared_buffers')::TEXT,
        CASE 
            WHEN (SELECT pg_size_bytes(current_setting('shared_buffers'))) < 
                 (SELECT (pg_database_size(current_database()) * 0.25)::BIGINT)
            THEN pg_size_pretty((pg_database_size(current_database()) * 0.25)::BIGINT)::TEXT
            ELSE 'Current value is appropriate'
        END::TEXT,
        'Should be ~25% of database size for optimal performance'::TEXT,
        'HIGH'::TEXT
    WHERE (SELECT pg_size_bytes(current_setting('shared_buffers'))) < 
          (SELECT (pg_database_size(current_database()) * 0.25)::BIGINT)
    
    UNION ALL
    
    -- work_mem recommendation
    SELECT 
        'work_mem'::TEXT,
        current_setting('work_mem')::TEXT,
        '16MB'::TEXT,
        'Increase for better sort and hash performance'::TEXT,
        'MEDIUM'::TEXT
    WHERE pg_size_bytes(current_setting('work_mem')) < 16777216 -- 16MB
    
    ORDER BY impact DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION recommend_config_changes IS 
'Recommends PostgreSQL configuration changes based on current database state';
