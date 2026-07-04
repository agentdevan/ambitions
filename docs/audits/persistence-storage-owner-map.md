# Persistence Storage Owner Map

Status: AMB-1718 Implemented Yellow

Snapshot date: 2026-07-02

Baseline repo state inspected before this artifact:
`9b16579a31839f92a0820f030784c3869a6a97ef` on `main`

Scope: AMB-1667 -> AMB-1718 only. This map defines which current storage
interfaces remain canonical, where they belong under LocalRuntimeOS storage
ownership, and which runtime owner is allowed to decide meaningful state. It
does not move Swift source, delete legacy persistence source, prove direct-save
rejection, prove migration safety, prove CloudKit production readiness, or
claim persistence Green.

Evidence class: Implemented Yellow. The current source contains canonical
storage tier files and storage tests, but `Core/Persistence` still contains
legacy repository, model, import, preview, diagnostic, and direct-write
scaffolding. AMB-1719 now classifies direct-save/direct-write proof as
Implemented Yellow explicit unsafe debt, so stronger mutation authority claims
remain blocked. AMB-1720 now defines the existing-data migration fixture and
replay proof plan in
`docs/audits/persistence-existing-data-migration-proof-plan.md`; that plan is
Implemented Yellow and does not prove migration safety Green.

## Canonical Constraints

Runtime mutation law remains:

```text
Command -> Event -> Projection -> Receipt -> Replay
```

Architecture simplification direction remains:

```text
law over lore
deep runtime, boring UI
delete before naming
Green requires linked evidence
proof automation outranks prose
```

Storage is substrate. Storage may persist events, projections, indexes, object
snapshots, redacted external snapshots, blobs, backups, and migration records.
Storage must not decide planning, trust, reflow, Source Atlas policy, privacy
egress, side effects, migration execution, repair execution, product copy, or
user-facing recommendation behavior.

SwiftData and model types are dumb storage. They may hold stable identifiers,
query columns, raw enum strings, timestamps, schema versions, checksums,
encoded typed payloads, receipt references, lineage references, and fallback
snapshots. They must not own business decisions.

Persistent surfaces remain Today / Goals / Time / You. Capture remains the
global composer. Motion remains behavior under Stage/Motion. R2 and Source
Atlas remain public/reference/freshness infrastructure only and are not private
life graph storage.

## Evidence Inspected

- `docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/audits/persistence-authority-classification.md`
- `docs/audits/runtime-authority-map.md`
- `Native/Ambitions/Core/LocalRuntimeOS/Storage/*.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/ObjectState/*.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/*.swift`
- `Native/Ambitions/Core/Persistence/*.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/Storage/StorageTierTests.swift`
- `Native/AmbitionsTests/Persistence/CorePersistenceCanonicalOwnershipTests.swift`
- `Native/AmbitionsTests/Persistence/StoragePackageBoundaryModelsTests.swift`

## Proof Codes

| Code | Meaning |
| --- | --- |
| P-MAP | This AMB-1718 owner map. |
| P-STORAGE | Existing focused storage/source tests for canonical storage tier shape and substrate behavior. |
| P-REJECT | AMB-1719 direct-save proof in `docs/audits/persistence-direct-save-rejection-proof.md`: direct persistence writes fail, are unreachable from production roots, or remain explicit unsafe debt. Current result is Implemented Yellow explicit unsafe debt. |
| P-MIGRATE | AMB-1720 existing-data migration proof plan in `docs/audits/persistence-existing-data-migration-proof-plan.md`, followed by later executable migration proof before any migration Green claim. |
| P-CLOUDKIT | SyncContinuity privacy/local-authority evidence before any CloudKit continuity claim. |
| P-DIAGNOSTIC | Proof that diagnostics/health/readers cannot authorize durable mutation or repair. |

## Canonical Storage Tier Map

