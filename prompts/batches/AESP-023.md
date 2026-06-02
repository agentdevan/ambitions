<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-023 - Overloaded Day recovery journey

Linear issue: AMB-445
Project: Ambitions Experience Sovereignty Program
Milestone: M05 - Journey-Level Experience Proof

## Required Truth Checks

- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`

## Runtime Contract Boundary

- Preserve and expose `SourceRecord`, `Receipt`, and `ReplayTrace` continuity for any runtime-affecting change.
- Include explicit `What Ambitions Knows` / You inspection so state transitions remain explainable.

## Batch Goal

Prove recovery from overloaded-day pressure with non-shaming language, clear receipt path, and user-visible control.

## Implementation Scope

- `Native/Ambitions/Services/ExecutionResilienceProjector.swift`
- `Native/Ambitions/Services/ExecutionResilienceProjector.swift` and runtime callers
- `Native/Ambitions/Features/Time`, `Native/Ambitions/Features/Today`
- `Native/Ambitions/Tests/Runtime`

## Required Product Outcomes

- Overload/low-capacity conditions are explicitly stated and inspectable.
- Recovery option is not coercive.
- Receipt/history continuity remains intact.

## Required Tests

- `Native/AmbitionsTests/Runtime/ExecutionResilience*`
- `Native/AmbitionsTests/Today/TodayDerivedReadModelCacheTests.swift`
- `Native/AmbitionsTests/App/CoreSurfaceIntegrationScenarioTests.swift`

## Required Evidence Packet

Create: `build/reports/aesp/AESP-023/overloaded-day-recovery-journey-evidence.md`

## Required Validation

```bash
xcodegen generate
make xcode-build-for-testing BATCH=AESP-023
make xcode-focused-test BATCH=AESP-023 TEST=AmbitionsTests/Runtime
make xcode-focused-test BATCH=AESP-023 TEST=AmbitionsTests/Today/TodayDerivedReadModelCacheTests
make xcode-focused-test BATCH=AESP-023 TEST=AmbitionsTests
```
