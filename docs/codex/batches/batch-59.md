# Batch 59 - Front-End Transformation 20 / Watch and Apple TV ambient surface architecture and first implementation
## Status
Completed
## Program
Post-hardening Front-End Transformation Program
## Canon Source
- [Ambitions_Full_Frontend_Transformation_Program.md](../../canon/Ambitions_Full_Frontend_Transformation_Program.md)
- [BATCH_REGISTRY.md](../BATCH_REGISTRY.md)

## Design Truth References
- [design/README.md](../../canon/design/README.md)
- [shell-ia-spec.md](../../canon/design/shell-ia-spec.md)
- [screen-architecture-spec.md](../../canon/design/screen-architecture-spec.md)
- [design-system-spec.md](../../canon/design/design-system-spec.md)
- [motion-microinteraction-spec.md](../../canon/design/motion-microinteraction-spec.md)
- [trust-explainability-correction-spec.md](../../canon/design/trust-explainability-correction-spec.md)
- [copy-state-language-spec.md](../../canon/design/copy-state-language-spec.md)
- [external-surface-spec.md](../../canon/design/external-surface-spec.md)
- [cross-device-surface-roles-spec.md](../../canon/design/cross-device-surface-roles-spec.md)
- [novel-interaction-systems-spec.md](../../canon/design/novel-interaction-systems-spec.md)
## Start Gate
- Start only after Batch 38 is complete and stable.
- Do not activate or implement this batch early; follow the registry and dependency order.
## Goal
Align launch scope so Watch and Apple TV stay intentionally out of v1 while preserving future-compatible ambient contracts.
## In Scope
- launch-scope wording that keeps Watch and Apple TV out of v1
- future-compatibility language for existing ambient and external contracts
- confirmation that Watch is the first likely post-launch expansion target
- confirmation that TV remains future/optional and outside release-candidate scope
## Deferred, Not Excluded
- Watch implementation
- Apple TV implementation
- all ambient and room-scale surface product work until after v1
## Dependency Rules
- preserve future-compatible external-surface and continuity contracts
- keep the locked launch strategy iPhone-only, portrait-only, and U.S.-only
- keep Watch as the first likely post-launch expansion target
- keep TV as future/optional, not release-candidate scope
## Exit Criteria
- launch-scope docs agree that Watch and Apple TV are intentionally deferred from v1
- future ambient contracts remain compatible with later expansion
- no product implementation was required for this batch under the locked launch strategy
## Validation
- docs/control reconciliation only
- registry and roadmap consistency checks
- no product build or implementation work required
## Completion Rule
Complete only when the launch strategy clearly records Watch as a likely post-launch target and Apple TV as future/optional rather than a v1 requirement.

## Completion Note
Completed as a scope-alignment batch. Watch and Apple TV implementation is intentionally deferred out of v1, Watch remains the first likely post-launch expansion target, Apple TV remains future/optional and outside release-candidate scope, existing external-surface contracts stay future-compatible, and no product implementation was required under the locked launch strategy.

---

## Program-Wide Validation Standard

Every implementation batch in this program should expect, at minimum:

- `xcodegen generate`
- native build validation
- targeted tests for touched surface / service / routing areas
- full `AmbitionsTests`
- `AmbitionsUITests` where user-critical flows changed
- manual simulator review for the affected surface family
- accessibility and motion review when visual interaction changes are central

---

## Handoff Artifacts to Derive from This Program

This roadmap should eventually produce:

- updated `BATCH_REGISTRY.md` rows for Batch 39 onward
- one batch doc per proposed batch
- a shell architecture spec
- a design token and component system spec
- a motion and transition grammar spec
- a copy and trust-language spec
- a surface-by-surface rebuild spec set
- an external-surface implementation spec
- future-device continuity specs for iPad, Mac, Watch, and Apple TV

---

## Final Program Thesis

This is no longer a limited visual refinement plan.

It is a full front-end transformation program that is allowed to change:

- shell architecture
- route ownership
- interaction grammar
- product logic where needed
- external surfaces
- future platform surfaces

The governing requirement is not minimal change.

The governing requirement is to make Ambitions feel like the premium, calm, organized, reality-aware external brain it is trying to become.
