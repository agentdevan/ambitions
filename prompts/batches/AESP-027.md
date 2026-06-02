<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-027 - User correction journey

Linear issue: AMB-449
Project: Ambitions Experience Sovereignty Program
Milestone: M05 - Journey-Level Experience Proof

## Required Truth Checks

- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`

## Runtime Contract Boundary

- Preserve and expose `SourceRecord`, `Receipt`, and `ReplayTrace` continuity for any runtime-affecting change.
- Include explicit `What Ambitions Knows` / You inspection so state transitions remain explainable.

## Batch Goal

Prove users can inspect and correct runtime assumptions without hidden mutation, with local learning, receipts, and reset/delete boundaries visible.

## Implementation Scope

- `Native/Ambitions/Features/Goals`
- `Native/Ambitions/Features/Today`
- `Native/Ambitions/Services/GoalClarificationService.swift`
- `Native/Ambitions/Services/PolicyGuardedCommandExecutor.swift`
- `Native/Ambitions/Tests/Runtime` (where correction/runtime paths are tested)
- `Native/AmbitionsTests/Goals/GoalDetailExplainabilityActionTests.swift`
- `Native/AmbitionsTests/Goals/GoalExplainabilityProjectionTests.swift`
- `Native/AmbitionsTests/Services/PolicyGuardedCommandExecutorTests.swift`
- `Native/AmbitionsTests/Runtime/CaptureRuntimeGauntletTests.swift`

## Required Product Outcomes

- Correction and reset/delete routes are explicit and inspectable.
- Runtime assumptions remain recoverable and justified by local receipts.
- Corrections preserve privacy and local-first history/continuity.

## Required Evidence Packet

Create: `build/reports/aesp/AESP-027/user-correction-journey-evidence.md`

## Required Validation

```bash
xcodegen generate
make xcode-build-for-testing BATCH=AESP-027
make xcode-focused-test BATCH=AESP-027 TEST=AmbitionsTests/Goals/GoalDetailExplainabilityActionTests
make xcode-focused-test BATCH=AESP-027 TEST=AmbitionsTests/Goals/GoalExplainabilityProjectionTests
make xcode-focused-test BATCH=AESP-027 TEST=AmbitionsTests/Services/PolicyGuardedCommandExecutorTests
make xcode-focused-test BATCH=AESP-027 TEST=AmbitionsTests
```
