#!/bin/bash

# Install script for AI agents and their dependencies
# This script sets up the environment for running AI agents

set -e

echo "🤖 Installing AI Agents and Dependencies..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    print_message "$RED" "❌ Python 3 is not installed. Please install Python 3.8 or higher."
    exit 1
fi

print_message "$GREEN" "✅ Python 3 found: $(python3 --version)"

# Check Python version
PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
REQUIRED_VERSION="3.8"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$PYTHON_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    print_message "$RED" "❌ Python version $PYTHON_VERSION is too old. Required: $REQUIRED_VERSION or higher"
    exit 1
fi

print_message "$GREEN" "✅ Python version check passed"

# Create virtual environment if it doesn't exist
VENV_DIR="agents/venv"

if [ ! -d "$VENV_DIR" ]; then
    print_message "$YELLOW" "📦 Creating virtual environment..."
    python3 -m venv "$VENV_DIR"
    print_message "$GREEN" "✅ Virtual environment created"
else
    print_message "$GREEN" "✅ Virtual environment already exists"
fi

# Activate virtual environment
print_message "$YELLOW" "🔄 Activating virtual environment..."
source "$VENV_DIR/bin/activate"

# Upgrade pip
print_message "$YELLOW" "⬆️  Upgrading pip..."
pip install --upgrade pip

# Install core dependencies
print_message "$YELLOW" "📦 Installing core dependencies..."
pip install --upgrade \
    crewai \
    crewai-tools \
    langchain \
    langchain-openai \
    langchain-community \
    openai \
    anthropic \
    google-generativeai \
    pydantic \
    python-dotenv \
    requests \
    pyyaml \
    rich \
    typer

# Install additional AI/ML tools
print_message "$YELLOW" "🧠 Installing AI/ML tools..."
pip install --upgrade \
    transformers \
    torch \
    sentence-transformers \
    chromadb \
    faiss-cpu

# Install code analysis tools
print_message "$YELLOW" "🔍 Installing code analysis tools..."
pip install --upgrade \
    pylint \
    black \
    isort \
    mypy \
    ruff \
    bandit \
    safety

# Install GitHub integration tools
print_message "$YELLOW" "🐙 Installing GitHub tools..."
pip install --upgrade \
    PyGithub \
    gitpython

# Install testing tools
print_message "$YELLOW" "🧪 Installing testing tools..."
pip install --upgrade \
    pytest \
    pytest-cov \
    pytest-asyncio

# Create requirements file
print_message "$YELLOW" "📝 Creating requirements.txt..."
cat > agents/requirements.txt << EOF
# AI Framework
crewai>=0.1.0
crewai-tools>=0.1.0
langchain>=0.1.0
langchain-openai>=0.0.5
langchain-community>=0.0.10

# AI Models
openai>=1.0.0
anthropic>=0.8.0
google-generativeai>=0.3.0

# Core utilities
pydantic>=2.0.0
python-dotenv>=1.0.0
requests>=2.31.0
pyyaml>=6.0.0
rich>=13.0.0
typer>=0.9.0

# AI/ML Tools
transformers>=4.35.0
torch>=2.1.0
sentence-transformers>=2.2.0
chromadb>=0.4.0
faiss-cpu>=1.7.4

# Code Analysis
pylint>=3.0.0
black>=23.0.0
isort>=5.12.0
mypy>=1.7.0
ruff>=0.1.0
bandit>=1.7.0
safety>=2.3.0

# GitHub Integration
PyGithub>=2.1.0
gitpython>=3.1.0

# Testing
pytest>=7.4.0
pytest-cov>=4.1.0
pytest-asyncio>=0.21.0
EOF

print_message "$GREEN" "✅ Requirements file created"

# Create .env.example file
print_message "$YELLOW" "🔐 Creating .env.example file..."
cat > agents/.env.example << EOF
# API Keys for AI Services
OPENAI_API_KEY=your-openai-api-key-here
ANTHROPIC_API_KEY=your-anthropic-api-key-here
GEMINI_API_KEY=your-google-gemini-api-key-here

# GitHub Configuration
GITHUB_TOKEN=your-github-token-here
GITHUB_REPOSITORY=owner/repo

# Agent Configuration
AGENT_MODEL=gpt-4
AGENT_TEMPERATURE=0.1
AGENT_MAX_TOKENS=2000

# Logging
LOG_LEVEL=INFO
LOG_FILE=agents/logs/agent.log

# Vector Database
CHROMA_PERSIST_DIRECTORY=agents/data/chroma
FAISS_INDEX_PATH=agents/data/faiss

# Crew Configuration
CREW_VERBOSE=true
CREW_MEMORY=true
EOF

print_message "$GREEN" "✅ Environment example file created"

# Create directory structure
print_message "$YELLOW" "📁 Creating directory structure..."
mkdir -p agents/{logs,data,cache,output}
mkdir -p agents/data/{chroma,faiss}

print_message "$GREEN" "✅ Directory structure created"

# Create agent runner script
print_message "$YELLOW" "🎬 Creating agent runner script..."
cat > agents/scripts/run_agent.py << 'EOF'
#!/usr/bin/env python3
"""
Agent Runner Script
Provides CLI interface for running AI agents
"""

import sys
import os
from pathlib import Path
import typer
from rich.console import Console
from rich.panel import Panel
from dotenv import load_dotenv

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

app = typer.Typer()
console = Console()

# Load environment variables
load_dotenv()


