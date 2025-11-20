# AI Agents Stack

Comprehensive AI agent infrastructure with LLMs, vector databases, workflow automation, and agent frameworks.

## Components

### LLM Services
- **openai-api** (port 4000) - LiteLLM proxy for multiple LLM providers
- **ollama** (port 11434) - Local LLM runtime
- **ollama-webui** (port 3000) - Web interface for Ollama
- **text-generation-webui** (ports 7860, 5000, 5005) - oobabooga interface

### Agent Frameworks
- **langchain-agent** (port 8000) - LangChain agent runtime
- **autogpt** - Autonomous AI agent
- **agentgpt** (port 3001) - Web-based autonomous agent
- **crewai** - Multi-agent collaboration system

### Workflow & Visual Builders
- **n8n** (port 5678) - Workflow automation
- **flowise** (port 3002) - Visual LangChain builder
- **langflow** (port 7861) - Another LangChain visual builder

### Vector Databases
- **qdrant** (ports 6333, 6334) - Vector similarity search
- **weaviate** (port 8080) - AI-native vector database
- **chromadb** (port 8001) - Embeddings database

### Supporting Services
- **redis** (port 6379) - Caching and queue
- **minio** (ports 9000, 9001) - S3-compatible object storage
- **jupyter** (port 8888) - Development notebooks
- **agent-monitor** (port 9090) - Monitoring dashboard
- **agentgpt-db** - PostgreSQL for AgentGPT

## Quick Start

### 1. Environment Setup

Create `.env` file:

```bash
# API Keys
OPENAI_API_KEY=sk-xxxxxxxxxxxxx
ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxxx
GEMINI_API_KEY=xxxxxxxxxxxxx
COHERE_API_KEY=xxxxxxxxxxxxx

# Database
DATABASE_URL=sqlite:////app/data/litellm.db

# Web UI secrets
WEBUI_SECRET_KEY=change_this_secret
NEXTAUTH_SECRET=change_this_nextauth_secret
N8N_USER=admin
N8N_PASSWORD=secure_password
FLOWISE_USER=admin
FLOWISE_PASSWORD=secure_password

# Redis
REDIS_PASSWORD=redis_secure_password

# MinIO
MINIO_USER=minioadmin
MINIO_PASSWORD=minioadmin_password
```

### 2. Start Core Services

```bash
# Start LiteLLM API gateway
docker-compose up -d openai-api

# Start local LLM (requires GPU)
docker-compose up -d ollama ollama-webui

# Start vector databases
docker-compose up -d qdrant chromadb weaviate

# Start workflow tools
docker-compose up -d n8n flowise
```

### 3. Verify Services

```bash
# Check LiteLLM health
curl http://localhost:4000/health

# Check Ollama
curl http://localhost:11434/api/tags

# Check vector databases
curl http://localhost:6333/collections
curl http://localhost:8001/api/v1/heartbeat
```

## Usage Examples

### Using LiteLLM Proxy

```python
import openai

# Point to local proxy
openai.api_base = "http://localhost:4000/v1"
openai.api_key = "dummy"  # Not needed for local proxy

# Use any model
response = openai.ChatCompletion.create(
    model="gpt-4",  # or "claude-3", "gemini-pro", etc.
    messages=[{"role": "user", "content": "Hello!"}]
)
print(response.choices[0].message.content)
```

### Using Ollama

```bash
# Pull a model
docker exec ai-ollama ollama pull llama2

# Run a model
docker exec ai-ollama ollama run llama2 "Hello, how are you?"

# List installed models
docker exec ai-ollama ollama list
```

```python
# Python client
import requests

response = requests.post('http://localhost:11434/api/generate',
    json={
        'model': 'llama2',
        'prompt': 'Why is the sky blue?'
    })
print(response.json())
```

### Using LangChain Agent

```python
import requests

# Send request to LangChain agent
response = requests.post('http://localhost:8000/agent/invoke',
    json={
        'input': 'What is the weather like?'
    })
print(response.json())
```

### Using Vector Databases

```python
# Qdrant
from qdrant_client import QdrantClient

client = QdrantClient(host="localhost", port=6333)

# Create collection
client.create_collection(
    collection_name="documents",
    vectors_config={"size": 384, "distance": "Cosine"}
)

# Insert vectors
client.upsert(
    collection_name="documents",
    points=[
        {"id": 1, "vector": [...], "payload": {"text": "document 1"}},
    ]
)

# Search
results = client.search(
    collection_name="documents",
    query_vector=[...],
    limit=5
)
```

```python
# ChromaDB
import chromadb

client = chromadb.HttpClient(host="localhost", port=8001)

# Create collection
collection = client.create_collection("documents")

# Add documents
collection.add(
    documents=["This is document 1", "This is document 2"],
    ids=["doc1", "doc2"]
)

# Query
results = collection.query(
    query_texts=["search query"],
    n_results=5
)
```

### Using n8n Workflows

1. Access http://localhost:5678
2. Login with N8N_USER/N8N_PASSWORD
3. Create workflow with AI nodes
4. Example workflow: Slack → OpenAI → Database

### Using Flowise

1. Access http://localhost:3002
2. Login with FLOWISE_USER/FLOWISE_PASSWORD
3. Drag and drop to build LangChain flows
4. Connect LLMs, vector stores, and tools

## AI Agent Development

### Simple Agent with LangChain

