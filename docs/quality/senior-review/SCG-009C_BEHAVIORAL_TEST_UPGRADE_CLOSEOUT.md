# SCG-009C Behavioral Test Upgrade Closeout

Issue: AMB-1304 - SCG-009C Behavioral test upgrade train  
Baseline SHA: `03152e2422ca4ea509f5b51226736bea1c7d447c`  
Final SHA: resolved by the SCG-009C commit created from this closeout; exact hash is recorded in the final operator and Linear closeout after commit creation.  
Train scope: SCG-009C only. No SCG-010, visual proof repair queue, shell geometry repair, app redesign, release readiness work, or broad production implementation.

## 1. Executive Verdict

SCG-009C is Green for the scoped source/test behavior proof added in this train and Yellow for the broader SCG-009 parent ceiling.

This train upgraded behavior proof without production source changes. The new tests prove local persistence, mutation, recompute, fallback, deterministic-clock, no-account, permission-denied, and undo-availability behavior at service/projection/runtime seams. They do not claim device runtime proof, visual proof, accessibility proof, keyboard/full-screen composer proof, release readiness, owner acceptance, or parent SCG-009 closure.

Status ceiling:

- Source/Test Green: allowed only for the behavior tests and selectors listed in this artifact.
- Runtime Green: allowed only for the specifically tested local service/projection paths.
- Visual Green: forbidden.
- Release Green: forbidden.
- Senior-readiness, app release-ready, and owner acceptance: forbidden.
- SCG-009 parent: must remain open or in owner review until A/B/C evidence is reconciled by owner review.

## 2. Behavior-Proof Matrix

| Flow | Required behavior | Proof added or used | Status |
| --- | --- | --- | --- |
| SCG006-F03 Capture save | Local capture persists and receipt exists where architecture supports it. | `CaptureServiceTests.testSCG009CCaptureSavePersistsLocalCaptureAndLedgerReceipt` proves before empty repository/ledger, action create, after persisted capture and `.captureCreated` ledger receipt. Existing `CaptureRuntimeReceiptTests` selector also passed. | Green for local service behavior. No keyboard/full-screen/device claim. |
| SCG006-F05 Goal creation | Goal creation persists real domain state. | Adjacent selector `GoalCreationServiceTests` passed; SCG-009C goal feed test creates a goal through `RepositoryBackedGoalsService` and reads it from a separate repository facade over the same store. | Green for local service behavior. No visual/device crash claim. |
| SCG006-F06 Goal thread feeds Today | Persisted/projected goal contributes to Today recommendation behavior. | `TodayFreshGoalVisibilityTests.testSCG009CPersistedGoalThreadFeedsTodayAfterRepositoryReload` proves persisted goal thread state makes Today active and drives hero/action/fixed commitment targets. | Green for local projection behavior. |
| SCG006-F08 Closure mutates Today | Closure action changes state and emits proof/receipt/undo metadata. | `TodayCommandHandlerTests.testSCG009CClosureMutatesTodayBeforeActionAfterWithProofReceipt` proves before/action/after Today state, step completion, feedback/evidence increase, command record success, ledger IDs, and stage pipeline metadata. | Green for local Today command path. |
| SCG006-F09 Move step | Time mutation recomputes Today where required. | Existing `TimeFieldMutationCoordinatorTests` and adjacent `TimeTodayCouplingTests` selectors passed for place-step/time mutation coupling; SCG-009C undo test also exercises recompute metadata on a protected-time mutation. | Green for tested projection paths; no UI drag/shell claim. |
| SCG006-F10 Protect window | Protected time mutation updates Time and Today recommendation constraints. | `TimeFieldMutationCoordinatorTests.testSCG009CTimeProtectCorrectionUndoOnlyAppearsWithRestoreSnapshot` proves protected bucket after state, Today recompute, affected-window avoidance, complete mutation proof, and restore snapshot. | Green for tested projection path. |
| SCG006-F11 Time correction | Time correction/recompute behavior uses deterministic time where touched. | Adjacent `TimeTodayCouplingTests` selector passed; SCG-009C Time test uses fixed `now` and asserts before/after snapshots and recompute metadata. | Green for tested deterministic projection path. |
| SCG006-F14 Undo | Undo appears only when real; unavailable undo is typed and does not claim restore. | `TimeFieldMutationCoordinatorTests.testSCG009CTimeProtectCorrectionUndoOnlyAppearsWithRestoreSnapshot` proves undo available only with restore snapshot, undo restores prior Time shape, and post-undo state has unavailable undo with typed reason. | Green for Time mutation undo path. Broader closure undo remains not claimed. |
| SCG006-F15 Offline/no-account | Core flow works without account/network dependency where testable. | `LocalOnlyProofHarnessTests.testSCG009CNoAccountCoreFlowPersistsLocallyAndFeedsToday` proves local-only sync unavailable, no remote intelligence backend, local goal and capture persistence, and Today feed from local repositories. | Green for local harness behavior. No full device/offline release proof. |
| SCG006-F16 Permission denied fallback | Denied permission returns fallback and avoids system write. | `CalendarReminderActionFlowTests.testSCG009CPermissionDeniedCalendarFallbackDoesNotWriteSystemEvent` proves denied Calendar response, warning fallback copy/state, no selected event, and zero calendar write attempts. | Green for test-seam permission fallback. No fake system permission/device claim. |

