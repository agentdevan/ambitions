# Persistence Authority Classification

Status: AMB-1717 Implemented Yellow

Snapshot date: 2026-07-02

Repo state inspected: `6382ad1d50444351212dcb4460b0e436a63398fd` on `main`

Scope: AMB-1667 -> AMB-1717 only. This audit classifies current
`Native/Ambitions/Core/Persistence` files and related canonical storage /
continuity files by actual role. It does not move source, delete source,
change Swift behavior, prove direct-save rejection, prove migration safety, or
claim persistence Green.

Evidence class: Implemented Yellow. The tables below are current source
inventory and classification evidence only. They do not prove runtime
correctness, data-loss safety, device behavior, accessibility behavior,
privacy/legal approval, TestFlight readiness, App Store readiness, CloudKit
readiness, or total LocalRuntimeOS completion.

AMB-1718 follow-up map: `docs/audits/persistence-storage-owner-map.md`
defines the canonical LocalRuntimeOS storage owner map and the dumb SwiftData
model boundary. That map satisfies P-MAP at Implemented Yellow only; it does
not prove direct-save rejection or migration safety.

AMB-1719 follow-up proof: `docs/audits/persistence-direct-save-rejection-proof.md`
classifies direct model-save and direct persistence-write markers. It satisfies
P-REJECT at Implemented Yellow only by linking unsafe rows to repair work; it
does not prove broad runtime rejection, migration safety, or persistence Green.

AMB-1720 follow-up plan: `docs/audits/persistence-existing-data-migration-proof-plan.md`
defines the existing-data migration fixture matrix, replay expectations,
failure modes, proof gates, and residual Yellow gaps. It satisfies P-MIGRATE at
Implemented Yellow only; it does not prove executable migration safety.

## Canonical Constraints

Runtime mutation law remains:

```text
Command -> Event -> Projection -> Receipt -> Replay
```

Remediation direction remains:

```text
law over lore
deep runtime, boring UI
delete before naming
Green requires linked evidence
proof automation outranks prose
```

Persistence must become storage substrate for events, projections, caches,
migrations, and continuity. It must not own business decisions, planning,
trust, reflow, Source Atlas policy, product policy, or private life graph
sync authority.

Persistent surfaces remain Today / Goals / Time / You. Capture remains the
global composer. Motion remains behavior under Stage/Motion. R2 and Source
Atlas remain public/reference/freshness infrastructure only; they are not a
private life graph backend.

## Evidence Commands

- `git status --short --branch`
- `git rev-parse HEAD`
- `git ls-remote origin refs/heads/main`
- `find Native/Ambitions/Core/Persistence -maxdepth 3 -type f -name '*.swift' | sort`
- `find Native/Ambitions/Core/LocalRuntimeOS/Storage -maxdepth 3 -type f -name '*.swift' | sort`
- `find Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity -maxdepth 2 -type f -name '*.swift' | sort`
- `wc -l Native/Ambitions/Core/Persistence/*.swift Native/Ambitions/Core/LocalRuntimeOS/Storage/*.swift`
- Static source scan for `SwiftData`, `ModelContext`, `store.write`,
  `context.insert`, `context.delete`, `save`, `fetch`, `CloudKit`, `CK`,
  `Migration`, `Snapshot`, `Cache`, `Repository`, `Store`, `Ledger`,
  `Receipt`, `Event`, `Projection`, `Command`, `SQLite`, and `FTS`.
- Source inspection of `docs/audits/runtime-authority-map.md` AMB-1709 rows.
- Test-source inspection of:
  - `Native/AmbitionsTests/Persistence/CorePersistenceCanonicalOwnershipTests.swift`
  - `Native/AmbitionsTests/LocalRuntimeOS/Storage/StorageTierTests.swift`
  - `Native/AmbitionsTests/LocalRuntimeOS/SyncContinuity/*.swift`

## Classification Summary

