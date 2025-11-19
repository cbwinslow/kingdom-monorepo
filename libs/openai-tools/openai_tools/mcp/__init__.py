"""
MCP (Model Context Protocol) server operations tools.

Provides tools to manage and interact with MCP servers, including starting/stopping
servers, listing available tools, and calling MCP tools.
"""

import subprocess
import json
import time
from typing import Dict, Any, List, Optional


# In-memory MCP server registry
_MCP_SERVERS: Dict[str, Dict[str, Any]] = {}


def start_mcp_server(
    server_name: str,
    command: str,
    port: Optional[int] = None,
    config: Optional[Dict[str, Any]] = None,
) -> str:
    """
    Start an MCP server.
    
    Args:
        server_name: Unique name for the MCP server
        command: Command to start the server
        port: Optional port number for the server
        config: Optional configuration dictionary
        
    Returns:
        Success message with server name and status
    """
    if server_name in _MCP_SERVERS:
        return f"MCP server {server_name} is already running"
    
    try:
        # Start the server process
        process = subprocess.Popen(
            command,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        
        _MCP_SERVERS[server_name] = {
            "name": server_name,
            "command": command,
            "port": port,
            "config": config or {},
            "process": process,
            "pid": process.pid,
            "status": "running",
            "started_at": time.time(),
        }
        
        return f"MCP server {server_name} started with PID {process.pid}"
    except Exception as e:
        return f"Failed to start MCP server {server_name}: {str(e)}"


def stop_mcp_server(server_name: str, force: bool = False) -> str:
    """
    Stop an MCP server.
    
    Args:
        server_name: Name of the MCP server to stop
        force: Whether to force kill the server (default: False)
        
    Returns:
        Success message
    """
    if server_name not in _MCP_SERVERS:
        return f"MCP server {server_name} is not running"
    
    server = _MCP_SERVERS[server_name]
    process = server["process"]
    
    try:
        if force:
            process.kill()
        else:
            process.terminate()
        
        process.wait(timeout=5)
        
        del _MCP_SERVERS[server_name]
        
        return f"MCP server {server_name} stopped"
    except subprocess.TimeoutExpired:
        process.kill()
        del _MCP_SERVERS[server_name]
        return f"MCP server {server_name} force killed after timeout"
    except Exception as e:
        return f"Error stopping MCP server {server_name}: {str(e)}"


def list_mcp_servers() -> List[Dict[str, Any]]:
    """
    List all running MCP servers.
    
    Returns:
        List of MCP server information dictionaries
    """
    servers = []
    
    for name, info in _MCP_SERVERS.items():
        # Check if process is still running
        if info["process"].poll() is None:
            status = "running"
        else:
            status = "stopped"
            info["status"] = status
        
        servers.append({
            "name": name,
            "command": info["command"],
            "port": info["port"],
            "pid": info["pid"],
            "status": status,
            "uptime_seconds": time.time() - info["started_at"] if status == "running" else 0,
        })
    
    return servers


def get_mcp_status(server_name: str) -> Dict[str, Any]:
    """
    Get the status of a specific MCP server.
    
    Args:
        server_name: Name of the MCP server
        
    Returns:
        Server status information dictionary
        
    Raises:
        KeyError: If server not found
    """
    if server_name not in _MCP_SERVERS:
        raise KeyError(f"MCP server {server_name} not found")
    
    info = _MCP_SERVERS[server_name]
    
    # Check if process is still running
    is_running = info["process"].poll() is None
    
    return {
        "name": server_name,
        "command": info["command"],
        "port": info["port"],
        "pid": info["pid"],
        "status": "running" if is_running else "stopped",
        "uptime_seconds": time.time() - info["started_at"] if is_running else 0,
        "config": info["config"],
    }


def configure_mcp_server(server_name: str, config: Dict[str, Any]) -> str:
    """
    Configure an MCP server.
    
    Args:
        server_name: Name of the MCP server
        config: Configuration dictionary
        
    Returns:
        Success message
    """
    if server_name not in _MCP_SERVERS:
        return f"MCP server {server_name} not found"
    
    _MCP_SERVERS[server_name]["config"].update(config)
    
    return f"MCP server {server_name} configuration updated"


def list_mcp_tools(server_name: str) -> List[Dict[str, Any]]:
    """
    List available tools from an MCP server.
    
    Args:
        server_name: Name of the MCP server
        
    Returns:
        List of available tool definitions
        
    Note:
        This is a placeholder implementation. In a real system, this would
        query the MCP server's API to get available tools.
    """
    if server_name not in _MCP_SERVERS:
        return []
    
    # Placeholder - would query actual MCP server
    return [
        {
            "name": "example_tool",
            "description": "An example tool from the MCP server",
            "parameters": {},
        }
    ]


def call_mcp_tool(
    server_name: str,
    tool_name: str,
    arguments: Dict[str, Any],
    timeout: int = 30,
) -> Any:
    """
    Call a tool on an MCP server.
    
    Args:
        server_name: Name of the MCP server
        tool_name: Name of the tool to call
        arguments: Arguments to pass to the tool
        timeout: Timeout in seconds (default: 30)
        
    Returns:
        Result from the tool execution
        
    Raises:
        KeyError: If server not found
        
    Note:
        This is a placeholder implementation. In a real system, this would
        make an actual call to the MCP server's API.
    """
    if server_name not in _MCP_SERVERS:
        raise KeyError(f"MCP server {server_name} not found")
    
    server = _MCP_SERVERS[server_name]
    
    # Placeholder - would make actual API call to MCP server
    return {
        "server": server_name,
        "tool": tool_name,
        "arguments": arguments,
        "result": "Tool execution placeholder",
        "status": "success",
    }


def restart_mcp_server(server_name: str) -> str:
    """
    Restart an MCP server.
    
    Args:
        server_name: Name of the MCP server to restart
        
    Returns:
        Success message
    """
    if server_name not in _MCP_SERVERS:
        return f"MCP server {server_name} not found"
    
    # Get server info before stopping
    server = _MCP_SERVERS[server_name]
    command = server["command"]
    port = server["port"]
    config = server["config"]
    
    # Stop the server
    stop_result = stop_mcp_server(server_name, force=False)
    
    # Wait a moment
    time.sleep(1)
    
    # Start the server again
    start_result = start_mcp_server(server_name, command, port, config)
    
    return f"MCP server {server_name} restarted"


def get_mcp_logs(server_name: str, lines: int = 50) -> Dict[str, List[str]]:
    """
    Get logs from an MCP server.
    
    Args:
        server_name: Name of the MCP server
        lines: Number of log lines to retrieve (default: 50)
        
    Returns:
        Dictionary containing stdout and stderr logs
    """
    if server_name not in _MCP_SERVERS:
        return {"stdout": [], "stderr": [], "error": f"Server {server_name} not found"}
    
    server = _MCP_SERVERS[server_name]
    process = server["process"]
    
    # Get available output (non-blocking)
    stdout_lines = []
    stderr_lines = []
    
    # This is a simplified version - in production would need better log handling
    return {
        "stdout": stdout_lines,
        "stderr": stderr_lines,
    }


__all__ = [
    "start_mcp_server",
    "stop_mcp_server",
    "list_mcp_servers",
    "get_mcp_status",
    "configure_mcp_server",
    "list_mcp_tools",
    "call_mcp_tool",
    "restart_mcp_server",
    "get_mcp_logs",
]
