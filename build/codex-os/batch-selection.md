# Codex OS Batch Selection

Generated: 2026-05-17T23:14:53-04:00

Selected batch: FCP29
Prompt file: prompts/batches/FCP29.md
Lane: flagship
Queue classification: executable_now

## Reason

Selected the safest live batch from current state: FCP29.

## Blockers

- queue_prerequisites:Complete prior batch FCP28 and preserve accessibility, Dynamic Type, FVQ, and release-claim boundaries.

## Preflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Postflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Run Command

make authorized-batch BATCH=FCP29 PROMPT=prompts/batches/FCP29.md
