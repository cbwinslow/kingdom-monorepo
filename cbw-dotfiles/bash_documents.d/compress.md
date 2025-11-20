# compress - Create archive from files

## Description
Creates compressed archives in various formats. Automatically detects format from file extension.

**Supported formats:** tar.gz, tar.bz2, tar.xz, zip, 7z

## Usage
```
compress <archive_name> <file1> [file2] ...
```

## Parameters
- `archive_name` (required): Output archive file name with extension
- `file1, file2, ...` (required): Files or directories to compress

## Examples
```
# Create tar.gz archive
compress backup.tar.gz myfile.txt mydir/

# Create zip archive
compress project.zip src/ docs/

# Create 7z archive
compress data.7z data/
```

## See Also
- extract - Extract archives
