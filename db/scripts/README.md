# Database SQL Scripts

A comprehensive collection of standardized SQL scripts, queries, and utility functions for PostgreSQL database operations, maintenance, and optimization.

## 📁 Directory Structure

```
scripts/
├── backup/              # Backup and restore operations
├── queries/             # System information and monitoring queries
├── optimization/        # Performance optimization scripts
├── normalization/       # Data type and constraint management
├── functions/           # Enhanced utility functions
└── utilities/          # Performance and maintenance helpers
```

## 🔧 Installation

To install all functions in your database:

```bash
# Install all scripts at once
psql -d your_database -f backup/pg_backup.sql
psql -d your_database -f backup/pg_restore.sql
psql -d your_database -f queries/system_info.sql
psql -d your_database -f optimization/vacuum_analyze.sql
psql -d your_database -f optimization/index_optimization.sql
psql -d your_database -f normalization/data_type_operations.sql
psql -d your_database -f normalization/constraint_helpers.sql
psql -d your_database -f functions/string_functions.sql
psql -d your_database -f functions/date_time_functions.sql
psql -d your_database -f functions/numeric_functions.sql
psql -d your_database -f utilities/performance_helpers.sql
```

Or use a single command to install all:

```bash
for file in backup/*.sql queries/*.sql optimization/*.sql normalization/*.sql functions/*.sql utilities/*.sql; do
    psql -d your_database -f "$file"
done
```

## 📚 Module Documentation

### Backup Operations (`backup/`)

#### pg_backup.sql
Functions for database backup operations:

- **`create_backup_with_timestamp(backup_path, database_name)`** - Generates timestamped backup commands
- **`get_database_size_info()`** - Returns database sizes with backup time estimates
- **`create_backup_audit_table()`** - Creates audit table for tracking backups
- **`log_backup_start(type, database, location)`** - Logs backup operation start
- **`log_backup_complete(backup_id, size)`** - Marks backup as completed
- **`get_tables_for_backup()`** - Lists tables prioritized by size for backup

**Example Usage:**
```sql
-- Get database size information
SELECT * FROM get_database_size_info();

-- Create backup audit table
SELECT create_backup_audit_table();

-- Get tables prioritized for backup
SELECT * FROM get_tables_for_backup();
```

#### pg_restore.sql
Functions for database restore operations:

- **`check_restore_safety(target_database)`** - Validates if restore is safe
- **`terminate_database_connections(target_database)`** - Closes all connections
- **`prepare_for_restore(target_database)`** - Prepares database for restore
- **`log_restore_start(database, location, size)`** - Logs restore operation
- **`create_schema_snapshot(snapshot_name)`** - Creates schema snapshot before restore

**Example Usage:**
```sql
-- Check if restore is safe
SELECT * FROM check_restore_safety('mydb');

-- Prepare database for restore
SELECT * FROM prepare_for_restore('mydb');
```

### System Queries (`queries/`)

#### system_info.sql
Functions for monitoring and system information:

- **`get_database_stats()`** - Comprehensive database statistics
- **`get_table_stats()`** - Detailed table statistics with sizes
- **`get_index_stats()`** - Index usage statistics
- **`get_slow_queries(min_time, limit)`** - Identifies slow queries (requires pg_stat_statements)
- **`get_active_connections()`** - Lists all active connections
- **`get_blocking_queries()`** - Identifies blocking queries
- **`get_cache_hit_ratio()`** - Cache performance metrics

**Example Usage:**
```sql
-- Get database overview
SELECT * FROM get_database_stats();

-- Find slow queries (> 1 second)
SELECT * FROM get_slow_queries(1000, 10);

-- Check cache hit ratios
SELECT * FROM get_cache_hit_ratio();

-- Find blocking queries
SELECT * FROM get_blocking_queries();
```

### Optimization (`optimization/`)

#### vacuum_analyze.sql
Functions for vacuum and analyze operations:

- **`get_tables_needing_vacuum(threshold)`** - Tables requiring vacuum
- **`get_tables_needing_analyze(days)`** - Tables requiring analyze
- **`generate_vacuum_commands(schema, full, analyze)`** - Generates vacuum commands
- **`safe_vacuum_table(schema, table, full, analyze)`** - Safely vacuums a table
- **`get_table_bloat()`** - Estimates table bloat
- **`analyze_maintenance_window(schema)`** - Plans maintenance windows

