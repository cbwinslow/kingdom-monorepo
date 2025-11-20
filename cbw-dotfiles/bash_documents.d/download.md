# download - Download file with progress

## Description
Downloads a file from a URL with a progress bar, automatically resuming interrupted downloads.

## Usage
```
download <url> [output_file]
```

## Parameters
- `url` (required): URL of the file to download
- `output_file` (optional): Output filename (default: basename of URL)

## Examples
```
# Download with automatic filename
download https://example.com/file.zip

# Download with custom filename
download https://example.com/file.zip myfile.zip

# Download large file
download https://example.com/video.mp4 video.mp4
```

## See Also
- httpget - GET request
- curl - Direct curl usage
