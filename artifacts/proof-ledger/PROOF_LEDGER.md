# Proof Ledger

Status: Active Codex OS v2 proof ledger
Authority: Process evidence ledger, subordinate to `docs/truth/RELEASE_TRUTH.md`

## Rules

Entries must include claim, commit, touched files, command, exit code, artifact path, screenshot path if visual, scope, non-claims, freshness, responsible program, related Linear issue, and Green/Yellow/Red evidence status.

## Entries

### 2026-06-11 - AMB-CODEX-OS-V2 Initial Validator Audit

- Claim: Existing Codex OS validator/doctor expectations were audited before v2 install.
- Commit: working tree before install from `b5bfa2ed891a412e0d9e43b99c744422fe2a990c`.
- Touched files: audit logs under `artifacts/codex-os-v2/script-output/`.
- Command: `python3 scripts/ambitions-codex-os-validate.py`; `python3 scripts/ambitions-codex-os-doctor.py`; `make scripts-doctor`; `make repo-doctor`.
- Exit code: validate `1`; doctor `0`; scripts-doctor `2`; repo-doctor terminated after bounded timeout.
- Artifact path: `artifacts/codex-os-v2/script-output/`.
- Screenshot path if visual: not applicable.
- Scope: Codex OS governance audit only.
- Non-claims: no app build, tests, accessibility, performance, privacy/legal, device, TestFlight, App Store, or release readiness proof.
- Freshness: current on 2026-06-11 for the local working tree.
- Responsible program: CODEX-OS.
- Related Linear issue: AMB-CODEX-OS-V2-001.
- Evidence status: Yellow/Red existing drift documented.

### 2026-06-11 - UIQL-001 Program Preflight

- Claim: UIQL-001 program preflight and authority refresh ran on `main` and identified the next UIQL dependency.
- Commit: pending UIQL-001 closeout commit at report creation.
- Touched files: UIQL artifacts, proof ledger, script-output logs.
- Command: `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-preflight.sh`; `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-mini-regression.sh`.
- Exit code: preflight `0`; mini-regression `0`.
- Artifact path: `artifacts/ui-quality-lockdown/UIQL-001_PREFLIGHT_REPORT.md`; `artifacts/ui-quality-lockdown/script-output/`.
- Screenshot path if visual: not applicable.
- Scope: UIQL preflight and authority refresh only.
- Non-claims: no app source change, app test change, screenshot proof, visual approval, accessibility conformance, owner approval, release readiness, TestFlight readiness, App Store readiness, physical-device proof, performance proof, or privacy/legal approval.
- Freshness: current on 2026-06-11 for branch `main` at start HEAD `51db282625ff08fba17fe89faa0f26273adbd73e`.
- Responsible program: UIQL.
- Related Linear issue: UIQL-001; issue not found by available Linear fetch.
- Evidence status: UIQL-001 preflight Green; dependent UIQL work Red-blocked by stale Activation Contract IA/test expectation.

### 2026-06-11 - UIQL-001 Activation Contract Canon Repair

- Claim: The stale `ActivationContractTests` expectation that promoted Capture into canonical `AppTab.allCases` was repaired and validated after rebuilding the test bundle.
- Commit: pending UIQL-001 repair closeout commit at report creation.
- Touched files: `Native/AmbitionsTests/App/ActivationContractTests.swift`; UIQL repair artifacts; proof ledger.
- Command: `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-mini-regression.sh`; `scripts/ambitions-xcode-build-for-testing.sh --batch UIQL-001`; `scripts/ambitions-xcode-test-focused.sh --batch UIQL-001 --only-testing AmbitionsTests/ActivationContractTests`.
- Exit code: mini-regression `0`; build-for-testing `0`; rebuilt focused test `0`.
- Artifact path: `artifacts/ui-quality-lockdown/UIQL-001_ACTIVATION_CONTRACT_REPAIR.md`; `artifacts/ui-quality-lockdown/script-output/UIQL-001-build-for-testing-20260611T051751Z.log`; `artifacts/ui-quality-lockdown/script-output/UIQL-001-activation-contract-focused-test-rebuilt-20260611T051909Z.log`.
- Screenshot path if visual: not applicable.
- Scope: UIQL stale test-canon repair only.
- Non-claims: no runtime behavior change, screenshot proof, visual approval, accessibility conformance, owner approval, release readiness, TestFlight readiness, App Store readiness, physical-device proof, performance proof, privacy/legal approval, or broader UIQL product Green.
- Freshness: current on 2026-06-11 for branch `main` after rebuilding local derived data.
- Responsible program: UIQL.
- Related Linear issue: UIQL-001; issue not found by available Linear fetch.
- Evidence status: Green for the scoped stale Activation Contract test repair; Yellow for visual/accessibility/release/owner claims not in scope.

