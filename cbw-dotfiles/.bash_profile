#!/bin/bash
# ============================================================================
# Bash Profile - Login Shell Configuration
# ============================================================================
# This file is executed for login shells
# It sources .bashrc for consistent behavior across login and non-login shells

# Load .bashrc if it exists
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi

# Additional login shell specific configuration can go here
