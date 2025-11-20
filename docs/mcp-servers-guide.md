# MCP Servers Guide

A comprehensive guide to Model Context Protocol (MCP) servers, their configurations, and installation instructions for AI agents.

## Table of Contents

- [What is MCP?](#what-is-mcp)
- [Common MCP Servers](#common-mcp-servers)
- [Installation Methods](#installation-methods)
- [Configuration Examples](#configuration-examples)

## What is MCP?

The Model Context Protocol (MCP) is an open protocol that standardizes how applications provide context to Language Learning Models (LLMs). MCP servers expose tools, resources, and prompts that AI agents can use to interact with various systems.

## Common MCP Servers

### Official Anthropic MCP Servers

#### 1. **Filesystem MCP Server**
- **Purpose**: Read and write files on the local filesystem
- **Repository**: https://github.com/modelcontextprotocol/servers
- **Protocol**: stdio
- **Installation**:
  ```bash
  npm install -g @modelcontextprotocol/server-filesystem
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "filesystem": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/allowed/directory"]
      }
    }
  }
  ```

#### 2. **GitHub MCP Server**
- **Purpose**: Interact with GitHub repositories, issues, PRs
- **Repository**: https://github.com/modelcontextprotocol/servers
- **Protocol**: stdio
- **Installation**:
  ```bash
  npm install -g @modelcontextprotocol/server-github
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "github": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-github"],
        "env": {
          "GITHUB_TOKEN": "your_github_personal_access_token"
        }
      }
    }
  }
  ```

#### 3. **PostgreSQL MCP Server**
- **Purpose**: Query and manage PostgreSQL databases
- **Repository**: https://github.com/modelcontextprotocol/servers
- **Protocol**: stdio
- **Installation**:
  ```bash
  npm install -g @modelcontextprotocol/server-postgres
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "postgres": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-postgres", "postgresql://user:password@localhost/dbname"]
      }
    }
  }
  ```

#### 4. **SQLite MCP Server**
- **Purpose**: Query and manage SQLite databases
- **Repository**: https://github.com/modelcontextprotocol/servers
- **Protocol**: stdio
- **Installation**:
  ```bash
  npm install -g @modelcontextprotocol/server-sqlite
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "sqlite": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-sqlite", "/path/to/database.db"]
      }
    }
  }
  ```

#### 5. **Slack MCP Server**
- **Purpose**: Read and send messages in Slack
- **Repository**: https://github.com/modelcontextprotocol/servers
- **Protocol**: stdio
- **Installation**:
  ```bash
  npm install -g @modelcontextprotocol/server-slack
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "slack": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-slack"],
        "env": {
          "SLACK_BOT_TOKEN": "xoxb-your-bot-token",
          "SLACK_TEAM_ID": "T1234567890"
        }
      }
    }
  }
  ```

#### 6. **Google Drive MCP Server**
- **Purpose**: Access and manage Google Drive files
- **Repository**: https://github.com/modelcontextprotocol/servers
- **Protocol**: stdio
- **Installation**:
  ```bash
  npm install -g @modelcontextprotocol/server-gdrive
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "gdrive": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-gdrive"],
        "env": {
          "GOOGLE_APPLICATION_CREDENTIALS": "/path/to/credentials.json"
        }
      }
    }
  }
  ```

#### 7. **Puppeteer MCP Server**
- **Purpose**: Web scraping and browser automation
- **Repository**: https://github.com/modelcontextprotocol/servers
- **Protocol**: stdio
- **Installation**:
  ```bash
  npm install -g @modelcontextprotocol/server-puppeteer
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "puppeteer": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-puppeteer"]
      }
    }
  }
  ```

#### 8. **Brave Search MCP Server**
- **Purpose**: Web search using Brave Search API
- **Repository**: https://github.com/modelcontextprotocol/servers
- **Protocol**: stdio
- **Installation**:
  ```bash
  npm install -g @modelcontextprotocol/server-brave-search
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "brave-search": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-brave-search"],
        "env": {
          "BRAVE_API_KEY": "your_brave_api_key"
        }
      }
    }
  }
  ```

#### 9. **Google Maps MCP Server**
- **Purpose**: Access Google Maps geocoding and places data
- **Repository**: https://github.com/modelcontextprotocol/servers
- **Protocol**: stdio
- **Installation**:
  ```bash
  npm install -g @modelcontextprotocol/server-google-maps
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "google-maps": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-google-maps"],
        "env": {
          "GOOGLE_MAPS_API_KEY": "your_google_maps_api_key"
        }
      }
    }
  }
  ```

#### 10. **Memory MCP Server**
- **Purpose**: Persistent memory storage for AI agents
- **Repository**: https://github.com/modelcontextprotocol/servers
- **Protocol**: stdio
- **Installation**:
  ```bash
  npm install -g @modelcontextprotocol/server-memory
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "memory": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-memory"]
      }
    }
  }
  ```

### Community MCP Servers

#### 11. **Docker MCP Server**
- **Purpose**: Manage Docker containers and images
- **Repository**: https://github.com/ckreiling/mcp-server-docker
- **Protocol**: stdio
- **Installation**:
  ```bash
  npm install -g mcp-server-docker
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "docker": {
        "command": "npx",
        "args": ["-y", "mcp-server-docker"]
      }
    }
  }
  ```

#### 12. **Kubernetes MCP Server**
- **Purpose**: Manage Kubernetes clusters and resources
- **Repository**: https://github.com/strowk/mcp-k8s-go
- **Protocol**: stdio
- **Installation**:
  ```bash
  go install github.com/strowk/mcp-k8s-go@latest
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "kubernetes": {
        "command": "mcp-k8s-go",
        "args": []
      }
    }
  }
  ```

#### 13. **AWS MCP Server**
- **Purpose**: Interact with AWS services
- **Repository**: https://github.com/ivo-toby/mcp-server-aws
- **Protocol**: stdio
- **Installation**:
  ```bash
  npm install -g @ivo-toby/mcp-server-aws
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "aws": {
        "command": "npx",
        "args": ["-y", "@ivo-toby/mcp-server-aws"],
        "env": {
          "AWS_ACCESS_KEY_ID": "your_access_key",
          "AWS_SECRET_ACCESS_KEY": "your_secret_key",
          "AWS_REGION": "us-east-1"
        }
      }
    }
  }
  ```

#### 14. **Git MCP Server**
- **Purpose**: Git repository operations
- **Repository**: https://github.com/modelcontextprotocol/servers
- **Protocol**: stdio
- **Installation**:
  ```bash
  npm install -g @modelcontextprotocol/server-git
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "git": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-git", "/path/to/repository"]
      }
    }
  }
  ```

#### 15. **Prometheus MCP Server**
- **Purpose**: Query Prometheus metrics
- **Repository**: https://github.com/tumf/mcp-server-prometheus
- **Protocol**: stdio
- **Installation**:
  ```bash
  npm install -g @tumf/mcp-server-prometheus
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "prometheus": {
        "command": "npx",
        "args": ["-y", "@tumf/mcp-server-prometheus"],
        "env": {
          "PROMETHEUS_URL": "http://localhost:9090"
        }
      }
    }
  }
  ```

#### 16. **Sentry MCP Server**
- **Purpose**: Access Sentry error tracking data
- **Repository**: https://github.com/modelcontextprotocol/servers
- **Protocol**: stdio
- **Installation**:
  ```bash
  npm install -g @modelcontextprotocol/server-sentry
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "sentry": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-sentry"],
        "env": {
          "SENTRY_AUTH_TOKEN": "your_sentry_token",
          "SENTRY_ORG": "your_org"
        }
      }
    }
  }
  ```

#### 17. **Fetch MCP Server**
- **Purpose**: Make HTTP requests and fetch web content
- **Repository**: https://github.com/modelcontextprotocol/servers
- **Protocol**: stdio
- **Installation**:
  ```bash
  npm install -g @modelcontextprotocol/server-fetch
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "fetch": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-fetch"]
      }
    }
  }
  ```

#### 18. **Sequential Thinking MCP Server**
- **Purpose**: Advanced reasoning and chain-of-thought processing
- **Repository**: https://github.com/modelcontextprotocol/servers
- **Protocol**: stdio
- **Installation**:
  ```bash
  npm install -g @modelcontextprotocol/server-sequential-thinking
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "sequential-thinking": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
      }
    }
  }
  ```

#### 19. **EverArt MCP Server**
- **Purpose**: AI image generation
- **Repository**: https://github.com/modelcontextprotocol/servers
- **Protocol**: stdio
- **Installation**:
  ```bash
  npm install -g @modelcontextprotocol/server-everart
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "everart": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-everart"],
        "env": {
          "EVERART_API_KEY": "your_everart_api_key"
        }
      }
    }
  }
  ```

#### 20. **MySQL MCP Server**
- **Purpose**: Query and manage MySQL databases
- **Repository**: https://github.com/benborla/mcp-server-mysql
- **Protocol**: stdio
- **Installation**:
  ```bash
  npm install -g @benborla/mcp-server-mysql
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "mysql": {
        "command": "npx",
        "args": ["-y", "@benborla/mcp-server-mysql"],
        "env": {
          "MYSQL_HOST": "localhost",
          "MYSQL_USER": "root",
          "MYSQL_PASSWORD": "password",
          "MYSQL_DATABASE": "mydb"
        }
      }
    }
  }
  ```

#### 21. **Mongo MCP Server**
- **Purpose**: Query and manage MongoDB databases
- **Repository**: https://github.com/kiliczsh/mcp-mongo-server
- **Protocol**: stdio
- **Installation**:
  ```bash
  npm install -g mcp-mongo-server
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "mongo": {
        "command": "npx",
        "args": ["-y", "mcp-mongo-server"],
        "env": {
          "MONGODB_URI": "mongodb://localhost:27017/mydb"
        }
      }
    }
  }
  ```

#### 22. **Snowflake MCP Server**
- **Purpose**: Query Snowflake data warehouse
- **Repository**: https://github.com/isaacwasserman/mcp-server-snowflake
- **Protocol**: stdio
- **Installation**:
  ```bash
  npm install -g mcp-server-snowflake
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "snowflake": {
        "command": "npx",
        "args": ["-y", "mcp-server-snowflake"],
        "env": {
          "SNOWFLAKE_ACCOUNT": "your_account",
          "SNOWFLAKE_USERNAME": "your_username",
          "SNOWFLAKE_PASSWORD": "your_password",
          "SNOWFLAKE_WAREHOUSE": "your_warehouse",
          "SNOWFLAKE_DATABASE": "your_database",
          "SNOWFLAKE_SCHEMA": "your_schema"
        }
      }
    }
  }
  ```

#### 23. **Playwright MCP Server**
- **Purpose**: Browser automation and testing
- **Repository**: https://github.com/executeautomation/mcp-playwright
- **Protocol**: stdio
- **Installation**:
  ```bash
  npm install -g @executeautomation/mcp-playwright
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "playwright": {
        "command": "npx",
        "args": ["-y", "@executeautomation/mcp-playwright"]
      }
    }
  }
  ```

#### 24. **Cloudflare MCP Server**
- **Purpose**: Manage Cloudflare resources
- **Repository**: https://github.com/cloudflare/mcp-server-cloudflare
- **Protocol**: stdio
- **Installation**:
  ```bash
  npm install -g @cloudflare/mcp-server-cloudflare
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "cloudflare": {
        "command": "npx",
        "args": ["-y", "@cloudflare/mcp-server-cloudflare"],
        "env": {
          "CLOUDFLARE_API_TOKEN": "your_api_token"
        }
      }
    }
  }
  ```

#### 25. **Linear MCP Server**
- **Purpose**: Interact with Linear issue tracking
- **Repository**: https://github.com/jerhadf/linear-mcp-server
- **Protocol**: stdio
- **Installation**:
  ```bash
  npm install -g linear-mcp-server
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "linear": {
        "command": "npx",
        "args": ["-y", "linear-mcp-server"],
        "env": {
          "LINEAR_API_KEY": "your_linear_api_key"
        }
      }
    }
  }
  ```

#### 26. **Jira MCP Server**
- **Purpose**: Manage Jira issues and projects
- **Repository**: https://github.com/modelcontextprotocol/servers
- **Protocol**: stdio
- **Installation**:
  ```bash
  npm install -g @modelcontextprotocol/server-jira
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "jira": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-jira"],
        "env": {
          "JIRA_URL": "https://your-domain.atlassian.net",
          "JIRA_EMAIL": "your_email@example.com",
          "JIRA_API_TOKEN": "your_jira_api_token"
        }
      }
    }
  }
  ```

#### 27. **Notion MCP Server**
- **Purpose**: Access and manage Notion databases
- **Repository**: https://github.com/modelcontextprotocol/servers
- **Protocol**: stdio
- **Installation**:
  ```bash
  npm install -g @modelcontextprotocol/server-notion
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "notion": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-notion"],
        "env": {
          "NOTION_API_KEY": "your_notion_integration_token"
        }
      }
    }
  }
  ```

#### 28. **Obsidian MCP Server**
- **Purpose**: Access Obsidian vault notes
- **Repository**: https://github.com/loonghao/obsidian-mcp
- **Protocol**: stdio
- **Installation**:
  ```bash
  npm install -g obsidian-mcp
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "obsidian": {
        "command": "npx",
        "args": ["-y", "obsidian-mcp", "/path/to/vault"]
      }
    }
  }
  ```

#### 29. **Raycast MCP Server**
- **Purpose**: Access Raycast extensions and commands
- **Repository**: https://github.com/pomdtr/mcp-server-raycast
- **Protocol**: stdio
- **Installation**:
  ```bash
  npm install -g @pomdtr/mcp-server-raycast
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "raycast": {
        "command": "npx",
        "args": ["-y", "@pomdtr/mcp-server-raycast"]
      }
    }
  }
  ```

#### 30. **Filesystem with Git MCP Server**
- **Purpose**: Advanced filesystem operations with Git integration
- **Repository**: https://github.com/modelcontextprotocol/servers
- **Protocol**: stdio
- **Installation**:
  ```bash
  npm install -g @modelcontextprotocol/server-filesystem-git
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "filesystem-git": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-filesystem-git", "/path/to/directory"]
      }
    }
  }
  ```

### HTTP/SSE-based MCP Servers

#### 31. **MCP Gateway**
- **Purpose**: HTTP/SSE gateway for MCP servers
- **Repository**: https://github.com/modelcontextprotocol/gateway
- **Protocol**: HTTP/SSE
- **Address**: `http://localhost:3000` (configurable)
- **Installation via Docker**:
  ```bash
  docker run -p 3000:3000 modelcontextprotocol/gateway
  ```
- **Installation via npm**:
  ```bash
  npm install -g @modelcontextprotocol/gateway
  mcp-gateway
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "gateway": {
        "url": "http://localhost:3000/sse",
        "transport": "sse"
      }
    }
  }
  ```

#### 32. **HTTP Server Wrapper**
- **Purpose**: Wrap stdio MCP servers with HTTP/SSE
- **Installation via Docker**:
  ```dockerfile
  FROM node:20-alpine
  RUN npm install -g @modelcontextprotocol/server-filesystem
  EXPOSE 3000
  CMD ["npx", "@modelcontextprotocol/server-filesystem", "/data"]
  ```

### Docker-based MCP Server Deployments

#### 33. **Dockerized PostgreSQL MCP**
- **Docker Compose**:
  ```yaml
  version: '3.8'
  services:
    postgres-mcp:
      image: node:20-alpine
      command: npx -y @modelcontextprotocol/server-postgres postgresql://user:password@postgres:5432/dbname
      environment:
        - NODE_ENV=production
      depends_on:
        - postgres
    postgres:
      image: postgres:16-alpine
      environment:
        POSTGRES_USER: user
        POSTGRES_PASSWORD: password
        POSTGRES_DB: dbname
      volumes:
        - postgres_data:/var/lib/postgresql/data
  volumes:
    postgres_data:
  ```

#### 34. **Dockerized Git MCP**
- **Docker Compose**:
  ```yaml
  version: '3.8'
  services:
    git-mcp:
      image: node:20-alpine
      command: npx -y @modelcontextprotocol/server-git /repos
      volumes:
        - ./repos:/repos:ro
      environment:
        - NODE_ENV=production
  ```

### Python-based MCP Servers

#### 35. **Python Filesystem MCP Server**
- **Repository**: https://github.com/modelcontextprotocol/python-sdk
- **Installation**:
  ```bash
  pip install mcp
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "python-fs": {
        "command": "python",
        "args": ["-m", "mcp.server.filesystem", "/path/to/directory"]
      }
    }
  }
  ```

#### 36. **Time MCP Server (Python)**
- **Purpose**: Get current time and timezone information
- **Repository**: https://github.com/modelcontextprotocol/python-sdk
- **Installation**:
  ```bash
  pip install mcp[time]
  ```
- **Configuration**:
  ```json
  {
    "mcpServers": {
      "time": {
        "command": "python",
        "args": ["-m", "mcp.server.time"]
      }
    }
  }
  ```

## Installation Methods

### Method 1: NPM Global Installation

```bash
npm install -g @modelcontextprotocol/server-name
```

This installs the MCP server globally, making it available via `npx` command.

### Method 2: Local Project Installation

```bash
npm install --save-dev @modelcontextprotocol/server-name
```

Use in your project's `package.json` scripts.

### Method 3: NPX Direct Execution

```bash
npx -y @modelcontextprotocol/server-name [args]
```

Downloads and runs the server without installation.

### Method 4: Docker Deployment

```bash
docker run -d --name mcp-server \
  -e ENV_VAR=value \
  -v /local/path:/container/path \
  mcp-server-image
```

### Method 5: Docker Compose

```yaml
version: '3.8'
services:
  mcp-server:
    image: mcp-server-image
    environment:
      - ENV_VAR=value
    volumes:
      - /local/path:/container/path
```

### Method 6: Python pip Installation

```bash
pip install mcp
pip install mcp[server-type]
```

### Method 7: Go Installation

```bash
go install github.com/org/mcp-server@latest
```

## Configuration Examples

### Claude Desktop Configuration

Location: `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS) or `%APPDATA%\Claude\claude_desktop_config.json` (Windows)

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/username/Documents"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "ghp_your_token_here"
      }
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres", "postgresql://localhost/mydb"]
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
```

### Cursor IDE Configuration

Location: Cursor settings

```json
{
  "mcp.servers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "${workspaceFolder}"]
    },
    "git": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-git", "${workspaceFolder}"]
    }
  }
}
```

### Custom Agent Configuration

```json
{
  "agent": {
    "name": "my-agent",
    "mcp_servers": [
      {
        "name": "filesystem",
        "type": "stdio",
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-filesystem", "/data"]
      },
      {
        "name": "gateway",
        "type": "sse",
        "url": "http://localhost:3000/sse"
      },
      {
        "name": "docker-mcp",
        "type": "docker",
        "image": "mcp-server:latest",
        "ports": ["3000:3000"],
        "env": {
          "API_KEY": "secret"
        }
      }
    ]
  }
}
```

### Multi-Server Configuration for AI Agents

```json
{
  "mcpServers": {
    "local-filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/workspace"],
      "description": "Local file access"
    },
    "github-integration": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      },
      "description": "GitHub API access"
    },
    "database-postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres", "${DATABASE_URL}"],
      "description": "Database operations"
    },
    "web-fetch": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-fetch"],
      "description": "HTTP requests"
    },
    "memory-storage": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"],
      "description": "Persistent memory"
    },
    "docker-control": {
      "command": "npx",
      "args": ["-y", "mcp-server-docker"],
      "description": "Docker management"
    },
    "search-brave": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "${BRAVE_API_KEY}"
      },
      "description": "Web search"
    }
  }
}
```

## Environment Variable Management

### Using .env Files

```bash
# .env
GITHUB_TOKEN=ghp_xxxxxxxxxxxxx
BRAVE_API_KEY=BSAxxxxxxxxxxxxx
DATABASE_URL=postgresql://user:pass@localhost/db
AWS_ACCESS_KEY_ID=AKIAxxxxxxxxxxxxx
AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxx
SLACK_BOT_TOKEN=xoxb-xxxxxxxxxxxxx
```

### Loading Environment Variables

```bash
# Load .env and start agent
export $(cat .env | xargs) && your-agent-command
```

## Security Best Practices

1. **Never commit API keys** to version control
2. **Use environment variables** for sensitive data
3. **Limit filesystem access** to specific directories
4. **Use read-only mounts** in Docker when possible
5. **Rotate credentials** regularly
6. **Use secrets management** systems (Vault, AWS Secrets Manager, etc.)
7. **Enable logging** and monitoring for MCP server access
8. **Implement rate limiting** for external API calls
9. **Use network policies** to restrict container communication
10. **Regular security audits** of MCP server configurations

## Troubleshooting

### Common Issues

1. **Server not starting**: Check that dependencies are installed
2. **Permission errors**: Verify file system permissions
3. **Environment variables not loaded**: Check variable names and .env file
4. **Network connectivity**: Verify firewall rules and network access
5. **Docker issues**: Check Docker daemon status and container logs

### Debugging Commands

```bash
# Check MCP server logs
npx -y @modelcontextprotocol/server-name --verbose

# Test server connectivity
curl -X POST http://localhost:3000/mcp -H "Content-Type: application/json" -d '{"method":"ping"}'

# Docker logs
docker logs mcp-server-container

# List running MCP processes
ps aux | grep mcp
```

## Additional Resources

- [MCP Specification](https://modelcontextprotocol.io/introduction)
- [Official MCP Servers Repository](https://github.com/modelcontextprotocol/servers)
- [MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk)
- [MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk)
- [Claude Desktop Documentation](https://docs.anthropic.com/claude/docs/claude-desktop)
- [MCP Community Servers List](https://github.com/punkpeye/awesome-mcp-servers)

## Contributing

To add a new MCP server to this guide:

1. Verify the server is functional and maintained
2. Include complete installation instructions
3. Provide working configuration examples
4. Document all required environment variables
5. Test the configuration before submitting
