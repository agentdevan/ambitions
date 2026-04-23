# Batch 59 - Front-End Transformation 20 / Watch and Apple TV ambient surface architecture and first implementation
## Status
Queued
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
Begin future ambient and room-scale implementations for Watch and Apple TV.
## In Scope
- Watch surface architecture
- Apple TV surface architecture
- Focus Screenlet watch adaptation
- glance and confirm patterns for Watch
- routine / reminder / momentum / quick-capture ambient patterns for Watch
- Apple TV reflection / weekly reset / review-oriented ambient concepts where appropriate
- first implementation pass for Watch and Apple TV priorities
- cross-device state and continuity treatment
- ambient copy and interaction refinement for ultra-low-input surfaces
## Deferred, Not Excluded
- final finish-quality pass
## Dependency Rules
- Watch should prioritize clarity, confirmation, momentum, and quick actions
- Apple TV should prioritize ritual, review, and ambient value, not deep editing
- future surfaces must inherit the same trust and tone standards
## Exit Criteria
- Watch and Apple TV have coherent first implementations
- ambient device roles are meaningful
- future device work no longer lives only as theory
## Validation
- platform build validation as applicable
- targeted ambient-surface tests
- shared-state continuity tests
- manual audits as available
## Completion Rule
Complete only when Watch and Apple TV surfaces have real product roles and initial implementation truth.

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
