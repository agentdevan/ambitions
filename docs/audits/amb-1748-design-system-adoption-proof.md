# AMB-1748 Design System Adoption Proof

Status: Ready for review
Date: 2026-07-04
Scope: AMB-1748, Architecture Simplification + Flagship Readiness Remediation
Baseline SHA: `2f0e5d99f039e72b0fd76c8c476bec4312cf38e9`
Linear status before audit: `Spec Ready`

## Purpose

AMB-1748 proves, within a bounded source/test claim, that retained Ambitions
design-system primitives are used by real runtime screens and not only by
previews or aspirational docs.

This packet is a source-adoption and proof-requirement audit. It does not
produce screenshots, run a manual Dynamic Type sweep, run a manual VoiceOver
sweep, prove visual quality, prove accessibility conformance, prove physical
device behavior, or prove release readiness.

## Linear Scope

AMB-1748 acceptance requires:

- map shared visual primitives to Today, Goals, Time, You, Capture, and
  inspection details
- require screenshot proof before any visual quality claim
- require Dynamic Type and accessibility proof for shared components
- link remaining visual recovery work to the sibling frontend project

## Truth And Skill Inputs

Inspected inputs:

- `AGENTS.md`
- `docs/truth/CODEX_START_HERE.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md`
- `.agents/skills/ambitions-source-truth-authority/SKILL.md`
- `.agents/skills/ambitions-architecture-tree-enforcement/SKILL.md`
- `.agents/skills/ambitions-ios-quality-gate/SKILL.md`
- `.agents/skills/ambitions-release-proof-honesty/SKILL.md`
- `docs/audits/amb-1746-frontend-research-extension-gate.md`
- `docs/audits/amb-1747-stage-shell-frontend-reality-audit.md`
- Linear issue `AMB-1748`

Controlling proof rule:

- Source and unit tests can prove source adoption.
- Screenshot paths, preview names, source imports, and generated catalogs cannot
  prove rendered quality by themselves.
- Visual quality, accessibility conformance, device behavior, TestFlight, App
  Store, and release claims require current artifacts and owner acceptance
  outside this packet.

## Runtime Adoption Matrix

