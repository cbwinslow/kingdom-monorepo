# dcleanall - Full Docker cleanup

## Description
Performs a complete Docker cleanup, removing stopped containers, unused images, unused volumes, and unused networks.

**WARNING:** This will remove all unused Docker resources!

## Usage
```
dcleanall
```

## Examples
```
# Clean up all unused Docker resources
dcleanall
```

## See Also
- dcleanc - Remove stopped containers
- dcleani - Remove unused images
- dcleanv - Remove unused volumes
- ddiskusage - Show Docker disk usage
