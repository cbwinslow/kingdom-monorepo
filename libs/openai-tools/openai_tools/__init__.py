"""
OpenAI-Compatible Tools Library

A comprehensive collection of portable, robust tools for AI agents with OpenAI function calling support.
"""

from typing import Any, Dict, List, Callable
import importlib
import pkgutil

from .schema_generator import generate_schema, generate_schemas_for_module

__version__ = "0.1.0"

# Tool registry
_TOOL_REGISTRY: Dict[str, Callable[..., Any]] = {}


def register_tool(name: str, func: Callable[..., Any]) -> None:
    """
    Register a tool in the global registry.
    
    Args:
        name: The name of the tool
        func: The callable tool function
    """
    _TOOL_REGISTRY[name] = func


def get_tool(name: str) -> Callable[..., Any]:
    """
    Get a tool by name from the registry.
    
    Args:
        name: The name of the tool
        
    Returns:
        The tool function
        
    Raises:
        KeyError: If tool is not found
    """
    return _TOOL_REGISTRY[name]


def get_all_tools() -> Dict[str, Callable[..., Any]]:
    """
    Get all registered tools.
    
    Returns:
        Dictionary mapping tool names to tool functions
    """
    return _TOOL_REGISTRY.copy()


def generate_openai_schemas() -> List[Dict[str, Any]]:
    """
    Generate OpenAI function schemas for all registered tools.
    
    Returns:
        List of OpenAI function schema dictionaries
    """
    schemas = []
    for name, func in _TOOL_REGISTRY.items():
        schema = generate_schema(func)
        schemas.append(schema)
    return schemas


def execute_tool(tool_name: str, arguments: Dict[str, Any]) -> Any:
    """
    Execute a tool by name with the given arguments.
    
    Args:
        tool_name: The name of the tool to execute
        arguments: Dictionary of arguments to pass to the tool
        
    Returns:
        The result of the tool execution
        
    Raises:
        KeyError: If tool is not found
        Exception: Any exception raised by the tool
    """
    tool = get_tool(tool_name)
    return tool(**arguments)


def load_all_tools() -> None:
    """Load all tools from submodules and register them."""
    import openai_tools.filesystem as filesystem
    import openai_tools.networking as networking
    import openai_tools.database as database
    import openai_tools.git_ops as git_ops
    import openai_tools.system as system
    import openai_tools.agent_comm as agent_comm
    import openai_tools.mcp as mcp
    import openai_tools.logical as logical
    import openai_tools.data as data
    import openai_tools.web as web

    modules = [
        filesystem,
        networking,
        database,
        git_ops,
        system,
        agent_comm,
        mcp,
        logical,
        data,
        web,
    ]

    for module in modules:
        # Get all public functions from the module
        for name in dir(module):
            if not name.startswith("_"):
                obj = getattr(module, name)
                if callable(obj) and hasattr(obj, "__module__"):
                    # Check if it's defined in this module (not imported)
                    if obj.__module__ == module.__name__:
                        register_tool(name, obj)


# Auto-load tools on import
load_all_tools()

__all__ = [
    "register_tool",
    "get_tool",
    "get_all_tools",
    "generate_openai_schemas",
    "execute_tool",
    "load_all_tools",
    "generate_schema",
]
