<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-026 - Blocked/waiting/still-counts journey

Linear issue: AMB-448
Project: Ambitions Experience Sovereignty Program
Milestone: M05 - Journey-Level Experience Proof

## Required Truth Checks

- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`

## Batch Goal

Prove blocked, waiting, and still-counts states are explicit, inspectable, and tied to realistic recovery options without hidden mutations.

## Implementation Scope

- `Native/Ambitions/Services/ExecutionResilienceProjector.swift`
- `Native/Ambitions/Services/GoalBelievabilityProjector.swift`
- `Native/Ambitions/Services/GoalResourceGraphService.swift`
- `Native/Ambitions/Services/RecommendationExplanationAdapter.swift`
- `Native/Ambitions/Features/Today`
- `Native/Ambitions/Features/Time`
- `Native/AmbitionsTests/Services/ExecutionResilienceProjectorTests.swift`
- `Native/AmbitionsTests/Services/GoalBelievabilityProjectorTests.swift`
- `Native/AmbitionsTests/Today/TodayFreshGoalVisibilityTests.swift`
- `Native/AmbitionsTests/Today/TodayRealityMeridianExperienceElevationTests.swift`

## Required Product Outcomes

- Blocked and waiting status is legible before action.
- Still-counts and recovery text is explicit and user-controlled.
- Receipt and fallback continuity is preserved when state changes.

## Required Evidence Packet

Create: `build/reports/aesp/AESP-026/blocked-waiting-still-counts-journey-evidence.md`

## Required Validation

```bash
xcodegen generate
make xcode-build-for-testing BATCH=AESP-026
make xcode-focused-test BATCH=AESP-026 TEST=AmbitionsTests/Services/ExecutionResilienceProjectorTests
make xcode-focused-test BATCH=AESP-026 TEST=AmbitionsTests/Services/GoalBelievabilityProjectorTests
make xcode-focused-test BATCH=AESP-026 TEST=AmbitionsTests/Today/TodayFreshGoalVisibilityTests
make xcode-focused-test BATCH=AESP-026 TEST=AmbitionsTests
```
