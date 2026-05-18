# Codex OS Batch Selection

Generated: 2026-05-18T09:27:45-04:00

Selected batch: EFC11
Prompt file: prompts/batches/EFC11.md
Lane: efc
Queue classification: executable_now

## Reason

Selected the safest live batch from current state: EFC11.

## Blockers

- queue_prerequisites:Complete prior batch EFC10.

## Preflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Postflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Run Command

make authorized-batch BATCH=EFC11 PROMPT=prompts/batches/EFC11.md
