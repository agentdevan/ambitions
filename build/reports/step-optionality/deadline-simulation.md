# Deadline Simulation Proof

Batch: `IOS26-T04B-B03`
Date: `2026-05-23`

## What changed

- Added deterministic timeline-impact simulation types in `Native/Ambitions/Domain/GoalEngine/StepCandidateFieldModels.swift`.
- Attached per-candidate simulation output to `StepCandidate`.
- Wired the candidate generator to pass deadline, capacity, executable-state, and rejection-history context into each simulation.
- Phase 03 review repaired candidate/simulation ID alignment so `impactSimulation.candidateID` matches the final stable `StepCandidate.id`.
- Added focused simulation coverage in `Native/AmbitionsTests/Domain/StepCandidateFieldModelsTests.swift`.
- Added focused generator coverage in `Native/AmbitionsTests/Runtime/StepCandidateFieldGeneratorTests.swift`.

## Verified claims

- Each generated step candidate now carries deterministic local timeline-impact simulation.
- Lighter alternatives can increase future pressure and surface as compressed timeline paths.
- Skipping a critical candidate can surface deadline review pressure instead of pretending the timeline is fine.
- Equivalent alternatives preserve the same feasibility band when the schedule context is equivalent.
- Impossible timelines are surfaced as impossible under current constraints.
- Protected-time conflicts are surfaced explicitly.
- Codable round-trips preserve the simulation payload without echoing raw secret text into the field or summary text.
- Generated simulation payloads preserve the final candidate identifier used by ranking/replay.

## Validation run

- `make xcode-focused-test BATCH=IOS26-T04B-B03 TEST=AmbitionsTests/Domain/StepCandidateFieldModelsTests`
- `make xcode-focused-test BATCH=IOS26-T04B-B03 TEST=AmbitionsTests/Runtime/StepCandidateFieldGeneratorTests`
- `make xcode-focused-test BATCH=IOS26-T04B-B03 TEST=AmbitionsTests`
- `make xcode-focused-test BATCH=IOS26-T04B-B03 TEST=AmbitionsUITests`

## Validation results

- `AmbitionsTests/Domain/StepCandidateFieldModelsTests`: passed
- `AmbitionsTests/Runtime/StepCandidateFieldGeneratorTests`: passed
- `AmbitionsTests`: passed again in Phase 04 through `.codex/xcode-summaries/IOS26-T04B-B03/20260523T094956Z/focused-test-summary.json`.
- `AmbitionsUITests`: failed in Phase 04 through `.codex/xcode-summaries/IOS26-T04B-B03/20260523T093250Z/focused-test-summary.json`; the wrapper classified `test_failure` after executing 29 tests with 5 failures.

## iOS 26 API note

- No iOS 26-only date, duration, charting, layout, or accessibility API was introduced in this batch.

## Claims allowed

- Local deterministic simulation exists for each generated candidate.
- The simulation differentiates preserved, compressed, delayed, protected-time-threatened, deadline-review, scope-review, and impossible paths.
- The new simulation fields survive codable round-trips.
- The simulation candidate ID matches the generated `StepCandidate.id`.

## Claims forbidden

- No release, accessibility, device, TestFlight, App Store, or performance claim.
- No UI-shipped claim.
- No claim that the broader app surface is complete.
- No claim that unrelated dirty proof JSON files were modified or validated.
- No UI test pass claim from the latest Phase 04 wrapper run.

## Yellow / red items

- `AmbitionsUITests` failed in the latest wrapper lane with 5 failures in existing UI surfaces outside the IOS26-T04B-B03 domain/runtime simulation slice:
  - `testCapturePromotionOpensComposerWithSeededText`
  - `testDemoGoalsAtlasLoadsCoreModules`
  - `testPreviewBootstrapExposesCanonicalFiveTabShellAndSecondarySurfaces`
  - `testTodayCanHandOffToGoalDetail`
  - `testTodayStartNowCanOpenBoundedStepSession`
- Existing unrelated dirty proof JSON files in `docs/proof/amb-fe-be/moat-scenario-proof-98/` remain untouched.

## Rollback notes

- Revert only the touched IOS26-T04B-B03 source, test, and proof paths if needed.
- Leave unrelated worktree dirt alone.
