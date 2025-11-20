"""Tests for schema generator."""

import pytest
from openai_tools.schema_generator import generate_schema, python_type_to_json_type


def example_function(param1: str, param2: int = 10) -> str:
    """
    Example function for testing.
    
    Args:
        param1: The first parameter
        param2: The second parameter
        
    Returns:
        A string result
    """
    return f"{param1}-{param2}"


def test_generate_schema():
    """Test schema generation for a function."""
    schema = generate_schema(example_function)
    
    assert schema["name"] == "example_function"
    assert "description" in schema
    assert "parameters" in schema
    assert schema["parameters"]["type"] == "object"
    assert "properties" in schema["parameters"]
    
    # Check parameters
    props = schema["parameters"]["properties"]
    assert "param1" in props
    assert "param2" in props
    
    # Check required parameters
    assert "required" in schema["parameters"]
    assert "param1" in schema["parameters"]["required"]
    assert "param2" not in schema["parameters"]["required"]  # Has default


def test_python_type_to_json_type():
    """Test type conversion from Python to JSON schema types."""
    assert python_type_to_json_type(str) == "string"
    assert python_type_to_json_type(int) == "integer"
    assert python_type_to_json_type(float) == "number"
    assert python_type_to_json_type(bool) == "boolean"
    assert python_type_to_json_type(list) == "array"
    assert python_type_to_json_type(dict) == "object"


def test_schema_with_no_params():
    """Test schema generation for function with no parameters."""
    def no_params_func() -> str:
        """A function with no parameters."""
        return "result"
    
    schema = generate_schema(no_params_func)
    
    assert schema["name"] == "no_params_func"
    assert schema["parameters"]["properties"] == {}
    assert "required" not in schema["parameters"] or schema["parameters"]["required"] == []
