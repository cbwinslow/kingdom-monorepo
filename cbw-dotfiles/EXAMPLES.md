# Usage Examples - Kingdom Monorepo Bash Profile System

This document showcases real-world usage examples of the bash profile system.

## Installation Demo

```bash
# Clone or navigate to the kingdom-monorepo
cd kingdom-monorepo/cbw-dotfiles

# Run the installation script
./install.sh

# Reload your shell
source ~/.bashrc
```

Output:
```
╔════════════════════════════════════════════════════════╗
║  Kingdom Monorepo Bash Profile System Installer       ║
╚════════════════════════════════════════════════════════╝

Installation Complete!
```

## Getting Help

### List All Functions
```bash
$ bash_help
```

Output shows organized list of 39+ documented functions:
```
═══════════════════════════════════════════════════════════
  Kingdom Monorepo - Bash Helper Functions
═══════════════════════════════════════════════════════════

Available Functions:

  backup                         backup - Quick backup of a file
  bash_help                      bash_help - Display help for bash functions
  bash_search                    bash_search - Search for functions by keyword
  extract                        extract - Extract any type of archive
  gcm                            gcm - Quick git commit with message
  ...
```

### Get Help for Specific Function
```bash
$ bash_help extract
```

Output:
```
═══════════════════════════════════════════════════════════
  extract
═══════════════════════════════════════════════════════════

Description
Intelligent archive extraction utility that automatically detects 
the archive type and extracts it using the appropriate tool.

Supported formats: tar.gz, tar.bz2, tar.xz, zip, rar, 7z, gz, bz2

Usage
────────────────────────────────────────────
extract <archive_file>
────────────────────────────────────────────

Examples
extract myfile.tar.gz
extract archive.zip
extract compressed.7z
```

### Search for Functions
```bash
$ bash_search docker
```

Output:
```
Searching for functions matching: docker
════════════════════════════════════════

  dcleanall                      dcleanall - Full Docker cleanup
  denter                         denter - Enter running container
  dlogs                          dlogs - Docker container logs
```

## Real-World Workflow Examples

### Example 1: Starting a New Project

```bash
# Create project structure
$ mkproject my-web-app
Created project structure: my-web-app

# Enter the project
$ cd my-web-app

# Initialize git
$ git init
$ gcm "Initial commit"

# Create Python environment
$ pyvenv
Virtual environment activated: .venv

# Add to bookmarks for quick access
$ bookmark add webapp
Bookmarked current directory as 'webapp'
```

Now you can return anytime with:
```bash
$ bookmark go webapp
```

### Example 2: Docker Workflow

```bash
# Build and run your app
$ docker-compose up -d

# Check running containers
$ dps
NAMES           STATUS          PORTS
web_app         Up 2 hours      0.0.0.0:8080->80/tcp
database        Up 2 hours      0.0.0.0:5432->5432/tcp

# Enter a container
$ denter web_app
root@container:/app#

# View logs
$ dlogs web_app 50

# Check resource usage
$ dstats

# Cleanup when done
$ dcleanall
```

### Example 3: Code Search and Maintenance

```bash
# Find all TODO items in project
$ todos
TODO Items:
./src/auth.py:23:  # TODO: Add rate limiting
./src/api.py:45:   # FIXME: Error handling needed

# Search for specific function
$ codesearch "validate_user"
./src/auth.py:15:def validate_user(username, password):
./tests/test_auth.py:8:    def test_validate_user(self):

# Count lines of code
$ loc
Lines of Code Summary
═════════════════════
src/auth.py          245
src/api.py           189
...

# Create backup before refactoring
$ backup src/auth.py
Backup created: src/auth.py.backup.20240119_143022
```

### Example 4: Network Debugging

```bash
# Check if service is responding
$ portcheck 8080
Port 8080 on localhost is OPEN ✓

# See what's listening
$ listening | grep 8080
tcp        0      0 0.0.0.0:8080            0.0.0.0:*               LISTEN

# Find which process is using the port
$ whichport 8080
node      12345 user   23u  IPv4 0x... TCP *:8080 (LISTEN)

# Test API endpoint
$ httpget http://localhost:8080/api/health
{
  "status": "ok",
  "uptime": 3600
}

# Check response times
$ responsetime https://myapi.com
Time Statistics:
DNS Lookup:     0.045s
TCP Connect:    0.123s
Total Time:     0.456s
```

### Example 5: Database Operations

```bash
# Connect to PostgreSQL
$ pgconnect myapp_dev

# Quick backup
$ pgdump myapp_dev backup.sql
Database dumped to: backup.sql

# Run a query
$ pgquery myapp_dev "SELECT COUNT(*) FROM users"
 count 
-------
  1234

# Check database size
$ pgsize myapp_dev
 pg_size_pretty 
----------------
 45 MB
```

