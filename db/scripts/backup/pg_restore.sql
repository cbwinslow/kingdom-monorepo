-- PostgreSQL Restore Operations
-- This script provides utilities for restore operations

-- Function: Check if restore is safe
CREATE OR REPLACE FUNCTION check_restore_safety(
    target_database TEXT
)
RETURNS TABLE (
    is_safe BOOLEAN,
    warning_message TEXT,
    active_connections INTEGER,
    database_size TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (COUNT(*) FILTER (WHERE datname = target_database AND pid IS NOT NULL) = 0)::BOOLEAN,
        CASE 
            WHEN COUNT(*) FILTER (WHERE datname = target_database AND pid IS NOT NULL) > 0 
            THEN 'WARNING: Active connections detected. Close connections before restore.'
            ELSE 'Safe to proceed with restore'
        END::TEXT,
        COUNT(*) FILTER (WHERE datname = target_database AND pid IS NOT NULL)::INTEGER,
        pg_size_pretty(pg_database_size(target_database))::TEXT
    FROM pg_stat_activity;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION check_restore_safety IS 
'Checks if it is safe to perform a restore operation on a database';

-- Function: Kill all connections to a database (use with caution!)
CREATE OR REPLACE FUNCTION terminate_database_connections(
    target_database TEXT,
    exclude_current BOOLEAN DEFAULT true
)
RETURNS INTEGER AS $$
DECLARE
    connection_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO connection_count
    FROM pg_stat_activity
    WHERE datname = target_database
    AND (NOT exclude_current OR pid <> pg_backend_pid());
    
    PERFORM pg_terminate_backend(pid)
    FROM pg_stat_activity
    WHERE datname = target_database
    AND (NOT exclude_current OR pid <> pg_backend_pid());
    
    RETURN connection_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION terminate_database_connections IS 
'Terminates all connections to a database. Use with caution!';

-- Function: Prepare database for restore
CREATE OR REPLACE FUNCTION prepare_for_restore(
    target_database TEXT
)
RETURNS TABLE (
    step TEXT,
    status TEXT,
    details TEXT
) AS $$
DECLARE
    terminated_count INTEGER;
    db_size TEXT;
BEGIN
    -- Step 1: Check database exists
    IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = target_database) THEN
        RETURN QUERY SELECT 
            'check_database'::TEXT,
            'error'::TEXT,
            'Database does not exist'::TEXT;
        RETURN;
    END IF;
    
    RETURN QUERY SELECT 
        'check_database'::TEXT,
        'success'::TEXT,
        'Database exists'::TEXT;
    
    -- Step 2: Get current size
    SELECT pg_size_pretty(pg_database_size(target_database)) INTO db_size;
    
    RETURN QUERY SELECT 
        'get_size'::TEXT,
        'success'::TEXT,
        format('Current size: %s', db_size)::TEXT;
    
    -- Step 3: Terminate connections
    SELECT terminate_database_connections(target_database) INTO terminated_count;
    
    RETURN QUERY SELECT 
        'terminate_connections'::TEXT,
        'success'::TEXT,
        format('Terminated %s connections', terminated_count)::TEXT;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION prepare_for_restore IS 
'Prepares a database for restore by checking status and terminating connections';

-- Function: Validate backup file info (to be used with external tools)
CREATE OR REPLACE FUNCTION log_restore_start(
    p_database_name VARCHAR(255),
    p_backup_location TEXT,
    p_backup_size_bytes BIGINT DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
    restore_id INTEGER;
BEGIN
    INSERT INTO backup_audit (backup_type, database_name, backup_location, backup_size_bytes, status)
    VALUES ('restore', p_database_name, p_backup_location, p_backup_size_bytes, 'started')
    RETURNING id INTO restore_id;
    
    RETURN restore_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION log_restore_start IS 
'Logs the start of a restore operation';

-- Function: Create a pre-restore snapshot of schema
CREATE OR REPLACE FUNCTION create_schema_snapshot(
    snapshot_name TEXT DEFAULT NULL
)
RETURNS TEXT AS $$
DECLARE
    snapshot_timestamp TEXT;
    snapshot_identifier TEXT;
BEGIN
    snapshot_timestamp := to_char(current_timestamp, 'YYYY-MM-DD_HH24-MI-SS');
    snapshot_identifier := COALESCE(snapshot_name, 'schema_snapshot_' || snapshot_timestamp);
    
    -- Create a table to store schema information
    EXECUTE format('
        CREATE TABLE IF NOT EXISTS schema_snapshots (
            id SERIAL PRIMARY KEY,
            snapshot_name TEXT NOT NULL,
            snapshot_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            table_count INTEGER,
            view_count INTEGER,
            function_count INTEGER,
            schema_details JSONB
        )
    ');
    
    -- Insert snapshot information
    EXECUTE format('
        INSERT INTO schema_snapshots (snapshot_name, table_count, view_count, function_count, schema_details)
        SELECT 
            %L,
            (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema NOT IN (''pg_catalog'', ''information_schema'')),
            (SELECT COUNT(*) FROM information_schema.views WHERE table_schema NOT IN (''pg_catalog'', ''information_schema'')),
            (SELECT COUNT(*) FROM pg_proc WHERE pronamespace NOT IN (SELECT oid FROM pg_namespace WHERE nspname IN (''pg_catalog'', ''information_schema''))),
            jsonb_build_object(
                ''tables'', (SELECT jsonb_agg(table_name) FROM information_schema.tables WHERE table_schema = ''public''),
                ''views'', (SELECT jsonb_agg(table_name) FROM information_schema.views WHERE table_schema = ''public'')
            )
    ', snapshot_identifier);
    
    RETURN snapshot_identifier;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION create_schema_snapshot IS 
'Creates a snapshot of the current schema before restore operations';
