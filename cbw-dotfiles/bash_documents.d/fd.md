# fd - Find directories by name

## Description
Recursively searches for directories matching a name pattern (case-insensitive).

## Usage
```
fd <pattern> [directory]
```

## Parameters
- `pattern` (required): Directory name pattern to search for
- `directory` (optional): Starting directory (default: current directory)

## Examples
```
# Find directories containing "test"
fd test

# Find directories named "src"
fd src

# Search in specific location
fd config /etc

# Find hidden directories
fd ".git"
```

## See Also
- ff - Find files by name
- mkcd - Make and change to directory
