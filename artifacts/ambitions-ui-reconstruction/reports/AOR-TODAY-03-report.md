# AOR-TODAY-03 Report - Today Trust, Receipts, Closure, States

Status: Green
Issue: AMB-524
Date: 2026-06-06
Base commit: `b7628de118f9d3df8ecc63413309b8879fe31f65`

## Truth Files Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`

## Scope

AMB-524 verified and exposed Today state depth after the Reality Meridian and Start Here reconstruction. The change keeps trust, source, receipt, closure, and recovery depth attached to Today and drill-down sheets instead of adding root panels or a state-card inspection surface.

## Changed Source

- `Native/Ambitions/Features/Today/TodayScreen.swift`
  - Added DEBUG-only screenshot controls:
    - `-AmbitionsTodayEntryContext recovery`
    - `-AmbitionsTodaySheet trust`
    - `-AmbitionsTodaySheet receipt`
  - These controls open existing Today states/sheets deterministically for local screenshot proof only.
  - Live runtime behavior, routing, persistence, and product IA are unchanged outside DEBUG screenshot launches.
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
  - Empty/manual Start Here state now visibly says `Source unavailable. Manual fallback stays open.`
- `docs/codex/concept-lock-registry.yml`
  - Added `AMB-524` to the allowed `today_start_here` locked-concept prefixes.
- `prompts/batches/AMB-524.md`
  - Runner header and self-heal boundary are installed.

## State / Fixture Inventory

| Required state or behavior | Evidence path |
|---|---|
| empty day | `TodayExecutionProjector.dayRailState` sets `heroStep` to nil when `input.mode == .empty`; screenshot `today-source-unavailable-manual-after-final.png`. |
| manual day | Empty Day Rail copy exposes manual fallback; screenshot `today-source-unavailable-manual-after-final.png`. |
| no schedule connected | `TodayExecutionProjector.dayRailMode` maps `todayPosture == .noTime` to `.noSchedule`. |
| now open | `DayRailRowSlot.now` and `DayRailContinuityState.make` keep Now as the active rail node. |
| recommended step | `TodayExecutionProjector.heroState` creates `.nextAction`; screenshot path also covered by AMB-533 `today-recommendation-after-final.png`. |
| active step live | `TodayEntryContext.stepSession` and `TodayFeatureService.makeStepSession` provide the live step-session path. |
| next soon | `DayRailRowState.rows` maps Time items into Now/Next/Later rows. |
| pressure soon | `TodayExecutionProjector.frictionSignal` and `dayRailMode` map tight/overloaded pressure into visible state. |
| protected time active | `TodayExecutionProjector.dayRailMode` maps tight posture to `.protected`; contract entry `protectedMustDo` keeps protected work visible. |
| missed but recoverable | `ExecutionResilienceProjector` status feeds `TodayExecutionProjector.heroState` recovery mode. |
| Still counts | `TodayActionClosureSheetState.defaultOutcomes` includes `Still Counts` with proof receipt preview. |
| waiting | `TodayActionClosureSheetState.defaultOutcomes` includes `Waiting`; `TodayExecutionProjector.sourceFreshness` maps waiting blockers to partial source. |
| blocked | `TodayActionClosureSheetState.defaultOutcomes` includes `Blocked`; `TodayExecutionProjector.sourceFreshness` maps blockers to blocked source. |
| needs recovery | `TodayActionClosureSheetState.defaultOutcomes` includes `Needs recovery`; screenshot `today-needs-recovery-after-final.png`. |
| needs review | `TodayActionClosureSheetState.defaultOutcomes` includes `Needs review`; Start Here source chips can show `Needs review`. |
| receipt available | Closure sheet exposes receipt preview and consequence; screenshot `today-receipt-available-after-final.png`. |
| source unavailable | Empty Day Rail copy and `TodayExecutionProjector.sourceFreshness` unavailable branch; screenshot `today-source-unavailable-manual-after-final.png`. |
| trust explanation open | Step Detail sheet exposes source, context, reasons, proof, and receipt; screenshot `today-trust-open-after-final.png`. |
| reflow preview | `TodayStepReplacementSheetState` and `TodayStepReplacementSheet` provide the Start Here replacement/reflow preview path. |
| source label | Start Here metadata chips and Step Detail source rows. |
| Why this? / reason | Start Here `Why this?` action opens Step Detail; screenshot `today-trust-open-after-final.png`. |
| uncertainty where relevant | `sourceFreshness`, `sourceQualityLabel`, blocked/waiting/low-confidence branches in `TodayExecutionProjector`. |
| user control / adjust path | Start Here secondary action opens `TodayStepReplacementSheet`; closure sheet offers honest outcomes. |
| receipt after meaningful action | `RepositoryBackedTodayService.recordActionClosure` writes an `ActionReceiptHistoryRecord` when repository wiring exists; Yellow allowance remains for fixture-only receipt proof outside persistence-backed flows. |
| undo/revert where available | Receipt model and closure/rejection receipt paths expose correction/review labels where available; no silent rearrangement is introduced. |
| manual fallback | Empty Day Rail and quick-capture fallback path. |