**Example Usage:**
```sql
-- Find tables that need vacuuming
SELECT * FROM get_tables_needing_vacuum(1000);

-- Safely vacuum a specific table
SELECT * FROM safe_vacuum_table('public', 'users', false, true);

-- Estimate table bloat
SELECT * FROM get_table_bloat();

-- Plan maintenance window
SELECT * FROM analyze_maintenance_window('public');
```

#### index_optimization.sql
Functions for index analysis and optimization:

- **`find_unused_indexes(min_size_mb)`** - Identifies unused indexes
- **`find_duplicate_indexes()`** - Finds duplicate indexes
- **`find_missing_indexes(min_scans, min_size_mb)`** - Suggests missing indexes
- **`get_index_health()`** - Comprehensive index health metrics
- **`recommend_index_maintenance()`** - Actionable maintenance recommendations
- **`generate_reindex_commands(schema, concurrent)`** - Generates reindex commands
- **`analyze_index_usage_patterns(schema, table)`** - Analyzes index usage

**Example Usage:**
```sql
-- Find unused indexes
SELECT * FROM find_unused_indexes(10);

-- Find duplicate indexes
SELECT * FROM find_duplicate_indexes();

-- Get index health report
SELECT * FROM get_index_health();

-- Get maintenance recommendations
SELECT * FROM recommend_index_maintenance();
```

### Normalization (`normalization/`)

#### data_type_operations.sql
Functions for data type analysis and optimization:

- **`analyze_data_types(schema)`** - Analyzes data types with recommendations
- **`find_inconsistent_data_types()`** - Finds columns with inconsistent types
- **`generate_type_conversion_commands(schema, table, column, target_type)`** - Generates conversion commands
- **`safe_convert_column_type(schema, table, column, target_type, dry_run)`** - Safely converts column types
- **`standardize_timestamps_to_timestamptz(schema, dry_run)`** - Converts timestamps to TIMESTAMPTZ
- **`optimize_numeric_types(schema)`** - Suggests numeric type optimizations

**Example Usage:**
```sql
-- Analyze data types
SELECT * FROM analyze_data_types('public');

-- Find inconsistent data types across tables
SELECT * FROM find_inconsistent_data_types();

-- Generate safe conversion commands
SELECT * FROM generate_type_conversion_commands('public', 'users', 'age', 'INTEGER');

-- Optimize numeric types
SELECT * FROM optimize_numeric_types('public');
```

#### constraint_helpers.sql
Functions for constraint management:

- **`analyze_foreign_keys(schema)`** - Analyzes foreign key relationships
- **`find_missing_fk_indexes(schema)`** - Finds missing FK indexes
- **`analyze_check_constraints(schema)`** - Lists check constraints
- **`find_tables_without_primary_keys(schema)`** - Identifies tables without PKs
- **`generate_constraint_validation_commands(schema, table)`** - Generates validation commands
- **`safe_add_foreign_key(schema, table, column, ref_table, ref_column, ...)`** - Safely adds FKs
- **`validate_constraint_naming(schema)`** - Validates naming conventions

**Example Usage:**
```sql
-- Analyze foreign keys
SELECT * FROM analyze_foreign_keys('public');

-- Find missing indexes on foreign keys
SELECT * FROM find_missing_fk_indexes('public');

-- Find tables without primary keys
SELECT * FROM find_tables_without_primary_keys('public');

-- Safely add a foreign key
SELECT * FROM safe_add_foreign_key('public', 'orders', 'user_id', 'users', 'id', null, 'CASCADE', 'CASCADE', true);
```

### Utility Functions (`functions/`)

#### string_functions.sql
Enhanced string manipulation functions:

- **`safe_substring(text, start, length)`** - Bounds-checked substring
- **`smart_trim(text, trim_internal)`** - Enhanced whitespace trimming
- **`safe_concat(separator, ...strings)`** - NULL-safe concatenation
- **`truncate_with_ellipsis(text, max_length, ellipsis)`** - Smart truncation
- **`to_title_case(text)`** - Title case conversion
- **`slugify(text, separator)`** - URL-friendly slugs
- **`extract_numbers(text, as_array)`** - Extract numeric values
- **`safe_string_equals(str1, str2, case_sensitive)`** - NULL-safe comparison
- **`format_phone_number(phone, format_type)`** - Phone number formatting
- **`mask_sensitive_data(text, mask_char, visible_start, visible_end)`** - Data masking
- **`word_count(text)`** - Count words in text

