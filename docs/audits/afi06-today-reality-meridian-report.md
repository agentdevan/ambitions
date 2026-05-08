# AFI06 Today Reality Meridian Report

<!-- markdownlint-disable MD013 -->

Date: 2026-05-08
Status: Accepted Yellow
Batch: AFI06 Today Reality Meridian

## Result

AFI06 aligned Today to the active AFI object language: Reality Meridian plus
Start Here Surface. The existing Today mechanics remain intact, while
user-facing object titles, screen-contract content, motion policy titles,
degraded-state object labels, preview fixtures, and focused tests now assert
Reality Meridian instead of the older Reality Rail label.

## Files Changed

- `Native/Ambitions/Features/Today/DayRailProjection.swift`
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Native/Ambitions/Features/Today/TodayScreenContractSnapshot.swift`
- `Native/Ambitions/Domain/ScreenContractModels.swift`
- `Native/Ambitions/Features/Shared/DegradedStateOrchestrator.swift`
- `Native/Ambitions/Features/Profile/ProfileFeatureService.swift`
- `Native/Ambitions/PreviewSupport/PreviewFixtures.swift`
- `Sources/Components/TopLevelSurfaceCompositionPrimitives.swift`
- `Sources/Components/MotionPrimitives.swift`
- `Sources/Previews/SignatureInterfaceVisualQAFixtures.swift`
- focused Today/app contract tests
- batch/state/report docs

## Behavior Changed

Today now presents the flagship object as Reality Meridian in user-facing and
contract-facing labels. Start Here continuity copy now states that Start Here
emerges from the active Meridian node.

Internal `.realityRail` enum cases, `DayRail*` model/type names, and
`TodayRealityRail*` accessibility identifiers remain compatibility seams for
existing automation and code ownership.

## Tests Run

- `xcodegen generate`
- Focused Today/App contract lane:
  `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/TodayViewModelTests -only-testing:AmbitionsTests/TodayShellIntegrationTests -only-testing:AmbitionsTests/ScreenContractRegistryTests -only-testing:AmbitionsTests/InteractionMotionHapticsDesignSystemTests -only-testing:AmbitionsTests/TopLevelSurfaceCompositionTests test CODE_SIGNING_ALLOWED=NO`
  passed on rerun with 63 selected tests, 0 failures. Raw log:
  `.codex/logs/2026-05-08T11-afi06-focused-tests-rerun.raw.log`.
- First focused lane attempt failed at compile time because the new AFI06 test
  called `.contains` on optional `changeLabel`; the test was repaired with
  `XCTUnwrap`, then the lane passed.
- `scripts/build-local.sh` passed. Raw log:
  `output/logs/build-local-20260508-120540.log`.
- `python3 scripts/ai/acx_local.py bundle quick` passed.
- `python3 scripts/ai/acx_impact.py <AFI06 changed files>` passed and routed the
  batch through Today UI, You UI, and Codex docs/batch-closeout gates.
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

- Compatibility names still contain Reality Rail in internal identifiers/types.
- Rendered screenshot proof is not yet captured.
- Full UI test suite and manual accessibility traversal are not yet run.
- Existing ACX scan advisories include broad historical/product-drift and
  release-claim scanner hits outside this AFI06 touch scope.

## Claims

Today object language now follows active AFI Reality Meridian source truth in
the touched user-facing and contract-facing seams.

## Non-Claims

No route/raw-value rename, persistence/schema migration, full Today redesign,
rendered screenshot proof, accessibility conformance, performance proof,
release readiness, App Store readiness, TestFlight readiness, physical-device
proof, privacy/legal approval, sync readiness, backend completion, or
production readiness is claimed.

## Next Eligible Batch

AFI07 Goals Constellation Atlas.
