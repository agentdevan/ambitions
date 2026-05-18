# Codex OS Batch Selection

Generated: 2026-05-18T11:51:43-04:00

Selected batch: EFC18
Prompt file: prompts/batches/EFC18.md
Lane: efc
Queue classification: executable_now

## Reason

Selected the safest live batch from current state: EFC18.

## Blockers

- queue_prerequisites:Complete prior batch EFC17.

## Preflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Postflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Run Command

make authorized-batch BATCH=EFC18 PROMPT=prompts/batches/EFC18.md
