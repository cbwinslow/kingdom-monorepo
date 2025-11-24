# OpenRouter Agent & Crew Platform

A portable, shell-first framework for composing OpenAI/OpenRouter-compatible agents, crews, tools, and orchestration workflows. The platform is inspired by CrewAI-like multi-agent coordination and is designed to live alongside your dotfiles for fast iteration in terminals or headless environments.

## Goals
- **Deep, reusable configuration library** for agents, crews, toolsets, and workflows stored as JSON/YAML/Markdown.
- **Shell-native operations** so you can run, test, and compose agents directly from Bash or a future Go-based TUI shell.
- **OpenRouter-first compatibility** with free/low-cost models while remaining API-compatible with OpenAI-style schemas.
- **Distributed coordination** using RabbitMQ (message bus) and PostgreSQL (persistent state/telemetry) via docker-compose.
- **Autonomous execution** with democratic and consensus-based decision procedures to supervise multi-agent groups.

## Directory layout
- `configs/agents` — Atomic agent manifests (name, model, instructions, tools).
- `configs/crews` — Crews that bind agents to collaboration strategies and comms channels.
- `configs/tools` — Single tool definitions (shell, search, http, RAG, bus publish/consume, DB).
- `configs/toolsets` — Bundles of tools for quick composition.
- `configs/workflows` — Coordination blueprints (routing, voting, retries, self-check loops).
- `operations` — Runbooks for local, containerized, or CI-driven agent runs.
- `scripts` — Shell utilities for registering configs, building payloads, and dispatching jobs via OpenRouter.

## Core architecture
1. **Profiles & Shell Integration**
   - `cbw-dotfiles/bash/profiles/ai_shell.sh` wires local directories (`~/.bash_agents`, `~/.bash_tools`, etc.) with search helpers and OpenRouter credentials.
   - Functions under `cbw-dotfiles/bash/functions/12-ai-automation.sh` bootstrap directories, sync this repo into your home, and dispatch tasks to the platform.

2. **Multi-agent runtime**
   - Crews declare member agents plus **routing rules** (round-robin, capability matching) and **decision policies** (majority vote, confidence-weighted vote, rotating lead).
   - RabbitMQ topics mediate dialogue between agents; PostgreSQL stores artifacts, run logs, and audit trails.
   - Workflows describe **autonomous loops**: plan → assign → execute → self-check → consensus → deliver or retry.

3. **Tooling**
   - Tool definitions are OpenAI-compatible function/tool schemas. Toolsets bundle reusable capabilities (search, shell, retrieval, messaging, DB access).
   - The `agent_hub.sh` helper builds chat completion payloads that attach the right tools per crew and streams results to the bus/DB when configured.

4. **Future Go shell**
   - The directory structure and profiles anticipate a Go-based TUI shell with panes/layouts bound to crews. Panels can map to message topics (planning, execution, QA) and surface live consensus states.

## Quick start
1. **Bootstrap dotfile workspace**
   - Source `cbw-dotfiles/bash/profiles/ai_shell.sh` to add helpers and environment variables.
   - Run `ai_stack_bootstrap` to create/sync `~/.bash_agents`, `~/.bash_tools`, etc.
2. **Bring up infra (optional)**
   - `docker compose -f agents/openrouter-platform/docker-compose.agents.yml up -d` to start RabbitMQ + Postgres for coordination and storage.
3. **Register configs**
   - Use `agent_hub register-agent configs/agents/research_lead.json` to copy curated manifests into `~/.bash_agents`.
   - Use `agent_hub register-crew configs/crews/autonomous_delivery.json` to sync crew orchestrations.
4. **Run a job**
   - `agent_hub run configs/crews/autonomous_delivery.json tasks/feature_spec.md` builds an OpenRouter payload that binds the crew, tools, and workflow metadata.
5. **Iterate**
   - Edit JSON/Markdown configs, re-run `agent_hub render` to verify payloads, and plug into CI or the future Go shell panes.

## Notes
- All configs intentionally use OpenAI-compatible JSON schema to stay portable across OpenRouter or OpenAI endpoints.
- The platform is shell-first: no heavy runtime is required beyond Bash, `jq`/`python3`, and Docker for the optional infra stack.
- Extend by adding more agents, tools, and workflows under `configs/` and referencing them from crews.
