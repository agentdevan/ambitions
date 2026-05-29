# DAV05 Plan LifeShapeMap And CapacityVisuals Implementation Prompt

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-74249518, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-66075429

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof, terminology-quarantine
> Dispositions: merge-before-proof, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->
## Batch Identity
- Batch ID: DAV05
- Name: Plan LifeShapeMap And CapacityVisuals Implementation
- Global order: 059
## Active 4.0 Status
Active DAV implementation batch; production SwiftUI allowed in Plan visual owners.
## Purpose
Upgrade Plan with LifeShapeMap, capacity visual, pressure visual, protected time blocks, Day/Week/Month scope chip, and evidence labels.
## Affected Surfaces
Plan.
## Allowed Production Swift Files
Native/Ambitions/Features/Plan/**, Sources/Components/**, Native/Ambitions/PreviewSupport/**.
## Forbidden Files
Calendar permission behavior changes, persistence/schema, routes/raw values, dependencies, workflows.
## Required Visual Primitives
LivingSurfaceBackground, PressureGlow, EvidenceLabel, AdaptiveModuleChrome.
## Motion Rules
Believable reflow orientation only; no calendar clone animation.
## Reduce Motion Equivalent
Static capacity state and non-animated scope selection.
## Dynamic Type Requirements
Capacity labels wrap and remain readable.
## VoiceOver Requirements
Scope, pressure, capacity, protected time in order.
## Preview Fixture Requirements
Day, week, month, overloaded, calendar denied, recovery.
## Product-Experience Before/After Notes
Record no-calendar-clone impact.
## Validation Commands
`git diff --check`; DAV scans; focused Plan build/tests.
## Green/Yellow/Red Criteria
Green: Plan compiles and is visually time-aware. Yellow: performance/human polish deferred. Red: generic calendar/dashboard drift.
## Stop Conditions
Stop on permission, persistence, route, or schema changes.
## Commit Message
`Implement Plan dynamic adaptive screen`
## Next Safe Path
DAV06 Goals.

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
