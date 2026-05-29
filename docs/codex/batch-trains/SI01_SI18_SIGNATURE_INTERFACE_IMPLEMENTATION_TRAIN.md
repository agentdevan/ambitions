# SI01-SI18 Signature Interface Implementation Train

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-23200176, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, merge-overlap-before-proof, terminology-quarantine
> Dispositions: merge-before-proof, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

<!-- markdownlint-disable MD013 -->

Status: Queued Ambitions 4.0 implementation train; not started unless selected by global order and gates.
Train type: Signature Interface / SwiftUI primitives / visual QA / interaction system
Date: 2026-05-02

## Required User Approval Phrase

Start Signature Interface Train

The global phrase Run Global Batch Sequence Until Blocked may carry execution into SI when the updated global order reaches SI and all gates are Green or accepted Yellow. This does not replace proof or validation.

## Train Purpose

Implement Ambitions-exclusive SwiftUI interface primitives, adaptive panels, IA, shell, action system, grouped navigation lists, iconography, loading states, in-app modules, transitions, interaction systems, and top-level visual operating surfaces using PXOS canon while preserving ME/CS/REC/AOS gates.

SI creates the reusable interface language that PD and AOS24 can compose. It is not a cosmetic lane.

## Source Truth Hierarchy

- README.md
- AGENTS.md
- docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md
- docs/canon/Ambitions_3_0_Primitive_Architecture.md
- docs/canon/Ambitions_4_0_Execution_Program.md
- docs/canon/Ambitions_Product_Experience_OS_Index.md
- docs/canon/PXOS_Surface_Hierarchy_And_Navigation.md
- docs/canon/PXOS_Visual_Interaction_System.md
- docs/canon/PXOS_Product_Depth_And_Drilldown_Rules.md
- docs/canon/Ambitions_Signature_Interface_System.md
- docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md
- docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md
- docs/codex/BATCH_REGISTRY.md
- docs/canon/Ambitions_Signature_Interface_System.md
- .codex/review-boards/signature-interface-review-board.md

## Train Gates

- Signature Interface Creative Direction Gate
- Native iPhone Believability Gate
- Anti-Generic UI Gate
- Top-Level Composition Gate where relevant
- Interaction/Motion/Haptics Gate
- Reduce Motion Gate
- Accessibility/Dynamic Type/VoiceOver Gate
- Preview Coverage Gate
- Visual QA Gate
- File-Size/Component Boundary Gate
- Release-Claim Safety Gate

## Batch Order

| Batch | Title | Type | Global order | Status | Primary purpose |
| --- | --- | --- | --- | --- | --- |
| SI01 | Signature Interface Canon To SwiftUI Architecture | docs/architecture planning | 048 | Complete | Map PXOS into reusable SwiftUI architecture. |
| SI02 | Adaptive Panel Action And Module Foundation | SwiftUI implementation | 049 | Complete | Build adaptive panels, actions, materials, and in-app module foundations. |
| SI03 | App Shell IA And Navigation List System | SwiftUI implementation | 050 | Complete | Build shell, IA, and grouped navigation primitives. |
| SI04 | DayTimelineRail 2.0 | SwiftUI implementation | 051 | Complete | Build the Ambitions-exclusive Today rail primitive. |
| SI05 | Hero Step Panel System | SwiftUI implementation | 052 | Complete | Build the adaptive Today hero object. |
| SI06 | LifePath Visualization System | SwiftUI implementation | 053 | Complete | Invent Ambitions goal path visual grammar. |
| SI07 | Mission Control Lane Components | SwiftUI implementation | 054 | Complete | Built reusable lanes for Goal Detail and Mission Control. |
| SI08 | LifeShape Time Capacity Map | SwiftUI implementation | 055 | Complete | Built Plan time/capacity/pressure primitive. |
| SI09 | Capture Atmosphere Composer | SwiftUI implementation | 056 | Complete | Built Capture signature atmosphere/composer primitive. |
| SI10 | Trust Receipt Layer | SwiftUI implementation | 057 | Complete | Built reusable trust/proof/receipt layer. |
| SI11 | Personal System Center Components | SwiftUI implementation | 058 | Complete | Built reusable You header, setup completeness, grouped navigation wrapper, preview states, and focused design-system tests. |
| SI12 | Interaction Motion Haptics System | SwiftUI implementation | 059 | Complete | Built shared interaction tokens, transition helpers, optional user-initiated haptic mappings, Reduce Motion equivalents, preview evidence, and focused design-system tests. |
| SI13 | Loading Empty Degraded State Primitives | SwiftUI implementation | 060 | Complete | Built shared loading/degraded state taxonomy, state module, stale source label, recovery prompt module, previews, and focused design-system tests. |
| SI14 | Iconography Symbol And Status Grammar | SwiftUI/design-system implementation | 061 | Complete | Built shared status/source/proof/privacy/pressure/recovery symbol grammar, visible label pairing, previews, and focused design-system tests. |
| SI15 | Accessibility Adaptive Interface Pass | SwiftUI implementation/test pass | 062 | Complete | Built shared adaptive axes, review lanes, visible fallbacks, VoiceOver summaries, Reduce Motion equivalents, previews, and focused design-system tests. |
| SI16 | Preview Fixture And Visual QA Infrastructure | implementation/test infrastructure | 063 | Complete | Built deterministic preview fixtures and visual QA harness evidence. |
| SI17 | Top-Level Surface Composition Implementation | SwiftUI implementation | 064 | Complete | Applied SI composition bar to Today, Goals, Capture, Plan, and You. |
| SI18 | Signature Interface Handoff And Product Depth Readiness | docs/handoff/evidence | 065 | Complete | Closed SI with handoff evidence and stopped before PD approval gate. |

## Continuation

Each SI batch requires dry-run selection, execution budget, batch report under docs/audits/, Strong validation for code, Adequate validation for docs/handoff, clean commit, push, and post-commit drift check.

## Stop Conditions

Stop on unresolved Red, weak implementation validation, forbidden file touch, unsupported release/platform claim, false SI/PXOS/PD/AOS implementation claim, top-level stack regression, generic product drift, missing UI evidence for UI work, missing Reduce Motion equivalent for motion, missing component state matrix, or unreviewable file-size growth.

## Non-Claims

This manifest does not start SI, implement SI, claim human visual approval, claim public accessibility proof, claim physical-device proof, claim release readiness, or authorize Product Depth/AOS24 to skip gates.

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
