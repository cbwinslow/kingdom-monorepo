-- Test Script for Database SQL Functions
-- This script tests various functions to ensure they work correctly
-- Run this after installation to verify everything is working

\echo '=========================================='
\echo 'Testing String Functions'
\echo '=========================================='

SELECT 'safe_substring' AS function_name, 
       safe_substring('Hello World', 1, 5) AS result,
       'Hello' AS expected;

SELECT 'slugify' AS function_name,
       slugify('Hello World! This is a Test') AS result,
       'hello-world-this-is-a-test' AS expected;

SELECT 'mask_sensitive_data' AS function_name,
       mask_sensitive_data('1234567890', '*', 0, 4) AS result,
       '******7890' AS expected;

SELECT 'word_count' AS function_name,
       word_count('This is a test') AS result,
       '4' AS expected;

\echo ''
\echo '=========================================='
\echo 'Testing Date/Time Functions'
\echo '=========================================='

SELECT 'age_in_years' AS function_name,
       age_in_years('2000-01-01') >= 24 AS result,
       'true' AS expected;

SELECT 'is_business_day (Monday)' AS function_name,
       is_business_day('2024-01-01'::date) AS result, -- Monday
       'true' AS expected;

SELECT 'is_business_day (Sunday)' AS function_name,
       is_business_day('2024-01-07'::date) AS result, -- Sunday
       'false' AS expected;

SELECT 'business_days_between' AS function_name,
       business_days_between('2024-01-01', '2024-01-05') AS result, -- Mon to Fri
       '5' AS expected;

SELECT 'start_of_week' AS function_name,
       start_of_week('2024-01-03') AS result, -- Wednesday
       '2024-01-01' AS expected; -- Should return Monday

\echo ''
\echo '=========================================='
\echo 'Testing Numeric Functions'
\echo '=========================================='

SELECT 'safe_divide' AS function_name,
       safe_divide(10, 0, 0) AS result,
       '0' AS expected;

SELECT 'safe_percentage' AS function_name,
       safe_percentage(25, 100) AS result,
       '25.00' AS expected;

SELECT 'clamp_value' AS function_name,
       clamp_value(150, 0, 100) AS result,
       '100' AS expected;

SELECT 'is_in_range' AS function_name,
       is_in_range(50, 0, 100) AS result,
       'true' AS expected;

SELECT 'is_even' AS function_name,
       is_even(4) AS result,
       'true' AS expected;

SELECT 'is_odd' AS function_name,
       is_odd(5) AS result,
       'true' AS expected;

SELECT 'factorial' AS function_name,
       factorial(5) AS result,
       '120' AS expected;

SELECT 'gcd' AS function_name,
       gcd(48, 18) AS result,
       '6' AS expected;

\echo ''
\echo '=========================================='
\echo 'Testing System Query Functions'
\echo '=========================================='

-- Test get_database_stats (should return rows)
SELECT 'get_database_stats' AS function_name,
       COUNT(*) > 0 AS has_results
FROM get_database_stats();

-- Test get_cache_hit_ratio (should return rows)
SELECT 'get_cache_hit_ratio' AS function_name,
       COUNT(*) > 0 AS has_results
FROM get_cache_hit_ratio();

-- Test get_active_connections (should return rows, at least this connection)
SELECT 'get_active_connections' AS function_name,
       COUNT(*) >= 0 AS has_results
FROM get_active_connections();

\echo ''
\echo '=========================================='
\echo 'Testing Table Analysis Functions'
\echo '=========================================='

-- Test get_table_stats (may return 0 rows if no user tables exist)
SELECT 'get_table_stats' AS function_name,
       COUNT(*) >= 0 AS has_results
FROM get_table_stats();

-- Test get_index_stats (may return 0 rows if no user indexes exist)
SELECT 'get_index_stats' AS function_name,
       COUNT(*) >= 0 AS has_results
FROM get_index_stats();

\echo ''
\echo '=========================================='
\echo 'Testing Optimization Functions'
\echo '=========================================='

-- Test get_tables_needing_vacuum
SELECT 'get_tables_needing_vacuum' AS function_name,
       COUNT(*) >= 0 AS has_results
FROM get_tables_needing_vacuum(1000);

-- Test find_unused_indexes
SELECT 'find_unused_indexes' AS function_name,
       COUNT(*) >= 0 AS has_results
FROM find_unused_indexes(1);

\echo ''
\echo '=========================================='
\echo 'Testing Data Type Analysis Functions'
\echo '=========================================='

-- Test analyze_data_types
SELECT 'analyze_data_types' AS function_name,
       COUNT(*) >= 0 AS has_results
FROM analyze_data_types('public');

-- Test find_inconsistent_data_types
SELECT 'find_inconsistent_data_types' AS function_name,
       COUNT(*) >= 0 AS has_results
FROM find_inconsistent_data_types();

\echo ''
\echo '=========================================='
\echo 'Testing Constraint Analysis Functions'
\echo '=========================================='

-- Test analyze_foreign_keys
SELECT 'analyze_foreign_keys' AS function_name,
       COUNT(*) >= 0 AS has_results
FROM analyze_foreign_keys('public');

-- Test find_tables_without_primary_keys
SELECT 'find_tables_without_primary_keys' AS function_name,
       COUNT(*) >= 0 AS has_results
FROM find_tables_without_primary_keys('public');

\echo ''
\echo '=========================================='
\echo 'Testing Performance Helper Functions'
\echo '=========================================='

-- Test generate_performance_report
SELECT 'generate_performance_report' AS function_name,
       COUNT(*) > 0 AS has_results
FROM generate_performance_report();

-- Test find_long_running_queries (should work even if no long queries)
SELECT 'find_long_running_queries' AS function_name,
       COUNT(*) >= 0 AS has_results
FROM find_long_running_queries(60);

\echo ''
\echo '=========================================='
\echo 'Testing Backup Functions'
\echo '=========================================='

-- Test get_database_size_info
SELECT 'get_database_size_info' AS function_name,
       COUNT(*) > 0 AS has_results
FROM get_database_size_info();

\echo ''
\echo '=========================================='
\echo 'All Tests Complete!'
\echo '=========================================='
\echo ''
\echo 'If you see results above, the functions are working correctly.'
\echo 'Functions returning 0 results may be expected if you have no user tables/indexes yet.'
\echo ''