### 2026-06-11 - UIQL-002 Shell Geometry And Safe-Area Proof

- Claim: UIQL-002 shell geometry Reds were repaired so root shell header controls stay inside the app window, canonical tab buttons remain hittable with 44pt targets, Capture remains out of the top-level tab bar, and activated Capture seam stays above the native tab bar after keyboard dismissal.
- Commit: pending UIQL-002 closeout commit at report creation.
- Touched files: `Native/Ambitions/App/AppShellView.swift`; `Native/Ambitions/App/AmbitionsRootView.swift`; `Native/AmbitionsUITests/AmbitionsUITests.swift`; UIQL proof artifacts; proof ledger.
- Command: `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-preflight.sh`; `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-mini-regression.sh`; `scripts/ambitions-xcode-build-for-testing.sh --batch UIQL-002`; `scripts/ambitions-xcode-test-focused.sh --batch UIQL-002 --only-testing AmbitionsUITests/AmbitionsUITests/testUIQL002ShellGeometryKeepsChromeInsideSafeAreasAndDockHittable`; `scripts/ambitions-xcode-test-focused.sh --batch UIQL-002 --only-testing AmbitionsUITests/AmbitionsUITests/testUIQL002ActivatedCaptureSeamStaysAboveNativeDockAfterKeyboardDismissal`.
- Exit code: preflight `0`; mini-regression `0`; final build-for-testing `0`; shell geometry UI test `0`; activated Capture seam UI test `0`.
- Artifact path: `artifacts/ui-quality-lockdown/UIQL-002_SHELL_GEOMETRY_PROOF.md`; `artifacts/ui-quality-lockdown/UIQL-002_REPAIR_REFRAME_REPORT.md`; final logs under `artifacts/ui-quality-lockdown/script-output/`.
- Screenshot path if visual: not applicable; no screenshot approval claimed.
- Scope: UIQL-002 shell geometry and safe-area proof only.
- Non-claims: no screenshot approval, full accessibility certification, Dynamic Type certification, VoiceOver proof, Increase Contrast proof, physical-device proof, performance proof, privacy/legal approval, owner approval, release readiness, TestFlight readiness, App Store readiness, or UIQL-003+ surface quality.
- Freshness: current on 2026-06-11 for branch `main` after rebuilding local derived data.
- Responsible program: UIQL.
- Related Linear issue: UIQL-002; issue not found by available Linear connector.
- Evidence status: Green for scoped UIQL-002 shell geometry and safe-area repair; Yellow only for Linear issue unavailable and non-claimed screenshot/accessibility/owner/release proof.

### 2026-06-11 - UIQL-003 Today Reality Meridian Quality Gate

- Claim: Today / Reality Meridian first viewport uses current Start here object-stage language, removes stale/generic task/card/dashboard copy from touched Today projections, and is validated by current build/test/unit proof plus visual screenshot evaluation.
- Commit: pending UIQL-003 closeout commit at report creation.
- Touched files: `Native/Ambitions/Features/Today/TodayFeatureService.swift`; `Native/Ambitions/Features/Today/TodayExecutionProjector.swift`; `Native/Ambitions/Features/Today/TodayExecutionCompatibility.swift`; `Native/AmbitionsUITests/AmbitionsUITests.swift`; UIQL proof artifacts; proof ledger.
- Command: `git diff --check`; `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-scan-banned-copy.sh`; `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-scan-card-anatomy.sh`; `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-mini-regression.sh`; `scripts/ambitions-xcode-build-for-testing.sh --batch UIQL-003`; `AMBITIONS_SIM_UDID=8ACCD665-4807-4102-B526-5A1AE20686A8 scripts/ambitions-xcode-test-focused.sh --batch UIQL-003 --only-testing AmbitionsUITests/AmbitionsUITests/testUIQL003TodayRealityMeridianOwnsFirstViewportWithoutGenericTaskAnatomy`; `AMBITIONS_SIM_UDID=8ACCD665-4807-4102-B526-5A1AE20686A8 scripts/ambitions-xcode-test-focused.sh --batch UIQL-003 --only-testing AmbitionsTests/TodayViewModelTests/testF02RealityRailVisibleCopyAvoidsForbiddenTerms`; `AMBITIONS_SIM_UDID=8ACCD665-4807-4102-B526-5A1AE20686A8 scripts/ambitions-xcode-test-focused.sh --batch UIQL-003 --only-testing AmbitionsTests/TodayRealityMeridianExperienceElevationTests`.
- Exit code: diff-check `0`; banned-copy scan `0`; card-anatomy scan `0`; mini-regression `0`; final build-for-testing `0`; final focused UI test `0`; visible-copy unit test `0`; object-stage unit suite `0`.
- Artifact path: `artifacts/ui-quality-lockdown/UIQL-003_TODAY_REALITY_MERIDIAN_PROOF.md`; final logs under `artifacts/ui-quality-lockdown/script-output/`.
- Screenshot path if visual: `artifacts/ui-quality-lockdown/screenshots/UIQL-003-today-preview-stable-final.png`.
- Scope: UIQL-003 Today first-viewport Reality Meridian quality gate only.
- Non-claims: no full accessibility certification, VoiceOver audit, Dynamic Type certification beyond current contracts, Reduce Motion audit, Increase Contrast audit, physical-device proof, performance proof, privacy/legal approval, owner approval, release readiness, TestFlight readiness, App Store readiness, PLOS runtime completeness, or UIQL-004+ proof.
- Freshness: current on 2026-06-11 for branch `main` after rebuilding local derived data and visually inspecting the current simulator screenshot.
- Responsible program: UIQL.
- Related Linear issue: UIQL-003; issue not found by available Linear connector.
- Evidence status: Green for scoped UIQL-003 Today / Reality Meridian quality gate; Yellow only for Linear issue unavailable and non-claimed accessibility/device/owner/release proof.

