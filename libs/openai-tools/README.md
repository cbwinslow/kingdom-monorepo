# OpenAI-Compatible Tools Library

A comprehensive, portable, and robust collection of OpenAI-compatible function tools for AI agents. This library provides a wide range of tools across multiple domains, all with proper docstrings, type hints, and OpenAI function schema generation.

## Features

- 🔧 **Comprehensive Coverage**: Tools spanning 10+ domains including filesystem, networking, databases, Git, system operations, and more
- 🤖 **OpenAI Compatible**: All tools can be automatically converted to OpenAI function calling format
- 📝 **Well-Documented**: Complete docstrings and type hints for all functions
- 🛡️ **Robust & Safe**: Input validation, error handling, and security considerations
- 🔌 **Portable**: Minimal dependencies, works across platforms
- 🧪 **Tested**: Comprehensive test coverage

## Installation

### From Source
```bash
cd libs/openai-tools
pip install -e .
```

### With Optional Dependencies
```bash
# For database support
pip install -e ".[database]"

# For development
pip install -e ".[dev]"
```

## Quick Start

```python
from openai_tools import get_all_tools, generate_openai_schemas

# Get all available tools
tools = get_all_tools()

# Generate OpenAI function schemas
schemas = generate_openai_schemas()

# Use with OpenAI API
import openai
response = openai.ChatCompletion.create(
    model="gpt-4",
    messages=[{"role": "user", "content": "List files in /tmp"}],
    functions=schemas
)
```

## Available Tool Domains

### 1. Filesystem Operations (`openai_tools.filesystem`)
- `read_file`: Read file contents
- `write_file`: Write content to file
- `list_directory`: List directory contents
- `search_files`: Search for files by pattern
- `copy_file`: Copy files or directories
- `move_file`: Move/rename files or directories
- `delete_file`: Delete files or directories
- `get_file_info`: Get file metadata

### 2. Networking Tools (`openai_tools.networking`)
- `http_request`: Make HTTP requests (GET, POST, PUT, DELETE)
- `dns_lookup`: Perform DNS lookups
- `ping_host`: Ping a host
- `check_port`: Check if a port is open
- `download_file`: Download files from URLs
- `get_public_ip`: Get public IP address

### 3. Database Operations (`openai_tools.database`)
- `execute_query`: Execute SQL queries
- `insert_record`: Insert database records
- `update_record`: Update database records
- `delete_record`: Delete database records
- `list_tables`: List database tables
- `get_table_schema`: Get table structure

### 4. Git Operations (`openai_tools.git_ops`)
- `git_clone`: Clone a repository
- `git_status`: Get repository status
- `git_commit`: Commit changes
- `git_push`: Push changes
- `git_pull`: Pull changes
- `git_branch`: Manage branches
- `git_diff`: View differences
- `git_log`: View commit history

### 5. System Operations (`openai_tools.system`)
- `execute_command`: Execute shell commands
- `get_environment`: Get environment variables
- `list_processes`: List running processes
- `kill_process`: Terminate processes
- `get_system_info`: Get system information
- `read_stdin`: Read from standard input
- `write_stdout`: Write to standard output

### 6. Agent Communication (`openai_tools.agent_comm`)
- `send_message`: Send messages to other agents
- `receive_message`: Receive messages from other agents
- `broadcast_message`: Broadcast to multiple agents
- `register_agent`: Register agent in network
- `discover_agents`: Discover available agents
- `create_channel`: Create communication channel

### 7. MCP Server Operations (`openai_tools.mcp`)
- `start_mcp_server`: Start MCP server
- `stop_mcp_server`: Stop MCP server
- `list_mcp_tools`: List available MCP tools
- `call_mcp_tool`: Call an MCP tool
- `get_mcp_status`: Get MCP server status
- `configure_mcp_server`: Configure MCP server

### 8. Logical Operations (`openai_tools.logical`)
- `logical_and`: Perform logical AND
- `logical_or`: Perform logical OR
- `logical_not`: Perform logical NOT
- `logical_xor`: Perform logical XOR
- `evaluate_condition`: Evaluate conditional expressions
- `compare_values`: Compare two values

### 9. Data Processing (`openai_tools.data`)
- `parse_json`: Parse JSON data
- `parse_yaml`: Parse YAML data
- `parse_csv`: Parse CSV data
- `convert_format`: Convert between data formats
- `filter_data`: Filter data by criteria
- `transform_data`: Transform data structure
- `merge_data`: Merge multiple data sources

### 10. Web Scraping (`openai_tools.web`)
- `fetch_webpage`: Fetch webpage content
- `extract_links`: Extract links from HTML
- `extract_text`: Extract text from HTML
- `extract_metadata`: Extract metadata from webpage
- `parse_html`: Parse HTML with selectors
- `take_screenshot`: Take webpage screenshot (requires browser)

## Usage Examples

### Filesystem Operations
```python
from openai_tools.filesystem import read_file, write_file, list_directory

# Read a file
content = read_file("/path/to/file.txt")

# Write to a file
write_file("/path/to/output.txt", "Hello, World!")

# List directory contents
files = list_directory("/path/to/dir", recursive=True)
```

### Networking
```python
from openai_tools.networking import http_request, dns_lookup

# Make HTTP request
response = http_request("https://api.example.com/data", method="GET")

# DNS lookup
ip_addresses = dns_lookup("example.com")
```

### Git Operations
```python
from openai_tools.git_ops import git_status, git_commit, git_push

# Get repository status
status = git_status("/path/to/repo")

# Commit changes
git_commit("/path/to/repo", "Update documentation")

# Push changes
git_push("/path/to/repo", "main")
```

### Using with OpenAI API

```python
import openai
from openai_tools import get_all_tools, generate_openai_schemas, execute_tool

# Get schemas for OpenAI
schemas = generate_openai_schemas()

# Create chat completion with function calling
response = openai.ChatCompletion.create(
    model="gpt-4",
    messages=[
        {"role": "user", "content": "What files are in /tmp?"}
    ],
    functions=schemas,
    function_call="auto"
)

# Execute the function if called
message = response["choices"][0]["message"]
if message.get("function_call"):
    function_name = message["function_call"]["name"]
    arguments = json.loads(message["function_call"]["arguments"])
    result = execute_tool(function_name, arguments)
    print(result)
```

## OpenAI Schema Generation

All tools automatically generate OpenAI-compatible schemas:

```python
from openai_tools.filesystem import read_file
from openai_tools.schema_generator import generate_schema

# Generate schema for a single tool
schema = generate_schema(read_file)
print(json.dumps(schema, indent=2))
```

Output:
```json
{
  "name": "read_file",
  "description": "Read the contents of a file from the filesystem.",
  "parameters": {
    "type": "object",
    "properties": {
      "file_path": {
        "type": "string",
        "description": "The path to the file to read"
      },
      "encoding": {
        "type": "string",
        "description": "The file encoding (default: utf-8)",
        "default": "utf-8"
      }
    },
    "required": ["file_path"]
  }
}
```

## Security Considerations

- All filesystem operations validate paths and prevent directory traversal
- Command execution tools have safeguards against injection
- Network tools respect timeouts and size limits
- Database operations use parameterized queries
- All tools include proper error handling

## Development

### Running Tests
```bash
pytest
```

### Code Formatting
```bash
black openai_tools
ruff check openai_tools
```

### Type Checking
```bash
mypy openai_tools
```

## Contributing

Contributions are welcome! Please ensure:
- All new tools have complete docstrings
- Type hints are provided for all parameters and returns
- Tests are included for new functionality
- Code follows the existing style (Black formatting)

## License

MIT License - see LICENSE file for details
