# AFI07 Goals Constellation Atlas Report

<!-- markdownlint-disable MD013 -->

Date: 2026-05-08
Status: Accepted Yellow
Batch: AFI07 Goals Constellation Atlas

## Result

AFI07 aligned top-level Goals with active AFI source truth: Your Direction,
Constellation Atlas, and Orbital Lens. Mission Control remains valid inside Goal
Detail and internal compatibility seams, but no longer serves as the top-level
Goals object language in the touched surface, contract, motion, degraded-state,
or preview seams.

## Files Changed

- `Native/Ambitions/Features/Goals/GoalComponents.swift`
- `Native/Ambitions/Features/Goals/GoalLifePathSignaturePrimitives.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureModels.swift`
- `Native/Ambitions/Features/Goals/GoalsScreen.swift`
- `Native/Ambitions/Features/Shared/DegradedStateOrchestrator.swift`
- `Native/Ambitions/Domain/ScreenContractModels.swift`
- `Sources/Components/TopLevelSurfaceCompositionPrimitives.swift`
- `Sources/Components/MotionPrimitives.swift`
- `Sources/Previews/DynamicAdaptiveVisualPreviews.swift`
- `Sources/Previews/SignatureInterfaceVisualQAFixtures.swift`
- focused Goals/app contract tests
- batch/state/report docs

## Behavior Changed

Goals now presents the top-level object as Your Direction / Constellation Atlas
with Orbital Lens for one goal thread. The focused projection preserves
equal-weight life areas, list fallback, and thread-to-Today copy while blocking
KPI, dashboard, ranked-score, habit-ring, astrology, and top-level Mission
Control drift in focused proof.

Internal Mission Control names remain where they own Goal Detail lane behavior
or preserve compatibility.

## Tests Run

- `xcodegen generate`
- Focused Goals/App contract lane:
  `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/GoalsOverviewBoardTests -only-testing:AmbitionsTests/GoalsShellIntegrationTests -only-testing:AmbitionsTests/ScreenContractRegistryTests -only-testing:AmbitionsTests/InteractionMotionHapticsDesignSystemTests -only-testing:AmbitionsTests/LoadingDegradedStateDesignSystemTests -only-testing:AmbitionsTests/TopLevelSurfaceCompositionTests test CODE_SIGNING_ALLOWED=NO`
  passed on rerun with 41 selected tests, 0 failures. Raw log:
  `.codex/logs/2026-05-08T12-afi07-focused-tests-rerun.raw.log`.
- First focused lane attempt failed one stale motion-policy expectation that
  still required the old Goals object phrase. The assertion was updated to the
  AFI07 state meaning, then the lane passed.
- `scripts/build-local.sh` passed. Raw log:
  `output/logs/build-local-20260508-123100.log`.
- `python3 scripts/ai/acx_local.py bundle quick` passed.
- `python3 scripts/ai/acx_impact.py <AFI07 changed files>` passed and routed
  the batch through Goals UI and Codex docs/batch-closeout gates.
- `python3 scripts/ai/acx_local.py bundle docs` passed Green with advisory
  Yellow scan findings.
- `python3 scripts/ai/acx_local.py bundle batch-closeout` passed Green with
  advisory Yellow scan findings.
- `python3 scripts/ai/acx_local.py bundle build-triage` returned informational
  Yellow because it prints discovered build/test docs only.
- `git diff --check` passed.

## Tests Not Run

- Rendered screenshots.
- Full UI test suite.
- Manual accessibility traversal.

## Known Risks

- Internal Mission Control identifiers remain as Goal Detail and compatibility
  seams.
- Rendered screenshot proof is not yet captured.
- Full UI test suite and manual accessibility traversal are not yet run.
- Existing ACX scan advisories include broad historical/product-drift and
  release-claim scanner hits outside this AFI07 touch scope.

## Claims

The touched top-level Goals object language follows active AFI source truth.

## Non-Claims

No route/raw-value rename, persistence/schema migration, full Goals redesign,
rendered screenshot proof, accessibility conformance, performance proof,
release readiness, App Store readiness, TestFlight readiness, physical-device
proof, privacy/legal approval, sync readiness, backend completion, or
production readiness is claimed.

## Next Eligible Batch

AFI08 Capture Atmosphere Composer.
