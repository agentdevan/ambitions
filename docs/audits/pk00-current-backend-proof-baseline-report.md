# PK00 Current Backend Proof Baseline Report

<!-- markdownlint-disable MD013 -->

Date: 2026-05-08
Result: Green with accepted Yellow follow-ups
Batch: PK00 Current Backend Proof Baseline

## Closeout

Result: Green with accepted Yellow follow-ups
Batch: PK00 Current Backend Proof Baseline
Commit: pending
Files changed: docs/audits/pk00-current-backend-proof-baseline-report.md, docs/audits/platform-kernel-train-report.md, docs/audits/platform-kernel-risk-register.md, docs/codex/platform-kernel-current-state.md, docs/codex/BATCH_REGISTRY.md, .codex/reports/current-run-state.md, .codex/reports/current-batch-train-state.md, .codex/state/active-batch.yml
Behavior changed: none. PK00 is report-only and made no production Swift, persistence schema, runtime behavior, generated project, signing, entitlement, workflow, dependency, or release change.
Tests run: `git diff --check`; `python3 scripts/ai/acx_local.py bundle quick`; `python3 scripts/ai/acx_impact.py $(git diff --name-only) $(git ls-files --others --exclude-standard)`; `python3 scripts/ai/acx_local.py bundle docs`; `python3 scripts/ai/acx_local.py bundle batch-closeout`; `scripts/global-train-next-batch.sh`; `scripts/batch-train-gate-check.sh || true`; `scripts/run-doc-qa.sh || true`.
Tests not run: app build and focused Swift tests were not run because PK00 is a docs-only baseline with no production Swift, persistence schema, generated project, signing, entitlement, dependency, or app behavior change.
Known risks: transaction safety, migration safety, import rollback, side-effect isolation, sync readiness, intelligence quarantine, performance budgets, and package/module moves remain unproven by PK.
Yellows carried: pre-sync stash remains preserved and unapplied because it contains source-truth conflicts; docs QA has broad historical advisories; PK00 does not provide app build/test proof.
Rollback path: revert the PK00 docs/state commit; no app data or schema rollback is involved.
Claims: PK00 maps current backend/platform evidence and selects PK01 as the next eligible Platform Kernel batch.
Non-claims: no production readiness, backend 100/100, migration safety, data-loss-proof storage, sync readiness, cloud readiness, AI readiness, privacy compliance, CI green, all-tests-pass, performance-budget proof, App Store readiness, TestFlight readiness, physical-device proof, public accessibility conformance, or legal approval.
Next eligible batch: PK01 Package/Module Boundary Scaffold.

## Current Backend / Platform Map

The current app target is still wired from `Native/Ambitions` in `project.yml`.
`Package.swift` currently exposes `AmbitionsDesignSystem` and
`AmbitionsWidgetUI`; it does not yet split Domain, Persistence, Runtime, or
feature engines into separate package products. That makes PK01-PK02 necessary
before PK38-PK41 module moves.

Core local persistence is SwiftData-backed:

- `Native/Ambitions/Persistence/SwiftDataStore.swift` owns
  `AmbitionsPersistenceStore`, its `ModelContainer`, and per-operation
  `ModelContext` read/write wrappers.
- `Native/Ambitions/Persistence/SwiftDataModels.swift` defines SwiftData model
  records for goals, drafts, plans, plan sections, steps, progress evidence,
  feedback events, captures, teaching signals, event ledger entries, and app
  state.
- `Native/Ambitions/Persistence/SwiftDataRepositories.swift` maps domain values
  into records and back. Multiple records carry encoded snapshot/blob data
  alongside scalar fields.
- `Native/Ambitions/Persistence/PersistenceContracts.swift` defines repository
  contracts consumed by runtime and feature services.
- `Native/Ambitions/Persistence/PortableSnapshotService.swift` owns portable
  export/import/merge behavior.
- `Native/Ambitions/Persistence/SyncCapabilityContracts.swift` currently
  exposes local-only sync capability posture.

Runtime and service assembly are local:

- `Native/Ambitions/Runtime/AmbitionsRuntimeFactory.swift` assembles runtime
  services from repositories, local sync capability, and external snapshot
  reader/writer seams.
- `Native/Ambitions/Runtime/AmbitionsRuntimeServices.swift` and
  `Native/Ambitions/Services/*` provide repository-backed runtime memory,
  context, intelligence, and snapshot-refreshing services.

Side-effect paths are present but not centralized behind a PK ledger:

- `Native/Ambitions/Notifications/LocalNotificationFoundation.swift` schedules
  local notifications from external snapshot state through
  `UNUserNotificationCenterClient`.
- `Native/Ambitions/Notifications/NextStepLiveActivityService.swift` refreshes
  Live Activity state from external snapshots.
- `Native/Ambitions/Integrations/CalendarReminders/EventKitIntegrationService.swift`
  owns EventKit calendar/reminder reads and writes behind local service
  protocols.
- `Native/Ambitions/ExternalSnapshots/ExternalSurfaceSnapshotWriter.swift`,
  `ExternalSurfaceSnapshotBuilder.swift`, and shared snapshot store contracts
  write external-surface snapshots for widgets, share extension, notifications,
  and Live Activity surfaces.

