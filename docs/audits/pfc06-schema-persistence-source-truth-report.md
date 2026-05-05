# PFC06 Schema And Persistence Source Truth Report
<!-- markdownlint-disable MD013 -->

Result: Green
Date: 2026-05-05
Train: PFC01-PFC40 Platform / Framework / Compliance Completion Train
Batch: PFC06 Schema And Persistence Source Truth
Owner: Persistence

## Summary

PFC06 completed a docs-only source-truth pass over Ambitions persistence. The
current repo has a local SwiftData store, repository layer, portable
export/import package, legacy import bridge, app preferences store, and an
explicit local-only sync capability. No production Swift, schema, migration,
project, workflow, dependency, signing, entitlement, privacy manifest, lockfile,
test, generated, sync, CloudKit, account, or release file was edited.

PFC06 does not claim export/import UI completion, delete-all-memory UI
completion, CloudKit sync, account sync, production migration readiness,
physical-device proof, legal/privacy compliance, App Store readiness, TestFlight
readiness, or public accessibility conformance.

## Files Inspected

- `Native/Ambitions/Persistence/SwiftDataModels.swift`
- `Native/Ambitions/Persistence/SwiftDataStore.swift`
- `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
- `Native/Ambitions/Persistence/PersistenceContracts.swift`
- `Native/Ambitions/Persistence/PortableSnapshotContracts.swift`
- `Native/Ambitions/Persistence/PortableSnapshotService.swift`
- `Native/Ambitions/Persistence/LegacyImportService.swift`
- `Native/Ambitions/Persistence/AppPreferencesStore.swift`
- `Native/Ambitions/Persistence/SyncCapabilityContracts.swift`
- `Native/Ambitions/ExternalSnapshots/**`
- `Native/AmbitionsTests/Persistence/LegacyImportServiceTests.swift`
- `Native/AmbitionsTests/Persistence/PortableSnapshotServiceTests.swift`
- `Native/AmbitionsTests/Persistence/CaptureServiceTests.swift`
- `Native/AmbitionsTests/Persistence/PersistenceRepositoryTests.swift`
- `Native/AmbitionsTests/Persistence/EventLedgerRepositoryTests.swift`
- `Native/AmbitionsTests/Persistence/SyncCapabilityTests.swift`
- `docs/canon/DATA_LOCAL_SYNC_EXPORT.md`
- `docs/canon/TRUST_PRIVACY_MEMORY.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Files Changed

- `docs/codex/batches/PFC06_Schema_And_Persistence_Source_Truth_Prompt.md`
- `docs/audits/pfc06-schema-persistence-source-truth-report.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Current Schema Map

SwiftData model ownership is centered in
`Native/Ambitions/Persistence/SwiftDataModels.swift` and the active schema is
assembled by `AmbitionsPersistenceStore.schema` in
`Native/Ambitions/Persistence/SwiftDataStore.swift`.

Current SwiftData records:

- `GoalRecord`
- `GoalDraftRecord`
- `GoalPlanRecord`
- `PlanSectionRecord`
- `StepRecord`
- `ProgressEvidenceRecord`
- `FeedbackEventRecord`
- `CaptureRecord`
- `TeachingSignalRecord`
- `EventLedgerRecord`
- `AppStateRecord`

Store construction:

- `AmbitionsPersistenceStore` owns `ModelContainer` creation.
- `ModelConfiguration(isStoredInMemoryOnly:)` supports in-memory tests and local
  persisted runtime storage.
- `read` and `write` create isolated `ModelContext` instances with autosave
  disabled.
- `resetAllData()` deletes all known SwiftData record types in an explicit
  order.

Repository contracts:

- `GoalRepository`
- `GoalDraftRepository`
- `ProgressEvidenceRepository`
- `FeedbackEventRepository`
- `CaptureRepository`
- `GoalTeachingSignalRepository`
- `EventLedgerRepository`
- `AppStateRepository`

Repository implementations:

- `SwiftDataGoalRepository`
- `SwiftDataGoalDraftRepository`
- `SwiftDataProgressEvidenceRepository`
- `SwiftDataFeedbackEventRepository`
- `SwiftDataCaptureRepository`
- `SwiftDataGoalTeachingSignalRepository`
- `SwiftDataEventLedgerRepository`
- `SwiftDataAppStateRepository`

## Persistence Ownership

`Native/Ambitions/Persistence/PersistenceContracts.swift` owns the repository
protocols, `PersistedGoalDraft`, `AppStateSnapshot`, legacy import DTOs, and
`AppRepositories`.

`Native/Ambitions/Persistence/SwiftDataRepositories.swift` owns mapping between
SwiftData records and domain objects. This is the primary future edit surface
for repository behavior, but PFC06 keeps it inspect-only.

`Native/Ambitions/Persistence/AppPreferencesStore.swift` owns preference loading
and saving through `AppStateRepository`. It persists `preferredTab`,
`userDisplayName`, `appearancePreference`, and `accentFamily` as local app
state.

## Export / Import Posture

`Native/Ambitions/Persistence/PortableSnapshotContracts.swift` defines
`PortableAppSnapshot` and `PortableExportManifest`.

Portable export categories are:

- Goals and plans
- Captures
- Proof
- Receipts and history
- Memory
- Settings

The manifest explicitly excludes:

- Raw calendar events
- Cloud sync or account data
- Rendered widget or Live Activity state

`Native/Ambitions/Persistence/PortableSnapshotService.swift` owns service-level
export/import behavior. Test evidence in
`Native/AmbitionsTests/Persistence/PortableSnapshotServiceTests.swift` covers
current repository export, user-selected categories, replace-local-store import,
merge-with-conflict-report import, unsupported schema rejection, manifest warning
surfacing, malformed package handling, and legacy pre-manifest package handling.

This is service-level evidence, not user-facing You / Trust Center export/import
UI completion.

## Sync Posture

`Native/Ambitions/Persistence/SyncCapabilityContracts.swift` defines only:

- `SyncBackendKind.localOnly`
- `SyncCapabilityAvailability.unavailable`
- `LocalOnlySyncCapability`

`Native/AmbitionsTests/Persistence/SyncCapabilityTests.swift` verifies the
current runtime posture as explicit local-only mode. PFC06 therefore records
CloudKit/account/server sync as not implemented and not claimed.

## Sensitive Data And Privacy Categories

The portable snapshot manifest classifies the following categories as containing
sensitive user text:

- Goals and plans
- Captures
- Proof
- Receipts and history
- Memory

Settings are not classified as sensitive user text in the current manifest, but
they still include personal preferences such as display name, selected tab,
appearance preference, accent family, onboarding/import metadata, and goal
priority order. Future privacy work must review preference previews and export
copy before making public privacy or release claims.

`docs/canon/DATA_LOCAL_SYNC_EXPORT.md` remains the controlling canon for
local-first behavior, no launch account, no launch sync, export-before-cloud
sync, delete-all-memory scope, and no-claim boundaries.

## Migration Risk Ledger

| Risk | Severity | Owner | Future Treatment |
| --- | --- | --- | --- |
| No explicit production migration ladder is documented in code. | Yellow | PFC07 | Add migration fixtures/tests or document why current local-only schema boundary is safe. |
| `PortableAppSnapshotSchemaVersion.v1` exists, but future schema changes need compatibility proof. | Yellow | PFC07 | Add versioned payload survival tests before changing portable snapshot shape. |
| `resetAllData()` is broad and deletes all SwiftData records; product delete-all-memory must remain memory-only. | Yellow | PFC08 / PFC25 | Keep reset as technical store reset only; define user-facing destructive actions separately. |
| Export/import has service-level proof but no completed You / Trust Center UI proof in this batch. | Yellow | PFC25 / FCP / You owner | Build visible export/import surfaces only in a scoped future batch with review copy and tests. |
| Sync is explicit local-only/unavailable; CloudKit/account/server sync is not implemented. | Green current / Yellow future | PFC09-PFC11 | Decide sync strategy before any CloudKit or server-backed implementation. |
| App Group shared storage and external snapshots are separate from primary persistence. | Yellow | PFC12-PFC16 | Map exactly what widgets, Live Activities, share extension, and App Intents may read or expose. |
| Sensitive text can exist in goals, captures, proof, receipts, and memory package categories. | Yellow | PFC24-PFC25 / Privacy | Maintain redaction, preview safety, and user review before export, widgets, notifications, or external surfaces. |
| Legacy import DTOs preserve history vocabulary, including old goal/task statuses. | Yellow | PFC07 / Copy-boundary owners | Preserve compatibility internally; prevent legacy vocabulary from leaking into user-facing copy. |

## Product And Platform Decisions Preserved

- Ambitions remains local-first.
- No account is required at launch.
- Sync remains not implemented and not claimed.
- Export/import exists at service/package level only.
- Data controls remain You / Trust-owned.
- Proof remains evidence, not achievement.
- Receipts remain consequence/reversibility, not notification feed posture.
- Source/privacy language remains review/control oriented.
- Internal compatibility vocabulary may remain when required for migration or
  legacy data interpretation.

## Caveats Preserved

- No production schema edit was made.
- No migration test was added by PFC06.
- No export/import UI claim was made.
- No delete-all-memory UI claim was made.
- No CloudKit, account, server, external-service, sync, or network claim was
  made.
- No legal/privacy/App Store/TestFlight/release/device/public accessibility
  claim was made.

## Validation Commands Run

- `git status --short`
- `git diff --check`
- touched-doc trailing whitespace scan
- `scripts/cqs-privacy-security-claim-scan.sh docs/codex/batches/PFC06_Schema_And_Persistence_Source_Truth_Prompt.md docs/audits/pfc06-schema-persistence-source-truth-report.md || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Validation Results

- `git diff --check`: PASS.
- Touched-doc trailing whitespace: PASS.
- CQS privacy/security claim scan: PASS with zero hits for the PFC06 prompt
  scan root.
- `scripts/run-doc-qa.sh || true`: PASS with accepted Yellow advisory backlog.
  Lychee reported 650 OK and 0 errors. Markdownlint and deprecated-language
  findings are repo-wide known backlog and were not introduced as production
  source changes by PFC06.
- `scripts/batch-train-gate-check.sh || true`: PASS with expected dirty-tree
  Yellow hint before commit.

## Result Classification

Green. PFC06 produced docs-only persistence source truth and a migration risk
ledger. All implementation risks are owned by future PFC batches and no Hard Red
was found.

## Rollback Path

Revert the PFC06 commit to remove the docs-only prompt, audit report, and train
state updates. No production Swift, schema, migration, workflow, dependency, or
generated file rollback is needed because none were changed.

## Next Eligible Batch

PFC07 Migration Ladder And Backward Compatibility Tests.
