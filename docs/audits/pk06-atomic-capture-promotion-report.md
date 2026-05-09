# PK06 Atomic Capture Promotion Report

<!-- markdownlint-disable MD013 -->

Date: 2026-05-08
Batch: PK06 Atomic Capture Promotion
Result: Green

## Summary

PK06 extends the PK03-PK05 local UnitOfWork proof from Goal/Draft creation and
clarification into Capture promotion. SwiftData-backed Capture promotion now
prepares the deterministic Goal and persisted Draft without saving them first,
then commits the Goal, Draft, and promoted Capture record through one local
single-context UnitOfWork.

## Implementation

- Added `PreparedGoalCreation` plus a narrow `GoalCreationPreparing` protocol so
  Capture promotion can reuse the existing deterministic goal compiler without
  performing a prior Goal/Draft write.
- Added `CapturePromotionUnitOfWorking` contracts and
  `SwiftDataCapturePromotionUnitOfWork` for atomic Goal, Draft, and Capture
  persistence.
- Wired live and preview SwiftData repositories with the Capture promotion
  UnitOfWork.
- Updated `DefaultCaptureService.turnCaptureIntoGoal` to use the atomic path
  when a goal preparer and Capture promotion UnitOfWork are available, while
  preserving the existing fallback for lightweight/test capture services.
- Forwarded post-commit snapshot and notification refresh through the existing
  Goals service wrappers after the atomic persistence commit.
- Added focused tests proving successful receipt metadata and injected rollback
  before the Capture write leaves no new Goal/Draft and keeps the original
  Capture unbound.

## Files Changed

- `Native/Ambitions/App/AppContainerFactory.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureModels.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`
- `Native/Ambitions/Notifications/LocalNotificationFoundation.swift`
- `Native/Ambitions/Persistence/PersistenceContracts.swift`
- `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
- `Native/Ambitions/PreviewSupport/PreviewAppContainer.swift`
- `Native/Ambitions/Runtime/AmbitionsRuntimeFactory.swift`
- `Native/Ambitions/Services/AppServices.swift`
- `Native/Ambitions/Services/CaptureService.swift`
- `Native/Ambitions/Services/SnapshotRefreshingServices.swift`
- `Native/AmbitionsTests/Persistence/CaptureServiceTests.swift`

## Validation

Verified:

- `git status --short`
  - Result: expected PK06 working-tree changes before staging.
- `git diff --check`
  - Result: passed.
- `xcodegen generate`
  - Result: passed.
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/CaptureServiceTests/testTurnCaptureIntoGoalPersistsGoalDraftAndCaptureThroughUnitOfWork -only-testing:AmbitionsTests/CaptureServiceTests/testAtomicCapturePromotionRollsBackGoalDraftAndKeepsOriginalCaptureWhenCaptureWriteFailsBeforeSave test`
  - Result: passed, 2 tests, 0 failures.

Closeout validation to run after state updates:

- `scripts/global-train-next-batch.sh || true`
- `scripts/global-train-status-summary.sh || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`
- `scripts/build-local.sh`

## Data Safety Classification

Green for the focused PK06 seam only. The proof covers local SwiftData-backed
Capture promotion atomicity across Goal, Draft, and Capture writes and injected
rollback before Capture save. It does not prove schema migration safety,
backup/restore, import/export rollback, sync/cloud conflict safety, full
data-loss-proof storage, or unrelated Capture routing paths.

## EFC Flagship Proof Overlay

- EFC applicability: invoked
- Product proof: Capture-to-Goal promotion now commits the new Goal, persisted
  Draft, and promoted Capture together through one local UnitOfWork.
- Trust proof: service output includes local UnitOfWork receipt metadata for the
  atomic promotion path.
- Privacy proof: no external service, hosted AI, telemetry, analytics, account,
  sync/cloud, or user-data server behavior added.
- Accessibility proof: no UI, visual, gesture, motion, or accessibility
  presentation behavior changed.
- Degraded-state proof: thrown-error rollback test leaves the original Capture
  unbound and creates no Goal/Draft residue.
- Test proof: focused simulator tests passed, 2 tests, 0 failures.
- Release-claim boundary: no release, TestFlight, App Store, physical-device,
  legal/privacy, public accessibility, production readiness, CI, sync/cloud, or
  all-tests-pass claim.
- Recovery proof: failure injection confirms rollback before Capture save.
- Performance proof: not applicable beyond focused tests; no performance-budget
  claim.
- Continuation proof: PK07 is the next eligible batch after PK06 closeout and
  clean worktree/commit/push.
- EFC Yellow owners: PK07-PK41 retain remaining storage, migration, side-effect,
  privacy/data-control, sync-readiness, intelligence-readiness, scale, and
  modularization proof owners; release/legal/device/accessibility proof remains
  unclaimed.

## No-Claim Boundary

PK06 does not claim production readiness, migration-safe storage, data-loss-
proof behavior outside the focused seam, sync readiness, cloud readiness,
privacy compliance, public accessibility conformance, performance-budget proof,
hosted CI, release readiness, TestFlight readiness, App Store readiness, signed
archive proof, physical-device proof, hosted AI, telemetry, analytics, or all-
tests-pass.

## Next Eligible

PK07 Storage Schema Version Ledger.
