# Complete Tool Reference

This document provides a comprehensive reference of all 106 tools available in the OpenAI-compatible tools library.

## Table of Contents

1. [Filesystem Operations](#filesystem-operations) (9 tools)
2. [Networking Tools](#networking-tools) (8 tools)
3. [Database Operations](#database-operations) (8 tools)
4. [Git Operations](#git-operations) (9 tools)
5. [System Operations](#system-operations) (12 tools)
6. [Agent Communication](#agent-communication) (10 tools)
7. [MCP Server Operations](#mcp-server-operations) (9 tools)
8. [Logical Operations](#logical-operations) (16 tools)
9. [Data Processing](#data-processing) (15 tools)
10. [Web Scraping](#web-scraping) (10 tools)

---

## Filesystem Operations

Safe and validated filesystem operations.

| Function | Description | Key Parameters |
|----------|-------------|----------------|
| `read_file` | Read file contents | `file_path`, `encoding` |
| `write_file` | Write content to file | `file_path`, `content`, `append` |
| `list_directory` | List directory contents | `directory_path`, `recursive`, `pattern` |
| `search_files` | Search for files by pattern | `directory_path`, `pattern`, `recursive` |
| `copy_file` | Copy file or directory | `source_path`, `destination_path`, `overwrite` |
| `move_file` | Move/rename file or directory | `source_path`, `destination_path`, `overwrite` |
| `delete_file` | Delete file or directory | `file_path`, `recursive` |
| `get_file_info` | Get file metadata | `file_path` |
| `create_directory` | Create new directory | `directory_path`, `parents` |

### Example Usage
```python
from openai_tools.filesystem import read_file, write_file, list_directory

# Write a file
write_file("/path/to/file.txt", "Hello, World!")

# Read the file
content = read_file("/path/to/file.txt")

# List directory with pattern
files = list_directory("/path/to/dir", pattern="*.py", recursive=True)
```

---

## Networking Tools

Network operations including HTTP, DNS, and connectivity checks.

| Function | Description | Key Parameters |
|----------|-------------|----------------|
| `http_request` | Make HTTP request | `url`, `method`, `headers`, `data` |
| `dns_lookup` | Perform DNS lookup | `hostname`, `record_type` |
| `ping_host` | Ping a host | `host`, `count`, `timeout` |
| `check_port` | Check if port is open | `host`, `port`, `timeout` |
| `download_file` | Download file from URL | `url`, `destination_path`, `timeout` |
| `get_public_ip` | Get public IP address | None |
| `resolve_hostname` | Reverse DNS lookup | `ip_address` |
| `get_network_interfaces` | Get network interface info | None |

### Example Usage
```python
from openai_tools.networking import http_request, dns_lookup, check_port

# Make HTTP request
response = http_request("https://api.example.com/data", method="GET")

# DNS lookup
ips = dns_lookup("example.com")

# Check if port is open
status = check_port("example.com", 443)
```

---

## Database Operations

Database operations for SQL and NoSQL databases (requires optional dependencies).

| Function | Description | Key Parameters |
|----------|-------------|----------------|
| `execute_query` | Execute SQL query | `connection_string`, `query`, `parameters` |
| `insert_record` | Insert database record | `connection_string`, `table`, `record` |
| `update_record` | Update database records | `connection_string`, `table`, `updates`, `condition` |
| `delete_record` | Delete database records | `connection_string`, `table`, `condition` |
| `list_tables` | List database tables | `connection_string` |
| `get_table_schema` | Get table structure | `connection_string`, `table` |
| `mongodb_find` | Find MongoDB documents | `connection_string`, `database`, `collection`, `query` |
| `mongodb_insert` | Insert MongoDB document | `connection_string`, `database`, `collection`, `document` |

### Example Usage
```python
from openai_tools.database import execute_query, insert_record

# Execute query
results = execute_query(
    "sqlite:///mydb.db",
    "SELECT * FROM users WHERE age > :age",
    {"age": 25}
)

# Insert record
insert_record(
    "sqlite:///mydb.db",
    "users",
    {"name": "Alice", "age": 30}
)
```

---

## Git Operations

Version control operations using Git.

| Function | Description | Key Parameters |
|----------|-------------|----------------|
| `git_clone` | Clone repository | `repository_url`, `destination_path`, `branch` |
| `git_status` | Get repository status | `repository_path` |
| `git_commit` | Commit changes | `repository_path`, `message`, `author` |
| `git_push` | Push commits | `repository_path`, `remote`, `branch` |
| `git_pull` | Pull changes | `repository_path`, `remote`, `branch` |
| `git_branch` | Manage branches | `repository_path`, `action`, `branch_name` |
| `git_diff` | View differences | `repository_path`, `ref1`, `ref2` |
| `git_log` | View commit history | `repository_path`, `max_count`, `branch` |
| `git_remote` | Manage remotes | `repository_path`, `action` |

### Example Usage
```python
from openai_tools.git_ops import git_status, git_commit, git_push

# Get status
status = git_status("/path/to/repo")

# Commit changes
git_commit("/path/to/repo", "Update documentation")

# Push to remote
git_push("/path/to/repo", "origin", "main")
```

---

## System Operations

System-level operations including process management and environment access.

| Function | Description | Key Parameters |
|----------|-------------|----------------|
| `execute_command` | Execute shell command | `command`, `timeout`, `shell`, `cwd` |
| `get_environment` | Get environment variables | `variable_name` |
| `set_environment` | Set environment variable | `variable_name`, `value` |
| `list_processes` | List running processes | `filter_name` |
| `kill_process` | Terminate process | `pid`, `force` |
| `get_system_info` | Get comprehensive system info | None |
| `get_cpu_info` | Get CPU information | None |
| `get_memory_info` | Get memory information | None |
| `get_disk_info` | Get disk usage info | `path` |
| `read_stdin` | Read from stdin | `timeout` |
| `write_stdout` | Write to stdout | `text` |
| `write_stderr` | Write to stderr | `text` |

### Example Usage
```python
from openai_tools.system import execute_command, list_processes, get_system_info

# Execute command
result = execute_command("ls -la", timeout=10)

# List processes
processes = list_processes(filter_name="python")

# Get system info
info = get_system_info()
```

---

## Agent Communication

Agent-to-agent (A2A) communication and coordination.

| Function | Description | Key Parameters |
|----------|-------------|----------------|
| `send_message` | Send message to agent | `sender_id`, `receiver_id`, `message`, `message_type` |
| `receive_message` | Receive messages | `agent_id`, `message_type`, `mark_read` |
| `broadcast_message` | Broadcast to channel | `sender_id`, `message`, `channel` |
| `register_agent` | Register agent in network | `agent_id`, `agent_name`, `capabilities` |
| `unregister_agent` | Unregister agent | `agent_id` |
| `discover_agents` | Find available agents | `capability` |
| `create_channel` | Create communication channel | `channel_name`, `members` |
| `join_channel` | Join channel | `agent_id`, `channel_name` |
| `leave_channel` | Leave channel | `agent_id`, `channel_name` |
| `get_agent_status` | Get agent status | `agent_id` |

### Example Usage
```python
from openai_tools.agent_comm import register_agent, send_message, receive_message

# Register agent
register_agent("agent1", "Data Processor", ["data_processing", "analysis"])

# Send message
send_message("agent1", "agent2", "Process this data", message_type="request")

# Receive messages
messages = receive_message("agent2")
```

---

## MCP Server Operations

Model Context Protocol (MCP) server management.

| Function | Description | Key Parameters |
|----------|-------------|----------------|
| `start_mcp_server` | Start MCP server | `server_name`, `command`, `port`, `config` |
| `stop_mcp_server` | Stop MCP server | `server_name`, `force` |
| `list_mcp_servers` | List running servers | None |
| `get_mcp_status` | Get server status | `server_name` |
| `configure_mcp_server` | Configure server | `server_name`, `config` |
| `list_mcp_tools` | List available tools | `server_name` |
| `call_mcp_tool` | Call MCP tool | `server_name`, `tool_name`, `arguments` |
| `restart_mcp_server` | Restart server | `server_name` |
| `get_mcp_logs` | Get server logs | `server_name`, `lines` |

### Example Usage
```python
from openai_tools.mcp import start_mcp_server, list_mcp_servers, get_mcp_status

# Start server
start_mcp_server("my_server", "mcp-server --port 8080", port=8080)

# List servers
servers = list_mcp_servers()

# Get status
status = get_mcp_status("my_server")
```

---

## Logical Operations

Boolean logic and conditional operations.

| Function | Description | Key Parameters |
|----------|-------------|----------------|
| `logical_and` | Logical AND | `*values` |
| `logical_or` | Logical OR | `*values` |
| `logical_not` | Logical NOT | `value` |
| `logical_xor` | Logical XOR | `value1`, `value2` |
| `logical_nand` | Logical NAND | `*values` |
| `logical_nor` | Logical NOR | `*values` |
| `evaluate_condition` | Evaluate condition | `left`, `operator`, `right` |
| `compare_values` | Compare two values | `value1`, `value2` |
| `if_then_else` | Conditional return | `condition`, `if_true`, `if_false` |
| `all_true` | Check if all true | `values` |
| `any_true` | Check if any true | `values` |
| `none_true` | Check if none true | `values` |
| `count_true` | Count true values | `values` |
| `is_truthy` | Check if truthy | `value` |
| `is_falsy` | Check if falsy | `value` |
| `evaluate_expression` | Evaluate expression | `expression`, `variables` |

### Example Usage
```python
from openai_tools.logical import logical_and, evaluate_condition, if_then_else

# Boolean operations
result = logical_and(True, True, False)  # False

# Conditional evaluation
is_greater = evaluate_condition(10, ">", 5)  # True

# Conditional return
value = if_then_else(is_greater, "yes", "no")  # "yes"
```

---

## Data Processing

Data parsing, transformation, and conversion.

| Function | Description | Key Parameters |
|----------|-------------|----------------|
| `parse_json` | Parse JSON string | `json_string` |
| `stringify_json` | Convert to JSON string | `data`, `indent` |
| `parse_yaml` | Parse YAML string | `yaml_string` |
| `stringify_yaml` | Convert to YAML string | `data` |
| `parse_csv` | Parse CSV string | `csv_string`, `delimiter`, `has_header` |
| `stringify_csv` | Convert to CSV string | `data`, `delimiter`, `include_header` |
| `convert_format` | Convert between formats | `data_string`, `from_format`, `to_format` |
| `filter_data` | Filter data by condition | `data`, `filter_key`, `filter_value`, `operator` |
| `transform_data` | Transform data structure | `data`, `transformations` |
| `merge_data` | Merge datasets | `*datasets` |
| `group_by` | Group data by key | `data`, `key` |
| `sort_data` | Sort data by key | `data`, `sort_key`, `reverse` |
| `aggregate_data` | Aggregate data | `data`, `group_key`, `aggregate_key`, `operation` |
| `flatten_dict` | Flatten nested dictionary | `data`, `separator` |
| `unflatten_dict` | Unflatten dictionary | `data`, `separator` |

### Example Usage
```python
from openai_tools.data import parse_json, filter_data, group_by

# Parse JSON
data = parse_json('{"name": "Alice", "age": 30}')

# Filter data
dataset = [
    {"name": "Alice", "score": 85},
    {"name": "Bob", "score": 92}
]
high_scores = filter_data(dataset, "score", 80, operator=">")

# Group by
grouped = group_by(dataset, "name")
```

---

## Web Scraping

Web content fetching and HTML parsing.

| Function | Description | Key Parameters |
|----------|-------------|----------------|
| `fetch_webpage` | Fetch webpage content | `url`, `timeout`, `headers` |
| `extract_links` | Extract links from HTML | `html_content`, `base_url` |
| `extract_text` | Extract plain text | `html_content`, `remove_scripts` |
| `extract_metadata` | Extract metadata | `html_content` |
| `parse_html` | Parse with CSS selector | `html_content`, `selector`, `extract` |
| `extract_tables` | Extract HTML tables | `html_content` |
| `extract_images` | Extract images | `html_content`, `base_url` |
| `extract_headings` | Extract headings (h1-h6) | `html_content` |
| `extract_forms` | Extract form information | `html_content` |
| `get_page_structure` | Get page structure | `html_content` |

### Example Usage
```python
from openai_tools.web import fetch_webpage, extract_links, extract_text

# Fetch webpage
page = fetch_webpage("https://example.com")

# Extract links
links = extract_links(page["content"])

# Extract plain text
text = extract_text(page["content"])
```

---

## OpenAI Function Schema Format

All tools automatically generate OpenAI-compatible function schemas:

```json
{
  "name": "function_name",
  "description": "Function description from docstring",
  "parameters": {
    "type": "object",
    "properties": {
      "param_name": {
        "type": "string|integer|number|boolean|array|object",
        "description": "Parameter description",
        "default": "optional_default_value"
      }
    },
    "required": ["required_param1", "required_param2"]
  }
}
```

## Usage Tips

1. **Filter by domain**: Only send relevant tools to OpenAI to reduce token usage
2. **Error handling**: All tools raise appropriate exceptions; handle them in your code
3. **Security**: Validate inputs and be cautious with command execution and file operations
4. **Optional dependencies**: Database and some other operations require `pip install openai-tools[database]`
5. **Cross-platform**: Tools work on Windows, Linux, and macOS where applicable

## See Also

- [README.md](README.md) - Main documentation
- [examples/basic_usage.py](examples/basic_usage.py) - Basic usage examples
- [examples/openai_integration.py](examples/openai_integration.py) - OpenAI integration examples
