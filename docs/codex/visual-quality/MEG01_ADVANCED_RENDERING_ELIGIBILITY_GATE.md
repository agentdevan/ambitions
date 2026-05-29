# MEG01 Metal / Advanced Rendering Eligibility Gate

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Active-scope advanced-rendering policy.
Date: 2026-05-05

## Purpose

MEG01 prevents Codex from using Metal, shaders, particles, or advanced rendering as a gimmick or as a substitute for proper layout, hierarchy, copy, and SwiftUI composition.

Metal may be valuable for Ambitions signature visuals, but it is not the default fix for visual quality.

## Default Rendering Stack

Use this order unless MEG01 approves escalation:

1. SwiftUI native layout, typography, materials, safe areas, and controls.
2. SwiftUI Shapes and custom view composition.
3. SwiftUI Canvas for rich 2D drawing and lightweight atmospheric/contour work.
4. Metal only if SwiftUI/Canvas cannot meet the measured quality/performance target.

## Metal / Advanced Rendering Candidate Areas

Potential candidates for future evaluation only:

- Capture Atmosphere starfield / thought-field renderer
- LifeShape contour / pressure / protected-pocket renderer
- MissionControlTimeSpine proof/pressure field renderer
- subtle material texture/noise/light-falloff where Canvas is insufficient

These candidates are not implementation approval. Each candidate must still
produce a primitive-specific eligibility report before any Metal, shader, or
advanced renderer is added.

## Current Gate Decision

MEG01 approves no Metal implementation by default.

Current decision:

- SwiftUI native layout, materials, typography, and controls remain the default.
- SwiftUI Shapes and Canvas remain the preferred escalation path for rich
  Ambitions visuals.
- Metal is deferred until a named signature primitive proves SwiftUI/Canvas
  insufficiency, performance/battery budget, static fallback, Reduce Motion
  fallback, nonvisual equivalent, isolated file boundary, screenshot evidence,
  and profiling plan.
- Existing DAV rendering/battery evidence remains Yellow for device/Instruments
  proof and does not authorize new shader or Metal work.

## Forbidden Uses

Do not use Metal or advanced rendering to fix:

- weak Today hierarchy
- poor Start Here composition
- generic Reality Rail layout
- tab/shell polish
- generic cards
- surface drift
- weak copy
- missing source/trust behavior
- missing accessibility labels
- business logic
- navigation
- persistence
- recommendation logic
- privacy/trust/source logic

## Eligibility Requirements

Metal/advanced rendering is allowed only when all are true:

- target is a true Ambitions signature primitive
- simpler SwiftUI/Canvas approach is insufficient or measured as too weak
- performance and battery budget exists
- static fallback exists
- Reduce Motion fallback exists
- VoiceOver/nonvisual equivalent exists
- low-power/degraded mode exists where needed
- renderer is isolated in a small component boundary
- no business/domain/trust logic enters renderer
- screenshot evidence exists
- profiling/instruments plan exists
- effect is subtle, premium, and non-gimmicky
- no sci-fi UI drift

## Required Report

Any batch requesting or adding Metal/advanced rendering must write:

`docs/audits/meg01-advanced-rendering-eligibility-report.md`

Report must include:

- why SwiftUI/Canvas was insufficient
- visual primitive owner
- exact requested escalation: Canvas / shader / Metal / other renderer
- renderer file boundary
- files forbidden to touch
- performance/battery budget
- fallback behavior
- accessibility equivalent
- Reduce Motion equivalent
- screenshots
- profiling plan or evidence
- rollback path
- no-claim boundary for App Store, release, physical device, public
  accessibility, and legal/privacy proof

## Hard Red

Hard Red if:

- Metal is added broadly
- Metal code contains business logic
- effect is decorative/noisy/gimmicky
- no static fallback exists
- no Reduce Motion fallback exists
- no accessibility equivalent exists
- battery/performance risk is unbounded
- shader complexity makes the repo harder to maintain without clear product value

## Completion

MEG01 completes when advanced rendering is either explicitly deferred or approved for named signature primitives with strict boundaries. No Metal implementation is required by this policy.

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
