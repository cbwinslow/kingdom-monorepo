#!/bin/bash
# Installation script for all database SQL scripts
# Usage: ./install_all.sh <database_name> [psql_options]

set -e

# Check if database name is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <database_name> [psql_options]"
    echo ""
    echo "Example:"
    echo "  $0 mydb"
    echo "  $0 mydb -h localhost -U postgres"
    exit 1
fi

DATABASE=$1
shift
PSQL_OPTS="$@"

echo "=========================================="
echo "Installing SQL Scripts to Database: $DATABASE"
echo "=========================================="
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Function to execute SQL file
execute_sql() {
    local category=$1
    local file=$2
    local filepath="$SCRIPT_DIR/$category/$file"
    
    if [ -f "$filepath" ]; then
        echo "Installing $category/$file..."
        psql -d "$DATABASE" $PSQL_OPTS -f "$filepath" -q
        if [ $? -eq 0 ]; then
            echo "✓ $category/$file installed successfully"
        else
            echo "✗ Failed to install $category/$file"
            return 1
        fi
    else
        echo "⚠ File not found: $filepath"
    fi
}

# Install backup scripts
echo ""
echo "=== Installing Backup Scripts ==="
execute_sql "backup" "pg_backup.sql"
execute_sql "backup" "pg_restore.sql"

# Install query scripts
echo ""
echo "=== Installing System Query Scripts ==="
execute_sql "queries" "system_info.sql"

# Install optimization scripts
echo ""
echo "=== Installing Optimization Scripts ==="
execute_sql "optimization" "vacuum_analyze.sql"
execute_sql "optimization" "index_optimization.sql"

# Install normalization scripts
echo ""
echo "=== Installing Normalization Scripts ==="
execute_sql "normalization" "data_type_operations.sql"
execute_sql "normalization" "constraint_helpers.sql"

# Install function libraries
echo ""
echo "=== Installing Utility Functions ==="
execute_sql "functions" "string_functions.sql"
execute_sql "functions" "date_time_functions.sql"
execute_sql "functions" "numeric_functions.sql"

# Install performance helpers
echo ""
echo "=== Installing Performance Utilities ==="
execute_sql "utilities" "performance_helpers.sql"

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "Quick Start:"
echo "  SELECT * FROM get_database_stats();"
echo "  SELECT * FROM get_cache_hit_ratio();"
echo "  SELECT * FROM generate_performance_report();"
echo ""
echo "For more information, see: $SCRIPT_DIR/README.md"
echo ""