**Example Usage:**
```sql
-- Safe substring with auto-bounds checking
SELECT safe_substring('Hello World', 1, 5); -- 'Hello'

-- Create URL slug
SELECT slugify('Hello World! This is a Test'); -- 'hello-world-this-is-a-test'

-- Mask sensitive data
SELECT mask_sensitive_data('1234567890', '*', 0, 4); -- '******7890'

-- Format phone number
SELECT format_phone_number('5551234567', 'US'); -- '(555) 123-4567'
```

#### date_time_functions.sql
Enhanced date/time manipulation functions:

- **`safe_parse_date(date_string, format, fallback)`** - Safe date parsing
- **`safe_parse_timestamp(timestamp_string, format, fallback)`** - Safe timestamp parsing
- **`age_in_years(birth_date, reference_date)`** - Calculate age
- **`business_days_between(start_date, end_date)`** - Count business days
- **`add_business_days(start_date, days)`** - Add business days
- **`is_business_day(date)`** - Check if business day
- **`start_of_week/month/quarter(date)`** - Get period starts
- **`end_of_week/month/quarter(date)`** - Get period ends
- **`time_elapsed_human(start, end)`** - Human-readable time differences
- **`is_date_in_range(date, start, end)`** - Range checking
- **`date_ranges_overlap(start1, end1, start2, end2)`** - Overlap detection

**Example Usage:**
```sql
-- Calculate age
SELECT age_in_years('1990-01-15'); -- Age in years

-- Count business days between dates
SELECT business_days_between('2024-01-01', '2024-01-31');

-- Add 10 business days
SELECT add_business_days(CURRENT_DATE, 10);

-- Get start of current week
SELECT start_of_week(CURRENT_DATE);

-- Human-readable time elapsed
SELECT time_elapsed_human('2024-01-01 10:00:00'::timestamptz);
```

#### numeric_functions.sql
Enhanced numeric operations:

- **`safe_divide(numerator, denominator, default)`** - Division with zero protection
- **`safe_percentage(part, total, decimals)`** - Percentage calculation
- **`clamp_value(value, min, max)`** - Constrain to range
- **`is_in_range(value, min, max, inclusive)`** - Range checking
- **`round_to_significant_figures(value, sig_figs)`** - Significant figures rounding
- **`format_number_with_separator(value, decimals, thousands_sep, decimal_sep)`** - Number formatting
- **`format_currency(amount, symbol, decimals)`** - Currency formatting
- **`normalize_value(value, min, max)`** - Normalize to 0-1
- **`lerp(start, end, t)`** - Linear interpolation
- **`compound_interest(principal, rate, time, compounds)`** - Interest calculation
- **`gcd(a, b)` / `lcm(a, b)`** - Greatest common divisor / Least common multiple
- **`factorial(n)`** - Factorial calculation

**Example Usage:**
```sql
-- Safe division with default
SELECT safe_divide(10, 0, 0); -- Returns 0 instead of error

-- Calculate percentage
SELECT safe_percentage(25, 100); -- 25.00

-- Format as currency
SELECT format_currency(1234.56, '$'); -- '$1,234.56'

-- Clamp value to range
SELECT clamp_value(150, 0, 100); -- 100

-- Calculate compound interest
SELECT compound_interest(1000, 0.05, 10, 4); -- Amount after 10 years at 5% compounded quarterly
```

### Performance Utilities (`utilities/`)

#### performance_helpers.sql
Performance monitoring and optimization utilities:

- **`find_long_running_queries(min_duration_seconds)`** - Find long queries
- **`analyze_table_detailed(schema, table)`** - Detailed table analysis
- **`get_table_fragmentation(schema)`** - Table fragmentation estimates
- **`generate_performance_report()`** - Comprehensive performance report
- **`kill_idle_transactions(idle_threshold_minutes, dry_run)`** - Terminate idle transactions
- **`recommend_config_changes()`** - Configuration recommendations

**Example Usage:**
```sql
-- Find queries running longer than 60 seconds
SELECT * FROM find_long_running_queries(60);

-- Get detailed analysis of a table
SELECT * FROM analyze_table_detailed('public', 'users');

-- Generate performance report
SELECT * FROM generate_performance_report();

-- Kill idle transactions (dry run)
SELECT * FROM kill_idle_transactions(30, true);
```