| Runtime area | Current source adoption evidence | Current test evidence | AMB-1748 classification | Follow-up / proof ceiling |
| --- | --- | --- | --- | --- |
| Shell/chrome | `AppShellScaffold` imports `AmbitionsDesignSystem`, applies shell clearance, header rail, Dynamic Type spacing, and Stage safe-area policy (`Native/Ambitions/App/AppShellView.swift:1`). `StageDockRail` renders the canonical shell destinations from `StageChromeContract.launchDefault` and exposes accessibility labels/identifiers (`Native/Ambitions/Stage/Chrome/StageDockRail.swift:27`). | `AppShellNavigationTests` verifies shell root surfaces, dock destinations, root/drilldown dock policy, Capture access metadata, and activated Capture seam state (`Native/AmbitionsTests/App/AppShellNavigationTests.swift:190`, `:425`, `:449`, `:466`). | Source adoption present for shell primitives. | Rendered shell screenshots, accessibility sweep, and device proof remain AMB-1749/AMB-1750 scoped. |
| Today | `TodaySurface` imports `AmbitionsDesignSystem`, consumes `ambitionTheme`, Reduce Motion, Dynamic Type, `TodayBackgroundView`, and themed sheets (`Native/Ambitions/Surfaces/Today/TodaySurface.swift:1`). `TodayObjectView` routes the runtime Today experience into `RealityMeridianView` (`Native/Ambitions/Surfaces/Today/TodayObjectView.swift:12`). `RealityMeridianView` wraps `AmbitionsDayRailView` as the retained Today product object primitive (`Native/Ambitions/DesignSystem/ProductObjects/RealityMeridianView.swift:4`). | `TopLevelSurfaceCompositionTests` verifies Today remains one canonical top-level surface with one primary object (`Native/AmbitionsTests/App/TopLevelSurfaceCompositionTests.swift:5`). `AccessibilityNutritionChecklistTests` carries active-surface accessibility proof requirements and manual proof limits (`Native/AmbitionsTests/App/AccessibilityNutritionChecklistTests.swift:190`). | Source adoption present. | Screenshot, Dynamic Type, VoiceOver, Reduce Motion, contrast, and device proof remain required before any visual quality claim. |
| Goals | `GoalsSurface` uses `AmbitionsDesignSystem`, `DegradedStateSurface`, `AppCard`, `LivingSurfaceBackground`, design-system spacing, and route animation (`Native/Ambitions/Surfaces/Goals/GoalsSurface.swift:1`). `GoalsObjectView` renders the runtime overview through the Life Area Atlas field, `ProductMeaningCanvasEngine`, semantic icons, theme typography, Dynamic Type sizing, and accessibility labels (`Native/Ambitions/Surfaces/Goals/GoalsObjectView.swift:19`). | `DesignSystemProductObjectsCanonicalOwnershipTests` verifies canonical product-object owner files (`Native/AmbitionsTests/DesignSystemProductObjectsCanonicalOwnershipTests.swift:5`). `RichPanelDesignSystemTests` verifies semantic states, panel token scale, accessible state/icons, and button roles (`Native/AmbitionsTests/App/RichPanelDesignSystemTests.swift:5`). | Source adoption present for Goals root and object field. | Flagship rendered Goals proof remains AMB-1738 and AMB-1749 scoped; visual hardening remains AMB-1741 scoped. |
| Time | `TimeSurface` uses `AmbitionsDesignSystem`, `LivingSurfaceBackground`, `DegradedStateSurface`, Dynamic Type bottom clearance, Reduce Motion animation, and accessibility announcements (`Native/Ambitions/Surfaces/Time/TimeSurface.swift:1`). `TimeObjectView` routes runtime Time state into `LifeShapeFieldView` (`Native/Ambitions/Surfaces/Time/TimeObjectView.swift:33`). `LifeShapeFieldView` owns theme, Reduce Motion, contrast, Dynamic Type, screenshot render-state hooks, embedded proof banner, and accessibility value (`Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView.swift:4`). | `PanelDensitySizeDesignSystemTests` verifies density, tap-target, Dynamic Type, Reduce Motion, and non-color meaning constraints for panel display (`Native/AmbitionsTests/App/PanelDensitySizeDesignSystemTests.swift:5`). `AccessibilityNutritionChecklistTests` verifies Time accessibility fallback requirements as active-surface proof rows (`Native/AmbitionsTests/App/AccessibilityNutritionChecklistTests.swift:291`). | Source adoption present. | Rendered Time proof remains AMB-1739 and AMB-1749 scoped; no device or Visual Green claim here. |
| You | `YouSurface` uses `AmbitionsDesignSystem`, `LivingSurfaceBackground`, `DegradedStateSurface`, theme spacing, Reduce Motion animation, and screenshot-detail launch hooks (`Native/Ambitions/Surfaces/You/YouSurface.swift:1`). `YouObjectView` routes runtime profile state into `UserSystemProfileRootView` (`Native/Ambitions/Surfaces/You/YouObjectView.swift:7`). `UserSystemProfileRootView` consumes theme, Dynamic Type, `NativeSettingsGroup`, and row haptics (`Native/Ambitions/Surfaces/You/YouRootSurface.swift:120`). `NativeSettingsGroup` and `NativeSettingsRow` are retained product-object primitives (`Native/Ambitions/DesignSystem/ProductObjects/NativeSettingsGroup.swift:4`, `Native/Ambitions/DesignSystem/ProductObjects/NativeSettingsRow.swift:11`). | `DesignSystemProductObjectsCanonicalOwnershipTests` verifies `UserSystemProfileView`, `NativeSettingsGroup`, and `NativeSettingsRow` owner files (`Native/AmbitionsTests/DesignSystemProductObjectsCanonicalOwnershipTests.swift:5`). `AccessibilityNutritionChecklistTests` verifies You accessibility fallback requirements (`Native/AmbitionsTests/App/AccessibilityNutritionChecklistTests.swift:302`). | Source adoption present. | You / Trust / Privacy rendered proof remains AMB-1740 and AMB-1749 scoped. |
| Capture | `CaptureSurface` opens `CaptureComposerSurface` as the global composer (`Native/Ambitions/Composer/Capture/CaptureSurface.swift:3`). `CaptureComposerSurface` uses `AmbitionsDesignSystem`, `LivingSurfaceBackground`, `CaptureObjectView`, `DegradedStateSurface`, `CaptureDepthDisclosureStage`, `CaptureStageGroup`, `ProofPulse`, and `EvidenceLabel` (`Native/Ambitions/Composer/Capture/CaptureComposerSurface.swift:1`). `CaptureObjectView` wraps `CaptureAtmosphereComposer` and applies Capture accessibility policy (`Native/Ambitions/Composer/Capture/CaptureObjectView.swift:16`). `CaptureAtmosphereComposer` owns Dynamic Type layout switching, themed field/button styling, route preview animation, and accessibility identifiers (`Native/Ambitions/Composer/Capture/CaptureAtmosphereComposer.swift:150`). `AppShellActivatedCaptureSeam` reuses `CaptureObjectView` and `CaptureProposalStage` for the shell overlay seam (`Native/Ambitions/App/AppShellActivatedCaptureSeam.swift:112`). | `CaptureRoutingPrimitiveFamilyTests` verifies the activated Capture seam uses shared Atmosphere Composer primitives and blocks fallback shell implementations (`Native/AmbitionsTests/App/CaptureRoutingPrimitiveFamilyTests.swift:37`). `AppShellNavigationTests` verifies contextual Capture entry sources and accessible toolbar metadata for every canonical surface (`Native/AmbitionsTests/App/AppShellNavigationTests.swift:425`, `:449`). | Source adoption present for global Capture and activated seam. | Capture-to-Today rendered flow and keyboard-safe screenshots remain AMB-1736, AMB-1743, and AMB-1749 scoped. |
| Inspection / Trust details | `InspectionSurface` uses `AppCard`, `SectionHeader`, `TagPill`, `ambitionPanelAccessibility`, and themed inspection rows (`Native/Ambitions/Trust/InspectionSurface.swift:4`). `SourceInspectionView`, `HistoryInspectionView`, `PrivacyInspectionView`, and receipt/proof views route through this Trust owner. | `TrustCanonicalOwnershipTests` verifies inspection states are owned by You and stay contextual, not root-level. `TrustReceiptLayerDesignSystemTests` verifies primitive roles, source freshness, receipt drawer, accessibility summaries, and no unsupported readiness copy (`Native/AmbitionsTests/App/TrustReceiptLayerDesignSystemTests.swift:13`). | Source adoption present for inspection detail primitives. | Rendered Trust inspection screenshots and manual accessibility proof remain AMB-1740 and AMB-1749 scoped. |
| Shared degraded/loading states | `DegradedStateSurface` uses `AppCard`, `AmbitionsStatusSymbol`, `AmbitionButtonStyle`, theme typography, and accessibility identifiers (`Native/Ambitions/DesignSystem/ProductObjects/DegradedStateSurface.swift:4`). Runtime Today, Goals, Time, You, and Capture surfaces all call degraded/loading state surfaces. | `LoadingDegradedStateDesignSystemTests` verifies loading/degraded families, Reduce Motion equivalents, non-color meaning, object-specific copy, and no hidden mutation claims (`Native/AmbitionsTests/App/LoadingDegradedStateDesignSystemTests.swift:5`). | Source adoption present. | Rendered loading/empty/error/offline proof remains frontend QA scoped. |
| Accessibility policies | `DynamicTypePolicy` and `VoiceOverFocusPolicy` define reusable layout/focus contracts (`Native/Ambitions/DesignSystem/Accessibility/DynamicTypePolicy.swift:3`, `Native/Ambitions/DesignSystem/Accessibility/VoiceOverFocusPolicy.swift:3`). Capture accessibility consumes canonical policy owners (`Native/AmbitionsTests/DesignSystemAccessibilityCanonicalOwnershipTests.swift:55`). | `DesignSystemAccessibilityCanonicalOwnershipTests` verifies canonical accessibility policy owner files and policy behavior (`Native/AmbitionsTests/DesignSystemAccessibilityCanonicalOwnershipTests.swift:6`). `AccessibilityNutritionChecklistTests` verifies active-surface proof rows, manual proof requirements, and claim locks (`Native/AmbitionsTests/App/AccessibilityNutritionChecklistTests.swift:114`, `:224`). | Requirement coverage present; conformance not proven. | Manual VoiceOver, Dynamic Type, Reduce Motion, Reduce Transparency, and contrast sweeps remain required before accessibility claims. |
| Visual QA fixtures | Runtime surfaces expose screenshot launch hooks in limited places such as Today debug screenshot sheet, Goals screenshot proof state, Time screenshot render-state overrides, and You screenshot detail routes (`Native/Ambitions/Surfaces/Today/TodaySurface.swift:135`, `Native/Ambitions/Surfaces/Goals/GoalsSurface.swift:14`, `Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView.swift:125`, `Native/Ambitions/Surfaces/You/YouSurface.swift:140`). | `SignatureInterfaceVisualQAFixtureTests` verifies fixture and screenshot names, active-surface scorecards, and explicitly asserts no rendered screenshot proof, no human visual approval, no device proof, and no accessibility conformance (`Native/AmbitionsTests/App/SignatureInterfaceVisualQAFixtureTests.swift:17`, `:64`, `:122`). | Fixture/requirement coverage present; rendered proof missing. | AMB-1749 must index real current artifacts; AMB-1750 must prevent visual/app-store claims until accepted proof exists. |

