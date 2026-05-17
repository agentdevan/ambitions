<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07 — Receipt / Closure / Correction Loop

## Batch ID

`MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07`

## Runner Command

```bash
scripts/ambitions-codex-train.sh MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07 prompts/batches/MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07.md
```

## Objective

Connect Goal Reality outputs to a backend receipt, closure, correction, and visible local-learning loop so Ambitions can explain reframes, record user closure states, accept corrections, and adjust future candidates without hidden learning or silent mutation.

## Source Truth To Inspect

```text
docs/truth/IMPLEMENTATION_TRUTH.md
docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md
Native/Ambitions/Domain/GoalRealityReceiptModels.swift
Native/Ambitions/Domain/GoalRealityModels.swift
Native/Ambitions/Runtime/GoalRealityCompiler.swift
Native/Ambitions/Runtime/GoalRealityValidator.swift
Native/Ambitions/Domain/ActionClosureReceiptModels.swift
Native/Ambitions/Domain/RecommendationExplanationModels.swift
Native/AmbitionsTests/Runtime/GoalRealityReceiptTests.swift
```

## Allowed Scope

```text
Native/Ambitions/Domain/GoalRealityReceiptModels.swift
Native/Ambitions/Domain/GoalRealityClosureModels.swift
Native/Ambitions/Runtime/GoalRealityReceiptClosureService.swift
Native/Ambitions/Runtime/GoalRealityCompiler.swift
Native/Ambitions/Runtime/GoalRealityValidator.swift
Native/AmbitionsTests/Runtime/GoalRealityReceiptTests.swift
Native/AmbitionsTests/Runtime/GoalRealityClosureCorrectionTests.swift
docs/audits/moat-goal-reality-receipt-closure-07-report.md
docs/truth/IMPLEMENTATION_TRUTH.md
```

## Required Behavior

Every Goal Reality output must provide:

```text
receipt
closure prompt
correction controls
local learning hook when appropriate
reset/delete/disable learning pathway
no-silent-mutation flag
```

Closure states must include non-shaming options:

```text
Completed
Still Counts
Moved
Blocked
Waiting
Needs Recovery
Needs Review
Not Needed
```

Receipts must show:

```text
original intent
preserved North Star
active path created
reason for reframe
refused assumptions
blocked behaviors
missing evidence
review requirements
whether plan changed
whether persistence was written
local-only state
correction controls
```

Corrections must be visible, local-only, resettable, and receipt-backed.

## Required Tests

Prove:

```text
receipts are generated for all golden fixtures
closure options are non-shaming
corrections can alter future compile preference only through visible local hooks
correction hooks are resettable/deletable/disable-able
receipt records no hidden mutation
blocked outputs still get explanatory receipt
regulated-sensitive receipts preserve review boundaries and do not provide specialized professional instructions
```

## Forbidden Scope

No hidden learning. No invisible personalization. No schema migration unless explicitly proven. No UI redesign. No hosted AI. No external surfaces. No specialized professional instructions.

## Validation

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealityReceiptTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealityClosureCorrectionTests
scripts/build-local.sh
git diff --check
scripts/run-doc-qa.sh || true
scripts/batch-train-gate-check.sh || true
```

## Hard Red Stop Conditions

Stop if implementation requires hidden learning, unreviewed persistence, user-data server, remote AI, schema migration without rollback, specialized professional instructions, or punitive closure copy.

## Claim Boundary

Allowed: Goal Reality has source-present receipt/closure/correction value loop. Forbidden: durable cross-session learning complete unless persistence is installed and proven.

## Rollback

Normal revert.

## Next Batch

`MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08`