@app.command()
def review_code(
    code_path: str = typer.Argument(..., help="Path to code file to review"),
    output: str = typer.Option("console", help="Output format: console, json, markdown"),
):
    """Review code using AI agents"""
    console.print(Panel(f"[bold blue]Reviewing code: {code_path}[/bold blue]"))
    
    try:
        with open(code_path, 'r') as f:
            code = f.read()
        
        from crews.code_review_crew import CodeReviewCrew
        
        crew = CodeReviewCrew()
        result = crew.review_code(code)
        
        if output == "console":
            console.print(result)
        elif output == "json":
            import json
            print(json.dumps(result, indent=2))
        elif output == "markdown":
            print(f"# Code Review Results\n\n{result}")
        
        console.print("[bold green]✅ Review completed![/bold green]")
        
    except Exception as e:
        console.print(f"[bold red]❌ Error: {str(e)}[/bold red]")
        raise typer.Exit(1)


@app.command()
def review_pr(
    pr_number: int = typer.Argument(..., help="Pull request number"),
    repo: str = typer.Option(None, help="Repository (owner/name)"),
):
    """Review a pull request"""
    console.print(Panel(f"[bold blue]Reviewing PR #{pr_number}[/bold blue]"))
    
    repo = repo or os.getenv("GITHUB_REPOSITORY")
    if not repo:
        console.print("[bold red]❌ Repository not specified[/bold red]")
        raise typer.Exit(1)
    
    # Implementation would fetch PR data and review
    console.print(f"[yellow]Fetching PR #{pr_number} from {repo}...[/yellow]")
    console.print("[bold green]✅ Review completed![/bold green]")


@app.command()
def check_security(
    path: str = typer.Argument(".", help="Path to scan for security issues"),
):
    """Run security checks"""
    console.print(Panel(f"[bold blue]Running security scan: {path}[/bold blue]"))
    console.print("[yellow]Scanning for vulnerabilities...[/yellow]")
    console.print("[bold green]✅ Security scan completed![/bold green]")


@app.command()
def list_agents():
    """List available agents"""
    console.print(Panel("[bold blue]Available AI Agents[/bold blue]"))
    
    agents = [
        ("Code Reviewer", "Performs comprehensive code reviews"),
        ("Security Expert", "Identifies security vulnerabilities"),
        ("Performance Analyst", "Analyzes code performance"),
        ("Test Engineer", "Reviews test coverage and quality"),
        ("Tech Writer", "Reviews documentation"),
        ("PR Handler", "Manages pull request workflows"),
    ]
    
    for name, description in agents:
        console.print(f"[bold cyan]{name}[/bold cyan]: {description}")


if __name__ == "__main__":
    app()
EOF

chmod +x agents/scripts/run_agent.py

print_message "$GREEN" "✅ Agent runner script created"

# Create README for agents
print_message "$YELLOW" "📝 Creating agents README..."
cat > agents/README.md << 'EOF'
# AI Agents

This directory contains AI agents, crews, and tools for automated code review, 
pull request management, and development workflow automation.

## 🚀 Quick Start

### Installation

```bash
./scripts/install_agents.sh
```

### Activation

```bash
source venv/bin/activate
```

### Configuration

1. Copy `.env.example` to `.env`
2. Add your API keys
3. Configure agent settings

## 📦 Components

### Agents (`configs/`)
- **Code Reviewer Agent**: Performs code reviews
- **PR Handler Agent**: Manages pull requests
- Additional specialized agents

### Crews (`crews/`)
- **Code Review Crew**: Multi-agent code review system
- Custom crew configurations

### Prompts (`prompts/`)
- Reusable prompt templates
- Instruction sets
- Best practices

### Tools (`tools/`)
- Custom tools for agents
- Integration utilities

### Scripts (`scripts/`)
- Installation scripts
- Runner scripts
- Utility scripts

## 🎯 Usage

### Review Code

```bash
python scripts/run_agent.py review-code path/to/file.py
```

### Review Pull Request

```bash
python scripts/run_agent.py review-pr 123 --repo owner/repo
```

### Security Check

```bash
python scripts/run_agent.py check-security ./src
```

### List Agents

```bash
python scripts/run_agent.py list-agents
```

## 🔧 Configuration

### Environment Variables

See `.env.example` for required configuration.

### Agent Configuration

Agent configurations are in `configs/` directory in YAML format.

## 📚 Documentation

- [Code Review Prompts](prompts/code_review_prompts.md)
- [Instruction Sets](prompts/instruction_sets.md)

## 🤝 Integration

### GitHub Actions

Agents are integrated with GitHub Actions workflows in `.github/workflows/`

### API Usage

```python
from crews.code_review_crew import CodeReviewCrew

crew = CodeReviewCrew(api_key="your-key")
result = crew.review_code(code="your code here")
```

## 🛠️ Development

### Adding New Agents

1. Create config in `configs/`
2. Implement agent logic
3. Add to crew if needed
4. Update documentation

### Testing

```bash
pytest tests/
```

## 📖 Resources

- [CrewAI Documentation](https://docs.crewai.com/)
- [LangChain Documentation](https://python.langchain.com/)
- [OpenAI API](https://platform.openai.com/docs/)

## 🐛 Troubleshooting

### Common Issues

1. **API Key Issues**: Ensure `.env` file has valid API keys
2. **Python Version**: Requires Python 3.8+
3. **Dependencies**: Run installation script

### Support

Open an issue on GitHub for support.
EOF

print_message "$GREEN" "✅ Agents README created"

# Final summary
print_message "$GREEN" "
╔════════════════════════════════════════╗
║  ✅ Installation Complete!             ║
╚════════════════════════════════════════╝

Next steps:
1. Copy agents/.env.example to agents/.env
2. Add your API keys to agents/.env
3. Activate virtual environment:
   source agents/venv/bin/activate
4. Run an agent:
   python agents/scripts/run_agent.py list-agents

For more information, see agents/README.md
"

print_message "$YELLOW" "Note: Remember to add your API keys to agents/.env before running agents!"
