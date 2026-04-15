# Goal Engine Contract Notes

## Source Of Truth

- `Native/Ambitions/Domain/GoalEngine/GoalEngineContracts.swift` is the canonical contract for the current native rollout.
- The neighboring files in `Native/Ambitions/Domain/GoalEngine/` are the preferred import surface for planner, intake, feedback, and contract behavior in the shipping app.
- If code generation is added later, generate any secondary contracts from the native Swift source of truth instead of reviving the removed TypeScript runtime.

## Rollout Rules

- Keep the legacy domain in place while the engine contract remains additive.
- Keep migrated and inferred values annotated with provenance so downstream UI can distinguish direct data from migration defaults or inference.
- Prefer contract selectors and helpers over ad hoc plan traversal in screens so UI composition stays stable as the rollout continues.
