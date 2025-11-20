# mkproject - Create project structure

## Description
Creates a new project directory with a standard structure including src, tests, docs, bin directories, README, and .gitignore.

## Usage
```
mkproject <project_name>
```

## Parameters
- `project_name` (required): Name of the project directory to create

## Examples
```
# Create new project
mkproject my-api

# Create and start working
mkproject web-app
cd web-app
```

## Created Structure
```
project_name/
├── src/          # Source code
├── tests/        # Test files
├── docs/         # Documentation
├── bin/          # Executable scripts
├── README.md     # Project readme
└── .gitignore    # Git ignore file
```

## See Also
- mkcd - Make and change to directory
- pyvenv - Create Python virtual environment
