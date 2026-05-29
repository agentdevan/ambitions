# DAV11 DynamicType VoiceOver And VisualAccessibility Closeout Prompt

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
- Batch ID: DAV11
- Name: DynamicType VoiceOver And VisualAccessibility Closeout
- Global order: 065
## Active 4.0 Status
Active DAV accessibility evidence batch.
## Purpose
Close Dynamic Type, VoiceOver, contrast, tap target, non-color meaning, and Reduce Motion evidence for DAV surfaces.
## Affected Surfaces
All implemented DAV surfaces.
## Allowed Production Swift Files
Narrow accessibility fixes in DAV-touched files and preview support.
## Forbidden Files
Routes/raw values, persistence/schema, dependencies.
## Required Visual Primitives
All implemented DAV primitives.
## Motion Rules
No new motion except accessibility repair.
## Reduce Motion Equivalent
Verify every motion state.
## Dynamic Type Requirements
High Dynamic Type evidence.
## VoiceOver Requirements
Reading order and labels evidence.
## Preview Fixture Requirements
High Dynamic Type and accessibility states.
## Product-Experience Before/After Notes
Record accessibility impact.
## Validation Commands
DAV accessibility scripts and focused build/tests.
## Green/Yellow/Red Criteria
Green: evidence complete. Yellow: human device proof deferred. Red: blocker.
## Stop Conditions
Stop on public conformance claim or blocker.
## Commit Message
`Run DAV11 DynamicType VoiceOver And VisualAccessibility Closeout`
## Next Safe Path
DAV12 previews.

## Required Premium Experience Gates
- Inspect `docs/reference/visual-targets/ambitionsos-photo-matched/`.
- Cite Signature Experience docs.
- Pass SIG scorecard, PXEQ scorecard, DAV scorecard, accessibility evidence, Reduce Motion evidence, preview evidence, and photo-reference evidence.

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
