<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# MOAT-GOAL-REALITY-FIXTURE-LAB-02 — Full Golden / Negative Goal Reality Fixture Lab

## Batch ID

`MOAT-GOAL-REALITY-FIXTURE-LAB-02`

## Runner Command

```bash
scripts/ambitions-codex-train.sh MOAT-GOAL-REALITY-FIXTURE-LAB-02 prompts/batches/MOAT-GOAL-REALITY-FIXTURE-LAB-02.md
```

## Objective

Expand the Goal Reality Compiler from selected core fixtures into a serious red-team fixture lab that proves Ambitions can safely handle common problematic goals across health, money, medicine, law/immigration, relationships, revenge/harm, burnout, perfectionism, creator fame, regulated careers, athletic moonshots, and irreversible life decisions.

This batch must make generic productivity behavior fail. The fixture lab must prove the compiler preserves the user’s North Star while routing execution through truth state, risk lane, proof permission, reversible Today step, receipt, and correction controls.

## Active Source Truth To Inspect

```text
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/CODEX_PROCESS_TRUTH.md
docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md
prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md
Native/Ambitions/Domain/GoalRealityModels.swift
Native/Ambitions/Domain/GoalRealityRiskModels.swift
Native/Ambitions/Domain/GoalRealityProofModels.swift
Native/Ambitions/Domain/GoalRealityReceiptModels.swift
Native/Ambitions/Runtime/GoalRealityCompiler.swift
Native/Ambitions/Runtime/GoalRealityValidator.swift
Native/Ambitions/Runtime/GoalRealityFixtureLab.swift
Native/AmbitionsTests/Runtime/GoalRealityCompilerCoreTests.swift
Native/AmbitionsTests/Runtime/GoalRealityGoldenFixtureTests.swift
Native/AmbitionsTests/Runtime/GoalRealityNegativeFixtureTests.swift
```

If any Batch 01 artifact is absent, stop and report Yellow/Red with the missing prerequisite. Do not invent incompatible duplicate models.

## Allowed Scope

Preferred touched files:

```text
Native/Ambitions/Runtime/GoalRealityFixtureLab.swift
Native/Ambitions/Runtime/GoalRealityCompiler.swift
Native/Ambitions/Runtime/GoalRealityValidator.swift
Native/AmbitionsTests/Runtime/GoalRealityGoldenFixtureTests.swift
Native/AmbitionsTests/Runtime/GoalRealityNegativeFixtureTests.swift
Native/AmbitionsTests/Runtime/GoalRealityReceiptTests.swift
Native/AmbitionsTests/Runtime/GoalRealityRuntimeBoundaryTests.swift
docs/audits/goal-reality-golden-fixture-matrix.md
docs/audits/moat-goal-reality-fixture-lab-02-report.md
docs/truth/IMPLEMENTATION_TRUTH.md
```

No UI. No persistence. No network. No hosted AI.

## Required Golden Fixtures

Install and prove all 20 golden fixtures from the master plan:

```text
01 olympic_swimmer_from_zero
02 rapid_weight_loss_two_months
03 stop_medication
04 day_trade_full_time
05 quit_job_become_millionaire
06 become_doctor_in_two_years
07 move_abroad_next_month
08 revenge_goal
09 make_partner_change
10 work_sixteen_hours_daily
11 become_famous_in_ninety_days
12 drop_out_start_company
13 buy_house_while_broke
14 start_family_while_unstable
15 never_feel_anxious_again
16 be_perfect_never_fail
17 cut_everyone_off_start_over
18 make_ten_k_month_music
19 fluent_japanese_three_months
20 become_billionaire
```

Each fixture must assert:

```text
North Star preserved or safely blocked
Active Path safe
Risk Lane correct
Operating Level correct
Truth State honest
Proof Permission correct
Proof Gate exists where needed
Today Safe Step absent or reversible
Blocked Behaviors correct
Receipt present and specific
Correction Controls present
No guarantee language
No confidence score
No shame/punitive language
No hidden mutation
Local-only boundary preserved
```

## Required Negative Fixtures

Install at least one negative fixture for every golden fixture. Negative fixtures must prove the validator rejects:

```text
guarantee language
AI/model confidence language
productivity score language
overdue/failure shame language
unsafe medical advice
financial speculation as income replacement
legal/immigration claim without source review
regulated career claim without source review
relationship coercion
revenge/retaliation
irreversible decision without review
high-volume physical training before baseline
hidden plan or commitment mutation
remote intelligence / user-data server dependency
```

## Fixture Matrix

Update or create:

```text
docs/audits/goal-reality-golden-fixture-matrix.md
```

For each fixture include:

```text
fixture id
raw goal
risk lane(s)
operating level
North Star
Active Path
first proof gate
Today candidate
blocked behaviors
receipt assertions
test coverage
known deferred integrations
```

## Validation

Run:

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealityGoldenFixtureTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealityNegativeFixtureTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealityReceiptTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealityRuntimeBoundaryTests
scripts/build-local.sh
git diff --check
scripts/run-doc-qa.sh || true
scripts/batch-train-gate-check.sh || true
```

## Hard Red Stop Conditions

Stop if fixture coverage requires unsafe advice, source-sensitive claims without sources, hosted AI, network, schema migration, UI redesign, hidden mutation, or weakened validators.

## Rollback

Normal commit revert. No data migration, entitlement, route, network, or release rollback should be needed.

## Expected Result

Green only if all 20 golden fixtures and matching negative fixtures pass. Yellow is acceptable only for non-blocking repo-wide doc/scanner backlog, not missing fixture coverage.

## Next Batch

`MOAT-GOAL-REALITY-RUNTIME-SERVICE-03`
