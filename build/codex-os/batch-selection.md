# Codex OS Batch Selection

Generated: 2026-05-17T23:55:08-04:00

Selected batch: PFC31
Prompt file: prompts/batches/PFC31.md
Lane: platform
Queue classification: executable_now

## Reason

Selected the safest live batch from current state: PFC31.

## Blockers

- queue_prerequisites:Relevant PK/FCP/FVQ/EFC proof and human/legal/device gates where named.

## Preflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Postflight Commands

- `python3 scripts/governance/ambitions-repo-doctor.py`
- `python3 scripts/codex-os/ambitions-codex-os-sync-governance.py`

## Run Command

make authorized-batch BATCH=PFC31 PROMPT=prompts/batches/PFC31.md
