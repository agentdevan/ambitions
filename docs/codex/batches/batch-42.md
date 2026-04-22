# Batch 42 - Front-End Transformation 03 / Global compose, search, capture, and command surface
## Status
Completed
## Program
Post-hardening Front-End Transformation Program
## Canon Source
- [Ambitions_Full_Frontend_Transformation_Program.md](../../canon/Ambitions_Full_Frontend_Transformation_Program.md)
- [BATCH_REGISTRY.md](../BATCH_REGISTRY.md)

## Design Truth References
- [shell-ia-spec.md](../../canon/design/shell-ia-spec.md)
- [screen-architecture-spec.md](../../canon/design/screen-architecture-spec.md)
- [novel-interaction-systems-spec.md](../../canon/design/novel-interaction-systems-spec.md)
## Start Gate
- Start only after Batch 38 is complete and stable.
- The live registry is the operational source of truth for activation state.
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

## Completion Note
- Landed a shell-owned command system with structured overlay state, Quiet Command Sheet and Memory Lens foundations, canonical quick-open routing, shell-owned create-goal and quick-capture entry, normalized capture triage language, and external-entry routing through the same command contracts.
- Validated with `xcodegen generate`, native simulator build, targeted command/routing tests, full `AmbitionsTests`, targeted UI coverage added for command and Memory Lens seams, and manual human review confirming command-sheet opening, Memory Lens opening, canonical routing, create-goal, quick-capture, shell placement/readability, reduced-motion review, and regression checks for Goals create, Today quick capture, Plan-owned Captures, and external deep-link landing.

---
