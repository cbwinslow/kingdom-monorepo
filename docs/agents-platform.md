# Agent Platform and Crew Registry

This document describes the OpenAI-compatible agent system, tool registry, and crew configurations contained in the `agents` package. The platform is designed for local execution while producing payloads that can be sent directly to the OpenAI Chat Completions API or any compatible runtime.

## Registries
- **Agents (`agents/configs/agent_registry.json`)** — 100 structured roles with names, guardrails, and tool bindings. Each agent includes an input schema and stylistic guidance for markdown deliverables.
- **Tools (`agents/configs/tool_registry.json`)** — 100 function-style tools that follow the `type: function` OpenAI calling convention. Parameters are shaped for orchestration metadata (task, context, priority, deadline).
- **Crews (`agents/crews/crewai_configs.json`)** — 10 delivery crews that group agents into reusable workflows. Each entry captures the mission, entry agent, collaborator roster, playbook steps, and handoff policy.

## Platform
The `agents/platform` package loads the registries and exposes helpers to keep payloads OpenAI-ready:

- `AgentPlatform.build_openai_chat_request(agent_id, user_prompt)` builds the `model`, `messages`, and `tools` payload expected by chat completions.
- `AgentPlatform.crew_playbook(crew_id)` returns a ready-to-consume description of a crew mission and member lineup.
- `AgentPlatform.simulate_handshake(crew_id, objective)` stitches the crew playbook into a deterministic kickoff plan for downstream runtimes.
- `load_default_platform()` constructs a platform instance wired to the checked-in registries.

## Usage
1. Import the loader: `from agents.platform import load_default_platform`.
2. Call `platform = load_default_platform()`.
3. Inspect available resources with `platform.list_agents()`, `platform.list_tools()`, or `platform.list_crews()`.
4. Build a payload: `payload = platform.build_openai_chat_request('agent-001', 'Summarize incidents from today.')`.
5. Attach `payload` to your OpenAI Chat Completions client or route it to a compatible orchestrator.

## Compatibility Notes
- Tools follow the `function` block schema expected by OpenAI tool calling.
- Agents declare inputs explicitly via `input_schema`, simplifying validation before dispatch.
- Crews mirror CrewAI concepts (entry agent, collaborators, playbook) while staying serializable and execution-agnostic.
