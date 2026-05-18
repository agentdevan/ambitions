# PFC36 Batch Closeout Report

## Status
Green

## Scope
Performance and observability reconciliation only. The batch kept the internal `planLoad` seam in source but reworded its surfaced copy to `Time`-canonical language and added tests that block IA drift and release overclaims.

## Phase 03 Review Repair
- REPAIR REQUIRED and completed in Phase 03.
- Finding: the first Phase 02 patch still left `Today, Goals, Capture, Plan, You` in the performance report's tab-switching evidence, which read as stale top-level IA language.
- Repair: changed that evidence to `Today, Goals, Capture, Time, You`, clarified the startup/calendar note as Time-owned through the internal Plan compatibility seam, and added a regression test blocking Plan-as-top-level evidence.

## Phase 04 Repair Pass 1
- No additional source repair was required in Phase 04.
- The repaired slice remained inside the four-file PFC36 boundary.
- Phase 04 reran validation and confirmed the focused result bundles passed; the MCP wrapper still timed out at 120s while underlying `xcodebuild` completed and wrote valid `.xcresult` bundles.

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
- `docs/native-build-and-release.md`
- `docs/status/performance-budgets.md`
- `docs/status/release-evidence-packet.md`
- `Native/Ambitions/Support/ReleasePerformanceResponsivenessReport.swift`
- `Native/AmbitionsTests/App/ReleasePerformanceResponsivenessReportTests.swift`

## Files Changed
- `Native/Ambitions/Support/ReleasePerformanceResponsivenessReport.swift`
- `Native/AmbitionsTests/App/ReleasePerformanceResponsivenessReportTests.swift`
- `docs/status/release-evidence-packet.md`
- `docs/audits/pfc36-batch-closeout-report.md`

## Validation

### Verified Proof
- `git status --short` -> `0` with only the four edited batch files and the pre-existing untracked `.codex/state/global-train.lock`
- `git diff --check` -> `0`
- `make prompt-audit` -> `0`
  - Output: `YELLOW: prompt-like support/eval/template files classified; no active runnable prompt missing metadata`
- `make batch-self-check` -> `0`
  - Output: `GREEN: runner self-check passed`
- `xcodegen generate` -> `0`
- `xcodebuildmcp test_sim` focused on `AmbitionsTests/ReleasePerformanceResponsivenessReportTests` -> wrapper timed out at `120s`; underlying result bundle passed
  - Result bundle: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/result-bundles/test_sim_2026-05-18T07-08-00-828Z_pid38566_98ab36cb.xcresult`
  - Summary: `Passed`, `6` tests, `0` recorded failures, simulator `iPhone 17` on `iOS Simulator 26.3.1`
- `xcodebuildmcp test_sim` focused on `AmbitionsTests/AmbitionsOSPerformanceEnergyModelsTests` -> wrapper timed out at `120s`; underlying result bundle passed
  - Result bundle: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/result-bundles/test_sim_2026-05-18T07-13-28-056Z_pid38566_c9620e57.xcresult`
  - Summary: `Passed`, `10` total tests recorded in the bundle, `0` recorded failures, simulator `iPhone 17` on `iOS Simulator 26.3.1`
- `bash scripts/codex-forbidden-claim-scan.sh Native/Ambitions/Support/ReleasePerformanceResponsivenessReport.swift Native/AmbitionsTests/App/ReleasePerformanceResponsivenessReportTests.swift docs/status/release-evidence-packet.md docs/audits/pfc36-batch-closeout-report.md 2>/dev/null || true` -> `0`
  - Final scan output: context-only `top-level Plan drift` guard in source; `codex-forbidden-claim-scan: no blocking hits`

### Blocked/Timed Out Transport
- The direct `xcodebuildmcp/test_sim` tool call timed out at the 120s wrapper ceiling for both Phase 04 slices, but the underlying `xcodebuild` processes completed and wrote passing `.xcresult` bundles. The batch records the bundle-backed result, not the wrapper timeout, as the actual validation outcome.
- A direct shell `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/AmbitionsOSPerformanceEnergyModelsTests test CODE_SIGNING_ALLOWED=NO` attempt was blocked before shell execution by the outer command policy: `approval required by policy, but AskForApproval is set to Never`.

## EFC Applicability
- Invoked.
- No additional EFC overlay action was needed for this bounded reconciliation beyond keeping the batch within the accepted proof boundary.

## Accepted Yellow Rationale
- Not used for the final status. The transport issues were the MCP wrapper timeout and direct-shell policy block; the underlying Xcode result bundles recovered valid passing test evidence.

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
- Restore only the two edited source files and the two docs files if a later review finds the Time wording or proof boundaries incorrect.
- Do not remove `.codex/state/global-train.lock`; it predates this batch.

## Next Handoff
- PFC37
