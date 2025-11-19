# db

Database workspace containing SQL scripts, functions, and utilities.

## Purpose
This directory contains database-related projects, configurations, and resources including:
- Standardized SQL scripts for backup operations
- System monitoring and diagnostic queries
- Performance optimization scripts
- Database normalization utilities
- Enhanced SQL functions for common operations

## Quick Start

### Installation
Install all SQL scripts to your database:
```bash
cd scripts
./install_all.sh your_database_name
```

Or install with custom PostgreSQL options:
```bash
./install_all.sh your_database_name -h localhost -U postgres
```

### Common Operations

**Database Health Check:**
```sql
SELECT * FROM get_database_stats();
SELECT * FROM get_cache_hit_ratio();
```

**Performance Analysis:**
```sql
SELECT * FROM generate_performance_report();
SELECT * FROM find_long_running_queries(60);
```

**Maintenance:**
```sql
SELECT * FROM get_tables_needing_vacuum(1000);
SELECT * FROM get_index_health();
```

## Documentation

See [scripts/README.md](scripts/README.md) for comprehensive documentation of all available functions and utilities.

