# services

SERVICES workspace and components.

## Purpose
This directory contains services-related projects, configurations, and resources.

## Available Services

### LiteLLM Proxy

A unified proxy server for managing multiple LLM providers (OpenAI, Anthropic, Google, etc.) with a single API interface.

**Location:** `services/litellm/`

**Quick Start:**
```bash
cd services/litellm
./setup.sh
```

**Features:**
- Unified API for all LLM providers
- API key management
- Response caching with Redis
- Automatic fallbacks
- Load balancing
- Web UI for management

**Documentation:**
- [Complete Setup Guide](./litellm/README.md)
- [Homelab Server Setup](./litellm/HOMELAB_SETUP.md)

