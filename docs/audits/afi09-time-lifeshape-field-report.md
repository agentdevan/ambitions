# AFI09 Time LifeShape Field Report

<!-- markdownlint-disable MD013 -->

Date: 2026-05-08
Status: Accepted Yellow
Batch: AFI09 Time LifeShape Field

## Result

AFI09 aligned the fourth top-level destination with active AFI source truth:
Time / Shape Time / LifeShape Field. The implementation keeps the existing
internal `.plan` route, Plan feature folder, and compatibility seams intact
while changing touched user-facing copy, screen contracts, preview fixtures,
and focused tests away from top-level Plan language.

## Files Changed

- `Native/Ambitions/Domain/ScreenContractModels.swift`
- `Native/Ambitions/Features/Plan/PlanScreen.swift`
- `Native/Ambitions/Features/Plan/PlanFeatureService.swift`
- `Native/Ambitions/Features/Plan/PlanCalendarAwarenessSupport.swift`
- `Native/Ambitions/Features/Plan/PlanLifeShapeTimeCapacityMap.swift`
- `Native/Ambitions/Features/Plan/PlanLifeSuiteState.swift`
- `Native/Ambitions/Features/Plan/PlanScreenContractSnapshot.swift`
- focused top-level, Calendar/reality, external-surface, preview, and contract
  copy seams that reference opening the fourth destination
- focused Time/Plan/app contract tests
- `scripts/ai/acx_visual_packet.py`
- batch/state/report docs

## Behavior Changed

The visible fourth destination now presents as Time, with Shape Time and
LifeShape Field as the primary object language. The touched top-level action
copy now says Open Time rather than Open Plan. Calendar-aware copy now frames
Calendar as an optional Time input, and manual mode remains explicit.

Internal route names, route raw values, feature folders, and compatibility APIs
continue to use Plan where the repo currently depends on that seam.

## Tests Run

- `xcodegen generate`
- Focused Time/contract/reality lane:
  `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/PlanFeatureServiceTests -only-testing:AmbitionsTests/ScreenContractRegistryTests -only-testing:AmbitionsTests/TopLevelSurfaceCompositionTests -only-testing:AmbitionsTests/LoadingDegradedStateDesignSystemTests -only-testing:AmbitionsTests/InteractionMotionHapticsDesignSystemTests -only-testing:AmbitionsTests/CalendarRealityServiceTests -only-testing:AmbitionsTests/RealityModelsTests -only-testing:AmbitionsTests/RealityIntegrationAdaptersTests -only-testing:AmbitionsTests/CalendarReminderActionFlowTests test CODE_SIGNING_ALLOWED=NO`
  passed with 72 selected tests, 0 failures. Raw log:
  `.codex/logs/2026-05-08T14-afi09-focused-tests-final.raw.log`.
- `./scripts/build-local.sh` passed. Raw log:
  `output/logs/build-local-20260508-133224.log`.
- `python3 -m py_compile scripts/ai/acx_visual_packet.py`
- `python3 scripts/ai/acx_visual_packet.py Time Native/Ambitions/Features/Plan/PlanScreen.swift Native/Ambitions/Features/Plan/PlanLifeShapeTimeCapacityMap.swift Native/Ambitions/Features/Plan/PlanLifeSuiteState.swift Native/Ambitions/Features/Plan/PlanScreenContractSnapshot.swift`
- `python3 scripts/ai/acx_accessibility_packet.py Time Native/Ambitions/Features/Plan/PlanScreen.swift Native/Ambitions/Features/Plan/PlanLifeShapeTimeCapacityMap.swift Native/Ambitions/Features/Plan/PlanLifeSuiteState.swift Native/Ambitions/Features/Plan/PlanScreenContractSnapshot.swift`
- `python3 -m py_compile scripts/ai/acx.py scripts/ai/acx_local.py scripts/ai/acx_impact.py scripts/ai/acx_closeout.py scripts/ai/acx_repair.py scripts/ai/acx_visual_packet.py scripts/ai/acx_accessibility_packet.py`
- `python3 scripts/ai/acx_local.py bundle quick`
- `python3 scripts/ai/acx_local.py bundle docs`
- `python3 scripts/ai/acx_local.py bundle batch-closeout`
- `python3 scripts/ai/acx_local.py bundle build-triage`
- `python3 scripts/ai/acx_local.py bundle codex-os`
- `python3 scripts/ai/acx_repair.py diagnose`
- `scripts/batch-train-gate-check.sh || true`
- `scripts/global-train-next-batch.sh`
- `git diff --check`

## Tests Not Run

- Rendered screenshot proof for default week/capacity state.
- Manual accessibility traversal for pressure/protected summaries.
- Full UI test suite.
- Physical-device validation.
- Signed archive validation.

## Known Risks

- The app build emitted unsigned simulator app-group warnings during simulator
  validation; focused tests and the local build still passed.
- Historical docs and internal compatibility seams still contain Plan-era
  identifiers. They were not treated as active top-level IA source truth.
- `scripts/ai/acx_visual_packet.py` now accepts Time and keeps Plan only as a
  compatibility alias for active AFI proof routing.
- Rendered screenshot and manual accessibility proof remain Yellow.
- The preserved stash remains Yellow evidence and was not applied.

## Claims

The touched Time/Plan surface, contract, Calendar-awareness, route-action,
external-surface, degraded-state, composition, preview-fixture, and focused-test
seams now respect active AFI Time / Shape Time / LifeShape Field language while
preserving internal compatibility seams.

## Non-Claims

No route/raw-value rename, persistence/schema migration, calendar-write
behavior, automatic scheduling, sync/cloud behavior, production readiness,
release readiness, App Store readiness, TestFlight readiness, physical-device
proof, public accessibility conformance, privacy/legal approval, migration
safety, backend completion, or CI green status is claimed.

## Next Eligible Batch

AFI10 You User System Profile.
