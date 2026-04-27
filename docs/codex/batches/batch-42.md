# Batch 42 - Front-End Transformation 03 / Global compose, search, capture, and command surface
## Status
Completed for planning purposes
## Program
Post-hardening Front-End Transformation Program
## Canon Source
- [Ambitions_Full_Frontend_Transformation_Program.md](../../canon/Ambitions_Full_Frontend_Transformation_Program.md)
- [BATCH_REGISTRY.md](../BATCH_REGISTRY.md)

## Design Truth References
- [shell-ia-spec.md](../../archive/superseded-design-canon/design/shell-ia-spec.md)
- [screen-architecture-spec.md](../../archive/superseded-design-canon/design/screen-architecture-spec.md)
- [novel-interaction-systems-spec.md](../../archive/superseded-design-canon/design/novel-interaction-systems-spec.md)
## Start Gate
- Start only after Batch 38 is complete and stable.
- Do not activate or implement this batch early; follow the registry and dependency order.
## Goal
Implement the cross-app command layer that unifies creation, capture, quick recovery, quick planning, and memory recall.
## In Scope
- Contextual Global Compose implementation
- create / capture / quick plan patch / quick recovery / quick focus entry points
- Memory Lens foundation
- global search and recall architecture
- quick open goal / quick open week / quick open capture flows
- shell-level compose presentation
- command routing from external entry points
- create-goal shortcut entry to Strategy Composer
- capture triage quick actions redesign
- keyboard and hardware-keyboard-aware command surfaces for future iPad / Mac continuity
- command-state motion and microinteraction design
## Deferred, Not Excluded
- final surface-specific logic details for all major pages
- future device-specific adaptations
## Dependency Rules
- compose must feel like part of the OS, not a random modal
- global actions must respect shell hierarchy
- quick actions must route into canonical destinations, not side systems
## Exit Criteria
- one global action model exists
- command / compose / capture entry feels coherent across the app
- recall and command no longer feel scattered
## Validation
- xcodegen generate
- native build
- command routing tests
- deep-link / shortcut / compose tests
- full AmbitionsTests
- targeted UI tests
## Completion Rule
Complete only when creation, capture, recovery, and recall feel like one coherent system.

---
