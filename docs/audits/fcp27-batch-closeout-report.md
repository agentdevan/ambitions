# FCP27 Batch Closeout Report

## Status
Completed (Green: app-target compile debt repaired locally)

## Scope Summary
- FCP27 closeout plus focused app-target compile-debt repair.
- Repaired stale Plan-to-Time routing compatibility, Today/Time/Capture command-model drift, Source Atlas UI access debt, Living Plan public/internal access debt, one SwiftUI type-check timeout in design-system primitives, and the remaining non-blocking app-target warnings.
- No signing, entitlement, hosted CI, release workflow, or product strategy changes were made.

## Source Truth Inspected
- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `.codex/state/active-batch.yml`
- `.codex/reports/current-batch-train-state.md`
- `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json`
- `docs/native-build-and-release.md`
- `prompts/batches/FCP27.md`
- `docs/audits/fcp27-batch-closeout-report.md`

## Validation Commands and Exit Codes

### Verified
- `git status --short --branch --untracked-files=all`: exit `0`; working tree contains the focused compile-debt repair files plus this report
- `git diff --check`: exit `0`
- `make prompt-audit`: exit `0`
  - Result: `YELLOW: prompt-like support/eval/template files classified; no active runnable prompt missing metadata`
  - Active runnable prompts audited: `322`
- `make batch-self-check`: exit `0`
  - Result: `GREEN: runner self-check passed`
- `bash scripts/codex-forbidden-claim-scan.sh docs/audits/fcp27-batch-closeout-report.md 2>/dev/null || true`: exit `0`
  - Result: `codex-forbidden-claim-scan: no blocking hits`
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -version`: exit `0`
  - Result: Xcode `26.3`, build `17C529`
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -resolvePackageDependencies`: exit `0`
  - Result: package graph resolved; source package `AmbitionsDesignSystem`
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer ./scripts/build-local.sh`: exit `65`
  - Result: app-target simulator build failed
  - Destination: `platform=iOS Simulator,name=iPhone 17`
  - Log: `output/logs/build-local-20260517-084148.log`
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer ./scripts/build-local.sh`: exit `0`
  - Result: app-target simulator build succeeded after compile-debt repair
  - Destination: `platform=iOS Simulator,name=iPhone 17`
  - Log: `output/logs/build-local-20260517-092454.log`
  - Evidence: `** BUILD SUCCEEDED **`
- `rg -n "warning:|error:" output/logs/build-local-20260517-092454.log`: exit `0`
  - Result: no `error:` hits; two non-blocking warnings remain in the final log.
  - Remaining warnings:
    - `Native/Ambitions/Features/Goals/GoalComponents.swift:469`: non-Sendable function conversion warning
    - `Native/Ambitions/Domain/SourceAtlasDocumentTypeClassifierModels.swift:208`: unreachable-code warning
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer ./scripts/build-local.sh`: exit `0`
  - Result: app-target simulator build succeeded after non-blocking warning repair
  - Destination: `platform=iOS Simulator,name=iPhone 17`
  - Log: `output/logs/build-local-20260517-093215.log`
  - Evidence: `** BUILD SUCCEEDED **`
- `rg -n "BUILD SUCCEEDED|warning:|error:" output/logs/build-local-20260517-093215.log`: exit `0`
  - Result: `** BUILD SUCCEEDED **`; no `warning:` or `error:` hits in the final log

### Blocked in Nested Runner
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -resolvePackageDependencies` during nested runner execution
  - Blocked by the outer policy wrapper before shell execution:
    `approval required by policy, but AskForApproval is set to Never`
- `focused xcodebuild` UI/accessibility proof
  - Not performed in nested runner because app-target compile debt blocked that proof path.

## EFC / FVQ Applicability
- EFC proof gate: invoked for source-touching repair; accepted Green for compile restoration only.
- FET/FVQ visual proof gate: not applicable to this compile-debt repair because no visual QA, UI behavior validation, screenshot proof, or accessibility proof was performed.

## Verified Conclusions
- The batch prompt, current truth files, and current batch mirrors were inspected before closeout.
- The runner self-check is green.
- The prompt audit is current and shows no active runnable prompt missing metadata.
- The working tree was clean at the start of this phase.
- The parent macOS session resolved packages successfully with Xcode `26.3` build `17C529`.
- The repaired app target now builds locally through `./scripts/build-local.sh`.
- The remaining non-blocking warning pair from `output/logs/build-local-20260517-092454.log` was repaired and no warning/error hits remain in `output/logs/build-local-20260517-093215.log`.

## Failed or Blocked Proof
- Package resolution proof succeeded in the parent macOS session.
- The first simulator build proof failed with app-target compile debt.
- Initial compile-debt clusters from `output/logs/build-local-20260517-084148.log`:
  - AOS tail-gate public APIs return internal `ActionReceipt` types, for example `Native/Ambitions/Domain/AmbitionsOSCloseoutTailGate.swift`.
  - `InsightsRouteTarget` is missing while still referenced by `AppExternalRoute`, `ShellCommandDestination`, `InsightsModels`, `PreviewFixtures`, and `InsightsScreen`.
  - Plan-to-Time compatibility drift remains in preview and runtime seams, including `.openPlan`, `.plan`, `TodayPlanLayerState`, and `TodayPlanLayerItemState` references.
  - Living Plan public APIs expose internal app types in `Native/Ambitions/Domain/Planning/*`.
  - `SourceAtlasUIPrimitives` public initializers expose internal Source Atlas state types.
- Those clusters were repaired in the current working tree. The final local build log is `output/logs/build-local-20260517-093215.log`.

## Skipped Proof
- UI/accessibility-focused `xcodebuild` proof
- device proof
- signed archive proof
- TestFlight/App Store proof

## Claims Not Made
- App release readiness
- TestFlight readiness
- App Store readiness
- Signed archive readiness
- Physical-device validation
- Public accessibility conformance
- VoiceOver verification
- Dynamic Type verification
- Reduce Motion verification
- Performance validation
- Privacy/legal approval
- Hosted CI proof
- Production readiness
- Global queue completion

## Rollback Notes
- The repair touched app source, shared UI source, and this audit report. Use path-limited review before staging or rollback.

## Next Handoff
- Review and commit the compile-debt repair slice before advancing to `FCP28`.
