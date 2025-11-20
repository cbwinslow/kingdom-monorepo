# denter - Enter running container

## Description
Opens an interactive shell session inside a running Docker container. Tries bash first, falls back to sh if bash is not available.

## Usage
```
denter <container_name_or_id>
```

## Parameters
- `container_name_or_id` (required): Container name or ID

## Examples
```
# Enter container by name
denter web_app

# Enter container by ID
denter a1b2c3d4

# Common use case
dps                    # List running containers
denter container_name  # Enter the container
```

## See Also
- dps - List running containers
- dlogs - View container logs
- dex - Execute command in container
