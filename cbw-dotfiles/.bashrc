#!/bin/bash
# ============================================================================
# Kingdom Monorepo Bash Configuration
# ============================================================================
# A masterful and robust bash profile system with hundreds of helper functions
# Author: CBW
# Description: Comprehensive bash environment with organized helper functions,
#              documentation system, and productivity enhancements

# ============================================================================
# Core Configuration
# ============================================================================

# Bash options for better shell experience
shopt -s histappend        # Append to history, don't overwrite
shopt -s checkwinsize      # Check window size after each command
shopt -s cdspell           # Autocorrect typos in path names when using cd
shopt -s dirspell          # Autocorrect directory names during completion
shopt -s nocaseglob        # Case-insensitive globbing
shopt -s extglob           # Extended pattern matching
shopt -s dotglob           # Include hidden files in pathname expansion

# History configuration
export HISTSIZE=50000
export HISTFILESIZE=100000
export HISTCONTROL=ignoreboth:erasedups  # Ignore duplicates and commands starting with space
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S  "
export HISTIGNORE="ls:ll:cd:pwd:exit:date:clear:history"

# Better bash completion
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# ============================================================================
# Environment Variables
# ============================================================================

# Colors for better terminal output
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

# Editor preferences
export EDITOR=vim
export VISUAL=vim
export PAGER=less

# Less configuration for better viewing
export LESS="-R -M -i -j10"
export LESSCHARSET=utf-8

# Path additions (add custom paths here)
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# ============================================================================
# Color Definitions
# ============================================================================

# ANSI color codes for terminal output
export COLOR_RESET='\033[0m'
export COLOR_BLACK='\033[0;30m'
export COLOR_RED='\033[0;31m'
export COLOR_GREEN='\033[0;32m'
export COLOR_YELLOW='\033[0;33m'
export COLOR_BLUE='\033[0;34m'
export COLOR_MAGENTA='\033[0;35m'
export COLOR_CYAN='\033[0;36m'
export COLOR_WHITE='\033[0;37m'
export COLOR_BOLD='\033[1m'
export COLOR_DIM='\033[2m'

# ============================================================================
# Prompt Configuration
# ============================================================================

# Function to get git branch
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Colorful and informative prompt
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\]$(parse_git_branch)\[\033[00m\]\$ '

# ============================================================================
# Load Helper Functions
# ============================================================================

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load all function files from bash_functions.d
if [ -d "$DOTFILES_DIR/bash_functions.d" ]; then
    for func_file in "$DOTFILES_DIR/bash_functions.d"/*.sh; do
        if [ -f "$func_file" ]; then
            source "$func_file"
        fi
    done
fi

# ============================================================================
# Load Aliases
# ============================================================================

if [ -f "$DOTFILES_DIR/bash_aliases" ]; then
    source "$DOTFILES_DIR/bash_aliases"
fi

# ============================================================================
# Load Secrets (if exists)
# ============================================================================

if [ -f "$DOTFILES_DIR/bash_secrets" ]; then
    source "$DOTFILES_DIR/bash_secrets"
fi

# ============================================================================
# Welcome Message
# ============================================================================

echo -e "${COLOR_GREEN}${COLOR_BOLD}Kingdom Monorepo Bash Environment Loaded${COLOR_RESET}"
echo -e "${COLOR_CYAN}Type 'bash_help' for a list of available helper functions${COLOR_RESET}"
echo -e "${COLOR_CYAN}Type 'bash_help <function_name>' for detailed help on a specific function${COLOR_RESET}"
echo ""
