# AMB-570 Accessibility Fallback Primitive Family

Status: Green for the scoped primitive contract install.
Date: 2026-06-08
Base SHA: 7184600174f26ff89cfa3d547d0f61a3707f8f53

## Scope

AMB-570 installed a shared accessibility fallback contract for new Ambitions primitives. The contract records required fallback behavior for Dynamic Type, Reduce Motion, Reduce Transparency, and Increase Contrast before later primitive adoption work.

This issue does not install a new user-facing surface, change product IA, alter runtime intelligence, or produce public accessibility proof.

## Files Changed

- `Sources/Components/AccessibilityAdaptiveInterfacePrimitives.swift`
- `Native/AmbitionsTests/App/AccessibilityAdaptiveInterfaceDesignSystemTests.swift`
- `docs/codex/ambitions_primitive_invention_registry.md`
- `docs/codex/concept-lock-registry.yml`
- `artifacts/ambitions-ui-reconstruction/primitive-install/AMB-570-accessibility-fallback-family.md`

## Behavior Recorded

Dynamic Type:

- `AmbitionsPrimitiveAccessibilityFallbackProfile` records that the source, freshness, trust, and receipt items can stack vertically at accessibility text sizes.
- `AmbitionsPrimitiveAccessibilityFallbackModifier` adds scoped padding when `dynamicTypeSize.isAccessibilitySize` is true.

Reduce Motion:

- The profile records that the primitive remains understandable as static source and receipt state.
- The modifier clears scoped SwiftUI transaction animation when `accessibilityReduceMotion` is true.

Reduce Transparency:

- The profile records that translucent material can flatten into an opaque semantic fill without hiding state.
- The modifier applies `theme.colors.surfaceOverlay` behind the primitive when `accessibilityReduceTransparency` is true.

Increase Contrast:

- The profile records that item borders, labels, and symbols preserve meaning instead of relying on color alone.
- The modifier adds an explicit border when `colorSchemeContrast == .increased`.

## Registry

- Added `accessibility-fallback-contract` to `docs/codex/ambitions_primitive_invention_registry.md`.
- Added AMB-570 to the `design_primitives` concept-lock allowance in `docs/codex/concept-lock-registry.yml`.

## Validation

Champion coverage:

- Command: `python3 scripts/ambitions-champion-coverage-check.py`
- Result: Green
- Report: `build/reports/intelligence-consolidation/champion-coverage-check.md`

Parallel implementation guard pre:

- Command: `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-570 --prompt docs/codex/ambitions_primitive_invention_registry.md`
- Result: Green
- Report: `build/reports/parallel-implementation-guard/AMB-570-pre.md`

Parallel implementation guard post:

- Command: `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-570 --prompt docs/codex/ambitions_primitive_invention_registry.md --changed-from 7184600174f26ff89cfa3d547d0f61a3707f8f53`
- Result: Green
- Report: `build/reports/parallel-implementation-guard/AMB-570-post.md`

Focused Xcode validation:

- Command: `make xcode-focused-test BATCH=AMB-570 TEST=AmbitionsTests/AccessibilityAdaptiveInterfaceDesignSystemTests`
- Result: Passed
- Build log: `.codex/xcode-logs/AMB-570/20260608T071110Z-bft-82786-9387/build-for-testing.log`
- Test log: `.codex/xcode-logs/AMB-570/20260608T071834Z-AmbitionsTests-AccessibilityAdaptiveInterfaceDesignSystemTests-84805-30616/focused-test.log`
- Result bundle: `.codex/xcode-results/AMB-570/20260608T071834Z-AmbitionsTests-AccessibilityAdaptiveInterfaceDesignSystemTests-84805-30616/focused-test.xcresult`
- Summary: `Executed 11 tests, with 0 failures (0 unexpected)`.

Claim and diff scans:

- Command: `python3 scripts/ambitions-unsupported-claim-scan.py Sources/Components/AccessibilityAdaptiveInterfacePrimitives.swift Native/AmbitionsTests/App/AccessibilityAdaptiveInterfaceDesignSystemTests.swift docs/codex/ambitions_primitive_invention_registry.md docs/codex/concept-lock-registry.yml artifacts/ambitions-ui-reconstruction/primitive-install/AMB-570-accessibility-fallback-family.md`
- Result: Green
- Command: `bash scripts/codex-forbidden-claim-scan.sh Sources/Components/AccessibilityAdaptiveInterfacePrimitives.swift Native/AmbitionsTests/App/AccessibilityAdaptiveInterfaceDesignSystemTests.swift docs/codex/ambitions_primitive_invention_registry.md docs/codex/concept-lock-registry.yml artifacts/ambitions-ui-reconstruction/primitive-install/AMB-570-accessibility-fallback-family.md`
- Result: No blocking hits; one context-only existing accessibility primitive line remained non-blocking.
- Command: `git diff --check`
- Result: Passed
- Command: `bash scripts/release-claim-safety-scan.sh`
- Result: Green

## Screenshot Artifacts

- None. AMB-570 creates a shared contract and modifier but does not add a rendered product surface or update visual baselines.

## Proof Boundaries

- Manual VoiceOver walkthrough was not run.
- Manual Dynamic Type screenshot review was not run.
- Manual Reduce Motion walkthrough was not run.
- Manual Reduce Transparency screenshot review was not run.
- Manual Increase Contrast screenshot review was not run.
- Physical-device validation was not run.
- No release, TestFlight, App Store, public accessibility, privacy/legal, performance, or device readiness claim is made.

## Yellow Items

- None for the scoped source/test/report install.

## Rollback

- Remove `AmbitionsPrimitiveAccessibilityFallbackAxis`, `AmbitionsPrimitiveAccessibilityFallbackBehavior`, `AmbitionsPrimitiveAccessibilityFallbackProfile`, `AmbitionsPrimitiveAccessibilityFallbackModifier`, and `View.ambitionsPrimitiveAccessibilityFallback(_:)` from `Sources/Components/AccessibilityAdaptiveInterfacePrimitives.swift`.
- Remove AMB-570 tests from `Native/AmbitionsTests/App/AccessibilityAdaptiveInterfaceDesignSystemTests.swift`.
- Remove the `accessibility-fallback-contract` registry entry.
- Remove AMB-570 from the `design_primitives` concept-lock allowance.
