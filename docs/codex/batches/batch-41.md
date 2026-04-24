# Batch 41 - Front-End Transformation 02 / Design system, materials, motion engine, and controls
## Status
Completed for planning purposes
## Program
Post-hardening Front-End Transformation Program
## Canon Source
- [Ambitions_Full_Frontend_Transformation_Program.md](../../canon/Ambitions_Full_Frontend_Transformation_Program.md)
- [BATCH_REGISTRY.md](../BATCH_REGISTRY.md)

## Design Truth References
- [design-system-spec.md](../../canon/design/design-system-spec.md)
- [motion-microinteraction-spec.md](../../canon/design/motion-microinteraction-spec.md)
- [copy-state-language-spec.md](../../canon/design/copy-state-language-spec.md)
## Start Gate
- Start only after Batch 38 is complete and stable.
- Do not activate or implement this batch early; follow the registry and dependency order.
## Goal
Implement the full premium visual system and motion grammar used by every later batch.
## In Scope
- design token system for color, tone, depth, radii, spacing, typography, timing, motion, and haptics
- dark-first authored theme system
- premium light mode equal in quality to dark mode
- curated accent family architecture
- Appearance Studio foundations
- three-tier button system implementation
- card / row / band / section container system
- status chip and pill system
- iconography rules and replacements where needed
- materiality and tonal layering system
- transition primitives
- completion, correction, reschedule, and route-change motion patterns
- reduced-motion compatibility
- reusable loading / empty / error visual primitives
## Deferred, Not Excluded
- surface-specific composition details
- future-device-specific adaptations
## Dependency Rules
- shared system must land before major surface rebuilds
- premium styling must not outrun clarity
- do not over-card the app
- all later surface work must use these tokens and components
## Exit Criteria
- shared design system is production-ready
- motion grammar is established
- core controls feel premium and consistent
- theme architecture is live and stable
## Validation
- build and preview validation
- component-level snapshot / rendering checks where appropriate
- accessibility contrast review
- reduced-motion review
- full AmbitionsTests
- full AmbitionsUITests
## Completion Rule
Complete only when the app has one real system language rather than per-screen styling decisions.

---
