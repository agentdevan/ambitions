# PFC07 Migration Ladder And Backward Compatibility Tests Report
<!-- markdownlint-disable MD013 -->

Result: Green
Date: 2026-05-05
Train: PFC01-PFC40 Platform / Framework / Compliance Completion Train
Batch: PFC07 Migration Ladder And Backward Compatibility Tests
Owner: Persistence

## Summary

PFC07 completed a focused persistence compatibility proof. The current repo does
not define a separate production SwiftData migration ladder, and PFC07 made no
schema changes. Instead, it validated the current local-only schema boundary
with existing focused tests for repository round-trips, legacy import mapping,
portable snapshot compatibility, malformed payload safety, conflict reporting,
fresh-store restore, and explicit local-only sync posture.

No production Swift, schema, migration, workflow, project, dependency, signing,
entitlement, privacy manifest, lockfile, generated file, CloudKit/sync/account
runtime, user-facing export/import surface, delete-all-memory surface, AI/LDI
runtime, or release/legal/App Store/TestFlight/device/public accessibility claim
was changed or created.

## Files Inspected

- `docs/audits/pfc06-schema-persistence-source-truth-report.md`
- `docs/codex/batches/PFC06_Schema_And_Persistence_Source_Truth_Prompt.md`
- `docs/canon/DATA_LOCAL_SYNC_EXPORT.md`
- `docs/canon/TRUST_PRIVACY_MEMORY.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `Native/Ambitions/Persistence/SwiftDataModels.swift`
- `Native/Ambitions/Persistence/SwiftDataStore.swift`
- `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
- `Native/Ambitions/Persistence/PersistenceContracts.swift`
- `Native/Ambitions/Persistence/PortableSnapshotContracts.swift`
- `Native/Ambitions/Persistence/PortableSnapshotService.swift`
- `Native/Ambitions/Persistence/LegacyImportService.swift`
- `Native/Ambitions/Persistence/SyncCapabilityContracts.swift`
- `Native/AmbitionsTests/Persistence/PersistenceRepositoryTests.swift`
- `Native/AmbitionsTests/Persistence/PortableSnapshotServiceTests.swift`
- `Native/AmbitionsTests/Persistence/LegacyImportServiceTests.swift`
- `Native/AmbitionsTests/Persistence/SyncCapabilityTests.swift`

## Files Changed

- `docs/codex/batches/PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt.md`
- `docs/audits/pfc07-migration-ladder-backward-compatibility-tests-report.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Migration Boundary

Current state:

- `AmbitionsPersistenceStore.schema` defines the active SwiftData model set.
- No new SwiftData model, attribute, relationship, migration plan, CloudKit
  schema, or destructive store reset behavior was introduced by PFC07.
- Repository compatibility is currently proven through in-memory SwiftData store
  round-trips and raw-value fallback tests.
- Portable snapshot compatibility is versioned through
  `PortableSnapshotSchemaVersion.v1`.
- Unsupported portable snapshot versions are rejected instead of imported.
- Legacy pre-manifest packages decode with generated manifests.
- Malformed packages fail before mutating local records.

This is a local-only compatibility proof, not production-store migration proof
on real user data shapes.

## Existing Test Proof Used

`PersistenceRepositoryTests` proves:

- Goal, plan, Step, LifeGraph, shared-life metadata, draft, proof, receipt,
  capture, teaching signal, and app-state repository round-trips.
- Capture canonical state raw values persist and reload.
- Legacy capture raw values `pending` and `processed` map through one
  persistence fallback to current capture states.

`LegacyImportServiceTests` proves:

- Legacy learning goals import into current untimed learning draft/goal shape.
- Legacy support ownership, parent relationship, tasks, and milestone structure
  map into current goal/plan shape.

`PortableSnapshotServiceTests` proves:

- Current native repositories export into `PortableAppSnapshot.v1`.
- User-selected export categories work without claiming sync.
- Replace-local-store restores known package records.
- Merge-with-conflict-report imports safe new records and reports ambiguous
  conflicts.
- Unsupported portable snapshot schema versions throw before import.
- Manifest warnings are surfaced without silently dropping local data.
- Partial-package reference warnings do not drop records.
- New-phone disaster drill restores an encoded package into a fresh in-memory
  store.
- Additive shared-life metadata round-trips through portable snapshots.
- Missing `teachingSignals` decodes as empty and generates a manifest.
- Legacy packages without manifests merge without deleting local data.
- Malformed package decode failure leaves local data untouched.

`SyncCapabilityTests` proves:

- The only supported sync posture is local-only and unavailable.

## Validation Commands Run

- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/PersistenceRepositoryTests -only-testing:AmbitionsTests/PortableSnapshotServiceTests -only-testing:AmbitionsTests/LegacyImportServiceTests -only-testing:AmbitionsTests/SyncCapabilityTests`
- `git status --short`
- `git diff --check`
- touched-doc trailing whitespace scan
- `scripts/cqs-privacy-security-claim-scan.sh docs/codex/batches/PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt.md docs/audits/pfc07-migration-ladder-backward-compatibility-tests-report.md || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Validation Results

- Focused persistence test slice: PASS. 28 tests executed, 0 failures.
- `xcodegen generate`: PASS and left no tracked project diff.
- `git diff --check`: PASS.
- Touched-doc trailing whitespace: PASS.
- CQS privacy/security claim scan: PASS with zero hits for the PFC07 prompt
  scan root.
- `scripts/run-doc-qa.sh || true`: PASS with accepted Yellow advisory backlog.
  Lychee reported 650 OK and 0 errors. Markdownlint and deprecated-language
  findings are repo-wide known backlog and were not introduced as production
  source changes by PFC07.
- `scripts/batch-train-gate-check.sh || true`: PASS with expected dirty-tree
  Yellow hint before commit.

## Remaining Yellow Owners

- PFC08 owns corruption recovery, backup, restore, and user-visible recovery
  copy.
- PFC09-PFC11 own any future sync strategy, CloudKit schema, conflict model, and
  sync implementation proof.
- PFC12-PFC16 own App Group, widget, Live Activity, and external-surface storage
  boundaries.
- PFC24-PFC25 own privacy labels, privacy manifests, data controls, export,
  import, delete, and retention truth.
- Future schema changes must add migration tests before changing durable model
  shape or portable snapshot shape.

## Hard Red Review

No Hard Red occurred. No data-loss risk was introduced because no schema or
store behavior changed. The focused tests passed, and unsupported sync/release
claims were not made.

## Rollback Path

Revert the PFC07 commit to remove the docs-only prompt, audit report, and train
state updates. No production Swift, schema, test, generated project, workflow,
dependency, or signing rollback is needed because none were changed.

## Next Eligible Batch

PFC08 Corruption Recovery / Backup / Restore Plan.
