# Persistence Direct Save Rejection Proof

Status: AMB-1719 Implemented Yellow

Snapshot date: 2026-07-02

Baseline repo state inspected before this artifact:
`6c60c6c95fadc9990b0d8198ab895e20ec05f8de` on `main`

Scope: AMB-1667 -> AMB-1719 only. This artifact adds audit proof for direct
model-save and direct persistence-write markers outside the
`Command -> Event -> Projection -> Receipt -> Replay` path. It does not move
Swift source, delete legacy persistence source, add executable rejection tests,
change runtime behavior, prove migration safety, prove storage Green, or claim
that every meaningful Ambitions state change is command-only.

Evidence class: Implemented Yellow. Current direct writes are classified by
`scripts/ambitions-runtime-direct-write-audit.py`, and unsafe rows are linked
to AMB-1719 and the remaining AMB-1667 follow-ups. The proof mode for unsafe
rows is explicit unsafe classification, not successful runtime rejection.

AMB-1720 follow-up plan: `docs/audits/persistence-existing-data-migration-proof-plan.md`
now defines the existing-data migration fixture matrix, replay expectations,
failure modes, proof gates, and residual Yellow gaps for migration/import/
restore paths. It does not make unsafe direct writes safe and does not prove
migration safety Green.

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

Storage is substrate. SwiftData models are dumb storage records. Persistence
must not own planning, trust, reflow, Source Atlas policy, privacy egress,
side effects, migration execution, repair execution, product copy, or
user-facing recommendation behavior.

Persistent surfaces remain Today / Goals / Time / You. Capture remains the
global composer. Motion remains behavior under Stage/Motion. R2 and Source
Atlas remain public/reference/freshness infrastructure only and are not
private life graph storage.

## Acceptance Mapping

AMB-1719 acceptance allows three proof modes:

| Proof mode | AMB-1719 result | Claim ceiling |
| --- | --- | --- |
| Direct persistence writes fail | Not broadly proven by this slice. Existing scoped ObjectState/AppState rejection proof is not generalized to all persistence families. | No Green direct-save rejection claim. |
| Direct persistence writes are impossible from production roots | Not broadly proven. Adapter/projection rows are classified, but app-wide impossibility is not claimed. | No app-wide command-only claim. |
| Direct persistence writes are explicitly classified unsafe with linked repair work | Satisfied at Implemented Yellow for current unsafe direct-write audit rows. | Unsafe rows remain Yellow debt until migrated, quarantined, or proven rejected. |

## Direct-Write Audit Summary

`python3 scripts/ambitions-runtime-direct-write-audit.py --json` is the machine
source for the direct-write inventory. AMB-1719 aligns the unsafe follow-up
labels to this leaf.

Validated AMB-1719 summary:

| Field | Value |
| --- | ---: |
| `proofStatus` | `Implemented Yellow` |
| `directWriteMarkerCount` | 49 |
| `findingCount` | 0 |
| `canonical command` | 25 |
| `adapter into command` | 2 |
| `projection-only read` | 2 |
| `unsafe write` | 19 |
| `unknown` | 1 |

Marker counts: FileManager 23, SwiftData 22, write_call 14,
context_insert 8, try_save 3, context_delete 3, ModelContext 3,
context_save 1.

This is not a Green result. A `findingCount` of `0` means every current
direct-write marker is classified and linked; it does not mean unsafe writes
are fixed.

## Unsafe Direct-Write Rows

These rows remain unsafe linked debt. Direct-save rejection is not proven for
them unless a future scoped source/test artifact shows the write fails, is
unreachable from production roots, or is routed through sanctioned runtime
context.

