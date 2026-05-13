# MRI14 Global Correction Fold Report

Status: Accepted Yellow; Phase 02 patch installed, Phase 03 review found no MRI14 source-scope violation, and Phase 04 repaired the observed `missingReceiptBehavior` bridge compile blocker. Focused simulator testing still does not reach MRI14 assertions because unrelated test-target compile debt stops the build.
Batch: MRI14-GLOBAL-CORRECTION-FOLD
Operating system: Inspectable Intelligence Engine
Product loop: Capture-to-meaning
Date: 2026-05-13

## Source Truth Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `.codex/reports/current-run-state.md`
- `docs/codex/MOAT_RUNTIME_INTEGRATION_MASTER_PLAN.md`
- `docs/codex/MOAT_RUNTIME_LOOP_MATRIX.md`
- `docs/codex/MOAT_RUNTIME_ACCEPTANCE_CRITERIA.md`
- `docs/codex/MOAT_RUNTIME_GOLDEN_SCENARIOS.md`
- `docs/codex/MOAT_RUNTIME_BATCH_OVERLAY.json`

## Files Changed

- `Native/Ambitions/Domain/CorrectionFoldModels.swift`
- `Native/AmbitionsTests/Domain/CorrectionFoldModelsTests.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamTodayBridgeModels.swift`
- `docs/audits/mri14-global-correction-fold-report.md`

## Loop Behavior Added

- Added a domain-only correction fold value model for five targets: capture route, source claim, recommendation, time-fit decision, and learning input.
- Added deterministic typed correction values, local-only receipts, no-silent-mutation behavior, and derived effects for route correction, source review, recommendation suppression, time-fit review, and learning reset/ignore.
- Added scenario tests for wrong capture route, stale/wrong source claim, rejected recommendation, wrong time-fit decision, and reset/ignored learning input.

## Deferred

- No UI exposure in Capture, Today, Time, or You.
- No persistence or repository storage.
- No service/runtime wiring.
- No cross-surface golden scenario proof.
- No accessibility, performance, privacy/legal, device, TestFlight, App Store, or release proof.

## EFC Applicability

EFC applicability: invoked. This batch touches local intelligence, correction behavior, source/freshness interpretation, user data semantics, and receipt posture. The Phase 02 patch stays value-model and focused-test only; it does not authorize release/platform claims or broader runtime wiring.

## Validation Commands And Exit Codes

| Command | Exit | Result |
|---|---:|---|
| `git diff --check` | 0 | Passed. |
| `xcodegen generate` | 0 | Passed; generated `Ambitions.xcodeproj` without leaving tracked project diffs. |
| `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/CorrectionFoldModelsTests` | 65 | Blocked before MRI14 tests ran by existing app-target compile errors in `Native/Ambitions/Features/Goals/GoalsOverviewProjector.swift`; `CorrectionFoldModels.swift` compiled before the blocker. |
| `python3 scripts/ambitions-state-advance-validate.py || true` | 0 | Passed: state advancement coherent; current `SA16 Source Container Model`, next `SA17 URL Source Importer`. |
| `python3 scripts/ambitions-unsupported-claim-scan.py Native/Ambitions/Domain/CorrectionFoldModels.swift Native/AmbitionsTests/Domain/CorrectionFoldModelsTests.swift docs/audits/mri14-global-correction-fold-report.md 2>/dev/null || true` | 0 | Passed: unsupported completion/readiness claim scan passed. |

Phase 03 validation rerun:

| Command | Exit | Result |
|---|---:|---|
| `git diff --check` | 0 | Passed; note that the MRI14 files are untracked, so this command has no tracked diff payload until staging or intent-to-add. |
| `xcodegen generate` | 0 | Passed; generated `Ambitions.xcodeproj` and included `CorrectionFoldModels.swift` / `CorrectionFoldModelsTests.swift` in the generated project. |
| `xcrun swiftc -typecheck Native/Ambitions/Domain/CorrectionFoldModels.swift` | 0 | Passed; domain value model typechecks in isolation. |
| `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/CorrectionFoldModelsTests` | not run | Direct shell execution was rejected before command execution by the outer policy wrapper: approval required by policy while AskForApproval is Never. |
| `XcodeBuildMCP test_sim -only-testing:AmbitionsTests/CorrectionFoldModelsTests` | failed | Blocked before MRI14 tests ran by existing app-target compile debt in `Native/Ambitions/Domain/AmbitionsOSLivingDreamTodayBridgeModels.swift`: non-exhaustive switch over `AmbitionsOSRecommendationStartHereIssue` missing `missingReceiptBehavior`. |
| `python3 scripts/ambitions-state-advance-validate.py || true` | 0 | Passed: state advancement coherent; current `SA16 Source Container Model`, next `SA17 URL Source Importer`. |
| `python3 scripts/ambitions-unsupported-claim-scan.py Native/Ambitions/Domain/CorrectionFoldModels.swift Native/AmbitionsTests/Domain/CorrectionFoldModelsTests.swift docs/audits/mri14-global-correction-fold-report.md 2>/dev/null || true` | 0 | Passed: unsupported completion/readiness claim scan passed. |