| Area | Swift file count | Primary AMB-1717 finding |
| --- | ---: | --- |
| `Core/Persistence` | 34 | Legacy persistence remains a mixed storage, repository, import, diagnostics, and preview support owner. Several files can still support durable writes outside the LocalRuntimeOS mutation law. |
| `Core/LocalRuntimeOS/Storage` | 9 | Canonical storage tier source exists for event, projection, search, object, blob, app-group snapshot, backup, and migration stores. It is storage authority only, not proof every app path consumes it safely. |
| `Core/LocalRuntimeOS/SyncContinuity` | 10 | CloudKit continuity source exists under LocalRuntimeOS with local-authoritative and privacy-gated vocabulary. It is not production CloudKit readiness or private graph sync approval. |

Role legend:

| Role | Meaning |
| --- | --- |
| Event journal storage | Append/query/checksum storage for runtime events or legacy command/snapshot ledgers. |
| Projection storage | Derived projection/search/external snapshot storage. |
| Cache | Local cache, preview/in-memory store, blob store, or diagnostic/export payload support. |
| Migration | Import/export, backup, health, schema, dry-run, rollback, or migration support. |
| CloudKit continuity | Optional continuity metadata/envelope/outbox/zone setup source. |
| Legacy direct mutation | Current or legacy repository/model/service path can create, replace, or persist meaningful Ambitions state outside the LocalRuntimeOS command/event/projection/receipt/replay spine. |

Proof code legend:

| Code | Proof needed before stronger claim |
| --- | --- |
| P-MAP | AMB-1718 canonical owner mapping, including target LocalRuntimeOS owner and SwiftData/model dumb-storage boundary. Implemented Yellow in `docs/audits/persistence-storage-owner-map.md`. |
| P-REJECT | AMB-1719 direct-save proof in `docs/audits/persistence-direct-save-rejection-proof.md`: direct persistence writes fail, are impossible from production roots, or remain explicit unsafe debt. Current result is Implemented Yellow explicit unsafe debt. |
| P-MIGRATE | AMB-1720 migration proof plan in `docs/audits/persistence-existing-data-migration-proof-plan.md`, with fixtures, replay expectations, failure modes, and no migration Green without executable evidence. Implemented Yellow plan only. |
| P-STORAGE | Focused storage tests plus proof that the storage tier is substrate only and not business-decision authority. |
| P-CLOUDKIT | SyncContinuity tests plus privacy/no-private-graph evidence before any CloudKit continuity claim; no production CloudKit claim without release proof. |
| P-DIAGNOSTIC | Proof that diagnostics/health/readers are read-only or review-only and cannot authorize durable repair or mutation. |

Direct-mutation status legend:

| Status | Meaning |
| --- | --- |
| Unsafe direct mutation | Source can persist meaningful Ambitions state outside a proven command/event/receipt path. |
| Contract enables unsafe mutation | File defines legacy save/append/import contracts used by unsafe writers; the file may not write directly. |
| Model authority outside canonical owner | SwiftData record declarations remain under legacy `Core/Persistence` and must be treated as storage debt. |
| Canonical storage substrate | Source is under `Core/LocalRuntimeOS/Storage`; it may write storage records but does not authorize product decisions. |
| Read/diagnostic only | Source inspects, reports, or prepares evidence without authorizing durable product mutation. |
| Preview/test cache only | Source stores local preview/test values and is not production mutation proof. |

## Core/Persistence Classification

