# Codex Batch Prompt — T-B: Local Data Foundation

## Objective

Harden domain, SwiftData, repositories, migrations, and local data integrity.

## Scope

### AMB-FR-005 — Decontaminate life-context domain fixtures

Severity: Critical
Priority: P0
Labels: domain, fixtures, runtime, prelaunch
Dependencies: None

Affected files:
- `Native/Ambitions/Domain`
- `Native/Ambitions/Runtime`
- `Native/AmbitionsTests`

Problem: Domain fixtures may contain off-domain or stale scenario vocabulary.

Implementation: Replace non-Ambitions fixtures with neutral, privacy-safe Ambitions-native personas. Remove obsolete enum references and fixture bleed.

Acceptance: No off-domain fixture vocabulary remains in compiled domain source.

Validation: Build, fixture lint, runtime scenario tests.

Rollback: Archive old fixtures only in docs, never active source.

### AMB-FR-006 — SwiftData temporal and enum type-safety pass

Severity: Critical
Priority: P0
Labels: swiftdata, persistence, migration, prelaunch
Dependencies: AMB-FR-005

Affected files:
- `Native/Ambitions/Persistence`

Problem: Persistence can become fragile if dates, states, and enums rely on raw strings.

Implementation: Convert persisted temporal fields to Date where appropriate and isolate raw enum storage to tested adapters.

Acceptance: Core persisted entities no longer depend on ad hoc string ordering.

Validation: Migration harness, repository round-trip tests, deterministic ordering tests.

Rollback: Add v1-to-v2 migration adapters and backup export path.

### AMB-FR-007 — Normalize persistence away from blob-first reads

Severity: Critical
Priority: P0
Labels: swiftdata, persistence, architecture, prelaunch
Dependencies: AMB-FR-006

Affected files:
- `Native/Ambitions/Persistence`

Problem: Snapshot blobs should not be the ordinary read path for key product objects.

Implementation: Normalize primary fields for goals, steps, receipts, context, closure, recovery, and time placement. Keep snapshots for audit/export boundaries.

Acceptance: Today, Goals, Time, and You reads do not require decoding whole object snapshots.

Validation: Repository query tests, performance baseline, storage comparison.

Rollback: Maintain snapshot fallback for one migration cycle.

### AMB-FR-008 — Explicit schema migration and store recovery system

Severity: Critical
Priority: P0
Labels: swiftdata, migration, data-integrity, prelaunch
Dependencies: AMB-FR-006, AMB-FR-007

Affected files:
- `Native/Ambitions/Persistence`
- `Native/AmbitionsTests/Persistence`

Problem: The store needs explicit migration, recovery, corruption handling, and proof artifacts.

Implementation: Add schema versioning, migration plans, seeded historical stores, corruption handling, recovery mode, and migration receipts.

Acceptance: Every persisted model revision has a tested upgrade path.

Validation: Migration matrix, seeded old-store upgrade tests, corrupt-store simulation.

Rollback: Export backup before migration and support explicit safe reset.

### AMB-FR-009 — Repository query performance and deterministic ordering gates

Severity: High
Priority: P1
Labels: persistence, performance, testing
Dependencies: AMB-FR-007, AMB-FR-008

Affected files:
- `Native/Ambitions/Persistence`
- `Native/AmbitionsTests/Persistence`

Problem: Core local reads need reliable ordering and bounded query work.

Implementation: Add deterministic sorting, query limits, large fixtures, and budget gates for repository calls.

Acceptance: Core repository reads have deterministic ordering and measured budgets.

Validation: Repository benchmark tests and deterministic result snapshots.

Rollback: Keep old repository methods as deprecated internal helpers.

### AMB-FR-010 — Structured life context and Memory Lens data basis

Severity: High
Priority: P1
Labels: you, memory, privacy, persistence
Dependencies: AMB-FR-005, AMB-FR-007

Affected files:
- `Native/Ambitions/Features/You`
- `Native/Ambitions/Domain`
- `Native/Ambitions/Persistence`

Problem: You and Memory Lens need structured, editable, provenance-aware local data.

Implementation: Back memory/profile/life-context display with structured local records, provenance, confidence, edit/reset controls, and privacy-safe indexing.

Acceptance: User can inspect, edit, reset, and understand local life-context records.

Validation: You feature tests, reset tests, provenance rendering tests, privacy redaction tests.

Rollback: Keep projected summaries as display fallback.

## Batch rules

- Keep the batch scoped to listed issues.
- Do not use generic task-manager terminology.
- Do not use cloud/external LLMs as core runtime architecture.
- Add or update tests before declaring Green.
- Add proof artifacts under `docs/audits/flagship-remediation/`.
- End with summary, files changed, validation, proof artifacts, risks, rollback path, and Green / Yellow / Red status.
