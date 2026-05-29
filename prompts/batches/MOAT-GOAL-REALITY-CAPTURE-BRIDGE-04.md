<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# MOAT-GOAL-REALITY-CAPTURE-BRIDGE-04 — Capture To Goal Reality Candidate Bridge

## Batch ID

`MOAT-GOAL-REALITY-CAPTURE-BRIDGE-04`

## Runner Command

```bash
scripts/ambitions-codex-train.sh MOAT-GOAL-REALITY-CAPTURE-BRIDGE-04 prompts/batches/MOAT-GOAL-REALITY-CAPTURE-BRIDGE-04.md
```

## Objective

Wire raw Capture fragments into reviewable Goal Reality candidates without automatically creating goals, mutating plans, writing irreversible state, or surfacing unsafe plans. Capture becomes the entry point for complex ambitions while preserving quiet composer-first product posture.

## Source Truth To Inspect

```text
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md
Native/Ambitions/Features/Captures/
Native/Ambitions/Runtime/GoalRealityRuntimeService.swift
Native/Ambitions/Runtime/GoalRealityCompiler.swift
Native/Ambitions/Domain/GoalRealityModels.swift
Native/Ambitions/Persistence/PersistenceContracts.swift
Native/AmbitionsTests/Persistence/CaptureServiceTests.swift
Native/AmbitionsTests/Runtime/GoalRealityRuntimeServiceTests.swift
```

## Allowed Scope

```text
Native/Ambitions/Features/Captures/CaptureGoalRealityBridge.swift
Native/Ambitions/Features/Captures/CaptureService.swift or closest active capture service seam
Native/Ambitions/Domain/GoalRealityModels.swift
Native/AmbitionsTests/Captures/CaptureGoalRealityBridgeTests.swift
Native/AmbitionsTests/Persistence/CaptureServiceTests.swift
docs/audits/moat-goal-reality-capture-bridge-04-report.md
docs/truth/IMPLEMENTATION_TRUTH.md
```

Use closest real paths if names differ. Do not redesign Capture UI.

## Required Behavior

When a capture fragment contains a moonshot, regulated, sensitive, irreversible, or high-risk goal, the bridge must create a reviewable candidate value model:

```text
raw capture text
GoalRealityOutput
candidate review state
safe route label
receipt summary
blocked behavior summary
```

The bridge must not:

```text
automatically create a Goal
automatically schedule a Today step
automatically mutate commitments
persist sensitive candidate without review path
turn Capture into a feed/dashboard
```

For the Olympic swimmer fixture from Capture:

```text
Capture: I want to be an Olympic swimmer. I am 32 and cannot swim.
Candidate: Goal Reality review candidate
North Star: Olympic swimmer
Active Path: Become a swimmer from zero
First Gate: Water safety baseline
Suggested review action: Review proof path
```

## Required Tests

Prove:

```text
raw Capture fragment can compile into GoalRealityOutput
candidate is reviewable, not activated
high-risk capture does not create plan/goal automatically
medical-sensitive, financial-speculation, and interpersonal-boundary captures are routed safely
receipt summary is available
private/sensitive captures preserve privacy classification
no hidden mutation
no network/hosted AI
```

## Forbidden Scope

No schema migration unless already safely supported. No UI redesign. No automatic goal creation. No Today surfacing. No notifications/widgets/App Intents. No release claims.

## Validation

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/CaptureGoalRealityBridgeTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/CaptureServiceTests
scripts/build-local.sh
git diff --check
scripts/run-doc-qa.sh || true
scripts/batch-train-gate-check.sh || true
```

## Hard Red Stop Conditions

Stop if implementation requires automatic goal creation, schema migration without rollback proof, broad Capture redesign, unsafe planning, hosted AI, network, or hidden mutation.

## Claim Boundary

Allowed: Capture fragments can produce reviewable local Goal Reality candidates. Forbidden: full Capture-to-Goal live product flow complete.

## Rollback

Normal revert. No migration rollback expected.

## Next Batch

`MOAT-GOAL-REALITY-GOALS-BRIDGE-05`

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
