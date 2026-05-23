# Anti-Bucket Factor Ledger Proof

- Status: Yellow
- Batch: IOS26-T04A-B06
- Branch: `main`
- Commit: `8d22be5faf7da7fddd281f194ab16b475677fa9e`

## Commands run

- `xcodegen generate`
- `scripts/build-local.sh`
- `make xcode-focused-test BATCH=IOS26-T04A-B06 TEST=AmbitionsTests/PersonalizationFactorLedgerTests`
- `make xcode-focused-test BATCH=IOS26-T04A-B06 TEST=AmbitionsTests`
- `make xcode-focused-test BATCH=IOS26-T04A-B06 TEST='AmbitionsUITests/AmbitionsUITests/testYouLifeContextLedgerInspectionShowsRuntimeFactorsAndReplayReceipts'`
- `make xcode-focused-test BATCH=IOS26-T04A-B06 TEST=AmbitionsUITests`
- `git diff --check`

Latest Phase 04 rerun evidence:

- `scripts/build-local.sh`: `output/logs/build-local-20260523-022542.log`
- `AmbitionsTests/PersonalizationFactorLedgerTests`: `.codex/xcode-summaries/IOS26-T04A-B06/20260523T062756Z/focused-test-summary.json`
- `AmbitionsTests`: `.codex/xcode-summaries/IOS26-T04A-B06/20260523T063012Z/focused-test-summary.json`
- Focused ledger UI test: `.codex/xcode-summaries/IOS26-T04A-B06/20260523T063323Z/focused-test-summary.json`
- Broad `AmbitionsUITests`: `.codex/xcode-summaries/IOS26-T04A-B06/20260523T063539Z/focused-test-summary.json`

## Commands not run

- `git push`
- Raw `xcodebuild` direct invocation
- Any broad UI repair beyond the focused ledger inspection route

## Files changed

