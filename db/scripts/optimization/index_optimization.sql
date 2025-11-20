-- PostgreSQL Index Optimization
-- Scripts for analyzing and optimizing database indexes

-- Function: Find unused indexes
CREATE OR REPLACE FUNCTION find_unused_indexes(
    min_size_mb INTEGER DEFAULT 1
)
RETURNS TABLE (
    schema_name NAME,
    table_name NAME,
    index_name NAME,
    index_size TEXT,
    index_scans BIGINT,
    table_scans BIGINT,
    recommendation TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        schemaname::NAME,
        tablename::NAME,
        indexrelname::NAME,
        pg_size_pretty(pg_relation_size(indexrelid))::TEXT,
        idx_scan::BIGINT,
        seq_scan::BIGINT,
        CASE 
            WHEN idx_scan = 0 AND pg_relation_size(indexrelid) > min_size_mb * 1024 * 1024 
                THEN 'DROP - Never used and takes up space'
            WHEN idx_scan < 10 AND seq_scan > 1000 
                THEN 'CONSIDER DROPPING - Rarely used, table is frequently scanned'
            WHEN idx_scan < 100 AND pg_relation_size(indexrelid) > 100 * 1024 * 1024 
                THEN 'REVIEW - Low usage for large index'
            ELSE 'KEEP - Regular usage'
        END::TEXT
    FROM pg_stat_user_indexes
    JOIN pg_stat_user_tables USING (schemaname, tablename)
    WHERE pg_relation_size(indexrelid) > min_size_mb * 1024 * 1024
    ORDER BY 
        CASE 
            WHEN idx_scan = 0 THEN 1
            WHEN idx_scan < 10 THEN 2
            ELSE 3
        END,
        pg_relation_size(indexrelid) DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION find_unused_indexes IS 
'Identifies unused or rarely used indexes that may be candidates for removal';

-- Function: Find duplicate indexes
CREATE OR REPLACE FUNCTION find_duplicate_indexes()
RETURNS TABLE (
    schema_name TEXT,
    table_name TEXT,
    index1_name TEXT,
    index2_name TEXT,
    index1_definition TEXT,
    index2_definition TEXT,
    index1_size TEXT,
    index2_size TEXT,
    recommendation TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        n.nspname::TEXT AS schema_name,
        t.relname::TEXT AS table_name,
        i1.relname::TEXT AS index1_name,
        i2.relname::TEXT AS index2_name,
        pg_get_indexdef(i1.oid)::TEXT AS index1_definition,
        pg_get_indexdef(i2.oid)::TEXT AS index2_definition,
        pg_size_pretty(pg_relation_size(i1.oid))::TEXT AS index1_size,
        pg_size_pretty(pg_relation_size(i2.oid))::TEXT AS index2_size,
        'Consider dropping the smaller or less used index'::TEXT AS recommendation
    FROM pg_class t
    JOIN pg_namespace n ON n.oid = t.relnamespace
    JOIN pg_index ix1 ON t.oid = ix1.indrelid
    JOIN pg_class i1 ON i1.oid = ix1.indexrelid
    JOIN pg_index ix2 ON t.oid = ix2.indrelid AND ix1.indexrelid < ix2.indexrelid
    JOIN pg_class i2 ON i2.oid = ix2.indexrelid
    WHERE 
        n.nspname NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
        AND ix1.indkey::TEXT = ix2.indkey::TEXT
        AND i1.oid <> i2.oid
    ORDER BY n.nspname, t.relname, i1.relname;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION find_duplicate_indexes IS 
'Identifies duplicate indexes on the same columns';

-- Function: Find missing indexes (based on sequential scans)
CREATE OR REPLACE FUNCTION find_missing_indexes(
    min_seq_scans INTEGER DEFAULT 1000,
    min_table_size_mb INTEGER DEFAULT 10
)
RETURNS TABLE (
    schema_name NAME,
    table_name NAME,
    seq_scans BIGINT,
    seq_tup_read BIGINT,
    table_size TEXT,
    avg_rows_per_scan BIGINT,
    recommendation TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        schemaname::NAME,
        tablename::NAME,
        seq_scan::BIGINT,
        seq_tup_read::BIGINT,
        pg_size_pretty(pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)))::TEXT,
        CASE 
            WHEN seq_scan > 0 THEN (seq_tup_read / seq_scan)::BIGINT
            ELSE 0
        END AS avg_rows_per_scan,
        CASE 
            WHEN seq_scan > min_seq_scans * 10 THEN 'HIGH PRIORITY - Add indexes on frequently queried columns'
            WHEN seq_scan > min_seq_scans THEN 'MEDIUM PRIORITY - Consider adding indexes'
            ELSE 'LOW PRIORITY - Monitor performance'
        END::TEXT
    FROM pg_stat_user_tables
    WHERE seq_scan > min_seq_scans
      AND pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)) > min_table_size_mb * 1024 * 1024
    ORDER BY seq_scan DESC, pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)) DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION find_missing_indexes IS 