```python
from langchain.agents import AgentExecutor, create_openai_functions_agent
from langchain_openai import ChatOpenAI
from langchain.tools import Tool
from langchain.prompts import ChatPromptTemplate

# Initialize LLM
llm = ChatOpenAI(
    openai_api_base="http://localhost:4000/v1",
    openai_api_key="dummy"
)

# Define tools
def calculator(expression: str) -> str:
    return str(eval(expression))

tools = [
    Tool(
        name="Calculator",
        func=calculator,
        description="Useful for math calculations"
    )
]

# Create agent
prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful assistant."),
    ("user", "{input}"),
    ("assistant", "{agent_scratchpad}")
])

agent = create_openai_functions_agent(llm, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools)

# Run agent
result = agent_executor.invoke({"input": "What is 25 * 4?"})
print(result)
```

### RAG System with Vector Database

```python
from langchain.vectorstores import Chroma
from langchain.embeddings import OpenAIEmbeddings
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.chains import RetrievalQA
from langchain_openai import ChatOpenAI

# Initialize components
embeddings = OpenAIEmbeddings(
    openai_api_base="http://localhost:4000/v1"
)

vectorstore = Chroma(
    client=chromadb.HttpClient(host="localhost", port=8001),
    embedding_function=embeddings
)

llm = ChatOpenAI(openai_api_base="http://localhost:4000/v1")

# Create RAG chain
qa_chain = RetrievalQA.from_chain_type(
    llm=llm,
    retriever=vectorstore.as_retriever(),
    return_source_documents=True
)

# Query
result = qa_chain({"query": "What is the document about?"})
print(result['result'])
```

### CrewAI Multi-Agent System

The CrewAI container runs a multi-agent system with researcher and writer agents. To customize:

```python
# Create custom crew configuration
from crewai import Agent, Task, Crew, Process

# Define agents with specific roles
researcher = Agent(
    role='Senior Researcher',
    goal='Uncover cutting-edge developments',
    backstory='Expert at finding and analyzing information',
    verbose=True
)

writer = Agent(
    role='Content Creator',
    goal='Create engaging content',
    backstory='Skilled writer with technical knowledge',
    verbose=True
)

# Define tasks
research_task = Task(
    description='Research AI developments',
    agent=researcher
)

write_task = Task(
    description='Write blog post',
    agent=writer
)

# Create crew
crew = Crew(
    agents=[researcher, writer],
    tasks=[research_task, write_task],
    process=Process.sequential
)

# Execute
result = crew.kickoff()
```

## Model Management

### Ollama Models

```bash
# Pull models
docker exec ai-ollama ollama pull llama2
docker exec ai-ollama ollama pull codellama
docker exec ai-ollama ollama pull mistral

# List models
docker exec ai-ollama ollama list

# Remove model
docker exec ai-ollama ollama rm llama2

# Show model info
docker exec ai-ollama ollama show llama2
```

### Text Generation WebUI

1. Access http://localhost:7860
2. Download models from Hugging Face
3. Place in `text-generation-webui/models/`
4. Load model in UI

## Monitoring

### Agent Metrics

```bash
# View Prometheus metrics
curl http://localhost:9090/metrics

# Output includes:
# agent_requests_total
# agent_errors_total
# active_agents
```

### LLM Usage Tracking

```bash
# LiteLLM logs
docker-compose logs openai-api

# Check database for usage stats
sqlite3 litellm/data/litellm.db "SELECT * FROM request_logs"
```

### Resource Usage

```bash
# Check GPU usage (if available)
docker exec ai-ollama nvidia-smi

# Check memory usage
docker stats ai-ollama ai-text-generation-webui
```

## Storage and Data Management

### MinIO Object Storage

```bash
# Access UI: http://localhost:9001
# Login with MINIO_USER/MINIO_PASSWORD

# Create bucket
docker exec ai-minio mc alias set local http://localhost:9000 $MINIO_USER $MINIO_PASSWORD
docker exec ai-minio mc mb local/ai-data

# Upload file
docker exec ai-minio mc cp /data/file.txt local/ai-data/
```

### Jupyter Notebooks

```bash
# Get Jupyter token
docker-compose logs jupyter | grep token

# Access: http://localhost:8888
# Token will be in the logs
```

## Production Deployment

### GPU Support

Ensure Docker has GPU support:

```yaml
services:
  ollama:
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
```

### Scaling

```yaml
# Scale LangChain agents
docker-compose up -d --scale langchain-agent=3

# Use load balancer
services:
  nginx:
    image: nginx:alpine
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
```

### Security

1. **API authentication** for all services
2. **Network isolation** between services
3. **Secrets management** for API keys
4. **Rate limiting** on public endpoints
5. **Regular updates** of all images
6. **Audit logging** of agent actions

## Troubleshooting

### Ollama GPU Issues

```bash
# Check GPU availability
docker exec ai-ollama nvidia-smi

# Check CUDA
docker exec ai-ollama nvcc --version

# Run CPU-only
# Remove GPU deployment section from docker-compose.yml
```

### Vector Database Connection Errors

```bash
# Test Qdrant
curl http://localhost:6333/collections

# Test ChromaDB
curl http://localhost:8001/api/v1/heartbeat

# Check logs
docker-compose logs qdrant chromadb
```

### Out of Memory

```bash
# Check memory usage
docker stats

# Increase limits in docker-compose.yml
deploy:
  resources:
    limits:
      memory: 8G
```

## References

- [LiteLLM Documentation](https://docs.litellm.ai/)
- [Ollama Documentation](https://ollama.ai/docs)
- [LangChain Documentation](https://python.langchain.com/docs/)
- [CrewAI Documentation](https://docs.crewai.com/)
- [n8n Documentation](https://docs.n8n.io/)
- [Flowise Documentation](https://docs.flowiseai.com/)
- [Qdrant Documentation](https://qdrant.tech/documentation/)
- [ChromaDB Documentation](https://docs.trychroma.com/)
