# myip - Get public IP address

## Description
Displays your public/external IP address by querying an external service.

## Usage
```
myip
```

## Examples
```
# Show public IP
myip
# Output: 203.0.113.42

# Save IP to variable
MY_IP=$(myip)
echo "My IP is: $MY_IP"
```

## See Also
- localip - Get local IP addresses
- netinterfaces - Show network interfaces
- dnslookup - DNS lookup
