# AFEP-003 Replay Validation Report

- Batch: `AFEP-003`
- Branch: `main`
- Commit: `7c3e4897d`
- Generated at: `2026-06-01T04:28:10Z`

## Validation Summary

- `RuntimeSnapshotLedgerEnvelope` compatibility handling:
  - Current schema -> `current`
  - Legacy schema -> `migrated_older`
  - Unknown schema -> `unsupported`
- Replay validation outcomes implemented and tested:
  - `valid`
  - `missing_envelope`
  - `unsupported_envelope`
  - `checksum_mismatch`
  - `ambiguous_envelope`

## Commands Used

- `make xcode-build-for-testing BATCH=AFEP-003`
- `make xcode-focused-test BATCH=AFEP-003 TEST=AmbitionsTests/RuntimeSnapshotLedgerModelsTests`
- `make xcode-focused-test BATCH=AFEP-003 TEST=AmbitionsTests/RuntimeSnapshotLedgerRepositoryTests`

## Evidence

- Domain tests passed and exercised:
  - envelope compatibility classification
  - export-safe redaction projection
  - replay validation for missing, migrated older, unsupported, and checksum mismatch
- Repository tests passed and exercised:
  - SwiftData round-trip append/fetch
  - receipt/proof/replay-trace reference lookup
  - missing, migrated older, unsupported, and checksum mismatch validation results

## Known Yellow Items

- None for this batch slice.

## Non-Claims

- This report is not release proof.
- This report is not device proof, accessibility proof, privacy proof, or performance proof.
- This report does not claim the full `AmbitionsTests` suite or any production rollout.
