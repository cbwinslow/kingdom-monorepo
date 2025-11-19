"""Tests for data processing operations."""

import pytest
from openai_tools.data import (
    parse_json,
    stringify_json,
    parse_yaml,
    stringify_yaml,
    parse_csv,
    stringify_csv,
    filter_data,
    group_by,
    sort_data,
)


def test_parse_json():
    """Test JSON parsing."""
    json_str = '{"name": "Alice", "age": 30}'
    data = parse_json(json_str)
    
    assert data["name"] == "Alice"
    assert data["age"] == 30


def test_stringify_json():
    """Test JSON stringification."""
    data = {"name": "Bob", "age": 25}
    json_str = stringify_json(data)
    
    assert "Bob" in json_str
    assert "25" in json_str


def test_parse_yaml():
    """Test YAML parsing."""
    yaml_str = """
name: Charlie
age: 35
hobbies:
  - reading
  - coding
"""
    data = parse_yaml(yaml_str)
    
    assert data["name"] == "Charlie"
    assert data["age"] == 35
    assert "reading" in data["hobbies"]


def test_stringify_yaml():
    """Test YAML stringification."""
    data = {"name": "David", "skills": ["python", "javascript"]}
    yaml_str = stringify_yaml(data)
    
    assert "David" in yaml_str
    assert "python" in yaml_str


def test_parse_csv():
    """Test CSV parsing."""
    csv_str = """name,age,city
Alice,30,NYC
Bob,25,LA"""
    
    data = parse_csv(csv_str)
    
    assert len(data) == 2
    assert data[0]["name"] == "Alice"
    assert data[1]["age"] == "25"


def test_stringify_csv():
    """Test CSV stringification."""
    data = [
        {"name": "Alice", "age": 30},
        {"name": "Bob", "age": 25},
    ]
    
    csv_str = stringify_csv(data)
    
    assert "Alice" in csv_str
    assert "Bob" in csv_str
    assert "name,age" in csv_str or "age,name" in csv_str


def test_filter_data():
    """Test data filtering."""
    data = [
        {"name": "Alice", "score": 85},
        {"name": "Bob", "score": 92},
        {"name": "Charlie", "score": 78},
    ]
    
    filtered = filter_data(data, "score", 80, operator=">")
    
    assert len(filtered) == 2
    assert all(item["score"] > 80 for item in filtered)


def test_group_by():
    """Test data grouping."""
    data = [
        {"category": "A", "value": 10},
        {"category": "B", "value": 20},
        {"category": "A", "value": 15},
    ]
    
    grouped = group_by(data, "category")
    
    assert "A" in grouped
    assert "B" in grouped
    assert len(grouped["A"]) == 2
    assert len(grouped["B"]) == 1


def test_sort_data():
    """Test data sorting."""
    data = [
        {"name": "Charlie", "age": 35},
        {"name": "Alice", "age": 30},
        {"name": "Bob", "age": 25},
    ]
    
    sorted_data = sort_data(data, "age")
    
    assert sorted_data[0]["name"] == "Bob"
    assert sorted_data[1]["name"] == "Alice"
    assert sorted_data[2]["name"] == "Charlie"
