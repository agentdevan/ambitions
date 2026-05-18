# Codex OS Batch Selection

Generated: 2026-05-18T03:22:01-04:00

Selected batch: PFC37
Prompt file: prompts/batches/PFC37.md
Lane: platform
Queue classification: executable_now

## Reason

Selected the safest live batch from current state: PFC37.

## Blockers

- queue_prerequisites:Complete prior batch PFC36.

## Preflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Postflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Run Command

make authorized-batch BATCH=PFC37 PROMPT=prompts/batches/PFC37.md
