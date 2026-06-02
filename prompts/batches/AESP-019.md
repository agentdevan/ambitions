<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-019 - Motion grammar

Linear issue: AMB-441
Project: Ambitions Experience Sovereignty Program
Milestone: M04 - Visual System, Motion, and Haptics

## Required Truth Checks

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`

## Batch Goal

Formalize motion grammar per surface/state and attach non-motion alternatives for Reduce Motion settings while preserving intent and inspection value.

## Implementation Scope

- `Native/Ambitions/App`
- `Native/Ambitions/Features`
- `Native/Ambitions/UI`
- `Native/AmbitionsTests/App/InteractionMotionHapticsDesignSystemTests.swift`

## Product Outcomes

- Motion uses are explicit and purposeful.
- No motion-only information.
- Reduce Motion is a first-class equivalent.

## Evidence Packet

Create: `build/reports/aesp/AESP-019/motion-grammar-evidence.md`

## Required Validation

```bash
xcodegen generate
make xcode-build-for-testing BATCH=AESP-019
make xcode-focused-test BATCH=AESP-019 TEST=AmbitionsTests/App/InteractionMotionHapticsDesignSystemTests
make xcode-focused-test BATCH=AESP-019 TEST=AmbitionsTests/App/AppShellNavigationTests
make xcode-focused-test BATCH=AESP-019 TEST=AmbitionsTests
```