## 3. Upgraded Tests

### `CaptureServiceTests.testSCG009CCaptureSavePersistsLocalCaptureAndLedgerReceipt`

- Old proof weakness: capture coverage could pass from service construction or repository presence without proving before/action/after local persistence plus receipt state in the same behavior path.
- New behavior assertion: starts with empty local capture repository and event ledger, creates a capture through `DefaultCaptureService`, then asserts the persisted capture fields and `.captureCreated` ledger receipt.
- Source path under test: `Native/Ambitions/Core/Persistence` repositories through `SwiftDataCaptureRepository`; capture service behavior through `DefaultCaptureService`.
- Expected evidence: capture ID, trimmed raw text, source type, status, route, repository list membership, receipt ID, receipt kind, and receipt capture ID.

### `TodayCommandHandlerTests.testSCG009CClosureMutatesTodayBeforeActionAfterWithProofReceipt`

- Old proof weakness: Today command tests proved pieces of command recording and copy, but did not fully pin a Today-projected primary action through before/action/after mutation and proof metadata in one behavior test.
- New behavior assertion: creates a goal, loads Today, uses Today primary action target as source of truth, completes the step, reloads Today, then asserts completed step state, feedback/evidence increments, command execution success, ledger linkage, and stage action metadata.
- Source path under test: `RepositoryBackedTodayService`, `RepositoryBackedGoalsService`, command execution repository, event ledger, evidence and feedback repositories.
- Expected evidence: step state changes from open projected action to completed persisted step; evidence and feedback counts increase by one; command record is succeeded; ledger IDs are real and linked.

### `TodayFreshGoalVisibilityTests.testSCG009CPersistedGoalThreadFeedsTodayAfterRepositoryReload`

- Old proof weakness: goal-to-Today coverage could be satisfied by in-memory object continuity or string labels without proving persisted goal thread state feeds Today through repository reload.
- New behavior assertion: writes a goal through one repository facade, reads through a second facade over the same SwiftData store, and proves Today becomes active from the persisted goal thread.
- Source path under test: `RepositoryBackedGoalsService`, `RepositoryBackedTodayService`, `SwiftDataGoalRepository`, Today surface lens projection.
- Expected evidence: persisted goal exists, Today hero subtitle matches persisted goal title, Today primary action targets the persisted goal/step, and fixed commitments include the same target.

### `TimeFieldMutationCoordinatorTests.testSCG009CTimeProtectCorrectionUndoOnlyAppearsWithRestoreSnapshot`

- Old proof weakness: Time mutation tests covered individual projections but did not pin undo availability to a real restore snapshot and typed post-undo unavailability.
- New behavior assertion: performs a protect-window mutation with deterministic `now`, asserts after projection and Today recompute, verifies before/after proof snapshots and undo restore snapshot, then applies undo and asserts restore plus unavailable typed undo.
- Source path under test: `TimeFieldMutationCoordinator`, Time mutation projection, stage mutation proof artifact.
- Expected evidence: protected bucket layer, recompute flags, complete action flow proof, undo label and restore snapshot, before/after proof snapshots, restored Time reading, unavailable reason after undo.

### `LocalOnlyProofHarnessTests.testSCG009CNoAccountCoreFlowPersistsLocallyAndFeedsToday`

- Old proof weakness: offline/no-account proof was mostly capability declaration, not a core behavior path creating local data and projecting Today without account/network dependency.
- New behavior assertion: with `LocalOnlySyncCapability`, creates a goal and capture locally, confirms no remote intelligence backend, reloads persisted state, and loads Today from local repositories.
- Source path under test: local runtime capabilities, `DefaultCaptureService`, `RepositoryBackedGoalsService`, `RepositoryBackedTodayService`, local persistence repositories.
- Expected evidence: local-only backend kind, unavailable sync, remote intelligence false, persisted goal/capture, Today primary target and subtitle from local goal.

### `CalendarReminderActionFlowTests.testSCG009CPermissionDeniedCalendarFallbackDoesNotWriteSystemEvent`

