# AI Agents

AI agents, crews, tools, and toolsets for automated code review, pull request management, and development workflow automation.

## 🚀 Quick Start

### Installation

```bash
cd agents
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
- **Code Reviewer Agent**: Performs comprehensive code reviews
- **PR Handler Agent**: Manages pull requests and workflow automation
- Additional specialized agents for various tasks

### Crews (`crews/`)
- **Code Review Crew**: Multi-agent code review system with specialized reviewers
  - Senior Code Reviewer
  - Security Expert
  - Performance Analyst
  - Test Engineer
  - Technical Writer

### Prompts (`prompts/`)
- **code_review_prompts.md**: Reusable prompt templates for code reviews
- **instruction_sets.md**: Detailed instruction sets for various development tasks
- Best practices and guidelines

### Tools (`tools/`)
- **github_tools.py**: GitHub API integration utilities
- Custom tools for agent interactions
- Integration utilities

### Scripts (`scripts/`)
- **install_agents.sh**: Automated installation and setup
- Runner scripts for executing agents
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

Create `.env` file with required configuration:

```bash
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
```

### Agent Configuration

Agent configurations are stored in `configs/` directory in YAML format:

```yaml
name: Code Reviewer Agent
role: Senior Code Reviewer
goal: Perform thorough code reviews
capabilities:
  - code_analysis
  - security_review
  - performance_review
```

## 📚 Documentation

- [Code Review Prompts](prompts/code_review_prompts.md)
- [Instruction Sets](prompts/instruction_sets.md)
- [GitHub Actions Integration](../.github/workflows/ai-code-review.yml)

## 🤝 GitHub Actions Integration

Agents are integrated with GitHub Actions workflows:

- **AI Code Review**: `.github/workflows/ai-code-review.yml`
- **Gemini Code Review**: `.github/actions/gemini-code-review/`
- **AI Code Suggestions**: `.github/actions/ai-code-suggestions/`
- **AI Auto-Fix**: `.github/actions/ai-auto-fix/`

## 💻 API Usage

```python
from crews.code_review_crew import CodeReviewCrew

# Initialize crew with API key
crew = CodeReviewCrew(api_key="your-key")

# Review code
result = crew.review_code(
    code="your code here",
    context="Additional context"
)

# Review pull request
pr_result = crew.review_pull_request({
    'title': 'Add new feature',
    'description': 'Feature description',
    'diff': 'git diff output',
    'files': ['file1.py', 'file2.py']
})
```

## 🛠️ Development

### Adding New Agents

1. Create configuration in `configs/`
2. Implement agent logic if needed
3. Add to crew configuration
4. Update documentation
5. Test thoroughly

### Testing

```bash
# Run tests
pytest tests/

# Test specific agent
python -m pytest tests/test_code_reviewer.py
```

### Directory Structure

```
agents/
├── configs/           # Agent configuration files
├── crews/            # Multi-agent crew implementations
├── prompts/          # Prompt templates and instructions
├── scripts/          # Installation and runner scripts
├── tools/            # Agent tools and utilities
├── data/             # Agent data and cache
│   ├── chroma/       # Vector database
│   └── faiss/        # FAISS index
├── logs/             # Agent execution logs
├── venv/             # Python virtual environment
└── README.md         # This file
```

## 📖 Resources

- [CrewAI Documentation](https://docs.crewai.com/)
- [LangChain Documentation](https://python.langchain.com/)
- [OpenAI API](https://platform.openai.com/docs/)
- [Google Gemini API](https://ai.google.dev/)
- [Anthropic Claude API](https://docs.anthropic.com/)

## 🐛 Troubleshooting

### Common Issues

1. **API Key Issues**: Ensure `.env` file has valid API keys
2. **Python Version**: Requires Python 3.8 or higher
3. **Dependencies**: Run `./scripts/install_agents.sh` to install all dependencies
4. **Import Errors**: Activate virtual environment with `source venv/bin/activate`

### Debug Mode

Enable debug logging:

```bash
export LOG_LEVEL=DEBUG
python scripts/run_agent.py review-code file.py
```

### Support

- Check [GitHub Issues](../../issues)
- Review [documentation](../../.github/)
- Open a new issue for bugs or feature requests

## 🚦 Status

- ✅ Code Review Crew implemented
- ✅ GitHub integration configured
- ✅ Prompt library created
- ✅ Installation scripts ready
- ✅ Configuration templates available
- 🔄 Additional agents in development

## 📄 License

See [LICENSE](../LICENSE) for details.

---

*For more information, see the main repository [README](../README.md)*
