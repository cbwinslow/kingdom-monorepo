# bookmark - Bookmark directories

## Description
Bookmark frequently used directories for quick navigation.

## Usage
```
bookmark                # Show all bookmarks
bookmark add <name>     # Bookmark current directory
bookmark go <name>      # Go to bookmarked directory
```

## Parameters
- `add <name>`: Name for the bookmark
- `go <name>`: Name of bookmark to navigate to

## Examples
```
# Bookmark current directory
cd /path/to/project
bookmark add myproject

# Show all bookmarks
bookmark

# Navigate to bookmark
bookmark go myproject

# Typical workflow
cd ~/projects/website
bookmark add site
cd ~
bookmark go site  # Returns to ~/projects/website
```

## See Also
- mkcd - Make and change to directory
- cd - Change directory
