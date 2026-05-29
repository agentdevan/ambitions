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

# MOAT-GOAL-REALITY-TODAY-BRIDGE-06 — Today Safe Start Here Bridge

## Batch ID

`MOAT-GOAL-REALITY-TODAY-BRIDGE-06`

## Runner Command

```bash
scripts/ambitions-codex-train.sh MOAT-GOAL-REALITY-TODAY-BRIDGE-06 prompts/batches/MOAT-GOAL-REALITY-TODAY-BRIDGE-06.md
```

## Objective

Bridge Goal Reality outputs into Today so the app can surface exactly one safe, reversible, proof-gated Start Here candidate from a complex/risky ambition without redesigning Today or turning it into a goal surface.

## Source Truth To Inspect

```text
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md
Native/Ambitions/Features/Today/TodayExecutionProjector.swift
Native/Ambitions/Features/Today/DayRailViewState.swift
Native/Ambitions/Features/Today/TodayFeatureService.swift
Native/Ambitions/PreviewSupport/PreviewTodayScenarios.swift
Native/Ambitions/Runtime/GoalRealityRuntimeService.swift
Native/Ambitions/Domain/GoalRealityModels.swift
Native/AmbitionsTests/Today/TodayViewModelTests.swift
Native/AmbitionsTests/Runtime/GoalRealityGoldenFixtureTests.swift
```

## Allowed Scope

```text
Native/Ambitions/Features/Today/GoalRealityTodayBridge.swift
Native/Ambitions/Features/Today/TodayExecutionProjector.swift
Native/Ambitions/Features/Today/DayRailViewState.swift
Native/Ambitions/Features/Today/TodayFeatureService.swift
Native/Ambitions/PreviewSupport/PreviewTodayScenarios.swift
Native/AmbitionsTests/Today/GoalRealityTodayBridgeTests.swift
Native/AmbitionsTests/Today/TodayViewModelTests.swift
docs/audits/moat-goal-reality-today-bridge-06-report.md
docs/truth/IMPLEMENTATION_TRUTH.md
```

## Required Behavior

Today may receive only a safe candidate:

```text
one Start Here candidate
proof gate reference
because line
receipt seam
closure prompt
source/review label
no hidden mutation
no full risky plan
```

If a Goal Reality output is blocked/hold-only, Today must not surface it as an execution step. It may surface a safe review/closure/protection candidate only if the runtime marks it allowed.

Olympic swimmer expected Today candidate:

```text
Start here: Book adult beginner swim assessment
Because: The first proof gate is water safety, not Olympic training volume.
Receipt seam: preserved North Star, refused Olympic feasibility assumption, next unlock.
```

## Required Tests

Prove:

```text
safe GoalRealityOutput maps into Today candidate
blocked output does not become executable Today step
receipt seam is present
closure prompt uses non-shaming options
because line is specific
no training/fantasy/guarantee language appears
private/sensitive source labels are respected
Today does not mutate goal/plan state
```

## Forbidden Scope

No Today redesign. No new top-level route. No calendar clone. No schema migration. No notification/widget/Live Activity. No hosted AI. No release claims.

## Validation

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealityTodayBridgeTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/TodayViewModelTests
scripts/build-local.sh
git diff --check
scripts/run-doc-qa.sh || true
scripts/batch-train-gate-check.sh || true
```

## Visual Proof

If Today preview is touched, provide preview/screenshot proof. Do not claim final visual quality, accessibility conformance, device proof, or release readiness.

## Hard Red Stop Conditions

Stop if Today integration requires broad redesign, hidden mutation, risky execution step, new route/tab, source-sensitive overclaiming, hosted AI, or schema migration without rollback proof.

## Claim Boundary

Allowed: Today can project a safe Goal Reality Start Here candidate in source/tests. Forbidden: all Today recommendations are Goal Reality-driven.

## Rollback

Normal revert.

## Next Batch

`MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07`

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