- Old proof weakness: permission fallback could assert only fallback strings or authorization state without proving the system-write path stayed untouched.
- New behavior assertion: creates a scheduled goal step, forces denied Calendar authorization through the test seam, invokes calendar-event action, then asserts fallback warning and zero calendar write attempts.
- Source path under test: `RepositoryBackedGoalsService` calendar action flow and `CalendarRemindersServicing` seam.
- Expected evidence: fallback title/state/body, no calendar selection, `calendarWriteAttemptCount == 0`.

## 4. Before / Action / After References

| Claim | Before | Action | After |
| --- | --- | --- | --- |
| Capture save persists | `beforeCaptures.isEmpty`, `beforeEvents.isEmpty` | `DefaultCaptureService.createCapture(...)` | persisted capture exists, list contains created ID, `.captureCreated` receipt exists |
| Closure mutates Today | Today primary action target and open persisted step selected | `RepositoryBackedTodayService.performAction(.complete, ...)` | persisted step completed, evidence/feedback counts increase, command record succeeds, ledger IDs linked |
| Goal thread feeds Today | goal absent from fresh read repository until create result is loaded | `RepositoryBackedGoalsService.createGoal(...)` | read repository returns goal, Today active hero/action/fixed commitment target persisted goal/step |
| Time protect/recompute/undo | seeded Time state and protected-time mark selected | `TimeFieldMutationCoordinator.perform(.protectWindow, ...)` | protected bucket, Today recompute, proof snapshots, undo restore snapshot; post-undo restores prior Time reading and marks undo unavailable |
| Offline/no-account | local-only sync status and no remote intelligence backend | create goal and capture, then load Today | local persisted goal/capture and Today projection exist without account/network dependency |
| Permission denied fallback | scheduled goal step and denied Calendar authorization seam | `.createCalendarEvent` action | warning fallback response, no calendar selection, zero calendar write attempts |

## 5. Stale Proof Handling

No tests were removed in this child. The train supplemented prior file/string/source-presence-heavy coverage with six behavior tests that assert real state transitions, repository persistence, event/proof receipts, fallback behavior, deterministic clock use, or undo restore semantics.

`python3 scripts/ambitions-test-strength-audit.py` passed after the upgrade, confirming the touched test set does not rely on architecture-name or file-presence assertions while claiming behavior.

Fixture-only detector IDs such as `SCG-004-903`, `SCG-004-913`, and `SCG-004-915` remain support evidence only. They were not escalated into production defects and did not drive production changes.

## 6. Known-Issues Mapping

Rows mapped for behavior-proof evidence only; no known-issues rows were closed by this train.

- Capture save/proof: `AMB-ISSUE-0003`, `AMB-ISSUE-0008`, `AMB-ISSUE-0012`, `AMB-ISSUE-1101` through `AMB-ISSUE-1107`.
- Closure mutates Today: `AMB-ISSUE-0004`, `AMB-ISSUE-1006`, `AMB-ISSUE-1201`, `AMB-ISSUE-0014`, `AMB-ISSUE-1801`, `AMB-ISSUE-1802`.
- Move/protect/correct Time recomputes Today: `AMB-ISSUE-0009`, `AMB-ISSUE-0501` through `AMB-ISSUE-0507`, `AMB-ISSUE-0913`, `AMB-ISSUE-1401` through `AMB-ISSUE-1404`.
- Goal thread feeds Today: `AMB-ISSUE-1301` through `AMB-ISSUE-1304`, `AMB-ISSUE-1309`, `AMB-ISSUE-0004`, `AMB-ISSUE-0005`.
- Offline/no-account and permission fallback: `AMB-ISSUE-0014`, `AMB-ISSUE-0807`, `AMB-ISSUE-1801`, `AMB-ISSUE-1802`.
- Related QA remediation issues, not duplicates: `AMB-1192`, `AMB-1193`, `AMB-1186`, `AMB-1188`, `AMB-1197`, `AMB-1199`.

## 7. Findings and Root Causes Addressed

Addressed within scoped behavior-test proof:

- `SCG-004-011` - TestStrengthAudit: added behavior assertions over state transitions instead of file/string/source presence.
- `SCG-004-004` - RuntimeMutationProofAudit: added mutation/proof/receipt/undo checks for capture, Today closure, Time mutation, and permission fallback paths.
- `SCG-004-007` - TimeCorrectnessAudit: used deterministic clock inputs in touched local-only and Time mutation paths.
- `SCG-004-010` - PrivacyLocalFirstAudit: added no-account/local-only and denied-permission fallback behavior proof.
- `SCG-004-013` - VisualProofAudit: treated only as a non-claim ceiling. No visual repair or Visual Green claim.

Root cause coverage:

- `RC-SCG006-001`: remains a current runtime/device proof gap; this child improves unit/integration behavior proof only.
- `RC-SCG006-002`: partially addressed for capture save local persistence and receipt; keyboard/full-screen composer proof remains pending.
- `RC-SCG006-003`: partially addressed for persisted goal thread feeding Today projection.
- `RC-SCG006-004`: partially addressed for Today closure mutation/proof path.
- `RC-SCG006-005`: partially addressed for Time mutation, recompute metadata, and adjacent Time/Today coupling selectors.
- `RC-SCG006-007`: partially addressed for Time undo availability and typed unavailable undo; broad undo parity remains Yellow.
- `RC-SCG006-009`: partially addressed for local-only/no-account and denied Calendar fallback behavior.
- `RC-SCG006-010`: remains a proof ceiling only; no visual/accessibility repair was in scope.

## 8. Architecture and Scope Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched: tests only under `Native/AmbitionsTests/...`; no production owner changed.
- Files created: `docs/quality/senior-review/SCG-009C_BEHAVIORAL_TEST_UPGRADE_CLOSEOUT.md`.
- Files moved: none.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Production seams changed: none.
- UI, shell, visual, navigation, account, R2, Package.swift, project.yml, xcodeproj, privacy manifest, AppUI, and Packages changes: none.
- Architecture Yellow debt: none introduced by this child.
- No "equivalent" folder/path interpretation was used.

## 9. Validation

Passed:

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test -only-testing:AmbitionsTests/CaptureServiceTests -only-testing:AmbitionsTests/TodayCommandHandlerTests -only-testing:AmbitionsTests/TodayFreshGoalVisibilityTests -only-testing:AmbitionsTests/TimeFieldMutationCoordinatorTests -only-testing:AmbitionsTests/LocalOnlyProofHarnessTests -only-testing:AmbitionsTests/CalendarReminderActionFlowTests CODE_SIGNING_ALLOWED=NO
```

Result: `** TEST SUCCEEDED **`; 50 tests, 0 failures.  
Result bundle: `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.06.24_01-51-17--0400.xcresult`

```bash
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test -only-testing:AmbitionsTests/TimeTodayCouplingTests -only-testing:AmbitionsTests/GoalCreationServiceTests -only-testing:AmbitionsTests/CaptureRuntimeReceiptTests CODE_SIGNING_ALLOWED=NO
```

Result: `** TEST SUCCEEDED **`; 25 tests, 0 failures.  
Result bundle: `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.06.24_01-52-38--0400.xcresult`

```bash
python3 scripts/ambitions-architecture-inventory.py
```

Result: Green final-tree parity achieved; canonical required files 224, entries 224, blocking entries 0, implemented 224.

```bash
python3 scripts/ambitions-quality-gate.py
```

Result: Green all strict quality gates passed; production Swift files 1223, changed paths 6 at the time of the run.

```bash
python3 scripts/ambitions-test-strength-audit.py
```

Result: Green.

```bash
git diff --check
git status --short --branch
```

Result before this closeout artifact: diff check clean; worktree had only the six scoped test files modified.

Capped/failed validation:

- One earlier changed-class selector run exposed compile issues from `await` inside `XCTUnwrap` autoclosures; those were fixed before the passing run.
- One superseded run reached tests, exposed earlier assertion mistakes, and was manually interrupted after hanging while saving results. It ended with `** TEST INTERRUPTED **` and was replaced by the passing 50-test rerun above.

Build-local: not run because no production seams changed.

## 10. Remaining Yellow Limitations

- No device runtime proof, keyboard proof, full-screen composer proof, screenshot evaluation, accessibility review, Visual Green, Release Green, senior-readiness, app release-ready claim, or owner acceptance.
- SCG-009 parent remains Yellow/In Review until owner reconciles SCG-009A audit, SCG-009B domain repair, and SCG-009C behavior proof together.
- Closure undo beyond the tested Time mutation path remains not claimed.
- Permission fallback is proven through test seams, not real device system permission UI.
- Offline/no-account is proven through local services and runtime capability flags, not full device offline release validation.

## 11. Parent Status and Pause Checkpoint

SCG-009C can move to In Review with evidence from this train. SCG-009 parent must not be marked Done by this child unless owner review separately reconciles SCG-009A/B/C and Linear permits closure.

Explicit pause checkpoint: stop after SCG-009C. Do not proceed to SCG-010, the visual proof repair queue, shell geometry repair, app redesign, or release-readiness work until the owner reviews the SCG-009 closeout.

## 12. Rollback Plan

Revert the single SCG-009C commit. The behavior tests and this closeout artifact roll back together. No production seams were changed, so no targeted production rollback verification is required. After revert, rerun:

```bash
python3 scripts/ambitions-quality-gate.py
python3 scripts/ambitions-test-strength-audit.py
git diff --check
```
