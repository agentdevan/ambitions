# AMB_APPLE_CONTINUITY_CONFLICT_RESTORE_SPEC

## Continuity scope

Apple-native continuity supported with strict proof and partial-restore handling.

## Required states

- local_only
- unavailable
- enabled
- sync_pending
- partial_restore
- restore_checkpoint
- conflict_detected
- conflict_receipt
- migration_required
- migration_complete
- source_freshness_degraded_after_restore
- continuity_proof_unavailable
- new_device_restore

## Continuity requirements

- new-device restore must emit `ContinuityReceipt`.
- conflict must produce review surface and migration path.
- restore and conflict states are never Green without proof.
