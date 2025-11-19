# dlogs - Docker container logs

## Description
Shows and follows logs for a Docker container with optional tail limit.

## Usage
```
dlogs <container_name_or_id> [lines]
```

## Parameters
- `container_name_or_id` (required): Container name or ID
- `lines` (optional): Number of recent lines to show (default: 100)

## Examples
```
# Follow logs for container (last 100 lines)
dlogs web_app

# Show last 50 lines and follow
dlogs web_app 50

# Show all logs and follow
dlogs api_server 1000
```

## Notes
- Press Ctrl+C to stop following logs
- Logs are shown in real-time

## See Also
- denter - Enter container shell
- dps - List running containers
- dinspect - Inspect container details
