# Codex OS Batch Selection

Generated: 2026-05-18T10:22:56-04:00

Selected batch: EFC14
Prompt file: prompts/batches/EFC14.md
Lane: efc
Queue classification: executable_now

## Reason

Selected the safest live batch from current state: EFC14.

## Blockers

- queue_prerequisites:Complete prior batch EFC13.

## Preflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Postflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Run Command

make authorized-batch BATCH=EFC14 PROMPT=prompts/batches/EFC14.md
