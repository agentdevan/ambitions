# Codex OS Batch Selection

Generated: 2026-05-18T08:33:11-04:00

Selected batch: EFC08
Prompt file: prompts/batches/EFC08.md
Lane: efc
Queue classification: executable_now

## Reason

Selected the safest live batch from current state: EFC08.

## Blockers

- queue_prerequisites:Complete prior batch EFC07.

## Preflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Postflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Run Command

make authorized-batch BATCH=EFC08 PROMPT=prompts/batches/EFC08.md
