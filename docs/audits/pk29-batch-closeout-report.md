# PK29 Batch Closeout Report

## Status

Phase 02 Spark bounded patch completed. Phase 03 GPT-5.5 review found one file-placement issue and repaired it inside the approved test boundary. Phase 04 GPT-5.5 Repair Pass 1 found no further source repair required and reran validation.

- Starting commit: `b20ff9d7e7c60e2a2a77a502ecad73c59dba930e`
- Branch: `main`
- Working directory: `/Users/devan/Documents/GitHub/ambitions`
- Run directory: `.codex/runs/PK29/20260512T153449Z`
- EFC applicability: Invoked for local revision-tombstone and schema-ledger proof integrity.

## Truth inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `Native/Ambitions/Domain/EntityRevisionTombstoneModels.swift`
- `Native/Ambitions/Persistence/PersistenceContracts.swift`
- `Native/Ambitions/Persistence/SwiftDataModels.swift`
- `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
- `Native/Ambitions/Persistence/SwiftDataStore.swift`
- `Native/Ambitions/Persistence/StorageSchemaVersionLedger.swift`
- `Native/AmbitionsTests/Domain/EntityRevisionTombstoneModelsTests.swift`
- `Native/AmbitionsTests/Persistence/EntityRevisionTombstoneRepositoryTests.swift`
- `Native/AmbitionsTests/Persistence/StorageSchemaVersionLedgerTests.swift`

## Files changed

- `Native/Ambitions/Domain/EntityRevisionTombstoneModels.swift` (new)
- `Native/Ambitions/Persistence/PersistenceContracts.swift`
- `Native/Ambitions/Persistence/SwiftDataModels.swift`
- `Native/Ambitions/Persistence/SwiftDataStore.swift`
- `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
- `Native/Ambitions/Persistence/StorageSchemaVersionLedger.swift`
- `Native/AmbitionsTests/Domain/EntityRevisionTombstoneModelsTests.swift` (new)
- `Native/AmbitionsTests/Persistence/EntityRevisionTombstoneRepositoryTests.swift` (new)
- `Native/AmbitionsTests/Persistence/StorageSchemaVersionLedgerTests.swift`
- `docs/audits/pk29-batch-closeout-report.md` (this report)

## Behavior introduced

- Added `EntityRevisionTombstone` domain model with deterministic identity and schema-version validation.
- Added persistence protocol + repository slot in `AppRepositories` for revision tombstones.
- Added SwiftData model record and store wiring (`EntityRevisionTombstoneRecord`) with reset delete handling.
- Added SwiftData repository mapping and `SwiftDataEntityRevisionTombstoneRepository` with deterministic upsert + recent/entity-scoped fetch.
- Added ledger coverage for `EntityRevisionTombstoneRecord` in both current entries and required SwiftData type set.
- Added focused domain and persistence tests for shape/well-formedness, stable ID behavior, append/fetch/replace/ordering, and ledger entry coverage.

## GPT-5.5 review repair

- Required repair: moved `EntityRevisionTombstoneModelsTests.swift` out of app source and into `Native/AmbitionsTests/Domain/`, matching the approved Phase 02 boundary and preventing test code from being included in the app target source tree.

## GPT-5.5 repair pass 1

- No additional source repair was required.
- Boundary rechecked against Phase 01 approved files; no dependency-container, UI, sync/cloud, migration execution, export/delete execution, project, package, signing, entitlement, generated-Xcode, or workflow files were added to scope.
- `xcodegen generate` reran successfully; it dirtied the out-of-scope `.swiftpm/xcode/xcuserdata/devan.xcuserdatad/xcschemes/xcschememanagement.plist` scheme-order file, which was restored before closeout.

## Validation

- `git status --short --untracked-files=all` — exit code: 0, includes allowed PK29-scoped deltas only.
- `git diff --check` — exit code: 0, no whitespace or line-termination issues.
- `xcodegen generate` — exit code: 0, generated project successfully; out-of-scope `.swiftpm` scheme-order drift was restored.
- `make prompt-audit` — exit code: 0, returned expected `YELLOW` due classified prompt/support/eval/template metadata only.
- `make batch-self-check` — exit code: 0, runner self-check passed.
- `scripts/codex-forbidden-claim-scan.sh Native/Ambitions/Domain/EntityRevisionTombstoneModels.swift Native/Ambitions/Persistence/PersistenceContracts.swift Native/Ambitions/Persistence/SwiftDataModels.swift Native/Ambitions/Persistence/SwiftDataRepositories.swift Native/Ambitions/Persistence/SwiftDataStore.swift Native/Ambitions/Persistence/StorageSchemaVersionLedger.swift Native/AmbitionsTests/Domain/EntityRevisionTombstoneModelsTests.swift Native/AmbitionsTests/Persistence/EntityRevisionTombstoneRepositoryTests.swift Native/AmbitionsTests/Persistence/StorageSchemaVersionLedgerTests.swift docs/audits/pk29-batch-closeout-report.md 2>/dev/null || true` — exit code: 0, no blocking claims.
- `scripts/ambitions-xcode-validate.sh --batch PK29 --lane focused-test --test AmbitionsTests/EntityRevisionTombstoneModelsTests` — exit code: 0, validation passed.
- `scripts/ambitions-xcode-validate.sh --batch PK29 --lane focused-test --test AmbitionsTests/EntityRevisionTombstoneRepositoryTests` — exit code: 0, validation passed.
- `scripts/ambitions-xcode-validate.sh --batch PK29 --lane focused-test --test AmbitionsTests/StorageSchemaVersionLedgerTests` — exit code: 0, validation passed.

Accepted-Yellow rationale:

- None required for this batch boundary.

Next handoff:

- `PK30`

## Claims not made

- No UI wiring or screen-level feature behavior.
- No cloud sync execution, conflict resolution execution, migration execution, deletion/export execution, or hosted-service behavior.
- No release, TestFlight, App Store, or accessibility/physical-device claims.

## Rollback notes

Rollback is file-limited to this batch scope if required:

- `Native/Ambitions/Domain/EntityRevisionTombstoneModels.swift`
- `Native/Ambitions/Persistence/PersistenceContracts.swift`
- `Native/Ambitions/Persistence/SwiftDataModels.swift`
- `Native/Ambitions/Persistence/SwiftDataStore.swift`
- `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
- `Native/Ambitions/Persistence/StorageSchemaVersionLedger.swift`
- `Native/AmbitionsTests/Domain/EntityRevisionTombstoneModelsTests.swift`
- `Native/AmbitionsTests/Persistence/EntityRevisionTombstoneRepositoryTests.swift`
- `Native/AmbitionsTests/Persistence/StorageSchemaVersionLedgerTests.swift`
