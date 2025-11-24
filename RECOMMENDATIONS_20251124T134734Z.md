# Recommendations (20251124T134734Z)

- Add a small Go prototype that binds RabbitMQ topics to TUI panes and embeds the `agent_hub` payload preview for end-to-end Go shell validation.
- Wire `ai_search` to optionally call a local RAG index (e.g., `llamaindex` or `chroma`) so agent context stays offline-friendly.
- Extend `agent_hub run` to stream responses and persist transcripts directly into PostgreSQL tables for replay and analytics.
- Provide integration tests that load the sample crew configs and assert payload schemas with `jq` to guard against regressions.
- Consider adding a GitHub Actions workflow that builds the docker-compose stack and runs a smoke test against OpenRouter’s mock server if available.
