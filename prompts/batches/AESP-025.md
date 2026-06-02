<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-025 - Goal tension journey

Linear issue: AMB-447
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

Prove that goal-thread tension is surfaced with Today/Time continuity, visible proof, and recoverable next action posture.

## Implementation Scope

- `Native/Ambitions/Services/ExecutionResilienceProjector.swift`
- `Native/Ambitions/Services/LifeAreaAtlasProjector.swift`
- `Native/Ambitions/Services/GoalPathCompilerService.swift`
- `Native/Ambitions/Features/Goals`
- `Native/Ambitions/Features/Time`
- `Native/Ambitions/Features/Today`
- `Native/AmbitionsTests/Services/ExecutionResilienceProjectorTests.swift`
- `Native/AmbitionsTests/Services/LifeAreaAtlasProjectorTests.swift`
- `Native/AmbitionsTests/Goals/GoalExplainabilityProjectionTests.swift`
- `Native/AmbitionsTests/Today/TodayRealityMeridianExperienceElevationTests.swift`
- `Native/AmbitionsTests/Today/TodayShellIntegrationTests.swift`

## Required Product Outcomes

- Goal-thread tension is explicit and inspectable in goal, today, and time surfaces.
- Receipts/continuity links remain local and recoverable at each state transition.
- Recovery guidance is non-shaming and non-coercive.

## Required Evidence Packet

Create: `build/reports/aesp/AESP-025/goal-tension-journey-evidence.md`

## Required Validation

```bash
xcodegen generate
make xcode-build-for-testing BATCH=AESP-025
make xcode-focused-test BATCH=AESP-025 TEST=AmbitionsTests/Services/ExecutionResilienceProjectorTests
make xcode-focused-test BATCH=AESP-025 TEST=AmbitionsTests/Services/LifeAreaAtlasProjectorTests
make xcode-focused-test BATCH=AESP-025 TEST=AmbitionsTests/Goals/GoalExplainabilityProjectionTests
make xcode-focused-test BATCH=AESP-025 TEST=AmbitionsTests/Today/TodayRealityMeridianExperienceElevationTests
make xcode-focused-test BATCH=AESP-025 TEST=AmbitionsTests
```
