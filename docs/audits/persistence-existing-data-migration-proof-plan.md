# Existing Data Migration Proof Plan

Status: AMB-1720 Implemented Yellow

Snapshot date: 2026-07-02

Baseline repo state inspected before this artifact:
`43c41b2125b22b4a04f941ba8f53254baf1f8f25` on `main`

Scope: AMB-1667 -> AMB-1720 only. This artifact defines the proof plan for
existing local data affected by persistence authority cleanup. It does not move
Swift source, delete legacy persistence source, run an executable migration,
authorize restore execution, prove migration safety, or claim persistence Green.

Evidence class: Implemented Yellow. The plan is tied to current source and
tests, but no migration safety Green is claimed because fixture-backed replay,
rollback, and data-loss proof is not executable in this slice.

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

Existing local data is private life graph data. Migration, import, restore,
backup, diagnostics, and repair proof must stay local-first, inspectable, and
receipt-backed. R2 and Source Atlas remain public/reference/freshness
infrastructure only; they are not a private life graph backend.

## Evidence Inspected

- `docs/audits/runtime-authority-map.md`
- `docs/audits/persistence-authority-classification.md`
- `docs/audits/persistence-storage-owner-map.md`
- `docs/audits/persistence-direct-save-rejection-proof.md`
- `Native/Ambitions/Core/Persistence/PortableSnapshotService.swift`
- `Native/Ambitions/Core/Persistence/PortableSnapshotService+02-PortableSnapshotService.swift`
- `Native/Ambitions/Core/Persistence/LegacyImportService.swift`
- `Native/Ambitions/Core/Persistence/DemoSeedPipeline.swift`
- `Native/Ambitions/Core/Persistence/PersistedValueDegradation.swift`
- `Native/Ambitions/Core/Persistence/StoreHealthCheck.swift`
- `Native/Ambitions/Core/Persistence/SupportDiagnosticsBundle.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/SchemaLedger.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/MigrationDSL.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/MigrationPlanner.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/DryRunMigration.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/PreMigrationBackup.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/StoreInvariantChecker.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/CorruptionQuarantine.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/RuntimeDoctor.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/RuntimeDoctorRepairOperator.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/RepairPlanEngine.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/RestoreRollback.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/Storage/BackupStore.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/Storage/MigrationStore.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftData.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/MigrationRepair/DryRunMigrationTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/MigrationRepair/RestoreRollbackTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/MigrationRepair/MigrationRepairOwnershipTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/MigrationRepair/StoreInvariantCheckerTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/Storage/StorageTierTests.swift`
- `Native/AmbitionsTests/Persistence/CorePersistenceCanonicalOwnershipTests.swift`

## Current Surface Classification

| Surface | Current evidence | AMB-1720 proof boundary |
| --- | --- | --- |
| Portable snapshot export and dry-run | `PortableSnapshotService` exports v1 snapshots and computes dry-run reports. | Read/dry-run evidence only. It does not prove apply safety. |
| Portable snapshot replace and merge apply | `PortableSnapshotService+02-PortableSnapshotService.swift` resets/saves through legacy repositories for goals, drafts, evidence, feedback, receipts, tombstones, captures, teaching signals, and app state. | Unsafe migration apply debt. Future proof must route apply through command/event/receipt or prove rejection/quarantine. |
| Restore rollback wrapper | `RestoreRollback.swift` lives under LocalRuntimeOS but delegates both import and rollback import to `PortableSnapshotServicing.importSnapshot`. | Effective mutation remains unsafe until the delegate is migrated or executable proof shows safe command/receipt behavior. |
| Legacy prototype import | `LegacyImportService.swift` transforms legacy goal/task/milestone snapshots and saves through repositories. | Migration scaffold only. Future proof must fixture legacy snapshots and preserve reviewable lossy mappings. |
| Demo seed pipeline | `DemoSeedPipeline.swift` writes seeded goals, drafts, evidence, feedback, captures, and app state through repositories. | Useful fixture input, not production mutation proof. Demo seed must not become migration Green evidence by itself. |
| Degradation helpers | `PersistedValueDegradation.swift` and `StoreInvariantChecker.swift` flag bad raw values, malformed payloads, and missing references. | Review/blocker proof only. They do not authorize repair execution. |
| Backup and migration stores | `BackupStore.swift` and `MigrationStore.swift` store encrypted backup packages and dry-run records under LocalRuntimeOS. | Canonical storage substrate only. They do not prove data-loss safety or migration execution. |
| MigrationRepair review pipeline | `SchemaLedger`, `MigrationDSL`, `MigrationPlanner`, `DryRunMigration`, `PreMigrationBackup`, `RuntimeDoctor`, `RepairPlanEngine`, and `RestoreRollback` create plans, backups, dry-runs, receipts, recovery assessments, and review blockers. | Non-executable proof scaffold. Future proof must connect fixture data to command/event/projection/receipt/replay and rollback evidence. |

