#!/bin/bash

# Kingdom Monorepo Verification Script
# Verifies that all directories and submodules are properly set up

echo "🏰 Kingdom Monorepo Verification"
echo "================================"

# Check main directories
echo "📁 Checking main directory structure..."
main_dirs=("agents" "ansible" "apps" "data" "db" "docs" "infra" "libs" "projects" "research" "services" "tools")

for dir in "${main_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo "✅ $dir/"
        # Check subdirectories
        subdirs=$(find "$dir" -maxdepth 1 -type d | wc -l)
        echo "   └── $((subdirs-1)) subdirectories"
    else
        echo "❌ $dir/ (missing)"
    fi
done

echo ""
echo "📦 Checking submodules..."
git submodule status

echo ""
echo "🔧 Setup Instructions:"
echo "   git clone https://github.com/cbwinslow/kingdom-monorepo.git"
echo "   cd kingdom-monorepo"
echo "   ./setup.sh"
echo "   make bootstrap"
echo ""
echo "🚀 Ready for development!"