# AMB-1047 / M00.T01 Canon Authority and IA Lock

Ambitions Master Build train closeout

Linear project: Ambitions Personal Life OS Runtime + Native iPhone App Master Build Program (`ca716546-e3d4-4d5b-a399-03076ccba9ee`)

Linear issue: `AMB-1047`

Train label: `M00.T01`

## Scope

Lock the active Ambitions IA and canon as `Today / Goals / Time / Motion / You` with Capture as a global Atmosphere Composer action, not a top-level tab. This train updates source, support reports, fixtures, tests, and repo-native validators that still carried stale root-surface assumptions.

## Green/Yellow/Red status

Green/Yellow/Red status: Green for the scoped AMB-1047 canon/IA lock after focused simulator validation.

Pushed to main: no, pending AMB-1047 commit.

Push hash: pending commit.

App source changed: yes.

Runtime behavior changed: Scoped user-facing canon/UI contract update in global Capture and app-intent description; no storage, recommendation, data mutation, privacy, sync, release, or scheduling runtime behavior changed.

Linear identifiers used: `AMB-*` issue identifiers only.

## Files changed:

- `docs/truth/PRODUCT_DESIGN_TRUTH.md` - removed ambiguous Motion ordinal language.
- `Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift` - updates Shortcut description to active IA plus global Capture.
- `Native/Ambitions/Features/Capture/CaptureScreen.swift` - removes stale top-level Capture composition usage and uses the existing Capture prompt/stage.
- `Native/Ambitions/Support/ReleaseDeviceQAReadinessReport.swift` - updates representative journey copy to Motion.
- `Native/Ambitions/Support/ReleasePerformanceResponsivenessReport.swift` - updates performance surface enum/report from root Capture to Motion plus global Capture.
- `Sources/Components/TopLevelSurfaceCompositionPrimitives.swift` - replaces root Capture with Motion and global Capture handoffs in SI17/AFI14 composition.
- `Sources/Components/DynamicAdaptiveVisualPrimitives.swift` - adds Motion tab visual context.
- `Sources/Previews/SignatureInterfaceVisualQAFixtures.swift` - updates SI16/AFI13 fixture rows, scorecards, drift gallery, and canonical order.
- `Sources/Previews/TopLevelSurfaceCompositionPreviews.swift` - selects Motion in the top-level composition preview.
- `Native/AmbitionsTests/App/FrontendRecoveryGateTests.swift` - locks active root tabs and rejects Capture/Pulse as roots.
- `Native/AmbitionsTests/App/TopLevelSurfaceCompositionTests.swift` - locks Today / Goals / Time / Motion / You composition and grammar.
- `Native/AmbitionsTests/App/SignatureInterfaceVisualQAFixtureTests.swift` - locks SI16/AFI13 fixture coverage and Motion drift gallery requirements.
- `Native/AmbitionsTests/App/ReleasePerformanceResponsivenessReportTests.swift` - locks Motion performance surface expectations.
- `Native/AmbitionsTests/Today/TodayViewModelTests.swift` - updates canonical top-level tab expectation.
- `scripts/codex/amb-master-canon-ia-validate.py` - new AMB master canon/IA validator.
- `scripts/codex/amb-master-readiness-validate.py` and `scripts/codex/program-preflight.sh` - require the canon/IA validator.
- `docs/codex/AMB_MASTER_VALIDATION_REGISTRY.md` and `artifacts/ambitions-master-build/AMB_MASTER_PHASE_GATES.md` - add AMB-1047 canon/IA validation gate.
- `artifacts/ambitions-master-build/AMB_MASTER-run-state.md`, issue map, execution queue, and this report - record AMB-1047 local Green handoff state.

## Validation run:

- `python3 scripts/codex/amb-master-canon-ia-validate.py` - pass.
- `python3 scripts/codex/amb-master-readiness-validate.py` - pass.
- `scripts/codex/program-phase-gate.sh amb-master M00` - pass, `artifacts/ambitions-master-build/script-output/program-phase-gate-M00-20260614T031549.log`.
- `git diff --check` - pass.
- `python3 -m json.tool artifacts/ambitions-master-build/AMB_MASTER_EXECUTION_QUEUE.json` - pass.
- `python3 -m json.tool artifacts/ambitions-master-build/AMB_MASTER_LINEAR_ISSUE_MAP.json` - pass.
- `python3 scripts/ambitions-champion-coverage-check.py --batch AMB-1047` - pass / Green, report `build/reports/intelligence-consolidation/champion-coverage-check.md`.
- `python3 scripts/ambitions-parallel-implementation-scan.py` - Yellow advisory, report `build/reports/intelligence-consolidation/parallel-implementation-scan.md`.
- Focused direct simulator test:
  `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -configuration Debug -destination "platform=iOS Simulator,id=8ACCD665-4807-4102-B526-5A1AE20686A8" -derivedDataPath output/DerivedData-AMB1047 -only-testing:AmbitionsTests/FrontendRecoveryGateTests -only-testing:AmbitionsTests/TopLevelSurfaceCompositionTests -only-testing:AmbitionsTests/SignatureInterfaceVisualQAFixtureTests -only-testing:AmbitionsTests/ReleasePerformanceResponsivenessReportTests -only-testing:AmbitionsTests/ReleaseDeviceQAReadinessReportTests -only-testing:AmbitionsTests/TodayViewModelTests/testRepositoryBackedServiceIncludesOneStepGoalsPanelForCommittedCapture` - pass, 31 tests, 0 failures.
- Focused test log: `artifacts/ambitions-master-build/script-output/AMB-1047-focused-xcodebuild-20260614T030812.log`.
- Result bundle: `output/DerivedData-AMB1047/Logs/Test/Test-Ambitions-2026.06.14_03-09-54--0400.xcresult`.

## Proof artifacts:

- `scripts/codex/amb-master-canon-ia-validate.py`
- `artifacts/ambitions-master-build/AMB_MASTER-run-state.md`
- `artifacts/ambitions-master-build/AMB_MASTER_EXECUTION_QUEUE.md`
- `artifacts/ambitions-master-build/AMB_MASTER_LINEAR_ISSUE_MAP.md`
- `artifacts/ambitions-master-build/AMB_MASTER_PHASE_GATES.md`
- `artifacts/ambitions-master-build/reports/AMB-1047-amb-master-canon-ia-lock.md`
- `artifacts/ambitions-master-build/script-output/AMB-1047-focused-xcodebuild-20260614T030812.log`

## Red blockers

Red blockers: none for AMB-1047 scoped canon/IA lock.

## Yellow limits

Yellow limits: the broad parallel implementation scan remains Yellow for pre-existing duplicate-surface/advisory clusters outside this AMB-1047 canon lock. XcodeBuildMCP timed out earlier at the tool boundary, so direct `xcodebuild` is the passing build/test proof. No screenshot, visual human approval, VoiceOver audit, Dynamic Type walkthrough, Increase Contrast walkthrough, physical-device proof, performance measurement, privacy/legal approval, TestFlight proof, or App Store proof is claimed.

Owner approval claimed: no.

Release/TestFlight/App Store readiness claimed: no.

Accessibility certification claimed: no.

Privacy/legal approval claimed: no.

## Rollback:

- `git revert <AMB-1047-commit-sha>` after commit, or path-level revert of the listed source/test/support/validator changes if unsafe before commit.

Next train: `AMB-1048` / `M00.T02` Live repository wiring and quarantine proof.
