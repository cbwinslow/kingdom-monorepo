#!/usr/bin/env bash
# Text Processing and Manipulation

# Count words in text
wordcount() {
    echo "$1" | wc -w
}

# Count characters
charcount() {
    echo -n "$1" | wc -c
}

# Lowercase text
lowercase() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

# Uppercase text
uppercase() {
    echo "$1" | tr '[:lower:]' '[:upper:]'
}

# Title case
titlecase() {
    echo "$1" | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1'
}

# Reverse text
reverse() {
    echo "$1" | rev
}

# Remove whitespace
trim() {
    echo "$1" | xargs
}

# Remove duplicate lines
dedup() {
    if [ -f "$1" ]; then
        sort "$1" | uniq
    else
        echo "$1" | sort | uniq
    fi
}

# Remove empty lines
remove_empty() {
    if [ -f "$1" ]; then
        sed '/^$/d' "$1"
    else
        echo "$1" | sed '/^$/d'
    fi
}

# Add line numbers
add_line_numbers() {
    nl -ba "$1"
}

# Extract column
extract_col() {
    awk -v col="$1" '{print $col}' "$2"
}

# CSV to JSON
csv2json() {
    python3 << EOF
import csv, json, sys
print(json.dumps([row for row in csv.DictReader(open('$1'))], indent=2))
EOF
}

# JSON to CSV
json2csv() {
    python3 << EOF
import json, csv, sys
data = json.load(open('$1'))
if data:
    keys = data[0].keys()
    writer = csv.DictWriter(sys.stdout, keys)
    writer.writeheader()
    writer.writerows(data)
EOF
}

# Markdown to HTML
md2html() {
    if command -v pandoc > /dev/null; then
        pandoc "$1" -o "${1%.md}.html"
    else
        echo "Install pandoc for markdown conversion"
    fi
}

# HTML to Markdown
html2md() {
    if command -v pandoc > /dev/null; then
        pandoc "$1" -o "${1%.html}.md"
    else
        echo "Install pandoc for HTML conversion"
    fi
}

# Sort lines
sort_lines() {
    sort "$1"
}

# Sort by column
sort_by_col() {
    sort -k "$1" "$2"
}

# Sort numerically
sort_numeric() {
    sort -n "$1"
}

# Sort reverse
sort_reverse() {
    sort -r "$1"
}

# Unique lines
unique_lines() {
    sort "$1" | uniq
}

# Count unique lines
count_unique() {
    sort "$1" | uniq | wc -l
}

# Find duplicates
find_duplicates() {
    sort "$1" | uniq -d
}

# Count occurrences
count_occurrences() {
    sort "$1" | uniq -c | sort -rn
}

# Replace text
replace_text() {
    sed "s/$1/$2/g" "$3"
}

# Replace text in place
replace_in_place() {
    sed -i "s/$1/$2/g" "$3"
}

# Extract lines containing pattern
grep_lines() {
    grep "$1" "$2"
}

# Extract lines not containing pattern
grep_not() {
    grep -v "$1" "$2"
}

# Extract between patterns
extract_between() {
    sed -n "/$1/,/$2/p" "$3"
}

# Remove lines containing pattern
remove_lines() {
    sed "/$1/d" "$2"
}

# Insert line before pattern
insert_before() {
    sed "/$2/i\\$1" "$3"
}

# Insert line after pattern
insert_after() {
    sed "/$2/a\\$1" "$3"
}

# Split file by lines
split_lines() {
    split -l "$1" "$2" "${3:-output_}"
}

# Split file by size
split_size() {
    split -b "$1" "$2" "${3:-output_}"
}

# Join files
join_files() {
    cat "$@"
}

# Diff files
diff_files() {
    diff "$1" "$2"
}

# Side by side diff
diff_side() {
    diff -y "$1" "$2"
}

# Column format
columnize() {
    column -t "$1"
}

# Table format
tabulate() {
    column -t -s, "$1"
}

# Head n lines
head_n() {
    head -n "$1" "$2"
}

# Tail n lines
tail_n() {
    tail -n "$1" "$2"
}

# Random lines
random_lines() {
    shuf -n "$1" "$2"
}

# Shuffle lines
shuffle() {
    shuf "$1"
}

# Paginate
paginate() {
    less "$1"
}

# Word wrap
wrap() {
    fold -w "${1:-80}" "$2"
}

# Indent text
indent() {
    sed "s/^/    /" "$1"
}

# Unindent text
unindent() {
    sed "s/^    //" "$1"
}

# Comment lines
comment() {
    sed "s/^/# /" "$1"
}

