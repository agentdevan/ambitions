# AMB-1749 Frontend Evidence Harness

Status: Ready for review
Date: 2026-07-04
Scope: AMB-1749, Architecture Simplification + Flagship Readiness Remediation
Baseline SHA: `432a5eaee16e8d1135e18bb23b805584aae14add`
Linear status before audit: `Spec Ready`

## Purpose

AMB-1749 installs the frontend evidence harness/index needed before frontend
quality claims can rely on screenshots, UI journeys, accessibility checks, and
stable artifact paths.

This packet is a harness and evidence-index change. It does not run the full
rendered screenshot matrix, prove visual quality, prove accessibility
conformance, prove physical-device behavior, or prove release readiness.

## Linear Scope

AMB-1749 acceptance requires:

- fast frontend local lane
- Root, Capture, Today, Goals, Time, and You UI journeys
- screenshot artifact capture
- accessibility smoke
- Dynamic Type and Reduce Motion checks
- frontend release evidence indexing
- stable screenshot artifact paths
- separation between slow release checks and fast local checks
- no frontend Green claim inferred from unit tests alone

## Harness Artifacts

Retained artifacts:

- Manifest: `docs/audits/amb-1749-frontend-evidence-harness.json`
- Validator/launcher: `scripts/ambitions-frontend-evidence-harness.py`
- Audit packet: `docs/audits/amb-1749-frontend-evidence-harness.md`

Stable local artifact roots:

- Fast local lane:
  `.codex/xcode-results/AMB_1749_FRONTEND_FAST_LOCAL/`
  `.codex/xcode-logs/AMB_1749_FRONTEND_FAST_LOCAL/`
  `.codex/xcode-summaries/AMB_1749_FRONTEND_FAST_LOCAL/`
- Screenshot artifact lane:
  `.codex/xcode-results/AMB_1749_FRONTEND_SCREENSHOT_ARTIFACTS/`
  `.codex/xcode-logs/AMB_1749_FRONTEND_SCREENSHOT_ARTIFACTS/`
  `.codex/xcode-summaries/AMB_1749_FRONTEND_SCREENSHOT_ARTIFACTS/`
- Release index lane:
  `.codex/xcode-results/AMB_1749_FRONTEND_RELEASE_INDEX/`
  `.codex/xcode-logs/AMB_1749_FRONTEND_RELEASE_INDEX/`
  `.codex/xcode-summaries/AMB_1749_FRONTEND_RELEASE_INDEX/`

The `.codex` paths are local working evidence paths, not visual acceptance.
Any final visual, accessibility, device, TestFlight, App Store, or Release
Green claim still requires the current proof artifacts and review gates named
in `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md` and
`docs/truth/RELEASE_TRUTH.md`.

## Lane Separation

| Lane | Command owner | Purpose | Claim ceiling |
| --- | --- | --- | --- |
| `fast_frontend_local` | `scripts/ambitions-xcode-validate.sh --lane focused-test` | Runs source-route, shell, visual-fixture, and accessibility contract checks. | Harness/source coverage only; no visual quality, accessibility conformance, device, or frontend Green claim. |
| `frontend_screenshot_artifacts` | `scripts/ambitions-run-ui-screenshot-matrix.sh` plus `scripts/ambitions-xcode-test-focused.sh` over `VisualTargetAttachmentUITests` | Captures rendered screenshot attachments and extracts them from result bundles under stable local paths. | Screenshot artifact existence for that run only; no visual acceptance or release claim. |
| `frontend_release_index` | `scripts/ambitions-frontend-evidence-harness.py --check --json` | Verifies the evidence index and proof-denial locks before release proof can reference frontend quality. | Index proof only; AMB-1750 owns frontend release Green/Yellow/Red and device-sensitive claims. |

This separation addresses the current test-speed issue: fast local checks must
not pay screenshot/release proof cost by default, and slow proof lanes must not
be silently counted as ordinary unit-test Green.

## Journey Coverage Index

| Journey | Current source/test index | Required evidence before Green |
| --- | --- | --- |
| Root shell | `testPreviewBootstrapExposesCanonicalFourTabShellAndSecondarySurfaces`, `testUIQL002ShellGeometryKeepsChromeInsideSafeAreasAndDockHittable`, `testAFRI005ShellScreenshotBaselineCapturesCanonicalTabs` in `Native/AmbitionsUITests/AmbitionsUITests.swift`. | Current screenshot or explicit not-run reason, safe-area note, root dock note, independent visual review before Visual Green. |
| Capture | `testUIQL002ActivatedCaptureSeamUsesOverlayKeyboardClearanceWithoutRootDock`, `testAMB967CaptureCreateGoalScreenshotMatrix`, `testCaptureComposerLaunchKeepsGlobalCaptureComposerReachable`. | Current screenshot or not-run reason, keyboard clearance note, proof that Capture remains global composer and not a root destination. |
| Today | `testTodaySurfaceShowsDominantHeroAndPrimaryAction`, `testAMB962TodayReconstructionScreenshotMatrix`, `testTodayCanHandOffToGoalDetail`, `testTodayCanHandOffToTime`. | Current Start here screenshot evidence, handoff evidence, and no generic task/dashboard drift. |
| Goals | `testDemoGoalsAtlasLoadsCoreModules`, `testAMB963GoalsReconstructionScreenshotMatrix`, `testDemoGoalsAtlasPrimaryActionAndCardRouteToGoalDetail`. | Current Goals screenshot evidence and goal-detail route evidence. |
| Time | `testDemoTimeWorkspaceShowsBatch49CoreModules`, `testAMB964TimeReconstructionScreenshotMatrix`, `testAMB1174TimeVisualFlagshipLayerScreenshotProof`, `testAMB1176TimeEmptyAndAccessibilityProofPacket`. | Current Time screenshot evidence, Dynamic Type note, Reduce Motion note, and visual review. |
| You | `testYouScreenshotProofLaunchStatesOpenRequiredDetailSheets`, `testAMB966YouReconstructionScreenshotMatrix`, `testYouTrustSurfaceShowsConservativeExternalStatusLabels`. | Current You/Trust screenshots, conservative status evidence, and privacy/trust review. |
| Inspection | `testSourceInspectionYouSourcesAttachesRenderedProofScreenshots` in `Native/AmbitionsUITests/VisualTargetAttachmentUITests.swift`. | Current Source inspection screenshots, accessibility-size evidence, and no release/device claim without AMB-1750 proof. |

