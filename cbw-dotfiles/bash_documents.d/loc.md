# loc - Count lines of code

## Description
Counts lines of code in a project, supporting multiple programming languages. Excludes common directories like node_modules, venv, dist, build.

**Supported languages:** Python, JavaScript, TypeScript, Java, C, C++, Go, Rust, Shell

## Usage
```
loc [directory]
```

## Parameters
- `directory` (optional): Directory to analyze (default: current directory)

## Examples
```
# Count LOC in current directory
loc

# Count LOC in specific project
loc ./myproject

# Count and save to file
loc > project_stats.txt
```

## See Also
- codesearch - Search code files
- todos - Find TODO comments
