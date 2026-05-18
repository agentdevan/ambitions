# Codex OS Batch Selection

Generated: 2026-05-18T06:26:08-04:00

Selected batch: RHC06
Prompt file: prompts/batches/RHC06.md
Lane: rhc
Queue classification: executable_now

## Reason

Selected the safest live batch from current state: RHC06.

## Blockers

- queue_prerequisites:Complete prior batch RHC05.

## Preflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Postflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Run Command

make authorized-batch BATCH=RHC06 PROMPT=prompts/batches/RHC06.md
