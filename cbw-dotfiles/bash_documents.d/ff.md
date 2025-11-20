# ff - Find files by name pattern

## Description
Recursively searches for files matching a name pattern (case-insensitive).

## Usage
```
ff <pattern> [directory]
```

## Parameters
- `pattern` (required): File name pattern to search for
- `directory` (optional): Directory to search in (default: current directory)

## Examples
```
# Find all Python files
ff "*.py"

# Find files containing "test" in name
ff "test"

# Search in specific directory
ff "config" /etc
```

## See Also
- fd - Find directories by name
- codesearch - Search file contents
