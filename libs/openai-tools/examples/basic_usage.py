"""
Basic usage examples for OpenAI-compatible tools.

This script demonstrates how to use the tools and generate OpenAI function schemas.
"""

import json
from openai_tools import (
    get_all_tools,
    generate_openai_schemas,
    execute_tool,
)
from openai_tools.filesystem import read_file, write_file, list_directory
from openai_tools.networking import http_request, dns_lookup
from openai_tools.logical import logical_and, evaluate_condition
from openai_tools.data import parse_json, filter_data


def example_filesystem_operations():
    """Example of filesystem operations."""
    print("=== Filesystem Operations ===")
    
    # Write a file
    write_file("/tmp/test.txt", "Hello, World!")
    print("File written to /tmp/test.txt")
    
    # Read the file
    content = read_file("/tmp/test.txt")
    print(f"File content: {content}")
    
    # List directory
    files = list_directory("/tmp", pattern="test*")
    print(f"Found {len(files)} files matching pattern")


def example_networking_operations():
    """Example of networking operations."""
    print("\n=== Networking Operations ===")
    
    # DNS lookup
    try:
        ips = dns_lookup("google.com")
        print(f"Google.com resolves to: {ips}")
    except Exception as e:
        print(f"DNS lookup failed: {e}")
    
    # HTTP request (example.com is always available)
    try:
        response = http_request("https://example.com")
        print(f"HTTP request returned status: {response['status_code']}")
    except Exception as e:
        print(f"HTTP request failed: {e}")


def example_logical_operations():
    """Example of logical operations."""
    print("\n=== Logical Operations ===")
    
    # Boolean operations
    result1 = logical_and(True, True, False)
    print(f"logical_and(True, True, False) = {result1}")
    
    # Conditional evaluation
    result2 = evaluate_condition(10, ">", 5)
    print(f"evaluate_condition(10, '>', 5) = {result2}")
    
    result3 = evaluate_condition("hello", "starts_with", "hel")
    print(f"evaluate_condition('hello', 'starts_with', 'hel') = {result3}")


def example_data_operations():
    """Example of data operations."""
    print("\n=== Data Operations ===")
    
    # Parse JSON
    json_str = '{"name": "Alice", "age": 30, "city": "NYC"}'
    data = parse_json(json_str)
    print(f"Parsed JSON: {data}")
    
    # Filter data
    dataset = [
        {"name": "Alice", "age": 30, "score": 85},
        {"name": "Bob", "age": 25, "score": 92},
        {"name": "Charlie", "age": 35, "score": 78},
    ]
    
    filtered = filter_data(dataset, "score", 80, operator=">")
    print(f"Filtered data (score > 80): {filtered}")


def example_openai_schemas():
    """Example of generating OpenAI function schemas."""
    print("\n=== OpenAI Schema Generation ===")
    
    # Generate schemas for all tools
    schemas = generate_openai_schemas()
    print(f"Generated {len(schemas)} OpenAI function schemas")
    
    # Show example schema
    from openai_tools.filesystem import read_file
    from openai_tools.schema_generator import generate_schema
    
    schema = generate_schema(read_file)
    print("\nExample schema for 'read_file' function:")
    print(json.dumps(schema, indent=2))


def example_tool_execution():
    """Example of executing tools by name."""
    print("\n=== Tool Execution ===")
    
    # Execute tool by name (note: logical_and doesn't work well with execute_tool due to *args)
    # Use evaluate_condition instead
    result = execute_tool("evaluate_condition", {
        "left": 100,
        "operator": ">=",
        "right": 50,
    })
    print(f"Executed 'evaluate_condition' with result: {result}")
    
    # Another example with if_then_else
    result2 = execute_tool("if_then_else", {
        "condition": True,
        "if_true": "yes",
        "if_false": "no",
    })
    print(f"Executed 'if_then_else' with result: {result2}")


def example_listing_tools():
    """Example of listing available tools."""
    print("\n=== Available Tools ===")
    
    tools = get_all_tools()
    print(f"Total tools available: {len(tools)}")
    
    # Group by module
    by_module = {}
    for name, func in tools.items():
        module = func.__module__.split('.')[-1]
        if module not in by_module:
            by_module[module] = []
        by_module[module].append(name)
    
    for module, tool_names in sorted(by_module.items()):
        print(f"\n{module.upper()} ({len(tool_names)} tools):")
        for tool_name in sorted(tool_names):
            print(f"  - {tool_name}")


def main():
    """Run all examples."""
    print("OpenAI-Compatible Tools - Usage Examples")
    print("=" * 50)
    
    try:
        example_listing_tools()
        example_filesystem_operations()
        example_logical_operations()
        example_data_operations()
        example_openai_schemas()
        example_tool_execution()
        
        # Networking might fail in some environments
        try:
            example_networking_operations()
        except Exception as e:
            print(f"\nNetworking examples skipped: {e}")
        
        print("\n" + "=" * 50)
        print("All examples completed successfully!")
        
    except Exception as e:
        print(f"\nError running examples: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()
