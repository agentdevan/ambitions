# DAV Dynamic Adaptive Visual Dependency Graph

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

<!-- markdownlint-disable MD013 -->

Status: Active DAV dependency graph; implementation authority is per-batch only.
Date: 2026-05-03

## Topological Order

DAV01 source truth precedes all DAV work. DAV02 shared primitives precedes every surface batch. DAV03-DAV09 surface implementation precedes DAV10-DAV15 closeout and EB UI-heavy implementation. DAV10 motion/reduce-motion and DAV11 accessibility closeout precede DAV12 previews, DAV13 performance, DAV14 QA, and DAV15 closeout.

## Batch Dependencies

| Batch | Depends on | Blocks | Reason |
| --- | --- | --- | --- |
| DAV01 | EB32, PXEQ, PXOS/SI visual canon | DAV02-DAV15 | Source truth and surface map before implementation. |
| DAV02 | DAV01 | DAV03-DAV15 | Shared primitives, material, labels, motion helpers. |
| DAV03 | DAV02, Today/PXOS/PXEQ | EB Today UI work | Today rail/hero visual object. |
| DAV04 | DAV02, EB02/EB13/EB25/PXEQ | EB capture UI work | Capture composer and routing receipt visual object. |
| DAV05 | DAV02, Plan/PXOS/PXEQ | EB onboarding/plan UI work | Plan LifeShape/capacity visual object. |
| DAV06 | DAV02, Goals/PXOS/PXEQ | EB goal-related UI work | Goals Mission Control lanes. |
| DAV07 | DAV02, Trust/PXEQ/Profile compatibility | EB Trust/You UI work | You personal system center. |
| DAV08 | DAV02, EB07/EB13/EB25/PXEQ | EB memory/search UI work | Memory visuals remain source/control-bound. |
| DAV09 | DAV02, EB13/EB31/PXEQ | EB receipt/trust UI work | Trust receipt stack and evidence labels. |
| DAV10 | DAV03-DAV09 classified | DAV11-DAV15 | Motion meaning and Reduce Motion equivalence. |
| DAV11 | DAV03-DAV10 classified | DAV12-DAV15 | Visual accessibility evidence. |
| DAV12 | DAV02-DAV11 classified | DAV13-DAV15 | Preview fixtures and scenario gallery. |
| DAV13 | DAV02-DAV12 classified | DAV14-DAV15 | Rendering/battery risk review. |
| DAV14 | DAV02-DAV13 classified | DAV15 | PXEQ/product-experience QA. |
| DAV15 | DAV01-DAV14 resolved | EB35/EB38/EB40 closeout | DAV handoff and non-claims. |

## EB Blocking Rules

DAV03-DAV09 must run before EB03, EB14, EB20, EB26, EB33, or any UI-heavy EB implementation can pass product-experience Green. DAV10-DAV15 must run before EB35, EB38, and EB40 closeout claims.

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
