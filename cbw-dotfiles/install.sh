#!/usr/bin/env bash
# Installation script for CBW Dotfiles

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}=== CBW Dotfiles Installation ===${NC}"
echo ""
echo "This script will install dotfiles and configure your shell."
echo "Installation directory: $DOTFILES_DIR"
echo ""

# Detect shell
detect_shell() {
    if [ -n "$BASH_VERSION" ]; then
        echo "bash"
    elif [ -n "$ZSH_VERSION" ]; then
        echo "zsh"
    else
        echo "unknown"
    fi
}

SHELL_TYPE=$(detect_shell)
echo -e "${BLUE}Detected shell:${NC} $SHELL_TYPE"
echo ""

# Backup existing configuration
backup_config() {
    local config_file="$1"
    if [ -f "$config_file" ]; then
        local backup_file="${config_file}.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${YELLOW}Backing up existing config:${NC} $config_file -> $backup_file"
        cp "$config_file" "$backup_file"
    fi
}

# Add source line to shell config
add_to_config() {
    local config_file="$1"
    local source_line="source $DOTFILES_DIR/bashrc"
    
    if [ ! -f "$config_file" ]; then
        touch "$config_file"
    fi
    
    if grep -q "$source_line" "$config_file"; then
        echo -e "${GREEN}✓${NC} Dotfiles already configured in $config_file"
    else
        echo "" >> "$config_file"
        echo "# CBW Dotfiles" >> "$config_file"
        echo "$source_line" >> "$config_file"
        echo -e "${GREEN}✓${NC} Added dotfiles to $config_file"
    fi
}

# Install based on shell type
case "$SHELL_TYPE" in
    bash)
        CONFIG_FILE="$HOME/.bashrc"
        if [ "$(uname)" = "Darwin" ]; then
            # macOS uses .bash_profile
            CONFIG_FILE="$HOME/.bash_profile"
        fi
        
        echo -e "${BLUE}Installing for Bash...${NC}"
        backup_config "$CONFIG_FILE"
        add_to_config "$CONFIG_FILE"
        ;;
    
    zsh)
        CONFIG_FILE="$HOME/.zshrc"
        echo -e "${BLUE}Installing for Zsh...${NC}"
        backup_config "$CONFIG_FILE"
        add_to_config "$CONFIG_FILE"
        ;;
    
    *)
        echo -e "${RED}Unknown shell. Please add this line manually to your shell config:${NC}"
        echo "source $DOTFILES_DIR/bashrc"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}=== Installation Complete! ===${NC}"
echo ""
echo "To start using the dotfiles:"
echo -e "  ${YELLOW}source $CONFIG_FILE${NC}"
echo ""
echo "Or restart your terminal."
echo ""
echo "Quick start commands:"
echo -e "  ${YELLOW}dotfiles_help${NC}   - Show help and available functions"
echo -e "  ${YELLOW}dotfiles_count${NC}  - Count available functions"
echo -e "  ${YELLOW}dotfiles_list${NC}   - List all functions"
echo ""
echo "Function categories:"
echo "  - Navigation & Directory Management"
echo "  - File Operations"
echo "  - Git Operations (80+ functions)"
echo "  - Docker Operations (90+ functions)"
echo "  - Kubernetes (100+ functions)"
echo "  - System Utilities (100+ functions)"
echo "  - Development Tools (120+ functions)"
echo "  - Text Processing (100+ functions)"
echo "  - AWS Cloud (100+ functions)"
echo "  - Network Tools (90+ functions)"
echo "  - Media Processing (60+ functions)"
echo ""
echo -e "${BLUE}Total: 500+ functions and 200+ aliases!${NC}"
echo ""
echo "Optional dependencies for enhanced functionality:"
echo "  - fzf (fuzzy finder)"
echo "  - bat (better cat)"
echo "  - ripgrep (better grep)"
echo "  - fd (better find)"
echo "  - exa (better ls)"
echo "  - jq (JSON processor)"
echo ""
echo "Install on macOS: brew install fzf bat ripgrep fd exa jq"
echo "Install on Ubuntu: sudo apt install fzf bat ripgrep fd-find jq"
echo ""
echo -e "${GREEN}Happy coding! 🚀${NC}"
