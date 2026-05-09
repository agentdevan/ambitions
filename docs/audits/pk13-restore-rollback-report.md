# PK13 Restore Rollback Report

<!-- markdownlint-disable MD013 -->

Date: 2026-05-08
Batch: PK13 Restore Rollback
Status: Green

## Scope

PK13 adds a storage-local portable restore rollback wrapper. It preflights the
incoming package, prepares or accepts a rollback package, preflights that
rollback package, attempts the requested import, and restores the rollback
package if the requested import throws.

## Files Changed

- `Native/Ambitions/Persistence/PortableRestoreRollback.swift`
- `Native/AmbitionsTests/Persistence/PortableRestoreRollbackTests.swift`
- `.codex/state/active-batch.yml`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `docs/audits/platform-kernel-risk-register.md`
- `docs/audits/platform-kernel-train-report.md`
- `docs/codex/platform-kernel-current-state.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json`
- `docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md`
- `docs/codex/batch-trains/PK00_PK41_PLATFORM_KERNEL_TRAIN.md`
- `docs/audits/pk13-restore-rollback-report.md`

## Implementation Summary

- Added `PortableRestoreRollbackStatus` and
  `PortableRestoreRollbackReport`.
- Added `PortableRestoreRollbackService` as a wrapper over existing
  `PortableSnapshotServicing`.
- The service blocks before import when incoming dry-run or rollback-package
  dry-run fails.
- The service attempts rollback with `.replaceLocalStore` only after the
  requested import throws.
- The report keeps `durableMutationAllowed` false and includes an explicit
  no-claim boundary.

## Proof

- `xcodegen generate`: passed.
- Initial focused `PortableRestoreRollbackTests` run failed to compile because
  actor-isolated test reads were placed inside XCTest autoclosures; the test
  code was narrowed by assigning awaited values to locals.
- Focused `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/PortableRestoreRollbackTests`: passed, 3 tests, 0 failures.
- `git diff --check`: passed.
- `jq empty docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json`: passed.

## Validation Scripts

The closeout validation scripts were run with non-blocking `|| true` handling
where required by the train protocol:

- `scripts/run-doc-qa.sh || true`: existing broad historical advisory backlog
  only.
- `scripts/batch-train-gate-check.sh || true`: expected dirty-tree Yellow
  before commit while PK13 files were open.
- `scripts/swiftui-architecture-scan.sh || true`: existing advisory
  extraction/responsibility backlog only.
- `scripts/global-train-next-batch.sh || true`: PK14 Durable Command/Event
  Ledger after queue/status updates.

## EFC Applicability

Invoked. PK13 inherits the EFC storage/data-safety proof overlay. This pass
proves the covered rollback wrapper can restore a local rollback package after
a scripted import failure and can complete a real in-memory replace import
without rollback. It does not prove arbitrary migration safety or data-loss
impossibility.

## Yellow Advisories

- Full unit/UI suite was not run.
- Restore rollback is PK-proven only for the focused wrapper paths tested here.
- Durable migration execution, destructive schema migration, sync/cloud,
  release readiness, migration-safe, and data-loss-proof claims remain blocked.
- Existing docs QA and architecture scan advisory backlogs remain Yellow.

## What This Proves

PK13 proves a typed restore rollback wrapper exists for portable snapshot import
attempts and that it can restore a rollback package after a failed import in
the covered focused scenario.

## What This Does Not Prove

This does not prove durable migration execution, schema mutation safety,
data-loss-proof behavior, sync readiness, privacy compliance, public
accessibility conformance, physical-device verification, TestFlight readiness,
App Store readiness, production readiness, or release readiness.

## Next Eligible Batch

PK14 Durable Command/Event Ledger.

## No-Claim Boundary

No migration-safe, data-loss-proof, release-ready, production-ready, App
Store-ready, TestFlight-ready, privacy-compliant, accessibility-compliant,
physical-device-proven, sync/cloud-ready, or best-local-AI claim is made.
