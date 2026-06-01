# AFEP-002 Lineage Graph Packet

- Branch: `main`
- Commit: `37bbfbd12de3eeafd93674229b2838a0b0bda648`
- Batch: `AFEP-002`
- Packet timestamp: `2026-06-01T03:51:26Z`

## Scope

Extended the existing tombstone/persistence seam to carry:

- stable lineage IDs
- ancestry references
- recoverable vs finalized tombstone lifecycle state
- export-safe redacted lineage views
- export-safe redacted tombstone payload references for lineage/source/receipt/replay identifiers
- SwiftData-backed lineage queries

## Changed Files

- `Native/Ambitions/Domain/EntityRevisionTombstoneModels.swift`
- `Native/Ambitions/Domain/AmbitionGraphLineageModels.swift`
- `Native/Ambitions/Persistence/PersistenceContracts.swift`
- `Native/Ambitions/Persistence/SwiftDataModels.swift`
- `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
- `Native/Ambitions/Persistence/PortableSnapshotContracts.swift`
- `Native/Ambitions/Persistence/PortableSnapshotService.swift`
- `Native/Ambitions/Persistence/StorageSchemaVersionLedger.swift`
- `Native/AmbitionsTests/Domain/EntityRevisionTombstoneModelsTests.swift`
- `Native/AmbitionsTests/Domain/AmbitionGraphLineageModelsTests.swift`
- `Native/AmbitionsTests/Persistence/EntityRevisionTombstoneRepositoryTests.swift`
- `Native/AmbitionsTests/Persistence/PortableSnapshotServiceTests.swift`

## Validation

Commands run:

```text
python3 scripts/ambitions-champion-coverage-check.py
python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AFEP-002 --prompt prompts/batches/AFEP-002.md
xcodegen generate
make xcode-build-for-testing BATCH=AFEP-002
make xcode-focused-test BATCH=AFEP-002 TEST=AmbitionsTests/Domain/AmbitionGraphLineageModelsTests
make xcode-focused-test BATCH=AFEP-002 TEST=AmbitionsTests/Persistence/EntityRevisionTombstoneRepositoryTests
make xcode-focused-test BATCH=AFEP-002 TEST=AmbitionsTests/Persistence/PortableSnapshotServiceTests
python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AFEP-002 --prompt prompts/batches/AFEP-002.md --changed-from 37bbfbd12de3eeafd93674229b2838a0b0bda648
git diff --check
scripts/ambitions-xcode-benchmark.sh --status
```

Result status:

- Champion coverage: pass
- Pre parallel guard: pass
- Build-for-testing: pass
- Focused lineage tests: pass
- Focused tombstone repository tests: pass
- Focused portable snapshot tests: pass
- Post parallel guard: pass
- Diff whitespace check: pass
- Benchmark helper status: installed; timing evidence only

Latest Phase 04 wrapper summaries:

- Build-for-testing: `.codex/xcode-summaries/AFEP-002/20260601T034317Z/build-for-testing-summary.json`
- Focused lineage test: `.codex/xcode-summaries/AFEP-002/20260601T034418Z/focused-test-summary.json`
- Focused tombstone repository test: `.codex/xcode-summaries/AFEP-002/20260601T034645Z/focused-test-summary.json`
- Focused portable snapshot test: `.codex/xcode-summaries/AFEP-002/20260601T034848Z/focused-test-summary.json`

## Phase 04 Repair Pass

Phase 04 found no additional code repair after the Phase 03 export-safe tombstone repair. The current pass revalidated champion coverage, parallel guards, XcodeGen generation, build-for-testing, focused lineage/repository/export tests, and whitespace status. `xcodegen generate` reintroduced local SwiftPM scheme-order user-data churn; that generated user-data change was removed again because it is outside the eligible AFEP-002 slice.

## Phase 03 Review Repair

Phase 03 found that adding lineage/source/receipt/replay fields to full tombstone payloads could expose private lineage identifiers in portable exports even though the separate lineage view was redacted. The repair added `EntityRevisionTombstone.exportSafeTombstone` and routes portable snapshot tombstone export through that redacted copy while preserving lineage IDs and lifecycle state.

## Known Yellow Items

- No release, accessibility, privacy, performance, device, or CI proof is claimed.
- The broader `AmbitionsTests` lane was not rerun or claimed in Phase 04.
- `docs/codex/concept-lock-registry.yml` remains preexisting dirty worktree context and was preserved.

## Rollback Notes

- Before commit: `git restore -- Native/Ambitions/Domain/AmbitionGraphLineageModels.swift Native/Ambitions/Domain/EntityRevisionTombstoneModels.swift Native/Ambitions/Persistence/PersistenceContracts.swift Native/Ambitions/Persistence/PortableSnapshotContracts.swift Native/Ambitions/Persistence/PortableSnapshotService.swift Native/Ambitions/Persistence/StorageSchemaVersionLedger.swift Native/Ambitions/Persistence/SwiftDataModels.swift Native/Ambitions/Persistence/SwiftDataRepositories.swift Native/AmbitionsTests/Domain/AmbitionGraphLineageModelsTests.swift Native/AmbitionsTests/Domain/EntityRevisionTombstoneModelsTests.swift Native/AmbitionsTests/Persistence/EntityRevisionTombstoneRepositoryTests.swift Native/AmbitionsTests/Persistence/PortableSnapshotServiceTests.swift docs/codex/existing-code-champion-coverage.yml`
- After commit: `git revert <AFEP-002-commit-sha>`

## Non-Claims

- This packet does not claim release readiness.
- This packet does not claim accessibility verification.
- This packet does not claim device validation.
- This packet does not claim performance validation.
- This packet does not claim any cloud/backend dependency was added.
