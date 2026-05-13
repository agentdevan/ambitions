# MRI04 Proof Capital Model Report

## Status
- Phase status: YELLOW (GPT-5.5 final gate found no additional in-boundary source defect; focused runtime test lane remains blocked by outside-seam test-target compile debt)
- Phase 02 Spark patch status: REPAIRED IN PHASE 03 (no external runtime or UI surface changes)
- Phase 04 GPT-5.5 repair status: NO ADDITIONAL SOURCE REPAIR REQUIRED
- Final GPT-5.5 gate status: YELLOW / not eligible for autonomous Green commit because focused owner tests did not reach MRI04 assertions

## Operating System
- Ambition Lifecycle Engine

## Product Loop
- Goal-to-life-direction

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
- `Native/Ambitions/Domain/ProofResourceGraphModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSProofTrustModels.swift`
- `Native/AmbitionsTests/Domain/ProofResourceGraphModelsTests.swift`

## Files Changed
- `Native/Ambitions/Domain/ProofResourceGraphModels.swift`
- `Native/AmbitionsTests/Domain/ProofResourceGraphModelsTests.swift`
- `docs/audits/mri04-proof-capital-model-report.md`

## Validation Commands
- `git diff --check` — exit `0`
- `xcodegen generate` — exit `0`
- `python3 scripts/ambitions-state-advance-validate.py` — exit `0` (`GREEN: state advancement coherent; current=SA10C Projection Fixtures And No-Sprawl Validation; next=SA11 Source Atlas Store`)
- `python3 scripts/ambitions-unsupported-claim-scan.py Native/Ambitions/Domain/ProofResourceGraphModels.swift Native/AmbitionsTests/Domain/ProofResourceGraphModelsTests.swift docs/audits/mri04-proof-capital-model-report.md 2>/dev/null || true` — exit `0` (`GREEN: unsupported completion/readiness claim scan passed`)
- XcodeBuildMCP defaults inspected; generated project discovered at `Ambitions.xcodeproj`; scheme `Ambitions`; simulator `iPhone 17` (`iOS 26.3`) selected.
- XcodeBuildMCP `test_sim` with `-only-testing:AmbitionsTests/ProofResourceGraphModelsTests CODE_SIGNING_ALLOWED=NO` — returned nonzero before MRI04 assertions because current test-target compilation stops outside the MRI04 seam:
  - `Native/AmbitionsTests/Services/PolicyGuardedCommandExecutorTests.swift:28` uses `await` inside `XCTAssertEqual` autoclosure / actor-isolated value access.
  - `Native/AmbitionsTests/Persistence/PortableRestoreRollbackTests.swift:109` has `ScriptedRollbackSnapshotService` not conforming to `PortableSnapshotServicing`.
  - `Native/AmbitionsTests/Persistence/PreMigrationBackupTests.swift:110` has `FixedSnapshotService` not conforming to `PortableSnapshotServicing`.
  - Final-gate artifact log: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-05-13T00-49-45-426Z_pid43828_60ab7062.log`

## Phase 03 Review Repair
- Review finding: `ProofReference.evaluatePivotTransfer(to:)` passed `capitalProfile.evidence.anchorObjectIDs` into the candidate overlap set, so any proof with an anchor could satisfy overlap even when the anchor did not match the pivot destination.
- Repair: restrict pivot transfer overlap candidates to the destination object's stable key.
- Review finding: adding nonoptional `ProofReference.capitalProfile` risked breaking decode of older proof-resource graph payloads that do not contain the new field.
- Repair: add a custom `ProofReference` decode path that defaults missing `capitalProfile` to the manual/user-stated/not-applicable profile, plus a focused legacy decode test.
- Scope: `Native/Ambitions/Domain/ProofResourceGraphModels.swift` only; no persistence, UI, shell, project, entitlement, privacy, hosted/backend, or release automation files touched.

## Phase 04 Repair Pass
- Re-inspected the Phase 03 repair against the MRI04 boundary and active truth files.
- No further source changes were required: pivot transfer overlap is destination-only, and legacy proof payload decoding has a default `ProofCapitalProfile`.
- Updated this report with current Phase 04 validation evidence and current outside-seam test-target blockers.

## Final GPT-5.5 Gate
- Inspected final git status and diff; dirty files remain bounded to the MRI04 domain model, focused test file, and this audit report.
- Confirmed no project, Package.swift, entitlement, privacy manifest, release automation, hosted backend, external/cloud LLM, shell IA, or visual runtime files changed.
- Static validation passed, and unsupported claim scan passed.
- Focused owner proof did not execute MRI04 assertions because the test target fails to compile in outside-seam test files listed above.
- Result: YELLOW. Source scope is clean, but the batch is not autonomous Green commit eligible without owner acceptance or a later passing focused test lane.

## EFC Applicability
- Invoked for this batch because MRI04 models proof trust flow and correction behavior.
- Not an approval to make broader release, accessibility, performance, privacy/legal, or global-train completion claims.

## Loop Behavior Added
- Added proof-capital creation metadata in domain model:
  - `ProofCapitalSourceKind`
  - `ProofCapitalContradictionState`
  - `ProofCapitalEvidence`
  - `ProofCapitalProfile`
- Added deterministic transfer-state modeling:
  - `ProofCapitalTransferOutcome`
  - `ProofCapitalTransferIssue`
  - `ProofCapitalTransferRecord`
  - `ProofPivotPreservationReport`
- Added pure projection behavior for pivot preservation:
  - `ProofReference.evaluatePivotTransfer(to:)`
  - `ProofResourceGraphProjection.evaluatePivotPreservation(from:to:)`
- Added focused proof-capital tests for:
  - Preserved vs review vs non-transferable classification during pivot transitions.
  - Overlap + source/proof-receipt requirements before transfer.
  - Contradiction and staleness effects blocking silent transfer.

## Loop Behavior Deferred
- No persistence migration/schema changes.
- No services, app shell, or UI wiring changes.
- No runtime integration validation beyond the focused unit-test source added in this phase; the focused test lane did not execute MRI04 assertions because current test-target compilation stops outside this seam.

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
- `git restore -- Native/Ambitions/Domain/ProofResourceGraphModels.swift Native/AmbitionsTests/Domain/ProofResourceGraphModelsTests.swift docs/audits/mri04-proof-capital-model-report.md`

## Next Handoff
- Validate behavior with owning feature/runtime integration points that consume `ProofResourceGraphProjection` and decide whether any of the new `ProofCapitalProfile` fields require cross-source write population.
- Re-run focused test lane after the current outside-seam test-target compile blockers are resolved.
