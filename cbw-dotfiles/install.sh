#!/bin/bash
# ============================================================================
# Kingdom Monorepo Bash Profile System - Installation Script
# ============================================================================
# This script installs the bash profile system by creating symlinks

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}${BOLD}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}${BOLD}║  Kingdom Monorepo Bash Profile System Installer       ║${NC}"
echo -e "${BLUE}${BOLD}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to create backup
backup_file() {
    local file="$1"
    if [ -f "$file" ] || [ -L "$file" ]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${YELLOW}  Backing up existing $file to $backup${NC}"
        mv "$file" "$backup"
    fi
}

# Function to create symlink
create_symlink() {
    local source="$1"
    local target="$2"
    
    if [ -L "$target" ]; then
        local current_target=$(readlink "$target")
        if [ "$current_target" = "$source" ]; then
            echo -e "${GREEN}  ✓ $target already points to correct location${NC}"
            return
        fi
    fi
    
    backup_file "$target"
    ln -sf "$source" "$target"
    echo -e "${GREEN}  ✓ Created symlink: $target -> $source${NC}"
}

# Main installation
echo -e "${BOLD}Installation Steps:${NC}"
echo ""

# 1. Backup existing files
echo -e "${BOLD}1. Checking for existing configuration files...${NC}"
backup_file "$HOME/.bashrc"
backup_file "$HOME/.bash_profile"
echo ""

# 2. Create symlinks
echo -e "${BOLD}2. Creating symlinks...${NC}"
create_symlink "$SCRIPT_DIR/.bashrc" "$HOME/.bashrc"
create_symlink "$SCRIPT_DIR/.bash_profile" "$HOME/.bash_profile"
echo ""

# 3. Create secrets file if it doesn't exist
echo -e "${BOLD}3. Setting up secrets file...${NC}"
if [ ! -f "$SCRIPT_DIR/bash_secrets" ]; then
    echo -e "${YELLOW}  Creating bash_secrets from template...${NC}"
    cp "$SCRIPT_DIR/bash_secrets.example" "$SCRIPT_DIR/bash_secrets"
    echo -e "${GREEN}  ✓ Created bash_secrets (remember to edit with your actual secrets)${NC}"
else
    echo -e "${GREEN}  ✓ bash_secrets already exists${NC}"
fi
echo ""

# 4. Set correct permissions
echo -e "${BOLD}4. Setting correct permissions...${NC}"
chmod 600 "$SCRIPT_DIR/bash_secrets" 2>/dev/null || echo -e "${YELLOW}  Note: Could not set permissions on bash_secrets${NC}"
echo -e "${GREEN}  ✓ Permissions set${NC}"
echo ""

# 5. Summary
echo -e "${GREEN}${BOLD}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}║  Installation Complete!                                ║${NC}"
echo -e "${GREEN}${BOLD}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}Next Steps:${NC}"
echo -e "  1. ${BLUE}Reload your shell:${NC}"
echo -e "     ${YELLOW}source ~/.bashrc${NC}"
echo ""
echo -e "  2. ${BLUE}Edit secrets file (if needed):${NC}"
echo -e "     ${YELLOW}vim $SCRIPT_DIR/bash_secrets${NC}"
echo ""
echo -e "  3. ${BLUE}Explore available functions:${NC}"
echo -e "     ${YELLOW}bash_help${NC}           # Show all functions"
echo -e "     ${YELLOW}bash_help extract${NC}   # Get help for specific function"
echo -e "     ${YELLOW}bash_search docker${NC}  # Search for functions"
echo ""
echo -e "${GREEN}Enjoy your new bash environment! 🚀${NC}"
echo ""
