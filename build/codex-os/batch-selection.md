# Codex OS Batch Selection

Generated: 2026-05-18T00:42:41-04:00

Selected batch: PFC33
Prompt file: prompts/batches/PFC33.md
Lane: platform
Queue classification: executable_now

## Reason

Selected the safest live batch from current state: PFC33.

## Blockers

- queue_prerequisites:Relevant PK/FCP/FVQ/EFC proof and human/legal/device gates where named.

## Preflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Postflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Run Command

make authorized-batch BATCH=PFC33 PROMPT=prompts/batches/PFC33.md
