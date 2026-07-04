# AMB-1670 Runtime Compartment Ownership Tests

Status: Ready for review
Date: 2026-07-04
Scope: AMB-1670 M03 Runtime Simplification

## Purpose

AMB-1670 requires each retained runtime compartment in scope to earn permanence
through executable behavior tests. This packet maps the live tests to the Linear
acceptance leaves and records the narrow coverage added for the remaining gap.

This is not a new architecture map. The owner map remains the Final Architecture
Tree and the LocalRuntimeOS law:

```text
Command -> Event -> Projection -> Receipt -> Replay
```

## Required Leaf Coverage

| Leaf | Required behavior | Executable evidence |
| --- | --- | --- |
| Commands | validation, idempotency, rejection, receipt emission | `Native/AmbitionsTests/LocalRuntimeOS/Commands/CommandsLeafTests.swift`, `AmbitionsCommandExecutorTests.swift`, `ExternalActionCommandServiceTests.swift`, `PolicyGuardedCommandExecutorTests.swift`, and `LocalRuntimeOSCommandsOwnershipTests.swift` cover validation/rejection, command-journal append-before-mutation, idempotency replay, command/runtime receipt metadata, unsupported/future command blocking, external adapter rejection receipts, and policy-guarded mutation blocking. |
| Transactions | atomic commit, rollback, conflict detection, interrupted commit recovery | `Native/AmbitionsTests/LocalRuntimeOS/Transactions/LocalRuntimeOSTransactionsOwnershipTests.swift` covers validated prepare, read/write sets, rollback plan creation, event append, projection/search materialization, replayable commit receipts, duplicate idempotency replay, stale read-set conflicts, invalid-command rejection, coordinator-owned mutation contexts, and the AMB-1670 interrupted-commit failure receipt case. |
| Events | append ordering, replay determinism, corruption handling | `Native/AmbitionsTests/LocalRuntimeOS/EventJournal/RuntimeEventJournalTests.swift` covers append ordering, reload/cursor behavior, checksum chain validity, tamper detection, deterministic replay, tombstone events, compaction snapshots, and command-event append without duplicate replay mutation. |
| Projections | rebuild, stale invalidation, extension snapshot read | `Native/AmbitionsTests/LocalRuntimeOS/Projections/LocalRuntimeOSProjectionsTests.swift` covers canonical definitions, event-fed materialization, projection diffs/invalidations, projection-store reads for Today/Goals/Time/You/Search, widget and App Intent projection reads, stale projection repair receipts, and missing-projection rebuild requirements. |
| Scheduling | time fit, reflow, recovery moves, closure impact | `Native/AmbitionsTests/LocalRuntimeOS/Scheduling/SchedulingTests.swift`, `ProtectedStepPlacementPolicyTests.swift`, and `PriorityPlacementPolicyTests.swift` cover protected placement gating, graph conflicts, recurrence/DST behavior, local calendar persistence, user-approved protected moves, missed recovery move-it behavior, priority review without fake confidence, and local/account-free placement policy. |
| ExternalWrites | EventKit/Reminders outbox, notifications, no private graph egress | `Native/AmbitionsTests/LocalRuntimeOS/ExternalWrites/ExternalWritesTests.swift`, `SideEffectLedgerModelsTests.swift`, and `SideEffectLedgerRepositoryTests.swift` cover EventKit outbox presence, removed ReminderOutbox duplicate authority, local-commit receipt gating, failed-safe external attempts, notification side-effect records, App Intent and Share Extension handoff through canonical side-effect owners, legacy receipt rejection, and deterministic side-effect ledger persistence. |
| Continuity | optional CloudKit, offline-first behavior, conflict receipts | `Native/AmbitionsTests/LocalRuntimeOS/Continuity/ContinuityTests.swift`, `CloudKitContinuityFoundationTests.swift`, `LivingPlanContinuitySyncTests.swift`, and `SyncCapabilityTests.swift` cover local-device authority, proof-backed continuity eligibility, private-graph payload denial, CloudKit default-off diagnostics, offline no-account operation, local-first queued changes, causal merge conflicts, conflict quarantine/review receipts, tombstone propagation limits, and sign-out local-data retention. |
| Repair | migration repair, projection rebuild, journal validation | `Native/AmbitionsTests/LocalRuntimeOS/Repair/SchemaLedgerTests.swift`, `MigrationPlannerTests.swift`, `DryRunMigrationTests.swift`, `PreMigrationBackupTests.swift`, `RuntimeDoctorTests.swift`, `StoreInvariantCheckerTests.swift`, `RepairPlanEngineTests.swift`, and `RestoreRollbackTests.swift` cover schema ledger validation, migration repair gating, non-executable dry-run repair, backup gates, command/event replay drift, search projection rebuild repair signals, journal validation, local drift readers, preview repair receipts, invariant blockers, and rollback restore behavior. |

## Added Coverage

`LocalRuntimeOSTransactionsOwnershipTests.testInterruptedCommitReturnsFailureReceiptAndDoesNotRecordIdempotency`
simulates an event-store append failure during runtime transaction commit. The
test proves:

