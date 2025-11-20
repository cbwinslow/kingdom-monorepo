"""
Networking tools for AI agents.

Provides HTTP requests, DNS lookups, ping operations, port checking,
and file downloading capabilities.
"""

import socket
import subprocess
import platform
from typing import Dict, Any, Optional, List
import requests
import dns.resolver


def http_request(
    url: str,
    method: str = "GET",
    headers: Optional[Dict[str, str]] = None,
    data: Optional[Dict[str, Any]] = None,
    timeout: int = 30,
) -> Dict[str, Any]:
    """
    Make an HTTP request to a URL.
    
    Args:
        url: The URL to make the request to
        method: HTTP method (GET, POST, PUT, DELETE, PATCH) (default: GET)
        headers: Optional dictionary of HTTP headers
        data: Optional dictionary of data to send in the request body
        timeout: Request timeout in seconds (default: 30)
        
    Returns:
        Dictionary containing status_code, headers, and body
        
    Raises:
        requests.RequestException: If the request fails
    """
    method = method.upper()
    
    response = requests.request(
        method=method,
        url=url,
        headers=headers,
        json=data if data else None,
        timeout=timeout,
    )
    
    return {
        "status_code": response.status_code,
        "headers": dict(response.headers),
        "body": response.text,
        "url": response.url,
    }


def dns_lookup(hostname: str, record_type: str = "A") -> List[str]:
    """
    Perform a DNS lookup for a hostname.
    
    Args:
        hostname: The hostname to look up
        record_type: DNS record type (A, AAAA, MX, NS, TXT, CNAME) (default: A)
        
    Returns:
        List of DNS records as strings
        
    Raises:
        dns.resolver.NXDOMAIN: If the domain does not exist
        dns.resolver.NoAnswer: If no records found for the query type
    """
    record_type = record_type.upper()
    
    answers = dns.resolver.resolve(hostname, record_type)
    return [str(rdata) for rdata in answers]


def ping_host(host: str, count: int = 4, timeout: int = 5) -> Dict[str, Any]:
    """
    Ping a host to check if it's reachable.
    
    Args:
        host: The hostname or IP address to ping
        count: Number of ping packets to send (default: 4)
        timeout: Timeout in seconds for each ping (default: 5)
        
    Returns:
        Dictionary containing success status and ping statistics
        
    Raises:
        subprocess.CalledProcessError: If ping command fails
    """
    # Determine ping command based on platform
    param = "-n" if platform.system().lower() == "windows" else "-c"
    timeout_param = "-w" if platform.system().lower() == "windows" else "-W"
    
    command = ["ping", param, str(count), timeout_param, str(timeout), host]
    
    try:
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            timeout=timeout * count + 5,
        )
        
        success = result.returncode == 0
        
        return {
            "success": success,
            "host": host,
            "packets_sent": count,
            "output": result.stdout,
            "error": result.stderr if not success else None,
        }
    except subprocess.TimeoutExpired:
        return {
            "success": False,
            "host": host,
            "packets_sent": count,
            "output": "",
            "error": "Ping command timed out",
        }


def check_port(host: str, port: int, timeout: int = 5) -> Dict[str, Any]:
    """
    Check if a TCP port is open on a host.
    
    Args:
        host: The hostname or IP address
        port: The port number to check
        timeout: Connection timeout in seconds (default: 5)
        
    Returns:
        Dictionary containing open status and connection info
    """
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(timeout)
    
    try:
        result = sock.connect_ex((host, port))
        is_open = result == 0
        
        return {
            "host": host,
            "port": port,
            "is_open": is_open,
            "status": "open" if is_open else "closed",
        }
    except socket.gaierror:
        return {
            "host": host,
            "port": port,
            "is_open": False,
            "status": "error",
            "error": "Hostname could not be resolved",
        }
    except socket.timeout:
        return {
            "host": host,
            "port": port,
            "is_open": False,
            "status": "timeout",
            "error": "Connection timed out",
        }
    finally:
        sock.close()


def download_file(url: str, destination_path: str, timeout: int = 60) -> str:
    """
    Download a file from a URL.
    
    Args:
        url: The URL to download from
        destination_path: The local path to save the file to
        timeout: Download timeout in seconds (default: 60)
        
    Returns:
        Success message with the destination path
        
    Raises:
        requests.RequestException: If the download fails
    """
    response = requests.get(url, stream=True, timeout=timeout)
    response.raise_for_status()
    
    with open(destination_path, "wb") as f:
        for chunk in response.iter_content(chunk_size=8192):
            f.write(chunk)
    
    return f"File downloaded to {destination_path}"


def get_public_ip() -> str:
    """
    Get the public IP address of the current machine.
    
    Returns:
        The public IP address as a string
        
    Raises:
        requests.RequestException: If unable to retrieve IP
    """
    response = requests.get("https://api.ipify.org", timeout=10)
    response.raise_for_status()
    return response.text


def resolve_hostname(ip_address: str) -> str:
    """
    Resolve an IP address to a hostname (reverse DNS lookup).
    
    Args:
        ip_address: The IP address to resolve
        
    Returns:
        The hostname associated with the IP address
        
    Raises:
        socket.herror: If the hostname cannot be resolved
    """
    hostname, _, _ = socket.gethostbyaddr(ip_address)
    return hostname


def get_network_interfaces() -> Dict[str, Any]:
    """
    Get information about network interfaces on the current machine.
    
    Returns:
        Dictionary containing hostname and IP addresses
    """
    hostname = socket.gethostname()
    
    try:
        local_ip = socket.gethostbyname(hostname)
    except socket.gaierror:
        local_ip = "127.0.0.1"
    
    return {
        "hostname": hostname,
        "local_ip": local_ip,
    }


__all__ = [
    "http_request",
    "dns_lookup",
    "ping_host",
    "check_port",
    "download_file",
    "get_public_ip",
    "resolve_hostname",
    "get_network_interfaces",
]
