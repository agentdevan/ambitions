# Codex OS Batch Selection

Generated: 2026-05-18T08:01:34-04:00

Selected batch: EFC06
Prompt file: prompts/batches/EFC06.md
Lane: efc
Queue classification: executable_now

## Reason

Selected the safest live batch from current state: EFC06.

## Blockers

- queue_prerequisites:Complete prior batch EFC05.

## Preflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Postflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Run Command

make authorized-batch BATCH=EFC06 PROMPT=prompts/batches/EFC06.md
