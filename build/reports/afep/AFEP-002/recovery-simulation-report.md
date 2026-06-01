# AFEP-002 Recovery Simulation Report

- Branch: `main`
- Commit: `37bbfbd12de3eeafd93674229b2838a0b0bda648`
- Batch: `AFEP-002`
- Packet timestamp: `2026-06-01T03:51:26Z`

## Scenario Covered

Validated the recovery path for:

- one edited/moved tombstone lineage with ancestry linkage
- one tombstoned private lineage with redacted export view
- repository filters for recoverable and finalized tombstones
- portable export of tombstones plus lineage views
- portable export redaction for private tombstone lineage/source/receipt/replay references

## Evidence

Passed focused tests:

- `AmbitionsTests/Domain/AmbitionGraphLineageModelsTests`
- `AmbitionsTests/Persistence/EntityRevisionTombstoneRepositoryTests`
- `AmbitionsTests/Persistence/PortableSnapshotServiceTests`

Observed behavior:

- stable lineage IDs remain consistent across revisions of the same object
- ancestry lineage IDs are preserved for the edited/moved object
- recoverable tombstones stay queryable via the repository
- finalized tombstones stay queryable via the repository
- private tombstones export a redacted lineage view
- private tombstones export redacted lineage/source/receipt/replay identifiers in the full tombstone payload
- shared-receipt lineage can retain receipt visibility while redacting source identifiers

## Validation Commands

```text
make xcode-build-for-testing BATCH=AFEP-002
make xcode-focused-test BATCH=AFEP-002 TEST=AmbitionsTests/Domain/AmbitionGraphLineageModelsTests
make xcode-focused-test BATCH=AFEP-002 TEST=AmbitionsTests/Persistence/EntityRevisionTombstoneRepositoryTests
make xcode-focused-test BATCH=AFEP-002 TEST=AmbitionsTests/Persistence/PortableSnapshotServiceTests
python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AFEP-002 --prompt prompts/batches/AFEP-002.md --changed-from 37bbfbd12de3eeafd93674229b2838a0b0bda648
git diff --check
scripts/ambitions-xcode-benchmark.sh --status
```

Result status:

- Build-for-testing: pass
- Focused lineage test lane: pass
- Focused tombstone repository lane: pass
- Focused portable snapshot lane: pass
- Post parallel guard: pass
- Diff whitespace check: pass
- Benchmark helper status: installed; timing evidence only

Latest Phase 04 wrapper summaries:

- Build-for-testing: `.codex/xcode-summaries/AFEP-002/20260601T034317Z/build-for-testing-summary.json`
- Focused lineage test: `.codex/xcode-summaries/AFEP-002/20260601T034418Z/focused-test-summary.json`
- Focused tombstone repository test: `.codex/xcode-summaries/AFEP-002/20260601T034645Z/focused-test-summary.json`
- Focused portable snapshot test: `.codex/xcode-summaries/AFEP-002/20260601T034848Z/focused-test-summary.json`

## Phase 04 Repair Pass

Phase 04 found no additional code repair after the Phase 03 export-safe tombstone repair. The current pass revalidated the wrapper build and focused recovery/export lanes. `xcodegen generate` reintroduced local SwiftPM scheme-order user-data churn; that generated user-data change was removed again because it is outside the eligible AFEP-002 slice.

## Yellow Items

- The broader `AmbitionsTests` lane was not claimed.
- No physical-device, release, or accessibility proof is claimed.
- No performance measurement is claimed.

## Rollback Notes

- Before commit: restore the approved source/test slice with `git restore -- <approved files>`
- After commit: `git revert <AFEP-002-commit-sha>`

## Non-Claims

- This report does not claim a full data migration was performed.
- This report does not claim user data loss prevention beyond the tested repository/export paths.
- This report does not claim any server, cloud AI, analytics, or hosted backend behavior.
