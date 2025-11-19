#!/usr/bin/env bash
# File Operations and Utilities

# Extract any archive type
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *.tar.xz)    tar xf "$1"      ;;
            *.xz)        unxz "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Create archive from directory/file
archive() {
    local archive_name="${2:-$(basename "$1")_$(date +%Y%m%d).tar.gz}"
    tar -czf "$archive_name" "$1"
    echo "Created: $archive_name"
}

# Backup a file with timestamp
backup() {
    if [ -f "$1" ]; then
        cp "$1" "${1}.backup.$(date +%Y%m%d_%H%M%S)"
        echo "Backed up: $1"
    else
        echo "File not found: $1"
    fi
}

# Find files by name
ff() {
    find . -type f -iname "*$1*" 2>/dev/null
}

# Find directories by name
fd() {
    find . -type d -iname "*$1*" 2>/dev/null
}

# Find files containing text
findtext() {
    grep -rnw . -e "$1" 2>/dev/null
}

# Find and replace text in files
findreplace() {
    if [ "$#" -ne 2 ]; then
        echo "Usage: findreplace <search> <replace>"
        return 1
    fi
    find . -type f -exec sed -i "s/$1/$2/g" {} + 2>/dev/null
    echo "Replaced '$1' with '$2'"
}

# Get file size in human readable format
filesize() {
    if [ -f "$1" ]; then
        du -h "$1" | cut -f1
    else
        echo "File not found: $1"
    fi
}

# Count lines in file
countlines() {
    wc -l < "$1"
}

# Count files in directory
countfiles() {
    find "${1:-.}" -type f | wc -l
}

# Count directories
countdirs() {
    find "${1:-.}" -type d | wc -l
}

# List largest files in directory
largest() {
    local num="${1:-10}"
    du -ah . | sort -rh | head -n "$num"
}

# List recently modified files
recent() {
    local num="${1:-10}"
    find . -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -n "$num" | cut -d' ' -f2-
}

# Find duplicate files
finddupes() {
    find "${1:-.}" -type f -exec md5sum {} + | sort | uniq -w32 -dD
}

# Create multiple directories
mkdirs() {
    for dir in "$@"; do
        mkdir -p "$dir"
    done
}

# Copy with progress bar (requires pv)
cpv() {
    if command -v pv > /dev/null; then
        pv "$1" > "$2"
    else
        cp "$1" "$2"
    fi
}

# Move with progress bar (requires pv)
mvv() {
    if command -v pv > /dev/null; then
        pv "$1" > "$2" && rm "$1"
    else
        mv "$1" "$2"
    fi
}

# Quick file viewer with syntax highlighting
view() {
    if command -v bat > /dev/null; then
        bat "$1"
    elif command -v pygmentize > /dev/null; then
        pygmentize -g "$1"
    else
        less "$1"
    fi
}

# Create empty file with timestamp
touch_date() {
    touch "$(date +%Y%m%d_%H%M%S)_$1"
}

# Create numbered backup
backup_numbered() {
    local file="$1"
    local counter=1
    while [ -e "${file}.${counter}" ]; do
        ((counter++))
    done
    cp "$file" "${file}.${counter}"
    echo "Created: ${file}.${counter}"
}

# Compare two directories
dirdiff() {
    diff -rq "$1" "$2"
}

# Sync directories
dirsync() {
    rsync -av --delete "$1/" "$2/"
}

# Make file executable
mkexec() {
    chmod +x "$1"
    echo "Made executable: $1"
}

# Remove file extensions
noext() {
    for file in "$@"; do
        mv "$file" "${file%.*}"
    done
}

# Change file extensions
changeext() {
    local old_ext="$1"
    local new_ext="$2"
    for file in *."$old_ext"; do
        [ -f "$file" ] && mv "$file" "${file%.*}.$new_ext"
    done
}

# Create file with content
mkfile() {
    echo "$2" > "$1"
}

# Append to file
appendfile() {
    echo "$2" >> "$1"
}

# Get file modification time
filemtime() {
    stat -c %y "$1" 2>/dev/null || stat -f %Sm "$1" 2>/dev/null
}

# Quick grep with color
search() {
    grep --color=auto -rnw . -e "$1" 2>/dev/null
}

# Case-insensitive search
isearch() {
    grep --color=auto -rnwi . -e "$1" 2>/dev/null
}

# List empty directories
listempty() {
    find "${1:-.}" -type d -empty
}

# Remove empty directories
rmempty() {
    find "${1:-.}" -type d -empty -delete
    echo "Removed empty directories"
}

# Show file permissions in octal
octalperm() {
    stat -c '%a %n' "$1" 2>/dev/null || stat -f '%A %N' "$1" 2>/dev/null
}

# Batch rename files
batch_rename() {
    local pattern="$1"
    local replacement="$2"
    for file in *"$pattern"*; do
        [ -f "$file" ] && mv "$file" "${file//$pattern/$replacement}"
    done
}

# Create file from clipboard (macOS)
paste_to_file() {
    if command -v pbpaste > /dev/null; then
        pbpaste > "$1"
        echo "Created: $1 from clipboard"
    elif command -v xclip > /dev/null; then
        xclip -o > "$1"
        echo "Created: $1 from clipboard"
    fi
}

# Copy file content to clipboard
copy_file() {
    if command -v pbcopy > /dev/null; then
        pbcopy < "$1"
        echo "Copied to clipboard: $1"
    elif command -v xclip > /dev/null; then
        xclip -selection clipboard < "$1"
        echo "Copied to clipboard: $1"
    fi
}
