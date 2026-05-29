# FVQ03 Drill-Down And External Surface Visual Sweep

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-16768161, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

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

Status: Active-scope visual quality gate.
Date: 2026-05-05

## Purpose

FVQ03 ensures Ambitions' premium visual system does not collapse outside the five top-level tabs.

FVQ03 audits rendered drill-downs and external surfaces after their implementation batches exist and before final handoff claims.

## Drill-Down Targets

Audit when implemented:

- Step Detail
- Step Session
- Goal Detail / Mission Control
- LifePath detail
- LifeShape detail
- Memory Lens
- Receipt Drawer
- Source Fold
- Weekly Life Sweep
- Appearance Studio
- Schedule & Availability
- Planning Defaults
- Capture Placement Resolver
- Grow Into Goal
- Proof Spine / Evidence Ledger
- Reflow Decision Fold
- Pressure / Recovery Loop

## External Surface Targets

Audit when implemented:

- widgets
- Live Activities
- App Intents confirmation/result surfaces
- notification content previews
- Lock Screen / Dynamic Island content where applicable
- App Store screenshots

## Required Standards

All drill-downs must:

- feel native and premium
- preserve the parent surface's object language
- avoid dashboard/card-stack drift
- use progressive disclosure
- show trust/source/privacy where relevant
- preserve accessibility and Reduce Motion equivalents
- avoid showing sensitive Found Life content by default

All external surfaces must:

- be glanceable
- be privacy-safe by default
- deep-link to exact relevant app context
- avoid ads/promotions
- avoid sensitive life content unless explicitly allowed
- use restrained Ambitions identity
- never look like generic widgets or notification spam

## Evidence

Save visual evidence under:

`docs/audits/visual-evidence/fvq03/`

Every audited surface needs:

- screenshot or rendered preview
- freshness proof or fixture proof
- visual score
- privacy/accessibility note
- repair owner if below bar

## Hard Red

Hard Red if:

- drill-down becomes dashboard/page pile
- external surface exposes sensitive Found Life content
- widget/Live Activity looks generic or promotional
- App Intent confirmation allows hidden mutation
- detail surface breaks object language
- screenshot or preview cannot be tied to current build/fixture

## Completion

FVQ03 completes only when implemented drill-down/external surfaces have visual evidence or explicit accepted Yellow deferral with owner and no Hard Red.

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