## Gaps Linked To Frontend Recovery

No source evidence was found that lets AMB-1748 claim rendered visual quality or
accessibility conformance. The following proof remains required:

- Screenshot and journey evidence for runtime screens: AMB-1749.
- Visual Green / App Store frontend proof gate: AMB-1750.
- Visual system hardening and design-system surface adoption follow-through:
  AMB-1741.
- Today, Goals, Time, and You / Trust rendered flagship proof: AMB-1737,
  AMB-1738, AMB-1739, and AMB-1740.
- Capture-to-Today usable rendered flow: AMB-1736.
- Release-grade frontend QA and device proof: AMB-1743 and AMB-1744.
- Root IA / journey registry proof and stale/dead UI quarantine: AMB-1734,
  AMB-1735, AMB-1751, and AMB-1742.

## Acceptance Mapping

| AMB-1748 acceptance criterion | Current result |
| --- | --- |
| Runtime screens use retained primitives. | Source evidence is present for shell, Today, Goals, Time, You, Capture, inspection details, degraded states, and accessibility policy primitives. |
| Screenshot proof is required before any visual quality claim. | Present. Existing fixture tests explicitly block rendered screenshot/device/accessibility claims; this packet preserves that ceiling. |
| Shared components have accessibility requirements. | Present. Dynamic Type, VoiceOver, Reduce Motion, Reduce Transparency, contrast, non-color meaning, tap targets, and manual proof requirements are represented in source/tests. |
| Gaps are linked to frontend recovery work. | Present. Remaining rendered, screenshot, accessibility, visual, and device proof is linked to AMB-1734 through AMB-1744, AMB-1751, AMB-1749, and AMB-1750. |

