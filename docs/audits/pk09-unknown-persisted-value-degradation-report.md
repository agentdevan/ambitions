# PK09 Unknown Persisted Value Degradation Report

<!-- markdownlint-disable MD013 -->

Date: 2026-05-08
Result: Green
Batch: PK09 Unknown Persisted Value Degradation
Train: PK00-PK41 Platform Kernel

## Scope

PK09 adds a persistence-local degradation contract for persisted raw values that
newer or older app versions may not recognize. Unknown values degrade through
deterministic fallbacks or optional nil fallbacks with explicit metadata that
blocks migration-safety claims until later review/proof owners handle the case.

This batch does not implement a migration runner, execute migrations, mutate
schema, add UI, change routes, add sync/cloud behavior, or claim migration-safe
or data-loss-proof storage.

## Files Changed

- `Native/Ambitions/Persistence/PersistedValueDegradation.swift`
- `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
- `Native/AmbitionsTests/Persistence/PersistedValueDegradationTests.swift`
- `Native/AmbitionsTests/Persistence/PersistenceRepositoryTests.swift`
- `.codex/state/active-batch.yml`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `docs/audits/platform-kernel-train-report.md`
- `docs/audits/platform-kernel-risk-register.md`
- `docs/codex/platform-kernel-current-state.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json`
- `docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md`
- `docs/codex/batch-trains/PK00_PK41_PLATFORM_KERNEL_TRAIN.md`

## Implementation Summary

- Added `persistedValueDegradationSchemaVersion` and typed degradation reason,
  disposition, entry, and resolution models.
- Added `PersistedValueDegradation.resolve` for known raw values, legacy aliases,
  and unknown raw values with deterministic fallback metadata.
- Added `PersistedValueDegradation.resolveOptional` for optional raw values,
  legacy aliases, and unknown raw values that safely degrade to nil.
- Routed repository raw-value fallbacks through a single persistence helper for
  Goals, Steps, Progress Evidence, Capture, Event Ledger, App State, and Plan
  section records.
- Preserved legacy Capture status aliases for `pending` and `processed` while
  keeping unknown raw values review-blocking.

## Proof

- `xcodegen generate` passed before focused tests.
- Focused `xcodebuild test` passed for:
  - `AmbitionsTests/PersistedValueDegradationTests`
  - `AmbitionsTests/PersistenceRepositoryTests/testGoalRepositoryDegradesUnknownRawValuesWhenSnapshotCannotDecode`
  - `AmbitionsTests/PersistenceRepositoryTests/testAppStateRepositoryDegradesUnknownRawValuesWhenSnapshotCannotDecode`
  - `AmbitionsTests/PersistenceRepositoryTests/testCaptureRepositoryMapsLegacyStatusRawValuesInOnePersistenceFallback`
- Focused result: 7 tests, 0 failures.

## Validation Commands

- `git status --short`
- `git branch --show-current`
- `git rev-parse HEAD`
- `git log -1 --oneline`
- `xcodegen generate`
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/PersistedValueDegradationTests -only-testing:AmbitionsTests/PersistenceRepositoryTests/testGoalRepositoryDegradesUnknownRawValuesWhenSnapshotCannotDecode -only-testing:AmbitionsTests/PersistenceRepositoryTests/testAppStateRepositoryDegradesUnknownRawValuesWhenSnapshotCannotDecode -only-testing:AmbitionsTests/PersistenceRepositoryTests/testCaptureRepositoryMapsLegacyStatusRawValuesInOnePersistenceFallback`
- `git diff --check`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`
- `scripts/swiftui-architecture-scan.sh || true`

## Validation Results

- `xcodegen generate`: passed.
- Focused `xcodebuild test`: passed, 7 tests, 0 failures.
- `git diff --check`: passed.
- `scripts/run-doc-qa.sh || true`: completed with existing advisory backlog.
  Stale-guidance and deprecated-language scans report historical/cautionary
  matches; markdownlint reports broad historical MD013/MD012/MD032 backlog;
  lychee reports 669 OK, 0 errors, 1 redirect.
- `scripts/batch-train-gate-check.sh || true`: completed with expected dirty
  worktree Yellow because PK09 files were intentionally open before commit.
- `scripts/swiftui-architecture-scan.sh || true`: completed with existing
  advisory extraction/responsibility findings; no PK09-specific hard Red was
  introduced.

## Model Tier

- Model tier used: unknown under Mini-safe rules.
- Model-tier source: no explicit tier marker was visible in repo state.
- Mini-safe classification: yes, bounded persistence fallback contract with
  focused tests and no migration execution.
- Senior-only gates encountered: none.
- Deferrals created or closed: none.

## EFC Applicability

EFC invoked. PK09 touches persistence/data-safety behavior, so the batch records
explicit no-claim boundaries, focused local proof, deterministic fallback
behavior, and continuation state. EFC does not make this release, migration,
privacy, accessibility, device, or data-loss proof.

## Yellow Advisories

- PK10-PK13 remain required before any migration-safe or data-loss-proof claim:
  storage invariant checking, backup, import dry run, and restore rollback are
  not yet PK-proven.
- Degradation metadata is inspectable in the persistence helper contract and
  tests, but no UI review surface or durable degradation ledger is implemented
  by PK09.
- Full unit/UI suite, physical-device proof, signed archive proof, hosted CI,
  public accessibility proof, migration/import/export proof, sync/cloud proof,
  and performance-budget proof were not run and are not claimed.

## What This Proves

- Current repository raw-value fallbacks can route through a shared typed
  degradation contract.
- Unknown persisted enum raw values can fall back deterministically, or to nil
  for optional values, while preserving metadata that requires later review.
- Legacy Capture status aliases remain mapped without treating them as hidden
  migration safety.

## What This Does Not Prove

- This does not prove migration execution safety, import/export safety,
  data-loss-proof storage, sync readiness, cloud readiness, all-tests-pass,
  performance budgets, physical-device behavior, public accessibility
  conformance, privacy compliance, TestFlight readiness, App Store readiness,
  release readiness, or production readiness.

## Next Eligible Batch

PK10 Storage Invariant Checker.

## Release / No-Claim Boundary

No release, migration-safe, data-loss-proof, privacy compliance, accessibility
compliance, physical-device, App Store, TestFlight, production-readiness,
company-ready, hosted-CI, sync/cloud, hosted-AI, chatbot, or best-local-AI claim
is made.
