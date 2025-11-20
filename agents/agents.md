# Agents Operating Guide

_Last updated: 2025-11-19 20:18 UTC by AI Agent (ChatGPT)_

This guide governs how agents operate within the **agents/** workspace. It explains how to use **rules.md**, maintain **tasks.md**, and manage the supporting project journals and summaries. All agents must follow these instructions for every activity inside this directory tree.

## Core References
- **rules.md** — Canonical operating rules. Read before each work session; update whenever rules change or new patterns emerge.
- **tasks.md** — The live, versioned task ledger ("income statement"). Every task must include microgoals, completion criteria, required tests, sign-off, and timestamps.
- **journal.md** — Append-only reasoning and communication log. Record decisions, rationales, inter-agent dialogue, test results, and notable events in chronological order.
- **project_summary.md** — High-level snapshot of the current project intent, scope, and status. Keep aligned with **features.md** and **srs.md** if present.

## Required Behaviors
1. **Avoid task drift:** Begin each work block by reviewing **tasks.md** and the active task. Restate the current task in the journal before making changes.
2. **Logging discipline:**
   - Log all reasoning dialogue, decisions, and inter-agent communications to **journal.md** as append-only entries.
   - Summaries of tests and outcomes belong both in **tasks.md** (per task) and **journal.md** (chronological log).
3. **Version safety:**
   - Treat **rules.md**, **tasks.md**, **project_summary.md**, **features.md**, **srs.md**, and **journal.md** as critical artifacts. Never delete them; update with clear timestamps and sign-offs.
   - Back up **tasks.md** changes to git with meaningful commits.
4. **Rules updates:** When **rules.md** changes, note the change and rationale in **journal.md**, and ensure **agents.md** references any new requirements.
5. **Task hygiene:**
   - Each task entry in **tasks.md** must remain measurable, repeatable, and linked to completion tests (pytest, unit tests, Jest, integration checks, or documented verification steps).
   - Capture agent sign-off and timestamps for each task update.
6. **Communication etiquette:** All sub-agent or inter-agent coordination must be recorded in **journal.md**, including decisions, assumptions, and action items.

## File Handling
- **journal.md** is append-only; never rewrite or delete prior content.
- **rules.md**, **tasks.md**, **project_summary.md**, **features.md**, and **srs.md** are editable but must retain historical context via timestamps and git history.
- When starting a new project from this starter kit, copy this folder and immediately update timestamps, owners, and scope notes in all control files.

## Update Cadence
- **journal.md:** After any notable reasoning step, decision, or test execution.
- **tasks.md:** Whenever task scope, microgoals, or status changes; at minimum after each meaningful work session.
- **rules.md:** As soon as operating norms change or gaps are discovered.
- **agents.md:** After changes to process definitions or references to control files.

Failure to comply with these instructions should be recorded in **journal.md** with corrective actions.
