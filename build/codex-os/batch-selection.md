# Codex OS Batch Selection

Generated: 2026-05-18T07:33:17-04:00

Selected batch: EFC04
Prompt file: prompts/batches/EFC04.md
Lane: efc
Queue classification: executable_now

## Reason

Selected the safest live batch from current state: EFC04.

## Blockers

- queue_prerequisites:Complete prior batch EFC03.

## Preflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Postflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Run Command

make authorized-batch BATCH=EFC04 PROMPT=prompts/batches/EFC04.md
