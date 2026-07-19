# SCG-009B Domain Model Repair Closeout

Status: Source Green for touched domain repairs; Runtime Yellow / Visual not claimed / Release not claimed.

Status ceiling: Source Green is limited to the touched `GoalThread`, `UserSystemProfile`, and `ClosureOutcome` domain contracts plus the closure mutation adapter proof covered by focused tests. Runtime Green is not claimed beyond the tested closure mutation classification seam. Visual Green, Release Green, senior-readiness, app release-ready, owner acceptance, and parent SCG-009 Done are not claimed.

Baseline SHA: `504ddf6f319cb4bbc37daa816702a4c385897b1e`

Final SHA: assigned by the SCG-009B repair commit; record exact pushed SHA in Linear/final closeout.

Branch: `main`

## Scope Control

SCG-009B only. SCG-009C behavioral test upgrade, SCG-010+, visual proof queue, UI/shell/visual repair, app redesign, release readiness, root navigation changes, Motion root surface, Capture tab, hosted AI/cloud LLM, private graph backend, R2 private-data path, package/project/privacy-manifest changes, and duplicate known-issues creation were not started.

Highest severity addressed: B3. No B0/B1/B2 production issue was proven by SCG-009A or this repair slice.

## Files Changed

- `Native/Ambitions/Core/Domain/GoalThread.swift`
- `Native/Ambitions/Core/Domain/UserSystemProfile.swift`
- `Native/Ambitions/Core/Domain/ClosureOutcome.swift`
- `Native/Ambitions/Projection/Mutations/ClosureStageMutation.swift`
- `Native/AmbitionsTests/Domain/CoreDomainCanonicalOwnershipTests.swift`
- `docs/qa/KNOWN_ISSUES.md`
- `docs/quality/senior-review/SCG-009B_DOMAIN_MODEL_REPAIR_CLOSEOUT.md`

Forbidden paths touched: none.

## Domain Objects Repaired

`GoalThread`

- Repair: added an explicit computed `PersistenceAuthority.projectedFromPersistedGoals` and `requiresDedicatedThreadRecord == false`.
- Behavior/persistence link: SCG-009A showed current thread hierarchy is projected from persisted Goal records through `RepositoryBackedGoalsService.makeGoalThreadHierarchies`, not through a dedicated thread table.
- Encoding proof: focused Codable round-trip keeps the computed authority out of stored JSON shape while preserving thread identity and stable unique goal IDs.
- Migration assessment: no persisted shape change; no SwiftData model, record, repository, migration, `project.yml`, or `Package.swift` change.

`UserSystemProfile`

- Repair: made the domain shape `Codable` and added explicit computed `PersistenceAuthority.derivedFromLocalContextAndSettings`, `requiresDedicatedProfileRecord == false`, and `privateGraphBackendAllowed == false`.
- Behavior/persistence link: current You/profile behavior is derived from local context/settings projections and existing local repositories; this repair classifies that derived authority instead of adding a speculative profile record.
- Encoding proof: focused Codable round-trip covers normalized user profile values and verifies computed privacy/backend classification is not serialized as persisted data.
- Migration assessment: no persisted shape change; no dedicated profile record added; no private graph backend or account-required path introduced.

`ClosureOutcome`

- Repair: added typed `MutationClassification` for proof, receipt, undo, and local-only semantics; added domain lookup by `ClosureState`.
- Behavior/projection link: `ClosureStageMutation` now reads undo availability from `ClosureOutcome.mutationClassification` instead of duplicating the closure-state decision.
- Encoding proof: focused Codable round-trip covers `ClosureOutcome` and verifies derived mutation classification after decode.
- Runtime/projection proof: focused test proves `.stillCounts` creates a local proof/receipt/undo-capable closure stage mutation, while `.blocked` keeps receipt/proof available but exposes review instead of direct undo.
- Migration assessment: no persisted shape change; no SwiftData record or migration change.

## Domain Objects Deferred

- `Step`: source/persistence present; behavior proof upgrades remain SCG-009C.
- `LifeArea`: source/projection present; local customization/persistence proof remains deferred unless later issue proves a concrete gap.
- `RealityWindow`: source/projection present; runtime/device permission-denied proof remains SCG-009C or later.
- `CapacityShape`: source/runtime projection present; offline/runtime proof remains deferred.
- `CaptureIntake`: source/persistence route present through Capture; full composer/save/receipt proof remains SCG-009C or Capture owner train.
- `ProofEvent`: source/runtime ledger present; proof ID continuity across flows remains SCG-009C.
- `RecoveryState`: source/runtime projection present; recovery visible-state proof remains SCG-009C.

## Findings Addressed

- `SCG-004-004`: addressed for the touched closure domain option seam by adding typed proof/receipt/undo classification and routing closure stage mutation undo availability through that domain classification.
- `SCG-004-010`: addressed for touched `UserSystemProfile` classification by explicitly preserving derived local context/settings authority, no dedicated profile record, and no private graph backend.
- `SCG-004-011`: addressed for touched domain repairs by adding focused behavior/encoding tests rather than file-name or string-only assertions.
- `SCG-004-001`: addressed only where SCG-009A proved concrete domain-owner ambiguity for `GoalThread` and `UserSystemProfile`; no broad architecture reclassification was attempted.
- `SCG-004-003`: no concrete touched layer/import gap was proven; deferred as accepted Yellow.
- `SCG-004-007`: no Today/Time direct time path was touched; deferred.

