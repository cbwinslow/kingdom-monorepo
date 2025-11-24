#!/usr/bin/env bash
set -euo pipefail

HUB_ROOT="${HUB_ROOT:-$HOME/.ai_hub}"

usage() {
  cat <<'USAGE'
agent_hub <command> [args]

Commands:
  register-agent <path>      Copy an agent config into $HOME/.bash_agents
  register-crew <path>       Copy a crew config into $HOME/.bash_crews
  register-toolset <path>    Copy a toolset config into $HOME/.bash_tools
  render <crew> <task>       Render an OpenAI/OpenRouter payload using crew+task
  run <crew> <task>          Render and submit the payload to OpenRouter
USAGE
}

ensure_dirs() {
  mkdir -p "$HUB_ROOT" "$HOME/.bash_agents" "$HOME/.bash_crews" "$HOME/.bash_tools"
}

copy_into() {
  local source_path="$1";
  local target_dir="$2";
  ensure_dirs
  local base
  base="$(basename "$source_path")"
  cp "$source_path" "$target_dir/$base"
  echo "Registered $(basename "$source_path") -> $target_dir"
}

resolve_file() {
  local name="$1"; shift
  local -n paths=$1
  for base in "${paths[@]}"; do
    if [ -f "$base/$name" ]; then
      echo "$base/$name"
      return 0
    fi
    if [ -f "$base/${name}.json" ]; then
      echo "$base/${name}.json"
      return 0
    fi
  done
  return 1
}

render_payload() {
  local crew_ref="$1"; local task_file="$2"
  python3 - "$crew_ref" "$task_file" <<'PY'
import json
import os
import sys
from pathlib import Path

crew_ref = Path(sys.argv[1])
task_file = Path(sys.argv[2])

search_paths = {
    "agents": os.environ.get("AGENT_SEARCH_PATHS", ":".join([
        "agents/openrouter-platform/configs/agents",
        str(Path.home() / ".bash_agents"),
    ])).split(":"),
    "toolsets": os.environ.get("AGENT_TOOLSET_PATHS", ":".join([
        "agents/openrouter-platform/configs/toolsets",
        str(Path.home() / ".bash_tools"),
    ])).split(":"),
    "tools": os.environ.get("AGENT_TOOL_PATHS", ":".join([
        "agents/openrouter-platform/configs/tools",
        str(Path.home() / ".bash_tools"),
    ])).split(":"),
    "workflows": os.environ.get("AGENT_WORKFLOW_PATHS", ":".join([
        "agents/openrouter-platform/configs/workflows",
        str(Path.home() / ".bash_crews"),
    ])).split(":"),
    "crews": os.environ.get("AGENT_CREW_PATHS", ":".join([
        "agents/openrouter-platform/configs/crews",
        str(Path.home() / ".bash_crews"),
    ])).split(":"),
}

def load_json(path: Path) -> dict:
    with path.open() as handle:
        return json.load(handle)


def resolve(name: str, kind: str) -> Path:
    for base in search_paths[kind]:
        candidate = Path(base) / name
        if candidate.exists():
            return candidate
        candidate_json = candidate.with_suffix(".json")
        if candidate_json.exists():
            return candidate_json
    raise SystemExit(f"Could not resolve {kind}: {name}")

crew_path = crew_ref if crew_ref.exists() else resolve(crew_ref.name, "crews")
crew = load_json(crew_path)

def agent_manifest(name: str) -> dict:
    path = resolve(name, "agents")
    manifest = load_json(path)
    manifest.setdefault("tools", [])
    return manifest

# Build toolset
if "toolset" not in crew:
    raise SystemExit("Crew missing toolset reference")

toolset_path = resolve(crew["toolset"], "toolsets")
toolset = load_json(toolset_path)

# Load workflow metadata
workflow_path = resolve(crew.get("workflow", ""), "workflows") if crew.get("workflow") else None
workflow = load_json(workflow_path) if workflow_path else {}

# Resolve tools
registry = []
for tool_name in toolset.get("tools", []):
    tool_path = resolve(tool_name, "tools")
    tool = load_json(tool_path)
    registry.append(tool)

agents = [agent_manifest(member["agent"]) for member in crew.get("members", [])]
if not agents:
    raise SystemExit("Crew has no members")

primary_model = agents[0].get("model", "openrouter/openai/gpt-4o-mini")

system_chunks = [
    crew.get("description", ""),
    f"Workflow: {workflow.get('name', 'unspecified')}",
    "Decision policy: " + crew.get("policies", {}).get("decision", "unspecified"),
    "Routing policy: " + crew.get("policies", {}).get("routing", "unspecified"),
]

payload = {
    "model": primary_model,
    "tools": registry,
    "messages": [
        {"role": "system", "content": "\n".join(filter(None, system_chunks))},
        {"role": "user", "content": task_file.read_text()},
    ],
    "metadata": {
        "crew": crew.get("name"),
        "workflow": workflow.get("name"),
        "members": [a.get("name") for a in agents],
    },
}

print(json.dumps(payload, indent=2))
PY
}

submit_payload() {
  local payload="$1"
  local endpoint="${OPENROUTER_BASE_URL:-https://openrouter.ai/api/v1/chat/completions}"
  if [ -z "${OPENROUTER_API_KEY:-}" ]; then
    echo "OPENROUTER_API_KEY is not set; printing payload only" >&2
    echo "$payload"
    return 1
  fi
  echo "$payload" | curl -sS "$endpoint" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${OPENROUTER_API_KEY}" \
    --data @-
}

main() {
  local cmd="${1:-}"; shift || true
  case "$cmd" in
    register-agent)
      copy_into "$1" "$HOME/.bash_agents";
      ;;
    register-crew)
      copy_into "$1" "$HOME/.bash_crews";
      ;;
    register-toolset)
      copy_into "$1" "$HOME/.bash_tools";
      ;;
    render)
      if [ $# -lt 2 ]; then usage; exit 1; fi
      render_payload "$1" "$2"
      ;;
    run)
      if [ $# -lt 2 ]; then usage; exit 1; fi
      local payload
      payload="$(render_payload "$1" "$2")"
      submit_payload "$payload"
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "$@"
