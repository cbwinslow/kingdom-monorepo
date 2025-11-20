# listening - Show listening ports

## Description
Displays all ports that are currently listening for connections on the system.

## Usage
```
listening
```

## Examples
```
# Show all listening ports
listening

# Filter for specific port
listening | grep 8080

# Show only TCP ports
listening | grep tcp
```

## Output
Shows protocol, local address, port, and state for all listening sockets.

## See Also
- portcheck - Check if port is open
- whichport - Find process using a port
- connections - Show active connections
