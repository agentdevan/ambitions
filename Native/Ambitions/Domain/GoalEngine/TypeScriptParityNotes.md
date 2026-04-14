# Goal Engine TS -> Swift Mapping

The native runtime source of truth now lives under `Native/Ambitions/Domain/GoalEngine`.

Key mappings:

- `Goal`, `GoalDraft`, `GoalPlan`, `PlanSection`, and `Step` map directly to Swift structs with `Codable` and `Sendable`.
- `GoalTempo`, `GoalMode`, `GoalRelationshipKind`, `PlanningReadiness`, and orchestration result kinds map directly to Swift enums.
- TypeScript execution-owner variants were collapsed into the native app-facing `ExecutionOwnership` enum:
  `self`, `delegated`, `child`, `support`, `observedOnly`.
  This preserves the behaviors the native app needs now while keeping support/delegation framing explicit.
- TypeScript `ClassificationResult`, `ClarificationSet`, `GoalPlanningBlocker`, planner metadata, and reasoning metadata are mirrored as Swift persistence-friendly structs.
- `compileGoal(...)` is now represented by `GoalEngineOrchestrator.compileGoal(_:context:)` plus the top-level `compileGoal(_:context:)` helper.
- Starter-plan assumptions remain first-class via `PlanAssumption` and are surfaced both on the plan and in orchestration metadata.

Intentional scope for this port:

- Intake classification, orchestration decisions, starter-plan assumptions, and app-facing result cases are native.
- The deeper adaptive re-planning and feedback-analysis stack is intentionally deferred until the next planner/adaptation port.
- The old unattached `contracts/swift/AmbitionsGoalEngine.swift` mirror was removed to avoid maintaining a second fake Swift architecture beside the native domain implementation.
