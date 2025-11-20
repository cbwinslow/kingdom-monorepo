# findlarge - Find large files

## Description
Finds and lists files larger than a specified size in a directory tree.

## Usage
```
findlarge [size] [directory]
```

## Parameters
- `size` (optional): Minimum file size (default: 100M). Use K, M, G suffixes
- `directory` (optional): Directory to search (default: current directory)

## Examples
```
# Find files larger than 100MB
findlarge

# Find files larger than 1GB
findlarge 1G

# Find files larger than 500MB in /var
findlarge 500M /var

# Find files larger than 10KB
findlarge 10K
```

## See Also
- fsize - Get file/directory size
- dusort - Sort directories by size
- diskcheck - Check disk usage
