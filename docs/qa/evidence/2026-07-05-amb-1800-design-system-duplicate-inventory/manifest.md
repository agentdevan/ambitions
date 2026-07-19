# AMB-1800 Design System Duplicate Inventory Evidence

Date: 2026-07-05

Scope: inventory duplicated design-system token/primitive authority and remove
one low-risk duplicate wrapper.

Status: Implemented Yellow. Source/static proof exists; XCTest, build,
simulator, device, Visual Green, accessibility conformance, and release proof
were not run or claimed.

## Files

- `Native/Ambitions/DesignSystem/ProductObjects/TodayStartHereSurface.swift`
- `Native/AmbitionsTests/DesignSystemFoundationsCanonicalOwnershipTests.swift`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- Deleted `Native/Ambitions/DesignSystem/Foundations/AmbitionsLighting.swift`
- `docs/audits/amb-1800-design-system-token-primitive-duplicate-inventory.md`
- `docs/qa/evidence/2026-07-05-amb-1800-design-system-duplicate-inventory/design-system-duplicate-inventory.json`

## Inventory Result

- Removed duplicate set: app-local `AmbitionsLighting` wrapper.
- Package semantic lighting remains represented by `AmbitionFoundationLightingRole`.
- Final Architecture Tree no longer lists `AmbitionsLighting.swift` as a
  required DesignSystem foundation owner.
- Remaining app-local foundation wrappers are still used and stay Yellow until
  future focused collapse/move slices.

## Validation

- `rg -n "AmbitionsLighting" Native/Ambitions Sources AppUI/Sources Native/AmbitionsTests ...`: no production references remain; remaining hits are evidence and the regression assertion.
- `swiftc -parse Native/Ambitions/DesignSystem/ProductObjects/TodayStartHereSurface.swift Native/AmbitionsTests/DesignSystemFoundationsCanonicalOwnershipTests.swift`: passed.
- `python3 -m json.tool docs/qa/evidence/2026-07-05-amb-1800-design-system-duplicate-inventory/design-system-duplicate-inventory.json`: passed.
- `xcodegen generate`: passed.
- `python3 scripts/ambitions-remediation-governance-check.py`: passed.
- `python3 scripts/ambitions-quality-gate.py`: passed after the Final Architecture Tree was updated.
- `python3 scripts/ambitions-architecture-inventory.py`: passed after the Final Architecture Tree was updated.
- `python3 scripts/ambitions-vocabulary-drift-scan.py`: passed.
- `python3 scripts/ambitions-truth-path-vocabulary-audit.py`: passed.
- `python3 scripts/ambitions-green-standard-audit.py`: passed.
- `python3 scripts/ambitions-local-first-boundary-scan.py`: passed.
- `git diff --check`: passed.
- `scripts/release-claim-safety-scan.sh $(git ls-files --modified --deleted --others --exclude-standard)`: passed.
- `scripts/no-unsupported-ai-claim-scan.sh $(git ls-files --modified --deleted --others --exclude-standard)`: advisory Yellow only.
- `scripts/privacy-boundary-scan.sh $(git ls-files --modified --deleted --others --exclude-standard)`: advisory Yellow only.
