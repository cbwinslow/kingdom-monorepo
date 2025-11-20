-- PostgreSQL System Information Queries
-- Useful queries for system monitoring and analysis

-- Function: Get comprehensive database statistics
CREATE OR REPLACE FUNCTION get_database_stats()
RETURNS TABLE (
    metric TEXT,
    value TEXT,
    category TEXT
) AS $$
BEGIN
    RETURN QUERY
    -- Version and uptime
    SELECT 'PostgreSQL Version'::TEXT, version()::TEXT, 'system'::TEXT
    UNION ALL
    SELECT 'Database Name'::TEXT, current_database()::TEXT, 'system'::TEXT
    UNION ALL
    SELECT 'Current User'::TEXT, current_user::TEXT, 'system'::TEXT
    UNION ALL
    SELECT 'Server Uptime'::TEXT, 
           (NOW() - pg_postmaster_start_time())::TEXT, 
           'system'::TEXT
    UNION ALL
    -- Database size
    SELECT 'Total Database Size'::TEXT, 
           pg_size_pretty(pg_database_size(current_database()))::TEXT,
           'size'::TEXT
    UNION ALL
    -- Connection stats
    SELECT 'Active Connections'::TEXT,
           COUNT(*)::TEXT,
           'connections'::TEXT
    FROM pg_stat_activity
    WHERE state = 'active'
    UNION ALL
    SELECT 'Total Connections'::TEXT,
           COUNT(*)::TEXT,
           'connections'::TEXT
    FROM pg_stat_activity
    UNION ALL
    -- Transaction stats
    SELECT 'Transactions Committed'::TEXT,
           SUM(xact_commit)::TEXT,
           'transactions'::TEXT
    FROM pg_stat_database
    WHERE datname = current_database()
    UNION ALL
    SELECT 'Transactions Rolled Back'::TEXT,
           SUM(xact_rollback)::TEXT,
           'transactions'::TEXT
    FROM pg_stat_database
    WHERE datname = current_database();
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_database_stats IS 
'Returns comprehensive database statistics organized by category';

-- Function: Get table statistics with detailed information
CREATE OR REPLACE FUNCTION get_table_stats()
RETURNS TABLE (
    schema_name NAME,
    table_name NAME,
    row_count BIGINT,
    total_size TEXT,
    table_size TEXT,
    index_size TEXT,
    toast_size TEXT,
    last_vacuum TIMESTAMP WITH TIME ZONE,
    last_analyze TIMESTAMP WITH TIME ZONE,
    n_tup_ins BIGINT,
    n_tup_upd BIGINT,
    n_tup_del BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        schemaname::NAME,
        tablename::NAME,
        n_live_tup::BIGINT,
        pg_size_pretty(pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)))::TEXT,
        pg_size_pretty(pg_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)))::TEXT,
        pg_size_pretty(pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)) - 
                      pg_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)))::TEXT,
        pg_size_pretty(COALESCE(pg_total_relation_size(reltoastrelid), 0))::TEXT,
        last_vacuum,
        last_analyze,
        n_tup_ins::BIGINT,
        n_tup_upd::BIGINT,
        n_tup_del::BIGINT
    FROM pg_stat_user_tables
    LEFT JOIN pg_class ON pg_class.oid = (quote_ident(schemaname) || '.' || quote_ident(tablename))::regclass
    ORDER BY pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)) DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_table_stats IS 
'Returns detailed statistics for all user tables including sizes and activity';

