# AESP-012 Today / Reality Meridian Evidence

- Batch: `AESP-012`
- Branch: `main`
- Base commit: `d3402a321001b5964ea9ef7719d5b49380be7a83`
- Evidence timestamp UTC: `2026-06-02T02:22:22Z`
- Worktree status: dirty before commit; intended AESP-012 slice validated green

## Files Changed

- `Native/Ambitions/Features/Today/DayRailProjection.swift`
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `Native/Ambitions/Features/Today/TodayExecutionProjector.swift`
- `Native/Ambitions/Features/Today/TodayRealityMeridianTopology.swift`
- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Native/Ambitions/Features/Today/TodayStartHereSurface.swift`
- `Native/Ambitions/Features/You/YouFeatureService.swift`
- `Native/Ambitions/Domain/ActionClosureReceiptModels.swift`
- `Native/Ambitions/Domain/FutureProofContextCandidate.swift`
- `Native/Ambitions/Domain/GoalEngine/GoalEngineContracts.swift`
- `Native/Ambitions/Domain/GoalRelevanceScan.swift`
- `Native/Ambitions/Domain/LifeKnowledgeOperationModels.swift`
- `Native/Ambitions/Domain/PlanInsertionCandidate.swift`
- `Native/Ambitions/Domain/ProjectStepOperationModels.swift`
- `Native/Ambitions/Domain/ProofResourceGraphModels.swift`
- `Native/Ambitions/Domain/ReminderNaturalLanguageCaptureParser.swift`
- `Native/Ambitions/Persistence/StorageSchemaVersionLedger.swift`
- `Native/Ambitions/Runtime/ReplayableDecisionTraceModels.swift`
- `Native/Ambitions/Services/AmbitionsCommandExecutor.swift`
- `Native/Ambitions/Services/GoalUnderstandingService.swift`
- `Native/Ambitions/PreviewSupport/PreviewTodayScenarios.swift`
- `Native/AmbitionsTests/App/EventKitIntegrationServiceTests.swift`
- `Native/AmbitionsTests/App/ReleasePrivacyProtectedStorageReportTests.swift`
- `Native/AmbitionsTests/Domain/GoalRelevanceScanTests.swift`
- `Native/AmbitionsTests/Domain/IOS26NotionP0ContractHarnessTests.swift`
- `Native/AmbitionsTests/Domain/LifeKnowledgeOperationModelsTests.swift`
- `Native/AmbitionsTests/Domain/ProjectStepOperationModelsTests.swift`
- `Native/AmbitionsTests/Runtime/AmbitionsRuntimeBoundaryTests.swift`
- `Native/AmbitionsTests/Runtime/CaptureRuntimeGauntletTests.swift`
- `Native/AmbitionsTests/Services/GoalUnderstandingServiceTests.swift`
- `Native/AmbitionsTests/Services/OneStepGoalProjectorTests.swift`
- `Native/AmbitionsTests/Today/TodayRealityMeridianExperienceElevationTests.swift`
- `Native/AmbitionsTests/You/YouFeatureServiceTests.swift`
- `docs/codex/existing-code-champion-coverage.yml`
- `build/reports/intelligence-consolidation/champion-coverage-check.md`
- `build/reports/intelligence-consolidation/champion-coverage-check.json`
- `build/reports/capture-runtime-bridge/capture-runtime-gauntlet.md`
- `build/reports/capture-runtime-bridge/capture-runtime-gauntlet-output.json`
- `prompts/batches/AESP-012.md`
- `build/reports/aesp/AESP-012/today-reality-meridian-evidence.md`

## Why This Changed

- Today now exposes the Reality Meridian / Start Here layer with explicit freshness and correction paths instead of leaving those states implicit.
- The projector now differentiates source freshness for stale, blocked/waiting, recovery, low-confidence, private, unavailable, and empty/manual-fallback cases.
- Preview fixtures now cover the approved state set so tests can verify the visible and accessibility-facing copy.
- Phase 03 added the focused Today test to the champion coverage map after the first review rerun found the new test file unclassified.
- Phase 03 repaired the focused test expectations after a real scheme-qualified run exposed stale assertions.
- Repair cycle cleared stale broad-suite contracts across local-only sync copy, capture future-proof classification, LifeKnowledge search proof visibility, Notion resource relationships, ActionReceipt freshness review, storage schema ledger coverage, schedule write receipts, and deterministic replay labels.

## Validation

### Passed

- `python3 scripts/ambitions-champion-coverage-check.py --batch AESP-012`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AESP-012 --prompt prompts/batches/AESP-012.md --batch-type source-changing --allow-yellow`
- `xcodegen generate`
- `make xcode-build-for-testing BATCH=AESP-012`
- `make xcode-focused-test BATCH=AESP-012 TEST=AmbitionsTests/TodayRealityMeridianExperienceElevationTests`
- `make xcode-focused-test BATCH=AESP-012 TEST=AmbitionsTests/CaptureRuntimeGauntletTests`
- `make xcode-focused-test BATCH=AESP-012 TEST=AmbitionsTests/IOS26NotionP0ContractHarnessTests`
- `make xcode-focused-test BATCH=AESP-012 TEST=AmbitionsTests/YouFeatureServiceTests`
- `make xcode-focused-test BATCH=AESP-012 TEST=AmbitionsTests`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AESP-012 --prompt prompts/batches/AESP-012.md --changed-from d3402a321001b5964ea9ef7719d5b49380be7a83 --batch-type source-changing --allow-yellow`

Current Phase 03 wrapper evidence:

- Build-for-testing summary: `.codex/xcode-summaries/AESP-012/20260602T000655Z/validate-summary.json` (`status=passed`, `exit_code=0`, `duration_seconds=59`)
- Build-for-testing log root: `.codex/xcode-logs/AESP-012/20260602T000655Z`
- Build-for-testing result root: `.codex/xcode-results/AESP-012/20260602T000655Z`
- Focused test summary: `.codex/xcode-summaries/AESP-012/20260602T000759Z/validate-summary.json` (`status=passed`, `exit_code=0`, `duration_seconds=46`, `test=AmbitionsTests/TodayRealityMeridianExperienceElevationTests`)
- Focused test log: `.codex/xcode-logs/AESP-012/20260602T000802Z/focused-test.log` (`Executed 2 tests, with 0 failures`)
- Focused test result root: `.codex/xcode-results/AESP-012/20260602T000759Z`

Current Phase 04 repair-pass wrapper evidence:

- Build-for-testing summary: `.codex/xcode-summaries/AESP-012/20260602T001720Z/validate-summary.json` (`status=passed`, `exit_code=0`, `duration_seconds=88`)
- Build-for-testing log root: `.codex/xcode-logs/AESP-012/20260602T001720Z`
- Build-for-testing result root: `.codex/xcode-results/AESP-012/20260602T001720Z`
- Focused test summary: `.codex/xcode-summaries/AESP-012/20260602T001854Z/validate-summary.json` (`status=passed`, `exit_code=0`, `duration_seconds=50`, `test=AmbitionsTests/TodayRealityMeridianExperienceElevationTests`)
- Focused test log: `.codex/xcode-logs/AESP-012/20260602T001857Z/focused-test.log` (`Executed 2 tests, with 0 failures`)
- Focused test result root: `.codex/xcode-results/AESP-012/20260602T001854Z`

Current final repair-pass wrapper evidence:

- Build-for-testing summary: `.codex/xcode-summaries/AESP-012/20260602T022004Z/build-for-testing-summary.json` (`status=passed`, `timestamp_utc=20260602T022004Z`)
- Build-for-testing log: `.codex/xcode-logs/AESP-012/20260602T022004Z/build-for-testing.log`
- Build-for-testing result bundle: `.codex/xcode-results/AESP-012/20260602T022004Z/build-for-testing.xcresult`
- Broad `AmbitionsTests` summary: `.codex/xcode-summaries/AESP-012/20260602T022222Z/focused-test-summary.json` (`status=passed`, `failure_category=passed`, `test=AmbitionsTests`)
- Broad `AmbitionsTests` log: `.codex/xcode-logs/AESP-012/20260602T022222Z/focused-test.log`
- Broad `AmbitionsTests` result bundle: `.codex/xcode-results/AESP-012/20260602T022222Z/focused-test.xcresult`
- Capture gauntlet report: `build/reports/capture-runtime-bridge/capture-runtime-gauntlet.md` (`Failing Scenarios: None`)

### Failed / Yellow

- None in the final AESP-012 build-for-testing and broad `AmbitionsTests` validation lanes.

### Not Run Separately

- Full screenshot proof
- Manual device proof
- External accessibility audit
- Performance profiling

## Accessibility And Motion

- Dynamic Type is handled in the Today surfaces through existing stacked/conditional layouts and the new freshness/correction rows.
- Reduce Motion remains supported by the existing Today motion presets; the new patch does not add motion-dependent behavior.
- VoiceOver paths now include the new freshness and correction evidence lines through the existing receipt/accessibility summaries.

## Proof Boundaries

- This patch proves source-backed Today elevation through repository state, wrapper build validation, and focused tests.
- It does not claim device-verified visual polish, screenshot parity, or independent accessibility certification.
- It does not claim release readiness.

## Known Yellow Items

- No separate screenshot or device session was run for this batch.
- Screenshot proof, manual accessibility QA, and device proof were not run in Phase 03 or Phase 04.

## Rollback Notes

- Restore the changed Today source and test files if needed:
  - `Native/Ambitions/Features/Today/DayRailProjection.swift`
  - `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
  - `Native/Ambitions/Features/Today/TodayExecutionProjector.swift`
  - `Native/Ambitions/Features/Today/TodayRealityMeridianTopology.swift`
  - `Native/Ambitions/Features/Today/TodayStartHereSurface.swift`
  - `Native/Ambitions/PreviewSupport/PreviewTodayScenarios.swift`
  - `Native/AmbitionsTests/Today/TodayRealityMeridianExperienceElevationTests.swift`
  - `docs/codex/existing-code-champion-coverage.yml`
  - `build/reports/aesp/AESP-012/today-reality-meridian-evidence.md`

## Non-Claims

- No claim of screenshot proof.
- No claim of manual device proof.
- No claim of full screenshot or manual accessibility QA.
- No claim of release readiness.
