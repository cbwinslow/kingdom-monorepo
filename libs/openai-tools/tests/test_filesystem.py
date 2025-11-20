"""Tests for filesystem operations."""

import pytest
import os
import tempfile
from openai_tools.filesystem import (
    read_file,
    write_file,
    list_directory,
    search_files,
    copy_file,
    move_file,
    delete_file,
    get_file_info,
    create_directory,
)


@pytest.fixture
def temp_dir():
    """Create a temporary directory for tests."""
    with tempfile.TemporaryDirectory() as tmpdir:
        yield tmpdir


def test_write_and_read_file(temp_dir):
    """Test writing and reading a file."""
    file_path = os.path.join(temp_dir, "test.txt")
    content = "Hello, World!"
    
    write_file(file_path, content)
    assert os.path.exists(file_path)
    
    read_content = read_file(file_path)
    assert read_content == content


def test_list_directory(temp_dir):
    """Test listing directory contents."""
    # Create some test files
    for i in range(3):
        write_file(os.path.join(temp_dir, f"file{i}.txt"), f"content{i}")
    
    files = list_directory(temp_dir)
    assert len(files) >= 3
    assert all(f["type"] in ["file", "directory"] for f in files)


def test_search_files(temp_dir):
    """Test searching for files."""
    # Create test files
    write_file(os.path.join(temp_dir, "test1.txt"), "content")
    write_file(os.path.join(temp_dir, "test2.txt"), "content")
    write_file(os.path.join(temp_dir, "other.md"), "content")
    
    # Search for .txt files
    txt_files = search_files(temp_dir, "*.txt", recursive=False)
    assert len(txt_files) == 2


def test_copy_file(temp_dir):
    """Test copying a file."""
    source = os.path.join(temp_dir, "source.txt")
    dest = os.path.join(temp_dir, "dest.txt")
    
    write_file(source, "test content")
    copy_file(source, dest)
    
    assert os.path.exists(dest)
    assert read_file(dest) == "test content"


def test_move_file(temp_dir):
    """Test moving a file."""
    source = os.path.join(temp_dir, "source.txt")
    dest = os.path.join(temp_dir, "dest.txt")
    
    write_file(source, "test content")
    move_file(source, dest)
    
    assert not os.path.exists(source)
    assert os.path.exists(dest)
    assert read_file(dest) == "test content"


def test_delete_file(temp_dir):
    """Test deleting a file."""
    file_path = os.path.join(temp_dir, "delete_me.txt")
    
    write_file(file_path, "content")
    assert os.path.exists(file_path)
    
    delete_file(file_path)
    assert not os.path.exists(file_path)


def test_get_file_info(temp_dir):
    """Test getting file information."""
    file_path = os.path.join(temp_dir, "info.txt")
    write_file(file_path, "test")
    
    info = get_file_info(file_path)
    
    assert info["name"] == "info.txt"
    assert info["type"] == "file"
    assert info["size"] > 0
    assert "modified_time" in info


def test_create_directory(temp_dir):
    """Test creating a directory."""
    dir_path = os.path.join(temp_dir, "new_dir")
    
    create_directory(dir_path)
    assert os.path.isdir(dir_path)
