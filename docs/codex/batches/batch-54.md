# Batch 54 - Front-End Transformation 15 / External surfaces I - widgets, Live Activities, notifications
## Status
Queued
## Program
Post-hardening Front-End Transformation Program
## Canon Source
- [Ambitions_Full_Frontend_Transformation_Program.md](../../canon/Ambitions_Full_Frontend_Transformation_Program.md)
- [BATCH_REGISTRY.md](../BATCH_REGISTRY.md)

## Design Truth References
- [external-surface-spec.md](../../canon/design/external-surface-spec.md)
- [motion-microinteraction-spec.md](../../canon/design/motion-microinteraction-spec.md)
- [cross-device-surface-roles-spec.md](../../canon/design/cross-device-surface-roles-spec.md)
## Start Gate
- Start only after Batch 38 is complete and stable.
- Do not activate or implement this batch early; follow the registry and dependency order.
## Goal
Fully implement the core ambient and external surfaces as premium first-class product surfaces.
## In Scope
- widget redesign and implementation
- lock screen widget hierarchy
- home screen widget hierarchy
- Live Activity redesign and implementation
- Focus Screenlet implementation
- notification content and action redesign
- notification landing logic refinement
- widget-to-app and activity-to-app shell-aware transitions
- calm ambient trust language
- external motion and visual continuity with the main app
- external state variants for Today, Focus, Goal, and Plan use cases
## Deferred, Not Excluded
- share extension
- App Intents / shortcuts
- future Watch / TV ambient surfaces
## Dependency Rules
- external surfaces must inherit canonical truth from the app
- they must feel useful at glance depth
- they must not use a different visual language from the main product
## Exit Criteria
- widgets, activities, and notifications are real product surfaces
- external landing behavior is coherent
- ambient surfaces feel premium and useful
## Validation
- build
- shared snapshot / external-route tests
- targeted widget / notification / live activity tests
- full AmbitionsTests
- manual simulator / platform surface audit as available
## Completion Rule
Complete only when the app’s external surfaces no longer feel conservative or half-shipped.

---
