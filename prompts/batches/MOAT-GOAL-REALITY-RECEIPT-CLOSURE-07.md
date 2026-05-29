<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-file-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
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