| Path | Role | Target owner | Proof | Direct-mutation status |
| --- | --- | --- | --- | --- |
| `Native/Ambitions/Core/Persistence/AppPreferencesStore.swift` | Legacy direct mutation | `Core/LocalRuntimeOS/ObjectState` plus `Core/LocalRuntimeOS/Storage/ObjectStoreSwiftData` | P-MAP, P-REJECT | Unsafe direct mutation through `AppStateRepository.saveState`; must be command-receipt gated before Green. |
| `Native/Ambitions/Core/Persistence/DemoSeedPipeline.swift` | Legacy direct mutation | `Quality`/preview fixture support or command-seeded LocalRuntimeOS fixture path | P-MAP, P-REJECT, P-MIGRATE | Unsafe debug/demo seed apply path; useful for fixtures but not production authority proof. |
| `Native/Ambitions/Core/Persistence/LegacyImportService.swift` | Migration | `Core/LocalRuntimeOS/MigrationRepair` | P-MAP, P-MIGRATE | Unsafe migration apply scaffold until import writes are command/event/receipt gated or explicitly blocked. |
| `Native/Ambitions/Core/Persistence/LifeContextPersistence.swift` | Legacy direct mutation | `Core/LocalRuntimeOS/ObjectState` plus `Core/LocalRuntimeOS/Storage/ObjectStoreSwiftData` | P-MAP, P-REJECT | Unsafe direct SwiftData repository path with `store.write` and `context.insert`. |
| `Native/Ambitions/Core/Persistence/PersistedValueDegradation.swift` | Migration | `Core/LocalRuntimeOS/MigrationRepair` | P-MAP, P-MIGRATE | Read/decode degradation helper; no direct write found in AMB-1717 scan. |
| `Native/Ambitions/Core/Persistence/PersistenceContracts+02-AFEPQueryBudgetCatalog.swift` | Legacy direct mutation | Split contracts to `Core/LocalRuntimeOS/ObjectState`, `TrustSystem`, `Projections`, `Commands`, and `Storage` as mapped by AMB-1718 | P-MAP, P-REJECT | Contract enables unsafe mutation through legacy `save`, `append`, and unit-of-work APIs. |
| `Native/Ambitions/Core/Persistence/PersistenceContracts+03-UnavailableReminderRepository.swift` | Legacy direct mutation | Same contract split as `PersistenceContracts+02` | P-MAP, P-REJECT | Contract bundle and unavailable repositories; no product write by itself, but keeps legacy repository surface active. |
| `Native/Ambitions/Core/Persistence/PersistenceContracts.swift` | Migration | `Core/Domain`, `Core/LocalRuntimeOS/ObjectState`, `TrustSystem`, and `MigrationRepair` according to record family | P-MAP, P-MIGRATE | Persisted data contracts outside canonical storage owner; no direct write found in this file. |
| `Native/Ambitions/Core/Persistence/PortableSnapshotContracts.swift` | Migration | `Core/LocalRuntimeOS/MigrationRepair` and `Core/LocalRuntimeOS/Storage/BackupStore` | P-MAP, P-MIGRATE | Snapshot contract only; no direct write found. |
| `Native/Ambitions/Core/Persistence/PortableSnapshotContracts+02-PortableAppSnapshot.swift` | Migration | `Core/LocalRuntimeOS/MigrationRepair` and `Core/LocalRuntimeOS/Storage/BackupStore` | P-MAP, P-MIGRATE | Snapshot/import report contract only; no direct write found. |
| `Native/Ambitions/Core/Persistence/PortableSnapshotContracts+03-PortableStoredGoalFeedbackEvent.swift` | Migration | `Core/LocalRuntimeOS/MigrationRepair` and `TrustSystem` | P-MAP, P-MIGRATE | Portable stored feedback/receipt contract only; no direct write found. |
| `Native/Ambitions/Core/Persistence/PortableSnapshotService.swift` | Migration | `Core/LocalRuntimeOS/MigrationRepair` and `Core/LocalRuntimeOS/Storage/BackupStore` | P-MAP, P-MIGRATE | Service protocol/facade; import implementation remains unsafe in split extension file. |
| `Native/Ambitions/Core/Persistence/PortableSnapshotService+02-PortableSnapshotService.swift` | Legacy direct mutation | `Core/LocalRuntimeOS/MigrationRepair`, `BackupStore`, `ObjectState`, and `TrustSystem` | P-MAP, P-REJECT, P-MIGRATE | Unsafe import/replace/merge apply path saves through legacy repositories. |
| `Native/Ambitions/Core/Persistence/PortableSnapshotService+02-PortableSnapshotService+03-referenceWarnings.swift` | Migration | `Core/LocalRuntimeOS/MigrationRepair` | P-MAP, P-MIGRATE | Reference warning/read helper; no direct write found. |
| `Native/Ambitions/Core/Persistence/PreviewCaptureRepository.swift` | Cache | Test/preview support or `Core/LocalRuntimeOS/CaptureRouteGraph` fixture boundary | P-MAP, P-REJECT | Preview/test cache only; not production mutation proof. |
| `Native/Ambitions/Core/Persistence/StoragePackageBoundaryModels.swift` | CloudKit continuity | `Diagnostics`/`Quality` boundary reporting, with SyncContinuity references under `Core/LocalRuntimeOS/SyncContinuity` | P-MAP, P-CLOUDKIT | Read/diagnostic boundary model; no direct write found, but stale package-boundary vocabulary cannot become source authority. |
| `Native/Ambitions/Core/Persistence/StoreHealthCheck.swift` | Migration | `Core/LocalRuntimeOS/MigrationRepair` and `Diagnostics` | P-MAP, P-DIAGNOSTIC, P-MIGRATE | Diagnostic write probe uses `store.write`; not product mutation authority and must remain review/health scoped. |
| `Native/Ambitions/Core/Persistence/SupportDiagnosticsBundle.swift` | Cache | `Diagnostics` plus `PrivacySecurity` for redaction/export limits | P-MAP, P-DIAGNOSTIC | Read/diagnostic export payload support; no direct product write found. |
| `Native/Ambitions/Core/Persistence/SwiftDataModels.swift` | Legacy direct mutation | `Core/LocalRuntimeOS/Storage/ObjectStoreSwiftData` plus family owners in AMB-1718 | P-MAP, P-REJECT | Model authority outside canonical owner for private graph records. |
| `Native/Ambitions/Core/Persistence/SwiftDataModels+02-CaptureRecord.swift` | Legacy direct mutation | `ObjectStoreSwiftData`, `CaptureRouteGraph`, `TrustSystem`, and `Commands` by record family | P-MAP, P-REJECT | Model authority outside canonical owner for captures, commands, side effects, and receipt-related records. |
| `Native/Ambitions/Core/Persistence/SwiftDataModels+03-EntityRevisionTombstoneRecord.swift` | Legacy direct mutation | `ObjectStoreSwiftData`, `TrustSystem`, `SyncContinuity`, and `MigrationRepair` by record family | P-MAP, P-REJECT, P-MIGRATE | Model authority outside canonical owner for tombstones, proof/source/history, and sync-adjacent records. |
| `Native/Ambitions/Core/Persistence/SwiftDataModels+04-AmbitionGraphProjectionRecordModel.swift` | Projection storage | `Core/LocalRuntimeOS/Projections` and `Core/LocalRuntimeOS/Storage/ProjectionStoreSQLite` | P-MAP, P-REJECT, P-STORAGE | Legacy SwiftData projection-record model outside canonical projection storage. |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories.swift` | Legacy direct mutation | `ObjectStoreSwiftData` and family-specific LocalRuntimeOS owners | P-MAP, P-REJECT | Legacy repository helper surface outside canonical storage owner. |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+02-RepositoryMapping.swift` | Legacy direct mutation | `ObjectStoreSwiftData` mapping boundary only | P-MAP, P-REJECT | Mapping namespace enables legacy repository writes. |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+02-RepositoryMapping+02-persisted.swift` | Legacy direct mutation | `ObjectStoreSwiftData` mapping boundary only | P-MAP, P-REJECT | Mapping helper for persisted goal/draft records outside canonical owner. |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+02-RepositoryMapping+03-feedbackRecord.swift` | Legacy direct mutation | `ObjectStoreSwiftData` plus `TrustSystem` for feedback/proof/receipt families | P-MAP, P-REJECT | Mapping helper for feedback/event-style records outside canonical owner. |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+02-RepositoryMapping+04-apply.swift` | Legacy direct mutation | `ObjectStoreSwiftData` mapping boundary only | P-MAP, P-REJECT | Apply helper used by legacy repository writes. |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+02-RepositoryMapping+05-entityRevisionTombstone.swift` | Legacy direct mutation | `ObjectStoreSwiftData`, `TrustSystem`, and `MigrationRepair` by tombstone family | P-MAP, P-REJECT, P-MIGRATE | Tombstone mapping helper outside canonical owner. |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+03-Array.swift` | Legacy direct mutation | `ObjectStoreSwiftData`, `Commands`, and `CaptureRouteGraph` by unit-of-work family | P-MAP, P-REJECT | Unsafe repository/unit-of-work path with `store.write` and `context.delete`. |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+04-SwiftDataGoalPersistence.swift` | Legacy direct mutation | `ObjectStoreSwiftData`, `PlanningEngine`, `TrustSystem`, and `CaptureRouteGraph` by record family | P-MAP, P-REJECT | Unsafe SwiftData goal/draft/evidence/feedback/capture writes with `ModelContext` insert/delete. |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+05-SwiftDataAmbitionGraphProjectionRecordRepository.swift` | Projection storage | `Projections`, `ProjectionStoreSQLite`, and `Commands` for command execution records | P-MAP, P-REJECT, P-STORAGE | Unsafe legacy projection/command record repository writes through SwiftData. |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+06-SwiftDataAppStateRepository.swift` | Legacy direct mutation | `Core/LocalRuntimeOS/ObjectState/AppStateStore` plus `ObjectStoreSwiftData` | P-MAP, P-REJECT | Unsafe app-state direct save path unless called through sanctioned command context. |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+07-SwiftDataRuntimeSnapshotLedgerRepository.swift` | Event journal storage | `EventJournal`, `TrustSystem`, `Commands`, and `ObjectStoreSwiftData` by ledger family | P-MAP, P-REJECT, P-STORAGE | Unsafe legacy command/snapshot ledger writes through SwiftData; not canonical event journal proof. |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+08-SwiftDataReminderRepository.swift` | Legacy direct mutation | `SideEffectSystem/EventKitOutbox` plus `ObjectStoreSwiftData` if retained as local object store | P-MAP, P-REJECT | Unsafe reminder repository writes after system-surface flows; adapter proof remains AMB-1668/AMB-1719. AMB-1732 removed the unused `ReminderOutbox` duplicate anchor. |

