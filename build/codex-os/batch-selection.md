# Codex OS Batch Selection

Generated: 2026-05-17T23:39:46-04:00

Selected batch: FCP30
Prompt file: prompts/batches/FCP30.md
Lane: flagship
Queue classification: executable_now

## Reason

Selected the safest live batch from current state: FCP30.

## Blockers

- queue_prerequisites:Earlier FCP object maturity, FVQ rendered proof, accessibility and release-claim boundaries.

## Preflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Postflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Run Command

make authorized-batch BATCH=FCP30 PROMPT=prompts/batches/FCP30.md
