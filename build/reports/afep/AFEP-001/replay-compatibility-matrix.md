# AFEP-001 Replay Compatibility Matrix

- Batch: AFEP-001
- Branch: `main`
- Commit: `10ef4719e`
- Timestamp UTC: `2026-06-01T02:41:39Z`

## Compatibility Matrix

| Record | Replay-related fields | Compatibility posture | Notes |
| --- | --- | --- | --- |
| Operational record | `sourceObjectIDs`, `receiptIDs`, `replayTraceIDs`, `sourceFields` | Compatible | Queryable record for live operational reads; blob snapshot is retained only as fallback metadata. |
| Proof record | `proofID`, `version`, `supersedesProofID`, `sourceSnapshotID`, `receiptIDs`, `replayTraceIDs` | Compatible | Append-only versioning preserves proof lineage rather than overwriting identity. |
| Projection record | `sourceSnapshotID`, `receiptIDs`, `replayTraceIDs`, `invalidationReason`, `projectionHash`, `checksum` | Compatible | Deterministic materialization with explicit rebuild reason. |

## Source / Receipt / ReplayTrace Wiring

The new split records preserve the replay-facing seams used by the runtime through explicit stored identifiers:

- `sourceObjectIDs`
- `receiptIDs`
- `replayTraceIDs`

This means replay and provenance checks can reason about the record without reading the snapshot blob first.

## Fallback Path

The SwiftData repositories still decode `snapshotData` only as an adapter fallback when needed. That keeps the AFRI-compatible path available while the AFEP read path remains queryable.

## Validation Evidence

- `xcodegen generate` -> pass
- `make xcode-build-for-testing` -> not a usable proof result in this phase
- `make xcode-focused-test BATCH=AFEP-001 TEST=AmbitionsTests/Domain/AmbitionGraphProjectionStoreTests` -> failed at simulator install due missing bundle ID
- `git diff --check` -> pending final rerun after report creation

## Known Yellow Items

- Replay compatibility is proven at the record-shape level and by focused unit assertions, not by an end-to-end launch/install run.
- The focused simulator lane did not finish because the built app bundle could not be installed.

## Non-Claims

- No claim of full runtime replay certification.
- No claim of release readiness.
- No claim of simulator launch success.
- No claim that every legacy replay format is retired.

## Rollback Notes

If rollback is required, remove only the AFEP-001 files and reverse the bounded persistence/domain edits. Do not revert unrelated dirty files in the worktree.