-- Function: Get index usage statistics
CREATE OR REPLACE FUNCTION get_index_stats()
RETURNS TABLE (
    schema_name NAME,
    table_name NAME,
    index_name NAME,
    index_size TEXT,
    index_scans BIGINT,
    rows_read BIGINT,
    rows_fetched BIGINT,
    usage_ratio NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        schemaname::NAME,
        tablename::NAME,
        indexrelname::NAME,
        pg_size_pretty(pg_relation_size(indexrelid))::TEXT,
        idx_scan::BIGINT,
        idx_tup_read::BIGINT,
        idx_tup_fetch::BIGINT,
        CASE 
            WHEN idx_scan > 0 THEN ROUND(100.0 * idx_tup_fetch / idx_scan, 2)
            ELSE 0
        END::NUMERIC
    FROM pg_stat_user_indexes
    ORDER BY idx_scan DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_index_stats IS 
'Returns index usage statistics to identify unused or inefficient indexes';

-- Function: Get slow queries (requires pg_stat_statements extension)
CREATE OR REPLACE FUNCTION get_slow_queries(
    min_exec_time_ms INTEGER DEFAULT 1000,
    result_limit INTEGER DEFAULT 20
)
RETURNS TABLE (
    query_text TEXT,
    calls BIGINT,
    total_time_ms NUMERIC,
    mean_time_ms NUMERIC,
    max_time_ms NUMERIC,
    stddev_time_ms NUMERIC,
    rows_avg BIGINT
) AS $$
BEGIN
    -- Check if pg_stat_statements extension exists
    IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_stat_statements') THEN
        RAISE NOTICE 'pg_stat_statements extension not found. Install with: CREATE EXTENSION pg_stat_statements;';
        RETURN;
    END IF;
    
    RETURN QUERY
    EXECUTE format('
        SELECT 
            query::TEXT,
            calls::BIGINT,
            ROUND(total_exec_time::NUMERIC, 2) AS total_time_ms,
            ROUND(mean_exec_time::NUMERIC, 2) AS mean_time_ms,
            ROUND(max_exec_time::NUMERIC, 2) AS max_time_ms,
            ROUND(stddev_exec_time::NUMERIC, 2) AS stddev_time_ms,
            ROUND(rows::NUMERIC / NULLIF(calls, 0))::BIGINT AS rows_avg
        FROM pg_stat_statements
        WHERE mean_exec_time >= %s
        ORDER BY mean_exec_time DESC
        LIMIT %s
    ', min_exec_time_ms, result_limit);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_slow_queries IS 
'Returns slow queries that exceed the specified execution time threshold';

-- Function: Get active connections with details
CREATE OR REPLACE FUNCTION get_active_connections()
RETURNS TABLE (
    pid INTEGER,
    username NAME,
    database_name NAME,
    client_address INET,
    application_name TEXT,
    state TEXT,
    query_start TIMESTAMP WITH TIME ZONE,
    state_change TIMESTAMP WITH TIME ZONE,
    wait_event_type TEXT,
    wait_event TEXT,
    query TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        pg_stat_activity.pid::INTEGER,
        usename::NAME,
        datname::NAME,
        client_addr::INET,
        application_name::TEXT,
        state::TEXT,
        query_start,
        state_change,
        wait_event_type::TEXT,
        wait_event::TEXT,
        query::TEXT
    FROM pg_stat_activity
    WHERE pid <> pg_backend_pid()
    ORDER BY query_start DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_active_connections IS 
'Returns information about all active database connections';

-- Function: Get blocking queries
CREATE OR REPLACE FUNCTION get_blocking_queries()
RETURNS TABLE (
    blocked_pid INTEGER,
    blocked_user NAME,
    blocked_query TEXT,
    blocked_duration INTERVAL,
    blocking_pid INTEGER,
    blocking_user NAME,
    blocking_query TEXT,
    blocking_duration INTERVAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        blocked_activity.pid::INTEGER AS blocked_pid,
        blocked_activity.usename::NAME AS blocked_user,
        blocked_activity.query::TEXT AS blocked_query,
        (NOW() - blocked_activity.query_start)::INTERVAL AS blocked_duration,
        blocking_activity.pid::INTEGER AS blocking_pid,
        blocking_activity.usename::NAME AS blocking_user,
        blocking_activity.query::TEXT AS blocking_query,
        (NOW() - blocking_activity.query_start)::INTERVAL AS blocking_duration
    FROM pg_stat_activity AS blocked_activity
    JOIN pg_stat_activity AS blocking_activity 
        ON blocking_activity.pid = ANY(pg_blocking_pids(blocked_activity.pid))
    WHERE blocked_activity.pid <> pg_backend_pid();
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_blocking_queries IS 
'Identifies queries that are blocking other queries';

-- Function: Get cache hit ratio
CREATE OR REPLACE FUNCTION get_cache_hit_ratio()
RETURNS TABLE (
    cache_type TEXT,
    hit_ratio NUMERIC,
    description TEXT
) AS $$
BEGIN
    RETURN QUERY
    -- Table cache hit ratio
    SELECT 
        'Table Cache'::TEXT,
        ROUND(
            100.0 * SUM(heap_blks_hit) / NULLIF(SUM(heap_blks_hit) + SUM(heap_blks_read), 0),
            2
        )::NUMERIC,
        'Percentage of table blocks served from cache'::TEXT
    FROM pg_statio_user_tables
    UNION ALL
    -- Index cache hit ratio
    SELECT 
        'Index Cache'::TEXT,
        ROUND(
            100.0 * SUM(idx_blks_hit) / NULLIF(SUM(idx_blks_hit) + SUM(idx_blks_read), 0),
            2
        )::NUMERIC,
        'Percentage of index blocks served from cache'::TEXT
    FROM pg_statio_user_tables
    UNION ALL
    -- Overall cache hit ratio
    SELECT 
        'Overall Cache'::TEXT,
        ROUND(
            100.0 * SUM(blks_hit) / NULLIF(SUM(blks_hit) + SUM(blks_read), 0),
            2
        )::NUMERIC,
        'Overall percentage of blocks served from cache'::TEXT
    FROM pg_stat_database
    WHERE datname = current_database();
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_cache_hit_ratio IS 
'Returns cache hit ratios for tables, indexes, and overall database';
