<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# MOAT-GOAL-REALITY-GOALS-BRIDGE-05 — Goals North Star / Active Path Bridge

## Batch ID

`MOAT-GOAL-REALITY-GOALS-BRIDGE-05`

## Runner Command

```bash
scripts/ambitions-codex-train.sh MOAT-GOAL-REALITY-GOALS-BRIDGE-05 prompts/batches/MOAT-GOAL-REALITY-GOALS-BRIDGE-05.md
```

## Objective

Bridge Goal Reality outputs into Goals so Ambitions can show North Star, Active Path, Truth State, Proof Gates, blocked assumptions, receipts, and review controls without making the Goals surface a dashboard, scorecard, or generic planner.

## Source Truth To Inspect

```text
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md
Native/Ambitions/Features/Goals/
Native/Ambitions/Runtime/GoalRealityRuntimeService.swift
Native/Ambitions/Domain/GoalRealityModels.swift
Native/AmbitionsTests/Goals/
Native/AmbitionsTests/Runtime/GoalRealityGoldenFixtureTests.swift
```

## Allowed Scope

```text
Native/Ambitions/Features/Goals/GoalRealityGoalsBridge.swift
Native/Ambitions/Features/Goals/GoalsFeatureService.swift or closest service seam
Native/Ambitions/Domain/GoalRealityModels.swift
Native/AmbitionsTests/Goals/GoalRealityGoalsBridgeTests.swift
Native/AmbitionsTests/Goals/GoalsFeatureServiceTests.swift
docs/audits/moat-goal-reality-goals-bridge-05-report.md
docs/truth/IMPLEMENTATION_TRUTH.md
```

## Required Behavior

Goals bridge must represent:

```text
North Star
Active Path
Truth State
Operating Level
Proof Gates
Blocked Behaviors
Receipt Summary
Review Requirements
Correction Controls
```

It must not:

```text
automatically activate goals
turn risky candidates into scheduled plans
hide proof gaps
collapse North Star into Active Path
show productivity scores or confidence scores
claim final Constellation Atlas completion
```

For the Olympic swimmer fixture:

```text
Goals shows North Star: Olympic swimmer
Active Path: Become a swimmer from zero
Truth: literal outcome not evidence-supported yet
Proof Gate: Water safety baseline
Review action: Review proof path
```

## Required Tests

Prove:

```text
GoalRealityOutput maps into Goals bridge model
North Star and Active Path remain distinct
proof gates render as reviewable backend state
blocked behaviors remain visible
receipt summary exists
no automatic goal activation
no plan mutation
no generic dashboard score
sensitive/high-risk candidates preserve privacy and review state
```

## Forbidden Scope

No broad Goals redesign. No schema migration unless fully proven. No route/tab changes. No hosted AI. No source-sensitive overclaiming. No release claims.

## Validation

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealityGoalsBridgeTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalsFeatureServiceTests
scripts/build-local.sh
git diff --check
scripts/run-doc-qa.sh || true
scripts/batch-train-gate-check.sh || true
```

## Hard Red Stop Conditions

Stop if implementation requires broad Goals rewrite, unsafe plan activation, hidden mutation, source-sensitive claims without review, hosted AI, or schema migration without rollback proof.

## Claim Boundary

Allowed: Goals has a source-present backend bridge for Goal Reality review state. Forbidden: final Goals visual/product completion.

## Rollback

Normal revert.

## Next Batch

`MOAT-GOAL-REALITY-TODAY-BRIDGE-06`
