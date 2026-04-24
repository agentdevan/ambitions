# Ambitions Design Truth

This folder is the canonical design-truth set for the queued post-hardening Front-End Transformation Program.

It exists to remove interpretation drift from future implementation batches.
Use these specs together with:

- [../Ambitions_Full_Frontend_Transformation_Program.md](../Ambitions_Full_Frontend_Transformation_Program.md)
- [../Ambitions_Product_Addendum_Continuity_Reality_Execution.md](../Ambitions_Product_Addendum_Continuity_Reality_Execution.md)
- [../Ambitions_Frontend_Batches_49_60_Revised.md](../Ambitions_Frontend_Batches_49_60_Revised.md)
- [../../../MASTER_PRODUCT_SPEC.md](../../../MASTER_PRODUCT_SPEC.md)
- [../../codex/BATCH_REGISTRY.md](../../codex/BATCH_REGISTRY.md)

## Use Rules

- These docs define future design truth. They do not activate future UI batches.
- Batch 38 is completed.
- Batch 48 is completed in the registry.
- Batch 49 is completed in the registry.
- Batch 50 is completed in the registry.
- Batch 51 is completed in the registry.
- Batch 52 is completed in the registry.
- Batch 53 is completed in the registry.
- Batch 54 is completed in the registry.
- Batch 55 is the active frontend implementation batch in the registry.
- Batches 56-60 remain queued future implementation work.
- Treat iPhone execution truth as primary unless a spec explicitly defines a future-platform role.
- Prefer these docs over vague "premium" or "modern" interpretation when a future batch needs exact UI direction.
- If a future implementation task conflicts with current shipping behavior, preserve shipping truth until the relevant frontend batch becomes active.
- `MASTER_PRODUCT_SPEC.md` remains the shipping product spec; future-wave frontend doctrine lives in this design canon plus the transformation program doc.

## Spec Set

- [transformation-terminology-spec.md](transformation-terminology-spec.md)
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
- [transformation-validation-standard.md](transformation-validation-standard.md)

Continuity, sync-trust, handoff, return, and degraded-sync doctrine are governed by [../Ambitions_State_Continuity_Mesh.md](../Ambitions_State_Continuity_Mesh.md).

## Application Order

Use these specs in this order when planning a frontend batch:

1. Shared language from `transformation-terminology-spec.md`
2. Shell and route ownership from `shell-ia-spec.md`
3. Screen structure from `screen-architecture-spec.md`
4. Shared visual and control rules from `design-system-spec.md`
5. Motion and behavior from `motion-microinteraction-spec.md`
6. Trust and correction behavior from `trust-explainability-correction-spec.md`
7. Copy and state language from `copy-state-language-spec.md`
8. External and cross-device constraints from the surface-role specs
9. Signature system behavior from `novel-interaction-systems-spec.md`
10. Implementation tiering from `Ambitions_Frontend_Transformation_Execution_Classification.md`
11. Batch-closeout validation expectations from `transformation-validation-standard.md`

## Control-File Notes

- `transformation-terminology-spec.md` is the shared-language source for hero, recovery, trust, shaping, command, recall, continuity, and shell-layer terms.
- `transformation-validation-standard.md` is the program-wide validation doctrine for later transformation batches.
- Batch 39 establishes and aligns these control files; it does not authorize shell or surface implementation work.

## Scope Notes

- `Captures` and `Habits` are treated as subordinate but first-class product surfaces in the transformed shell, even though they are not top-level tabs in the current shipping truth.
- `Weekly Review`, `Monthly Review`, and `History` are treated as designed supporting routes, not top-level shell destinations.
- `Widgets`, `Live Activities`, `notifications`, `App Intents`, and `share extension` are specified here as future surfaces only.
- Additional named systems such as `Cognitive Mode Lens`, `Continuity Ribbon`, `Semantic Zoom`, `Quiet Command Sheet`, `Object-Persistent Navigation`, `Pressure Map`, `Review Constellation`, `Window Magnetism`, `Living Capture`, and `Intent-Sensitive Primary Action` are integrated into the existing specs below rather than split into a separate parallel doc set.
- Final App Store submission gating lives in [../Ambitions_App_Store_Release_Compliance.md](../Ambitions_App_Store_Release_Compliance.md); this design folder does not replace release-compliance review.
