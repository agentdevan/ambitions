<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# MOAT-GOAL-REALITY-EVAL-HARNESS-10 — Founder-Grade Evaluation Harness

## Batch ID

`MOAT-GOAL-REALITY-EVAL-HARNESS-10`

## Runner Command

```bash
scripts/ambitions-codex-train.sh MOAT-GOAL-REALITY-EVAL-HARNESS-10 prompts/batches/MOAT-GOAL-REALITY-EVAL-HARNESS-10.md
```

## Objective

Install a founder-grade evaluation harness for the Goal Reality Compiler so every future change can be regression-tested against Ambitions’ moat: truth honesty, risk routing, proof-gate quality, receipt completeness, local-only boundary, no hidden mutation, no guarantee language, no shame language, source/professional boundaries, and Today step reversibility.

## Source Truth To Inspect

```text
docs/truth/IMPLEMENTATION_TRUTH.md
docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md
docs/audits/goal-reality-golden-fixture-matrix.md
Native/Ambitions/Runtime/GoalRealityCompiler.swift
Native/Ambitions/Runtime/GoalRealityValidator.swift
Native/Ambitions/Runtime/GoalRealityFixtureLab.swift
Native/Ambitions/Runtime/GoalRealitySourceBoundaryService.swift
Native/AmbitionsTests/Runtime/GoalRealityGoldenFixtureTests.swift
Native/AmbitionsTests/Runtime/GoalRealityNegativeFixtureTests.swift
```

## Allowed Scope

```text
Native/Ambitions/Runtime/GoalRealityEvaluationHarness.swift
Native/Ambitions/Runtime/GoalRealityFixtureLab.swift
Native/AmbitionsTests/Runtime/GoalRealityEvaluationHarnessTests.swift
scripts/goal-reality-eval-harness.py or similar if repo script style supports it
docs/audits/moat-goal-reality-eval-harness-10-report.md
docs/audits/goal-reality-evaluation-scorecard.md
docs/truth/IMPLEMENTATION_TRUTH.md
```

## Required Evaluation Dimensions

Score each fixture on:

```text
truth honesty
risk lane correctness
operating level correctness
proof gate quality
Today step reversibility
receipt completeness
blocked behavior correctness
source/professional boundary correctness
non-shaming closure language
no guarantee language
no confidence score
no hidden mutation
local-only boundary
correction controls
privacy posture
```

Scores should be deterministic and testable. Prefer simple pass/fail plus optional numeric summary. Do not create user-facing scores.

## Required Behavior

The harness must:

```text
run all golden fixtures
run all negative fixtures
produce per-fixture evaluation records
fail if any Hard Red condition is present
produce a scorecard artifact
support future fixture additions without rewriting compiler logic
```

## Required Tests

Prove:

```text
all fixture records evaluate
bad outputs fail evaluation
good outputs pass evaluation
missing receipt fails
hidden mutation fails
remote dependency fails
source-sensitive overclaim fails
shame/guarantee language fails
scorecard is deterministic
```

## Forbidden Scope

No user-facing score UI. No hosted evaluation service. No remote model judge. No analytics. No release claim. No broad product rewrite.

## Validation

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealityEvaluationHarnessTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealityGoldenFixtureTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealityNegativeFixtureTests
scripts/build-local.sh
git diff --check
scripts/run-doc-qa.sh || true
scripts/batch-train-gate-check.sh || true
```

If a script is added:

```bash
python3 scripts/goal-reality-eval-harness.py
```

## Hard Red Stop Conditions

Stop if evaluation requires remote AI, network, user telemetry, user-facing scoring, or weakening validators.

## Claim Boundary

Allowed: Goal Reality Compiler has a local deterministic evaluation harness. Forbidden: production readiness or exhaustive real-world coverage.

## Rollback

Normal revert.

## Final Expected Claim

Only if Batches 01-10 are all Green or explicitly accepted Yellow:

```text
Ambitions has a local Goal Reality Compiler that converts risky, vague, moonshot, regulated, or emotionally loaded ambitions into proof-gated execution candidates with source/professional boundaries, reversible Today steps, non-shaming closure, correction controls, local-only posture, and inspectable receipts.
```