- the attempted successful mutation is downgraded to `.blocked`;
- no event-ledger IDs survive as committed evidence;
- `RuntimeTransactionFailureReceipt` metadata records the failure reason,
  blocked timestamp, missing runtime evidence, and interrupted append error;
- no idempotency receipt is recorded for a transaction that did not commit.

## Validation Evidence

Focused Xcode validation passed for 89 representative XCTest cases across the
eight AMB-1670 leaves.

| Leaf | Focused run | Result |
| --- | --- | ---: |
| Commands | `AmbitionsTests/CommandsLeafTests` | 11 passed |
| Transactions | `AmbitionsTests/LocalRuntimeOSTransactionsOwnershipTests` | 10 passed |
| Events | `AmbitionsTests/RuntimeEventJournalTests` | 6 passed |
| Projections | `AmbitionsTests/LocalRuntimeOSProjectionsTests` | 5 passed |
| Scheduling | `AmbitionsTests/SchedulingTests` and `AmbitionsTests/ProtectedStepPlacementPolicyTests` | 12 passed |
| ExternalWrites | `AmbitionsTests/ExternalWritesTests` and `AmbitionsTests/SideEffectLedgerModelsTests` | 16 passed |
| Continuity | `AmbitionsTests/ContinuityTests`, `AmbitionsTests/CloudKitContinuityFoundationTests`, and `AmbitionsTests/SyncCapabilityTests` | 18 passed |
| Repair | `AmbitionsTests/RuntimeDoctorTests` and `AmbitionsTests/MigrationPlannerTests` | 11 passed |

Primary summary artifacts:

- `.codex/xcode-summaries/AMB_1670_TRANSACTIONS_OWNERSHIP/20260704T102318Z-AmbitionsTests-LocalRuntimeOSTransactionsOwnershipTests-70666-29776/focused-test-summary.json`
- `.codex/xcode-summaries/AMB_1670_COMPARTMENT_OWNERSHIP/20260704T102528Z-AmbitionsTests-CommandsLeafTests-71605-7525/focused-test-summary.json`
- `.codex/xcode-summaries/AMB_1670_COMPARTMENT_OWNERSHIP/20260704T102655Z-AmbitionsTests-RuntimeEventJournalTests-72428-27728/focused-test-summary.json`
- `.codex/xcode-summaries/AMB_1670_COMPARTMENT_OWNERSHIP/20260704T102842Z-AmbitionsTests-LocalRuntimeOSProjectionsTests-72982-16729/focused-test-summary.json`
- `.codex/xcode-summaries/AMB_1670_COMPARTMENT_OWNERSHIP/20260704T103030Z-AmbitionsTests-SchedulingTests-73427-22200/focused-test-summary.json`
- `.codex/xcode-summaries/AMB_1670_COMPARTMENT_OWNERSHIP/20260704T103210Z-AmbitionsTests-ProtectedStepPlacementPolicyTests-73832-5865/focused-test-summary.json`
- `.codex/xcode-summaries/AMB_1670_COMPARTMENT_OWNERSHIP/20260704T103356Z-AmbitionsTests-ExternalWritesTests-74271-7702/focused-test-summary.json`
- `.codex/xcode-summaries/AMB_1670_COMPARTMENT_OWNERSHIP/20260704T103532Z-AmbitionsTests-SideEffectLedgerModelsTests-74706-3178/focused-test-summary.json`
- `.codex/xcode-summaries/AMB_1670_COMPARTMENT_OWNERSHIP/20260704T103708Z-AmbitionsTests-ContinuityTests-75127-25063/focused-test-summary.json`
- `.codex/xcode-summaries/AMB_1670_COMPARTMENT_OWNERSHIP/20260704T103819Z-AmbitionsTests-CloudKitContinuityFoundationTests-75613-32351/focused-test-summary.json`
- `.codex/xcode-summaries/AMB_1670_COMPARTMENT_OWNERSHIP/20260704T103856Z-AmbitionsTests-SyncCapabilityTests-76072-28311/focused-test-summary.json`
- `.codex/xcode-summaries/AMB_1670_COMPARTMENT_OWNERSHIP/20260704T103934Z-AmbitionsTests-RuntimeDoctorTests-76512-16094/focused-test-summary.json`
- `.codex/xcode-summaries/AMB_1670_COMPARTMENT_OWNERSHIP/20260704T104033Z-AmbitionsTests-MigrationPlannerTests-71604-25002/focused-test-summary.json`

Full build-for-testing, full test suite, device, screenshot, accessibility, and
release gates were not run for this AMB-1670 slice.

## Proof Ceiling

This packet supports AMB-1670 Ready For Review for executable compartment
ownership tests. It does not claim full LocalRuntimeOS completion, app-wide
command-only mutation, device behavior, rendered UI quality, accessibility
conformance, privacy/legal approval, Visual Green, Release Green, production R2,
production CloudKit, TestFlight readiness, or App Store readiness.
