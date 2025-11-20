# serve - Start HTTP server

## Description
Starts a simple HTTP server for the current directory using Python's built-in HTTP server. Perfect for quickly serving static files.

## Usage
```
serve [port]
```

## Parameters
- `port` (optional): Port number to listen on (default: 8000)

## Examples
```
# Start server on default port 8000
serve

# Start server on custom port
serve 3000

# Serve files from current directory
cd mywebsite && serve
```

## Notes
- Access via http://localhost:PORT
- Press Ctrl+C to stop the server
- Serves all files in current directory and subdirectories

## See Also
- download - Download files
- httpget - GET request to URL
