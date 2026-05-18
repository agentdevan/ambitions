# Codex OS Batch Selection

Generated: 2026-05-18T05:57:36-04:00

Selected batch: RHC04
Prompt file: prompts/batches/RHC04.md
Lane: rhc
Queue classification: executable_now

## Reason

Selected the safest live batch from current state: RHC04.

## Blockers

- queue_prerequisites:Complete prior batch RHC03.

## Preflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Postflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Run Command

make authorized-batch BATCH=RHC04 PROMPT=prompts/batches/RHC04.md
