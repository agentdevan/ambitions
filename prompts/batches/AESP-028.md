<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-028 - VoiceOver object model

Linear issue: AMB-450
Project: Ambitions Experience Sovereignty Program
Milestone: M06 - Accessibility and Cognitive Excellence

## Required Truth Checks

- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/accessibility/AMB_ACCESSIBILITY_MOAT_MATRIX.md`

## Batch Goal

Verify VoiceOver object semantics for core surfaces: labels, hints, values, ordering, rotor grouping, and state summaries.

## Implementation Scope

- `Native/Ambitions/Features/*`
- `Native/Ambitions/Runtime`
- `Native/Ambitions/UI`
- `Native/Ambitions/Tests` (accessibility-oriented fixtures as needed)
- `Native/AmbitionsTests/App/AccessibilityAdaptiveInterfaceDesignSystemTests.swift`
- `Native/AmbitionsTests/App/AccessibilityNutritionChecklistTests.swift`
- `Native/AmbitionsTests/App/PanelDensitySizeDesignSystemTests.swift`

## Required Product Outcomes

- Primary objects expose consistent VoiceOver identities and summaries.
- State and receipt paths remain discoverable through assistive traversal.
- Object-level labels do not encode unsupported or private claims.

## Required Evidence Packet

Create: `build/reports/aesp/AESP-028/voiceover-object-model-evidence.md`

## Required Validation

```bash
xcodegen generate
make xcode-build-for-testing BATCH=AESP-028
make xcode-focused-test BATCH=AESP-028 TEST=AmbitionsTests/App/AccessibilityAdaptiveInterfaceDesignSystemTests
make xcode-focused-test BATCH=AESP-028 TEST=AmbitionsTests/App/AccessibilityNutritionChecklistTests
make xcode-focused-test BATCH=AESP-028 TEST=AmbitionsTests/App/PanelDensitySizeDesignSystemTests
make xcode-focused-test BATCH=AESP-028 TEST=AmbitionsTests
```
