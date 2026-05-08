# PK00-PK41 Platform Kernel Train

<!-- markdownlint-disable MD013 -->

Status: Active planned platform/backend train for Ambitions local architecture.
Date: 2026-05-08

## Purpose

The Platform Kernel train hardens Ambitions' local backend/platform layer before
additional storage, sync, intelligence, side-effect, or large UI expansion work.
It makes the app transaction-safe, migration-safe, receipt-backed,
privacy-governed, side-effect-isolated, diagnostics-visible, sync-ready in
architecture, intelligence-claim-bounded, performance-budgeted, and locally
validated before those claims can be used by later batches.

PK supersedes older backend/platform sequencing where dependency order
conflicts. Historical PFC/AOS/LDI evidence remains valid, but future execution
must route through PK when a batch touches transaction boundaries, persistence,
migration, restore, event/receipt storage, side effects, diagnostics, sync,
intelligence claims, performance scale, or module extraction.

## Non-Goals

- No production readiness, backend 100/100, sync readiness, migration safety,
  privacy compliance, CI green, release readiness, App Store readiness,
  TestFlight readiness, physical-device proof, or public accessibility proof is
  claimed by this train document.
- PK00 is baseline/report-only and must not change production code.
- PK docs do not approve destructive migration, backend/server introduction,
  hosted AI, account sync, CloudKit runtime, workflow files, signing changes,
  or broad feature implementation by themselves.

## Hard Red Stops

- Continuing risks data loss or destructive storage/migration behavior.
- Persisted-data corruption appears and requires a human decision.
- A migration/storage change lacks backup or rollback proof.
- App compilation fails and the repair path is not narrow and obvious.
- A package/project split causes broad unresolved build failure.
- Dirty worktree changes cannot be safely classified.
- Remote/main state is unsafe to push without human intervention.
- Required credentials or permissions are unavailable.
- A serious privacy/security issue cannot be fixed narrowly.

Yellow does not stop the train unless it touches data safety. Yellow must record
an owner, safety reason, no-claim boundary, and next review condition.

## Ordered Train

