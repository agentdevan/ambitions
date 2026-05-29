# Time Replaces Plan Compatibility Ledger

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

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

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
