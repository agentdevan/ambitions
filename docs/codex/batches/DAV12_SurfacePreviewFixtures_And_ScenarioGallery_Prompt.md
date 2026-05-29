# DAV12 SurfacePreviewFixtures And ScenarioGallery Prompt

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->
## Batch Identity
- Batch ID: DAV12
- Name: SurfacePreviewFixtures And ScenarioGallery
- Global order: 066
## Active 4.0 Status
Active DAV preview fixture batch.
## Purpose
Create preview fixtures for calm normal day, overloaded day, recovery day, empty capture, routed capture, blocked step, Still Counts, goal proof/blocker, stale/rejected/private memory, high Dynamic Type, and Reduce Motion.
## Affected Surfaces
All DAV surfaces and PreviewSupport.
## Allowed Production Swift Files
Native/Ambitions/PreviewSupport/**, Sources/Previews/**, preview-only code in DAV components.
## Forbidden Files
Persistence/schema, routes/raw values, dependencies.
## Required Visual Primitives
All DAV primitives represented.
## Motion Rules
Preview motion must have Reduce Motion variant.
## Reduce Motion Equivalent
Preview included.
## Dynamic Type Requirements
Preview included.
## VoiceOver Requirements
Fixture labels named where possible.
## Preview Fixture Requirements
All named scenarios.
## Product-Experience Before/After Notes
Record preview coverage.
## Validation Commands
`scripts/dav-preview-fixture-check.sh || true`; focused build.
## Green/Yellow/Red Criteria
Green: fixture coverage exists. Yellow: screenshot capture deferred. Red: missing major scenarios.
## Stop Conditions
Stop on fake data claims.
## Commit Message
`Run DAV12 SurfacePreviewFixtures And ScenarioGallery`
## Next Safe Path
DAV13 performance.

## Required Premium Experience Gates
- Inspect `docs/reference/visual-targets/ambitionsos-photo-matched/`.
- Cite Signature Experience and Transformative Motion docs where scenarios include motion.
- Pass SIG scorecard, PXEQ scorecard, DAV scorecard, Transformative Motion QA if motion scenarios are added, accessibility evidence, Reduce Motion evidence, preview evidence, and photo-reference evidence.

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
