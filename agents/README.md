# Agents

AI agents, crews, tools, and toolsets for automation and intelligence in software development.

## Overview

This directory contains comprehensive configurations for AI agents and crews designed specifically for programming and software development tasks. The configurations are structured to work with agent frameworks like CrewAI, AutoGen, or custom orchestration systems.

### Contents

- **55 Agent Configurations** - Specialized roles covering all aspects of software development
- **55 Crew Configurations** - Coordinated teams for complex projects
- Detailed documentation and usage examples
- JSON-based configuration format for easy integration

## Structure

- **agents/** - Individual agent implementations and configurations
- **crews/** - Agent crews and orchestration configurations
- **tools/** - Agent tools and utilities (to be populated)
- **toolsets/** - Collections of related tools (to be populated)
- **logs/** - Agent execution logs and monitoring (runtime directory)

## Quick Start

### Exploring Agents

Browse the `agents/` directory to find specialized agent configurations:

```bash
# List all available agents
ls agents/*.json

# View a specific agent configuration
cat agents/backend-api-developer.json
```

See `agents/README.md` for detailed agent documentation.

### Exploring Crews

Browse the `crews/` directory to find team configurations:

```bash
# List all available crews
ls crews/*.json

# View a specific crew configuration
cat crews/fullstack-web-development-crew.json
```

See `crews/README.md` for detailed crew documentation.

## Agent Categories

Our 55 agents cover:

- **Backend Development** (API, Python, Node.js, Go, Microservices)
- **Frontend Development** (React, Vue, Angular, UI/UX)
- **Mobile Development** (Native, React Native, Flutter)
- **Data & ML** (Data Engineering, Data Science, ML, NLP, Computer Vision)
- **Database** (Architecture, Redis, Elasticsearch)
- **DevOps & Infrastructure** (Cloud, Kubernetes, CI/CD, SRE)
- **Security & Compliance** (AppSec, Accessibility)
- **Quality & Testing** (QA, Performance, Code Review)
- **Architecture & Design** (System Architecture, Technical Debt)
- **Documentation** (Technical Writing, API Docs, i18n)
- **Specialized Domains** (Blockchain, Gaming, Embedded, Graphics)
- **Project Management** (Scrum, Product, Release)
- **Operations** (Observability, Message Queues, Networking)

## Crew Categories

Our 55 crews support:

- **Web Applications** (Full-stack, Frontend, E-commerce, PWA)
- **Backend & APIs** (REST, GraphQL, Microservices)
- **Mobile Apps** (Native, Cross-platform)
- **Data & AI/ML** (Pipelines, Analytics, NLP, Computer Vision)
- **Infrastructure** (DevOps, Cloud, Kubernetes, Serverless)
- **Security & Quality** (Audits, Testing, Performance)
- **Specialized Platforms** (Blockchain, Gaming, IoT, Streaming)
- **Operations** (Monitoring, Disaster Recovery, Release)
- **Financial & Payments** (FinTech, Payment Processing)
- **Content & Search** (CMS, Search Platforms, SEO)

## Usage Examples

### Example 1: Using a Single Agent

```python
import json
from crewai import Agent

# Load agent configuration
with open('agents/backend-api-developer.json') as f:
    config = json.load(f)

# Create agent
agent = Agent(
    role=config['role'],
    goal=config['goal'],
    backstory=config['backstory'],
    verbose=config['verbose'],
    allow_delegation=config['allow_delegation']
)
```

### Example 2: Using a Crew

```python
import json
from crewai import Crew, Task, Agent

# Load crew configuration
with open('crews/fullstack-web-development-crew.json') as f:
    crew_config = json.load(f)

# Create agents from crew's agent list
agents = []
for agent_id in crew_config['agents']:
    with open(f'agents/{agent_id}.json') as f:
        agent_config = json.load(f)
        agents.append(create_agent(agent_config))

# Create tasks from crew configuration
tasks = []
for task_config in crew_config['tasks']:
    tasks.append(Task(
        description=task_config['description'],
        expected_output=task_config['expected_output'],
        agent=get_agent_by_id(agents, task_config['agent'])
    ))

# Create and execute crew
crew = Crew(
    agents=agents,
    tasks=tasks,
    process=crew_config['process'],
    verbose=crew_config['verbose']
)

result = crew.kickoff()
```

### Example 3: Custom Crew Assembly

```python
# Mix and match agents for custom needs
frontend_agent = load_agent('frontend-react-developer')
backend_agent = load_agent('backend-python-developer')
devops_agent = load_agent('devops-engineer')
qa_agent = load_agent('qa-automation-engineer')

custom_crew = Crew(
    agents=[frontend_agent, backend_agent, devops_agent, qa_agent],
    tasks=create_custom_tasks(),
    process='sequential'
)
```

## Integration with Frameworks

### CrewAI

These configurations are designed to work seamlessly with CrewAI:

```python
from crewai import Agent, Task, Crew
# Load and use configurations as shown above
```

### AutoGen

Can be adapted for AutoGen:

```python
from autogen import AssistantAgent
# Convert configuration to AutoGen format
```

### LangChain

Compatible with LangChain agents:

```python
from langchain.agents import initialize_agent
# Use configuration for agent initialization
```

## Configuration Format

### Agent Configuration

```json
{
  "id": "unique-id",
  "name": "Agent Name",
  "role": "Specific Role",
  "goal": "Primary objective",
  "backstory": "Experience description",
  "capabilities": ["skill1", "skill2"],
  "tools": ["tool1", "tool2"],
  "expertise_level": "senior",
  "languages": ["Python", "JavaScript"],
  "frameworks": ["Django", "React"],
  "max_iterations": 25,
  "allow_delegation": true,
  "verbose": true,
  "memory": true
}
```

### Crew Configuration

```json
{
  "id": "unique-crew-id",
  "name": "Crew Name",
  "description": "Brief description",
  "goal": "Crew objective",
  "agents": ["agent1-id", "agent2-id"],
  "process": "sequential",
  "tasks": [
    {
      "name": "task_name",
      "description": "Task details",
      "agent": "agent-id",
      "expected_output": "Expected result"
    }
  ],
  "manager_agent": "manager-id",
  "max_rpm": 100,
  "verbose": true
}
```

## Best Practices

1. **Match Agent Expertise to Task Complexity**
   - Use expert-level agents for architectural decisions
   - Use senior-level agents for implementation
   - Enable delegation for complex tasks

2. **Choose Appropriate Crews**
   - Start with pre-configured crews for common scenarios
   - Customize as needed for specific requirements
   - Combine multiple crews for large projects

3. **Monitor and Iterate**
   - Use verbose mode during development
   - Track task completion and quality
   - Adjust configurations based on results

4. **Tool Integration**
   - Ensure agents have access to required tools
   - Implement tool interfaces as needed
   - Test tool functionality before production use

5. **Documentation**
   - Keep configurations well-documented
   - Update README files when adding agents/crews
   - Share learnings and best practices

## Development Workflow

### 1. Planning Phase
- Use system-architect or product-owner agents
- Assemble planning crews (agile-scrum-crew)

### 2. Development Phase
- Use specialized development crews
- Full-stack, backend, frontend, mobile crews

### 3. Quality Assurance
- Use testing and quality crews
- Performance, security, accessibility crews

### 4. Deployment Phase
- Use DevOps and infrastructure crews
- Release and monitoring crews

### 5. Maintenance Phase
- Use observability and support crews
- Technical debt and optimization crews

## Contributing

We welcome contributions! To add new agents or crews:

1. **Fork the repository**
2. **Create configuration file** following the standard format
3. **Update README** with your addition
4. **Test configuration** with your agent framework
5. **Submit pull request** with clear description

### Adding a New Agent

```bash
# Create agent file
cat > agents/my-new-agent.json << 'EOF'
{
  "id": "my-new-agent-xxx",
  "name": "My New Agent",
  ...
}
EOF

# Update agents/README.md
# Add to appropriate category
```

### Adding a New Crew

```bash
# Create crew file
cat > crews/my-new-crew.json << 'EOF'
{
  "id": "my-new-crew-xxx",
  "name": "My New Crew",
  ...
}
EOF

# Update crews/README.md
# Add to appropriate category
```

## Support & Resources

- **Agent Documentation**: See `agents/README.md`
- **Crew Documentation**: See `crews/README.md`
- **Examples**: Check configuration files for patterns
- **Issues**: Report issues via GitHub Issues
- **Discussions**: Join discussions for questions

## Future Enhancements

Planned additions:

- [ ] Tool implementations in `tools/` directory
- [ ] Toolset collections in `toolsets/` directory
- [ ] Example scripts and integration guides
- [ ] Performance benchmarks
- [ ] Video tutorials and walkthroughs
- [ ] Additional specialized agents and crews
- [ ] Template generator for new configurations
- [ ] Validation tools for configurations

## License

See the repository LICENSE file for details.

---

**Ready to build with AI agents?** Start exploring the `agents/` and `crews/` directories!