'Suggests tables that might benefit from additional indexes based on sequential scan patterns';

-- Function: Get index health metrics
CREATE OR REPLACE FUNCTION get_index_health()
RETURNS TABLE (
    schema_name NAME,
    table_name NAME,
    index_name NAME,
    index_type TEXT,
    index_size TEXT,
    index_scans BIGINT,
    tuples_read BIGINT,
    tuples_fetched BIGINT,
    efficiency_ratio NUMERIC,
    bloat_estimate TEXT,
    health_status TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        schemaname::NAME,
        tablename::NAME,
        indexrelname::NAME,
        am.amname::TEXT AS index_type,
        pg_size_pretty(pg_relation_size(indexrelid))::TEXT,
        idx_scan::BIGINT,
        idx_tup_read::BIGINT,
        idx_tup_fetch::BIGINT,
        CASE 
            WHEN idx_tup_read > 0 
            THEN ROUND(100.0 * idx_tup_fetch / idx_tup_read, 2)
            ELSE 0
        END::NUMERIC AS efficiency_ratio,
        'N/A'::TEXT AS bloat_estimate, -- Simplified; full bloat calculation is complex
        CASE 
            WHEN idx_scan = 0 THEN 'UNUSED'
            WHEN idx_scan < 10 THEN 'RARELY USED'
            WHEN idx_tup_read > 0 AND (100.0 * idx_tup_fetch / idx_tup_read) < 50 THEN 'LOW EFFICIENCY'
            ELSE 'HEALTHY'
        END::TEXT
    FROM pg_stat_user_indexes
    JOIN pg_index USING (indexrelid)
    JOIN pg_class ON pg_class.oid = indexrelid
    JOIN pg_am am ON pg_class.relam = am.oid
    ORDER BY 
        CASE 
            WHEN idx_scan = 0 THEN 1
            WHEN idx_scan < 10 THEN 2
            ELSE 3
        END,
        pg_relation_size(indexrelid) DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_index_health IS 
'Provides comprehensive health metrics for all indexes';

-- Function: Recommend index maintenance actions
CREATE OR REPLACE FUNCTION recommend_index_maintenance()
RETURNS TABLE (
    schema_name TEXT,
    table_name TEXT,
    index_name TEXT,
    action TEXT,
    reason TEXT,
    impact TEXT,
    command TEXT
) AS $$
BEGIN
    RETURN QUERY
    -- Unused indexes
    SELECT 
        schemaname::TEXT,
        tablename::TEXT,
        indexrelname::TEXT,
        'DROP'::TEXT,
        format('Index has %s scans and size %s', idx_scan, pg_size_pretty(pg_relation_size(indexrelid)))::TEXT,
        'Reduce storage, improve write performance'::TEXT,
        format('DROP INDEX IF EXISTS %I.%I;', schemaname, indexrelname)::TEXT
    FROM pg_stat_user_indexes
    WHERE idx_scan < 10
      AND pg_relation_size(indexrelid) > 10 * 1024 * 1024
    
    UNION ALL
    
    -- Indexes on tables with high sequential scans
    SELECT 
        schemaname::TEXT,
        tablename::TEXT,
        'N/A'::TEXT,
        'ADD INDEX'::TEXT,
        format('Table has %s sequential scans, %s rows read', seq_scan, seq_tup_read)::TEXT,
        'Improve query performance'::TEXT,
        format('-- Analyze queries and add appropriate indexes on table %I.%I', schemaname, tablename)::TEXT
    FROM pg_stat_user_tables
    WHERE seq_scan > 5000
      AND pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)) > 50 * 1024 * 1024
      AND NOT EXISTS (
          SELECT 1 FROM pg_stat_user_indexes 
          WHERE pg_stat_user_indexes.schemaname = pg_stat_user_tables.schemaname 
            AND pg_stat_user_indexes.tablename = pg_stat_user_tables.tablename
      )
    
    ORDER BY 1, 2, 3;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION recommend_index_maintenance IS 
