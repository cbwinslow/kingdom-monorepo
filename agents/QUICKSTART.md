# Quick Start Guide

Get started with agent and crew configurations in 5 minutes!

## What You Have

- **55 Agent Configurations** - Specialized AI agents for different programming roles
- **55 Crew Configurations** - Pre-assembled teams for common development scenarios
- **Ready-to-use JSON files** - Compatible with CrewAI, AutoGen, and custom frameworks

## Step 1: Choose Your Use Case

Pick the scenario that matches your needs:

### Building Something New?

```bash
# Web application
cat crews/fullstack-web-development-crew.json

# Mobile app
cat crews/mobile-app-development-crew.json

# API service
cat crews/api-development-crew.json

# MVP quickly
cat crews/saas-mvp-crew.json
```

### Improving Existing Code?

```bash
# Fix performance
cat crews/performance-optimization-crew.json

# Improve security
cat crews/security-audit-crew.json

# Better code quality
cat crews/code-quality-crew.json

# Update legacy code
cat crews/legacy-modernization-crew.json
```

### Need Specific Expertise?

```bash
# Browse individual agents
ls agents/*.json

# Example: Backend Python expert
cat agents/backend-python-developer.json

# Example: React specialist
cat agents/frontend-react-developer.json
```

## Step 2: Explore the Configuration

Let's look at a crew configuration:

```bash
cat crews/fullstack-web-development-crew.json
```

You'll see:
- **Agents**: Which experts are on the team
- **Tasks**: What work needs to be done
- **Process**: How work is coordinated (sequential/hierarchical)
- **Expected Outputs**: What each task produces

## Step 3: Use With Your Framework

### Option A: CrewAI (Recommended)

```python
from crewai import Agent, Task, Crew
import json

# Load crew configuration
with open('agents/crews/fullstack-web-development-crew.json') as f:
    crew_config = json.load(f)

# Load agent configurations
def load_agent(agent_id):
    with open(f'agents/agents/{agent_id}.json') as f:
        config = json.load(f)
        return Agent(
            role=config['role'],
            goal=config['goal'],
            backstory=config['backstory'],
            verbose=config.get('verbose', True),
            allow_delegation=config.get('allow_delegation', True)
        )

# Create agents
agents = {agent_id: load_agent(agent_id) 
          for agent_id in crew_config['agents']}

# Create tasks
tasks = []
for task_config in crew_config['tasks']:
    task = Task(
        description=task_config['description'],
        agent=agents[task_config['agent']],
        expected_output=task_config['expected_output']
    )
    tasks.append(task)

# Create and run crew
crew = Crew(
    agents=list(agents.values()),
    tasks=tasks,
    process=crew_config['process'],
    verbose=True
)

result = crew.kickoff()
print(result)
```

### Option B: Custom Implementation

```python
import json

# Load any configuration
with open('agents/agents/backend-api-developer.json') as f:
    agent_config = json.load(f)

# Use the configuration data
print(f"Agent: {agent_config['name']}")
print(f"Role: {agent_config['role']}")
print(f"Capabilities: {', '.join(agent_config['capabilities'][:3])}...")

# Implement your agent logic using this configuration
# ...
```

## Step 4: Common Patterns

### Pattern 1: Full-Stack Web App

```python
# Use the pre-configured full-stack crew
crew_config = load_json('crews/fullstack-web-development-crew.json')

# This crew includes:
# - UI/UX Designer
# - Frontend React Developer
# - Backend Node.js Developer
# - Database Architect
# - QA Automation Engineer

# Run it!
crew = create_crew(crew_config)
result = crew.kickoff(inputs={
    'project_name': 'My Awesome App',
    'features': ['user auth', 'dashboard', 'API']
})
```

### Pattern 2: API-First Development

```python
# Use the API development crew
crew_config = load_json('crews/api-development-crew.json')

# This crew includes:
# - Backend API Developer
# - API Documentation Specialist
# - Security Engineer
# - QA Automation Engineer
# - Performance Engineer

crew = create_crew(crew_config)
result = crew.kickoff(inputs={
    'api_type': 'REST',
    'endpoints': ['users', 'products', 'orders']
})
```

### Pattern 3: Single Agent Tasks

```python
# Sometimes you just need one expert
agent_config = load_json('agents/security-engineer.json')
security_agent = create_agent(agent_config)

# Give them a specific task
task = Task(
    description="Audit the authentication system for vulnerabilities",
    agent=security_agent,
    expected_output="Security audit report with recommendations"
)

result = security_agent.execute(task)
```

### Pattern 4: Custom Crew Assembly

```python
# Mix and match agents for your specific needs
my_agents = [
    load_agent('frontend-react-developer'),
    load_agent('backend-python-developer'),
    load_agent('database-architect'),
    load_agent('devops-engineer')
]

# Create custom tasks
my_tasks = [
    Task(description="Build React dashboard", agent=my_agents[0]),
    Task(description="Create FastAPI backend", agent=my_agents[1]),
    Task(description="Design PostgreSQL schema", agent=my_agents[2]),
    Task(description="Setup Docker deployment", agent=my_agents[3])
]

custom_crew = Crew(agents=my_agents, tasks=my_tasks, process='sequential')
result = custom_crew.kickoff()
```

