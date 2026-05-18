# Codex OS Batch Selection

Generated: 2026-05-18T04:55:37-04:00

Selected batch: RHC01
Prompt file: prompts/batches/RHC01.md
Lane: rhc
Queue classification: executable_now

## Reason

Selected the safest live batch from current state: RHC01.

## Blockers

- queue_prerequisites:Complete prior batch PFC40.

## Preflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Postflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Run Command

make authorized-batch BATCH=RHC01 PROMPT=prompts/batches/RHC01.md