## Accessibility Smoke Index

The harness indexes existing automated contract tests for:

- Dynamic Type contract coverage:
  `AccessibilityAdaptiveInterfaceDesignSystemTests.testSI15PrimarySurfaceAccessibilitySummariesCoverAllActiveObjectTargets`
  and `testSI15RequirementsKeepAccessibilityEvidenceExplicitAndNonColor`.
- Reduce Motion contract coverage:
  `AccessibilityAdaptiveInterfaceDesignSystemTests.testSI15RequirementsKeepAccessibilityEvidenceExplicitAndNonColor`.
- Visual/accessibility claim locks:
  `SignatureInterfaceVisualQAFixtureTests.testSI16FixturesStayEvidenceOnlyWithoutRuntimeOrProofClaims`
  and `testAFI13VisualQAScorecardsLockActiveSurfaceTargetsWithoutClaims`.

These are accessibility smoke and requirement-index checks only. They do not
prove accessibility conformance, manual VoiceOver behavior, physical-device
behavior, or public accessibility claims.

## Sibling Frontend Recovery Coverage

The manifest links the harness to the Ambitions Flagship Frontend Recovery
project and indexes AMB-1733 through AMB-1744 plus AMB-1751 as the sibling
frontend implementation/proof work. AMB-1749 does not close those frontend
parents. It provides the architecture-side harness so their evidence can be
captured, separated by lane, and kept out of fake frontend Green claims.

## Acceptance Mapping

| AMB-1749 acceptance criterion | Current result |
| --- | --- |
| Evidence harness covers the sibling frontend recovery project. | Present. The manifest records the sibling project id and indexes AMB-1733 through AMB-1744 plus AMB-1751. |
| Screenshot artifacts have stable paths. | Present. The harness fixes local result, log, and summary roots for fast, screenshot, and release-index lanes. |
| Slow release checks are separated from fast local checks. | Present. `fast_frontend_local`, `frontend_screenshot_artifacts`, and `frontend_release_index` are separate lanes with separate artifact roots and claim ceilings. |
| No frontend Green claim is inferred from unit tests alone. | Present. Manifest claim locks and validator checks require denial of unit-test-only frontend Green, Visual Green without independent review, accessibility conformance without evidence, and device/release claims without AMB-1750 proof. |

## Proof Ceiling

Claim status for AMB-1749: Implemented Yellow / Ready for review.

Allowed claim:

- Current repo now has a machine-readable frontend evidence harness/index with
  stable local artifact paths, lane separation, journey coverage references,
  accessibility smoke references, and no-fake-Green claim locks.

Forbidden claims from this packet:

- rendered screenshot coverage for a current run
- rendered visual quality
- accessibility conformance
- physical-device behavior
- frontend Visual Green
- TestFlight readiness
- App Store readiness
- Release Green
- completion of AMB-1733 through AMB-1744 or AMB-1751

## Validation

Validation to run for this packet:

- `python3 scripts/ambitions-frontend-evidence-harness.py --check --json`
- `git diff --check`
- `python3 scripts/ambitions-remediation-governance-check.py`
- `python3 scripts/ambitions-accepted-yellow-misuse-audit.py`
- `python3 scripts/ambitions-unsupported-claim-scan.py docs/audits/amb-1749-frontend-evidence-harness.md`
- `python3 scripts/ambitions-copy-contract-lint.py`

If the slow screenshot lane is not run in the AMB-1749 execution turn, the
closeout must keep screenshot proof as not produced and preserve the AMB-1750
release/device proof dependency.

## Closeout Notes

- Private Life Orchestration relationship: preserved. The harness protects the
  proof side of `Intent -> Context -> Path -> Time Fit -> Reflow -> Action ->
  Proof -> Learning` by requiring current frontend evidence before surface or
  release quality claims.
- Final Architecture Tree inspected: yes.
- Canonical owners inspected: `App/`, `Stage/`, `DesignSystem/`,
  `Surfaces/Today`, `Surfaces/Goals`, `Surfaces/Time`, `Surfaces/You`,
  `Composer/Capture`, `Trust/`, `Quality/`, and related test/script owners.
- Canonical owners touched: none in production source.
- Files created: `docs/audits/amb-1749-frontend-evidence-harness.json`,
  `docs/audits/amb-1749-frontend-evidence-harness.md`, and
  `scripts/ambitions-frontend-evidence-harness.py`.
- Files moved: none.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Architecture debt: current rendered screenshot, manual accessibility,
  independent visual review, and device proof remain outside this packet and
  are required before frontend Green or release claims.
- Next proof train: AMB-1750 Visual Green / App Store Frontend Proof Gate.
- No equivalent folder/path interpretation was used.
