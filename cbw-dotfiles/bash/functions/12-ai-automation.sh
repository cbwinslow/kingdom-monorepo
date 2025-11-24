#!/usr/bin/env bash
# ai_stack_bootstrap creates a predefined set of hidden AI stack directories under the given root (defaults to $HOME) and prints a confirmation message.

ai_stack_bootstrap() {
    local root="${1:-$HOME}"
    mkdir -p "$root/.bash_agents" "$root/.bash_crews" "$root/.bash_tools" \
        "$root/.bash_configs" "$root/.bash_logs" "$root/.bash_history" \
        "$root/.bash_documents" "$root/.bash_repos" "$root/.bash_bins"
    echo "Initialized AI stack directories under $root"
}

# ai_stack_sync synchronizes agents, crews, and tools configuration from a repository into the home root, creating target directories as needed (defaults: repo_root=$PWD, home_root=$HOME).
ai_stack_sync() {
    local repo_root="${1:-$PWD}"
    local home_root="${2:-$HOME}"
    mkdir -p "$home_root/.bash_agents" "$home_root/.bash_crews" "$home_root/.bash_tools"
    rsync -av --delete "$repo_root/agents/openrouter-platform/configs/agents/" "$home_root/.bash_agents/" 2>/dev/null
    rsync -av --delete "$repo_root/agents/openrouter-platform/configs/crews/" "$home_root/.bash_crews/" 2>/dev/null
    rsync -av --delete "$repo_root/agents/openrouter-platform/configs/toolsets/" "$home_root/.bash_tools/" 2>/dev/null
    rsync -av --delete "$repo_root/agents/openrouter-platform/configs/tools/" "$home_root/.bash_tools/" 2>/dev/null
    echo "Synced agent configs, crews, and tools from $repo_root into $home_root"
}

# ai_shell_scan searches for a pattern in shell scripts and AI asset directories under a specified path (defaults to $HOME).
ai_shell_scan() {
    local needle="$1"; shift
    if [ -z "$needle" ]; then
        echo "Usage: ai_shell_scan <pattern> [path]";
        return 1;
    fi
    local search_path="${1:-$HOME}";
    echo "Scanning shell assets for: $needle"
    rg --hidden --glob "*.sh" "$needle" "$search_path" "$HOME/.bash_agents" "$HOME/.bash_crews" "$HOME/.bash_tools" 2>/dev/null
}

# ai_agents_status prints counts of JSON files directly under $HOME/.bash_agents, $HOME/.bash_crews, and $HOME/.bash_tools.
ai_agents_status() {
    echo "Agents: $(find "$HOME/.bash_agents" -maxdepth 1 -name '*.json' 2>/dev/null | wc -l)"
    echo "Crews:  $(find "$HOME/.bash_crews" -maxdepth 1 -name '*.json' 2>/dev/null | wc -l)"
    echo "Tools:  $(find "$HOME/.bash_tools" -maxdepth 1 -name '*.json' 2>/dev/null | wc -l)"
}

# ai_agents_run_task runs a task for the crew described in the given JSON file using the provided Markdown task file by invoking `agent_hub run`; prints a usage message and returns 1 if fewer than two arguments are provided.
ai_agents_run_task() {
    if [ $# -lt 2 ]; then
        echo "Usage: ai_agents_run_task <crew.json> <task.md>";
        return 1;
    fi
    agent_hub run "$1" "$2"
}

# ai_agents_plan_task renders a task plan for a given crew JSON and task markdown file by invoking `agent_hub render`.
ai_agents_plan_task() {
    if [ $# -lt 2 ]; then
        echo "Usage: ai_agents_plan_task <crew.json> <task.md>";
        return 1;
    fi
    agent_hub render "$1" "$2"
}

# ai_agents_toggle_autonomy sets the AI_AUTONOMY_STATE environment variable to the given state (default: on) and echoes the new state.
ai_agents_toggle_autonomy() {
    local state="${1:-on}"
    export AI_AUTONOMY_STATE="$state"
    echo "Autonomy switch set to: $state"
}

# ai_agents_vote_sweep records a sample set of agent votes for the given proposal into a JSON file (default path: $HOME/.bash_logs/votes_<timestamp>.json).
ai_agents_vote_sweep() {
    local proposal_id="${1:-default_proposal}"
    local votes_file="${2:-$HOME/.bash_logs/votes_$(date -u +%Y%m%dT%H%M%SZ).json}"
    python3 - <<PY
import json, os, sys
proposal = sys.argv[1]
path = sys.argv[2]
votes = [
    {"agent": "research_lead", "choice": "approve", "confidence": 0.32},
    {"agent": "builder", "choice": "approve", "confidence": 0.48},
    {"agent": "qa_chair", "choice": "revise", "confidence": 0.20},
]
with open(path, "w") as handle:
    json.dump({"proposal_id": proposal, "votes": votes}, handle, indent=2)
print(f"Recorded sample votes to {path}")
PY
"$proposal_id" "$votes_file"
}