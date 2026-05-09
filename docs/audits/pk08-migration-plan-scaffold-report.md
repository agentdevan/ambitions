# PK08 Migration Plan Scaffold Report

<!-- markdownlint-disable MD013 -->

Date: 2026-05-08
Batch: PK08 Migration Plan Scaffold
Result: Green

## Summary

PK08 adds an inert local migration plan scaffold on top of the PK07 storage
schema version ledger. The scaffold can describe no-change, stored-type version
change, added stored type, and removed stored type entries while keeping every
storage mutation plan blocked behind explicit future safety gates.

This is platform/storage planning infrastructure only. It does not run
migrations, mutate stored data, change SwiftData schemas, alter import/export
behavior, change UI behavior, or make release/readiness claims.

## Files Changed

- `Native/Ambitions/Persistence/StorageMigrationPlanScaffold.swift`
- `Native/AmbitionsTests/Persistence/StorageMigrationPlanScaffoldTests.swift`
- `.codex/state/active-batch.yml`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `docs/audits/platform-kernel-train-report.md`
- `docs/audits/platform-kernel-risk-register.md`
- `docs/codex/platform-kernel-current-state.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json`
- `docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md`

## Implementation

- Added `StorageMigrationPlanScaffold` as a deterministic planner from one
  `StorageSchemaVersionLedger` to another.
- Added migration plan actions for no change, version change, new stored type,
  and removed stored type.
- Added required mutation gates for storage invariant check, pre-migration
  backup, staged dry run, restore rollback plan, user review, and release-claim
  blocking.
- Added `StorageMigrationPlanValidator` so executable plans, duplicate entries,
  unsupported scaffold versions, unsupported ledger versions, and under-gated
  mutation plans fail validation.
- Preserved deterministic no-op behavior for the current ledger.

## Validation

- `xcodegen generate` passed.
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/StorageMigrationPlanScaffoldTests` passed, 4 tests, 0 failures.

## EFC Applicability

Invoked. PK08 touches storage migration planning and data-safety proof posture.
It records future mutation gates and keeps migration execution blocked. It does
not claim data-loss-proof migration behavior.

## No-Claim Boundary

PK08 does not prove migration safety, backup safety, import dry-run safety,
restore rollback safety, sync readiness, cloud readiness, production readiness,
App Store readiness, TestFlight readiness, privacy compliance, accessibility
compliance, physical-device proof, hosted CI proof, or all-tests-pass status.

## Next Eligible Batch

PK09 Unknown Persisted Value Degradation.