Focused test blocker detail: Phase 02 saw the Xcode test host compile stop on `GoalsOverviewProjector.swift` access-control/type-inference errors outside the MRI14 allowed files. Phase 03 direct `xcodebuild` was rejected before execution by the outer policy wrapper, and the XcodeBuildMCP simulator lane stopped on a different existing app-target compile error in `AmbitionsOSLivingDreamTodayBridgeModels.swift`. Both blockers are outside the MRI14 Phase 02 allowed files; the MRI14 domain value model typechecked in isolation, but the scenario tests did not execute.

Phase 04 repair validation rerun:

| Command | Exit | Result |
|---|---:|---|
| `git diff --check` | 0 | Passed for tracked diffs. |
| `git diff --check --no-index /dev/null Native/Ambitions/Domain/CorrectionFoldModels.swift; true` | 0 | Passed whitespace check for untracked MRI14 domain model. |
| `git diff --check --no-index /dev/null Native/AmbitionsTests/Domain/CorrectionFoldModelsTests.swift; true` | 0 | Passed whitespace check for untracked MRI14 tests. |
| `git diff --check --no-index /dev/null docs/audits/mri14-global-correction-fold-report.md; true` | 0 | Passed whitespace check for untracked MRI14 report. |
| `xcodegen generate` | 0 | Passed; regenerated `Ambitions.xcodeproj`. |
| `xcrun swiftc -typecheck Native/Ambitions/Domain/CorrectionFoldModels.swift` | 0 | Passed; MRI14 domain value model typechecks in isolation. |
| `xcrun swiftc -typecheck Native/Ambitions/Domain/AmbitionsOSLivingDreamTodayBridgeModels.swift` | 1 | Not a valid isolated proof lane for this file because it depends on sibling domain models; retained here only as diagnostic context. |
| `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/CorrectionFoldModelsTests` | not run | Direct shell execution was rejected before command execution by the outer policy wrapper: approval required by policy while AskForApproval is Never. |
| `XcodeBuildMCP test_sim -only-testing:AmbitionsTests/CorrectionFoldModelsTests` | failed | Phase 04 repaired the earlier non-exhaustive switch blocker, but the focused lane stopped before MRI14 tests ran on unrelated test-target compile debt in `PolicyGuardedCommandExecutorTests.swift`, `PortableRestoreRollbackTests.swift`, and `PreMigrationBackupTests.swift`. |
| `python3 scripts/ambitions-state-advance-validate.py || true` | 0 | Passed: state advancement coherent; current `SA16 Source Container Model`, next `SA17 URL Source Importer`. |
| `python3 scripts/ambitions-unsupported-claim-scan.py Native/Ambitions/Domain/CorrectionFoldModels.swift Native/AmbitionsTests/Domain/CorrectionFoldModelsTests.swift Native/Ambitions/Domain/AmbitionsOSLivingDreamTodayBridgeModels.swift docs/audits/mri14-global-correction-fold-report.md 2>/dev/null || true` | 0 | Passed: unsupported completion/readiness claim scan passed. |

Phase 04 repair detail: `AmbitionsOSLivingDreamTodayBridgeModels.swift` now maps `AmbitionsOSRecommendationStartHereIssue.missingReceiptBehavior` to `AmbitionsOSLivingDreamTodayBridgeIssue.proofTrustReviewRequired`, preserving the existing bridge issue taxonomy and avoiding a wider architecture change. MRI14 scenario tests remain source-present but unexecuted.

## Claims Not Made

- release readiness
- TestFlight readiness
- App Store readiness
- device proof
- public accessibility conformance
- performance validation
- privacy/legal approval
- visual runtime completion
- global train completion

## Rollback Notes

Rollback is limited to this batch's files:

```bash
git restore -- Native/Ambitions/Domain/AmbitionsOSLivingDreamTodayBridgeModels.swift
rm -f Native/Ambitions/Domain/CorrectionFoldModels.swift Native/AmbitionsTests/Domain/CorrectionFoldModelsTests.swift docs/audits/mri14-global-correction-fold-report.md
```

## Next Handoff

Next safe handoff is a separate owner-scoped repair for the remaining unrelated test-target compile debt, currently observed in `PolicyGuardedCommandExecutorTests.swift`, `PortableRestoreRollbackTests.swift`, and `PreMigrationBackupTests.swift`, before rerunning the focused MRI14 Xcode test.
