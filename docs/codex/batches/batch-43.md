# Batch 43 - Front-End Transformation 04 / Today rebuild I - living hero, now state, and action model
## Status
Completed
## Program
Post-hardening Front-End Transformation Program
## Canon Source
- [Ambitions_Full_Frontend_Transformation_Program.md](../../canon/Ambitions_Full_Frontend_Transformation_Program.md)
- [BATCH_REGISTRY.md](../BATCH_REGISTRY.md)

## Design Truth References
- [screen-architecture-spec.md](../../canon/design/screen-architecture-spec.md)
- [motion-microinteraction-spec.md](../../canon/design/motion-microinteraction-spec.md)
- [novel-interaction-systems-spec.md](../../canon/design/novel-interaction-systems-spec.md)

Key systems in this batch:
- Living Hero Surface
- Intent-Sensitive Primary Action
- Trust Whisper (quiet first-layer only)

Execution classification:
- early core: Living Hero Surface, Intent-Sensitive Primary Action, Trust Whisper
- later core: Recovery Bloom, Continuity Ribbon
## Start Gate
- Start only after Batch 38 is complete and stable.
- Do not activate or implement this batch early; follow the registry and dependency order.
## Goal
Rebuild Today into the flagship living execution surface with a new hero layer, stronger hierarchy, and a first-class action model.
## In Scope
- Today information architecture rewrite
- Living Hero Surface for Now / Next / dominant daily truth
- action hierarchy redesign
- stronger fixed-versus-flexible treatment
- module compression and card reduction
- Today header and hero behavior
- completion / defer / split / reschedule / protect action redesign
- re-entry entry-point framing
- daily momentum strip redesign
- stronger use of runtime truth in the top layer
- visual implementation of Today system language
- motion patterns for Today state changes
## Deferred, Not Excluded
- Time Aperture
- Recovery Bloom full system
- visible Continuity Ribbon system
- expanded Today logic changes tied to recovery and time shaping
## Dependency Rules
- Today must become the strongest surface in the product
- avoid dense stacked-card dashboard behavior
- hero truth must be instantly legible
- keep command, create, and capture shell-owned under Batch 42
- do not ship visible Time Aperture, full Recovery Bloom, or visible Continuity Ribbon in this batch
## Exit Criteria
- Today has one dominant focal structure
- daily action flow is materially more obvious
- Today looks and behaves like a flagship surface
## Validation
- build
- targeted Today service / view-model / routing tests
- full AmbitionsTests
- targeted UI tests
- manual simulator audit
## Completion Rule
Complete only when Today clearly feels like the product home base.

---
Completion note:
- Batch 43 completed by replacing the old Today card stack with a dominant hero, clearer Now/Next truth, compressed fixed/flexible/momentum support, shell-aware quick recovery / quick focus re-entry, and truthful bounded handoffs into Goal Detail and Plan.
- Validation completed with `xcodegen generate`, native simulator build, targeted Today/unit routing tests, full `AmbitionsTests`, targeted Today UI proof, and direct simulator/a11y review. Time Aperture, full Recovery Bloom, and visible Continuity Ribbon remain deferred to Batch 44+.
