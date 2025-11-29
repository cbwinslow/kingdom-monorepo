# TL;DR — Agent Platform

- **What:** 100 OpenAI-ready agents + 100 function tools + 10 crews captured in JSON registries.
- **Where:** `agents/configs/agent_registry.json`, `agents/configs/tool_registry.json`, `agents/crews/crewai_configs.json`.
- **How:** `from agents.platform import load_default_platform`; then build chat payloads or crew handoffs with `build_openai_chat_request` and `simulate_handshake`.
- **Why:** Enable drop-in chat completions payloads, CrewAI-style orchestration, and reproducible tool schemas without extra dependencies.
