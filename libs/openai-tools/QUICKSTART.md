# OpenAI Tools Quick Start Guide

Get started with the OpenAI-compatible tools library in 5 minutes.

## Installation

```bash
cd libs/openai-tools
pip install -e .

# Optional: Install database support
pip install -e ".[database]"

# Optional: Install dev tools
pip install -e ".[dev]"
```

## Basic Usage

### 1. Import and use tools directly

```python
from openai_tools.filesystem import read_file, write_file
from openai_tools.data import parse_json
from openai_tools.networking import http_request

# Use any tool
write_file("/tmp/data.txt", "Hello, World!")
content = read_file("/tmp/data.txt")

# Parse JSON
data = parse_json('{"name": "Alice", "age": 30}')

# Make HTTP request
response = http_request("https://api.example.com/data")
```

### 2. Generate OpenAI function schemas

```python
from openai_tools import generate_openai_schemas

# Get all 106 function schemas
schemas = generate_openai_schemas()

# Use with OpenAI API
import openai

response = openai.ChatCompletion.create(
    model="gpt-4",
    messages=[{"role": "user", "content": "List files in /tmp"}],
    functions=schemas,
    function_call="auto"
)
```

### 3. Execute tools by name

```python
from openai_tools import execute_tool

# Execute any tool by name
result = execute_tool("read_file", {
    "file_path": "/tmp/data.txt"
})

# Execute with OpenAI function call response
import json

function_call = response["choices"][0]["message"]["function_call"]
result = execute_tool(
    function_call["name"],
    json.loads(function_call["arguments"])
)
```

### 4. Filter tools by domain

```python
from openai_tools import get_all_tools
from openai_tools.schema_generator import generate_schema

tools = get_all_tools()

# Get only filesystem tools
fs_tools = {
    name: func for name, func in tools.items()
    if 'filesystem' in func.__module__
}

# Generate schemas for specific domain
fs_schemas = [generate_schema(func) for func in fs_tools.values()]
```

## Common Use Cases

### File Operations
```python
from openai_tools.filesystem import *

# Read and write files
content = read_file("input.txt")
write_file("output.txt", content.upper())

# List directory
files = list_directory("/path/to/dir", recursive=True, pattern="*.py")

# Copy and move files
copy_file("source.txt", "backup.txt")
move_file("old_name.txt", "new_name.txt")
```

### Data Processing
```python
from openai_tools.data import *

# Parse different formats
json_data = parse_json('{"key": "value"}')
yaml_data = parse_yaml("key: value")
csv_data = parse_csv("name,age\nAlice,30")

# Transform data
filtered = filter_data(data, "age", 18, operator=">")
sorted_data = sort_data(data, "name")
grouped = group_by(data, "category")
```

### Network Operations
```python
from openai_tools.networking import *

# HTTP requests
response = http_request("https://api.example.com", method="GET")

# DNS and connectivity
ips = dns_lookup("example.com")
status = check_port("example.com", 443)
ping_result = ping_host("example.com")
```

### Git Operations
```python
from openai_tools.git_ops import *

# Repository operations
status = git_status("/path/to/repo")
git_commit("/path/to/repo", "Update files")
git_push("/path/to/repo", "origin", "main")

# Branches
branches = git_branch("/path/to/repo", action="list")
git_branch("/path/to/repo", action="create", branch_name="feature")
```

### Logical Operations
```python
from openai_tools.logical import *

# Boolean logic
result = logical_and(True, True, False)  # False
result = logical_or(True, False, False)  # True

# Conditional evaluation
is_valid = evaluate_condition(score, ">", 80)
value = if_then_else(is_valid, "Pass", "Fail")
```

## Complete OpenAI Integration Example

```python
import openai
import json
from openai_tools import generate_openai_schemas, execute_tool

# Step 1: Get function schemas
functions = generate_openai_schemas()

# Step 2: Send to OpenAI
response = openai.ChatCompletion.create(
    model="gpt-4",
    messages=[
        {"role": "user", "content": "Read the file at /tmp/data.txt"}
    ],
    functions=functions,
    function_call="auto"
)

# Step 3: Execute function if called
message = response["choices"][0]["message"]
if message.get("function_call"):
    function_name = message["function_call"]["name"]
    arguments = json.loads(message["function_call"]["arguments"])
    
    # Execute the tool
    result = execute_tool(function_name, arguments)
    
    # Step 4: Send result back to OpenAI
    final_response = openai.ChatCompletion.create(
        model="gpt-4",
        messages=[
            {"role": "user", "content": "Read the file at /tmp/data.txt"},
            message,
            {
                "role": "function",
                "name": function_name,
                "content": str(result)
            }
        ]
    )
    
    print(final_response["choices"][0]["message"]["content"])
```

## Available Tool Domains

| Domain | Count | Description |
|--------|-------|-------------|
| Filesystem | 9 | File and directory operations |
| Networking | 8 | HTTP, DNS, connectivity |
| Database | 8 | SQL and NoSQL operations |
| Git | 9 | Version control operations |
| System | 12 | Process and environment management |
| Agent Comm | 10 | Inter-agent communication |
| MCP | 9 | MCP server management |
| Logical | 16 | Boolean logic and conditionals |
| Data | 15 | Data parsing and transformation |
| Web | 10 | Web scraping and parsing |

**Total: 106 tools**

## Running Examples

```bash
# Basic usage example
python examples/basic_usage.py

# OpenAI integration example
python examples/openai_integration.py
```

## Running Tests

```bash
pytest
```

## Next Steps

- Read [TOOLS.md](TOOLS.md) for complete tool reference
- Check [README.md](README.md) for detailed documentation
- Explore [examples/](examples/) for more usage patterns

## Getting Help

- Check docstrings: `help(openai_tools.filesystem.read_file)`
- View schemas: `print(json.dumps(generate_schema(read_file), indent=2))`
- See all tools: `print(get_all_tools().keys())`
