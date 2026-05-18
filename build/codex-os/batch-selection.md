# Codex OS Batch Selection

Generated: 2026-05-18T02:19:09-04:00

Selected batch: PFC36
Prompt file: prompts/batches/PFC36.md
Lane: platform
Queue classification: executable_now

## Reason

Selected the safest live batch from current state: PFC36.

## Blockers

- queue_prerequisites:Complete prior batch PFC35.

## Preflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Postflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Run Command

make authorized-batch BATCH=PFC36 PROMPT=prompts/batches/PFC36.md