## Canonical Storage And Continuity Classification

| Path | Role | Target owner | Proof | Direct-mutation status |
| --- | --- | --- | --- | --- |
| `Native/Ambitions/Core/LocalRuntimeOS/Storage/AppGroupSnapshotStore.swift` | Projection storage | Already under `Core/LocalRuntimeOS/Storage` | P-STORAGE | Canonical storage substrate for external snapshots; projection export only, not private graph authority. |
| `Native/Ambitions/Core/LocalRuntimeOS/Storage/BackupStore.swift` | Migration | Already under `Core/LocalRuntimeOS/Storage` | P-STORAGE, P-MIGRATE | Canonical encrypted backup storage; not migration safety Green by itself. |
| `Native/Ambitions/Core/LocalRuntimeOS/Storage/BlobStoreFileSystem.swift` | Cache | Already under `Core/LocalRuntimeOS/Storage` | P-STORAGE | Canonical blob store substrate; not product policy authority. |
| `Native/Ambitions/Core/LocalRuntimeOS/Storage/EventStoreSQLite.swift` | Event journal storage | Already under `Core/LocalRuntimeOS/Storage` | P-STORAGE | Canonical event-store substrate; does not prove every app mutation enters the event journal. |
| `Native/Ambitions/Core/LocalRuntimeOS/Storage/LocalRuntimeStorageCore.swift` | Cache | Already under `Core/LocalRuntimeOS/Storage` | P-STORAGE | Storage manifest/coding/error support; not mutation authority. |
| `Native/Ambitions/Core/LocalRuntimeOS/Storage/MigrationStore.swift` | Migration | Already under `Core/LocalRuntimeOS/Storage` | P-STORAGE, P-MIGRATE | Canonical migration record store; not executable migration Green by itself. |
| `Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftData.swift` | Legacy direct mutation | Already under `Core/LocalRuntimeOS/Storage`; consumes legacy SwiftData record types until AMB-1718/AMB-1719 resolves mapping | P-STORAGE, P-MAP, P-REJECT | Canonical storage substrate, not business-decision authority; must stay behind command/transaction/receipt context. |
| `Native/Ambitions/Core/LocalRuntimeOS/Storage/ProjectionStoreSQLite.swift` | Projection storage | Already under `Core/LocalRuntimeOS/Storage` | P-STORAGE | Canonical projection-store substrate; does not prove all UI reads consume it. |
| `Native/Ambitions/Core/LocalRuntimeOS/Storage/SearchStoreFTS.swift` | Cache | Already under `Core/LocalRuntimeOS/Storage` | P-STORAGE | Canonical search-index substrate fed by projections; not private graph mutation authority. |
| `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/AccountStateMachine.swift` | CloudKit continuity | Already under `Core/LocalRuntimeOS/SyncContinuity` | P-CLOUDKIT | Continuity state helper; no production CloudKit readiness claim. |
| `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/CausalMergeEngine.swift` | CloudKit continuity | Already under `Core/LocalRuntimeOS/SyncContinuity` | P-CLOUDKIT | Merge/conflict vocabulary only; no remote apply Green claim. |
| `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/CloudKitContinuityAdapter.swift` | CloudKit continuity | Already under `Core/LocalRuntimeOS/SyncContinuity` | P-CLOUDKIT | Zone setup/outbox source exists; not private graph sync approval or production CloudKit readiness. |
| `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/ConflictPolicyEngine.swift` | CloudKit continuity | Already under `Core/LocalRuntimeOS/SyncContinuity` | P-CLOUDKIT | Conflict policy source only; no remote apply Green claim. |
| `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/LocalAuthoritativeSyncModel.swift` | CloudKit continuity | Already under `Core/LocalRuntimeOS/SyncContinuity` | P-CLOUDKIT | Local-authoritative model; no private graph backend approval. |
| `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/SignOutDeleteResetCoordinator.swift` | CloudKit continuity | Already under `Core/LocalRuntimeOS/SyncContinuity` | P-CLOUDKIT | Account/reset continuity helper; not data deletion/export release proof. |
| `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/SyncContinuityAuthorityGate.swift` | CloudKit continuity | Already under `Core/LocalRuntimeOS/SyncContinuity` | P-CLOUDKIT | Authority gate source; privacy/legal proof still required for release-facing claims. |
| `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/SyncEligibilityPolicy.swift` | CloudKit continuity | Already under `Core/LocalRuntimeOS/SyncContinuity` | P-CLOUDKIT | Eligibility policy source; no production CloudKit readiness claim. |
| `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/SyncEnvelope.swift` | CloudKit continuity | Already under `Core/LocalRuntimeOS/SyncContinuity` | P-CLOUDKIT | Continuity envelope/source data model; private-sensitive payload denial remains proof-gated. |
| `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/TombstoneSync.swift` | CloudKit continuity | Already under `Core/LocalRuntimeOS/SyncContinuity` | P-CLOUDKIT | Tombstone sync metadata source; no remote private graph apply Green claim. |

