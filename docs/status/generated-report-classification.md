# Generated Report Classification

Status: Active supporting cleanup classification  
Created: 2026-05-16  
Authority: Subordinate to `docs/truth/*`, `docs/status/README.md`, and current source/proof evidence.

This file classifies generated report artifacts so they do not masquerade as active product truth, implementation proof, release proof, or frontend canon.

## Rules

- Generated reports are not source truth.
- Generated reports are not release proof unless tied to current validation commands, logs, commit SHA, and release-truth boundaries.
- Generated frontend authority packets are snapshots/exports, not the active visual encyclopedia.
- Build reports may be retained for traceability, but stale reports should be regenerated or archived rather than treated as current truth.
- No deletion is approved by this file alone.

## Classification table

| Path family | Classification | Retention decision | Active replacement authority | Delete now? | Notes |
|---|---|---|---|---|---|
| `build/reports/frontend-authority-packets/*.md` | Generated frontend authority snapshots | Retain until reference-dependency scan decides archive/delete | `frontend/README.md`, `frontend/visual-encyclopedia/` active files | No | Useful for traceability; not active frontend canon. |
| `build/reports/frontend-authority-packets/*.json` | Generated frontend authority data snapshots | Retain until source-binding workflow decides regenerate-only policy | `frontend/visual-encyclopedia/` and generation scripts | No | Treat as generated evidence/data, not truth. |
| `build/reports/frontend-authority-preflight/*.json` | Generated preflight snapshots | Retain only if scripts consume them or recent proof references them | owning scripts and current command output | No | Candidate for regenerate-only classification later. |
| `build/reports/frontend-implementation-prompts/*` | Generated implementation prompt artifacts | Historical/process artifact | `docs/truth/CODEX_PROCESS_TRUTH.md`, direct user instruction, active prompt routing | No | Must not drive direct-main work unless refreshed. |
| `build/reports/frontend-drift-check.json` | Generated drift report | Supporting receipt if current; stale otherwise | current rerun output | No | Needs timestamp/commit awareness before use. |
| `build/reports/frontend-source-bindings.*` | Generated source binding report | Supporting traceability | current source and active frontend trace docs | No | May be useful for validation. |
| `build/reports/frontend-next-surface-queue.json` | Generated queue artifact | Historical/planning artifact unless current run proves otherwise | `frontend/README.md`, issue tracker, active user instruction | No | Do not treat as active backlog by itself. |
| `build/reports/*dry-run*.json` | Generated dry-run receipts | Historical/supporting proof-adjacent receipts | current rerun output and `docs/truth/RELEASE_TRUTH.md` | No | Retain until archive/delete scan. |
| `build/reports/*.json` not listed above | Unknown generated artifact | Needs family-level review | owning script or status doc | No | Classify before deleting. |

## Required metadata for future generated reports

Future retained generated reports should include or be accompanied by:

- generating command;
- commit SHA or ref;
- timestamp;
- source paths inspected;
- claim boundary;
- whether report is current, historical, or regenerate-only.

## Hard stops

- Do not delete generated reports from this classification alone.
- Do not cite generated reports as release proof without current validation evidence.
- Do not let generated prompt artifacts override direct user instruction or `docs/truth/*`.
- Do not treat frontend authority packets as active visual encyclopedia source truth.

## Next action

Phase 14 or a dedicated generated-artifact cleanup pass should perform inbound-reference checks before moving, deleting, or ignoring any generated report family.
