# Codex OS Batch Selection

Generated: 2026-05-18T10:03:25-04:00

Selected batch: EFC13
Prompt file: prompts/batches/EFC13.md
Lane: efc
Queue classification: executable_now

## Reason

Selected the safest live batch from current state: EFC13.

## Blockers

- queue_prerequisites:Complete prior batch EFC12.

## Preflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Postflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Run Command

make authorized-batch BATCH=EFC13 PROMPT=prompts/batches/EFC13.md
