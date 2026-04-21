# Batch 40 - Front-End Transformation 01 / Shell reconsideration and navigation architecture
## Status
Completed
## Program
Post-hardening Front-End Transformation Program
## Canon Source
- [Ambitions_Full_Frontend_Transformation_Program.md](../../canon/Ambitions_Full_Frontend_Transformation_Program.md)
- [BATCH_REGISTRY.md](../BATCH_REGISTRY.md)

## Design Truth References
- [shell-ia-spec.md](../../canon/design/shell-ia-spec.md)
- [motion-microinteraction-spec.md](../../canon/design/motion-microinteraction-spec.md)
- [novel-interaction-systems-spec.md](../../canon/design/novel-interaction-systems-spec.md)

Key systems in this batch:
- Quiet Command Sheet
- Object-Persistent Navigation
- Adaptive Header Rail

Execution classification:
- early core: Quiet Command Sheet, Object-Persistent Navigation, Adaptive Header Rail
- later core: Cognitive Mode Lens, Continuity Ribbon
## Start Gate
- Start only after Batch 38 is complete and stable.
- The live registry is the operational source of truth for activation state.
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
## Canonical Batch 40 Decisions
- five top-level tabs remain: Today, Goals, Plan, Insights, Profile
- Captures moves from Today-owned routing to Plan-owned subordinate routing
- Habits remains Plan-owned
- Weekly Review belongs under Plan
- Monthly Review and History belong under Insights
- Trust Center remains Profile-owned and is not shell-global
- Memory Lens and Quiet Command Sheet are shell overlays, not tabs
- Cognitive Mode Lens and Continuity Ribbon remain deferred later-core systems and must not ship as user-facing Batch 40 features
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
## Completion Note
- Actual implementation scope: shipped the canonical shell-owned container, route ownership model, Plan-owned Captures landing, Plan-owned Habits continuity, shell header/overlay seams, external-entry landing normalization, and deterministic origin-surface Goal Detail routing proof across Today, Goals, Plan, and Insights.
- Validation truth: Batch 40 implementation and evidence were validated through `xcodegen generate`, native simulator build, targeted shell/routing/deep-link coverage, full `AmbitionsTests`, prior strong `AmbitionsUITests` coverage, focused simulator/manual shell review, and a final deterministic integration proof for origin-surface Goal Detail routing.
- Truthful limits: no full individual surface rebuilds occurred, no Batch 41 visual-system rollout occurred, no full Batch 42 command behavior occurred, and no later-core systems such as Cognitive Mode Lens or Continuity Ribbon shipped.
- Remaining manual-only caveat: true OS-surface Shortcut/App Intent invocation was not cleanly verifiable in this environment, and the final-turn full UITest rerun was not clean because the simulator runner exited unexpectedly during bootstrap.
