# AMB-571 Semantic Token Extensions

Status: Green for the scoped semantic token extension.
Date: 2026-06-08
Base SHA: 32cbbee52fa71126527b90f4800ccec13efd28e8

## Scope

AMB-571 added semantic tokens only for already installed primitive behavior:

- `SourceTrustReceiptStrip`
- `AmbitionsPrimitiveAccessibilityFallbackModifier`

The patch does not add decorative color tokens, new surfaces, product IA, runtime intelligence, or generated token files.

## Files Changed

- `Sources/Theme/AmbitionTheme.swift`
- `Sources/Components/TrustReceiptLayerPrimitives.swift`
- `Sources/Components/AccessibilityAdaptiveInterfacePrimitives.swift`
- `Native/AmbitionsTests/App/AppearancePreferenceTests.swift`
- `Native/AmbitionsTests/App/TrustReceiptLayerDesignSystemTests.swift`
- `docs/codex/ambitions_primitive_invention_registry.md`
- `docs/codex/concept-lock-registry.yml`
- `artifacts/ambitions-ui-reconstruction/primitive-install/AMB-571-semantic-token-extensions.md`

## Added Tokens

| Token ID | Installed primitive | Behavior use | Accessibility / contrast implication |
|---|---|---|---|
| `primitive.source` | `SourceTrustReceiptStrip` | Current source and freshness labels. | Paired with source text and symbol labels; color is not the only state channel. |
| `primitive.sourceAttention` | `SourceTrustReceiptStrip` | Source states that require attention before reuse. | Paired with stale or blocked labels and role symbols. |
| `primitive.privacyBoundary` | `SourceTrustReceiptStrip` | Private or protected trust boundary labels. | Paired with privacy/trust copy and lock or shield symbols. |
| `primitive.receipt` | `SourceTrustReceiptStrip` | Receipt path and proof-available labels. | Paired with receipt copy and document symbols. |
| `primitive.accessibilityFallbackSurface` | `AmbitionsPrimitiveAccessibilityFallbackModifier` | Opaque primitive surface when Reduce Transparency is active. | Preserves contrast when transparency is reduced. |
| `primitive.accessibilityContrastStroke` | `AmbitionsPrimitiveAccessibilityFallbackModifier` | Explicit primitive border when Increase Contrast is active. | Strengthens boundaries for increased contrast without adding a new surface. |

## Implementation Notes

- Added `AmbitionTheme.PrimitiveSemanticColors` as computed theme values derived from existing semantic colors and foundation colors.
- Added `AmbitionPrimitiveSemanticToken` as the exact token inventory with installed primitive, behavior, and accessibility implications.
- Updated `SourceTrustReceiptStripItem.primitiveSemanticToken` so strip role/state mapping is testable.
- Updated `AmbitionsPrimitiveAccessibilityFallbackModifier` to use the Reduce Transparency surface token and Increase Contrast stroke token.
- Recorded the token registry entries in `docs/codex/ambitions_primitive_invention_registry.md`.
- Added AMB-571 to the design primitive concept-lock allowance.

## Validation

Champion coverage:

- Command: `python3 scripts/ambitions-champion-coverage-check.py`
- Result: Green
- Report: `build/reports/intelligence-consolidation/champion-coverage-check.md`

Parallel implementation guard pre:

- Command: `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-571 --prompt docs/codex/ambitions_primitive_invention_registry.md`
- Result: Green
- Report: `build/reports/parallel-implementation-guard/AMB-571-pre.md`

Parallel implementation guard post:

- Command: `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-571 --prompt docs/codex/ambitions_primitive_invention_registry.md --changed-from 32cbbee52fa71126527b90f4800ccec13efd28e8`
- Result: Green
- Report: `build/reports/parallel-implementation-guard/AMB-571-post.md`

Focused Xcode validation:

- Command: `make xcode-focused-test BATCH=AMB-571 TEST=AmbitionsTests/TrustReceiptLayerDesignSystemTests`
- Result: Passed
- Build log: `.codex/xcode-logs/AMB-571/20260608T073009Z-bft-89266-13723/build-for-testing.log`
- Test log: `.codex/xcode-logs/AMB-571/20260608T073835Z-AmbitionsTests-TrustReceiptLayerDesignSystemTests-92026-22928/focused-test.log`
- Result bundle: `.codex/xcode-results/AMB-571/20260608T073835Z-AmbitionsTests-TrustReceiptLayerDesignSystemTests-92026-22928/focused-test.xcresult`
- Summary: `Executed 11 tests, with 0 failures (0 unexpected)`.

