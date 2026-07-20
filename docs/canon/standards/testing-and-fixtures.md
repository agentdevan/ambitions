+++
spec_id = "STANDARD-TESTING-FIXTURES"
title = "Testing and Fixtures"
kind = "standard"
status = "normative"
owner_domain = "standard-testing-fixtures"
canon_revision = 1
profile = "standard-v1"
owns_concepts = [
  "engineering.testing.lanes",
  "engineering.testing.fixtures",
  "engineering.testing.regression",
  "engineering.testing.failure-injection",
  "engineering.testing.no-theater",
  "engineering.testing.property-priorities",
  "engineering.testing.coverage-meaning",
  "engineering.reliability.failure-taxonomy",
  "engineering.reliability.diagnostics",
  "engineering.reliability.health",
  "engineering.reliability.crash-hang",
  "engineering.reliability.incident",
  "engineering.reliability.no-silent-repair",
  "test.scope-matrix",
  "test.runtime-contract",
  "test.scenario-executability",
]
inherits = ["CONST-PROOF-EVIDENCE-001", "LAW-DATA-LOSS-STOP-SHIP-001"]
depends_on = ["CONSTITUTION", "SYSTEM-DIAGNOSTICS", "SYSTEM-IMPORT-EXPORT-REPAIR"]
source_owners = ["Native/Ambitions/Quality/", "Native/Ambitions/Diagnostics/"]
+++

# Testing and Fixtures

This standard owns cross-cutting executable validation, fixture integrity, failure injection, and reliability rules.

## TEST-001 — Applicable evidence lanes
- **Concept:** `engineering.testing.lanes`
- **Modality:** `MUST`
- **Scope:** Changed behavior and acceptance
- **Status:** `normative`
- **Verification:** `AUDIT-TEST-LANES-001`
- **Supersedes:** none

Changed-file routing MUST run the applicable unit, property, runtime integration, persistence/migration, concurrency, UI, accessibility, visual, performance, security/fuzz, and release lanes. A skipped applicable lane is a validation failure unless the lane is unavailable and the affected behavior remains explicitly unverified.

## TEST-002 — Deterministic privacy-safe fixtures
- **Concept:** `engineering.testing.fixtures`
- **Modality:** `MUST`
- **Scope:** Test and proof data
- **Status:** `normative`
- **Verification:** `AUDIT-FIXTURE-CONTRACT-001`
- **Supersedes:** none

Fixtures MUST declare schema, clock, calendar, locale, time zone, seed, privacy class, origin, expected state, and scale where relevant; real private user data MUST NOT be used.

Test fixtures MUST NOT contain real private user data.

Production data MUST NOT leak into test fixtures.

## TEST-003 — Production escape regression
- **Concept:** `engineering.testing.regression`
- **Modality:** `MUST`
- **Scope:** Reproducible production or pre-release escapes
- **Status:** `normative`
- **Verification:** `AUDIT-BUG-REGRESSION-001`
- **Supersedes:** none

Each reproducible escape MUST receive a regression test that fails before repair or a documented technical reason automation is impossible plus a repeatable manual regression protocol.

## TEST-004 — Failure injection
- **Concept:** `engineering.testing.failure-injection`
- **Modality:** `MUST`
- **Scope:** Critical runtime, storage, migration, external-effect, continuity, attachment, and projection paths
- **Status:** `normative`
- **Verification:** `TEST-FAILURE-INJECTION-001`
- **Supersedes:** none

Critical paths MUST inject interruption and failure at every material phase and prove invariant preservation, truthful result, recovery, idempotency, and rollback.

## TEST-005 — No proof theater
- **Concept:** `engineering.testing.no-theater`
- **Modality:** `MUST NOT`
- **Scope:** Required evidence
- **Status:** `normative`
- **Verification:** `AUDIT-NO-PROOF-THEATER-001`
- **Supersedes:** none

Blind sleeps, retry-until-pass, expected-failure completion, optional lookup that hides failure, source-string-only UI checks, or unrelated aggregate coverage MUST NOT pass the applicable validation lane.

A policy change that reduces constraint preservation, correction compliance, explanation quality, or scenario success MUST fail targeted regression coverage and MUST NOT be hidden by aggregate pass counts.

A silent quality regression MUST NOT pass tests.

## TEST-006 — Property-based priorities
- **Concept:** `engineering.testing.property-priorities`
- **Modality:** `MUST`
- **Scope:** Recurrence, time zones, ordering, idempotency, merge, migration, conversion round trips, and invariants
- **Status:** `normative`
- **Verification:** `TEST-PROPERTY-PRIORITIES-001`
- **Supersedes:** none

Where input space or ordering is combinatorial, applicable invariants MUST have bounded deterministic property-based coverage with reproducible seeds.

## TEST-007 — Coverage has behavioral meaning
- **Concept:** `engineering.testing.coverage-meaning`
- **Modality:** `MUST`
- **Scope:** Test coverage claims
- **Status:** `normative`
- **Verification:** `AUDIT-BEHAVIOR-COVERAGE-001`
- **Supersedes:** none

Required behaviors, states, failures, recovery, accessibility, privacy, offline, and proof obligations MUST map to exact tests; percentage alone is diagnostic.

Planning quality MUST be tested across sparse and dense schedules, travel, time-zone change, caregiving interruptions, low capacity, deadline pressure, conflicting Goals, recurrence, repeated deferral, new-user cold start, explicit corrections, and insufficient context.

Coverage percentage MUST be diagnostic only.

Required behaviors and failure states MUST be explicitly mapped to tests and proof.