## Proof Ceiling

Claim status for AMB-1748: Implemented Yellow / Ready for review.

Allowed claim:

- Current source and unit tests support design-system adoption mapping for the
  inspected runtime screens and shared primitives.

Forbidden claims from this packet:

- screenshot coverage
- rendered visual quality
- accessibility conformance
- physical-device behavior
- TestFlight readiness
- App Store readiness
- Release Green
- full product completion

## Validation

Local validation on 2026-07-04:

- `git diff --check` - passed.
- `python3 scripts/ambitions-remediation-governance-check.py` - passed
  (`GREEN remediation governance guard passed`; changed paths: 1).
- `python3 scripts/ambitions-accepted-yellow-misuse-audit.py` - passed
  (`valid=true`, `invalidAcceptedYellowIssues=0`).
- `python3 scripts/ambitions-unsupported-claim-scan.py docs/audits/amb-1748-design-system-adoption-proof.md` -
  passed.
- `python3 scripts/ambitions-copy-contract-lint.py` - passed.
- `scripts/ambitions-xcode-test-focused.sh --batch AMB_1748_DESIGN_SYSTEM_ADOPTION --test AmbitionsTests/DesignSystemProductObjectsCanonicalOwnershipTests --without-building --timeout 8m --kill-after 60s` -
  passed (`FAILURE_CLASS=passed`, `EXECUTED_TESTS=3`).
  - Result bundle:
    `.codex/xcode-results/AMB_1748_DESIGN_SYSTEM_ADOPTION/20260704T112835Z-AmbitionsTests-DesignSystemProductObjectsCanonicalOwnershipTests-18276-11896/focused-test.xcresult`
  - Extract summary:
    `.codex/xcode-summaries/AMB_1748_DESIGN_SYSTEM_ADOPTION/20260704T112835Z-AmbitionsTests-DesignSystemProductObjectsCanonicalOwnershipTests-18276-11896/extract/summary.json`
