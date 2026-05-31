# AFRI-034 Accessibility Proof Matrix And Gates

Issue: AMB-386 / AFRI-034
Date: 2026-05-31
Commit under validation: `edaa1a293`

## Status

Green for source-backed accessibility gate coverage and focused automated tests.

Public accessibility claims remain locked. This packet is not public accessibility conformance proof.

## Authority Inspected

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/accessibility/AMB_ACCESSIBILITY_MOAT_MATRIX.md`
- `Sources/Accessibility/AccessibilityNutrition.swift`
- `Sources/Accessibility/AccessibilityClaimsLock.swift`
- `Native/AmbitionsTests/App/AccessibilityNutritionChecklistTests.swift`
- `docs/proof/afri/afri-033-unified-screenshot-matrix-visual-qa-proof.md`

## Gate Matrix

| Gate | Evidence | Status | Release boundary |
|---|---|---:|---|
| VoiceOver labels/order | `AFI12AccessibilityStateProof` covers all five top-level surfaces with VoiceOver summaries; focused tests assert required snippets and manual-proof limitations. | Green for source/test evidence | Manual VoiceOver traversal still required before public claim |
| Dynamic Type | `AccessibilityNutritionCategory.dynamicType`, EB27 adjustment evidence, AFI12 fallback strings, and AMB-033 screenshot matrix state `you-dynamic-type`. | Green for source/test evidence | Dynamic Type screenshots across device bands still required before public claim |
| Reduce Motion | `AccessibilityNutritionCategory.reduceMotion`, EB27 adjustment evidence, AFI12 static fallbacks, and AMB-033/AMB-034 screenshot state `you-reduce-motion`. | Green for source/test evidence | Manual Reduce Motion walkthrough still required before public claim |
| Increase Contrast | `AccessibilityNutritionCategory.contrast`, moat matrix keyword coverage, and AMB-033 screenshot state `you-increase-contrast`. | Green for gate coverage | Measured contrast pass still required before public claim |
| Tap targets | `AccessibilityNutritionCategory.tapTargetSize` and checklist guidance assert hit-area expectations. | Green for source/test evidence | Manual motor/tap-target pass still required before public claim |
| Non-color meaning | `AccessibilityNutritionCategory.colorNotOnlyMeaning`, AFI12 non-color state support, and focused tests assert no category relies on color-only state. | Green for source/test evidence | Rendered state review still required before public claim |
| Cognitive clarity | `AccessibilityNutritionCategory.cognitiveLoad`, EB28 plain-language evidence, EB30 overload adaptation evidence, and no-shame copy checks. | Green for source/test evidence | Manual cognitive-load review still required before public claim |
| Public accessibility claims | `AccessibilityClaimsLock.publishableClaims` remains empty and focused tests assert claims are locked. | Green lock | Any public accessibility claim remains blocked |

## Surface Matrix

| Surface | Primary object | Evidence owner | Covered dimensions | Status |
|---|---|---|---|---:|
| Today | Reality Meridian | `AFI12AccessibilityStateProof` | VoiceOver summary, Dynamic Type fallback, Reduce Motion fallback, non-color states, receipt path | Green source/test |
| Goals | Constellation Atlas | `AFI12AccessibilityStateProof` | VoiceOver summary, Dynamic Type fallback, Reduce Motion fallback, non-color states, receipt path | Green source/test |
| Capture | Atmosphere Composer | `AFI12AccessibilityStateProof` | VoiceOver summary, Dynamic Type fallback, Reduce Motion fallback, non-color states, receipt path | Green source/test |
| Time | LifeShape Field | `AFI12AccessibilityStateProof` | VoiceOver summary, Dynamic Type fallback, Reduce Motion fallback, non-color states, receipt path | Green source/test |
| You | User System Profile | `AFI12AccessibilityStateProof` | VoiceOver summary, Dynamic Type fallback, Reduce Motion fallback, non-color states, receipt path | Green source/test |

## Key Flow Matrix

| Flow | Evidence | Status | Manual proof still required |
|---|---|---:|---|
| Start Here / recommended step | Today AFI12 proof covers Now, Next, Later, source, recovery, primary action, and receipt availability. | Green source/test | VoiceOver traversal and Dynamic Type screenshots |
| Capture route correction | Capture AFI12 proof covers route result, correction path, privacy copy, and placement/correction receipts. | Green source/test | VoiceOver traversal and large-text capture flow |
| Time pressure/protected time | Time AFI12 proof covers horizon, open time, protected time, pressure, source review, and Quiet Reflow receipt path. | Green source/test | Contrast and Reduce Motion walkthrough |
| Goals proof/life-area direction | Goals AFI12 proof covers life areas, goal threads, Today connection, selected/pinned/stale/blocked state copy, and proof receipts. | Green source/test | Nonvisual drill-down order review |
| You trust/privacy controls | You AFI12 proof covers Planning Setup, Trust & Automation, Privacy, Receipts & History, Defaults, and What Ambitions Knows. | Green source/test | Manual VoiceOver traversal for settings-style grouped controls |

## Validation

- Pre guard: `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-386 --batch-type guard-repair --prompt /tmp/AMB-386-AFRI-034-guard-prompt.md`
  - Result: Green.
- Accessibility gate script: `python3 scripts/ambitions_validate_accessibility_gates.py`
  - Result: Green.
- Focused accessibility tests: `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -configuration Debug -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/AccessibilityNutritionChecklistTests`
  - Result: `** TEST SUCCEEDED **`
  - Tests: 21 executed, 0 failures.
  - Result bundle: `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.31_19-24-47--0400.xcresult`
- Accessibility screenshot smoke: `bash scripts/visual-qa/capture_matrix.sh --smoke --output-dir output/visual-qa/afri-034-accessibility-smoke`
  - Result: Green.
  - Report: `output/visual-qa/afri-034-accessibility-smoke/visual-qa-matrix-report.md`
  - States: `today-normal`, `today-recovery`, `you-reduce-motion`.

## P0 Release Gate

Release Green is blocked if any of the following becomes Red:

- Missing `docs/accessibility/AMB_ACCESSIBILITY_MOAT_MATRIX.md`.
- Missing required surface or check keyword in `scripts/ambitions_validate_accessibility_gates.py`.
- Failing `AccessibilityNutritionChecklistTests`.
- Any public accessibility claim appears while `AccessibilityClaimsLock.publishableClaims` is empty.
- Manual VoiceOver, Dynamic Type, Reduce Motion, Increase Contrast, tap-target, or non-color review finds a P0 issue.

## Proof Boundaries

Verified:

- Source-backed accessibility proof model covers all five active tabs.
- Automated focused tests assert surface coverage, fallbacks, receipt paths, non-color meaning, and locked public claims.
- Accessibility matrix validator is Green.
- Screenshot smoke includes current local accessibility-related visual states.

Not verified:

- Manual VoiceOver traversal.
- Dynamic Type screenshots across device bands.
- Reduce Motion walkthrough.
- Increase Contrast measured pass.
- Manual tap-target/motor review.
- Public accessibility conformance.
- Physical-device behavior.
- App Store accessibility claims.
- TestFlight/App Store readiness.
- Release readiness.

## Rollback

Revert the AMB-386 commit to remove this proof packet. If any future P0 accessibility gate turns Red, keep release Green blocked until the underlying issue is repaired and the proof matrix is updated with current evidence.