## 🎯 Common Use Cases

### Daily Health Check
```sql
-- 1. Check database statistics
SELECT * FROM get_database_stats();

-- 2. Check cache hit ratios (should be > 95%)
SELECT * FROM get_cache_hit_ratio();

-- 3. Check for blocking queries
SELECT * FROM get_blocking_queries();

-- 4. Find long-running queries
SELECT * FROM find_long_running_queries(300);
```

### Weekly Maintenance
```sql
-- 1. Find tables needing vacuum
SELECT * FROM get_tables_needing_vacuum(1000);

-- 2. Find tables needing analyze
SELECT * FROM get_tables_needing_analyze(7);

-- 3. Check index health
SELECT * FROM get_index_health() WHERE health_status != 'HEALTHY';

-- 4. Review unused indexes
SELECT * FROM find_unused_indexes(10);
```

### Monthly Optimization Review
```sql
-- 1. Generate performance report
SELECT * FROM generate_performance_report();

-- 2. Review index maintenance recommendations
SELECT * FROM recommend_index_maintenance();

-- 3. Check for duplicate indexes
SELECT * FROM find_duplicate_indexes();

-- 4. Analyze data type inconsistencies
SELECT * FROM find_inconsistent_data_types();

-- 5. Get configuration recommendations
SELECT * FROM recommend_config_changes();
```

### Pre-Deployment Checks
```sql
-- 1. Validate constraint naming
SELECT * FROM validate_constraint_naming('public') WHERE NOT is_compliant;

-- 2. Find tables without primary keys
SELECT * FROM find_tables_without_primary_keys('public');

-- 3. Check for missing FK indexes
SELECT * FROM find_missing_fk_indexes('public');

-- 4. Analyze data types
SELECT * FROM analyze_data_types('public') WHERE recommendation != 'Type appears appropriate';
```

## 🛡️ Safety Features

All functions include:
- **NULL handling** - Functions gracefully handle NULL inputs
- **Bounds checking** - Automatic validation of input parameters
- **Dry-run mode** - Many destructive operations support dry-run testing
- **Error handling** - Comprehensive exception handling with meaningful messages
- **Validation** - Pre-execution validation to prevent data loss

## 📊 Performance Considerations

- Functions are marked as `IMMUTABLE` where appropriate for optimization
- Query functions use efficient catalog queries
- Maintenance functions include progress reporting
- All functions include execution time estimates where applicable

## 🔍 Monitoring Extensions

Some functions require PostgreSQL extensions:
- **pg_stat_statements** - Required for `get_slow_queries()`
- **unaccent** - Optional for `slugify()` function (falls back gracefully)

Install extensions:
```sql
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE EXTENSION IF NOT EXISTS unaccent;
```

## 📝 Best Practices

1. **Always use dry-run first** for destructive operations
2. **Create backups** before major changes
3. **Monitor performance** regularly using provided functions
4. **Review recommendations** from analysis functions
5. **Test in development** before running in production
6. **Schedule maintenance** during low-traffic periods
7. **Keep statistics updated** with regular ANALYZE operations

## 🤝 Contributing

When adding new functions:
1. Follow the naming convention: `action_subject()` or `get_subject_info()`
2. Include comprehensive `COMMENT ON FUNCTION` documentation
3. Add NULL handling and parameter validation
4. Include example usage in this README
5. Consider adding dry-run support for destructive operations

## 📄 License

These scripts are part of the Kingdom Monorepo project. See the repository LICENSE file for details.

## 🐛 Troubleshooting

### Common Issues

**Permission Errors**
```sql
-- Grant execute permissions
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO your_user;
```

**Extension Not Found**
```sql
-- Install required extensions
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE EXTENSION IF NOT EXISTS unaccent;
```

**Function Conflicts**
```sql
-- Drop and recreate if needed
DROP FUNCTION IF EXISTS function_name CASCADE;
-- Then reinstall from script file
```

## 📚 Additional Resources

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [PostgreSQL Wiki - Performance Optimization](https://wiki.postgresql.org/wiki/Performance_Optimization)
- [PostgreSQL Statistics Collector](https://www.postgresql.org/docs/current/monitoring-stats.html)
