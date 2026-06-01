# AFEP-003 Runtime Ledger Packet

- Batch: `AFEP-003`
- Branch: `main`
- Commit: `7c3e4897d`
- Generated at: `2026-06-01T04:28:10Z`
- Scope: versioned runtime snapshot ledger, persistence repository, validation hook, and focused tests

## Files Changed

- `Native/Ambitions/Domain/RuntimeSnapshotLedgerModels.swift`
- `Native/Ambitions/Persistence/PersistenceContracts.swift`
- `Native/Ambitions/Persistence/SwiftDataModels.swift`
- `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
- `Native/Ambitions/Persistence/SwiftDataStore.swift`
- `Native/Ambitions/Persistence/StorageSchemaVersionLedger.swift`
- `Native/AmbitionsTests/Domain/RuntimeSnapshotLedgerModelsTests.swift`
- `Native/AmbitionsTests/Persistence/RuntimeSnapshotLedgerRepositoryTests.swift`
- `docs/codex/existing-code-champion-coverage.yml`

## What Changed

- Added a deterministic `RuntimeSnapshotLedgerEnvelope` with schema version, envelope ID, generated timestamp, source record IDs, receipt IDs, replay trace IDs, recommendation/proof input references, AFEP-002 lineage references, field redaction classes, compatibility status, checksum, and provenance hash.
- Added export-safe redaction projections for runtime snapshot envelopes.
- Added replay validation reporting for missing, migrated older, unsupported, ambiguous, and checksum-mismatch reference lookups.
- Added a SwiftData record and repository for source-backed runtime snapshot storage and validation.
- Added a schema ledger entry for the new runtime snapshot ledger record.
- Added focused unit tests for compatibility/redaction and repository round-trips/validation.
- Updated the champion coverage inventory so the new Swift files are classified.

## Validation Run

- `python3 scripts/ambitions-champion-coverage-check.py` -> `STATUS: GREEN`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AFEP-003 --prompt prompts/batches/AFEP-003.md` -> `Status: GREEN`
- `xcodegen generate` -> passed
- `make xcode-build-for-testing BATCH=AFEP-003` -> passed
- `make xcode-focused-test BATCH=AFEP-003 TEST=AmbitionsTests/RuntimeSnapshotLedgerModelsTests` -> passed
- `make xcode-focused-test BATCH=AFEP-003 TEST=AmbitionsTests/RuntimeSnapshotLedgerRepositoryTests` -> passed
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AFEP-003 --prompt prompts/batches/AFEP-003.md --changed-from 7c3e4897d0009a246cda2bd4059c8fbd9e35a8f3` -> `Status: GREEN`
- `git diff --check` -> passed

## Validation Not Run

- `make xcode-focused-test BATCH=AFEP-003 TEST=AmbitionsTests` was not run because the prompt asked for the focused new ledger lanes.
- No release, device, accessibility, privacy, or performance proof was run.

## Proof Boundaries

- The new ledger is source-backed and test-backed locally.
- The build/test proof here does not imply release readiness, device proof, accessibility proof, or privacy/legal signoff.
- No cloud AI, backend, analytics, or hosted inference dependency was added.

## Risks

- The runtime ledger is newly introduced and only covered by focused tests, not the full `AmbitionsTests` suite.
- Additional production call sites can be wired later; this batch only proves the core ledger, repository, and validation path compile and pass focused tests.

## Rollback Notes

- Restore the edited files with:

```bash
git restore -- Native/Ambitions/Domain/RuntimeSnapshotLedgerModels.swift Native/Ambitions/Persistence/PersistenceContracts.swift Native/Ambitions/Persistence/SwiftDataModels.swift Native/Ambitions/Persistence/SwiftDataRepositories.swift Native/Ambitions/Persistence/SwiftDataStore.swift Native/Ambitions/Persistence/StorageSchemaVersionLedger.swift Native/AmbitionsTests/Domain/RuntimeSnapshotLedgerModelsTests.swift Native/AmbitionsTests/Persistence/RuntimeSnapshotLedgerRepositoryTests.swift docs/codex/existing-code-champion-coverage.yml build/reports/afep/AFEP-003/runtime-ledger-packet.md build/reports/afep/AFEP-003/replay-validation-report.md
```
