# MRI16 Inspectable Intelligence Golden Tests Report

Status: Accepted Yellow
Operating system: Inspectable Intelligence Engine
Product loop: Personal Runtime trust/control
Date: 2026-05-13
Branch: main
Starting commit: 5e4979a074e46914327aa7d64c66352e63236d0a

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
- `.codex/state/active-batch.yml`
- `docs/codex/POST_BATCH_GATE_REGISTRY.md`
- `docs/codex/MOAT_RUNTIME_INTEGRATION_MASTER_PLAN.md`
- `docs/codex/MOAT_RUNTIME_LOOP_MATRIX.md`
- `docs/codex/MOAT_RUNTIME_ACCEPTANCE_CRITERIA.md`
- `docs/codex/MOAT_RUNTIME_GOLDEN_SCENARIOS.md`
- `docs/codex/MOAT_RUNTIME_BATCH_OVERLAY.json`
- Existing owner tests for Start Here recommendation, Recommendation Explanation, Correction Fold, and Source Atlas query models.

## Files Changed

- Added `Native/AmbitionsTests/Domain/InspectableIntelligenceGoldenScenarioTests.swift`
- Added `docs/audits/mri16-inspectable-intelligence-golden-tests-report.md`

## Loop Behavior Added Or Still Deferred

Added value-model golden scenario coverage for:

- Source-backed recommendation traces that can proceed only when current reviewed source evidence supports the recommendation.
- Stale, source-needed, and wrong/revoked source states degrading or blocking recommendation behavior without fake certainty.
- Why this? trace inspection covering source IDs, reason, fit state, uncertainty, controls, receipt behavior, and local-only trust seam copy guardrails.
- Rejected recommendation correction producing a structured local correction receipt and inspectable learning influence.
- Reset, delete, and disable learning-input corrections removing future learning use and creating local receipts.

Still deferred:

- No UI/runtime wiring was added.
- No persistence, sync, hosted service, external model, telemetry, signing, release, or visual runtime behavior was added.

## EFC Applicability

EFC applicability: invoked/applicable.

Reason: this batch touches inspectable intelligence, user control, local learning, recommendation behavior, proof boundaries, and claim language through golden tests.

## Validation

Verified:

| Command | Exit | Result |
| --- | ---: | --- |
| `git diff --check` | 0 | Passed. |
| `python3 scripts/ambitions-state-advance-validate.py \|\| true` | 0 | Passed with `GREEN: state advancement coherent; current=SA16 Source Container Model; next=SA17 URL Source Importer`. |
| `python3 scripts/ambitions-unsupported-claim-scan.py Native/AmbitionsTests/Domain/InspectableIntelligenceGoldenScenarioTests.swift docs/audits/mri16-inspectable-intelligence-golden-tests-report.md 2>/dev/null \|\| true` | 0 | Passed with `GREEN: unsupported completion/readiness claim scan passed`. |
| `xcodegen generate` | 0 | Passed and regenerated `Ambitions.xcodeproj`. |
| `xcrun swiftc -parse Native/AmbitionsTests/Domain/InspectableIntelligenceGoldenScenarioTests.swift` | 0 | Passed syntax parse for the new test file. |

Not fully verified:

| Command | Exit | Result |
| --- | ---: | --- |
| `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/InspectableIntelligenceGoldenScenarioTests CODE_SIGNING_ALLOWED=NO` | not executed | The outer command policy rejected the shell command before execution: `approval required by policy, but AskForApproval is set to Never`. |
| XcodeBuildMCP `test_sim` with `-only-testing:AmbitionsTests/InspectableIntelligenceGoldenScenarioTests CODE_SIGNING_ALLOWED=NO` | failed before tests | Test-target compile failed before MRI16 assertions ran due to existing out-of-scope compile debt in `Native/AmbitionsTests/Services/PolicyGuardedCommandExecutorTests.swift:28`, `Native/AmbitionsTests/Persistence/PortableRestoreRollbackTests.swift:109`, and `Native/AmbitionsTests/Persistence/PreMigrationBackupTests.swift:110`. MCP log: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-05-13T11-50-22-804Z_pid66166_4e007187.log`. |

Accepted Yellow reason: MRI16 installed the scoped golden tests and static/syntax checks passed, but the focused simulator proof could not reach the new test assertions because unrelated test-target compile debt blocks the build outside the approved Phase 02 boundary.

## Phase 04 Repair Pass 1

Repair performed:

- Updated this report's inspected source-truth list to include the prompt-required AGENTS and Moat Runtime overlay files inspected during Phase 04.

No test-source repair was made. The Phase 03 review blocker remains correctly classified as out-of-scope unrelated test-target compile debt, not MRI16 assertion failure.

Phase 04 validation:

| Command | Exit | Result |
| --- | ---: | --- |
| `git diff --no-index --check /dev/null Native/AmbitionsTests/Domain/InspectableIntelligenceGoldenScenarioTests.swift` | 0 | Passed after normalizing no-index diff output: no whitespace errors emitted. |
| `git diff --no-index --check /dev/null docs/audits/mri16-inspectable-intelligence-golden-tests-report.md` | 0 | Passed after normalizing no-index diff output: no whitespace errors emitted. |
| `python3 scripts/ambitions-unsupported-claim-scan.py Native/AmbitionsTests/Domain/InspectableIntelligenceGoldenScenarioTests.swift docs/audits/mri16-inspectable-intelligence-golden-tests-report.md 2>/dev/null \|\| true` | 0 | Passed with `GREEN: unsupported completion/readiness claim scan passed`. |
| `python3 scripts/ambitions-state-advance-validate.py \|\| true` | 0 | Passed with `GREEN: state advancement coherent; current=SA16 Source Container Model; next=SA17 URL Source Importer`. |
| `xcrun swiftc -parse Native/AmbitionsTests/Domain/InspectableIntelligenceGoldenScenarioTests.swift` | 0 | Passed syntax parse for the new test file. |
| `xcodegen generate` | 0 | Passed and regenerated `Ambitions.xcodeproj`. |
| XcodeBuildMCP `test_sim` with `-only-testing:AmbitionsTests/InspectableIntelligenceGoldenScenarioTests CODE_SIGNING_ALLOWED=NO` | failed before tests | Test-target compile failed before MRI16 assertions ran due to existing out-of-scope compile debt in `Native/AmbitionsTests/Services/PolicyGuardedCommandExecutorTests.swift:28`, `Native/AmbitionsTests/Persistence/PortableRestoreRollbackTests.swift:109`, and `Native/AmbitionsTests/Persistence/PreMigrationBackupTests.swift:110`. MCP log: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-05-13T11-57-34-391Z_pid66844_0e542e1c.log`. |

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

Rollback command:

```bash
rm -- Native/AmbitionsTests/Domain/InspectableIntelligenceGoldenScenarioTests.swift docs/audits/mri16-inspectable-intelligence-golden-tests-report.md
```

No conditional domain repair files were modified.

## Next Handoff

Run focused validation for the new value-model golden tests. If validation exposes only unrelated app-target compile debt, keep MRI16 scoped to scenario/eval proof and report accepted Yellow rather than widening into app runtime repair.
