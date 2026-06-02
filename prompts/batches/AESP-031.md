<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-031 - Cognitive clarity and recovery language

Linear issue: AMB-453
Project: Ambitions Experience Sovereignty Program
Milestone: M06 - Accessibility and Cognitive Excellence

## Required Truth Checks

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/accessibility/AMB_ACCESSIBILITY_MOAT_MATRIX.md`

## Batch Goal

Review and harden copy/interaction language for clarity, non-shame posture, and recovery/waiting/blocked state communication across user-facing surfaces.

## Implementation Scope

- `Native/Ambitions/Features/Goals`
- `Native/Ambitions/Features/Today`
- `Native/Ambitions/Features/Time`
- `Native/Ambitions/Features/You`
- `Native/Ambitions/Runtime`
- `Native/AmbitionsTests/Goals/GoalDetailStrategicPresentationTests.swift`
- `Native/AmbitionsTests/Goals/GoalsShellIntegrationTests.swift`
- `Native/AmbitionsTests/Today/TodayFreshGoalVisibilityTests.swift`
- `Native/AmbitionsTests/App/AccessibilityNutritionChecklistTests.swift`

## Required Product Outcomes

- Core copy uses plain, calm, non-judgmental language.
- Recovery messaging is explicit about options and consequences.
- Banned language patterns are removed from tested user paths.

## Required Evidence Packet

Create: `build/reports/aesp/AESP-031/cognitive-clarity-and-recovery-language-evidence.md`

## Required Validation

```bash
xcodegen generate
make xcode-build-for-testing BATCH=AESP-031
make xcode-focused-test BATCH=AESP-031 TEST=AmbitionsTests/Goals/GoalDetailStrategicPresentationTests
make xcode-focused-test BATCH=AESP-031 TEST=AmbitionsTests/Today/TodayFreshGoalVisibilityTests
make xcode-focused-test BATCH=AESP-031 TEST=AmbitionsTests/App/AccessibilityNutritionChecklistTests
make xcode-focused-test BATCH=AESP-031 TEST=AmbitionsTests
```
