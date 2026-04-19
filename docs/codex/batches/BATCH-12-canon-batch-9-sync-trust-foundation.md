# Batch 12 — Canon Batch 9 / Sync-Trust Foundation

## Status

Completed

## Goal

Build the sync/trust foundation as a boundary-first layer so Ambitions remains local-first, exportable, conflict-aware, and ready for future cross-device sync without prematurely locking the product to one backend shape or shipping half-trustworthy multi-device behavior.

## In Scope

- audit current persistence, snapshot, shared-container, and export/import seams
- define or formalize a canonical sync capability boundary
- define or refine local-only mode as an explicit supported trust posture
- add or refine versioned export/import snapshot models where justified
- add or refine conflict policy and merge strategy contracts
- add or refine backup/restore or portability seams if the repo already has a natural place for them
- add/update focused tests for export/import, version compatibility, conflict handling, and local-only trust behavior
- keep the implementation protocol-backed and future-adapter-friendly

## Out Of Scope

- full cloud sync rollout
- account system
- auth flows
- multi-user/shared household sync
- life graph / household / device work
- App Intents
- widgets / Live Activities work beyond compatibility
- broad UI redesign
- backend lock-in unless a minimal adapter stub is clearly justified

## Dependency Rules

- do not skip ahead
- define the boundary before any real sync backend commitment
- keep the app local-first by default unless this batch explicitly proves otherwise
- strengthen existing persistence/export seams instead of inventing a parallel data stack
- no speculative cloud product behavior
- prefer additive compatibility-safe snapshot/versioning work

## Extra Constraints

- keep `PortableAppSnapshot` fully separate from `ExternalSurfaceSnapshot`
- treat `PortableAppSnapshot` as the canonical native backup/restore format only for goals, drafts, evidence, feedback, captures, and app state
- keep `LocalOnlySyncCapability` as the default and only supported runtime posture after this batch
- destructive `replaceLocalStore` behavior must stay isolated to the portable snapshot service
- `mergeWithConflictReport` must stay conservative and must not silently overwrite local data for `.requiresUserDecision`
- use existing revision/timestamp markers conservatively and do not invent false precision
- older or unsupported schema versions must fail or report cleanly
- do not add sync settings, cloud wording, or device-management UI
- mark Batch 12 completed only if generation, build, targeted tests, and full `AmbitionsTests` validation all pass

## Current Repo Notes

- The native repo already persists canonical repository snapshots through SwiftData-backed repositories.
- `LegacyImportService` already provides a legacy import seam, but only for the old prototype format.
- `ExternalSurfaceSnapshot` is already versioned and compatibility-tested, but it is privacy-safe ambient export only and not the trust portability schema.
- App Group and shared-container seams already exist for ambient surface snapshot sharing.
- Profile already defaults to and enforces on-device-first posture.

## Exit Criteria

- a separate `PortableAppSnapshot` exists as the canonical native backup/restore format
- portable export/import covers goals, drafts, evidence, feedback, captures, and app state
- sync remains optional and isolated behind a capability boundary
- local-only posture is explicit and truthful
- conservative conflict reporting exists without speculative cloud behavior
- generation, build, targeted tests, and full `AmbitionsTests` validation pass before this batch is marked completed

## Validation

- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/PersistenceRepositoryTests -only-testing:AmbitionsTests/LegacyImportServiceTests -only-testing:AmbitionsTests/PortableSnapshotServiceTests -only-testing:AmbitionsTests/SyncCapabilityTests -only-testing:AmbitionsTests/ProfileFeatureServiceTests test`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test`

## Completion Notes

- Added a dedicated `PortableAppSnapshot` contract that stays fully separate from `ExternalSurfaceSnapshot`.
- Added `PortableSnapshotService` for export, isolated destructive restore, and conservative merge/conflict reporting across goals, drafts, evidence, feedback, captures, and app state.
- Added a protocol-backed sync capability boundary with `LocalOnlySyncCapability` as the only supported runtime posture.
- Updated Profile copy to make the local-only trust posture explicit without adding sync toggles, backend settings, or cloud wording.
