# AFEP-009 Replay Provenance Validation Report

Batch: `AFEP-009`

## What Was Validated

- `ExecutionLedgerReplayBrowserProjection` composes receipt, proof, runtime snapshot, and replay outcome data.
- The projection exposes:
  - source record IDs
  - receipt IDs
  - replay trace IDs
  - runtime snapshot checksum and provenance hash
  - privacy/export posture labels
  - proof and closure immutability labels
  - deterministic replay validation state
- `YouTrustHistoryProjector` surfaces the projection as a read-only proof-category summary item.

## Validation Results

- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AFEP-009 --prompt prompts/batches/AFEP-009.md --batch-type source-changing --allow-yellow`
  - `GREEN`
- `xcodegen generate`
  - passed
- `make xcode-build-for-testing BATCH=AFEP-009`
  - passed
- `make xcode-focused-test BATCH=AFEP-009 TEST=AmbitionsTests/AFEP009ExecutionLedgerReplayBrowserTests`
  - passed
- `make xcode-focused-test BATCH=AFEP-009 TEST=AmbitionsTests/LedgerReplayModelsTests`
  - passed
- `make xcode-focused-test BATCH=AFEP-009 TEST=AmbitionsTests/RuntimeSnapshotLedgerModelsTests`
  - passed
- `make xcode-focused-test BATCH=AFEP-009 TEST=AmbitionsTests/ActionClosureReceiptModelsTests`
  - passed
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AFEP-009 --prompt prompts/batches/AFEP-009.md --changed-from 83fbbb581afccb2ab778a445fb1da7da7fd22aa5 --batch-type source-changing --allow-yellow`
  - `GREEN`
- `python3 scripts/ambitions-champion-coverage-check.py --batch AFEP-009`
  - `GREEN` after classifying `Native/AmbitionsTests/Domain/AFEP009ExecutionLedgerReplayBrowserTests.swift` under `proof_receipt_replay`
- `git diff --check`
  - passed

## Deterministic Replay State

The focused test fixture validated as:

- runtime snapshot validation report: `valid`
- replay outcome: `replay_existing_receipt` + `skip_duplicate_mutation`
- deterministic replay validation state: `deterministic`

## Coverage Repair

The first champion coverage pass identified the new focused test file as unclassified. The repair added a test-only champion-coverage entry for `Native/AmbitionsTests/Domain/AFEP009ExecutionLedgerReplayBrowserTests.swift` with canonical owner `proof_receipt_replay`; the rerun returned `GREEN`.
