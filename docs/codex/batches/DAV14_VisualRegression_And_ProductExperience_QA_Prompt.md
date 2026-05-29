# DAV14 VisualRegression And ProductExperience QA Prompt

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-authority-check**
> AMB-291 note: This batch/prompt is not standalone authority and must read the listed source-of-truth files before use.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite
> Dispositions: rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->
## Batch Identity
- Batch ID: DAV14
- Name: VisualRegression And ProductExperience QA
- Global order: 068
## Active 4.0 Status
Active DAV QA batch.
## Purpose
Run visual QA, PXEQ product-experience scorecard, anti-generic checks, and regression validation for DAV surfaces.
## Affected Surfaces
All DAV surfaces.
## Allowed Production Swift Files
Only narrow repair files named by QA evidence.
## Forbidden Files
Dependencies, persistence/schema, routes/raw values.
## Required Visual Primitives
All DAV primitives scored.
## Motion Rules
Motion meaning validated.
## Reduce Motion Equivalent
Scorecard dimension.
## Dynamic Type Requirements
Scorecard dimension.
## VoiceOver Requirements
Scorecard dimension.
## Preview Fixture Requirements
Scenario gallery referenced.
## Product-Experience Before/After Notes
Each surface must score 4/5 or be Yellow/Red.
## Validation Commands
DAV scorecard scripts, docs QA, focused tests/build.
## Green/Yellow/Red Criteria
Green: scorecard passes. Yellow: safe polish advisory. Red: technical pass but mediocre product experience.
## Stop Conditions
Stop on unresolved PXEQ Red.
## Commit Message
`Run DAV14 VisualRegression And ProductExperience QA`
## Next Safe Path
DAV15 closeout.

## Required Premium Experience Gates
- Inspect `docs/reference/visual-targets/ambitionsos-photo-matched/`.
- Cite Signature Experience and Transformative Motion docs.
- Pass SIG scorecard, PXEQ scorecard, DAV scorecard, Transformative Motion QA if motion is affected, accessibility evidence, Reduce Motion evidence, preview evidence, visual QA evidence, and photo-reference evidence.

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
