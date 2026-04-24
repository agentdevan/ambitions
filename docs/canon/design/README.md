# Ambitions Design Truth

This folder is the historical design-truth set for the completed pre-Batch-61 Front-End Transformation Program.

For active Ambitions 2.0 Batch 61+ work, the top-level visual source of truth is [../Ambitions_2_0_Visual_System.md](../Ambitions_2_0_Visual_System.md).

It exists to remove interpretation drift from future implementation batches.
Use these specs together with:

- [../Ambitions_Full_Frontend_Transformation_Program.md](../Ambitions_Full_Frontend_Transformation_Program.md)
- [../../../MASTER_PRODUCT_SPEC.md](../../../MASTER_PRODUCT_SPEC.md)
- [../../codex/BATCH_REGISTRY.md](../../codex/BATCH_REGISTRY.md)

## Use Rules

- These docs are historical design context where not superseded by the Ambitions 2.0 Batch 61+ canon.
- All batches before Batch 61 are complete for planning purposes.
- Treat iPhone execution truth as primary unless a spec explicitly defines a future-platform role.
- Prefer [../Ambitions_2_0_Visual_System.md](../Ambitions_2_0_Visual_System.md) for future active UI direction.
- If a future implementation task conflicts with current shipping behavior, preserve shipping truth until the relevant frontend batch becomes active.

## Spec Set

- [shell-ia-spec.md](shell-ia-spec.md)
- [screen-architecture-spec.md](screen-architecture-spec.md)
- [design-system-spec.md](design-system-spec.md)
- [motion-microinteraction-spec.md](motion-microinteraction-spec.md)
- [trust-explainability-correction-spec.md](trust-explainability-correction-spec.md)
- [copy-state-language-spec.md](copy-state-language-spec.md)
- [external-surface-spec.md](external-surface-spec.md)
- [cross-device-surface-roles-spec.md](cross-device-surface-roles-spec.md)
- [novel-interaction-systems-spec.md](novel-interaction-systems-spec.md)
- [Ambitions_Frontend_Transformation_Execution_Classification.md](Ambitions_Frontend_Transformation_Execution_Classification.md)

## Application Order

Use these specs in this order when planning a frontend batch:

1. Shell and route ownership from `shell-ia-spec.md`
2. Screen structure from `screen-architecture-spec.md`
3. Shared visual and control rules from `design-system-spec.md`
4. Motion and behavior from `motion-microinteraction-spec.md`
5. Trust and correction behavior from `trust-explainability-correction-spec.md`
6. Copy and state language from `copy-state-language-spec.md`
7. External and cross-device constraints from the surface-role specs
8. Signature system behavior from `novel-interaction-systems-spec.md`
9. Implementation tiering from `Ambitions_Frontend_Transformation_Execution_Classification.md`

## Scope Notes

- `Captures` and `Habits` are treated as subordinate but first-class product surfaces in the transformed shell, even though they are not top-level tabs in the current shipping truth.
- `Weekly Review`, `Monthly Review`, and `History` are treated as designed supporting routes, not top-level shell destinations.
- `Widgets`, `Live Activities`, `notifications`, `App Intents`, and `share extension` are specified here as future surfaces only.
- Additional named systems such as `Cognitive Mode Lens`, `Continuity Ribbon`, `Semantic Zoom`, `Quiet Command Sheet`, `Object-Persistent Navigation`, `Pressure Map`, `Review Constellation`, `Window Magnetism`, `Living Capture`, and `Intent-Sensitive Primary Action` are integrated into the existing specs below rather than split into a separate parallel doc set.
