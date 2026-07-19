# AMB-1814 Automated Accessibility Nutrition Gate

Status: Implemented Yellow

AMB-1814 installs the first automated accessibility nutrition gate for source-backed coverage of VoiceOver, Dynamic Type, and Reduce Motion evidence. The gate is intentionally narrow: it records the source owners, automated assertion target, fallback requirement, and manual/device proof still required before any public accessibility claim.

## Evidence Installed

- Source model: `Sources/Accessibility/AccessibilityAutomatedNutritionGate.swift` (`AMB1814AutomatedNutritionGate`)
- Assertion target: `Native/AmbitionsTests/App/AccessibilityNutritionChecklistTests.swift`
- Covered categories: VoiceOver, Dynamic Type, Reduce Motion
- Covered axes: VoiceOver order, Dynamic Type layout, Reduce Motion equivalent

## Proof Ceiling

- Source-backed automated nutrition gate installed only.
- No public accessibility conformance is claimed.
- No Visual Green, Release Green, App Store accessibility claim, or device proof is claimed.
- Manual VoiceOver traversal, Dynamic Type screenshots/no-clipping review, toggled Reduce Motion walkthrough, contrast review, motor review, and physical-device proof remain required.

## Closeout Validation

- XCTest/UI execution: not run under the current user instruction authorizing issue completion without testing.
- `xcodegen generate`: passed; generated project had no diff.
- `python3 scripts/ambitions-remediation-governance-check.py`: GREEN.
- `python3 scripts/ambitions-quality-gate.py`: GREEN.
- `git diff --check && git diff --cached --check`: passed.
- `scripts/ambitions-xcode-sim-health.sh --json --timeout 20s`: passed after clearing active Xcode blockers with the repo repair path.
