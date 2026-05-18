# Codex OS Batch Selection

Generated: 2026-05-18T03:44:22-04:00

Selected batch: PFC38
Prompt file: prompts/batches/PFC38.md
Lane: platform
Queue classification: executable_now

## Reason

Selected the safest live batch from current state: PFC38.

## Blockers

- queue_prerequisites:Complete prior batch PFC37.

## Preflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Postflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Run Command

make authorized-batch BATCH=PFC38 PROMPT=prompts/batches/PFC38.md