'Provides actionable recommendations for index maintenance with SQL commands';

-- Function: Generate reindex commands
CREATE OR REPLACE FUNCTION generate_reindex_commands(
    p_schema_name TEXT DEFAULT 'public',
    concurrent BOOLEAN DEFAULT true
)
RETURNS TABLE (
    index_name TEXT,
    table_name TEXT,
    index_size TEXT,
    reindex_command TEXT,
    estimated_time TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        indexrelname::TEXT,
        tablename::TEXT,
        pg_size_pretty(pg_relation_size(indexrelid))::TEXT,
        format('REINDEX INDEX %s %I.%I;', 
               CASE WHEN concurrent THEN 'CONCURRENTLY' ELSE '' END,
               schemaname,
               indexrelname)::TEXT,
        CASE 
            WHEN pg_relation_size(indexrelid) > 10737418240 THEN '> 1 hour'
            WHEN pg_relation_size(indexrelid) > 1073741824 THEN '10-60 minutes'
            WHEN pg_relation_size(indexrelid) > 104857600 THEN '1-10 minutes'
            ELSE '< 1 minute'
        END::TEXT
    FROM pg_stat_user_indexes
    WHERE schemaname = p_schema_name
    ORDER BY pg_relation_size(indexrelid) DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generate_reindex_commands IS 
'Generates REINDEX commands for indexes with time estimates';

-- Function: Analyze index usage patterns
CREATE OR REPLACE FUNCTION analyze_index_usage_patterns(
    p_schema_name TEXT DEFAULT 'public',
    p_table_name TEXT DEFAULT NULL
)
RETURNS TABLE (
    schema_name NAME,
    table_name NAME,
    total_indexes INTEGER,
    used_indexes INTEGER,
    unused_indexes INTEGER,
    total_index_size TEXT,
    average_scans_per_index BIGINT,
    recommendation TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        schemaname::NAME,
        tablename::NAME,
        COUNT(*)::INTEGER AS total_indexes,
        COUNT(*) FILTER (WHERE idx_scan > 0)::INTEGER AS used_indexes,
        COUNT(*) FILTER (WHERE idx_scan = 0)::INTEGER AS unused_indexes,
        pg_size_pretty(SUM(pg_relation_size(indexrelid)))::TEXT,
        AVG(idx_scan)::BIGINT,
        CASE 
            WHEN COUNT(*) FILTER (WHERE idx_scan = 0) > COUNT(*) / 2 
                THEN 'Review unused indexes - more than 50% are not being used'
            WHEN COUNT(*) FILTER (WHERE idx_scan = 0) > 0 
                THEN 'Some indexes are unused - consider reviewing them'
            ELSE 'All indexes are being used'
        END::TEXT
    FROM pg_stat_user_indexes
    WHERE schemaname = p_schema_name
      AND (p_table_name IS NULL OR tablename = p_table_name)
    GROUP BY schemaname, tablename
    ORDER BY COUNT(*) FILTER (WHERE idx_scan = 0) DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION analyze_index_usage_patterns IS 
'Analyzes index usage patterns at the table level';
