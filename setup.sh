#!/bin/bash

# Kingdom Monorepo Setup Script
# This script properly initializes the kingdom monorepo with all submodules

set -e

echo "🏰 Setting up Kingdom Monorepo..."

# Initialize main submodules (non-recursive first)
echo "📦 Initializing main submodules..."
git submodule update --init

# Handle opendiscourse separately since it has nested submodules
echo "🔧 Setting up opendiscourse submodule..."
cd opendiscourse

# Initialize opendiscourse submodules if they exist, but don't fail if they don't
if [ -f .gitmodules ]; then
    echo "📚 Found nested submodules in opendiscourse, initializing..."
    git submodule update --init --recursive || echo "⚠️  Some nested submodules may need manual setup"
else
    echo "ℹ️  No nested submodules found in opendiscourse"
fi

cd ..

echo "✅ Submodule setup complete!"
echo ""
echo "🚀 Next steps:"
echo "   make bootstrap    # Install dependencies"
echo "   make dev          # Start development"
echo ""
echo "📁 Repository structure:"
tree -L 2 -I 'node_modules|.git|*.log' 2>/dev/null || find . -maxdepth 2 -type d | sort