## AMB-1717 Findings

- `Core/Persistence` remains mixed authority and must stay Yellow. It contains
  storage contracts, SwiftData model declarations, repository writes, snapshot
  import/apply paths, demo seed writers, health probes, diagnostics payloads,
  and preview support.
- `SwiftDataModels*` are not business-decision code, but their location under
  legacy `Core/Persistence` keeps model authority outside the canonical
  `Core/LocalRuntimeOS/Storage/ObjectStoreSwiftData` owner. AMB-1718 maps the
  family owners, and AMB-1719 records the current direct-save result as
  explicit unsafe Yellow debt rather than rejection Green.
- `SwiftDataRepositories*`, `LifeContextPersistence`, `AppPreferencesStore`,
  `PortableSnapshotService+02-PortableSnapshotService.swift`,
  `LegacyImportService`, and `DemoSeedPipeline` remain direct or effective
  legacy write surfaces.
- `docs/audits/persistence-existing-data-migration-proof-plan.md` now defines
  the AMB-1720 fixture matrix and proof gates for those import/restore paths,
  but the plan is not executable migration safety proof.
- `Core/LocalRuntimeOS/Storage` is the canonical storage owner, but its source
  presence does not prove every production app path consumes only the
  canonical storage tier.
- `SyncContinuity` is the CloudKit continuity owner. Current source does not
  prove approved private graph sync, production CloudKit behavior, privacy/legal
  approval, or release readiness.