| Interface | Storage role | Canonical owner | Runtime decision owner | Allowed stored data | Forbidden authority / proof ceiling |
| --- | --- | --- | --- | --- | --- |
| `LocalRuntimeStorageCore.swift` | Tier manifest, SQLite helper, checksum, coding, storage errors | `Core/LocalRuntimeOS/Storage` | None; support code only | Tier descriptors, privacy scopes, schema version, checksums | No mutation authority, no product policy, no storage Green by itself. P-STORAGE only. |
| `EventStoreSQLite.swift` | Event journal storage | `Core/LocalRuntimeOS/Storage` with `EventJournal` consumption | `Commands`, `Transactions`, `EventJournal` | Runtime event envelopes, append order, event checksum chain, causal cursors | Does not prove every app mutation enters the journal. AMB-1719 records bypass/direct-write rows as Yellow debt. |
| `ObjectStoreSwiftData.swift` | SwiftData object store substrate | `Core/LocalRuntimeOS/Storage` | Family-specific owners listed below, always through command/transaction/receipt context | App-facing object records, repository-mapped snapshots, bounded object queries | SwiftData is not business-decision authority and is not the canonical mutation backend. Direct writes remain Yellow after AMB-1719. |
| `ProjectionStoreSQLite.swift` | Projection storage | `Core/LocalRuntimeOS/Storage` with `Projections` consumption | `Projections` after event-fed materialization | Materialized projection payloads, cursors, projection checksums | Does not prove all UI/widget/App Intent reads consume this store. No product or UI Green. |
| `SearchStoreFTS.swift` | Search index storage/cache | `Core/LocalRuntimeOS/Storage` with `SearchRecall` consumption | `SearchRecall` and `Projections` rebuild pipeline | Local FTS rows, provenance, privacy-filtered index rows, rebuild cursor | No semantic cloud search, no private graph egress, no domain mutation. |
| `BlobStoreFileSystem.swift` | Blob/cache storage | `Core/LocalRuntimeOS/Storage` | `CaptureRouteGraph`, `TrustSystem`, `PrivacySecurity` when scoped | Attachment/proof blobs, checksums, content type, file-protection class records | No queryable domain authority, no event ordering, no migration approval. |
| `AppGroupSnapshotStore.swift` | Redacted external projection snapshot storage | `Core/LocalRuntimeOS/Storage` with `Projections` and `PrivacySecurity` boundaries | `Projections`, `PrivacySecurity`, `ExternalWrites` adapters | Sanitized widget/share/App Intent snapshots | No full private graph access, no extension-side mutation, no private text exposure, no external-surface Green. |
| `BackupStore.swift` | Backup package storage | `Core/LocalRuntimeOS/Storage` with `MigrationRepair` consumption | `MigrationRepair` plus `PrivacySecurity` review gates | Encrypted backup packages, backup manifests, backup checksums | No migration execution, no CloudKit authority, no public-reference pack authority, no data-safety Green. |
| `MigrationStore.swift` | Migration record storage | `Core/LocalRuntimeOS/Storage` with `MigrationRepair` consumption | `MigrationRepair` dry-run/review flows | Dry-run receipts, invariant summaries, rollback references | No destructive migration execution without proof gates. AMB-1720 owns migration proof planning. |

`Core/LocalRuntimeOS/SyncContinuity` is not a storage tier. It is the
continuity owner for optional CloudKit/account continuity metadata, envelopes,
eligibility, conflict policy, tombstone limits, and local-authoritative sync
gates. It remains P-CLOUDKIT Yellow and must not be described as approved
private graph sync or production CloudKit readiness.

## SwiftData Object Family Map

These families are object-store records only. The listed owners can decide
state only when the command/event/projection/receipt/replay law is present for
the scoped mutation.

| Object-store family | Stored model types | Runtime owner allowed to decide state | Dumb-storage rule | Current proof ceiling |
| --- | --- | --- | --- | --- |
| `goalThread` | `GoalRecord` | `Commands`, `Transactions`, `EventJournal`; planning policy remains under `PlanningEngine` when scoped | Store IDs, lifecycle columns, encoded planning/progress payloads, fallback goal snapshot | Legacy goal repository writes remain Yellow until P-REJECT. |
| `goalDraft` | `GoalDraftRecord` | `CaptureRouteGraph`, `Transactions` | Store draft identity, promotion lookup, fallback draft payload | Capture/draft writes must be command-receipt gated before Green. |
| `goalPlan` | `GoalPlanRecord`, `PlanSectionRecord` | `PlanningEngine`, `Transactions` | Store plan lookup/order columns and encoded assumptions/strategy payloads | No full pathing or planning Green from records alone. |
| `step` | `StepRecord` | `PlanningEngine`, `Scheduling`, `Transactions` | Store goal-scoped step lookup, lifecycle columns, dependency/actionability payloads | No Step, reflow, or Time behavior Green from records alone. |
| `capture` | `CaptureRecord` | `CaptureRouteGraph`, `Transactions` | Store capture lookup, linked goal reference, fallback capture payload | No global Capture routing Green from records alone. |
| `proof` | `ProgressEvidenceRecord`, `FeedbackEventRecord`, `AmbitionGraphProofRecordModel` | `TrustSystem`, `EventJournal` | Store proof/feedback lookup columns and proof projection fallback payloads | No proof meaning, trust, or progress-transfer Green from records alone. |
| `receipt` | `ActionReceiptHistoryRecordModel`, `RuntimeSnapshotLedgerRecord` | `TrustSystem`, `Projections` | Store typed receipt payloads, runtime lineage, replay-validation fallback payloads | Receipt storage is not receipt-policy authority. |
| `teachingSignal` | `TeachingSignalRecord` | `PrivateLifeRuntimeKernel` | Store local teaching signal lookup and payload | No learning/recommendation Green from stored signals alone. |
| `eventLedger` | `EventLedgerRecord`, `CommandExecutionRecord` | `Commands`, `EventJournal`, `TrustSystem` | Store trust/history event kind, command payload, command result payload | Legacy SwiftData ledger is not canonical EventJournal proof. |
| `sideEffectLedger` | `SideEffectLedgerStorageRecord` | `ExternalWrites` | Store effect outbox kind and side-effect receipt payload | No app-wide external side-effect outbox Green from records alone. |
| `runtimeSnapshot` | `RuntimeSnapshotLedgerRecord`, `AmbitionGraphProjectionRecordModel`, `AmbitionGraphOperationalRecordModel` | `Projections`, `TrustSystem` | Store projection/read-model fallback payloads | Projection storage does not prove Stage or widget consumption. |
| `lifeContext` | `LifeContextBundleRecord` | `PrivateLifeRuntimeKernel` | Store local life-context bundle lookup and fallback payload | No personalization/recommendation Green from stored context alone. |
| `appState` | `AppStateRecord`, `ReminderRecord` | `Commands`, `ObjectState`; reminders also require `ExternalWrites` when external delivery is scoped | Store canonical surface preference and encoded reminder delivery policy | `AppStateStore` has adapter proof; reminder writes remain Yellow. |

