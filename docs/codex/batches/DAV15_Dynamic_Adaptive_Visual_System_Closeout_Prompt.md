# DAV15 Dynamic Adaptive Visual System Closeout Prompt

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-authority-check**
> AMB-291 note: This batch/prompt is not standalone authority and must read the listed source-of-truth files before use.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, rewrite-authority-before-proof
> Dispositions: rewrite-authority-before-proof, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->
## Batch Identity
- Batch ID: DAV15
- Name: Dynamic Adaptive Visual System Closeout
- Global order: 069
## Active 4.0 Status
Active DAV closeout batch.
## Purpose
Close DAV train evidence, Yellow advisories, Red repairs, non-claims, validation, next EB gates, and handoff.
## Affected Surfaces
All DAV surfaces.
## Allowed Production Swift Files
None unless closing a named Yellow repair with proof.
## Forbidden Files
Dependencies, persistence/schema, routes/raw values, release files.
## Required Visual Primitives
All implemented primitives listed.
## Motion Rules
No new motion.
## Reduce Motion Equivalent
Closeout evidence required.
## Dynamic Type Requirements
Closeout evidence required.
## VoiceOver Requirements
Closeout evidence required.
## Preview Fixture Requirements
Closeout evidence required.
## Product-Experience Before/After Notes
Summarize train-level impact.
## Validation Commands
Full DAV validation pack, focused build/tests, docs QA, gate check.
## Green/Yellow/Red Criteria
Green: all prior DAV batches resolved. Yellow: safe deferred proof. Red: unresolved visual/accessibility/performance/release-claim blocker.
## Stop Conditions
Stop on false release/public conformance claim.
## Commit Message
`Complete Dynamic Adaptive visual QA closeout`
## Next Safe Path
Resume EB implementation lanes with DAV/PXEQ gates.

## Required Premium Experience Gates
- Inspect `docs/reference/visual-targets/ambitionsos-photo-matched/`.
- Cite Signature Experience and Transformative Motion docs.
- Pass SIG scorecard, PXEQ scorecard, DAV scorecard, Transformative Motion QA, accessibility evidence, Reduce Motion evidence, preview evidence, visual QA, performance evidence, and photo-reference evidence before closeout claims.

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
