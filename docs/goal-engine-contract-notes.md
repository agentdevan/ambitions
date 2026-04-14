# Goal Engine Contract Notes

## Source Of Truth

- `src/domain/models/goalEngine.ts` is the canonical contract for the additive goal engine rollout.
- `src/domain/models/goalEngineContracts.ts` is the preferred import surface when both legacy and engine models are in scope because it exposes explicit aliases like `LegacyGoal` and `EngineGoal`.
- `contracts/swift/AmbitionsGoalEngine.swift` is a mirrored secondary contract. It should follow the TypeScript contract instead of introducing shape differences.
- If code generation is added later, generate secondary contracts from the TypeScript source whenever possible.

## Rollout Rules

- Keep the legacy domain in place while the engine contract remains additive.
- Keep migrated and inferred values annotated with provenance so downstream UI can distinguish direct data from migration defaults or inference.
- Prefer contract selectors and helpers over ad hoc plan traversal in screens so UI composition stays stable as the rollout continues.
