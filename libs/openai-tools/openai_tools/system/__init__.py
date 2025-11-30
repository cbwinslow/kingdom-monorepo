"""
System operations tools for AI agents.

Provides system-level operations including command execution, environment
variable access, process management, and system information retrieval.
"""

import os
import subprocess
import platform
import sys
from typing import Dict, Any, Optional, List
import psutil


def execute_command(
    command: str,
    timeout: int = 30,
    shell: bool = True,
    cwd: Optional[str] = None,
) -> Dict[str, Any]:
    """
    Execute a shell command.
    
    Args:
        command: The command to execute
        timeout: Command timeout in seconds (default: 30)
        shell: Whether to execute through shell (default: True)
        cwd: Working directory for the command (default: current directory)
        
    Returns:
        Dictionary containing exit_code, stdout, and stderr
        
    Raises:
        subprocess.TimeoutExpired: If command times out
    """
    try:
        result = subprocess.run(
            command,
            shell=shell,
            capture_output=True,
            text=True,
            timeout=timeout,
            cwd=cwd,
        )
        
        return {
            "exit_code": result.returncode,
            "stdout": result.stdout,
            "stderr": result.stderr,
            "success": result.returncode == 0,
        }
    except subprocess.TimeoutExpired as e:
        return {
            "exit_code": -1,
            "stdout": e.stdout.decode() if e.stdout else "",
            "stderr": e.stderr.decode() if e.stderr else "",
            "success": False,
            "error": "Command timed out",
        }


def get_environment(variable_name: Optional[str] = None) -> Any:
    """
    Get environment variables.
    
    Args:
        variable_name: Optional specific variable name to get (default: return all)
        
    Returns:
        Value of the specific variable or dictionary of all environment variables
        
    Raises:
        KeyError: If specific variable is not found
    """
    if variable_name:
        return os.environ[variable_name]
    else:
        return dict(os.environ)


def set_environment(variable_name: str, value: str) -> str:
    """
    Set an environment variable (for current process only).
    
    Args:
        variable_name: Name of the environment variable
        value: Value to set
        
    Returns:
        Success message
    """
    os.environ[variable_name] = value
    return f"Set {variable_name} = {value}"


def list_processes(filter_name: Optional[str] = None) -> List[Dict[str, Any]]:
    """
    List running processes on the system.
    
    Args:
        filter_name: Optional process name filter (substring match)
        
    Returns:
        List of process dictionaries containing pid, name, status, and memory info
    """
    processes = []
    
    for proc in psutil.process_iter(['pid', 'name', 'status', 'memory_info', 'cpu_percent']):
        try:
            info = proc.info
            
            # Filter by name if specified
            if filter_name and filter_name.lower() not in info['name'].lower():
                continue
            
            processes.append({
                'pid': info['pid'],
                'name': info['name'],
                'status': info['status'],
                'memory_mb': info['memory_info'].rss / (1024 * 1024) if info['memory_info'] else 0,
                'cpu_percent': info.get('cpu_percent', 0),
            })
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            # Process may have terminated or we don't have permission
            continue
    
    return processes


def kill_process(pid: int, force: bool = False) -> str:
    """
    Terminate a process by PID.
    
    Args:
        pid: Process ID to terminate
        force: Whether to force kill (SIGKILL) or gracefully terminate (SIGTERM) (default: False)
        
    Returns:
        Success message
        
    Raises:
        psutil.NoSuchProcess: If process does not exist
        psutil.AccessDenied: If no permission to kill process
    """
    process = psutil.Process(pid)
    
    if force:
        process.kill()
        return f"Force killed process {pid} ({process.name()})"
    else:
        process.terminate()
        return f"Terminated process {pid} ({process.name()})"


