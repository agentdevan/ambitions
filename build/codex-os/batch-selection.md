# Codex OS Batch Selection

Generated: 2026-05-18T05:14:59-04:00

Selected batch: RHC02
Prompt file: prompts/batches/RHC02.md
Lane: rhc
Queue classification: executable_now

## Reason

Selected the safest live batch from current state: RHC02.

## Blockers

- queue_prerequisites:Complete prior batch RHC01.

## Preflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Postflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Run Command

make authorized-batch BATCH=RHC02 PROMPT=prompts/batches/RHC02.md
