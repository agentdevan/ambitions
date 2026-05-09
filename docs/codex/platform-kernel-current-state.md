# Platform Kernel Current State

<!-- markdownlint-disable MD013 -->

Status: Active Platform Kernel state mirror. Owner evidence remains source code,
raw logs, batch reports, and `docs/codex/BATCH_REGISTRY.md`.
Date: 2026-05-08

## Current Position

- PK00-PK41 is active planned scope for local backend/platform hardening.
- PK00 Current Backend Proof Baseline is complete / Green with accepted Yellow
  follow-ups as a report-only backend/platform proof baseline.
- PK01 Package/Module Boundary Scaffold is complete / Accepted Yellow as a
  docs-only future module-boundary scaffold. It did not move code or change
  package/project files.
- PK02 Architecture Boundary Scanner is complete / Accepted Yellow as local
  non-mutating scanner tooling. Current findings are Yellow boundary drift
  evidence, not a package-cleanliness claim.
- PK03 AppUnitOfWork Foundation is complete / Green as a local SwiftData
  transaction boundary. It adds receipt metadata and focused persistence proof
  for multi-record commit and thrown-error rollback before save.
- PK04 Atomic Goal Creation is complete / Green as focused SwiftData-backed
  goal-creation UnitOfWork proof. It routes planned/starter goal creation and
  clarification/blocked draft creation through a goal-creation UnitOfWork,
  records local receipt metadata, and proves thrown-error rollback leaves no
  partial Goal, Draft, or Step state.
- PK05 Atomic Clarification / Materialization is complete / Green as focused
  SwiftData-backed clarification answer write-back proof. It routes refreshed
  persisted drafts and optional materialized/revised Goals through the local
  UnitOfWork seam and proves injected rollback preserves pre-existing Goal,
  Step, and Draft state.
- PK06 Atomic Capture Promotion is complete / Green as focused SwiftData-backed
  Capture promotion proof. It routes deterministic Goal preparation plus new
  Goal, persisted Draft, and promoted Capture writes through one local
  UnitOfWork and proves injected rollback before Capture save leaves no
  Goal/Draft residue.
- AFI01 Canon Language Purge, AFI02 IA Hierarchy Lock, AFI03 Flagship Object
  Silhouettes, AFI04 Material System Proof, AFI05 Shell And Continuity Chrome,
  AFI06 Today Reality Meridian, AFI07 Goals Constellation Atlas, and AFI08
  Capture Atmosphere Composer, AFI09 Time LifeShape Field, AFI10 You User
  System Profile, AFI11 Trust Seam And Receipts, AFI12 Accessibility And
  State Proof, AFI13 Visual QA And Drift Gallery, AFI14 Cross-Surface
  Coherence Review, AFI15 Founder Acceptance Review, and AFI16 Release-Claim
  Safety Review are complete / Accepted Yellow under the active AFI insertion
  overlay.
- PK07 Storage Schema Version Ledger is complete / Green as an inert local
  version-ledger contract for current SwiftData model families and the portable
  snapshot schema. It does not implement migrations.
- PK08 Migration Plan Scaffold is complete / Green as an inert local migration
  planning scaffold over the storage version ledger. It describes no-change,
  version-change, added-type, and removed-type plans with required future
  safety gates while keeping migration execution blocked.
- PK09 Unknown Persisted Value Degradation is complete / Green as a
  persistence-local forward-compatible raw-value degradation contract. It
  routes unknown persisted enum raw values through deterministic fallbacks or
  optional nil fallbacks with review-blocking degradation metadata, without
  executing migrations.
- PK10 Storage Invariant Checker is complete / Green as a read-only SwiftData
  invariant checker for broken references, malformed payloads/snapshots, and
  unknown raw values before backup/import/restore work.
- PK11 Pre-Migration Backup is complete / Green as a local backup gate that
  prepares an inspectable portable snapshot package and typed receipt before
  later dry-run/restore work while keeping migration execution blocked.
- PK12 Staged Portable Import Dry Run is complete / Green as a local portable
  snapshot import dry-run report for replace and merge modes. It reports
  would-reset/would-import counts, conflicts, warnings, and no-durable-mutation
  safety state without saving, resetting, restoring, or importing data.
- PK13 Restore Rollback is complete / Green as a storage-local portable restore
  rollback wrapper. It preflights incoming and rollback packages, attempts the
  requested import, and restores the rollback package if import throws.
- PK14 Durable Command/Event Ledger is the next eligible global batch.
  PK14-PK41 remain active planned Platform Kernel scope.
- Current repo evidence shows local SwiftData-backed persistence, portable
  snapshot contracts/services, runtime service factories/contracts,
  notification foundations, EventKit integration services, external snapshot
  contracts/writers/builders, and broad domain/test coverage.
- Existing PFC/AOS/LDI work contains valuable platform, persistence, privacy,
  sync-posture, side-effect, and intelligence-boundary evidence, but it does
  not replace remaining PK proof unless a PK batch explicitly reconciles it.

## Active No-Claims

This state file does not claim production readiness, backend 100/100, migration
safety, data-loss-proof storage, sync readiness, cloud readiness, AI readiness,
privacy compliance, CI green, App Store readiness, TestFlight readiness,
physical-device proof, public accessibility conformance, or performance-budget
proof.

## Current Known Risks

- AppUnitOfWork single-context commit/rollback, SwiftData-backed atomic goal
  creation, clarification/materialization write-back, and Capture promotion are
  PK-proven by focused persistence/goal/capture tests.
- Storage schema version ledger coverage is PK-proven by PK07. Migration plan
  mutation gate scaffolding and execution blocking are PK-proven by PK08.
  Unknown persisted value degradation is PK-proven by PK09. Storage invariant
  checking is PK-proven by PK10. Pre-migration backup is PK-proven by PK11.
  Focused replace/merge import dry-run reporting is PK-proven by PK12. Focused
  restore rollback wrapper behavior is PK-proven by PK13. Arbitrary migration
  safety and data-loss-proof behavior remain non-claims.
- Side effects are present in platform-adjacent paths, but SideEffectLedger
  isolation is not yet PK-proven.
- Sync-readiness primitives, conflict policy, and manual portable merge are not
  yet PK-proven.
- Intelligence claim boundaries exist in AOS/LDI evidence, but PK32-PK34 have
  not reconciled them against backend/runtime paths.

## Next Eligible

PK14 Durable Command/Event Ledger.
