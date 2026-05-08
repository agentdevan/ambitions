# Codex Batch Train Protocol

Status: Active batch-train efficiency and continuation protocol.  
Date: 2026-05-07  
Scope: Global batch, repair-loop, and restart discipline.

## Primary State

Use `.codex/reports/current-batch-train-state.md` as the authoritative train state unless a newer committed owner file explicitly supersedes it.

Use `.codex/state/active-batch.yml` as a compact efficiency mirror only. If the two disagree, update the mirror or trust the report.

## Continue-Until-Hard-Red Rule

For a user directive that says to continue the global batch train:

1. Read `AGENTS.md`.
2. Read `docs/codex/RESUME_GLOBAL_BATCH_TRAIN.md`.
3. Read `docs/codex/CODEX_OS_INDEX.md`.
4. Read `.codex/reports/current-batch-train-state.md`.
5. Read the next eligible batch prompt/manifest.
6. Read the matching route file.
7. Execute the smallest safe batch slice.
8. Validate.
9. Classify Green / Accepted Yellow / Red.
10. Commit one logical batch.
11. Continue only when the protocol allows.

Stop only on unrecoverable Red, unknown dirty tree, destructive conflict, missing required local/human proof, or repeated same-root Red after repair attempts.

## Repair Taxonomy

| Code | Class | Default action |
| --- | --- | --- |
| R1 | Formatting/lint | Repair in-place if safe. |
| R2 | Compile failure | Repair narrowed touched code only. |
| R3 | Test failure | Repair cause or mark Red if cause unknown. |
| R4 | Canon conflict | Stop or reconcile in owner docs. |
| R5 | File-boundary violation | Stop and report. |
| R6 | Unsupported claim | Remove/qualify claim and rerun claim gate. |
| R7 | Privacy/security/legal/release ambiguity | Stop as hard Red unless proof exists. |
| R8 | Missing human/device proof | Stop or park Yellow only if no claim depends on it. |

## Yellow Parking

Accepted Yellow must have:

- owner
- reason it is safe to continue
- affected paths
- future proof needed
- explicit no-claim boundary

Use `.codex/state/yellow-ledger.md` as a compact index. Keep full historical truth in batch reports.

## Hard Red Ledger

Hard Red entries must include:

- root cause
- command and raw log path when available
- touched files
- exact stop condition
- restart prompt or next safe investigation

Use `.codex/state/hard-red-ledger.md` as the compact index.

## No Double Work

Before adding a batch doc, gate, script, source truth file, or implementation primitive, search for existing owner docs, generated scaffold, prompts, skills, boards, scripts, and indexes.

If an owner exists, extend or reconcile instead of duplicating.

## Closeout Format

```text
Result: Green / Accepted Yellow / Red
Batch:
Scope:
Files changed:
Files intentionally not changed:
Commands:
Exit codes:
Raw logs:
Gates:
Claims not made:
Next eligible batch:
```
