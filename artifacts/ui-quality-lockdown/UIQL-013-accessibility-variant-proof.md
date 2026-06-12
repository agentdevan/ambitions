# UIQL-013 / AMB-968 Accessibility Variant Proof Pass

Status: Local scoped Green for repaired product accessibility variants; Yellow for unavailable live VoiceOver traversal, physical-device proof, public accessibility certification, and manual system-setting Reduce Transparency walkthrough.
Linear issue: AMB-968
Program: UIQL
Branch: `main`
Push status: not pushed by Codex; owner will push manually after GitHub is fixed.

## Scope

AMB-968 proves that the current UIQL-repaired surfaces survive accessibility and variant conditions well enough for the next read-only red-team audit. It is not release proof, App Store proof, TestFlight proof, public accessibility certification, owner approval, or physical-device validation.

Surfaces reviewed:

- Today / Reality Meridian / Start Here
- Goals / Constellation Atlas / Your Direction
- Time / LifeShape Field
- Motion / Motion Current
- You / Personal Runtime / User System Profile
- Global Capture / Atmosphere Composer
- Create Goal
- Meridian shell dock and activated Capture seam

## Source Files Touched

- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `Native/Ambitions/Features/Time/TimeLifeShapeField.swift`

## Repairs Made

1. Today large Dynamic Type title clipping
   - Finding: exported Today large Dynamic Type screenshot from the AMB-962 final set showed the Start Here title clipped with an ellipsis.
   - Repair: removed the finite line limit for the Today Start Here title only at accessibility sizes.
   - Follow-up finding: the full title pushed the primary `Start now` action into the bottom fade.
   - Repair: compacted the accessibility-size visible metadata line to `Recommended step` while preserving richer source/receipt semantics through the existing accessibility value path.
   - Final proof: `artifacts/ui-quality-lockdown/screenshots/amb-968/today-rerun2/3B3E33A1-8AE6-4243-B823-640AFECAD502.png`.

2. Time large Dynamic Type secondary text clipping
   - Finding: exported Time large Dynamic Type screenshot from the AMB-964 final set showed `Capacity proof a...` and `Keep the week shape...` ellipses.
   - Repair: shortened accessibility-size-only secondary labels to `Source proof.` and `Keep shape.`.
   - Final proof: `artifacts/ui-quality-lockdown/screenshots/amb-968/time-rerun2/6BFE25E4-34D2-4A62-92C2-50A8B3D6C1D6.png`.

No other source repairs were made for AMB-968.

## Screenshot Evidence

Screenshot paths are not proof by themselves. The following exported screenshots were visually inspected for text clipping, primary action reachability, dock legibility, and obvious color/motion-only state dependence.