Fixture-only findings `SCG-004-900` through `SCG-004-915` were not treated as production defects.

## Root Causes Addressed

- `RC-SCG006-004`: partially addressed for the closure outcome domain classification feeding the closure stage mutation adapter.
- `RC-SCG006-007`: partially addressed for closure undo classification; broad Time/Capture/destructive undo matrix remains deferred.
- `RC-SCG006-009`: partially addressed for `UserSystemProfile` derived local-only/no-private-backend classification; release/offline proof remains deferred.

Not closed: `RC-SCG006-001`, `RC-SCG006-002`, `RC-SCG006-003`, `RC-SCG006-005`.

## Known-Issues Mapping

Updated `docs/qa/KNOWN_ISSUES.md` with a mapping note only. No rows were closed.

Rows mapped:

- Today/Closure: `AMB-ISSUE-0004`, `AMB-ISSUE-0005`, `AMB-ISSUE-1001`-`AMB-ISSUE-1007`
- Goals: `AMB-ISSUE-1301`-`AMB-ISSUE-1304`, `AMB-ISSUE-1309`
- Proof/accessibility/release/local-first: `AMB-ISSUE-0014`, `AMB-ISSUE-0807`, `AMB-ISSUE-1801`, `AMB-ISSUE-1802`

Related QA remediation references, not duplicates: `AMB-1192`, `AMB-1193`, `AMB-1186`, `AMB-1188`, `AMB-1197`, `AMB-1199`.

## Validation

Run:

- `git status --short --branch`: clean on `main` at baseline before edits.
- `git rev-parse HEAD`: `504ddf6f319cb4bbc37daa816702a4c385897b1e`.
- `xcodegen generate`: pass.
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test -only-testing:AmbitionsTests/Domain CODE_SIGNING_ALLOWED=NO`: build/test invocation succeeded but executed 0 tests; not counted as behavior proof.
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test -only-testing:AmbitionsTests/CoreDomainCanonicalOwnershipTests CODE_SIGNING_ALLOWED=NO`: pass, 15 tests, 0 failures.
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test -only-testing:AmbitionsTests/TodayViewModelTests/testAFRI022ActionClosureConfirmationPersistsReceiptAndFeedsLocalReplayInspection -only-testing:AmbitionsTests/TodayViewModelTests/testTrain6ActionClosureStageMutationUpdatesLoadedTodayRail CODE_SIGNING_ALLOWED=NO`: pass, 2 tests, 0 failures.

- `python3 scripts/ambitions-architecture-inventory.py`: pass, `GREEN final-tree parity achieved`, 224 required files, 224 implemented, 0 blocking entries.
- `python3 scripts/ambitions-quality-gate.py`: pass, `GREEN all strict quality gates passed`, 7 changed paths.
- `python3 scripts/ambitions-test-strength-audit.py`: pass, `ambitions-test-strength-audit GREEN`.
- `git diff --check`: pass.
- `git status --short --branch`: scoped dirty worktree before commit containing only SCG-009B files listed above.

Validation failed/capped:

- The initial `AmbitionsTests/Domain` selector executed 0 tests; it is recorded as build coverage only, not test proof.
- Runtime/device/manual/offline/no-account/permission-denied proof was not run and is not claimed.

## Architecture Tree Closeout

Final Architecture Tree section inspected: yes.

Canonical owners touched: `Core/Domain`, `Projection/Mutations`, tests, QA/SCG docs.

Files moved or created: created this closeout artifact only; no source files moved.

Old/non-canonical paths removed: none.

Compatibility shims left behind: none.

Yellow architecture debt remaining: broader SCG owner/import Yellow findings remain outside this child; SCG-009C still owns broader behavior-proof upgrades.

Next repair train if debt remains: AMB-1304 / SCG-009C for behavior tests; owner-specific trains for runtime/device/visual/release proof.

No equivalent folder/path interpretation was used.

## Linear Updates

Planned after validation and push:

- AMB-1303: closeout comment with commit, validation, status ceiling, remaining gaps.
- AMB-1292: parent update comment. Do not mark parent Done.
- AMB-1304: not started.
- AMB-1302: not altered except referenced.

## Remaining Gaps

- Runtime/device proof remains missing for traced flows.
- Capture save/full-screen composer proof remains pending.
- Goal creation to Today coupling remains source-backed but not runtime/device closed.
- Time mutation and Today recompute proof remains pending outside the untouched Time path.
- Broad undo matrix across closure/destructive/runtime flows remains uneven beyond the touched closure domain classification.
- Offline/no-account and permission-denied fallback proof remains release-unproven.
- Visual Green, Release Green, senior-readiness, app release-ready, owner acceptance, and parent SCG-009 Done remain forbidden.

## Rollback Plan

Revert the SCG-009B repair commit. Domain classifications, closure mutation adapter use, focused tests, known-issues mapping note, and this closeout artifact must roll back together. No persisted model shape changed; therefore no migration rollback or data-risk remediation is required.
