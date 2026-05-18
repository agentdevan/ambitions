# Codex OS Batch Selection

Generated: 2026-05-17T22:30:47-04:00

Selected batch: FCP28
Prompt file: prompts/batches/FCP28.md
Lane: flagship
Queue classification: executable_now

## Reason

Selected the safest live batch from current state: FCP28.

## Blockers

- queue_prerequisites:Complete prior batch FCP27 and preserve FVQ/accessibility/release-claim boundaries.

## Preflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Postflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Run Command

make authorized-batch BATCH=FCP28 PROMPT=prompts/batches/FCP28.md