| Batch | Title | Type | Dependency rationale |
| --- | --- | --- | --- |
| PK00 | Current Backend Proof Baseline | Audit | Establishes live repo truth before any platform mutation. |
| PK01 | Package/Module Boundary Scaffold | Architecture | Names package/module boundaries before extraction. |
| PK02 | Architecture Boundary Scanner | Tooling | Adds repeatable drift detection before larger moves. |
| PK03 | AppUnitOfWork Foundation | Runtime foundation | Creates transaction boundary before multi-repository writes. |
| PK04 | Atomic Goal Creation | Runtime | Proves goal creation through UnitOfWork. |
| PK05 | Atomic Clarification / Materialization | Runtime | Extends atomicity to clarification/materialization. |
| PK06 | Atomic Capture Promotion | Runtime | Protects Capture promotion before storage/migration work widens. |
| PK07 | Storage Schema Version Ledger | Storage | Names schema versions before migration plans. |
| PK08 | Migration Plan Scaffold | Storage | Plans migrations before unknown value handling. |
| PK09 | Unknown Persisted Value Degradation | Storage | Ensures forward-compatible degradation. |
| PK10 | Storage Invariant Checker | Storage | Detects corruption before backup/import/restore. |
| PK11 | Pre-Migration Backup | Storage | Adds backup requirement before migration execution. |
| PK12 | Staged Portable Import Dry Run | Backup/restore | Validates import without mutation. |
| PK13 | Restore Rollback | Backup/restore | Proves rollback before durable import/restore claims. |
| PK14 | Durable Command/Event Ledger | Events | Provides durable event spine before receipts. |
| PK15 | Receipt Backend | Trust | Persists/query-bounds receipts after event spine. |
| PK16 | Trust History Query | Trust | Enables read paths over receipt/event truth. |
| PK17 | Today Read Model Extraction | Service decomposition | Starts with read-only Today model extraction. |
| PK18 | Today Command Handler Extraction | Service decomposition | Separates Today commands after read model. |
| PK19 | Goals Query/Projector Extraction | Service decomposition | Separates Goals query/projection after Today boundary. |
| PK20 | Capture Service Extraction | Service decomposition | Extracts Capture behind atomic promotion rules. |
| PK21 | Plan Service Extraction | Service decomposition | Extracts Plan after command/read boundaries exist. |
| PK22 | SideEffectLedger Foundation | Side effects | Creates side-effect isolation before platform outputs. |
| PK23 | Notifications Through SideEffectLedger | Side effects | Routes notification effects through ledger. |
| PK24 | EventKit Through SideEffectLedger | Side effects | Routes calendar/reminder effects through ledger. |
| PK25 | External Snapshots Through SideEffectLedger | Side effects | Routes widget/share/Live Activity snapshots through ledger. |
| PK26 | Privacy Classification System | Privacy/data controls | Classifies data before diagnostics and data-control commands. |
| PK27 | Diagnostic Ledger | Diagnostics | Adds diagnostics after privacy classes are known. |
| PK28 | Data Control Commands | Data controls | Adds export/delete/review commands after diagnostics/privacy. |
| PK29 | Entity Revision And Tombstones | Sync readiness | Adds local revision/tombstone primitives before conflict policy. |
| PK30 | Conflict Policy Engine | Sync readiness | Defines merge/conflict policy before manual sync merge. |
| PK31 | Manual Portable Sync Merge | Sync readiness | Keeps sync manual/local until proof allows more. |
| PK32 | Knowledge Claim Boundary Hardening | Intelligence | Locks claim boundaries before recommendation evidence. |
| PK33 | Recommendation Evidence Model | Intelligence | Adds evidence model after claim boundaries. |
| PK34 | Intelligence Quarantine | Intelligence | Quarantines uncertain/generated intelligence before exposure. |
| PK35 | Large-Store Fixture Generator | Performance | Creates scale fixtures before budget proof. |
| PK36 | Performance Budgets | Performance | Defines budgets over large fixtures. |
| PK37 | Derived Read-Model Cache | Performance | Adds caches only after budgets and invalidation needs are known. |
| PK38 | Move Domain To Package | Modularization | Moves domain only after storage/runtime safety gates. |
| PK39 | Move Storage To Package | Modularization | Moves storage after schema/migration/backup gates. |
| PK40 | Move Runtime To Package | Modularization | Moves runtime after side-effect and command boundaries. |
| PK41 | Move Feature Engines To Package | Modularization | Moves feature engines after package boundaries are proven. |

## Validation Requirements

Every PK batch must run `git diff --check` and the route-appropriate ACX/local
bundle when available. Production Swift changes require `xcodegen generate` and
the narrowest safe focused build/test lane. Storage, migration, backup, restore,
sync-readiness, side-effect, privacy, and diagnostic batches must record
explicit Green/Yellow/Red data-safety classification.

## Closeout Requirements

Each PK batch closeout updates:

- `docs/audits/platform-kernel-train-report.md`
- `docs/audits/platform-kernel-risk-register.md`
- `docs/codex/platform-kernel-current-state.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `docs/codex/BATCH_REGISTRY.md`

## Claims Policy

Claim only the proof produced in the current batch. Do not claim production
ready, backend 100/100 complete, migration-safe, data-loss-proof, sync-ready,
cloud-ready, AI-ready, privacy compliant, App Store ready, TestFlight ready, CI
green, all tests pass, physical-device verified, or performance-budget proven
without matching raw evidence.

## Rollback Policy

Prefer forward repair for narrow issues. Revert only current-batch Codex-owned
changes when the batch cannot be made safe. Never discard user-authored dirty
work, persisted-data evidence, migration findings, or human review notes.

## Global Integration

PK00 is the next eligible backend/platform batch after this integration unless
a dirty or half-complete active batch must be closed first. Remote sync,
remote-intelligence, migration, package-split, and major platform feature work
must wait for the relevant PK prerequisites, especially PK07-PK13, PK22-PK34,
and PK38-PK41.
