# MRI05 Recovery Thread Runtime Report

## Status
- Phase status: YELLOW (Phase 04 repair pass found no further in-scope source repair; static checks passed and the patch is scoped; focused runtime test execution is blocked before MRI05 assertions by outside-seam test-target compile debt)

## Operating System
- Ambition Lifecycle Engine

## Product Loop
- Recovery and re-entry

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
- `docs/audits/mri03-commitment-lifecycle-report.md`
- `docs/audits/mri04-proof-capital-model-report.md`
- `Native/Ambitions/Domain/AmbitionGraphModels.swift`
- `Native/AmbitionsTests/Domain/AmbitionGraphModelsTests.swift`
- `Native/AmbitionsTests/Domain/AmbitionGraphProjectionStoreTests.swift`

## Files Changed
- `Native/Ambitions/Domain/AmbitionGraphModels.swift`
- `Native/AmbitionsTests/Domain/AmbitionGraphModelsTests.swift`
- `docs/audits/mri05-recovery-thread-runtime-report.md`

## Phase 03 Review Notes
- GPT-5.5 review found the Phase 02 scope stayed inside the approved MRI05 boundary.
- Repair applied: constructor-created `RecoveryThread` values now default `preservedProofRefs` from stable-unique `priorProofRefs` when no explicit preserved proof refs are supplied, matching the legacy decode path and preserving proof in new in-memory runtime objects.
- Added focused test coverage for the default preserved-proof behavior.
- No UI, shell, top-level IA, persistence/schema migration, project configuration, entitlement, privacy manifest, signing, hosted CI, backend, network, external/cloud LLM, or release automation files were changed.

## Phase 04 Repair Pass Notes
- Re-read active truth, moat runtime overlays, current run state, the MRI05 source diff, and existing MRI05 audit report.
- No additional in-scope source defect was found after the Phase 03 repair.
- No files outside the approved MRI05 boundary were modified.
- No attempt was made to repair outside-seam test-target compile debt in services or persistence tests.

## Final Gate Notes
- GPT-5.5 final review re-read active truth files, the current diff, and this audit report.
- Final gate found the source patch scoped to the MRI05 RecoveryThread runtime boundary and did not find a new in-scope source defect.
- Final gate corrected the rollback note so it removes the newly added audit report instead of using `git restore` for an untracked file.
- Final gate XcodeBuildMCP retry could not run because this session had no configured XcodeBuildMCP defaults and the exposed tool refused direct project/scheme arguments without those defaults.
- Final gate direct shell `xcodebuild` retry remained blocked before execution by outer command policy (`approval required by policy, but AskForApproval is set to Never`).

## Validation Commands
- `xcodegen generate` - exit `0`
- `git diff --check` - exit `0`
- `python3 scripts/ambitions-state-advance-validate.py || true` - exit `0` (`GREEN: state advancement coherent; current=SA10C Projection Fixtures And No-Sprawl Validation; next=SA11 Source Atlas Store`)
- `python3 scripts/ambitions-unsupported-claim-scan.py Native/Ambitions/Domain/AmbitionGraphModels.swift Native/AmbitionsTests/Domain/AmbitionGraphModelsTests.swift docs/audits/mri05-recovery-thread-runtime-report.md 2>/dev/null || true` - exit `0` (`GREEN: unsupported completion/readiness claim scan passed`)
- Direct shell `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/AmbitionGraphModelsTests test CODE_SIGNING_ALLOWED=NO` - blocked before execution by outer command policy (`approval required by policy, but AskForApproval is set to Never`)
- XcodeBuildMCP session defaults set to `Ambitions.xcodeproj`, scheme `Ambitions`, simulator `iPhone 17`.
- Phase 04 XcodeBuildMCP `test_sim` with `-only-testing:AmbitionsTests/AmbitionGraphModelsTests CODE_SIGNING_ALLOWED=NO` - failed before MRI05 assertions because the current test target stops on outside-seam compile errors:
  - `Native/AmbitionsTests/Services/PolicyGuardedCommandExecutorTests.swift:28` actor-isolated `value()` call inside `XCTAssertEqual` autoclosure.
  - `Native/AmbitionsTests/Persistence/PortableRestoreRollbackTests.swift:109` `ScriptedRollbackSnapshotService` does not conform to `PortableSnapshotServicing`.
  - `Native/AmbitionsTests/Persistence/PreMigrationBackupTests.swift:110` `FixedSnapshotService` does not conform to `PortableSnapshotServicing`.
  - XcodeBuildMCP logs:
    - Phase 02: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-05-13T01-05-00-837Z_pid46112_1e6fcfb9.log`
    - Phase 03: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-05-13T01-12-28-328Z_pid47276_a9895237.log`
    - Phase 04: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-05-13T01-17-44-099Z_pid48308_d98a6fe3.log`

## EFC Applicability
- Invoked for this batch because MRI05 touches recovery, proof preservation, receipt behavior, and future user-facing lifecycle semantics.
- EFC does not authorize release, accessibility, performance, privacy/legal, device, TestFlight, App Store, hosted backend, external/cloud LLM, or global-train claims.

## Loop Behavior Added
- Extended existing `RecoveryThread` rather than creating a parallel recovery model.
- Added deterministic runtime fields and value objects for:
  - last honest point (`RecoveryLastHonestPoint`)
  - stable-unique preserved proof references (`preservedProofRefs` and `effectiveProofRefs`)
  - re-entry step exposure (`RecoveryReentryStep` and `hasReentryStep`)
  - explicit receipt readiness (`AmbitionRecoveryReceiptBehavior` and `isReceiptReady`)
- Added defaulted `RecoveryThread` decode behavior so legacy payloads without the new runtime fields remain valid.
- Added constructor default behavior so in-memory runtime objects preserve prior proof refs when explicit preserved proof refs are absent.
- Expanded recoverable-state behavior so active, held, paused, stalled, and interrupted-but-still-useful recovery threads remain recoverable, while complete and not-needed threads do not.
- Added focused tests for proof-reference deduplication, last honest point preservation, default preserved proof refs, re-entry step exposure, receipt behavior, non-shaming receipt vocabulary, recoverable status mapping, and legacy decode defaults.

## Loop Behavior Deferred
- No persistence/schema migration was added.
- No services, app shell, UI, top-level IA, Plan compatibility, project configuration, entitlement, privacy manifest, hosted backend, external/cloud LLM, signing, release automation, or CI changes were made.
- Focused runtime proof did not reach MRI05 assertions because outside-seam test-target compile debt blocks test execution.

## Claims Not Made
- release readiness
- TestFlight readiness
- App Store readiness
- device proof
- public accessibility conformance
- performance validation
- privacy/legal approval
- visual runtime completion unless visual proof exists
- global train completion

## Rollback Notes
- `git restore -- Native/Ambitions/Domain/AmbitionGraphModels.swift Native/AmbitionsTests/Domain/AmbitionGraphModelsTests.swift`
- `rm docs/audits/mri05-recovery-thread-runtime-report.md`
- `xcodegen generate`

## Next Handoff
- Re-run the focused `AmbitionGraphModelsTests` lane after the current outside-seam test-target compile blockers are resolved.
- A later scoped batch should decide whether the new `RecoveryThread` runtime fields need persistence/schema migration or service/UI wiring.
