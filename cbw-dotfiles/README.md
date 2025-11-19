# CBW Dotfiles - Kingdom Monorepo Bash Profile System

A masterful and robust bash profile system with hundreds of helper functions, comprehensive documentation, and a powerful lookup system similar to `man` and `tldr`.

## Features

✨ **100+ Helper Functions** organized into categories:
- 🔧 System Utilities - File operations, process management, archives
- 💻 Development Tools - Git helpers, code search, project scaffolding
- 🌐 Network Utilities - Port checking, API testing, downloads
- 📝 Text Processing - Search, replace, formatting
- 🐳 Docker Utilities - Container management and cleanup
- 🗄️ Database Tools - PostgreSQL, MySQL, MongoDB, Redis, SQLite
- 📊 Monitoring - System diagnostics and performance analysis
- ⚡ Productivity - Notes, timers, calculators, bookmarks

🔍 **Built-in Help System** - Like `man` and `tldr` combined:
- `bash_help` - List all functions or get detailed help
- `bash_search` - Search functions by keyword
- Full markdown documentation for every function

🎨 **Rich Terminal Experience**:
- Colorful prompts with git branch display
- Smart history management
- Hundreds of convenient aliases

## Quick Start

### Installation

1. **Source the bashrc in your shell:**
```bash
# Add to your ~/.bashrc or ~/.bash_profile
source /path/to/cbw-dotfiles/.bashrc
```

Or create a symlink:
```bash
ln -sf $(pwd)/.bashrc ~/.bashrc
```

2. **Reload your shell:**
```bash
source ~/.bashrc
```

### First Steps

```bash
# Show all available functions
bash_help

# Get help for a specific function
bash_help extract

# Search for functions
bash_search docker

# List function categories
bash_categories
```

## Directory Structure

```
cbw-dotfiles/
├── .bashrc                  # Main bash configuration
├── .bash_profile            # Login shell configuration
├── bash_aliases             # Common aliases
├── bash_secrets.example     # Template for secrets (copy to bash_secrets)
├── bash_functions.d/        # Helper functions by category
│   ├── 00_help_system.sh    # Documentation and help system
│   ├── 10_system_utils.sh   # System utilities
│   ├── 20_dev_tools.sh      # Development tools
│   ├── 30_network_utils.sh  # Network utilities
│   ├── 40_text_utils.sh     # Text processing
│   ├── 50_docker_utils.sh   # Docker utilities
│   ├── 60_database_utils.sh # Database tools
│   ├── 70_monitoring_utils.sh # Monitoring and diagnostics
│   └── 80_productivity_utils.sh # Productivity tools
└── bash_documents.d/        # Markdown documentation for each function
    ├── bash_help.md
    ├── extract.md
    ├── gcm.md
    └── ... (100+ documentation files)
```

## Example Functions

### System Utilities
```bash
extract myfile.tar.gz          # Extract any archive
compress backup.tar.gz ./data  # Create archive
ff "*.py"                      # Find Python files
mkcd projects/newapp           # Make dir and cd into it
backup important.txt           # Quick backup with timestamp
```

### Development Tools
```bash
gcm "Fix bug"                  # Git add, commit with message
gcp "Add feature"              # Git add, commit, and push
codesearch "function_name"     # Search code files
loc                            # Count lines of code
pyvenv                         # Create Python virtual env
serve 8080                     # Start HTTP server
```

### Network Utilities
```bash
myip                          # Show public IP
portcheck 8080                # Check if port is open
httpget https://api.github.com/users/octocat
download https://example.com/file.zip
responsetime https://example.com
```

### Docker
```bash
dcleanall                     # Full Docker cleanup
denter container_name         # Enter container shell
dlogs container_name          # Follow container logs
dstats                        # Show resource usage
```

### Productivity
```bash
note "Meeting at 3pm"         # Quick note
timer 1500                    # 25 minute timer
pomodoro                      # Pomodoro timer
calc "2 + 2 * 5"             # Calculator
weather                       # Get weather
todo add "Finish project"     # Add TODO item
```

## Secrets Management

The system includes a secure secrets management system:

1. Copy the template: `cp bash_secrets.example bash_secrets`
2. Edit `bash_secrets` with your API keys, tokens, etc.
3. The `bash_secrets` file is gitignored and will never be committed

## Customization

### Adding Your Own Functions

1. Create a new file in `bash_functions.d/`:
```bash
# bash_functions.d/90_custom_utils.sh
my_function() {
    echo "My custom function"
}
```

2. Create documentation in `bash_documents.d/`:
```bash
# bash_documents.d/my_function.md
# my_function - Brief description

## Description
Full description here

## Usage
```
my_function
```
```

3. Reload your shell: `source ~/.bashrc`

### Modifying Aliases

Edit `bash_aliases` to add or modify aliases:
```bash
alias myalias='my command'
```

## Documentation System

Every function has comprehensive documentation including:
- Description
- Usage syntax
- Parameters
- Examples
- Related functions

Access documentation with:
- `bash_help <function>` - Full documentation
- `bash_search <keyword>` - Search by keyword
- `bash_categories` - Browse by category

## Requirements

Most functions work with standard Unix/Linux tools. Some optional features require:
- `git` - For git helper functions
- `docker` - For Docker utilities
- `python3` - For some utility functions
- `curl` - For network utilities
- Database clients (`psql`, `mysql`, `mongo`, etc.) - For database functions

## Contributing

This is part of the Kingdom Monorepo. To contribute:
1. Add new functions to appropriate category file in `bash_functions.d/`
2. Create documentation in `bash_documents.d/`
3. Follow existing naming conventions
4. Test thoroughly before committing

## License

Part of the Kingdom Monorepo project.

