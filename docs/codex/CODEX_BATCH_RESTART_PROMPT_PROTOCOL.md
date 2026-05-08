# Codex Batch Restart Prompt Protocol

Status: Active restart prompt protocol.
Date: 2026-05-07

## Purpose

Restart prompts let a future Codex session continue from repo evidence instead of chat memory or stale compacted summaries.

## Required Prompt Sections

- Repo and branch.
- Exact read order.
- Selected route(s).
- Active batch or hard Red/Yellow repair target.
- Allowed files.
- Forbidden files.
- Current dirty-tree expectations.
- Commands already run and raw log paths.
- Gate state.
- Claims not allowed.
- First next action.
- Stop conditions.

Use `.codex/templates/global-batch-resume-prompt.md`, `.codex/templates/hard-red-restart-prompt.md`, or `.codex/templates/yellow-repair-prompt.md` as the starting point.
