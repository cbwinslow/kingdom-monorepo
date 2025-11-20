-- PostgreSQL Backup Operations
-- This script provides utilities for backup operations

-- Function: Create a custom backup function with timestamp
CREATE OR REPLACE FUNCTION create_backup_with_timestamp(
    backup_path TEXT,
    database_name TEXT DEFAULT current_database()
)
RETURNS TEXT AS $$
DECLARE
    timestamp_str TEXT;
    backup_command TEXT;
BEGIN
    timestamp_str := to_char(current_timestamp, 'YYYY-MM-DD_HH24-MI-SS');
    backup_command := format('pg_dump -Fc -f %s/%s_%s.backup %s', 
                            backup_path, 
                            database_name, 
                            timestamp_str, 
                            database_name);
    RETURN backup_command;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION create_backup_with_timestamp IS 
'Generates a pg_dump command with timestamp for backup operations';

-- Function: Get database size for backup planning
CREATE OR REPLACE FUNCTION get_database_size_info()
RETURNS TABLE (
    database_name NAME,
    size_bytes BIGINT,
    size_pretty TEXT,
    backup_estimate_minutes NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        datname::NAME,
        pg_database_size(datname)::BIGINT,
        pg_size_pretty(pg_database_size(datname))::TEXT,
        ROUND((pg_database_size(datname)::NUMERIC / 1024 / 1024 / 100), 2)::NUMERIC -- Rough estimate: 100MB per minute
    FROM pg_database
    WHERE datistemplate = false
    ORDER BY pg_database_size(datname) DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_database_size_info IS 
'Returns database sizes with backup time estimates';

-- Function: Check last backup age (requires audit table)
CREATE OR REPLACE FUNCTION create_backup_audit_table()
RETURNS void AS $$
BEGIN
    CREATE TABLE IF NOT EXISTS backup_audit (
        id SERIAL PRIMARY KEY,
        backup_type VARCHAR(50) NOT NULL,
        database_name VARCHAR(255) NOT NULL,
        backup_location TEXT,
        backup_size_bytes BIGINT,
        started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        completed_at TIMESTAMP WITH TIME ZONE,
        status VARCHAR(20) CHECK (status IN ('started', 'completed', 'failed')),
        error_message TEXT,
        created_by VARCHAR(255) DEFAULT CURRENT_USER
    );
    
    CREATE INDEX IF NOT EXISTS idx_backup_audit_database ON backup_audit(database_name);
    CREATE INDEX IF NOT EXISTS idx_backup_audit_started ON backup_audit(started_at);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION create_backup_audit_table IS 
'Creates an audit table to track backup operations';

-- Function: Log backup operation
CREATE OR REPLACE FUNCTION log_backup_start(
    p_backup_type VARCHAR(50),
    p_database_name VARCHAR(255),
    p_backup_location TEXT DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
    backup_id INTEGER;
BEGIN
    INSERT INTO backup_audit (backup_type, database_name, backup_location, status)
    VALUES (p_backup_type, p_database_name, p_backup_location, 'started')
    RETURNING id INTO backup_id;
    
    RETURN backup_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION log_backup_start IS 
'Logs the start of a backup operation and returns the backup ID';

-- Function: Complete backup log
CREATE OR REPLACE FUNCTION log_backup_complete(
    p_backup_id INTEGER,
    p_backup_size_bytes BIGINT DEFAULT NULL
)
RETURNS void AS $$
BEGIN
    UPDATE backup_audit 
    SET completed_at = CURRENT_TIMESTAMP,
        status = 'completed',
        backup_size_bytes = p_backup_size_bytes
    WHERE id = p_backup_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION log_backup_complete IS 
'Marks a backup operation as completed';

-- Function: Get tables that need backup (large tables first)
CREATE OR REPLACE FUNCTION get_tables_for_backup()
RETURNS TABLE (
    schema_name NAME,
    table_name NAME,
    row_count BIGINT,
    total_size_bytes BIGINT,
    total_size_pretty TEXT,
    priority INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        schemaname::NAME,
        tablename::NAME,
        n_live_tup::BIGINT AS row_count,
        pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename))::BIGINT,
        pg_size_pretty(pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)))::TEXT,
        CASE 
            WHEN pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)) > 1073741824 THEN 1  -- > 1GB
            WHEN pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)) > 104857600 THEN 2   -- > 100MB
            ELSE 3
        END AS priority
    FROM pg_stat_user_tables
    ORDER BY pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)) DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_tables_for_backup IS 
'Returns tables ordered by size with backup priority';
