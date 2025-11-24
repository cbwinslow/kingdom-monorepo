#!/usr/bin/env bash
# Shell profile for AI-native workflows, OpenRouter integration, and multi-agent automation.

export AI_SHELL_ROOT="${AI_SHELL_ROOT:-$HOME}"
AI_PROFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export AI_SHELL_REPO_ROOT="${AI_SHELL_REPO_ROOT:-$(cd "${AI_PROFILE_DIR}/../.." && pwd)}"
export AI_SHELL_BIN="$AI_SHELL_ROOT/.local/bin"
export OPENROUTER_BASE_URL="${OPENROUTER_BASE_URL:-https://openrouter.ai/api/v1/chat/completions}"
export AI_AGENT_HOME="$HOME/.bash_agents"
export AI_CREW_HOME="$HOME/.bash_crews"
export AI_TOOL_HOME="$HOME/.bash_tools"
export AI_LOG_HOME="$HOME/.bash_logs"
export AI_HISTORY_HOME="$HOME/.bash_history"

mkdir -p "$AI_SHELL_BIN" "$AI_AGENT_HOME" "$AI_CREW_HOME" "$AI_TOOL_HOME" "$AI_LOG_HOME" "$AI_HISTORY_HOME"

# Export search paths for agent_hub and other runners
export AGENT_SEARCH_PATHS="agents/openrouter-platform/configs/agents:$AI_AGENT_HOME"
export AGENT_TOOLSET_PATHS="agents/openrouter-platform/configs/toolsets:$AI_TOOL_HOME"
export AGENT_TOOL_PATHS="agents/openrouter-platform/configs/tools:$AI_TOOL_HOME"
export AGENT_WORKFLOW_PATHS="agents/openrouter-platform/configs/workflows:$AI_CREW_HOME"
export AGENT_CREW_PATHS="agents/openrouter-platform/configs/crews:$AI_CREW_HOME"

# ai_search searches for QUERY in PATH (defaults to HOME), printing local ripgrep matches (including hidden files) and then querying DuckDuckGo's Instant Answer API to print a short web snippet.
ai_search() {
    if [ -z "$1" ]; then
        echo "Usage: ai_search <query> [path]";
        return 1;
    fi
    local query="$1";
    local search_path="${2:-$HOME}";
    echo "[local] searching ${search_path} for '${query}'";
    rg --hidden --no-heading --line-number "$query" "$search_path" 2>/dev/null || echo "(no local matches)";
    echo "[web] duckduckgo instant answer for '${query}'";
    curl -sG "https://api.duckduckgo.com/" --data-urlencode "q=$query" --data "format=json&no_redirect=1&no_html=1" | \
      python3 -c "import json,sys; data=json.load(sys.stdin); print(data.get('AbstractText') or data.get('Answer') or 'no web snippet found')"
}

# agent_hub invokes the repository's agent_hub.sh script and forwards all provided arguments.
agent_hub() {
    "${AI_SHELL_REPO_ROOT}/agents/openrouter-platform/scripts/agent_hub.sh" "$@"
}

# Route logs and payloads into predictable locations
export AGENT_HUB_PAYLOAD_DIR="${AI_LOG_HOME}/payloads"
mkdir -p "$AGENT_HUB_PAYLOAD_DIR"

# ai_payload renders a payload from a crew JSON and task Markdown into a timestamped JSON file and optionally runs the task.
ai_payload() {
    if [ $# -lt 2 ]; then
        echo "Usage: ai_payload <crew.json> <task.md> [run]";
        return 1;
    fi
    local crew="$1"; shift
    local task="$1"; shift
    local stamp
    stamp="$(date -u +%Y%m%dT%H%M%SZ)"
    local out="${AGENT_HUB_PAYLOAD_DIR}/payload_${stamp}.json"
    agent_hub render "$crew" "$task" | tee "$out"
    if [ "${1:-}" = "run" ]; then
        agent_hub run "$crew" "$task"
    fi
}