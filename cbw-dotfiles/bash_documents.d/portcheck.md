# portcheck - Check if port is open

## Description
Tests whether a specific port is open on a host (defaults to localhost).

## Usage
```
portcheck <port> [host]
```

## Parameters
- `port` (required): Port number to check
- `host` (optional): Host to check (default: localhost)

## Examples
```
# Check if port 8080 is open locally
portcheck 8080

# Check if port 443 is open on a remote host
portcheck 443 example.com

# Check database port
portcheck 5432 db.example.com
```

## See Also
- listening - Show all listening ports
- whichport - Find process using a port