| Path | Markers | AMB-1719 verdict | Next repair |
| --- | --- | --- | --- |
| `Native/Ambitions/Core/Domain/RealityModels.swift` | FileManager, write_call | Unsafe direct file write outside LocalRuntimeOS. Included because the direct-write guard tracks it, even though it is not a SwiftData model-save row. | AMB-1667 / later Time storage migration |
| `Native/Ambitions/Core/Persistence/LifeContextPersistence.swift` | SwiftData, context_insert | Unsafe legacy SwiftData persistence scaffolding outside LocalRuntimeOS. | AMB-1667 after AMB-1719 |
| `Native/Ambitions/Core/Persistence/PortableSnapshotService+02-PortableSnapshotService.swift` | try_save | Unsafe portable snapshot apply path through legacy Core/Persistence. | AMB-1720 migration proof plan |
| `Native/Ambitions/Core/Persistence/SwiftDataModels+02-CaptureRecord.swift` | SwiftData | Unsafe model authority location outside canonical storage owner. | AMB-1667 / ObjectState family migration |
| `Native/Ambitions/Core/Persistence/SwiftDataModels+03-EntityRevisionTombstoneRecord.swift` | SwiftData | Unsafe model authority location outside canonical storage owner. | AMB-1667 / TrustSystem or MigrationRepair family migration |
| `Native/Ambitions/Core/Persistence/SwiftDataModels+04-AmbitionGraphProjectionRecordModel.swift` | SwiftData | Unsafe model authority location outside canonical storage owner. | AMB-1667 / ProjectionEngine storage migration |
| `Native/Ambitions/Core/Persistence/SwiftDataModels.swift` | SwiftData | Unsafe model authority location outside canonical storage owner. | AMB-1667 / ObjectState family migration |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+02-RepositoryMapping+02-persisted.swift` | SwiftData | Unsafe legacy mapping surface enabling repository writes. | AMB-1667 / ObjectStoreSwiftData adapter migration |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+02-RepositoryMapping+03-feedbackRecord.swift` | SwiftData | Unsafe legacy mapping surface enabling feedback/proof repository writes. | AMB-1667 / TrustSystem storage migration |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+02-RepositoryMapping+04-apply.swift` | SwiftData | Unsafe legacy apply helper outside canonical storage owner. | AMB-1667 / ObjectStoreSwiftData adapter migration |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+02-RepositoryMapping+05-entityRevisionTombstone.swift` | SwiftData | Unsafe tombstone mapping helper outside canonical storage owner. | AMB-1667 / TrustSystem or MigrationRepair family migration |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+02-RepositoryMapping.swift` | SwiftData | Unsafe legacy mapping namespace outside canonical storage owner. | AMB-1667 / ObjectStoreSwiftData adapter migration |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+03-Array.swift` | SwiftData, context_delete | Unsafe repository/unit-of-work path outside LocalRuntimeOS. | AMB-1667 / command-context-gated storage migration |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+04-SwiftDataGoalPersistence.swift` | SwiftData, ModelContext, context_insert, context_delete | Unsafe goal/draft/evidence/feedback/capture writes outside LocalRuntimeOS. | AMB-1667 / object-family command migration |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+05-SwiftDataAmbitionGraphProjectionRecordRepository.swift` | SwiftData, context_insert | Unsafe graph projection record writes outside canonical projection storage. | AMB-1667 / ProjectionEngine storage migration |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+06-SwiftDataAppStateRepository.swift` | SwiftData, context_insert | Unsafe app-state direct save path unless called through sanctioned command context. | AMB-1667 / ObjectState storage migration |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+07-SwiftDataRuntimeSnapshotLedgerRepository.swift` | SwiftData, context_insert | Unsafe runtime snapshot ledger writes outside canonical event/trust storage. | AMB-1667 / TrustSystem or EventJournal migration |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+08-SwiftDataReminderRepository.swift` | SwiftData, context_insert | Unsafe reminder repository writes outside SideEffectSystem outbox authority. | AMB-1668 and AMB-1667 |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories.swift` | SwiftData | Unsafe legacy SwiftData repository authority outside LocalRuntimeOS. | AMB-1667 / ObjectStoreSwiftData adapter migration |

## Other Direct-Write Classifications

- `canonical command` rows live under `Core/LocalRuntimeOS`. They are allowed
  storage/runtime markers only with the scoped proof ceiling in the audit; they
  do not prove every app mutation is command-only.
- `adapter into command` rows are notification/external-creation handoffs with
  their own AMB-1708/AMB-1668 proof requirements.
- `projection-only read` rows materialize external projection snapshots and
  are not private graph mutation proof.
- The `unknown` row is `Native/Ambitions/PreviewSupport/PreviewAppContainer.swift`;
  it remains a preview/debug quarantine sentinel from AMB-1710.

## Residual Yellow Gaps

- Legacy SwiftData model and repository files remain under `Core/Persistence`.
- Portable snapshot import/restore can still apply through legacy repositories;
  AMB-1720 documents the existing-data migration proof plan, but executable
  migration safety remains unproven.
- Debug/demo seed paths and legacy import scaffolding remain unsafe if treated
  as production mutation authority.
- The direct-write audit is static source proof. It does not prove runtime
  behavior, device behavior, storage durability, migration safety, replay
  correctness, privacy/legal approval, TestFlight readiness, App Store
  readiness, or total LocalRuntimeOS completion.

## Private Life Orchestration Boundary

This work protects the Private Life Orchestration loop by refusing to let
persistence become a competing decision path for intent, context, path, time
fit, reflow, action, proof, and learning. The current result is Yellow because
unsafe storage paths are identified and linked, not because they are fixed.

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
- AMB-1719 unsafe-row coverage scanner against this artifact:
  - Result: passed with `unsafe_count=19`, `missing_doc_rows=[]`, and
    `bad_follow_up_rows=[]`.

## Validation Not Run

- `xcodegen generate` was not run; AMB-1719 did not touch `project.yml` or
  generated project configuration.
- Xcode build and focused simulator tests were not run; AMB-1719 changed docs
  and a static audit classifier only.
- Full test suite was not run.
- Device tests were not run.
- UI, accessibility, performance, privacy/legal, TestFlight, App Store,
  CloudKit production, R2 production, or release-readiness validation were not
  run.
- No executable direct-save rejection test was added in this slice. AMB-1719
  satisfies the leaf at Implemented Yellow by classifying unsafe direct-write
  debt with linked repair work.

## Closeout Boundary

- Final Architecture Tree inspected: yes, through
  `docs/truth/PRODUCT_DESIGN_TRUTH.md`.
- Canonical owners touched: `docs/audits` and
  `scripts/ambitions-runtime-direct-write-audit.py`.
- Swift owners touched: none.
- Files moved or created in Swift source: none.
- Old/non-canonical source paths removed: none.
- Compatibility shims left behind: none added by this slice.
- Yellow architecture debt remains: yes. Unsafe direct-write rows remain
  classified linked debt until later source migration or executable rejection
  proof.
- Next repair train: AMB-1667 parent closeout at Accepted Yellow, then
  AMB-1668 external adapter leaves before broader source migration parents.
- No equivalent folder/path interpretation was used.
- No Green runtime authority, direct-save rejection, storage safety, migration
  safety, CloudKit, device, release, privacy/legal, or product-completion claim
  is made.
