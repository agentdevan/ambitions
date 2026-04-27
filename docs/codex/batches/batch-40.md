# Batch 40 - Front-End Transformation 01 / Shell reconsideration and navigation architecture
## Status
Completed for planning purposes
## Program
Post-hardening Front-End Transformation Program
## Canon Source
- [Ambitions_Full_Frontend_Transformation_Program.md](../../canon/Ambitions_Full_Frontend_Transformation_Program.md)
- [BATCH_REGISTRY.md](../BATCH_REGISTRY.md)

## Design Truth References
- [shell-ia-spec.md](../../archive/superseded-design-canon/design/shell-ia-spec.md)
- [motion-microinteraction-spec.md](../../archive/superseded-design-canon/design/motion-microinteraction-spec.md)
- [novel-interaction-systems-spec.md](../../archive/superseded-design-canon/design/novel-interaction-systems-spec.md)

Key systems in this batch:
- Cognitive Mode Lens
- Continuity Ribbon
- Quiet Command Sheet
- Object-Persistent Navigation
- Adaptive Header Rail

Execution classification:
- early core: Quiet Command Sheet, Object-Persistent Navigation, Adaptive Header Rail
- later core: Cognitive Mode Lens, Continuity Ribbon
## Start Gate
- Start only after Batch 38 is complete and stable.
- Do not activate or implement this batch early; follow the registry and dependency order.
## Goal
Fully reconsider the shell and navigation model, then implement the new canonical shell architecture for the iPhone app.
## In Scope
- full review of whether the five-tab shell remains correct as-is or should evolve
- top-level tab ownership reconsideration
- subordinate-route ownership reconsideration
- global create / capture / command entry redesign
- adaptive header rail implementation
- shell-aware transition grammar implementation
- safe-area behavior redesign
- top-level navigation and route rewiring
- deep-link and external-route architecture updates
- shell landing logic updates from notifications, widgets, shortcuts, and share flows
- structural decisions for where Captures, Habits, Review, History, Trust, and Memory Lens live
- shell-level motion, focus, and hierarchy rules
## Deferred, Not Excluded
- full individual surface redesigns
- full external-surface UI implementation
## Dependency Rules
- treat the current five-tab shell as the starting truth, not untouchable truth
- preserve obviousness and daily usability
- novelty is allowed only if it improves comprehension
- any shell change must remain compatible with future external and cross-device surfaces
## Exit Criteria
- one canonical shell architecture is shipped
- route ownership is unambiguous
- deep links and external entry points have one coherent landing model
- shell motion grammar exists in production
## Validation
- xcodegen generate
- native build
- targeted shell / routing / deep-link tests
- full AmbitionsTests
- full AmbitionsUITests
- manual simulator shell audit
## Completion Rule
Complete only when the new shell is structurally coherent, visually intentional, and stable enough for all later surface rebuilds.

---