- Command: `make xcode-focused-test BATCH=AMB-571 TEST=AmbitionsTests/AppearancePreferenceTests`
- Result: Passed
- Build log: `.codex/xcode-logs/AMB-571/20260608T074118Z-bft-92935-18424/build-for-testing.log`
- Test log: `.codex/xcode-logs/AMB-571/20260608T074314Z-AmbitionsTests-AppearancePreferenceTests-93296-22136/focused-test.log`
- Result bundle: `.codex/xcode-results/AMB-571/20260608T074314Z-AmbitionsTests-AppearancePreferenceTests-93296-22136/focused-test.xcresult`
- Summary: `Executed 6 tests, with 0 failures (0 unexpected)`.

Claim and diff scans:

- Command: `python3 scripts/ambitions-unsupported-claim-scan.py Sources/Theme/AmbitionTheme.swift Sources/Components/TrustReceiptLayerPrimitives.swift Sources/Components/AccessibilityAdaptiveInterfacePrimitives.swift Native/AmbitionsTests/App/AppearancePreferenceTests.swift Native/AmbitionsTests/App/TrustReceiptLayerDesignSystemTests.swift docs/codex/ambitions_primitive_invention_registry.md docs/codex/concept-lock-registry.yml artifacts/ambitions-ui-reconstruction/primitive-install/AMB-571-semantic-token-extensions.md`
- Result: Green
- Command: `bash scripts/codex-forbidden-claim-scan.sh Sources/Theme/AmbitionTheme.swift Sources/Components/TrustReceiptLayerPrimitives.swift Sources/Components/AccessibilityAdaptiveInterfacePrimitives.swift Native/AmbitionsTests/App/AppearancePreferenceTests.swift Native/AmbitionsTests/App/TrustReceiptLayerDesignSystemTests.swift docs/codex/ambitions_primitive_invention_registry.md docs/codex/concept-lock-registry.yml artifacts/ambitions-ui-reconstruction/primitive-install/AMB-571-semantic-token-extensions.md`
- Result: No blocking hits; one context-only existing accessibility primitive line remained non-blocking.
- Command: `git diff --check`
- Result: Passed
- Command: `bash scripts/release-claim-safety-scan.sh`
- Result: Green

## Proof Boundaries

- Manual contrast inspection was not run.
- Manual Dynamic Type, VoiceOver, Reduce Motion, or Reduce Transparency walkthrough proof was not run.
- Physical-device validation was not run.
- No release, TestFlight, App Store, public accessibility, privacy/legal, performance, or device readiness claim is made.

## Rollback

- Remove `AmbitionTheme.PrimitiveSemanticColors` and `AmbitionPrimitiveSemanticToken` from `Sources/Theme/AmbitionTheme.swift`.
- Restore `SourceTrustReceiptStrip` color selection to the prior local visual-state mapping.
- Restore `AmbitionsPrimitiveAccessibilityFallbackModifier` to the prior foundation color tokens.
- Remove AMB-571 tests from `AppearancePreferenceTests` and `TrustReceiptLayerDesignSystemTests`.
- Remove the AMB-571 semantic token registry table entries and the AMB-571 concept-lock allowance.

## Completion Footer

Verdict: Green
Artifact paths:
- `artifacts/ambitions-ui-reconstruction/primitive-install/AMB-571-semantic-token-extensions.md`
Focused tests:
- `make xcode-focused-test BATCH=AMB-571 TEST=AmbitionsTests/TrustReceiptLayerDesignSystemTests` — passed
- `make xcode-focused-test BATCH=AMB-571 TEST=AmbitionsTests/AppearancePreferenceTests` — passed
Changed files:
- `Sources/Theme/AmbitionTheme.swift`
- `Sources/Components/TrustReceiptLayerPrimitives.swift`
- `Sources/Components/AccessibilityAdaptiveInterfacePrimitives.swift`
- `Native/AmbitionsTests/App/AppearancePreferenceTests.swift`
- `Native/AmbitionsTests/App/TrustReceiptLayerDesignSystemTests.swift`
- `docs/codex/ambitions_primitive_invention_registry.md`
- `docs/codex/concept-lock-registry.yml`
- `artifacts/ambitions-ui-reconstruction/primitive-install/AMB-571-semantic-token-extensions.md`
Rollback notes:
- Remove the token inventory and revert primitive adoption as listed above.
Remaining Yellow debt:
- None
