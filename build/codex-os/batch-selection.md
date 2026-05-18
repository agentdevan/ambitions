# Codex OS Batch Selection

Generated: 2026-05-18T09:13:30-04:00

Selected batch: EFC10
Prompt file: prompts/batches/EFC10.md
Lane: efc
Queue classification: executable_now

## Reason

Selected the safest live batch from current state: EFC10.

## Blockers

- queue_prerequisites:Complete prior batch EFC09.

## Preflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Postflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Run Command

make authorized-batch BATCH=EFC10 PROMPT=prompts/batches/EFC10.md