## RELIABILITY-001 — Failure taxonomy
- **Concept:** `engineering.reliability.failure-taxonomy`
- **Modality:** `MUST`
- **Scope:** Data loss, corruption, crash, hang, mutation/projection failure, stale UI, external failure, conflicts, partial import, privacy breach, and visual/accessibility regression
- **Status:** `normative`
- **Verification:** `AUDIT-FAILURE-TAXONOMY-001`
- **Supersedes:** none

Failures MUST have explicit severity, user consequence, containment, recovery, owner, evidence, and stop-ship posture.

If a test, trace, or direct inspection reveals a product-quality failure, the applicable validation MUST fail until the defect is repaired.

## RELIABILITY-002 — Structured private-safe diagnostics
- **Concept:** `engineering.reliability.diagnostics`
- **Modality:** `MUST`
- **Scope:** Diagnostic events
- **Status:** `normative`
- **Verification:** `AUDIT-STRUCTURED-DIAGNOSTICS-001`
- **Supersedes:** none

Diagnostics MUST use stable categories, privacy annotations, correlation identity, bounded retention, and signposts while excluding private content by default.

## RELIABILITY-003 — Evidence-backed subsystem health
- **Concept:** `engineering.reliability.health`
- **Modality:** `MUST`
- **Scope:** Major subsystem health
- **Status:** `normative`
- **Verification:** `TEST-SUBSYSTEM-HEALTH-001`
- **Supersedes:** none

Health MUST be one of healthy, degraded, recoverable, quarantined, blocked, or unknown, backed by current evidence and user-visible only when action or interpretation changes.

## RELIABILITY-004 — Crash and hang response
- **Concept:** `engineering.reliability.crash-hang`
- **Modality:** `MUST`
- **Scope:** Crash and hang evidence
- **Status:** `normative`
- **Verification:** `REVIEW-CRASH-HANG-001`
- **Supersedes:** none

Response MUST define capture, redaction, symbolication, reproduction, severity, regression test, user impact, and rollback or forward-fix decision.

## RELIABILITY-005 — Incident lifecycle
- **Concept:** `engineering.reliability.incident`
- **Modality:** `MUST`
- **Scope:** P0/P1 incidents
- **Status:** `normative`
- **Verification:** `AUDIT-INCIDENT-LIFECYCLE-001`
- **Supersedes:** none

P0/P1 incidents MUST record containment, diagnosis, owner, repair, validation, impact, rollback/kill switch where available, postmortem, and regression prevention.

## RELIABILITY-006 — No silent repair
- **Concept:** `engineering.reliability.no-silent-repair`
- **Modality:** `MUST`
- **Scope:** Repair that changes canonical state
- **Status:** `normative`
- **Verification:** `TEST-NO-SILENT-REPAIR-001`
- **Supersedes:** none

Canonical repair MUST provide preview, backup or rollback protection, explicit commit, Receipt/History, and post-repair invariant proof.

Repair MUST NOT occur silently.

<!-- canon-section: purpose -->
Make executable evidence deterministic, behavior-mapped, privacy-safe, failure-complete, and resistant to proof theater.
<!-- canon-section: scope -->
Source, specifications, migrations, extensions, and incident work use the applicable deterministic fixture, failure, recovery, and evidence contracts in this standard.
<!-- canon-section: requirements -->
The requirements consolidate useful Articles 32 and 35 while system-specific observability and recovery remain in owning specifications.
<!-- canon-section: exceptions -->
Unautomatable behavior requires a documented technical rationale and repeatable manual protocol with environment, fixtures, expected result, and rollback handling.
<!-- canon-section: verification -->
Verify with deterministic test discovery, fixture audits, mutation/failure injection, scenario maps, logs, and direct inspection where automation cannot cover behavior.
<!-- canon-section: source-ownership -->
`Quality/` owns test/proof infrastructure, exact subsystem owners provide fixtures and hooks, and `Diagnostics/` owns redacted observability;
<!-- canon-section: proof -->
Validation records include commands, exits, logs, fixture identity, injected failures, mapped requirements, skipped applicable lanes, and defects.
<!-- canon-section: amendment-impact -->
When test behavior changes, update affected fixtures, privacy handling, lanes, CI routing, incident regressions, migrations, and rollback handling.

## TEST-SCOPE-MATRIX-001 — Test scope matrix

- **Concept:** `test.scope-matrix`
- **Modality:** `MUST`
- **Scope:** Implementation test planning
- **Status:** `normative`
- **Verification:** `AUDIT-TEST-SCOPE-MATRIX-001`
- **Supersedes:** none

Each changed scope MUST execute the applicable domain, projection, UI, accessibility, migration, recurrence, time-zone, import, sync, and extension tests.

## TEST-RUNTIME-CONTRACT-001 — Runtime contract proof

- **Concept:** `test.runtime-contract`
- **Modality:** `MUST`
- **Scope:** Runtime mutation contracts
- **Status:** `normative`
- **Verification:** `TEST-RUNTIME-CONTRACT-001`
- **Supersedes:** none

Runtime contract tests MUST prove command validation, idempotency, Receipt issuance, replay, rejection, rollback, and recovery.

## TEST-SCENARIO-EXECUTABILITY-001 — Scenario executability

- **Concept:** `test.scenario-executability`
- **Modality:** `MUST`
- **Scope:** Canonical scenarios
- **Status:** `normative`
- **Verification:** `TEST-SCENARIO-EXECUTABILITY-001`
- **Supersedes:** none

Each canonical scenario MUST be executable with deterministic fixtures, observable boundaries, expected outcomes, recovery, and proof assertions.
