# extract - Extract any type of archive

## Description
Intelligent archive extraction utility that automatically detects the archive type and extracts it using the appropriate tool.

**Supported formats:** tar.gz, tar.bz2, tar.xz, zip, rar, 7z, gz, bz2

## Usage
```
extract <archive_file>
```

## Parameters
- `archive_file` (required): Path to the archive file to extract

## Examples
```
# Extract a tar.gz file
extract myfile.tar.gz

# Extract a zip file
extract archive.zip

# Extract a 7z file
extract compressed.7z
```

## See Also
- compress - Create archives