## Required Fixture Matrix

Future executable migration proof must include durable local fixtures at or
below a test-owned fixture path such as
`Native/AmbitionsTests/LocalRuntimeOS/MigrationRepair/Fixtures`. AMB-1720 does
not create these fixtures; it defines the minimum matrix.

| Fixture ID | Required shape | Required proof |
| --- | --- | --- |
| `migration_fixture_legacy_v0_goal_thread_full` | Legacy prototype goals, milestones, tasks, app state, parent linkage, completed and active steps, lossy recurrence metadata, and reference-only historical UI/session fields. | `LegacyImportService` path is dry-run or command-routed; lossy mappings are receipt-linked; replay rebuilds goal/plan/step projections. |
| `migration_fixture_portable_replace_full` | Portable v1 snapshot with goals, drafts, plan sections, steps, evidence, feedback, action receipt history, entity revision tombstones, captures, teaching signals, and app state. | Replace mode prepares backup, dry-run, reset review, command/event or explicit rejection receipt, projection rebuild, rollback package, and replay trace. |
| `migration_fixture_portable_merge_conflict` | Existing local records plus incoming snapshot collisions, tombstones, duplicate IDs, app-state differences, and feedback bound to steps. | Merge mode reports conflicts, never resurrects tombstoned state without receipt proof, and remains idempotent on replay. |
| `migration_fixture_corrupt_orphan_step` | Orphan `StepRecord`, orphan evidence, orphan capture link, malformed payloads, and missing goal/plan/section references. | `StoreInvariantChecker` blocks backup/import before mutation and produces reviewable blocker evidence. |
| `migration_fixture_unsupported_schema_future` | Future portable snapshot schema and SwiftData version ledger mismatch. | Import is blocked before mutation with unsupported-schema evidence and no partial write. |
| `migration_fixture_backup_checksum_failure` | Backup package with checksum mismatch, missing package record, or wrong encryption key. | Restore is blocked or rollback failure is reported without claiming data-loss safety. |
| `migration_fixture_side_effect_reminder_state` | Reminder/outbox records and app state adjacent to imported goal/step state. | Side-effect delivery is not executed by migration; any reminder carry-forward requires ExternalWrites receipt proof. |
| `migration_fixture_private_data_egress_guard` | Private user text, sensitive captures, local-only receipts, Source Atlas references, and public/reference pack metadata. | Migration stays local; no R2, Source Atlas public pack, CloudKit, or hosted AI egress occurs. |

## Replay Expectations

Executable migration proof cannot stop at import counts. For each fixture above,
the proof must show:

- source ledger and target ledger validation through `SchemaLedgerValidator`;
- migration plan validation through `MigrationPlanValidator`;
- invariant check through `StoreInvariantChecker`;
- pre-migration backup receipt through `PreMigrationBackup`;
- staged dry-run through `DryRunMigration`;
- command/event or explicit rejection receipt for every meaningful state
  mutation;
- projection rebuild after import or repair;
- rollback plan or blocked rollback report through `RestoreRollback`;
- replay trace proving the post-migration projection can be reconstructed from
  the command/event/projection/receipt chain or explicitly remains Yellow;
- idempotency proof by running the same fixture twice without duplicate state,
  tombstone resurrection, or receipt divergence;
- privacy proof that no private graph data leaves local storage.

## Failure Modes To Prove

| Failure mode | Required behavior before Green |
| --- | --- |
| Unsupported snapshot or ledger schema | Block before mutation and emit a reviewable unsupported-schema receipt. |
| Decode degradation or unknown raw values | Block or quarantine with `PersistedValueDegradation` evidence; no silent default that changes meaning. |
| Missing required relationships | Block before backup/import when goal, plan, section, step, evidence, capture, or app-state references are orphaned. |
| Duplicate IDs and merge conflicts | Conflict report is deterministic, local, reviewable, and replay-stable. |
| Tombstone/resurrection conflict | Tombstone lineage wins unless a receipt-backed user review explicitly authorizes restoration. |
| Partial write during import | Rollback restores the backup or reports rollback failure without claiming migration safety. |
| Backup failure or checksum mismatch | Migration execution remains blocked. |
| Side-effect adjacency | Migration never delivers external side effects, notifications, reminders, EventKit writes, CloudKit writes, or network calls. |
| Privacy egress attempt | Migration blocks or redacts locally; no R2, Source Atlas, hosted AI, or CloudKit private graph upload. |
| Destructive reset | Reset remains review-only until a later scoped source train provides explicit user confirmation and receipt proof. |

