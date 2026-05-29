# DAV10 AdaptiveMotion ReduceMotion And StateTransitions Prompt

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-58973986, AMB28-same_surface_multiple_active_batches-62616276

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
- Batch ID: DAV10
- Name: AdaptiveMotion ReduceMotion And StateTransitions
- Global order: 064
## Active 4.0 Status
Active DAV closeout/implementation batch for motion helpers.
## Purpose
Validate and refine reduce-motion-aware animations, subtle pulse, soft reveal, rail progress, receipt confirmation, and hero expansion transitions.
## Affected Surfaces
All DAV surfaces.
## Allowed Production Swift Files
Sources/Components/** and narrow surface files touched by prior DAV batches.
## Forbidden Files
Persistence/schema, routes/raw values, dependencies.
## Required Visual Primitives
Motion helpers attached to DAV primitives.
## Motion Rules
No infinite motion by default, no multi-axis/spinning/vortex motion.
## Reduce Motion Equivalent
Required for every meaningful transition.
## Dynamic Type Requirements
Motion must not depend on text size.
## VoiceOver Requirements
Motion cannot be the only state cue.
## Preview Fixture Requirements
Reduce Motion states.
## Product-Experience Before/After Notes
Record motion meaning.
## Validation Commands
`scripts/dav-reduce-motion-check.sh || true`; focused build/tests.
## Green/Yellow/Red Criteria
Green: all motion has meaning and fallback. Yellow: visual polish deferred. Red: decorative or accessibility-blocking motion.
## Stop Conditions
Stop on motion-only meaning.
## Commit Message
`Run DAV10 AdaptiveMotion ReduceMotion And StateTransitions`
## Next Safe Path
DAV11 accessibility closeout.

## Required Premium Experience Gates
- Inspect `docs/reference/visual-targets/ambitionsos-photo-matched/`.
- Cite Signature Experience and Transformative Motion docs.
- Pass SIG scorecard, PXEQ scorecard, DAV scorecard, Transformative Motion QA, accessibility evidence, Reduce Motion evidence, preview evidence, and photo-reference evidence.

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
