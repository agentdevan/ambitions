<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_source_file_targeted_by_multiple_active_batches-22647572, AMB28-same_source_file_targeted_by_multiple_active_batches-27167925, AMB28-same_source_file_targeted_by_multiple_active_batches-31687043, AMB28-same_source_file_targeted_by_multiple_active_batches-41488053, AMB28-same_source_file_targeted_by_multiple_active_batches-50843547, AMB28-same_source_file_targeted_by_multiple_active_batches-65376188, AMB28-same_source_file_targeted_by_multiple_active_batches-72416313, AMB28-same_source_file_targeted_by_multiple_active_batches-72778890, AMB28-same_source_file_targeted_by_multiple_active_batches-80494176, AMB28-same_source_file_targeted_by_multiple_active_batches-83544260, AMB28-same_source_file_targeted_by_multiple_active_batches-8484318 and 5 more

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
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

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
