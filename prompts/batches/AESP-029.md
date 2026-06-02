<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-029 - Dynamic Type and layout resilience

Linear issue: AMB-451
Project: Ambitions Experience Sovereignty Program
Milestone: M06 - Accessibility and Cognitive Excellence

## Required Truth Checks

- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/accessibility/AMB_ACCESSIBILITY_MOAT_MATRIX.md`

## Batch Goal

Verify critical surfaces remain functional, readable, and unbroken across compact and accessibility-size layouts.

## Implementation Scope

- `Native/Ambitions/DesignSystem` / `Native/Ambitions/UI`
- `Native/Ambitions/Features/*`
- `Native/AmbitionsTests/App/PanelDensitySizeDesignSystemTests.swift`
- `Native/AmbitionsTests/App/AppShellNavigationTests.swift`
- `Native/AmbitionsTests/App/LiquidGlassTokenLayerTests.swift`

## Required Product Outcomes

- Text scales without truncation/overlap on top-level and drill-down surfaces.
- Primary actions remain visible and reachable.
- Layout constraints remain stable across dense and compact viewport variants.

## Required Evidence Packet

Create: `build/reports/aesp/AESP-029/dynamic-type-layout-resilience-evidence.md`

## Required Validation

```bash
xcodegen generate
make xcode-build-for-testing BATCH=AESP-029
make xcode-focused-test BATCH=AESP-029 TEST=AmbitionsTests/App/PanelDensitySizeDesignSystemTests
make xcode-focused-test BATCH=AESP-029 TEST=AmbitionsTests/App/AppShellNavigationTests
make xcode-focused-test BATCH=AESP-029 TEST=AmbitionsTests
```
