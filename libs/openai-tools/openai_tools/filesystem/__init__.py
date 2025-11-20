"""
Filesystem operations tools for AI agents.

Provides safe, validated filesystem operations including reading, writing,
listing, searching, copying, moving, and deleting files and directories.
"""

import os
import shutil
import glob
import pathlib
from typing import List, Dict, Any, Optional


def read_file(file_path: str, encoding: str = "utf-8") -> str:
    """
    Read the contents of a file from the filesystem.
    
    Args:
        file_path: The path to the file to read
        encoding: The file encoding (default: utf-8)
        
    Returns:
        The contents of the file as a string
        
    Raises:
        FileNotFoundError: If the file does not exist
        PermissionError: If the file cannot be read
        UnicodeDecodeError: If the file cannot be decoded with the specified encoding
    """
    file_path = os.path.abspath(file_path)
    
    with open(file_path, "r", encoding=encoding) as f:
        return f.read()


def write_file(file_path: str, content: str, encoding: str = "utf-8", append: bool = False) -> str:
    """
    Write content to a file in the filesystem.
    
    Args:
        file_path: The path to the file to write
        content: The content to write to the file
        encoding: The file encoding (default: utf-8)
        append: Whether to append to the file or overwrite it (default: False)
        
    Returns:
        Success message with the file path
        
    Raises:
        PermissionError: If the file cannot be written
    """
    file_path = os.path.abspath(file_path)
    
    # Create parent directories if they don't exist
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    
    mode = "a" if append else "w"
    with open(file_path, mode, encoding=encoding) as f:
        f.write(content)
    
    action = "appended to" if append else "written to"
    return f"Content successfully {action} {file_path}"


def list_directory(
    directory_path: str, recursive: bool = False, pattern: str = "*"
) -> List[Dict[str, Any]]:
    """
    List contents of a directory.
    
    Args:
        directory_path: The path to the directory to list
        recursive: Whether to list subdirectories recursively (default: False)
        pattern: Glob pattern to filter files (default: *)
        
    Returns:
        List of dictionaries containing file information (name, type, size, modified_time)
        
    Raises:
        FileNotFoundError: If the directory does not exist
        NotADirectoryError: If the path is not a directory
    """
    directory_path = os.path.abspath(directory_path)
    
    if not os.path.exists(directory_path):
        raise FileNotFoundError(f"Directory not found: {directory_path}")
    
    if not os.path.isdir(directory_path):
        raise NotADirectoryError(f"Not a directory: {directory_path}")
    
    results = []
    
    if recursive:
        search_pattern = os.path.join(directory_path, "**", pattern)
        paths = glob.glob(search_pattern, recursive=True)
    else:
        search_pattern = os.path.join(directory_path, pattern)
        paths = glob.glob(search_pattern)
    
    for path in paths:
        try:
            stat = os.stat(path)
            results.append({
                "name": os.path.basename(path),
                "path": path,
                "type": "directory" if os.path.isdir(path) else "file",
                "size": stat.st_size if os.path.isfile(path) else None,
                "modified_time": stat.st_mtime,
            })
        except (OSError, PermissionError):
            # Skip files we can't access
            continue
    
    return results


def search_files(directory_path: str, pattern: str, recursive: bool = True) -> List[str]:
    """
    Search for files matching a pattern in a directory.
    
    Args:
        directory_path: The directory to search in
        pattern: Glob pattern to match files (e.g., *.py, test_*.txt)
        recursive: Whether to search subdirectories recursively (default: True)
        
    Returns:
        List of file paths matching the pattern
        
    Raises:
        FileNotFoundError: If the directory does not exist
    """
    directory_path = os.path.abspath(directory_path)
    
    if not os.path.exists(directory_path):
        raise FileNotFoundError(f"Directory not found: {directory_path}")
    
    if recursive:
        search_pattern = os.path.join(directory_path, "**", pattern)
        return glob.glob(search_pattern, recursive=True)
    else:
        search_pattern = os.path.join(directory_path, pattern)
        return glob.glob(search_pattern)


