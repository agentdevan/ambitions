# Codex OS Batch Selection

Generated: 2026-05-18T05:41:29-04:00

Selected batch: RHC03
Prompt file: prompts/batches/RHC03.md
Lane: rhc
Queue classification: executable_now

## Reason

Selected the safest live batch from current state: RHC03.

## Blockers

- queue_prerequisites:Complete prior batch RHC02.

## Preflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Postflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Run Command

make authorized-batch BATCH=RHC03 PROMPT=prompts/batches/RHC03.md
