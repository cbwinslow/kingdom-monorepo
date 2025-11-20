# Quick Reference Guide

## Getting Help

```bash
bash_help                      # List all available functions
bash_help <function>           # Get detailed help for a function
bash_search <keyword>          # Search for functions by keyword
bash_categories                # List function categories
```

## Most Useful Functions by Category

### 📁 File & Directory Operations
```bash
extract archive.tar.gz         # Extract any archive format
compress backup.tar.gz files/  # Create compressed archive
ff "*.py"                      # Find files by name pattern
fd "src"                       # Find directories by name
mkcd path/to/dir               # Create and cd into directory
backup config.yaml             # Create timestamped backup
fsize dirname/                 # Get file/directory size
findlarge 500M /var            # Find files larger than 500MB
```

### 💻 Git Operations
```bash
gcm "commit message"           # Add all, commit
gcp "commit message"           # Add all, commit, push
gnb feature/new-branch         # Create and switch to new branch
glog                          # Pretty git log
gss                           # Short git status
gundo                         # Undo last commit (keep changes)
```

### 🐳 Docker Management
```bash
dcleanall                     # Full Docker cleanup
denter container_name         # Enter container shell
dlogs container_name          # Follow container logs
dps                          # List running containers
dstats                       # Show container resource usage
dstopall                     # Stop all containers
```

### 🌐 Network Tools
```bash
myip                          # Show public IP address
localip                       # Show local IP addresses
portcheck 8080                # Check if port is open
listening                     # Show all listening ports
httpget https://api.url       # GET request with JSON formatting
httppost url '{"key":"val"}'  # POST JSON data
download https://url/file     # Download with progress bar
responsetime https://site     # Check website response time
```

### 🔍 Code & Text Search
```bash
codesearch "function_name"    # Search code (excludes node_modules, etc.)
todos                         # Find TODO/FIXME in code
loc                           # Count lines of code
ff "*.py"                     # Find files by pattern
jsonformat data.json          # Pretty-print JSON
```

### 💾 Database Operations
```bash
# PostgreSQL
pgconnect mydb                # Connect to database
pgdump mydb backup.sql        # Dump database
pgquery mydb "SELECT * FROM users LIMIT 5"

# MySQL
myconnect mydb                # Connect to database
mydump mydb backup.sql        # Dump database

# Redis
redisget mykey                # Get key value
redisset mykey "value"        # Set key value
```

### 📊 System Monitoring
```bash
sysinfo                       # System information summary
topcpu                        # Top CPU processes
topmem                        # Top memory processes
diskcheck                     # Check disk usage with alerts
cpumonitor                    # Real-time CPU monitoring
memmonitor                    # Real-time memory monitoring
sysmonitor                    # Full system monitor (htop/top)
```

### ⚡ Productivity
```bash
note "Meeting at 3pm"         # Quick timestamped note
shownotes                     # Show recent notes
searchnotes "keyword"         # Search through notes
timer 1500                    # 25-minute countdown timer
pomodoro                      # Pomodoro timer (25min work, 5min break)
calc "2 + 2 * 5"             # Calculator
todo add "Task description"   # Add TODO item
todo                         # Show TODO list
bookmark add myproject        # Bookmark current directory
bookmark go myproject         # Jump to bookmarked directory
weather                       # Get weather report
```

### 🛠️ Development Tools
```bash
serve 8080                    # Start HTTP server
pyvenv                        # Create Python virtual environment
pyreqs                        # Install from requirements.txt
pysave                        # Save requirements.txt
mkproject myapp               # Create project structure
genpass 20                    # Generate random password
genuuid                       # Generate UUID
b64encode "text"              # Base64 encode
urlencode "text"              # URL encode
```

### 📝 Text Processing
```bash
dedup file.txt                # Remove duplicate lines
rmblank file.txt              # Remove blank lines
replace "old" "new" file.txt  # Replace text in file
countlines file.txt           # Count lines
wordfreq file.txt             # Word frequency analysis
extracturls file.txt          # Extract URLs from text
extractemails file.txt        # Extract email addresses
```

## Common Aliases

```bash
# Navigation
..                            # cd ..
...                           # cd ../..
~                             # cd ~

# List files
ll                            # ls -lah
la                            # ls -A
lt                            # ls -lahtr (sort by time)

# Git shortcuts
gs                            # git status
ga                            # git add
gp                            # git push
gpl                           # git pull
gd                            # git diff

# Docker shortcuts
d                             # docker
dc                            # docker-compose
dps                           # docker ps
di                            # docker images

# Misc
h                             # history
c                             # clear
```

## Tips & Tricks

### 1. Pipe to Functions
Many functions work with stdin:
```bash
cat data.json | jsonformat
echo "hello world" | b64encode
history | grep docker
```

### 2. Combine Functions
```bash
# Find large files and sort
findlarge | sort -hr

# Search code and count results
codesearch "TODO" | wc -l

# Get IPs of all containers
docker ps -q | xargs -n1 docker inspect --format '{{.Name}} {{.NetworkSettings.IPAddress}}'
```

### 3. Use with Loops
```bash
# Backup multiple files
for f in *.txt; do backup "$f"; done

# Check multiple ports
for port in 80 443 8080; do portcheck $port; done
```

### 4. Create Custom Functions
Add your own functions to `bash_functions.d/90_custom.sh` and documentation to `bash_documents.d/`.

### 5. Environment Variables
Store frequently used values:
```bash
export PROJECT_DIR="/path/to/project"
export API_URL="https://api.example.com"
```

## Configuration Files

- `~/.bashrc` - Main configuration (symlinked)
- `bash_secrets` - API keys and secrets (gitignored)
- `bash_aliases` - Command aliases
- `bash_functions.d/` - Function definitions
- `bash_documents.d/` - Function documentation

## Getting More Help

- Full README: See `README.md` in cbw-dotfiles directory
- Function help: `bash_help <function_name>`
- Search: `bash_search <keyword>`
- Online: Check the Kingdom Monorepo repository

---

**Pro Tip:** Use `bash_help` frequently to discover new functions and refresh your memory on syntax!
