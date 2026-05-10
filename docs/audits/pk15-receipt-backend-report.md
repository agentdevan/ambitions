# PK15 Receipt Backend Report

Date: 2026-05-10

## Decision

- PK15 closeout: **accepted Yellow**.
- Boundaries: `Native/Ambitions/Persistence/*` and `Native/AmbitionsTests/Persistence/ActionReceiptHistoryRepositoryTests.swift` are the implementation scope.

## Evidence

- `xcodegen generate`
- Focused test run:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/ActionReceiptHistoryRepositoryTests test`
  - Result: 4 tests, 0 failures.
- `scripts/codex-forbidden-claim-scan.sh Native/Ambitions/Persistence/PersistenceContracts.swift Native/Ambitions/Persistence/StorageSchemaVersionLedger.swift Native/Ambitions/Persistence/SwiftDataModels.swift Native/Ambitions/Persistence/SwiftDataRepositories.swift Native/Ambitions/Persistence/SwiftDataStore.swift Native/AmbitionsTests/Persistence/ActionReceiptHistoryRepositoryTests.swift`
  - Result: no blocking hits.

## Validation Scope

- Preflight: `scripts/ambitions-process-preflight.sh --assert-clear` → STATUS: CLEAR.
- PK15-focused tests passed.
- Full test suite was not rerun in this phase.
- Known unrelated full-suite failure remains:
  - `ExternalSurfaceVerificationChecklistTests.testM04ExistingProjectionsCarryStalePrivateAndFallbackBehavior`

## Closure Position

- PK15 is closeable as **accepted Yellow** only.
- Owner: QA / External Surface.
- Retirement condition: run/fix `ExternalSurfaceVerificationChecklistTests.testM04ExistingProjectionsCarryStalePrivateAndFallbackBehavior` in its owning external-surface lane.
- Resume path: continue global train after closeout (PK16 next eligible) without claiming full-suite green.

## Proof Paths

- Focused test log: `/.codex/runs/PK15-FINALIZE-01/20260510T173519Z/` (phase execution artifacts).
- Prior PK15 final summary: `.codex/runs/PK15/20260510T151222Z/final-summary.md`.