### Example 6: File Management

```bash
# Find all Python files
$ ff "*.py"
./src/main.py
./src/utils.py
./tests/test_main.py

# Find large files
$ findlarge 100M
/var/log/app.log: 250M
/tmp/backup.tar.gz: 500M

# Extract archive
$ extract backup.tar.gz
[archive contents extracted]

# Create compressed backup
$ compress backup-$(date +%Y%m%d).tar.gz ./data ./config
Created: backup-20240119.tar.gz
```

### Example 7: Git Workflow

```bash
# Create feature branch
$ gnb feature/user-auth
Switched to a new branch 'feature/user-auth'

# Make changes and quick commit
$ gcm "Add user authentication"
[feature/user-auth a1b2c3d] Add user authentication

# View pretty log
$ glog 5
* a1b2c3d (HEAD -> feature/user-auth) Add user authentication
* d4e5f6g Update dependencies
* g7h8i9j Fix login bug
...

# Commit and push
$ gcp "Complete authentication feature"
[feature/user-auth b2c3d4e] Complete authentication feature
To github.com:user/repo.git
```

### Example 8: Productivity Tools

```bash
# Take a quick note
$ note "Review PR #123 before EOD"
Note added to /home/user/.notes/notes_20240119.md

# Set a reminder timer
$ timer 1500
Time remaining: 00:25:00
[waits 25 minutes]
Timer finished! 🎉

# Start a Pomodoro session
$ pomodoro
Pomodoro Timer
Work time: 25 minutes
Break time: 5 minutes

Work session started!
[...25 minute work session...]
Break time!
[...5 minute break...]
Pomodoro complete!

# Add to TODO list
$ todo add "Deploy new feature to staging"
Added to TODO list

$ todo
TODO List:
1  Deploy new feature to staging
2  Update documentation
```

### Example 9: System Monitoring

```bash
# System overview
$ sysinfo
System Information
══════════════════
Hostname:    workstation
OS:          Linux
Kernel:      5.15.0
Uptime:      5 days
Load:        0.45, 0.32, 0.28

# Check disk space
$ diskcheck
Disk Space Usage:
/dev/sda1  50G  35G  13G  73% /       ✓
/dev/sdb1 100G  85G  10G  90% /data   ⚠ ALERT

# Top CPU consumers
$ topcpu 3
USER       PID %CPU %MEM    TIME+  COMMAND
john     12345  25.0  2.5  12:34  node
john     23456  15.0  1.8   5:43  python
root      3456   8.0  0.5   2:15  nginx
```

### Example 10: Text Processing

```bash
# Format JSON from API
$ curl -s https://api.github.com/users/octocat | jsonformat
{
  "login": "octocat",
  "id": 1,
  "name": "The Octocat",
  ...
}

# Remove duplicates from file
$ dedup users.txt | sort > unique_users.txt

# Extract URLs from file
$ extracturls webpage.html
https://example.com
https://github.com
https://stackoverflow.com

# Count word frequency
$ wordfreq article.txt | head -10
  150 the
  120 and
  100 is
  ...
```

## Combining Functions

The real power comes from combining functions:

```bash
# Find large log files and show their sizes
$ findlarge 50M /var/log | xargs -I {} fsize {}

# Backup all config files
$ ff "*.conf" /etc | xargs -I {} backup {}

# Search code, count matches, sort by frequency
$ for lang in py js java; do 
    echo "$lang: $(codesearch "import" | grep ".$lang:" | wc -l)"
done

# Monitor specific log for errors
$ logmonitor /var/log/app.log "ERROR"

# Create project, setup venv, install deps in one go
$ mkproject myapp && cd myapp && pyvenv && pip install requests flask

# Quick git workflow
$ gnb feature/new-thing && gcm "WIP" && gcp "Work in progress"
```

## Tips for Daily Use

1. **Add to your workflow**: Make these functions part of your daily routine
2. **Create aliases**: Add personal shortcuts in `bash_aliases`
3. **Combine with pipes**: Most functions work well with stdin/stdout
4. **Use tab completion**: Bash completion works with function names
5. **Explore regularly**: Run `bash_help` to discover new functions

## Getting More Help

- Show all functions: `bash_help`
- Search: `bash_search <keyword>`
- Quick reference: See `QUICKREF.md`
- Function details: `bash_help <function_name>`

---

**Remember**: The goal is to make your shell workflow faster, easier, and more enjoyable! 🚀
