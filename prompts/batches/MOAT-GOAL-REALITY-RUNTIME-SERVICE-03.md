<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# MOAT-GOAL-REALITY-RUNTIME-SERVICE-03 — Local Runtime Service Integration

## Batch ID

`MOAT-GOAL-REALITY-RUNTIME-SERVICE-03`

## Runner Command

```bash
scripts/ambitions-codex-train.sh MOAT-GOAL-REALITY-RUNTIME-SERVICE-03 prompts/batches/MOAT-GOAL-REALITY-RUNTIME-SERVICE-03.md
```

## Objective

Expose the Goal Reality Compiler through Ambitions’ local runtime service layer without adding hosted AI, network, persistence writes during compile, launch dependency risk, or UI behavior. This batch turns the compiler from isolated value models into an injectable local runtime capability.

## Source Truth To Inspect

```text
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/CODEX_PROCESS_TRUTH.md
docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md
Native/Ambitions/Runtime/AmbitionsRuntimeContracts.swift
Native/Ambitions/Runtime/AmbitionsRuntimeFactory.swift
Native/Ambitions/Runtime/AmbitionsRuntimeGoalIntelligence.swift
Native/Ambitions/Runtime/GoalRealityCompiler.swift
Native/Ambitions/Runtime/GoalRealityValidator.swift
Native/Ambitions/Runtime/GoalRealityFixtureLab.swift
Native/AmbitionsTests/Runtime/GoalRealityRuntimeBoundaryTests.swift
Native/AmbitionsTests/App/AppContainerFactoryTests.swift
Native/AmbitionsTests/Runtime/AmbitionsRuntimeBoundaryTests.swift
```

## Allowed Scope

```text
Native/Ambitions/Runtime/GoalRealityRuntimeService.swift
Native/Ambitions/Runtime/AmbitionsRuntimeContracts.swift
Native/Ambitions/Runtime/AmbitionsRuntimeFactory.swift
Native/Ambitions/Runtime/AmbitionsRuntimeGoalIntelligence.swift
Native/AmbitionsTests/Runtime/GoalRealityRuntimeBoundaryTests.swift
Native/AmbitionsTests/Runtime/GoalRealityRuntimeServiceTests.swift
Native/AmbitionsTests/App/AppContainerFactoryTests.swift
docs/audits/moat-goal-reality-runtime-service-03-report.md
docs/truth/IMPLEMENTATION_TRUTH.md
```

## Required Implementation

Add a small protocol and default service:

```swift
protocol GoalRealityCompiling: Sendable {
    func compile(_ input: GoalRawIntent) -> GoalRealityOutput
    func validate(_ output: GoalRealityOutput) -> [GoalRealityIssue]
}

struct DefaultGoalRealityRuntimeService: GoalRealityCompiling { ... }
```

Integrate with `AmbitionsRuntime` only if safe:

```swift
let goalRealityService: any GoalRealityCompiling
```

Add factory injection if it does not create broad app launch risk.

The runtime service must:

```text
use local deterministic compiler
use local validator
not read/write persistence during pure compile
not perform network work
not depend on remote AI
not mutate goals/plans/commitments
not block app launch
not expose user-facing confidence
```

## Required Tests

Prove:

```text
runtime exposes GoalRealityCompiling
service compiles Olympic swimmer fixture identically to core compiler
service validates negative fixtures
current runtime capabilities remain local-only
no remote intelligence backend is introduced
no user-data server dependency is introduced
no compile path writes persistence
factory creates service without changing launch contract
```

## Forbidden Scope

No UI, no schema, no network, no hosted AI, no source-pack fetching, no route changes, no notifications/widgets/App Intents, no release claims.

## Validation

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealityRuntimeServiceTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealityRuntimeBoundaryTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/AmbitionsRuntimeBoundaryTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/AppContainerFactoryTests
scripts/build-local.sh
git diff --check
scripts/run-doc-qa.sh || true
scripts/batch-train-gate-check.sh || true
```

## Hard Red Stop Conditions

Stop if runtime integration requires remote inference, network, hosted backend, persistence write during compile, app-launch dependency on compiler output, schema migration, or broad app wiring.

## Claim Boundary

Allowed: Goal Reality Compiler is exposed through a local runtime service. Forbidden: live product flow fully uses it.

## Rollback

Normal revert. No data migration or release rollback.

## Next Batch

`MOAT-GOAL-REALITY-CAPTURE-BRIDGE-04`
