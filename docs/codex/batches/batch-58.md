# Batch 58 - Front-End Transformation 19 / iPad and Mac surface architecture and first implementation
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
- [cross-device-surface-roles-spec.md](../../canon/design/cross-device-surface-roles-spec.md)
## Start Gate
- Start only after Batch 38 is complete and stable.
- Do not activate or implement this batch early; follow the registry and dependency order.
## Goal
Align launch scope so iPad and Mac stay intentionally out of v1 while the iPhone app remains the only required launch client.
## In Scope
- launch-scope wording that keeps v1 iPhone-only
- confirmation that existing adaptive iPhone behavior should not regress
- future optionality language for iPad and Mac post-launch exploration
- control-layer consistency across launch docs and batch registry
## Deferred, Not Excluded
- iPad and Mac surface implementation
- larger-screen layout, keyboard, and multi-pane product work
- all future iPad and Mac surface prototypes until after v1
## Dependency Rules
- do not regress existing iPhone adaptive behavior
- keep the locked launch strategy iPhone-only, portrait-only, and U.S.-only
- treat iPad and Mac exploration as optional post-launch work
## Exit Criteria
- launch-scope docs agree that iPad and Mac are intentionally deferred from v1
- existing iPhone behavior remains stable and adaptive where needed
- no product implementation was required for this batch under the locked launch strategy
## Validation
- docs/control reconciliation only
- registry and roadmap consistency checks
- no product build or implementation work required
## Completion Rule
Complete only when the launch strategy clearly records iPad and Mac as post-launch optionality rather than a v1 requirement.

## Completion Note
Completed as a scope-alignment batch. iPad and Mac larger-screen implementation is intentionally deferred out of v1, the launch remains iPhone-only/portrait-only/U.S.-only, existing adaptive iPhone behavior must not regress, and future iPad/Mac exploration is post-launch optionality rather than required product work.

---