ObjectState source currently marks only `appState` as
`swiftdata_adapter_migrated`. The other object-state families are
`contract_defined` with tracked direct-write debt. This map must not be read
as full ObjectState migration proof.

Stored-model coverage note: `ObjectStoreSwiftData.storedModelNames` also
contains `EntityRevisionTombstoneRecord`. Until a future source train adds an
explicit tombstone object-store family or moves the type fully under
`TrustSystem`, `MigrationRepair`, or `SyncContinuity`, this map treats it as
dumb tombstone lineage storage only. It may store entity kind, object identity,
revision, deletion, sync, and repair metadata; it must not decide undo, sync,
migration, repair, or trust policy.

## Legacy Core/Persistence Owner Map

| Legacy persistence surface | Target owner | Required interpretation | Follow-up |
| --- | --- | --- | --- |
| Repository contracts in `PersistenceContracts+02-AFEPQueryBudgetCatalog.swift` | Split by family into `ObjectState`, `Commands`, `CaptureRouteGraph`, `PlanningEngine`, `Scheduling`, `TrustSystem`, `Projections`, `ExternalWrites`, `MigrationRepair`, and `Storage` | `save`, `append`, `delete`, import, and unit-of-work APIs are legacy adapter contracts, not business-decision authority. | P-REJECT |
| DTO and legacy snapshot records in `PersistenceContracts.swift` | `Core/Domain` for inert value shape, `ObjectState` for current object families, `MigrationRepair` for legacy import records | Value types may remain dumb DTOs. They must not drive current product behavior or prove migration safety. | P-MIGRATE |
| `SwiftDataModels*.swift` | `Storage/ObjectStoreSwiftData` plus the family owners above | `@Model` classes are dumb storage records. Their current `Core/Persistence` location is legacy model-location debt, not authority. | P-REJECT |
| `SwiftDataRepositories*.swift` | `Storage/ObjectStoreSwiftData` adapters behind family owners | Repository implementations may read/write storage, but may not decide planning, trust, reflow, Source Atlas, privacy, side effects, or product policy. | P-REJECT |
| `AppPreferencesStore.swift` | `ObjectState/AppStateStore` plus `Storage/ObjectStoreSwiftData` | App preference state must be command/receipt gated when it becomes meaningful app state. | P-REJECT |
| `LifeContextPersistence.swift` | `PrivateLifeRuntimeKernel`, `ObjectState`, `Storage/ObjectStoreSwiftData` | Life-context storage is local substrate only; it must not silently become learning or recommendation authority. | P-REJECT |
| `PortableSnapshot*`, `LegacyImportService.swift`, `PersistedValueDegradation.swift` | `MigrationRepair`, `BackupStore`, `TrustSystem` where proof/receipt records are involved | Import/export/snapshot code is migration support. It must not execute destructive apply or claim migration Green without proof. | P-MIGRATE |
| `StoreHealthCheck.swift` | `Diagnostics`, `MigrationRepair`, `Storage/ObjectStoreSwiftData` | Health checks and write probes are diagnostics. They must not authorize durable repair or product mutation. | P-DIAGNOSTIC |
| `SupportDiagnosticsBundle.swift`, `StoragePackageBoundaryModels.swift` | `Diagnostics`, `PrivacySecurity`, `Quality` | Diagnostic/export boundary data must stay redacted/review-only and cannot become package-boundary authority. | P-DIAGNOSTIC |
| `PreviewCaptureRepository.swift`, `DemoSeedPipeline.swift` | `Quality`/preview fixtures or command-seeded LocalRuntimeOS fixture paths | Preview/demo data is not production mutation proof. Demo apply paths are unsafe if reachable from production. | P-REJECT |
| Reminder repositories and contracts | `ExternalWrites/EventKitOutbox` plus `Storage/ObjectStoreSwiftData` for local object records | Reminder persistence cannot be external side-effect authority; delivery needs outbox/receipt proof. AMB-1732 removed the unused `ReminderOutbox` duplicate anchor. | AMB-1668 and P-REJECT |