## Step 5: Tips for Success

### 1. Start Small
```python
# Begin with a simple crew
simple_crew = load_json('crews/saas-mvp-crew.json')
# Get comfortable before moving to complex crews
```

### 2. Iterate on Configuration
```python
# Copy a configuration and modify it
import shutil
shutil.copy(
    'agents/backend-api-developer.json',
    'agents/my-custom-backend-agent.json'
)
# Edit my-custom-backend-agent.json for your needs
```

### 3. Enable Verbose Mode
```python
# See what agents are doing
crew = Crew(
    agents=agents,
    tasks=tasks,
    verbose=True  # This is your friend during development!
)
```

### 4. Use Appropriate Expertise Levels
```python
# Check agent expertise in config
agent_config = load_json('agents/system-architect.json')
print(f"Expertise: {agent_config['expertise_level']}")  # 'expert'

# Use expert agents for complex architectural decisions
# Use senior agents for implementation
# Match complexity to expertise
```

## Real-World Examples

### Example 1: Build a Blog Platform

```bash
# 1. Use full-stack web dev crew
crew = load_crew('fullstack-web-development-crew')

# 2. Define your requirements
inputs = {
    'project': 'Blog Platform',
    'features': [
        'User authentication',
        'Article editor (Markdown)',
        'Comments',
        'Tags and search',
        'Admin panel'
    ],
    'tech_stack': {
        'frontend': 'React with Next.js',
        'backend': 'Node.js with Express',
        'database': 'PostgreSQL',
        'deployment': 'Vercel'
    }
}

# 3. Run the crew
result = crew.kickoff(inputs=inputs)
```

### Example 2: Add Real-Time Chat

```bash
# 1. Use real-time systems crew
crew = load_crew('realtime-systems-crew')

# 2. Specify requirements
inputs = {
    'feature': 'Real-time chat',
    'requirements': [
        'WebSocket connections',
        'Message persistence',
        'Online presence',
        'Typing indicators',
        'Read receipts'
    ]
}

# 3. Execute
result = crew.kickoff(inputs=inputs)
```

### Example 3: Performance Optimization

```bash
# 1. Use performance optimization crew
crew = load_crew('performance-optimization-crew')

# 2. Define problem areas
inputs = {
    'issues': [
        'Slow page load times (>5s)',
        'Database queries taking too long',
        'Large bundle size (2MB)',
        'API response time >500ms'
    ],
    'current_metrics': {
        'page_load': '7s',
        'bundle_size': '2.1MB',
        'api_p95': '800ms'
    },
    'target_metrics': {
        'page_load': '<2s',
        'bundle_size': '<500KB',
        'api_p95': '<200ms'
    }
}

# 3. Let the crew optimize
result = crew.kickoff(inputs=inputs)
```

## Next Steps

1. **Explore the full documentation**
   - `README.md` - Overview and concepts
   - `agents/README.md` - All about agents
   - `crews/README.md` - All about crews
   - `INDEX.md` - Complete reference

2. **Check out all configurations**
   ```bash
   # List everything
   find agents -name "*.json" -type f
   
   # Count them
   echo "Agents: $(ls agents/*.json | wc -l)"
   echo "Crews: $(ls crews/*.json | wc -l)"
   ```

3. **Experiment and customize**
   - Copy configurations
   - Modify for your needs
   - Create new combinations
   - Share your learnings!

4. **Join the community**
   - Report issues on GitHub
   - Share your use cases
   - Contribute new agents/crews
   - Help improve documentation

## Troubleshooting

### "Agent not found"
```python
# Make sure agent ID matches filename
agent_id = 'backend-api-developer'  # ✅ Correct
agent_id = 'backend_api_developer'  # ❌ Wrong (underscore)
```

### "Task failing"
```python
# Check expected_output matches what agent can produce
# Enable verbose mode to see what's happening
crew = Crew(agents=agents, tasks=tasks, verbose=True)
```

### "Crew taking too long"
```python
# Reduce max_iterations in agent config
# Or split into smaller crews
# Or use hierarchical process for better coordination
```

## Getting Help

- **Documentation**: Start with README files
- **Examples**: Check the configuration files themselves
- **Issues**: Open a GitHub issue
- **Questions**: Start a GitHub discussion

## Summary

You now have:
- ✅ 55 ready-to-use agent configurations
- ✅ 55 pre-assembled crew configurations
- ✅ Knowledge of how to use them
- ✅ Real-world examples to learn from

**Ready to build something amazing? Pick a crew and get started!** 🚀

```bash
# Quick command to get started
cat crews/saas-mvp-crew.json
```
