<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-032 - Accessibility device-truth packet

Linear issue: AMB-454
Project: Ambitions Experience Sovereignty Program
Milestone: M06 - Accessibility and Cognitive Excellence

## Required Truth Checks

- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/accessibility/AMB_ACCESSIBILITY_MOAT_MATRIX.md`

## Runtime Contract Boundary

- Preserve and expose `SourceRecord`, `Receipt`, and `ReplayTrace` continuity for any runtime-affecting change.
- Include explicit `What Ambitions Knows` / You inspection so state transitions remain explainable.

## Batch Goal

Assemble and maintain the accessibility device-truth packet with clear verified/unverified/not verified/blocked outcomes for VoiceOver, Dynamic Type, Reduce Motion, contrast, tap targets, and journey surfaces.

## Scope

- `build/reports/aesp/AESP-0[0-9][0-9]/*`
- `build/reports/aesp/AESP-032/*`
- `scripts/accessibility-cognitive-load-scan.sh`
- `scripts/accessibility-ui-batch-readiness-scan.sh`
- `scripts/cqs-accessibility-motion-scan.sh`
- `scripts/cqs-privacy-security-claim-scan.sh`
- `scripts/dav-dynamic-type-evidence-check.sh`
- `scripts/dav-reduce-motion-check.sh`
- `Native/AmbitionsTests/App/AccessibilityAdaptiveInterfaceDesignSystemTests.swift`
- `Native/AmbitionsTests/App/AccessibilityNutritionChecklistTests.swift`
- `Native/AmbitionsTests/App/PanelDensitySizeDesignSystemTests.swift`

## Required Product Outcomes

- Device accessibility evidence packet is reproducible and explicit.
- Verification matrix records test status and environment details.
- Unsupported or skipped checks are named and owned as Yellow/blocked.

## Required Evidence Packet

Create: `build/reports/aesp/AESP-032/accessibility-device-truth-packet-evidence.md`

## Required Validation

```bash
xcodegen generate
make xcode-build-for-testing BATCH=AESP-032
make xcode-focused-test BATCH=AESP-032 TEST=AmbitionsTests/App/AccessibilityAdaptiveInterfaceDesignSystemTests
make xcode-focused-test BATCH=AESP-032 TEST=AmbitionsTests/App/AccessibilityNutritionChecklistTests
make xcode-focused-test BATCH=AESP-032 TEST=AmbitionsTests/App/PanelDensitySizeDesignSystemTests
./scripts/accessibility-cognitive-load-scan.sh
./scripts/dav-dynamic-type-evidence-check.sh
./scripts/dav-reduce-motion-check.sh
```
