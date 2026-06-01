# AFEP-001 Projection Diff Packet

- Batch: AFEP-001
- Branch: `main`
- Commit: `10ef4719e`
- Timestamp UTC: `2026-06-01T02:41:39Z`

## Scope

This packet covers the deterministic Today/Goals/Capture/Time/You projection materialization introduced by:

- `Native/Ambitions/Domain/AmbitionGraphStoreSplitModels.swift`
- `Native/Ambitions/Domain/AmbitionGraphProjectionStore.swift`
- `Native/AmbitionsTests/Domain/AmbitionGraphProjectionStoreTests.swift`

## Projection Shape

Each stored projection record now carries:

- `surface`
- `sourceSnapshotID`
- `ambitionID`
- `generatedAt`
- `localProjectionOnly`
- `privacyClass`
- `sourceObjectIDs`
- `receiptIDs`
- `replayTraceIDs`
- `sourceFields`
- `projectionHash`
- `checksum`
- `invalidationReason`
- `schemaVersion`

## Determinism Rules

- Input arrays are normalized with ordered uniqueness before hashing or persistence.
- JSON digests are encoded with sorted keys.
- Projection invalidation reasons are explicit and stable.
- Surface ordering is canonicalized across the four named product surfaces.

## Invalidation Reasons Observed

- `initialMaterialization`
- `unchanged`
- `surfaceChanged`
- `sourceSnapshotChanged`
- `privacyChanged`
- `sourceObjectIDsChanged`
- `receiptIDsChanged`
- `replayTraceIDsChanged`
- `sourceFieldsChanged`
- `projectionHashChanged`
- `checksumChanged`

## Validation Evidence

- `testProjectionRecordsAreDeterministicAndCarryInvalidationReasons()`
- `testOperationalRecordTracksPrivacyAndQuerySeams()`
- `testProofRecordVersionsCanBeSupersededWithoutOverwritingIdentity()`
- `testProjectionRepositoryReadsQueryableColumnsWhenSnapshotBlobIsCorrupt()`

## Known Yellow Items

- The patch proves deterministic record construction through unit tests, but the simulator lane could not complete because the installed app bundle was missing a bundle ID.
- The packet does not claim parity with all historical projection owners; it only documents the AFEP split path added in this batch.

## Non-Claims

- No UI/UX claim.
- No release claim.
- No performance claim.
- No claim that broader graph projection behavior outside the tested path changed.

## Rollback Notes

Rollback remains file-scoped to the AFEP-001 touch set. Do not use a whole-worktree reset.

