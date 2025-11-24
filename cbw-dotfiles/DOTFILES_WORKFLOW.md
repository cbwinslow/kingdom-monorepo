# Dotfiles + Agent Stack Workflow

This workflow keeps dotfiles, SSH material, AI agent configs, and shell utilities synchronized and searchable.

## Directory conventions (home)
- `~/.bash_agents` — registered agent manifests (OpenAI/OpenRouter compatible JSON).
- `~/.bash_crews` — crew definitions, workflows, and routing policies.
- `~/.bash_tools` — individual tools or toolset bundles.
- `~/.bash_configs` — misc configuration (ssh config snippets, env templates).
- `~/.bash_bins` — executable scripts and binaries added to `$PATH`.
- `~/.bash_documents` — docs, specs, and prompts used by agents.
- `~/.bash_logs` — payloads, votes, and run telemetry.
- `~/.bash_history` — curated shell history exports/backups.
- `~/.bash_repos` — cloned repos that back your shell/agent system.

## Setup
1. Source `cbw-dotfiles/bash/profiles/ai_shell.sh` from your `~/.bashrc` or start a new shell with it.
2. Run `ai_stack_bootstrap` to create the above directories.
3. Run `ai_stack_sync <repo_root>` to copy curated configs from the repo into your home directories.

## SSH workflow
- Store SSH config snippets in `~/.bash_configs/ssh/` and symlink into `~/.ssh/config.d/`.
- Keep keys outside the repo; point to them via `IdentityFile` entries in the snippets.
- Add helper functions (e.g., `ssh_workspace`) to `~/.bash_bins/` or `cbw-dotfiles/bash/functions` to keep commands versioned.

## Agent + tool management
- Register curated agent manifests with `agent_hub register-agent <path>`; the script copies them into `~/.bash_agents`.
- Register crew and toolset configs similarly (`register-crew`, `register-toolset`).
- Use `ai_agents_status` to verify counts and `ai_shell_scan` to search for functions or tool definitions.

## Backups and portability
- Periodically archive `~/.bash_agents`, `~/.bash_crews`, `~/.bash_tools`, and `~/.bash_configs` into `~/.bash_repos/backups/`.
- Commit reusable functions to this repo (`cbw-dotfiles/bash/functions`) to keep environments reproducible.

## Autonomy switch
- Toggle autonomous multi-agent behavior via `ai_agents_toggle_autonomy on|off`.
- Votes and consensus snapshots are written to `~/.bash_logs` for auditing.