def get_system_info() -> Dict[str, Any]:
    """
    Get comprehensive system information.
    
    Returns:
        Dictionary containing OS, platform, CPU, memory, and disk information
    """
    cpu_freq = psutil.cpu_freq()
    memory = psutil.virtual_memory()
    disk = psutil.disk_usage('/')
    
    return {
        'platform': {
            'system': platform.system(),
            'release': platform.release(),
            'version': platform.version(),
            'machine': platform.machine(),
            'processor': platform.processor(),
            'python_version': platform.python_version(),
        },
        'cpu': {
            'physical_cores': psutil.cpu_count(logical=False),
            'logical_cores': psutil.cpu_count(logical=True),
            'current_freq_mhz': cpu_freq.current if cpu_freq else None,
            'max_freq_mhz': cpu_freq.max if cpu_freq else None,
            'cpu_percent': psutil.cpu_percent(interval=1),
        },
        'memory': {
            'total_gb': memory.total / (1024 ** 3),
            'available_gb': memory.available / (1024 ** 3),
            'used_gb': memory.used / (1024 ** 3),
            'percent': memory.percent,
        },
        'disk': {
            'total_gb': disk.total / (1024 ** 3),
            'used_gb': disk.used / (1024 ** 3),
            'free_gb': disk.free / (1024 ** 3),
            'percent': disk.percent,
        },
    }


def get_cpu_info() -> Dict[str, Any]:
    """
    Get detailed CPU information.
    
    Returns:
        Dictionary containing CPU metrics
    """
    cpu_freq = psutil.cpu_freq()
    cpu_percent = psutil.cpu_percent(interval=1, percpu=True)
    
    return {
        'physical_cores': psutil.cpu_count(logical=False),
        'logical_cores': psutil.cpu_count(logical=True),
        'current_freq_mhz': cpu_freq.current if cpu_freq else None,
        'max_freq_mhz': cpu_freq.max if cpu_freq else None,
        'overall_percent': sum(cpu_percent) / len(cpu_percent),
        'per_core_percent': cpu_percent,
    }


def get_memory_info() -> Dict[str, Any]:
    """
    Get detailed memory information.
    
    Returns:
        Dictionary containing memory metrics
    """
    memory = psutil.virtual_memory()
    swap = psutil.swap_memory()
    
    return {
        'virtual': {
            'total_gb': memory.total / (1024 ** 3),
            'available_gb': memory.available / (1024 ** 3),
            'used_gb': memory.used / (1024 ** 3),
            'free_gb': memory.free / (1024 ** 3),
            'percent': memory.percent,
        },
        'swap': {
            'total_gb': swap.total / (1024 ** 3),
            'used_gb': swap.used / (1024 ** 3),
            'free_gb': swap.free / (1024 ** 3),
            'percent': swap.percent,
        },
    }


def get_disk_info(path: str = "/") -> Dict[str, Any]:
    """
    Get disk usage information for a specific path.
    
    Args:
        path: Path to check disk usage for (default: /)
        
    Returns:
        Dictionary containing disk usage metrics
    """
    disk = psutil.disk_usage(path)
    
    return {
        'path': path,
        'total_gb': disk.total / (1024 ** 3),
        'used_gb': disk.used / (1024 ** 3),
        'free_gb': disk.free / (1024 ** 3),
        'percent': disk.percent,
    }


def read_stdin(timeout: int = 10) -> str:
    """
    Read input from standard input.
    
    Args:
        timeout: Timeout in seconds for reading (default: 10)
        
    Returns:
        The input text read from stdin
    """
    import select
    
    if sys.stdin in select.select([sys.stdin], [], [], timeout)[0]:
        return sys.stdin.readline().strip()
    else:
        return ""


def write_stdout(text: str) -> str:
    """
    Write text to standard output.
    
    Args:
        text: Text to write to stdout
        
    Returns:
        Success message
    """
    sys.stdout.write(text)
    sys.stdout.flush()
    return f"Written {len(text)} characters to stdout"


def write_stderr(text: str) -> str:
    """
    Write text to standard error.
    
    Args:
        text: Text to write to stderr
        
    Returns:
        Success message
    """
    sys.stderr.write(text)
    sys.stderr.flush()
    return f"Written {len(text)} characters to stderr"


__all__ = [
    "execute_command",
    "get_environment",
    "set_environment",
    "list_processes",
    "kill_process",
    "get_system_info",
    "get_cpu_info",
    "get_memory_info",
    "get_disk_info",
    "read_stdin",
    "write_stdout",
    "write_stderr",
]