| Surface | Default / base proof | Large Dynamic Type proof | Reduce Motion / static proof | Increase Contrast / transparency fallback |
| --- | --- | --- | --- | --- |
| Today | `artifacts/ui-quality-lockdown/screenshots/amb-968/today-rerun2/833E2EEB-6810-4D0A-AF26-3710AB9CD83F.png` | `artifacts/ui-quality-lockdown/screenshots/amb-968/today-rerun2/3B3E33A1-8AE6-4243-B823-640AFECAD502.png` | `artifacts/ui-quality-lockdown/screenshots/amb-968/today-rerun2/F621E1A8-8719-452C-8BED-5CBFC23F6F28.png` | `artifacts/ui-quality-lockdown/screenshots/amb-959/AMB-959-final-labels-increase-contrast.png`; source fallback via `DayRailViewState.swift` and `AmbitionsPremiumMaterials.swift` |
| Goals | `artifacts/ui-quality-lockdown/screenshots/amb-963/rerun11/amb-963-goals-default.png` | `artifacts/ui-quality-lockdown/screenshots/amb-963/rerun11/amb-963-goals-large-dynamic-type.png` | Source/static fallback via `GoalComponents.swift` and `AFI12AccessibilityStateProof` | Source fallback via `GoalComponents.swift` contrast rules and `LiquidGlassTokenLayerTests` |
| Time | `artifacts/ui-quality-lockdown/screenshots/amb-968/time-rerun2/C816021A-9066-48C4-BF8F-9B55086ED0AF.png` | `artifacts/ui-quality-lockdown/screenshots/amb-968/time-rerun2/6BFE25E4-34D2-4A62-92C2-50A8B3D6C1D6.png` | `artifacts/ui-quality-lockdown/screenshots/amb-968/time-rerun2/97B557FC-7415-4D47-BCA0-925416E7C870.png` | Source fallback via `TimeLifeShapeField.swift`, `ProductMeaningCanvasEngine.swift`, and `LiquidGlassTokenLayerTests` |
| Motion | `artifacts/ui-quality-lockdown/screenshots/amb-965/rerun5/3175465E-AA84-4498-9F9B-58B3A804E28F.png` | `artifacts/ui-quality-lockdown/screenshots/amb-965/rerun5/9C90891D-10E0-4F38-A68B-6D70D907D5F8.png` | Source/static fallback via `MotionCurrentScreen.swift` and `AFI12AccessibilityStateProof` | Source fallback via `MotionCurrentScreen.swift` contrast rules |
| You | `artifacts/ui-quality-lockdown/screenshots/amb-966/rerun12/F13E5529-DCE6-4EE3-9A64-3EBB36407610.png` | `artifacts/ui-quality-lockdown/screenshots/amb-966/rerun12/102FE7B1-3A72-4CBC-BB72-7023C4185204.png` | Source/static fallback via `YouRootSurface.swift` and `AFI12AccessibilityStateProof` | `artifacts/ui-quality-lockdown/screenshots/amb-966/rerun12/815ABB73-018A-42D1-AC84-3CAA98F8AE4A.png` |
| Capture | `artifacts/ui-quality-lockdown/screenshots/amb-967/rerun9/53B1D787-D4EA-4F34-BDE9-0269437749D3.png` | Large text path is Create Goal-specific below; Capture source fallback in `AppShellView.swift` | Source/static fallback via `AppShellView.swift` Reduce Motion strip and `AFI12AccessibilityStateProof` | Source fallback via shared shell/material primitives |
| Create Goal | `artifacts/ui-quality-lockdown/screenshots/amb-967/rerun9/C9DF3963-F0E3-4052-B76E-9F155FDBC1C5.png` | `artifacts/ui-quality-lockdown/screenshots/amb-967/rerun9/2D390290-E516-4049-B80F-722D0CE5487B.png` | Source/static fallback via `CreateGoalScreen.swift` `accessibilityReduceMotion` handling | Source fallback via shared material primitives |

## Visual Findings

- Today final large Dynamic Type: full Start Here title wraps without ellipsis; visible metadata stays compact; `Start now` remains visible and readable above the Meridian dock. Secondary `Why this?` / `Move this` controls sit lower in the fade and remain available through normal scroll/interaction, but AMB-968 closes on primary action reachability, not full secondary-control first-viewport exposure.
- Goals final large Dynamic Type: `Your Direction`, `Equal-weight areas`, life-area labels, and dock labels remain readable; selected state uses icon/line/value instead of color alone.
- Time final large Dynamic Type: `Source proof.`, `Capacity`, the full protected recovery window sentence, and `Keep shape.` render without visible ellipsis in the inspected final screenshot.
- Motion final large Dynamic Type: proof/receipt/re-entry action stack remains readable; primary proof actions use text plus icons and do not rely on color alone.
- You final large Dynamic Type: Personal Runtime detail keeps headline and route context readable in a scrollable sheet; no owner/release/accessibility certification claim is made from this screenshot.
- Capture/Create Goal final screenshots: Capture keyboard state remains above the dock; route review appears after text entry; Create Goal large text keeps the setup object, input field, and plain-language first path visible without AI/spec/debug copy.

## Source Inspection

Inspected source patterns:

