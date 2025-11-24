# Agent Hub Operations

This runbook explains how to operate the shell-first multi-agent stack.

## Prerequisites
- `OPENROUTER_API_KEY` exported in your shell (OpenAI-compatible header).
- `docker` and `docker compose` available for infra services.
- `python3` or `jq` available for payload rendering (used by `agent_hub.sh`).

## Bring up services
```
docker compose -f agents/openrouter-platform/docker-compose.agents.yml up -d
```
RabbitMQ will expose ports 5672/15672; Postgres is exposed on 5432.

## Register artifacts
```
agent_hub register-agent agents/openrouter-platform/configs/agents/research_lead.json
agent_hub register-crew agents/openrouter-platform/configs/crews/autonomous_delivery.json
agent_hub register-toolset agents/openrouter-platform/configs/toolsets/delivery_core.json
```
Artifacts are copied into `~/.bash_agents`, `~/.bash_crews`, etc., keeping home-state synced with the repo.

## Render and run
```
agent_hub render agents/openrouter-platform/configs/crews/autonomous_delivery.json tasks/sample_request.md
agent_hub run agents/openrouter-platform/configs/crews/autonomous_delivery.json tasks/sample_request.md
```
`render` produces an OpenAI-compatible payload and prints it; `run` submits it to the OpenRouter `/chat/completions` endpoint when `OPENROUTER_API_KEY` is set.

## Autonomy & consensus
- Each crew references a workflow (e.g., `democratic_swarm`) that defines routing, voting, retries, and abort conditions.
- The QA chair triggers retries when confidence < quorum; the planner re-queues blocked tasks.

## Telemetry
- Set `AGENT_DB_*` env vars to store run metadata in Postgres via `db_record` tool calls.
- RabbitMQ topics are prefixed with the crew name; you can observe live traffic with the management UI on port 15672.

## Go shell roadmap
- Attach panes to RabbitMQ topics (`planning`, `execution`, `qa`).
- Provide dropdowns for switching crews, workflows, and toolsets.
- Embed the `agent_hub render` payload preview in a side pane for debugging.
