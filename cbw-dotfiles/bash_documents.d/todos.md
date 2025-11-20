# todos - Find TODO/FIXME comments in code

## Description
Searches for TODO, FIXME, XXX, HACK, and BUG comments in code files, excluding common directories.

## Usage
```
todos [directory]
```

## Parameters
- `directory` (optional): Directory to search (default: current directory)

## Examples
```
# Find all TODO items in current directory
todos

# Search in specific directory
todos ./src

# Pipe to file
todos > todo_list.txt
```

## See Also
- codesearch - General code search
- grep - General text search