- Accessibility labels/values/hints and semantic grouping:
  - `Native/Ambitions/App/AppShellView.swift`
  - `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
  - `Native/Ambitions/Features/Goals/GoalComponents.swift`
  - `Native/Ambitions/Features/Time/TimeLifeShapeField.swift`
  - `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift`
  - `Native/Ambitions/Features/You/YouRootSurface.swift`
  - `Native/Ambitions/Features/Capture/CapturePlacementReviewState.swift`
  - `Native/Ambitions/Features/Goals/CreateGoalScreen.swift`
- Dynamic Type handling:
  - Today and Time now use accessibility-size-specific wrapping/compaction for the repaired proof paths.
  - Goals, Motion, You, and Create Goal have existing dedicated large Dynamic Type screenshot proof from AMB-963 through AMB-967.
- Reduce Motion:
  - `AppShellView.swift`, `TimeLifeShapeField.swift`, `MotionCurrentScreen.swift`, and `CreateGoalScreen.swift` use `accessibilityReduceMotion` or static-equivalent source paths.
  - `AccessibilityNutritionChecklistTests` proves AFI12 reduce-motion fallback descriptions for active surfaces and Capture.
- Reduce Transparency / Increase Contrast:
  - `AmbitionsPremiumMaterials.swift`, `ChromeButtonPrimitives.swift`, `SurfaceShellPrimitives.swift`, `NavigationPrimitives.swift`, and `ProductMeaningCanvasEngine.swift` include Reduce Transparency / contrast fallback logic.
  - `LiquidGlassTokenLayerTests/testLiquidGlassDecisionDisablesForReduceTransparencyAndIncreasedContrast` passed.
- Tap targets:
  - Theme and shell tests assert `theme.panel.minimumTapTarget >= 44`.
  - Shell UI test asserts all five Meridian dock destination frames are at least 44x44.
- Icon-only controls:
  - Shell/capture controls expose accessibility identifiers and labels in `AppShellView.swift`; visual-only canvas/ornament layers are accessibility-hidden.

## Tests And Commands

- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/AccessibilityNutritionChecklistTests -only-testing:AmbitionsTests/AppShellChromeTests/testShellThemeKeepsHeaderAndTabChromeReadableInBothModes -only-testing:AmbitionsTests/LiquidGlassTokenLayerTests/testLiquidGlassDecisionDisablesForReduceTransparencyAndIncreasedContrast`
  - Exit code: 0
  - Result: 23 tests, 0 failures.
  - Local log: `artifacts/ui-quality-lockdown/script-output/AMB-968-accessibility-unit-contracts.log`
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsUITests/AmbitionsUITests/testUIQL002ShellGeometryKeepsChromeInsideSafeAreasAndDockHittable -only-testing:AmbitionsUITests/AmbitionsUITests/testUIQL002ActivatedCaptureSeamStaysAboveNativeDockAfterKeyboardDismissal`
  - Exit code: 0
  - Result: 2 UI tests, 0 failures.
  - Local log: `artifacts/ui-quality-lockdown/script-output/AMB-968-shell-accessibility-geometry.log`
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsUITests/AmbitionsUITests/testAMB964TimeReconstructionScreenshotMatrix`
  - First rerun exit code: 0; visual inspection still found ellipsized accessibility-size secondary copy.
  - Second rerun exit code: 0; final inspected Time large Dynamic Type proof is in `artifacts/ui-quality-lockdown/screenshots/amb-968/time-rerun2/`.
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsUITests/AmbitionsUITests/testAMB962TodayReconstructionScreenshotMatrix`
  - First rerun exit code: 0; visual inspection found `Start now` pushed into the bottom fade after title-wrap repair.
  - Second rerun exit code: 0; final inspected Today large Dynamic Type proof is in `artifacts/ui-quality-lockdown/screenshots/amb-968/today-rerun2/`.
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-mini-regression.sh`
  - Exit code: 0
  - Result: changed Swift source contains no UIQL-banned copy and adds no UIQL card-anatomy blockers.
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-preflight.sh`
  - Exit code before commit: 1
  - Reason: expected dirty source paths while AMB-968 repair was in progress. Rerun after commit is required.

## Variant Failures Found

- Red: Today large Dynamic Type title ellipsis.
  - Repaired.
- Red: Today large Dynamic Type primary action pushed too low after full-title wrapping.
  - Repaired by compacting accessibility-size visible metadata.
- Red: Time large Dynamic Type secondary text ellipsis.
  - Repaired.

No remaining product Red is claimed in the inspected final AMB-968 screenshot evidence.

## Remaining Yellow

- Live VoiceOver traversal was not executed. Source semantic grouping and accessibility unit contracts are current, but manual VoiceOver traversal remains required before any public accessibility claim.
- Physical-device proof was not executed.
- Manual system-setting Reduce Transparency walkthrough was not executed across every surface. Source fallback and unit proof exist; public claim remains locked.
- Prior AMB-962 through AMB-968 commits are local/push-pending until the owner manually pushes.

## No-Claim Boundary

This AMB-968 proof does not claim:

- owner approval
- release readiness
- TestFlight readiness
- App Store readiness
- physical-device validation
- public accessibility certification
- full VoiceOver traversal proof
- legal/privacy approval
- performance proof
- CI proof
- PLOS runtime completeness
- Linear Done before the local commit is pushed

## Closeout State

AMB-968 may close locally as scoped Green for product accessibility variant evidence, with Yellow for manual/device/public-certification limits and push-pending status. The next executable UIQL issue is AMB-970 / UIQL-013.5 Independent Red-Team Visual Audit, which is read-only.