## Screenshot Evidence

All screenshots were captured from the booted `iPhone 17e` simulator at 1170 x 2532 after installing `.codex/DerivedData/Ambitions/Build/Products/Debug-iphonesimulator/Ambitions.app`.

- `artifacts/ambitions-ui-reconstruction/screenshots/today-source-unavailable-manual-after-final.png`
  - Launch: `xcrun simctl launch --terminate-running-process booted com.ambitions.ios --args -AmbitionsInitialSurface today -AmbitionsScreenshotMode YES`
- `artifacts/ambitions-ui-reconstruction/screenshots/today-trust-open-after-final.png`
  - Launch: `SIMCTL_CHILD_AMBITIONS_BOOTSTRAP_MODE=demo xcrun simctl launch --terminate-running-process booted com.ambitions.ios --args -AmbitionsInitialSurface today -AmbitionsScreenshotMode YES -AmbitionsTodayEntryContext recovery -AmbitionsTodaySheet trust`
- `artifacts/ambitions-ui-reconstruction/screenshots/today-receipt-available-after-final.png`
  - Launch: `SIMCTL_CHILD_AMBITIONS_BOOTSTRAP_MODE=demo xcrun simctl launch --terminate-running-process booted com.ambitions.ios --args -AmbitionsInitialSurface today -AmbitionsScreenshotMode YES -AmbitionsTodayEntryContext recovery -AmbitionsTodaySheet receipt`
- `artifacts/ambitions-ui-reconstruction/screenshots/today-needs-recovery-after-final.png`
  - Launch: `SIMCTL_CHILD_AMBITIONS_BOOTSTRAP_MODE=demo xcrun simctl launch --terminate-running-process booted com.ambitions.ios --args -AmbitionsInitialSurface today -AmbitionsScreenshotMode YES -AmbitionsTodayEntryContext recovery`

## Validation

- `ALLOW_DIRTY=1 scripts/ambitions-codex-train.sh AMB-524 prompts/batches/AMB-524.md`
  - Runner preflight Green; nested Phase 01 stopped before source patch due OAuth `invalid_grant`.
- `python3 scripts/ambitions-champion-coverage-check.py --batch AMB-524`
  - Green.
  - Report: `build/reports/intelligence-consolidation/champion-coverage-check.md`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-524 --prompt prompts/batches/AMB-524.md --batch-type source-changing`
  - Green.
  - Report: `build/reports/parallel-implementation-guard/AMB-524-pre.md`
- `git diff --check`
  - Passed.
- `make xcode-build-for-testing BATCH=AMB-524`
  - Passed.
- `make xcode-focused-test BATCH=AMB-524 TEST=AmbitionsTests/TodayRealityMeridianExperienceElevationTests`
  - Passed.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-524 --prompt prompts/batches/AMB-524.md --changed-from b7628de118f9d3df8ecc63413309b8879fe31f65 --batch-type source-changing`
  - Green.
  - Report: `build/reports/parallel-implementation-guard/AMB-524-post.md`
- `xcrun simctl install booted .codex/DerivedData/Ambitions/Build/Products/Debug-iphonesimulator/Ambitions.app`
  - Passed.
- `sips -g pixelWidth -g pixelHeight` on all four AMB-524 screenshots
  - All screenshots are 1170 x 2532.

## Proof Boundaries

- Current evidence proves the scoped source patch, local build/test pass, guard pass, and simulator screenshots for AMB-524.
- This does not prove human visual approval, full VoiceOver traversal, Dynamic Type acceptance, Reduce Motion device QA, performance, physical-device behavior, release readiness, TestFlight readiness, App Store readiness, privacy/legal approval, or CI proof.

## Rollback

Revert the AMB-524 commit, or remove the source/report/screenshot/prompt changes listed above and rebuild from `b7628de118f9d3df8ecc63413309b8879fe31f65`.
