"""
OpenAI function schema generator.

Automatically generates OpenAI-compatible function schemas from Python functions.
"""

import inspect
from typing import Any, Callable, Dict, List, get_type_hints, get_args, get_origin


def python_type_to_json_type(py_type: Any) -> str:
    """
    Convert Python type to JSON schema type.
    
    Args:
        py_type: Python type annotation
        
    Returns:
        JSON schema type string
    """
    # Handle None/NoneType
    if py_type is type(None) or py_type is None:
        return "null"
    
    # Get origin for generic types (List, Dict, etc.)
    origin = get_origin(py_type)
    
    if origin is list or py_type is list:
        return "array"
    elif origin is dict or py_type is dict:
        return "object"
    elif origin is tuple or py_type is tuple:
        return "array"
    
    # Handle basic types
    type_map = {
        str: "string",
        int: "integer",
        float: "number",
        bool: "boolean",
        list: "array",
        dict: "object",
        Any: "string",  # Default to string for Any
    }
    
    return type_map.get(py_type, "string")


def extract_param_info_from_docstring(docstring: str) -> Dict[str, str]:
    """
    Extract parameter descriptions from docstring.
    
    Args:
        docstring: The function's docstring
        
    Returns:
        Dictionary mapping parameter names to descriptions
    """
    param_descriptions = {}
    
    if not docstring:
        return param_descriptions
    
    lines = docstring.split("\n")
    in_args_section = False
    current_param = None
    current_desc = []
    
    for line in lines:
        stripped = line.strip()
        
        # Check for Args section
        if stripped.lower() in ["args:", "arguments:", "parameters:"]:
            in_args_section = True
            continue
        
        # Check for end of args section
        if in_args_section and stripped and stripped[0].isupper() and stripped.endswith(":"):
            # New section started
            if current_param and current_desc:
                param_descriptions[current_param] = " ".join(current_desc).strip()
            break
        
        if in_args_section and stripped:
            # Check if it's a parameter line
            if ":" in stripped:
                # Save previous parameter if exists
                if current_param and current_desc:
                    param_descriptions[current_param] = " ".join(current_desc).strip()
                
                # Parse new parameter
                parts = stripped.split(":", 1)
                current_param = parts[0].strip()
                if len(parts) > 1:
                    current_desc = [parts[1].strip()]
                else:
                    current_desc = []
            else:
                # Continuation of description
                current_desc.append(stripped)
    
    # Save last parameter
    if current_param and current_desc:
        param_descriptions[current_param] = " ".join(current_desc).strip()
    
    return param_descriptions


def generate_schema(func: Callable[..., Any]) -> Dict[str, Any]:
    """
    Generate OpenAI function schema from a Python function.
    
    Args:
        func: The function to generate schema for
        
    Returns:
        OpenAI function schema dictionary
    """
    # Get function signature
    sig = inspect.signature(func)
    
    # Get type hints
    try:
        type_hints = get_type_hints(func)
    except Exception:
        type_hints = {}
    
    # Get docstring
    docstring = inspect.getdoc(func) or ""
    
    # Extract description (first line of docstring)
    description = docstring.split("\n")[0] if docstring else f"Execute {func.__name__}"
    
    # Extract parameter descriptions from docstring
    param_descriptions = extract_param_info_from_docstring(docstring)
    
    # Build parameters schema
    properties = {}
    required = []
    
    for param_name, param in sig.parameters.items():
        # Skip self, cls, *args, **kwargs
        if param_name in ["self", "cls"] or param.kind in [
            inspect.Parameter.VAR_POSITIONAL,
            inspect.Parameter.VAR_KEYWORD,
        ]:
            continue
        
        # Get parameter type
        param_type = type_hints.get(param_name, str)
        json_type = python_type_to_json_type(param_type)
        
        # Build parameter schema
        param_schema: Dict[str, Any] = {"type": json_type}
        
        # Add description if available
        if param_name in param_descriptions:
            param_schema["description"] = param_descriptions[param_name]
        else:
            param_schema["description"] = f"The {param_name} parameter"
        
        # Add enum if available in description
        desc = param_schema["description"]
        if "one of:" in desc.lower() or "options:" in desc.lower():
            # Try to extract enum values
            pass  # Could be enhanced
        
        # Add default value if available
        if param.default != inspect.Parameter.empty:
            if param.default is not None:
                param_schema["default"] = param.default
        else:
            # No default means required
            required.append(param_name)
        
        properties[param_name] = param_schema
    
    # Build final schema
    schema = {
        "name": func.__name__,
        "description": description,
        "parameters": {
            "type": "object",
            "properties": properties,
        },
    }
    
    if required:
        schema["parameters"]["required"] = required
    
    return schema


def generate_schemas_for_module(module: Any) -> List[Dict[str, Any]]:
    """
    Generate OpenAI schemas for all public functions in a module.
    
    Args:
        module: The module to generate schemas for
        
    Returns:
        List of OpenAI function schemas
    """
    schemas = []
    
    for name in dir(module):
        if not name.startswith("_"):
            obj = getattr(module, name)
            if callable(obj) and hasattr(obj, "__module__"):
                if obj.__module__ == module.__name__:
                    schema = generate_schema(obj)
                    schemas.append(schema)
    
    return schemas
