# DAV01 Dynamic Visual Source Truth And Surface Map Prompt

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-22647572, AMB28-same_source_file_targeted_by_multiple_active_batches-32178151, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->
## Batch Identity
- Batch ID: DAV01
- Name: Dynamic Visual Source Truth And Surface Map
- Global order: 055
## Active 4.0 Status
Active Ambitions 4.0 DAV implementation train. Docs/source mapping only; no app behavior unless a later DAV batch implements SwiftUI.
## Purpose
Map source truth, affected surfaces, primary visual objects, allowed Swift owners, dependencies, and validation lanes before visual implementation.
## Affected Surfaces
Today, Goals, Capture, Plan, You, Memory, Trust/Receipts, previews.
## Allowed Production Swift Files
None for DAV01.
## Forbidden Files
Native/**, Sources/**, AppUI/**, project.yml, persistence/schema, routes/raw values, enum/raw values, dependencies, workflows, signing.
## Required Visual Primitives
Name primitives and owner paths for DAV02.
## Motion Rules
No motion implementation; define allowed motion only.
## Reduce Motion Equivalent
Map required equivalents per surface.
## Dynamic Type Requirements
Map text hierarchy and large-type evidence.
## VoiceOver Requirements
Map reading order and labels.
## Preview Fixture Requirements
Define required scenario fixtures.
## Product-Experience Before/After Notes
Record current surface baseline and target impact.
## Validation Commands
`git status --short`; `git diff --check`; `scripts/dav-visual-primitive-inventory.sh || true`; `scripts/batch-train-gate-check.sh || true`.
## Green/Yellow/Red Criteria
Green: source map complete. Yellow: implementation deferred. Red: duplicate canon or unsafe Swift scope.
## Stop Conditions
Stop on dirty unknown tree, source conflict, or forbidden file request.
## Commit Message
`Run DAV01 Dynamic Visual Source Truth And Surface Map`
## Next Safe Path
DAV02 reusable primitives.

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
