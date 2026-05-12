# Codex Multi-Agent Build System (OBS)

## Purpose

Define a local-only agent orchestration model for batch execution support. It is an **operator coordination layer**, not app runtime code.

## Role model

`tools/openai/config/codex_agent_roles.json` defines these roles:

- Implementation Agent
- Focused Test Agent
- State Advancement Agent
- Claim Safety Agent
- Prompt Repair Agent
- Batch Report Agent
- Visual Critic Agent
- Repo Intelligence Agent
- Launch Docs Agent

## Operating contract

Each role is constrained by:

1. Files and scope.
2. Required checks before handoff.
3. Hard-Red conditions.

## Scope rules

- Reads and writes only allowed OBS scope artifacts.
- No Native/Ambitions runtime edits.
- No network calls from role tools in this batch.
- No dependency on hosted model output at runtime.

## Validation contract

- `scripts/openai-build-suite-validate.py` must remain green for repository policy checks.
- `scripts/openai-build-suite-dry-run.py` should complete with local JSON outputs.
- `make prompt-audit` and claim scans are expected to stay conservative and reject unsupported completion claims.