## Proof Gates

| Gate | Required artifact | Current AMB-1720 state |
| --- | --- | --- |
| Fixture coverage | Fixture files and tests covering the matrix above. | Missing; planned only. |
| Dry-run review | `DryRunMigration` report with mutation execution blocked. | Existing tests cover scaffold behavior, not full data fixtures. |
| Backup receipt | `PreMigrationBackup` receipt plus encrypted `BackupStore` package proof. | Existing tests cover store mechanics, not production migration fixtures. |
| Apply/rejection receipt | Command/event receipt or explicit rejection/quarantine for every apply path. | Missing for legacy import and portable snapshot apply. |
| Projection rebuild | Projection-store output compared after replay. | Missing for existing-data migration fixtures. |
| Rollback | Restore rollback success, blocked-before-import, and rollback-failed evidence for fixture data. | Existing tests cover wrapper behavior; delegate still applies through legacy repositories. |
| Privacy/no egress | Proof that migration cannot send private graph data to R2, Source Atlas, CloudKit, hosted AI, or network. | Missing for migration fixtures. |
| Device durability | Device or simulator persistence run with restart/reopen proof. | Not run in AMB-1720. |

## Residual Yellow Gaps

- Portable snapshot import/replace/merge can still apply through legacy
  `Core/Persistence` repositories.
- `RestoreRollback` is under LocalRuntimeOS, but its effective mutation safety
  depends on `PortableSnapshotServicing.importSnapshot`, which remains unsafe.
- `LegacyImportService` and `DemoSeedPipeline` remain repository-write paths and
  cannot be cited as production migration authority.
- Current MigrationRepair tests prove non-executable review scaffolding and
  selected rollback behavior, not full existing-data migration safety.
- No fixture-backed projection replay, idempotency, privacy/no-egress, device
  durability, or data-loss proof exists for the required matrix.

## Acceptance Boundary

AMB-1720 acceptance is satisfied at Implemented Yellow:

- fixtures are explicitly named and mapped to data shapes;
- replay expectations are explicit;
- failure modes are explicit;
- residual gaps are explicit;
- no migration safety Green is claimed without executable evidence.

This artifact begins the migration proof plan; it does not complete migration
proof. Any later Green claim must link executable fixtures, validation output,
and proof artifacts for the exact claim.

## Validation Run

- `git diff --check`
  - Result: passed.
- `python3 scripts/ambitions-remediation-governance-check.py`
  - Result: passed with `changed_paths=5`. The guard reported existing
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
    `directWriteMarkerCount: 49`, and classification counts of
    `unsafe write: 19`, `canonical command: 25`, `adapter into command: 2`,
    `projection-only read: 2`, and `unknown: 1`.
- `python3 scripts/ambitions-unsupported-claim-scan.py`
  - Result: passed.
- AMB-1720 coverage scanner against this artifact:
  - Result: passed with `missing_count=0` for required migration/import/
    restore source paths, required fixture IDs, and no-Green migration language.

## Validation Not Run

- `xcodegen generate` was not run; AMB-1720 did not touch `project.yml` or
  generated project configuration.
- Xcode build and focused simulator tests were not run; AMB-1720 changed docs
  only and did not change Swift behavior.
- Full test suite was not run.
- Device tests were not run.
- UI, accessibility, performance, privacy/legal, TestFlight, App Store,
  CloudKit production, R2 production, or release-readiness validation were not
  run.
- No executable migration fixture, import/restore apply migration, rollback
  safety run, projection replay run, idempotency run, privacy/no-egress run, or
  data-loss safety proof was run in this slice.

## Closeout Boundary

- Final Architecture Tree inspected: yes, through
  `docs/truth/PRODUCT_DESIGN_TRUTH.md`.
- Canonical owners touched: `docs/audits` only.
- Swift owners touched: none.
- Files moved or created in Swift source: none.
- Old/non-canonical source paths removed: none.
- Compatibility shims left behind: none added by this slice.
- Yellow architecture debt remains: yes. Existing migration/import/restore
  apply paths remain unsafe or proof-incomplete until later source and fixture
  trains migrate, block, or prove them.
- Next repair train: AMB-1667 parent closeout at Accepted Yellow, then AMB-1668
  external adapter leaves before broader source migration parents.
- No equivalent folder/path interpretation was used.
- No Green runtime authority, storage safety, migration safety, CloudKit,
  device, release, privacy/legal, or product-completion claim is made.
