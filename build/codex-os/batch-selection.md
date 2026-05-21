# Codex OS Batch Selection

Generated: 2026-05-20T22:43:38-04:00

Selected batch: IOS26-T00-B01
Prompt file: prompts/batches/IOS26-T00-B01-repo-source-inventory.md
Lane: ios
Queue classification: ios26_runnable

## Reason

Selected the safest live batch from current state: IOS26-T00-B01.

## Blockers

- None

## Preflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Postflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Run Command

make authorized-batch BATCH=IOS26-T00-B01 PROMPT=prompts/batches/IOS26-T00-B01-repo-source-inventory.md
