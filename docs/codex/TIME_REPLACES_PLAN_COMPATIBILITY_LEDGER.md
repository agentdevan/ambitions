# Time Replaces Plan Compatibility Ledger

<!-- markdownlint-disable MD013 -->

Status: Active compatibility ledger.
Date: 2026-05-08

## Active Product Truth

The active flagship top-level IA is:

```text
Today / Goals / Capture / Time / You
```

`Plan` is not an active top-level user-facing destination. Time owns LifeShape, schedule, availability, capacity, pressure, protected time, and reflow context.

## Allowed Plan Compatibility Seams

Plan may remain only as:

- internal route/raw-value compatibility such as `.plan`
- `PlanScreen`, `planNavigation()`, and `Native/Ambitions/Features/Plan/` owner paths until a scoped AFI migration batch proves a safe rename
- App Intent, widget, notification, import/export, persistence, test, or deep-link compatibility where a rename could break external or saved state
- contextual/action language such as Adjust plan, planning defaults, plan the week, review plan, and plan context
- historical evidence in old docs, reports, logs, and completed batch prompts

## Disallowed Plan Claims

Active docs and scripts must not describe Plan as a current top-level tab or destination. Active queue docs must use Time for the user-facing surface.

## Files Updated In GQ01

- `docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md`
- `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json`
- `scripts/global-train-next-batch.sh`
- `scripts/global-train-status-summary.sh`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `.codex/state/active-batch.yml`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `docs/audits/gq01-global-queue-maturity-report.md`
- `docs/audits/gq01-refactor-maturity-assessment.md`

## Files Intentionally Not Updated

- `Native/Ambitions/Features/Plan/**`, `.plan`, `PlanScreen`, `planNavigation()`: internal compatibility seams requiring focused route/raw-value proof before rename.
- historical docs under `docs/canon/`, `docs/audits/`, `docs/handoff/`, `.codex/logs/`: evidence history, not active top-level guidance.
- completed batch prompts that use Plan in their historical title or owner seam: retained as evidence unless a future RHC batch proves safe deletion.

## Validation Run

GQ01 ran the required Plan/Time scan. Remaining active-surface hits are either Time truth, allowed compatibility seams, source-code compatibility, or historical evidence. `docs/implementation-backlog.md` remains a stale active-looking doc and is Yellow-owned by RHC04 because deleting or rewriting it requires a broader reference cleanup than GQ01 can safely prove without risking traceability.
