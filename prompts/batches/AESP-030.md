<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-030 - Reduce Motion and semantic alternatives

Linear issue: AMB-452
Project: Ambitions Experience Sovereignty Program
Milestone: M06 - Accessibility and Cognitive Excellence

## Required Truth Checks

- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/accessibility/AMB_ACCESSIBILITY_MOAT_MATRIX.md`

## Batch Goal

Ensure every meaningful motion-driven state has deterministic non-motion alternatives that preserve meaning, continuity, and relationship.

## Implementation Scope

- `Native/Ambitions/Features/*`
- `Native/Ambitions/UI`
- `Native/Ambitions/App`
- `Native/AmbitionsTests/App/InteractionMotionHapticsDesignSystemTests.swift`
- `Native/AmbitionsTests/App/LoadingDegradedStateDesignSystemTests.swift`

## Required Product Outcomes

- Motion-based meaning has static equivalents.
- Reduced Motion users preserve receipt/source/state visibility.
- No motion-only state transitions.

## Required Evidence Packet

Create: `build/reports/aesp/AESP-030/reduce-motion-and-semantic-alternatives-evidence.md`

## Required Validation

```bash
xcodegen generate
make xcode-build-for-testing BATCH=AESP-030
make xcode-focused-test BATCH=AESP-030 TEST=AmbitionsTests/App/InteractionMotionHapticsDesignSystemTests
make xcode-focused-test BATCH=AESP-030 TEST=AmbitionsTests/App/LoadingDegradedStateDesignSystemTests
make xcode-focused-test BATCH=AESP-030 TEST=AmbitionsTests/App/AppShellNavigationTests
make xcode-focused-test BATCH=AESP-030 TEST=AmbitionsTests
```
