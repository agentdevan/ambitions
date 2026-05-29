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

# MOAT-GOAL-REALITY-GOALS-BRIDGE-05 — Goals North Star / Active Path Bridge

## Batch ID

`MOAT-GOAL-REALITY-GOALS-BRIDGE-05`

## Runner Command

```bash
scripts/ambitions-codex-train.sh MOAT-GOAL-REALITY-GOALS-BRIDGE-05 prompts/batches/MOAT-GOAL-REALITY-GOALS-BRIDGE-05.md
```

## Objective

Bridge Goal Reality outputs into Goals so Ambitions can show North Star, Active Path, Truth State, Proof Gates, blocked assumptions, receipts, and review controls without making the Goals surface a surface, scorecard, or generic planner.

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
no generic surface score
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