## Repository Write Paths

The main repository write path is `AmbitionsPersistenceStore.write`, which
creates a fresh `ModelContext`, disables autosave, runs a caller block, then
saves once if the context has changes. This is a useful low-level boundary, but
it is not yet an app-level UnitOfWork contract with cross-repository intent,
rollback reporting, durable receipts, or mutation classification.

Important write paths identified:

- Goal, draft, plan, step, evidence, feedback, capture, teaching signal, event
  ledger, and app-state save/delete paths in `SwiftDataRepositories.swift`.
- Full local reset in `AmbitionsPersistenceStore.resetAllData()`.
- Portable snapshot replace flow in `PortableSnapshotService.replaceLocalStore`,
  which resets the local store and then saves imported repositories in sequence.
- Portable snapshot merge flow in `PortableSnapshotService.mergeWithConflictReport`,
  which applies accepted incoming records across repositories.
- External snapshot writes through `ExternalSurfaceSnapshotWriter`.
- Notification scheduling/replacement through `LocalNotificationScheduler`.
- EventKit block/reminder/calendar writes through `EventKitIntegrationService`.

PK00 does not classify these as unsafe behavior. It classifies them as not yet
PK-proven for transaction safety, staged backup, rollback, and side-effect
isolation.

## Storage / Migration / Recovery Gaps

Current evidence includes SwiftData schema declarations, Codable snapshot/blob
bridges, local-only sync posture, portable snapshot export/import contracts,
legacy import service tests, and repository tests. PK00 did not find an active
PK-owned schema version ledger, migration plan scaffold, pre-migration backup
gate, staged portable import dry run, or restore rollback proof.

The highest-risk current gap is the portable replace flow: it can reset the
local store before sequential saves complete. Future PK12-PK13 work must prove
staging and rollback before Ambitions makes any migration-safe or
data-loss-proof claim.

## Current Test / Proof Inventory

Relevant local test files exist under `Native/AmbitionsTests`, including:

- `Persistence/PersistenceRepositoryTests.swift`
- `Persistence/PortableSnapshotServiceTests.swift`
- `Persistence/LegacyImportServiceTests.swift`
- `Persistence/CaptureServiceTests.swift`
- `Persistence/EventLedgerRepositoryTests.swift`
- `Persistence/SyncCapabilityTests.swift`
- `Runtime/AmbitionsRuntimeBoundaryTests.swift`
- `Runtime/AmbitionsRuntimeGoalIntelligenceServiceTests.swift`
- `Domain/FoundationPerformancePersistenceBudgetTests.swift`
- `Domain/ActionClosureReceiptModelsTests.swift`
- `App/LocalNotificationFoundationTests.swift`
- `App/EventKitIntegrationServiceTests.swift`
- `App/ExternalSurfaceSnapshotTests.swift`
- `App/ExternalWidgetProjectionTests.swift`

Hosted CI is not active proof in this repo state; `.github/workflows` is absent.
All validation claims must be local/Codex-operated unless future evidence
changes that truth.

## Validation Evidence

- `git diff --check`: exit 0.
- `python3 scripts/ai/acx_local.py bundle quick`: exit 0; raw logs under
  `.codex/logs/2026-05-08T09-49-05/`.
- `python3 scripts/ai/acx_impact.py $(git diff --name-only) $(git ls-files --others --exclude-standard)`: docs/codex route, suggested `docs` and `batch-closeout` bundles.
- `python3 scripts/ai/acx_local.py bundle docs`: exit 0; `acx-gate-all`
  Green with advisory scan findings; raw logs under
  `.codex/logs/2026-05-08T09-49-16/` and
  `.codex/logs/2026-05-08T09-49-17/`.
- `python3 scripts/ai/acx_local.py bundle batch-closeout`: exit 0;
  advisory CQS findings carried as Yellow; raw logs under
  `.codex/logs/2026-05-08T09-49-16/` and
  `.codex/logs/2026-05-08T09-49-17/`.
- `scripts/global-train-next-batch.sh`: exit 0, selected `PK01 Package/Module
  Boundary Scaffold`.
- `scripts/batch-train-gate-check.sh || true`: accepted Yellow because the
  worktree intentionally contained the PK00 docs/state edits before commit.
- `scripts/run-doc-qa.sh || true`: advisory historical backlog; lychee found
  640 total links, 0 errors, and 1 redirect. Logs were written under
  `docs/audits/doc-qa/20260508-094916-*`.

## PK Dependency Consequences

PK01 and PK02 should run before modularization or broad app-code movement.
PK03-PK06 should establish and prove UnitOfWork and atomic mutation behavior
before Ambitions expands backend-dependent feature mutation. PK07-PK13 should
prove schema ledger, migration plan, degradation, invariant checking, backup,
dry-run import, and rollback before any migration-safety claim. PK22-PK25
should route notifications, EventKit, and external snapshots through
SideEffectLedger before side-effect-isolation claims. PK29-PK34 remain hard
prerequisites for sync readiness and intelligence readiness claims.
