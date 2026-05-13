# MRI13 Local Learning Controls Report

Status: Accepted Yellow
Date: 2026-05-13
Branch: `main`
Starting commit: `5ff9876a22a39dfd92e4ddab2ef21ca1abc7b181`

## Operating System

Inspectable Intelligence Engine.

## Product Loop

Personal Runtime trust/control.

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
- `prompts/batches/MRI13-LOCAL-LEARNING-CONTROLS.md`

## Files Changed

- `Native/Ambitions/Domain/ProfileModels.swift`
- `Native/Ambitions/Features/Profile/ProfileFeatureService.swift`
- `Native/Ambitions/Features/Profile/ProfileScreen.swift`
- `Native/AmbitionsTests/Profile/ProfileFeatureServiceTests.swift`
- `docs/audits/mri13-local-learning-controls-report.md`

## Loop Behavior Added

- Extended the existing `What Ambitions Knows` / Personal Runtime inspection model with explicit local learning controls.
- Added reset, disable, delete, and export rows that are source-tied, local-only, confirmation-aware, and receipt-aware.
- Kept broad destructive deletion conservative: single learning-signal deletion is described as confirmation-gated, while broad deletion is not claimed.
- Kept export bounded to a local summary by category and boundary, without raw private text, sync payload, account data, or external memory.
- Added focused service tests for control labels, local-only posture, receipt language, export boundary, and banned-copy exclusions.

## Still Deferred

- Actual destructive deletion execution remains deferred until a safe command, confirmation, receipt, and undo boundary is implemented and tested.
- Durable disabled-learning storage remains deferred; this batch exposes the source-tied control posture without claiming persistence behavior beyond current source evidence.
- End-to-end recommendation behavior after reset/delete remains deferred to later Inspectable Intelligence batches.

## EFC Applicability

EFC applicable and invoked for this report boundary because MRI13 touches user data, local intelligence, trust controls, side-effect/deletion posture, export posture, accessibility-aware visible controls, and public claim safety.

## Validation

- `git diff --check`
  - Exit code: `0`
  - Result: passed.
- `python3 scripts/ambitions-state-advance-validate.py || true`
  - Effective shell exit code: `0`
  - Output: `GREEN: state advancement coherent; current=SA16 Source Container Model; next=SA17 URL Source Importer`
- `python3 scripts/ambitions-unsupported-claim-scan.py Native/Ambitions/Domain/ProfileModels.swift Native/Ambitions/Features/Profile/ProfileFeatureService.swift Native/Ambitions/Features/Profile/ProfileScreen.swift Native/AmbitionsTests/Profile/ProfileFeatureServiceTests.swift docs/audits/mri13-local-learning-controls-report.md 2>/dev/null || true`
  - Effective shell exit code: `0`
  - Output: `GREEN: unsupported completion/readiness claim scan passed`
- `xcodegen generate`
  - Exit code: `0`
  - Result: project generated.
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/ProfileFeatureServiceTests test`
  - Result: not executed by shell; rejected before launch by outer policy with `approval required by policy, but AskForApproval is set to Never`.
- XcodeBuildMCP `test_sim` with `-only-testing:AmbitionsTests/ProfileFeatureServiceTests`
  - Status: failed before focused tests executed.
  - Artifact: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-05-13T09-25-17-550Z_pid39933_7f01c896.log`
  - Blocking diagnostic: `Native/Ambitions/Features/Today/TodayReadModelProjector.swift:44` references `TodayTimeApertureState.summary`, but that type has no `summary` member.
  - Classification: unrelated app-target compile debt outside the approved MRI13 file boundary.

## Claims Not Made

- No release readiness claim.
- No TestFlight readiness claim.
- No App Store readiness claim.
- No device proof claim.
- No public accessibility conformance claim.
- No performance validation claim.
- No privacy/legal approval claim.
- No visual runtime completion claim.
- No global train completion claim.
- No broad destructive local-memory deletion claim.
- No cloud sync, hosted profile, or external model claim.

## Rollback Notes

Rollback this phase only:

