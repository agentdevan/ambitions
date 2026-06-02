<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-022 - Morning Start journey

Linear issue: AMB-444
Project: Ambitions Experience Sovereignty Program
Milestone: M05 - Journey-Level Experience Proof

## Required Truth Checks

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`

## Scope Notes

- Journey starts from current Reality Meridian/Today state and must show start/review/inspection flow.
- Verify no top-level IA drift and no score-only framing.

## Batch Goal

Prove morning launch through recommendation inspection, source/fact visibility, start action, and recovery-safe fallback in the app sequence.

## Implementation Scope

- `Native/Ambitions/Features/Today`
- `Native/Ambitions/App/AppShellNavigationTests.swift`
- `Native/Ambitions/Features/Time`
- `Native/Ambitions/Services`

## Required Product Outcomes

- `Today` start remains inspected, local, and honest.
- Source/receipt visibility before any mutable action.
- Recovery path is non-invasive and explicit.

## Required Tests

- `Native/AmbitionsTests/Today/TodayRealityMeridianExperienceElevationTests.swift`
- `Native/AmbitionsTests/Today/TodayShellIntegrationTests.swift`
- `Native/AmbitionsTests/App/CoreSurfaceIntegrationScenarioTests.swift`

## Required Evidence Packet

Create: `build/reports/aesp/AESP-022/morning-start-journey-evidence.md`

## Required Validation

```bash
xcodegen generate
make xcode-build-for-testing BATCH=AESP-022
make xcode-focused-test BATCH=AESP-022 TEST=AmbitionsTests/Today/TodayRealityMeridianExperienceElevationTests
make xcode-focused-test BATCH=AESP-022 TEST=AmbitionsTests/App/CoreSurfaceIntegrationScenarioTests
make xcode-focused-test BATCH=AESP-022 TEST=AmbitionsTests
```