- `scripts/ambitions-xcode-test-focused.sh --batch AMB_1748_DESIGN_SYSTEM_ACCESSIBILITY --test AmbitionsTests/DesignSystemAccessibilityCanonicalOwnershipTests --without-building --timeout 8m --kill-after 60s` -
  passed (`FAILURE_CLASS=passed`, `EXECUTED_TESTS=4`).
  - Result bundle:
    `.codex/xcode-results/AMB_1748_DESIGN_SYSTEM_ACCESSIBILITY/20260704T113051Z-AmbitionsTests-DesignSystemAccessibilityCanonicalOwnershipTests-18759-14584/focused-test.xcresult`
  - Extract summary:
    `.codex/xcode-summaries/AMB_1748_DESIGN_SYSTEM_ACCESSIBILITY/20260704T113051Z-AmbitionsTests-DesignSystemAccessibilityCanonicalOwnershipTests-18759-14584/extract/summary.json`
- `scripts/ambitions-xcode-test-focused.sh --batch AMB_1748_VISUAL_FIXTURE_CEILING --test AmbitionsTests/SignatureInterfaceVisualQAFixtureTests --without-building --timeout 8m --kill-after 60s` -
  passed (`FAILURE_CLASS=passed`, `EXECUTED_TESTS=9`).
  - Result bundle:
    `.codex/xcode-results/AMB_1748_VISUAL_FIXTURE_CEILING/20260704T113244Z-AmbitionsTests-SignatureInterfaceVisualQAFixtureTests-19252-27749/focused-test.xcresult`
  - Extract summary:
    `.codex/xcode-summaries/AMB_1748_VISUAL_FIXTURE_CEILING/20260704T113244Z-AmbitionsTests-SignatureInterfaceVisualQAFixtureTests-19252-27749/extract/summary.json`

These Xcode runs prove the current source/test ownership and fixture proof-lock
contracts only. They do not provide rendered screenshot proof, manual VoiceOver
or Dynamic Type proof, physical-device proof, visual approval, TestFlight proof,
App Store proof, or Release Green.

## Closeout Notes

- Private Life Orchestration relationship: preserved. The audit confirms the
  retained design-system primitives support the Today / Goals / Time / You
  shell, global Capture, inspection details, local trust/receipt affordances,
  and accessibility requirement surface needed for private life orchestration.
- Final Architecture Tree inspected: yes.
- Canonical owners inspected: `App/`, `Stage/`, `DesignSystem/`,
  `Surfaces/Today`, `Surfaces/Goals`, `Surfaces/Time`, `Surfaces/You`,
  `Composer/Capture`, `Trust/`, and related tests.
- Canonical owners touched: none in production source.
- Files created: `docs/audits/amb-1748-design-system-adoption-proof.md`.
- Files moved: none.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Architecture debt: rendered screenshot, manual accessibility, visual review,
  and device proof remain outside this packet and must be produced by linked
  frontend proof gates before any Green visual/release claim.
- Next repair/proof train: AMB-1749, then AMB-1750; sibling frontend proof
  remains AMB-1734 through AMB-1744 plus AMB-1751.
- No equivalent folder/path interpretation was used.