```bash
git restore -- Native/Ambitions/Domain/ProfileModels.swift Native/Ambitions/Features/Profile/ProfileFeatureService.swift Native/Ambitions/Features/Profile/ProfileScreen.swift Native/AmbitionsTests/Profile/ProfileFeatureServiceTests.swift docs/audits/mri13-local-learning-controls-report.md
```

## Next Handoff

Resolve the unrelated `TodayTimeApertureState.summary` compile debt, then rerun the focused `ProfileFeatureServiceTests` lane. After that, the next Inspectable Intelligence handoff should wire actual source-tied persistence/receipts for reset, disable, delete, and export behavior without widening to broad destructive deletion.

## Phase 03 Review Addendum

Reviewed on 2026-05-13 from `main` at `5ff9876a22a39dfd92e4ddab2ef21ca1abc7b181`.

- `git diff --check`
  - Exit code: `0`
  - Result: passed.
- `python3 scripts/ambitions-state-advance-validate.py || true`
  - Effective shell exit code: `0`
  - Output: `GREEN: state advancement coherent; current=SA16 Source Container Model; next=SA17 URL Source Importer`
- `python3 scripts/ambitions-unsupported-claim-scan.py Native/Ambitions/Domain/ProfileModels.swift Native/Ambitions/Features/Profile/ProfileFeatureService.swift Native/Ambitions/Features/Profile/ProfileScreen.swift Native/AmbitionsTests/Profile/ProfileFeatureServiceTests.swift docs/audits/mri13-local-learning-controls-report.md 2>/dev/null || true`
  - Effective shell exit code: `0`
  - Output: `GREEN: unsupported completion/readiness claim scan passed`
- `xcodegen generate`
  - Exit code: `0`
  - Result: project generated.
- XcodeBuildMCP `test_sim` with `-only-testing:AmbitionsTests/ProfileFeatureServiceTests`
  - Status: failed before focused tests executed.
  - Artifact: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-05-13T09-36-08-674Z_pid41630_fa5555a7.log`
  - Blocking diagnostics: unrelated test-target compile debt in `Native/AmbitionsTests/Services/PolicyGuardedCommandExecutorTests.swift:28`, `Native/AmbitionsTests/Persistence/PortableRestoreRollbackTests.swift:109`, and `Native/AmbitionsTests/Persistence/PreMigrationBackupTests.swift:110`.
- XcodeBuildMCP `build_sim`
  - Status: failed before app build completion.
  - Artifact: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/build_sim_2026-05-13T09-38-57-373Z_pid41630_7fb00458.log`
  - Blocking diagnostic: unrelated app-target compile debt in `Native/Ambitions/Features/Today/TodayReadModelProjector.swift:44` referencing `TodayTimeApertureState.summary`, which does not exist.

Phase 03 review found no MRI13 scope drift, no forbidden IA restoration, no hosted/backend/cloud LLM path, and no unsupported release/accessibility/privacy/performance claim. Focused proof remains blocked by unrelated compile debt, so Accepted Yellow remains the honest status.

## Phase 04 Repair Pass 1 Addendum

Reviewed on 2026-05-13 from `main` at `5ff9876a22a39dfd92e4ddab2ef21ca1abc7b181`.

Repair decision: no MRI13 source repair was required. The dirty slice remains bounded to the approved five files, and the remaining validation blockers are outside the Phase 01 approved boundary.

- `git diff --check`
  - Exit code: `0`
  - Result: passed.
- `python3 scripts/ambitions-state-advance-validate.py || true`
  - Effective shell exit code: `0`
  - Output: `GREEN: state advancement coherent; current=SA16 Source Container Model; next=SA17 URL Source Importer`
- `python3 scripts/ambitions-unsupported-claim-scan.py Native/Ambitions/Domain/ProfileModels.swift Native/Ambitions/Features/Profile/ProfileFeatureService.swift Native/Ambitions/Features/Profile/ProfileScreen.swift Native/AmbitionsTests/Profile/ProfileFeatureServiceTests.swift docs/audits/mri13-local-learning-controls-report.md 2>/dev/null || true`
  - Effective shell exit code: `0`
  - Output: `GREEN: unsupported completion/readiness claim scan passed`
- `xcodegen generate`
  - Exit code: `0`
  - Result: project generated.