# Uncomment lines
uncomment() {
    sed "s/^# //" "$1"
}

# Extract emails
extract_emails() {
    grep -Eio '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b' "$1"
}

# Extract URLs
extract_urls() {
    grep -Eoi 'https?://[^[:space:]]+' "$1"
}

# Extract IPs
extract_ips() {
    grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' "$1"
}

# Extract phone numbers
extract_phones() {
    grep -Eo '\+?[0-9]{1,4}?[-.\s]?\(?[0-9]{1,3}?\)?[-.\s]?[0-9]{1,4}[-.\s]?[0-9]{1,4}[-.\s]?[0-9]{1,9}' "$1"
}

# Convert tabs to spaces
tabs2spaces() {
    expand "$1"
}

# Convert spaces to tabs
spaces2tabs() {
    unexpand "$1"
}

# ROT13 encode
rot13() {
    echo "$1" | tr 'A-Za-z' 'N-ZA-Mn-za-m'
}

# Character frequency
char_freq() {
    fold -w1 "$1" | sort | uniq -c | sort -rn
}

# Word frequency
word_freq() {
    tr -cs '[:alnum:]' '\n' < "$1" | tr '[:upper:]' '[:lower:]' | sort | uniq -c | sort -rn
}

# Most common words
top_words() {
    tr -cs '[:alnum:]' '\n' < "$2" | tr '[:upper:]' '[:lower:]' | sort | uniq -c | sort -rn | head -n "$1"
}

# Line length
line_length() {
    awk '{print length}' "$1"
}

# Longest line
longest_line() {
    awk 'length > max {max=length; line=$0} END {print line}' "$1"
}

# Shortest line
shortest_line() {
    awk 'NR==1 || length < min {min=length; line=$0} END {print line}' "$1"
}

# Average line length
avg_line_length() {
    awk '{sum+=length; count++} END {print sum/count}' "$1"
}

# Concatenate lines
concat_lines() {
    tr '\n' ' ' < "$1"
}

# Vertical text
vertical() {
    echo "$1" | fold -w1
}

# Center text
center_text() {
    local width="${2:-80}"
    echo "$1" | awk -v width="$width" '{spaces=(width-length)/2; printf "%*s%s\n", spaces, "", $0}'
}

# Right align
right_align() {
    local width="${2:-80}"
    echo "$1" | awk -v width="$width" '{printf "%*s\n", width, $0}'
}

# Pad left
pad_left() {
    printf "%${2}s" "$1"
}

# Pad right
pad_right() {
    printf "%-${2}s" "$1"
}

# Truncate
truncate_text() {
    echo "$1" | cut -c1-"$2"
}

# Strip ANSI colors
strip_colors() {
    sed 's/\x1b\[[0-9;]*m//g' "$1"
}

# Add color
color_text() {
    case "$1" in
        red) echo -e "\033[31m$2\033[0m" ;;
        green) echo -e "\033[32m$2\033[0m" ;;
        yellow) echo -e "\033[33m$2\033[0m" ;;
        blue) echo -e "\033[34m$2\033[0m" ;;
        magenta) echo -e "\033[35m$2\033[0m" ;;
        cyan) echo -e "\033[36m$2\033[0m" ;;
        *) echo "$2" ;;
    esac
}

# Bold text
bold() {
    echo -e "\033[1m$1\033[0m"
}

# Underline text
underline() {
    echo -e "\033[4m$1\033[0m"
}

# Italic text
italic() {
    echo -e "\033[3m$1\033[0m"
}

# Blink text
blink() {
    echo -e "\033[5m$1\033[0m"
}

# Progress bar
progress_bar() {
    local current="$1"
    local total="$2"
    local width="${3:-50}"
    local percent=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))
    printf "\r["
    printf "%${filled}s" | tr ' ' '='
    printf "%${empty}s" | tr ' ' '-'
    printf "] %d%%" "$percent"
}

# Spinner
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Box text
box() {
    local text="$1"
    local length=${#text}
    local line=$(printf '%*s' $((length+4)) | tr ' ' '-')
    echo "$line"
    echo "| $text |"
    echo "$line"
}

# Banner text
banner() {
    echo "$1" | figlet 2>/dev/null || echo "=== $1 ==="
}

# Cowsay
cowsay_text() {
    if command -v cowsay > /dev/null; then
        echo "$1" | cowsay
    else
        echo "$1"
    fi
}

# Spell check
spellcheck() {
    aspell check "$1" 2>/dev/null || echo "Install aspell for spell checking"
}