def copy_file(source_path: str, destination_path: str, overwrite: bool = False) -> str:
    """
    Copy a file or directory to a new location.
    
    Args:
        source_path: The path to the source file or directory
        destination_path: The path to the destination
        overwrite: Whether to overwrite if destination exists (default: False)
        
    Returns:
        Success message with source and destination paths
        
    Raises:
        FileNotFoundError: If the source does not exist
        FileExistsError: If destination exists and overwrite is False
    """
    source_path = os.path.abspath(source_path)
    destination_path = os.path.abspath(destination_path)
    
    if not os.path.exists(source_path):
        raise FileNotFoundError(f"Source not found: {source_path}")
    
    if os.path.exists(destination_path) and not overwrite:
        raise FileExistsError(f"Destination already exists: {destination_path}")
    
    # Create parent directories if needed
    os.makedirs(os.path.dirname(destination_path), exist_ok=True)
    
    if os.path.isdir(source_path):
        if os.path.exists(destination_path):
            shutil.rmtree(destination_path)
        shutil.copytree(source_path, destination_path)
        return f"Directory copied from {source_path} to {destination_path}"
    else:
        shutil.copy2(source_path, destination_path)
        return f"File copied from {source_path} to {destination_path}"


def move_file(source_path: str, destination_path: str, overwrite: bool = False) -> str:
    """
    Move or rename a file or directory.
    
    Args:
        source_path: The path to the source file or directory
        destination_path: The path to the destination
        overwrite: Whether to overwrite if destination exists (default: False)
        
    Returns:
        Success message with source and destination paths
        
    Raises:
        FileNotFoundError: If the source does not exist
        FileExistsError: If destination exists and overwrite is False
    """
    source_path = os.path.abspath(source_path)
    destination_path = os.path.abspath(destination_path)
    
    if not os.path.exists(source_path):
        raise FileNotFoundError(f"Source not found: {source_path}")
    
    if os.path.exists(destination_path) and not overwrite:
        raise FileExistsError(f"Destination already exists: {destination_path}")
    
    # Create parent directories if needed
    os.makedirs(os.path.dirname(destination_path), exist_ok=True)
    
    if os.path.exists(destination_path):
        if os.path.isdir(destination_path):
            shutil.rmtree(destination_path)
        else:
            os.remove(destination_path)
    
    shutil.move(source_path, destination_path)
    return f"Moved from {source_path} to {destination_path}"


def delete_file(file_path: str, recursive: bool = False) -> str:
    """
    Delete a file or directory.
    
    Args:
        file_path: The path to the file or directory to delete
        recursive: Required to be True to delete directories (safety feature)
        
    Returns:
        Success message with the deleted path
        
    Raises:
        FileNotFoundError: If the file does not exist
        IsADirectoryError: If trying to delete a directory without recursive=True
    """
    file_path = os.path.abspath(file_path)
    
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"Path not found: {file_path}")
    
    if os.path.isdir(file_path):
        if not recursive:
            raise IsADirectoryError(
                f"Cannot delete directory without recursive=True: {file_path}"
            )
        shutil.rmtree(file_path)
        return f"Directory deleted: {file_path}"
    else:
        os.remove(file_path)
        return f"File deleted: {file_path}"


def get_file_info(file_path: str) -> Dict[str, Any]:
    """
    Get detailed information about a file or directory.
    
    Args:
        file_path: The path to the file or directory
        
    Returns:
        Dictionary containing file metadata (name, path, type, size, permissions, times)
        
    Raises:
        FileNotFoundError: If the file does not exist
    """
    file_path = os.path.abspath(file_path)
    
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"Path not found: {file_path}")
    
    stat = os.stat(file_path)
    
    return {
        "name": os.path.basename(file_path),
        "path": file_path,
        "type": "directory" if os.path.isdir(file_path) else "file",
        "size": stat.st_size if os.path.isfile(file_path) else None,
        "created_time": stat.st_ctime,
        "modified_time": stat.st_mtime,
        "accessed_time": stat.st_atime,
        "permissions": oct(stat.st_mode)[-3:],
        "is_readable": os.access(file_path, os.R_OK),
        "is_writable": os.access(file_path, os.W_OK),
        "is_executable": os.access(file_path, os.X_OK),
    }


def create_directory(directory_path: str, parents: bool = True) -> str:
    """
    Create a new directory.
    
    Args:
        directory_path: The path to the directory to create
        parents: Whether to create parent directories if they don't exist (default: True)
        
    Returns:
        Success message with the created directory path
        
    Raises:
        FileExistsError: If the directory already exists
    """
    directory_path = os.path.abspath(directory_path)
    
    if os.path.exists(directory_path):
        raise FileExistsError(f"Directory already exists: {directory_path}")
    
    os.makedirs(directory_path, exist_ok=parents)
    return f"Directory created: {directory_path}"


__all__ = [
    "read_file",
    "write_file",
    "list_directory",
    "search_files",
    "copy_file",
    "move_file",
    "delete_file",
    "get_file_info",
    "create_directory",
]