- XcodeBuildMCP `test_sim` with `-only-testing:AmbitionsTests/ProfileFeatureServiceTests`
  - Status: failed before focused MRI13 tests executed.
  - Artifact: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-05-13T09-46-39-523Z_pid42830_41c9ee02.log`
  - Blocking diagnostics: unrelated test-target compile debt in `Native/AmbitionsTests/Services/PolicyGuardedCommandExecutorTests.swift:28`, `Native/AmbitionsTests/Persistence/PortableRestoreRollbackTests.swift:109`, and `Native/AmbitionsTests/Persistence/PreMigrationBackupTests.swift:110`.
- XcodeBuildMCP `build_sim`
  - Status: failed before app build completion.
  - Artifact: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/build_sim_2026-05-13T09-48-16-777Z_pid42830_7aba25a9.log`
  - Blocking diagnostic: unrelated app-target compile debt in `Native/Ambitions/Domain/AmbitionsOSLivingDreamTodayBridgeModels.swift:392`, where `mapped(_:)` is non-exhaustive for `AmbitionsOSRecommendationStartHereIssue`.

Phase 04 found no scope drift, no forbidden top-level IA change, no hosted/backend/cloud LLM path, no silent learning/sync path, and no unsupported readiness claim. Focused proof remains blocked by unrelated compile debt, so Accepted Yellow remains the honest status.

## Phase 05 GPT-5.5 Final Gate Addendum

Reviewed on 2026-05-13 from `main` at starting commit `5ff9876a22a39dfd92e4ddab2ef21ca1abc7b181`.

Final dirty slice:

- `Native/Ambitions/Domain/ProfileModels.swift`
- `Native/Ambitions/Features/Profile/ProfileFeatureService.swift`
- `Native/Ambitions/Features/Profile/ProfileScreen.swift`
- `Native/AmbitionsTests/Profile/ProfileFeatureServiceTests.swift`
- `docs/audits/mri13-local-learning-controls-report.md`

Final gate findings:

- The patch remains bounded to MRI13 local learning controls in the You/Profile trust-control seam.
- No top-level IA change, Plan restoration, sixth tab, hosted personal-data backend, external/cloud LLM path, or silent sync path was found in the MRI13 diff.
- User-facing control copy stays local-only, source-tied, confirmation-aware, receipt-aware, and conservative about reset/delete/export behavior.
- The untracked audit report is part of the expected MRI13 slice and must be staged explicitly if this Accepted Yellow is committed.

Final validation rerun:

- `git diff --check`
  - Exit code: `0`
  - Result: passed.
- `python3 scripts/ambitions-state-advance-validate.py || true`
  - Effective shell exit code: `0`
  - Output: `GREEN: state advancement coherent; current=SA16 Source Container Model; next=SA17 URL Source Importer`
- `python3 scripts/ambitions-unsupported-claim-scan.py Native/Ambitions/Domain/ProfileModels.swift Native/Ambitions/Features/Profile/ProfileFeatureService.swift Native/Ambitions/Features/Profile/ProfileScreen.swift Native/AmbitionsTests/Profile/ProfileFeatureServiceTests.swift docs/audits/mri13-local-learning-controls-report.md 2>/dev/null || true`
  - Effective shell exit code: `0`
  - Output: `GREEN: unsupported completion/readiness claim scan passed`
- `xcodegen generate`
  - Exit code: `0`
  - Result: project generated.
- Prior XcodeBuildMCP focused `ProfileFeatureServiceTests`
  - Status: blocked before MRI13 assertions by unrelated test-target compile debt in `PolicyGuardedCommandExecutorTests.swift`, `PortableRestoreRollbackTests.swift`, and `PreMigrationBackupTests.swift`.
- Prior XcodeBuildMCP app build
  - Status: blocked before app build completion by unrelated non-exhaustive switch compile debt in `Native/Ambitions/Domain/AmbitionsOSLivingDreamTodayBridgeModels.swift:392`.

Final gate decision: Accepted Yellow remains the honest status. The MRI13 slice is commit-eligible as a bounded Accepted Yellow only if the owner accepts that focused Xcode proof is blocked by unrelated compile debt and no release/build/readiness claim is made.

STATUS: YELLOW
