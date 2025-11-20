# codesearch - Search for text in code files

## Description
Recursively searches for patterns in code files while excluding common directories like node_modules, .git, venv, etc.

## Usage
```
codesearch <pattern> [directory]
```

## Parameters
- `pattern` (required): Text pattern to search for
- `directory` (optional): Directory to search in (default: current directory)

## Examples
```
# Search for a function name
codesearch "def calculate_total"

# Search for a variable
codesearch "API_KEY" ./src

# Search for a TODO comment
codesearch "TODO"
```

## See Also
- todos - Find TODO/FIXME comments
- ff - Find files by name