### 2026-06-11 - UIQL-004 Start Here Recommendation Object Quality Gate

- Claim: Today Start Here recommendation object presents explicit Recommended step framing, canonical Start Here action labels, source/proof/receipt context, and privacy-safe kernel projection behavior.
- Commit: pending UIQL-004 closeout commit at report creation.
- Touched files: `Native/Ambitions/Features/Today/StartHereProductKernelProjection.swift`; `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`; `Native/AmbitionsTests/Today/TodayViewModelTests.swift`; `Native/AmbitionsUITests/AmbitionsUITests.swift`; UIQL proof artifacts; proof ledger.
- Command: `git diff --check`; `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-scan-banned-copy.sh`; `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-scan-card-anatomy.sh`; `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-mini-regression.sh`; `scripts/ambitions-xcode-build-for-testing.sh --batch UIQL-004`; `AMBITIONS_SIM_UDID=8ACCD665-4807-4102-B526-5A1AE20686A8 scripts/ambitions-xcode-test-focused.sh --batch UIQL-004 --only-testing AmbitionsUITests/AmbitionsUITests/testUIQL003TodayRealityMeridianOwnsFirstViewportWithoutGenericTaskAnatomy`; `AMBITIONS_SIM_UDID=8ACCD665-4807-4102-B526-5A1AE20686A8 scripts/ambitions-xcode-test-focused.sh --batch UIQL-004 --only-testing AmbitionsTests/TodayViewModelTests/testUIQL004StartHereKernelProjectionBindsRecommendationObjectProof`; `AMBITIONS_SIM_UDID=8ACCD665-4807-4102-B526-5A1AE20686A8 scripts/ambitions-xcode-test-focused.sh --batch UIQL-004 --only-testing AmbitionsTests/TodayViewModelTests/testUIQL004PrivateStartHereKernelKeepsRecommendationProofRedacted`.
- Exit code: diff-check `0`; banned-copy scan `0`; card-anatomy scan `0`; mini-regression `0`; final build-for-testing `0`; final focused Today UI test `0`; public kernel unit test `0`; private-redaction kernel unit test `0`.
- Artifact path: `artifacts/ui-quality-lockdown/UIQL-004_START_HERE_RECOMMENDATION_PROOF.md`; `artifacts/ui-quality-lockdown/UIQL-004_REPAIR_REFRAME_REPORT.md`; final logs under `artifacts/ui-quality-lockdown/script-output/`.
- Screenshot path if visual: `artifacts/ui-quality-lockdown/screenshots/UIQL-004-start-here-recommendation-final.png`.
- Scope: UIQL-004 Start Here recommendation object quality gate only.
- Non-claims: no full accessibility certification, VoiceOver audit, Dynamic Type certification, Reduce Motion audit, Increase Contrast audit, physical-device proof, performance proof, privacy/legal approval, owner approval, release readiness, TestFlight readiness, App Store readiness, PLOS runtime completeness, or UIQL-005+ proof.
- Freshness: current on 2026-06-11 for branch `main` after rebuilding local derived data and visually inspecting the current simulator screenshot.
- Responsible program: UIQL.
- Related Linear issue: UIQL-004; issue not found by available Linear connector.
- Evidence status: Green for scoped UIQL-004 Start Here recommendation object quality gate; Yellow only for Linear issue unavailable and non-claimed accessibility/device/owner/release proof.
