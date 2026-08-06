# Implementation Plan

## Outcome and boundary

Implement optional user-owned continuity as a subordinate transport projection
over the signed-in user’s private CloudKit database while preserving the current
local, no-account, offline command/event authority. `CKSyncEngine` schedules
transport; Ambitions owns eligibility, durable intent, account epochs, record
protection, causal reconciliation, quarantine, tombstones, migration, restore,
Receipts, diagnostics, and release gating.

Production remains non-mutating and disabled until one immutable manifest binds
every conjunctive gate cell to the exact source, build, signing, entitlements,
container/environment, deployed schema, fixtures, physical devices, privacy,
accessibility, migration, rollback, and known-gap evidence. No partial subset,
feature flag, simulator run, document approval, or successful upload enables it.

## Affected components and exact files

- Update `docs/canon/specifications/systems/sync-and-continuity.md`,
  `docs/canon/specifications/systems/privacy-and-data-classification.md`,
  `docs/canon/specifications/systems/persistence-and-replay.md`,
  `docs/canon/specifications/journeys/backup-restore-reset.md`,
  `docs/canon/specifications/surfaces/you.md`,
  `docs/canon/standards/accessibility.md`,
  `docs/canon/standards/security-and-privacy.md`,
  `docs/canon/standards/testing-and-fixtures.md`,
  `docs/canon/standards/performance-and-energy.md`,
  `docs/canon/standards/validation-and-release.md`,
  `docs/canon/migration/UX_BLUEPRINT.md`, and
  `docs/canon/migration/ux-blueprint.json`.
- Replace/extend the existing files under
  `Native/Ambitions/Core/LocalRuntimeOS/Continuity/`; add
  `ContinuityStore.swift`, `ContinuityStoreSchema.swift`,
  `ContinuityOutboxProjector.swift`, `ContinuityEligibilityManifest.swift`,
  `ContinuityEnvironmentManifest.swift`, `ContinuityReleaseGateManifest.swift`,
  `CKSyncEngineContinuityDriver.swift`, `ContinuityReconciler.swift`,
  `ContinuityOperationJournal.swift`, and `ContinuityProjection.swift`.
- Extend `Native/Ambitions/Core/LocalRuntimeOS/Commands/AmbitionsCommand.swift`,
  `Native/Ambitions/Core/LocalRuntimeOS/Commands/RuntimeCommandCodec.swift`,
  the Event/Receipt/History/replay registries,
  `Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/DataClassProtectionMatrix.swift`,
  `Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/EgressFirewall.swift`,
  continuity diagnostics under `Native/Ambitions/Core/LocalRuntimeOS/Inspection/`,
  and the existing storage/repair authorities.
- Add `Native/Ambitions/Surfaces/You/ContinuityControlCenterSurface.swift`,
  `ContinuityInitialReviewSurface.swift`, `ContinuityConflictReviewSurface.swift`,
  `ContinuityRecoverySurface.swift`, and projection/view-model integration.
- Update `Native/Ambitions/Ambitions.entitlements` and `project.yml` only after
  the environment manifest and disabled composition exist; use XcodeGen.
- Add the exact unit, integration, migration, privacy, performance, accessibility,
  UI, and release-gate fixtures named in `tasks.md`.

## Interfaces and data flow

An owning local Command commits before continuity intent exists. The outbox
projector tails committed Event IDs and atomically advances its cursor with one
revision-bound intent in `ContinuityStore`. The current reviewed account epoch,
closed eligibility manifest, policy/schema revision, and release gate determine
whether an intent may be supplied to `CKSyncEngine`. Engine serialization is
persisted, but never substitutes for the independent durable outbox.

Fetched records enter protected staging. Validation checks private destination,
environment, account epoch, record and protocol versions, encrypted payload and
encrypted domain-separated digests, causal frontier, eligibility, owner policy,
and tombstone state.
The reconciler submits an idempotent typed local-owner Command for a dominating
or registered deterministic merge. Semantically concurrent, unsupported,
missing-lineage, or delete/edit cases preserve both alternatives in quarantine;
CloudKit change tags, clocks, arrival order, and device labels never choose
meaning. Replay never performs network work.

## Persistence, migration, and concurrency

`ContinuityStore.sqlite` is an actor-isolated canonical runtime companion store
for consent, account epochs, outbox, inbox, engine serialization, opaque system
fields, remote inventory, quarantine, operation journals, cursors, tombstone
frontiers, and content-free diagnostics. Protected payloads use complete file
protection. Transactions enforce outbox/cursor atomicity, owner-command-before-
engine-state ordering, compare-and-set review choices, checksums, and idempotent
per-item acknowledgement.

The first migration creates empty disabled state and sends nothing. Later local
and CloudKit schema changes are additive, dual-readable across a declared client
matrix, checkpointed, crash-resumable, and fail closed for unknown versions.
Account change freezes the old epoch and discards its engine state while keeping
local intent; a fresh account never receives old or unreviewed-unbound payload.
Tombstones dominate older live copies and later minimize to content-free causal
integrity facts after the supported replica/client horizon.

## Rollout, canon, and implementation order

Land canon, closed manifests, and disabled gate first; then durable storage and
account epochs, protected envelope/causal contracts, driver/outbox, ingestion/
conflict/tombstone logic, migration/restore/destructive controls, native UI,
and proof harnesses. Development and production environments are compile-time
separate. Promote only additive reviewed production schema after development
two-device proof, then prove the signed release candidate against the exact
production manifest. Any mismatch returns to disabled without deleting local or
remote data.
