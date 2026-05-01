# Ambitions 3.0 F10 Plan Life Suite Foundation Report

Date: 2026-04-30
Result: Green with accepted background Yellow

## Resume Context

F10 resumed after a usage/compaction stop. The repo was on `main` at
`69b88d93 Complete F09 capture to goal handoff`, with only expected F10 Plan,
preview, and Plan test changes in the working tree. The previous stop point was
preview fixture constructors missing the new `lifeSuite` dashboard field while
Plan screen-contract extraction was in progress.

## Implementation

- Added `PlanLifeSuiteState`, `PlanLifeSuiteShapeState`, and
  `PlanLifeSuiteProjector`.
- Wired `PlanDashboard.lifeSuite` through `RepositoryBackedPlanService`.
- Projected Day Shape, Week Shape, and Life Shape as Plan-owned value state.
- Kept calendar behavior optional and confirmation-bound with no silent changes.
- Added deterministic seeded and empty preview fixtures for `lifeSuite`.
- Extracted `PlanDashboard.screenContractSnapshot` into
  `PlanScreenContractSnapshot.swift`.
- Updated the Plan screen contract so Day Shape, Week Shape, and Life Shape are
  first-screen contract content.
- Added focused Plan service assertions for the F10 value-state contract.

F10 did not implement F11 Day/Week Shape behavior, F12 reflow/recovery/decision
behavior, Today handoff changes, dependencies, workflow changes, Shell/Meridian,
or release-readiness claims.

## Files Changed

- `Native/Ambitions/Features/Plan/PlanLifeSuiteState.swift`
- `Native/Ambitions/Features/Plan/PlanScreenContractSnapshot.swift`
- `Native/Ambitions/Features/Plan/PlanFeatureModels.swift`
- `Native/Ambitions/Features/Plan/PlanFeatureService.swift`
- `Native/Ambitions/Domain/ScreenContractModels.swift`
- `Native/Ambitions/PreviewSupport/PreviewPlanScenarios.swift`
- `Native/AmbitionsTests/Plan/PlanFeatureServiceTests.swift`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`

## Architecture

- `PlanFeatureModels.swift`: 705 lines before F10, 666 lines after extraction.
- `PlanScreenContractSnapshot.swift`: new focused 47-line extraction.
- `PlanLifeSuiteState.swift`: new focused 104-line value-state/projector file.
- `PlanFeatureService.swift`: 2379 lines before F10, 2387 lines after narrow
  F10 wiring; remains pre-existing `EXTRACTION_REQUIRED`.
- `PlanScreen.swift`: remains pre-existing `EXTRACTION_REQUIRED`.
- `PreviewPlanScenarios.swift`: 708 lines before F10, 736 lines after preview
  fixture repair; now `EXTRACTION_RECOMMENDED`.

Architecture classification: accepted background Yellow, not a new F10 stopper.
F10 improved the model file boundary by extracting the screen contract and kept
new state out of the oversized Plan screen/service files except for unavoidable
dashboard wiring.

## Validation

- `scripts/build-local.sh`: PASS on iPhone 17.
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination
  'platform=iOS Simulator,name=iPhone 17'
  -only-testing:AmbitionsTests/PlanFeatureServiceTests test
  CODE_SIGNING_ALLOWED=NO`: PASS, 26 tests.
- `PlanViewModelTests`: not run because no `PlanViewModelTests` file exists in
  `Native/AmbitionsTests/Plan`; the relevant focused Plan suite is
  `PlanFeatureServiceTests`.
- `scripts/swiftui-architecture-scan.sh || true`: advisory only.
- touched-path copy scan: advisory hits only; no new fake AI, sync,
  productivity-score, shame, or silent-automation claim introduced.
- `scripts/run-doc-qa.sh || true`: completed with known advisory stale-guidance,
  deprecated-language, markdownlint, and lychee backlog.
- `git diff --check`: PASS.

## Privacy And Accessibility

F10 is a local Plan value-state foundation. It adds no account, sync, hidden
personalization, calendar write, silent replanning, or external data behavior.
The new state explicitly keeps suggestions confirmation-bound and calendar use
optional. Screen-contract privacy/accessibility flags remain true.

## Gate

F10 gate result: Green.

Accepted background Yellow remains:

- doc QA advisory backlog unchanged
- known full UI smoke failures outside current focused scope
- pre-existing large Plan files outside the narrow F10 extraction/wiring risk
- pre-existing legacy/internal identifier language debt outside F10

F11 may proceed after the F10 commit and push succeed.
