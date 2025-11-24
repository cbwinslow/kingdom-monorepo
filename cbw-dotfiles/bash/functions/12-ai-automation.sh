#!/usr/bin/env bash
# AI automation helpers for shell-first multi-agent workflows.

ai_stack_bootstrap() {
    local root="${1:-$HOME}"
    mkdir -p "$root/.bash_agents" "$root/.bash_crews" "$root/.bash_tools" \
        "$root/.bash_configs" "$root/.bash_logs" "$root/.bash_history" \
        "$root/.bash_documents" "$root/.bash_repos" "$root/.bash_bins"
    echo "Initialized AI stack directories under $root"
}

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

ai_agents_status() {
    echo "Agents: $(find "$HOME/.bash_agents" -maxdepth 1 -name '*.json' 2>/dev/null | wc -l)"
    echo "Crews:  $(find "$HOME/.bash_crews" -maxdepth 1 -name '*.json' 2>/dev/null | wc -l)"
    echo "Tools:  $(find "$HOME/.bash_tools" -maxdepth 1 -name '*.json' 2>/dev/null | wc -l)"
}

ai_agents_run_task() {
    if [ $# -lt 2 ]; then
        echo "Usage: ai_agents_run_task <crew.json> <task.md>";
        return 1;
    fi
    agent_hub run "$1" "$2"
}

ai_agents_plan_task() {
    if [ $# -lt 2 ]; then
        echo "Usage: ai_agents_plan_task <crew.json> <task.md>";
        return 1;
    fi
    agent_hub render "$1" "$2"
}

ai_agents_toggle_autonomy() {
    local state="${1:-on}"
    export AI_AUTONOMY_STATE="$state"
    echo "Autonomy switch set to: $state"
}

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