## Validation Run

- `python3 scripts/ambitions-remediation-governance-check.py`
  - Result: passed with `changed_paths=2`.
- `python3 scripts/ambitions-legacy-runtime-production-use-guard.py --json`
  - Result: passed with `valid: true`, `baselineLegacyRuntimeFiles: 111`,
    `currentLegacyRuntimeFiles: 111`, `legacyRuntimeFileCeiling: 111`,
    `findingCount: 0`.
- `python3 scripts/ambitions-runtime-direct-write-audit.py --self-test`
  - Result: passed.
- `python3 scripts/ambitions-runtime-direct-write-audit.py --json`
  - Result: passed with `findingCount: 0`, `proofStatus: Implemented Yellow`,
    and existing direct-write classification counts of `unsafe write: 19`,
    `canonical command: 25`, `adapter into command: 2`,
    `projection-only read: 2`, and `unknown: 1`.
- `python3 scripts/ambitions-unsupported-claim-scan.py`
  - Result: passed.
- `git diff --check`
  - Result: passed.
- Read-only coverage scanner against this audit:
  - Result: `missing_count=0` for `Core/Persistence`,
    `Core/LocalRuntimeOS/Storage`, and `Core/LocalRuntimeOS/SyncContinuity`.

## Validation Not Run

- `xcodegen generate` was not run; AMB-1717 changed docs only and did not touch
  `project.yml` or Swift source.
- Xcode build and focused simulator tests were not run; AMB-1717 is static
  classification/governance only.
- Full test suite was not run.
- Device tests were not run.
- UI, accessibility, performance, privacy/legal, TestFlight, App Store,
  CloudKit production, or release-readiness validation were not run.
- No persistence safety, migration safety, direct-save rejection, CloudKit,
  release, device, or runtime Green claim is made.

## Closeout Boundary

- Final Architecture Tree inspected: yes, through
  `docs/truth/PRODUCT_DESIGN_TRUTH.md`.
- Canonical owners touched: `docs/audits` only.
- Swift owners touched: none.
- Files moved or created in Swift source: none.
- Old/non-canonical source paths removed: none.
- Compatibility shims left behind: none added by this slice.
- Yellow architecture debt remains: yes. Legacy persistence files remain under
  `Core/Persistence`, and several write-capable repository/import/seed paths
  remain outside proven command/event/projection/receipt/replay authority.
- Next repair train: AMB-1667 parent closeout at Accepted Yellow, then
  AMB-1668 external adapter leaves before broader source migration parents.
- No equivalent folder/path interpretation was used.
- No Green runtime authority, persistence safety, migration safety, CloudKit,
  device, release, or product-completion claim is made.
