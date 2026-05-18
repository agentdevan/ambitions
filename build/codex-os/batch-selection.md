# Codex OS Batch Selection

Generated: 2026-05-18T08:21:08-04:00

Selected batch: EFC07
Prompt file: prompts/batches/EFC07.md
Lane: efc
Queue classification: executable_now

## Reason

Selected the safest live batch from current state: EFC07.

## Blockers

- queue_prerequisites:Complete prior batch EFC06.

## Preflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Postflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Run Command

make authorized-batch BATCH=EFC07 PROMPT=prompts/batches/EFC07.md
