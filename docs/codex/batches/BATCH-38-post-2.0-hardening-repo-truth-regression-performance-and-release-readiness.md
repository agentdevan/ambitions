<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: stale_or_unknown_active_status
> Prior recommended actions: Expedite
> Candidate references: AMB28-stale_or_unknown_active_status-33242065

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-authority-check**
> AMB-291 note: This batch/prompt is not standalone authority and must read the listed source-of-truth files before use.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, status-expedite
> Dispositions: clarify-status-before-use, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
﻿# Batch 38 â€” Post-2.0 Hardening 04 / Repo Truth, Regression, Performance, and Release Readiness

## Status

Completed for planning purposes
## Goal

Close repo truth drift, regression gaps, preview/docs/copy truth issues, performance-risk review, and release-readiness debt as the consolidation pass for the post-2.0 whole-repo/app hardening wave.

This batch is the fourth and final planned step of the current hardening wave. It consolidates the product after shell truth, external truth, and secondary-surface productization have been stabilized. The separate UI/UX excellence wave should be planned after this hardening wave, not inside it.

## In Scope

- repo truth drift cleanup
- preview, docs, and copy truth alignment
- regression-gap review and hardening
- performance-risk review
- release-readiness debt reduction
- hardening-wave consolidation across the repo and app

## Out Of Scope

- net-new product or intelligence features
- broad visual redesign
- speculative future-wave planning beyond this hardening sequence
- creation of Batch 39 or later in this pass

## Dependency Rules

- do not start this batch until Batches 35 through 37 are stable
- use this batch as the consolidation and release-readiness pass rather than an overflow bucket
- keep the later UI/UX excellence wave out of this batch

## Exit Criteria

- repo truth drift is materially reduced
- preview/docs/copy truth is aligned with shipped behavior
- regression and performance risks are reviewed and bounded
- release-readiness debt is reduced to a truthful, operationally clear state
- the repo is ready for a separate UI/UX excellence planning wave after hardening

## Validation

- docs/control-file truth checks for touched planning files
- targeted regression/performance/release-readiness verification appropriate to the eventual implementation scope
- do not mark this batch completed until the hardening-wave consolidation state is validated truthfully

## Completion Rule

Batch 38 was completed for planning purposes before the post-Batch-60 Ambitions 2.0 canon. Historical completion criteria were: the current hardening wave has been consolidated truthfully enough that a separate UI/UX excellence wave can begin without reopening shell, trust, or repo-truth fundamentals.

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
