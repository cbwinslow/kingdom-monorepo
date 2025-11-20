# Operating Rules for AI Agents

_Last updated: 2025-11-19 20:18 UTC by AI Agent (ChatGPT)_

These rules complement the base operating standards and govern all agent activity within the **agents/** directory. Follow them precisely to preserve auditability, avoid task drift, and ensure reliable delivery.

## 1. Task Alignment and Drift Prevention
- Begin every work session by reading the active task entry in **tasks.md** and restating it in **journal.md**.
- Reconfirm the task focus after any interruption, context switch, or dependency block.
- If scope changes, update **tasks.md** and log the rationale in **journal.md** before proceeding.

## 2. Logging and Journaling
- **journal.md** is append-only. Never delete or rewrite previous entries.
- Record all reasoning dialogue, design decisions, inter-agent communications, and external coordination (SSH, MCP servers, API calls) in **journal.md** with timestamps and agent identifiers.
- Capture summaries of executed commands, tests, and notable outcomes. Detailed logs may reference external artifacts when size is a concern.

## 3. Task Ledger Discipline (tasks.md)
- Every task must include:
  - A clear description and scope boundary.
  - Microgoals with measurable completion criteria.
  - Associated tests (pytest, unit tests, integration checks, Jest, or manual verification steps) mapped to each microgoal.
  - Completion proof: test results, links to logs, or verification notes.
  - Agent sign-off and timestamp for each status change.
- Keep **tasks.md** current; updates must be committed to git promptly.
- Store backups through normal git commits; never discard historical entries.

## 4. Rule and Process Maintenance
- Update this file whenever a gap or improvement is identified. Note changes in **journal.md** and summarize them in **agents.md**.
- Keep the rules compatible with **srs.md**, **features.md**, and **project_summary.md**. Resolve conflicts by clarifying precedence in **journal.md** and adjusting this file.
- At least once per milestone or major change, review and refresh these rules.

## 5. Communication Protocols
- All sub-agent and inter-agent communication must be logged in **journal.md** with participants, medium, decisions, and follow-up actions.
- External connections (SSH, MCP servers, third-party APIs) require noting endpoints, purpose, and data sensitivity in **journal.md** before use.
- When sharing context with other agents, reference the relevant **tasks.md** entry and current rule version.

## 6. File Permissions and Handling
- **journal.md:** Append-only. Use chronological entries with timestamps and agent names.
- **rules.md**, **tasks.md**, **agents.md**, **project_summary.md**, **srs.md**, and **features.md:** Editable with clear timestamps and sign-offs; never delete these files.
- Markdown control files should remain human-readable, concise, and version-controlled. Prefer additive edits over rewrites.

## 7. Testing and Evidence
- For each microgoal, define the tests required to demonstrate completion. Include command examples (e.g., `pytest path::test_case`, `npm test -- component`, integration scripts) or explicit manual checks with acceptance criteria.
- Record executed test commands and outcomes in **journal.md**, and summarize them in **tasks.md** per task.
- When tests are blocked, document the blocker, interim validation, and next steps in both **journal.md** and **tasks.md**.

## 8. Update Frequency and Reminders
- **journal.md:** After reasoning steps, communications, test executions, and status changes.
- **tasks.md:** Whenever microgoals, criteria, or status change; at least once per working session.
- **rules.md:** Upon discovering process improvements or inconsistencies; minimum once per milestone review.
- **agents.md:** After process or reference updates to ensure onboarding clarity.
- Agents should self-remind of the active task at least once per major edit session to avoid drift.

## 9. Startup Kit Usage
- When cloning or initializing a new project, copy this **agents/** bundle. Immediately update timestamps, ownership, and project context in all control files.
- Ensure **project_summary.md** reflects the current initiative and aligns with **srs.md** and **features.md** as the high-level balance sheet for intended outcomes.
- Use **tasks.md** as the operational cash-flow statement: plan, execute, and verify progress with measurable steps.

Non-compliance must be recorded in **journal.md** with corrective actions and responsible agents.
