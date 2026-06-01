# AFEP-001 Query Budget Report

- Batch: AFEP-001
- Branch: `main`
- Commit: `10ef4719e`
- Timestamp UTC: `2026-06-01T02:41:39Z`

## Scope

This packet documents the storage read shape for the AFEP split owners:

- `Native/Ambitions/Domain/AmbitionGraphStoreSplitModels.swift`
- `Native/Ambitions/Persistence/SwiftDataModels.swift`
- `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
- `Native/AmbitionsTests/Persistence/AmbitionGraphStoreSplitRepositoryTests.swift`

## Query Budget

Observed read paths are column-filtered and bounded:

- `SwiftDataAmbitionGraphOperationalRecordRepository.fetchRecords(surface:snapshotID:limit:)`
- `SwiftDataAmbitionGraphProofRecordRepository.fetchRecords(proofID:limit:)`
- `SwiftDataAmbitionGraphProjectionRecordRepository.fetchRecords(surface:snapshotID:limit:)`

Queryable columns used before any blob fallback:

- `surfaceRaw`
- `sourceSnapshotID`
- `proofID`
- `generatedAt`
- `version`

Blob/snapshot payloads remain adapter fallback only:

- `snapshotData`

## Validation Evidence

- `python3 scripts/ambitions-champion-coverage-check.py` -> `STATUS: GREEN`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AFEP-001 --prompt prompts/batches/AFEP-001.md` -> `STATUS: GREEN`
- `xcodegen generate` -> pass
- `make xcode-build-for-testing` -> fail at wrapper level before usable test proof
- `make xcode-focused-test BATCH=AFEP-001 TEST=AmbitionsTests/Domain/AmbitionGraphProjectionStoreTests` -> fail during simulator install, missing bundle ID

## Known Yellow Items

- The focused simulator test lane is blocked by packaging/install behavior, not by a compiler diagnostic from this patch.
- This packet does not claim performance proof, only query-shape and non-blob read-path coverage.
- Broader `AmbitionsTests` execution was not completed in this phase.

## Non-Claims

- No release readiness claim.
- No performance budget claim.
- No device-install proof claim.
- No app-behavior completeness claim beyond the covered storage paths and tests.

## Rollback Notes

Use the phase patch boundary only:

```bash
git diff -- Native/Ambitions/Domain Native/Ambitions/Persistence Native/AmbitionsTests build/reports/afep/AFEP-001 > /tmp/AFEP-001-phase02.patch
```

Revert only the AFEP-001 touched paths if owner approval requires rollback.

