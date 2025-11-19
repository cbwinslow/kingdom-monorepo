"""
Example of using OpenAI-compatible tools with OpenAI API.

This demonstrates how to integrate the tools with OpenAI's function calling.
"""

import json
from openai_tools import generate_openai_schemas, execute_tool, get_all_tools


def simulate_openai_function_call():
    """
    Simulate an OpenAI function calling workflow.
    
    In a real scenario, you would:
    1. Send the function schemas to OpenAI API
    2. Get back a function call from the model
    3. Execute the function locally
    4. Send the result back to OpenAI
    """
    print("=== OpenAI Function Calling Integration Example ===\n")
    
    # Step 1: Get all available function schemas
    schemas = generate_openai_schemas()
    print(f"Step 1: Generated {len(schemas)} function schemas for OpenAI")
    
    # Show a few example schemas
    print("\nExample schemas:")
    for schema in schemas[:3]:
        print(f"  - {schema['name']}: {schema['description']}")
    
    # Step 2: Simulate OpenAI returning a function call
    print("\n" + "="*60)
    print("Step 2: Simulating OpenAI model choosing to call a function")
    print("="*60)
    
    # Simulate the model deciding to read a file
    simulated_function_call = {
        "name": "read_file",
        "arguments": {
            "file_path": "/tmp/test.txt",
            "encoding": "utf-8"
        }
    }
    
    print(f"\nModel chose function: {simulated_function_call['name']}")
    print(f"With arguments: {json.dumps(simulated_function_call['arguments'], indent=2)}")
    
    # Step 3: Execute the function locally
    print("\n" + "="*60)
    print("Step 3: Executing the function locally")
    print("="*60)
    
    # First, create a test file
    from openai_tools.filesystem import write_file
    write_file("/tmp/test.txt", "This is test content for OpenAI integration!")
    print("\nCreated test file...")
    
    # Execute the function
    try:
        result = execute_tool(
            simulated_function_call["name"],
            simulated_function_call["arguments"]
        )
        print(f"\nFunction executed successfully!")
        print(f"Result: {result}")
        
    except Exception as e:
        print(f"\nFunction execution failed: {e}")
        result = f"Error: {e}"
    
    # Step 4: Format result for OpenAI
    print("\n" + "="*60)
    print("Step 4: Sending result back to OpenAI")
    print("="*60)
    
    function_response = {
        "role": "function",
        "name": simulated_function_call["name"],
        "content": str(result)
    }
    
    print(f"\nFormatted response:")
    print(json.dumps(function_response, indent=2))


def show_schema_filtering():
    """Show how to filter schemas by domain."""
    print("\n\n=== Filtering Schemas by Domain ===\n")
    
    tools = get_all_tools()
    
    # Group tools by module
    by_module = {}
    for name, func in tools.items():
        module = func.__module__.split('.')[-1]
        if module not in by_module:
            by_module[module] = []
        by_module[module].append(name)
    
    print("You can send only relevant tools to OpenAI to reduce token usage:")
    print("\nExample: Only filesystem and data processing tools")
    
    from openai_tools.schema_generator import generate_schema
    
    # Get only filesystem and data tools
    relevant_schemas = []
    for name, func in tools.items():
        module = func.__module__.split('.')[-1]
        if module in ['filesystem', 'data']:
            relevant_schemas.append(generate_schema(func))
    
    print(f"\nFiltered to {len(relevant_schemas)} tools:")
    for schema in relevant_schemas[:5]:
        print(f"  - {schema['name']}")
    print("  ...")


def show_usage_with_pseudocode():
    """Show pseudocode for actual OpenAI integration."""
    print("\n\n=== Actual OpenAI Integration (Pseudocode) ===\n")
    
    code = '''
import openai
from openai_tools import generate_openai_schemas, execute_tool

# Get function schemas
functions = generate_openai_schemas()

# Or filter to specific domains
from openai_tools import get_all_tools
from openai_tools.schema_generator import generate_schema

tools = get_all_tools()
filesystem_tools = {
    name: func for name, func in tools.items() 
    if 'filesystem' in func.__module__
}
functions = [generate_schema(func) for func in filesystem_tools.values()]

# Make initial request to OpenAI
response = openai.ChatCompletion.create(
    model="gpt-4",
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "What files are in /tmp?"}
    ],
    functions=functions,
    function_call="auto"
)

# Check if model wants to call a function
message = response["choices"][0]["message"]

if message.get("function_call"):
    # Extract function call details
    function_name = message["function_call"]["name"]
    function_args = json.loads(message["function_call"]["arguments"])
    
    # Execute the function
    function_result = execute_tool(function_name, function_args)
    
    # Send result back to OpenAI
    second_response = openai.ChatCompletion.create(
        model="gpt-4",
        messages=[
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": "What files are in /tmp?"},
            message,  # Include the assistant's function call
            {
                "role": "function",
                "name": function_name,
                "content": str(function_result)
            }
        ]
    )
    
    # Get the final response
    final_answer = second_response["choices"][0]["message"]["content"]
    print(final_answer)
'''
    
    print(code)


def main():
    """Run all examples."""
    simulate_openai_function_call()
    show_schema_filtering()
    show_usage_with_pseudocode()
    
    print("\n" + "="*60)
    print("Examples completed!")
    print("="*60)


if __name__ == "__main__":
    main()