- `Native/Ambitions/Domain/ActionClosureReceiptModels.swift`
- `Native/Ambitions/Domain/PersonalizationFactorLedgerModels.swift`
- `Native/Ambitions/Domain/YouModels.swift`
- `Native/Ambitions/Features/You/YouFeatureService.swift`
- `Native/Ambitions/Features/You/YouScreen.swift`
- `Native/Ambitions/Runtime/PersonalizationFactorLedgerBuilder.swift`
- `Native/Ambitions/Runtime/PrivateLifeRuntimeKernelContracts.swift`
- `Native/Ambitions/Runtime/ReplayableDecisionTraceModels.swift`
- `Native/AmbitionsTests/Domain/ActionClosureReceiptModelsTests.swift`
- `Native/AmbitionsTests/Runtime/PersonalizationFactorLedgerTests.swift`
- `Native/AmbitionsTests/You/YouFeatureServiceTests.swift`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`

Unrelated dirty files preserved untouched:

- `docs/proof/amb-fe-be/moat-scenario-proof-98/same-intent-context-a.json`
- `docs/proof/amb-fe-be/moat-scenario-proof-98/same-intent-context-b.json`

## Ledger object proof

- `PersonalizationFactorLedger` exists as a first-class value model.
- Required fields are present: `recommendationID`, `generatedAt`, `runtimeVersion`, `userContextVersion`, `goalID`, `selectedCandidateID`, `rejectedCandidateIDs`, `factors`, `confidenceBand`, `missingContextQuestions`, `sensitiveFactorUsage`, `explanationProjection`, `replayProjection`.
- Runtime now threads the ledger through `PrivateLifeRuntimeKernelDecisionRecord`, `PrivateLifeRuntimeKernelDecisionOutput`, and `ReplayableDecisionTrace`.
- Builder output is deterministic for fixed input and fixed generated time.

## Factor type proof

- Typed factor enums and projections exist in `PersonalizationFactorLedgerModels.swift`.
- The builder emits multi-factor runtime rows from Life Context, recommendation trace, candidate, source, receipt, and replay facts.
- Deadline pressure is now modeled explicitly when the visible goal/context mentions it.
- Demographic-only selection is not present in the ledger path.

## Receipt proof

- Added changed-fact receipt kinds:
  - `personalizationFactorUsed`
  - `personalizationFactorDisabled`
  - `personalizationFactorExpired`
  - `recommendationChangedDueToContext`
  - `staleContextReducedConfidence`
  - `replayDifferenceDetected`
  - `fallbackReasoningActivated`
  - `demographicFactorRejected`
  - `candidateRejectedByConstraint`
- `ActionClosureReceiptModelsTests` now round-trips the expanded kind set through encoding, decoding, and search projection.

## You inspection/control proof

- `You -> Life Context` now exposes:
  - `Runtime Factors`
  - `Recommendation Inputs`
  - `Why This Changes Plans`
  - `Rejected Factors`
  - `Sensitive Context Usage`
  - `Context Confidence`
  - `Needs Review`
  - `Disabled Factors`
  - `Replay & Receipts`
- `YouLifeContextFactRow` now carries activity, last-affected, and runtime-permission labels for accessibility and inspection.
- The focused UI route test covers the ledger inspection surface.

## Test Group Results

- Group A: Pass
- Group B: Pass
- Group C: Pass
- Group D: Pass
- Group E: Pass
- Group F: Pass

## Validation summary

- `xcodegen generate`: Pass
- `scripts/build-local.sh`: Pass, latest log `output/logs/build-local-20260523-022542.log`
- `make xcode-focused-test BATCH=IOS26-T04A-B06 TEST=AmbitionsTests/PersonalizationFactorLedgerTests`: Pass
- `make xcode-focused-test BATCH=IOS26-T04A-B06 TEST=AmbitionsTests`: Pass
- `make xcode-focused-test BATCH=IOS26-T04A-B06 TEST='AmbitionsUITests/AmbitionsUITests/testYouLifeContextLedgerInspectionShowsRuntimeFactorsAndReplayReceipts'`: Pass
- `make xcode-focused-test BATCH=IOS26-T04A-B06 TEST=AmbitionsUITests`: Failed with 6 broad UI-suite failures outside the scoped ledger route:
  - `testCapturePromotionOpensComposerWithSeededText`
  - `testDemoGoalsAtlasLoadsCoreModules`
  - `testDemoTimeWorkspaceShowsBatch49CoreModules`
  - `testPreviewBootstrapExposesCanonicalFiveTabShellAndSecondarySurfaces`
  - `testTodayCanHandOffToGoalDetail`
  - `testTodayStartNowCanOpenBoundedStepSession`
- `git diff --check`: Pass

## Accessibility status

- Focused ledger inspection route is exercised by UI test.
- Full public VoiceOver, Dynamic Type, Reduce Motion, and contrast verification is not claimed here.

## Privacy/local-first status

- Local-first / on-device-first posture preserved.
- No required cloud AI, hosted personal-data backend, analytics SDK, or tracking SDK introduced.
- Sensitive factors remain permission-gated and can fall back to non-sensitive reasoning; recovery and safety factors are blocked from runtime use until explicit permission exists.

## Claims allowed

- The ledger path exists.
- The ledger is inspectable in You.
- The focused runtime tests and focused UI ledger inspection test passed.
- The receipt kinds round-trip through projection.

## Claims forbidden

- Public accessibility verification.
- Release readiness.
- Device-level proof.
- Privacy/legal signoff.
- Performance proof.
- App Store / TestFlight / CI proof.

## Rollback notes

- Path-limited rollback is still valid for only the files listed in this batch.
- Unrelated dirty proof JSON files were left untouched.

## Yellow / Red items

- No batch Red items remain after the sensitive-factor repair.
- Residual Yellow: full public accessibility verification was not run and is not claimed.
- Residual Yellow: the broad `AmbitionsUITests` wrapper lane failed in unrelated Capture, Goals, Time, Today, and shell tests; the focused ledger UI route passed.

## Next eligible batch

- Follow up on the inherited broad UI-suite failures before using this batch as full UI-suite Green evidence.
