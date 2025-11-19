# backup - Quick backup of a file

## Description
Creates a timestamped backup copy of a file or directory.

## Usage
```
backup <file_or_directory>
```

## Parameters
- `file_or_directory` (required): File or directory to backup

## Examples
```
# Backup a file
backup config.yaml
# Creates: config.yaml.backup.20240119_143022

# Backup a directory
backup myproject/
# Creates: myproject.backup.20240119_143022/
```

## Notes
Backup is created in the same directory as the original file.
