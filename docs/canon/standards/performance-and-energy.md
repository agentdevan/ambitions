+++
spec_id = "STANDARD-PERFORMANCE-ENERGY"
title = "Performance and Energy"
kind = "standard"
status = "normative"
owner_domain = "standard-performance-energy"
canon_revision = 1
profile = "standard-v1"
owns_concepts = [
  "engineering.performance.registry",
  "engineering.performance.context",
  "engineering.performance.claim-proof",
  "engineering.performance.regression",
  "engineering.performance.resource-aware",
  "engineering.performance.calibration-gap",
]
inherits = ["CONST-PROOF-EVIDENCE-001"]
depends_on = ["CONSTITUTION"]
source_owners = ["Native/Ambitions/Quality/Performance/", "Native/Ambitions/Diagnostics/"]
+++

# Performance and Energy

This standard defines measurable resource behavior. It invents no numeric threshold where no measured budget exists.

## PERF-001 — Product-wide budget registry
- **Concept:** `engineering.performance.registry`
- **Modality:** `MUST`
- **Scope:** Launch, interaction, navigation, mutations, projections, Search, Time, Goal Path, Capture, recurrence, import, continuity, migration, backup/restore, attachments, extensions, memory, disk, and energy
- **Status:** `normative`
- **Verification:** `AUDIT-PERFORMANCE-REGISTRY-001`
- **Supersedes:** none

Every material operation MUST resolve to a measured budget or a structured calibration gap. Missing measurements MUST NOT be replaced with invented numbers.

The repository MUST maintain measured budgets for launch, first interaction, root switching, mutation, projection refresh, Search, Time scrolling, Goal Path interaction, Capture opening and draft save, recurrence, import, sync, migration, backup and restore, attachments, widgets, App Intents, memory, disk growth, and energy.

## PERF-002 — Complete budget context
- **Concept:** `engineering.performance.context`
- **Modality:** `MUST`
- **Scope:** Performance and energy budgets
- **Status:** `normative`
- **Verification:** `AUDIT-PERFORMANCE-CONTEXT-001`
- **Supersedes:** none

Each budget MUST state device floor, OS, build configuration, representative data scale, warm/cold state, tool, percentile and maximum, memory/energy/storage measures where relevant, and regression threshold.

## PERF-003 — No unverifiable performance claim
- **Concept:** `engineering.performance.claim-proof`
- **Modality:** `MUST NOT`
- **Scope:** Performance, responsiveness, scale, memory, disk, and energy claims
- **Status:** `normative`
- **Verification:** `REVIEW-PERFORMANCE-CLAIM-001`
- **Supersedes:** none

Unmeasured language such as fast, instant, efficient, lightweight, or device-ready MUST NOT substitute for current measurements tied to the tested commit, environment, tool, fixture scale, samples, and result.

Performance claims MUST require current measurements tied to commit and environment.



Performance proof MUST record the current tool or procedure, device or simulator, OS, build SHA, thresholds, results, regressions, and any skipped measurements for the scoped claim.

## PERF-004 — Regression blocking
- **Concept:** `engineering.performance.regression`
- **Modality:** `MUST`
- **Scope:** Approved required budgets
- **Status:** `normative`
- **Verification:** `TEST-PERFORMANCE-REGRESSION-001`
- **Supersedes:** none

A required budget regression beyond declared tolerance MUST fail the affected performance validation until repaired or the budget is changed using current measurements and documented user impact.

## PERF-005 — Resource-aware scheduling
- **Concept:** `engineering.performance.resource-aware`
- **Modality:** `MUST`
- **Scope:** Material foreground and background work
- **Status:** `normative`
- **Verification:** `TEST-RESOURCE-AWARE-001`
- **Supersedes:** none

Work MUST be bounded and cancellable and respect foreground responsiveness, Low Power Mode, thermal state, protected-data availability, storage pressure, and platform background limits.

## GAP-PERFORMANCE-CALIBRATION-ATLAS-001 — Missing budgets remain structured gaps
- **Concept:** `engineering.performance.calibration-gap`
- **Modality:** `MUST`
- **Scope:** Atlas specifications without measured numeric budgets
- **Status:** `normative`
- **Verification:** `AUDIT-PERFORMANCE-CALIBRATION-GAPS-001`
- **Supersedes:** none

Where no measured numeric budget exists, the Atlas MUST retain a calibration gap with operation, device/OS/build/tool, data scale, percentile/maximum, resource measures, and regression rule; it MUST NOT invent a number.

Budget changes require current measurements, user impact, regression comparison, and rollback handling; implementation difficulty alone is insufficient.

<!-- canon-section: purpose -->
Make latency, responsiveness, memory, disk, scale, and energy obligations measurable and honest.
<!-- canon-section: scope -->
Applies to all specifications and implementation lanes with material resource behavior.
<!-- canon-section: requirements -->
The requirements consolidate useful Article 31 and govern specification-local resource contracts.
<!-- canon-section: exceptions -->
No exception is granted for implementation difficulty alone.
<!-- canon-section: verification -->
Verify with the deterministic budget/gap registry and exact-commit instrument, metric, storage, memory, responsiveness, and energy evidence appropriate to scope.
<!-- canon-section: source-ownership -->
`Quality/Performance/` owns evidence lanes, `Diagnostics/` owns safe instrumentation, and each subsystem owns its budget;
<!-- canon-section: proof -->
Verification includes device/OS/build, tool, fixture scale, warm/cold state, samples, percentile/maximum, memory/energy/storage where relevant, result, and comparison.
<!-- canon-section: amendment-impact -->
When performance behavior changes, update affected budgets, fixtures, tools, source/tests, power/thermal/storage impact, and rollback handling.