## Business-Decision Ban

Persistence-owned code must not:

- choose a `Recommended step`;
- decide whether a goal, Step, proof item, or reminder fits now;
- reflow Time or move protected time;
- approve a Source Atlas request or R2 request;
- classify private graph data for egress;
- authorize CloudKit continuity;
- enqueue or execute external side effects without `ExternalWrites`;
- approve migration or repair execution;
- generate user-facing closure/trust wording;
- create receipt meaning without `TrustSystem`;
- bypass `Command -> Event -> Projection -> Receipt -> Replay`.

Any `ModelContext.insert`, `ModelContext.delete`, `ModelContext.save`,
`AmbitionsPersistenceStore.write`, repository `save`, repository `append`, or
import/apply path outside a validated runtime mutation context remains Yellow
direct-write debt after AMB-1719 unless a future source/test artifact proves
rejection, quarantine, or explicit unreachability from production roots.

## Acceptance Boundary

AMB-1718 acceptance is satisfied at Implemented Yellow:

- canonical storage interfaces are mapped to `Core/LocalRuntimeOS/Storage`;
- each storage interface has a runtime decision owner or explicit no-decision
  role;
- SwiftData families are documented as dumb object-store records;
- legacy `Core/Persistence` contracts, models, repositories, snapshots,
  diagnostics, preview/demo paths, and reminder persistence are mapped to
  target LocalRuntimeOS owners;
- direct-save proof is recorded as AMB-1719 Implemented Yellow explicit unsafe
  debt, and existing-data migration proof planning is recorded as AMB-1720
  Implemented Yellow in
  `docs/audits/persistence-existing-data-migration-proof-plan.md`.

This work protects the Private Life Orchestration loop by making durable local
state a substrate for intent, context, path, time fit, reflow, action, proof,
and learning instead of allowing persistence to become a competing decision
system.

## Validation Run

- `git diff --check`
  - Result: passed.
- `python3 scripts/ambitions-remediation-governance-check.py`
  - Result: passed with `changed_paths=2`. The guard reported existing
    baseline debt (`suffixSplitFiles=309`, `blockedSuffixSplitFiles=257`,
    `architectureNounFiles=363`, `sourceAtlasFiles=20`,
    `overHardLineCapFiles=3`) and did not upgrade any runtime claim.
- `python3 scripts/ambitions-legacy-runtime-production-use-guard.py --json`
  - Result: passed with `valid: true`, `baselineLegacyRuntimeFiles: 111`,
    `currentLegacyRuntimeFiles: 111`, `legacyRuntimeFileCeiling: 111`, and
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
- AMB-1718 coverage scanner against this artifact:
  - Result: passed with `storage_file_count=9`, `missing_storage_count=0`,
    `stored_model_count=21`, and `missing_model_count=0`.

## Validation Not Run

- `xcodegen generate` was not run; AMB-1718 changed docs only and did not
  touch `project.yml` or Swift source.
- Xcode build and focused simulator tests were not run; AMB-1718 is static
  storage owner mapping/governance only.
- Full test suite was not run.
- Device tests were not run.
- UI, accessibility, performance, privacy/legal, TestFlight, App Store,
  CloudKit production, R2 production, or release-readiness validation were not
  run.
- No direct-save rejection, migration safety, production CloudKit, release,
  device, runtime Green, or storage Green claim is made.

## Closeout Boundary

- Final Architecture Tree inspected: yes, through
  `docs/truth/PRODUCT_DESIGN_TRUTH.md`.
- Canonical owners touched: `docs/audits` only.
- Swift owners touched: none.
- Files moved or created in Swift source: none.
- Old/non-canonical source paths removed: none.
- Compatibility shims left behind: none added by this slice.
- Yellow architecture debt remains: yes. `Core/Persistence` still contains
  legacy direct-write and model-location debt, and only AppState has
  ObjectState SwiftData adapter proof.
- Next repair train: AMB-1667 parent closeout at Accepted Yellow, then
  AMB-1668 external adapter leaves before broader source migration parents.
- No equivalent folder/path interpretation was used.
- No Green runtime authority, storage safety, migration safety, CloudKit,
  device, release, privacy/legal, or product-completion claim is made.
