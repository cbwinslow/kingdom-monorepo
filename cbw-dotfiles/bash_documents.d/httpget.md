# httpget - GET request with JSON formatting

## Description
Performs an HTTP GET request and automatically formats JSON responses for readability.

## Usage
```
httpget <url>
```

## Parameters
- `url` (required): The URL to request

## Examples
```
# Get JSON from an API
httpget https://api.github.com/users/octocat

# Get data from a REST endpoint
httpget https://jsonplaceholder.typicode.com/posts/1
```

## See Also
- httppost - POST request with JSON data
- httptest - Test HTTP endpoint
- headers - Show HTTP headers
