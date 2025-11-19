#!/usr/bin/env bash
# Navigation and Directory Management Functions

# Create directory and cd into it
mkcd() {
    mkdir -p -- "$1" && cd -P -- "$1" || return
}

# Go up N directories
up() {
    local d=""
    local limit="${1:-1}"
    for ((i=1 ; i <= limit ; i++)); do
        d=$d/..
    done
    d=$(echo $d | sed 's/^\///')
    if [ -z "$d" ]; then
        d=..
    fi
    cd "$d" || return
}

# Go to root of git repository
cdgr() {
    local root
    root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [ -n "$root" ]; then
        cd "$root" || return
    else
        echo "Not in a git repository"
        return 1
    fi
}

# Go to project root (searches for common project markers)
cdpr() {
    local dir="$PWD"
    while [ "$dir" != "/" ]; do
        if [ -f "$dir/package.json" ] || [ -f "$dir/Makefile" ] || \
           [ -f "$dir/pyproject.toml" ] || [ -f "$dir/go.mod" ] || \
           [ -f "$dir/Cargo.toml" ] || [ -f "$dir/pom.xml" ]; then
            cd "$dir" || return
            return 0
        fi
        dir=$(dirname "$dir")
    done
    echo "No project root found"
    return 1
}

# Create a backup of current directory
backup_here() {
    local backup_name="backup_$(basename "$PWD")_$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -czf "../$backup_name" . && echo "Backup created: ../$backup_name"
}

# Quick bookmark system
bookmark() {
    local bookmark_file="$HOME/.bookmarks"
    if [ -z "$1" ]; then
        # List bookmarks
        if [ -f "$bookmark_file" ]; then
            cat "$bookmark_file"
        fi
    else
        # Add bookmark
        echo "$1=$(pwd)" >> "$bookmark_file"
        echo "Bookmark '$1' added for $(pwd)"
    fi
}

goto() {
    local bookmark_file="$HOME/.bookmarks"
    if [ -f "$bookmark_file" ]; then
        local path
        path=$(grep "^$1=" "$bookmark_file" | cut -d'=' -f2)
        if [ -n "$path" ]; then
            cd "$path" || return
        else
            echo "Bookmark '$1' not found"
        fi
    fi
}

# Remove bookmark
rmbookmark() {
    local bookmark_file="$HOME/.bookmarks"
    if [ -f "$bookmark_file" ]; then
        sed -i.bak "/^$1=/d" "$bookmark_file"
        echo "Bookmark '$1' removed"
    fi
}

# Quick directory stack operations
dirs_add() {
    pushd "$PWD" > /dev/null || return
}

dirs_back() {
    popd > /dev/null || return
}

dirs_list() {
    dirs -v
}

# Find and cd to directory
fcd() {
    local dir
    dir=$(find "${1:-.}" -type d -not -path '*/\.*' 2>/dev/null | fzf --preview 'ls -la {}' 2>/dev/null || find "${1:-.}" -type d -not -path '*/\.*' 2>/dev/null | head -1)
    if [ -n "$dir" ]; then
        cd "$dir" || return
    fi
}

# Create and cd into temporary directory
cdtmp() {
    local tmp_dir
    tmp_dir=$(mktemp -d)
    cd "$tmp_dir" || return
    echo "Created and moved to: $tmp_dir"
}

# Jump to parent directory containing specified file/folder
upto() {
    if [ -z "$1" ]; then
        return
    fi
    local upto="$1"
    cd "${PWD/\/$upto\/*//$upto}" || return
}

# Quick navigate to common directories
cdl() { cd ~/Downloads || return; }
cdp() { cd ~/Projects || return; }
cdd() { cd ~/Desktop || return; }
cdo() { cd ~/Documents || return; }
