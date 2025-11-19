# jsonformat - Format JSON beautifully

## Description
Pretty-prints JSON data with proper indentation and syntax highlighting.

## Usage
```
jsonformat [file]
cat file.json | jsonformat
```

## Parameters
- `file` (optional): JSON file to format (if not provided, reads from stdin)

## Examples
```
# Format JSON file
jsonformat data.json

# Format from stdin
echo '{"name":"John","age":30}' | jsonformat

# Format API response
curl -s https://api.example.com/data | jsonformat

# Save formatted output
jsonformat messy.json > formatted.json
```

## See Also
- httpget - GET with JSON formatting
- xmlformat - Format XML
