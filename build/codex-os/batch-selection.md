# Codex OS Batch Selection

Generated: 2026-05-18T06:42:36-04:00

Selected batch: EFC01
Prompt file: prompts/batches/EFC01.md
Lane: efc
Queue classification: executable_now

## Reason

Selected the safest live batch from current state: EFC01.

## Blockers

- queue_prerequisites:Complete prior batch RHC06.

## Preflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Postflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Run Command

make authorized-batch BATCH=EFC01 PROMPT=prompts/batches/EFC01.md
