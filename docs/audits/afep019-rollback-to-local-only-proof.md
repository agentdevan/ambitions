# AFEP-019C Rollback to Local-Only Proof

Batch: AFEP-019C
Purpose: Define the exact rollback path from this CloudKit continuity foundation back to local-only operation

## Exact Rollback Steps

1. Set `cloudKitContinuityEnabled` back to `false` wherever user-controlled enablement is introduced later.
2. Remove the CloudKit entitlement keys from `Native/Ambitions/Support/Ambitions.entitlements` if the signing/container rollout must be reversed.
3. Delete or revert the CloudKit continuity source files:
   - `Native/Ambitions/Persistence/CloudKitContinuityClient.swift`
   - `Native/Ambitions/Persistence/CloudKitContinuityModels.swift`
4. Revert the `SyncCapabilityContracts.swift` changes if the mode/state diagnostics are no longer wanted.
5. Remove the CloudKit-specific tests under `Native/AmbitionsTests/Persistence/`.
6. Revert the concept-lock registry prefix update for AFEP-019C if the lock policy should return to its prior state.
7. Rerun:
   - `git diff --check`
   - `make xcode-build-for-testing BATCH=AFEP-019C`
   - `make xcode-focused-test BATCH=AFEP-019C TEST=AmbitionsTests/SyncCapabilityTests`

## Proof of Local-Only Safety

- The current tests already verify the local-only path is still the default.
- The current coordinator test verifies local changes are queued without requiring iCloud.
- The current build lane passed after the bounded patch.

## What Rollback Preserves

- SwiftData remains authoritative.
- The app can continue to run locally without CloudKit.
- Export/import and existing local proof artifacts remain valid.
