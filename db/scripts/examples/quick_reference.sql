-- Quick Reference Guide for Database SQL Scripts
-- Common queries and functions for daily database operations

-- ============================================
-- HEALTH CHECKS
-- ============================================

-- Get overall database statistics
SELECT * FROM get_database_stats() ORDER BY category, metric;

-- Check cache hit ratios (should be > 95%)
SELECT * FROM get_cache_hit_ratio();

-- Find blocking queries
SELECT * FROM get_blocking_queries();

-- Get active connections
SELECT * FROM get_active_connections() ORDER BY query_start DESC LIMIT 10;


-- ============================================
-- PERFORMANCE MONITORING
-- ============================================

-- Generate comprehensive performance report
SELECT * FROM generate_performance_report() ORDER BY section, status;

-- Find long-running queries (> 60 seconds)
SELECT * FROM find_long_running_queries(60);

-- Find slow queries (requires pg_stat_statements extension)
-- SELECT * FROM get_slow_queries(1000, 20);

-- Get detailed table statistics
SELECT * FROM get_table_stats() ORDER BY total_size DESC LIMIT 20;

-- Get index usage statistics
SELECT * FROM get_index_stats() ORDER BY index_scans DESC LIMIT 20;


-- ============================================
-- MAINTENANCE
-- ============================================

-- Find tables that need vacuuming (> 1000 dead tuples)
SELECT * FROM get_tables_needing_vacuum(1000) ORDER BY priority, dead_tuple_percent DESC;

-- Find tables that need analyzing (> 7 days)
SELECT * FROM get_tables_needing_analyze(7) ORDER BY priority, days_since_analyze DESC;

-- Estimate table bloat
SELECT * FROM get_table_bloat() WHERE bloat_percent > 20 ORDER BY bloat_percent DESC;

-- Generate vacuum commands
SELECT * FROM generate_vacuum_commands('public', false, true);


-- ============================================
-- INDEX OPTIMIZATION
-- ============================================

-- Find unused indexes (> 1MB in size)
SELECT * FROM find_unused_indexes(1) ORDER BY index_size DESC;

-- Find duplicate indexes
SELECT * FROM find_duplicate_indexes();

-- Get index health metrics
SELECT * FROM get_index_health() WHERE health_status != 'HEALTHY';

-- Get maintenance recommendations
SELECT * FROM recommend_index_maintenance();

-- Analyze index usage patterns
SELECT * FROM analyze_index_usage_patterns('public') ORDER BY unused_indexes DESC;


-- ============================================
-- DATA TYPE ANALYSIS
-- ============================================

-- Analyze data types in schema
SELECT * FROM analyze_data_types('public') 
WHERE recommendation != 'Type appears appropriate' 
ORDER BY table_name, column_name;

-- Find inconsistent data types across tables
SELECT * FROM find_inconsistent_data_types() ORDER BY table_count DESC;

-- Optimize numeric types
SELECT * FROM optimize_numeric_types('public');

-- Standardize timestamps to TIMESTAMPTZ
SELECT * FROM standardize_timestamps_to_timestamptz('public', true);


-- ============================================
-- CONSTRAINT ANALYSIS
-- ============================================

-- Analyze foreign key relationships
SELECT * FROM analyze_foreign_keys('public') ORDER BY from_table;

-- Find missing FK indexes
SELECT * FROM find_missing_fk_indexes('public');

-- Find tables without primary keys
SELECT * FROM find_tables_without_primary_keys('public') ORDER BY row_count DESC;

-- Validate constraint naming
SELECT * FROM validate_constraint_naming('public') WHERE NOT is_compliant;


-- ============================================
-- BACKUP PLANNING
-- ============================================

-- Get database size information for backup planning
SELECT * FROM get_database_size_info();

-- Get tables prioritized for backup
SELECT * FROM get_tables_for_backup() LIMIT 20;

-- Create backup audit table (run once)
-- SELECT create_backup_audit_table();


-- ============================================
-- UTILITY FUNCTIONS - EXAMPLES
-- ============================================

-- String functions
SELECT 
    safe_substring('Hello World', 1, 5) as substring_example,
    slugify('Hello World! This is a Test') as slug_example,
    mask_sensitive_data('1234567890', '*', 0, 4) as masked_example,
    format_phone_number('5551234567', 'US') as phone_example,
    word_count('This is a test sentence') as word_count_example;

-- Date/time functions
SELECT 
    age_in_years('1990-01-15') as age_example,
    business_days_between('2024-01-01', '2024-01-31') as business_days_example,
    add_business_days(CURRENT_DATE, 10) as future_business_day,
    start_of_week(CURRENT_DATE) as week_start,
    end_of_month(CURRENT_DATE) as month_end;

-- Numeric functions
SELECT 
    safe_divide(10, 3, 0) as safe_division,
    safe_percentage(25, 100) as percentage,
    format_currency(1234.56, '$') as currency,
    clamp_value(150, 0, 100) as clamped_value,
    is_in_range(50, 0, 100) as in_range_check;


-- ============================================
-- CLEANUP & MAINTENANCE OPERATIONS
-- ============================================

-- Kill idle transactions (dry run first!)
SELECT * FROM kill_idle_transactions(30, true);

-- Safely vacuum a specific table (dry run)
SELECT * FROM safe_vacuum_table('public', 'your_table_name', false, true, false);

-- Get configuration recommendations
SELECT * FROM recommend_config_changes();


-- ============================================
-- MONITORING SETUP
-- ============================================

-- Enable pg_stat_statements extension (if not already enabled)
-- CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Enable unaccent extension for enhanced string functions
-- CREATE EXTENSION IF NOT EXISTS unaccent;

-- Create backup audit table for tracking backups
-- SELECT create_backup_audit_table();


-- ============================================
-- TROUBLESHOOTING
-- ============================================

-- Find tables with fragmentation issues
SELECT * FROM get_table_fragmentation('public') 
WHERE fragmentation_status IN ('HIGH', 'MEDIUM')
ORDER BY free_space_percent DESC;

-- Detailed table analysis
SELECT * FROM analyze_table_detailed('public', 'your_table_name');

-- Check restore safety before restore operation
-- SELECT * FROM check_restore_safety('your_database_name');
