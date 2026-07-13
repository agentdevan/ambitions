+++
spec_id = "SYSTEM-DIAGNOSTICS"
title = "Diagnostics"
kind = "system"
status = "normative"
owner_domain = "system-diagnostics"
canon_revision = 1
profile = "system-v1"
owns_concepts = ["system.diagnostics.redacted-health", "system.diagnostics.non-authority"]
inherits = ["PRIVACY-VISIBILITY-001", "LAW-LOCAL-AUTHORITY-001", "CONST-PROOF-EVIDENCE-001", "LAW-DATA-LOSS-STOP-SHIP-001"]
depends_on = ["CONSTITUTION", "APP-DEGRADED-STATES", "SYSTEM-PRIVACY-DATA-CLASSIFICATION", "SYSTEM-PERSISTENCE-REPLAY", "SURFACE-YOU"]
source_owners = ["Native/Ambitions/Core/LocalRuntimeOS/Diagnostics/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/", "Native/Ambitions/Diagnostics/", "Native/Ambitions/Surfaces/You/", "Native/Ambitions/Quality/"]
+++

# Diagnostics

This shadow target specifies private, local, redacted diagnostics and user-understandable health. It does not establish analytics, telemetry, implementation completeness, privacy approval, incident closure, or release proof.

## SYSTEM-DIAGNOSTICS-HEALTH-001 — Health is evidence-backed, scoped, and redacted

- **Concept:** `system.diagnostics.redacted-health`
- **Modality:** `MUST`
- **Scope:** Commands, projections, stores, replay, sync, Source Atlas, privacy firewall, imports, external writes, and performance/resource state
- **Status:** `normative`
- **Verification:** `SCENARIO-SYSTEM-DIAGNOSTICS-HEALTH-001`
- **Supersedes:** none

Each major subsystem MUST report healthy, degraded, recoverable, quarantined, blocked, or unknown from current evidence with affected scope, freshness, correlation, safe actions, and privacy annotation. User-facing health appears only when action or interpretation changes and uses product language rather than raw architecture. Logs and support packages exclude private content by default.

Diagnostics MUST expose sync health, local-store health, index status, extension status, and a privacy-reviewed debug export.

## SYSTEM-DIAGNOSTICS-AUTHORITY-001 — Diagnostics observe and propose; they never decide or repair silently

- **Concept:** `system.diagnostics.non-authority`
- **Modality:** `MUST NOT`
- **Scope:** Runtime inspection, support export, health checks, incident response, and repair routing
- **Status:** `normative`
- **Verification:** `AUDIT-SYSTEM-DIAGNOSTICS-NO-MUTATION-001`
- **Supersedes:** none

A diagnostic may produce a redacted diagnosis and typed repair proposal; any repair that changes state requires preview, rollback/backup protection, runtime Command/Event/Projection/Receipt/Replay, and post-repair invariants.

## Completeness contract

<!-- canon-section: responsibility-non-responsibility -->
Owns structured categories, correlation/signposts, bounded retention, subsystem health, privacy annotation, user diagnostics presentation model, reviewed support export, and incident evidence routing. It does not own product policy, canonical mutation, repair execution, telemetry by default, or proof-status promotion.

<!-- canon-section: inputs-outputs -->
The contract consumes redacted subsystem signals and emits scoped health and safe actions.
The contract consumes redacted runtime/store/projection/privacy/sync/import/effect/performance signals, policy revision, freshness, and correlation IDs. It emits scoped health, redacted traces/diagnosis, safe inspection actions, repair proposal link, and reviewed diagnostic export manifest.

<!-- canon-section: authority-boundary -->
`Core/LocalRuntimeOS/Diagnostics/` reads bounded inspector interfaces; `Inspection/` owns history facts; `PrivacySecurity/` redacts; app `Diagnostics/` and You present. Diagnostics cannot access unrestricted private values or write canonical stores.

<!-- canon-section: data-classification -->
Diagnostic data is redacted local metadata. Raw titles, notes, schedules, attachments, proof, behavior context, tokens, keys, and payloads are excluded by default; explicit support export previews every field/destination and remains user-controlled egress.

<!-- canon-section: state-model -->
Health binds subsystem/scope, category/severity, evidence source and age, correlation, privacy class, current status, safe action set, export inclusion, incident link, and resolution evidence.

<!-- canon-section: failure-recovery -->
Logging/inspection/export failure never blocks core or fabricates health. Overflow coalesces or drops low-priority diagnostics visibly; corrupt diagnosis is quarantined. Recovery re-reads current facts and preserves unresolved incident/history evidence.

<!-- canon-section: local-network-boundary -->
Health, traces, diagnosis, and repair routing operate locally/no-account. No telemetry or support upload is implicit; any diagnostic export is explicitly previewed/redacted egress. Server profiling and private analytics are excluded.

<!-- canon-section: determinism -->
Stable evidence, freshness, privacy policy, and health rules select the same status/action set. Diagnostic timing cannot change canonical state or the truth of the operation observed.

<!-- canon-section: observability -->
Local counters expose diagnostic volume, retention, and export behavior.
The diagnostic system observes itself through bounded volume/drop/retention/export counters and stable correlation while excluding private values. Evidence age, environment, source revision, and gaps remain explicit.

<!-- canon-section: source-ownership -->
Canonical ownership is divided among runtime Diagnostics, Inspection, PrivacySecurity, app presentation, and Quality.
Exact targets are `Core/LocalRuntimeOS/Diagnostics/`, `Inspection/`, and `PrivacySecurity/`; app `Diagnostics/` and `Surfaces/You/` present, while `Quality/` owns proof. app-wide consumption, calibrated budgets, incident operations, privacy approval, and release evidence remain separate.

<!-- canon-section: tests-proof -->
Executable scenarios exercise every health class, redaction boundary, and non-mutation rule.
Exercise every health class and subsystem, stale/missing/conflicting evidence, redaction of every private class, overflow/retention, support export preview/cancel, malicious log payload, no mutation, repair handoff, incident correlation, offline/no-account, accessibility, and proof-ceiling enforcement.

<!-- canon-section: performance-resource-constraints -->
Logging, signposts, health aggregation, retention, export, and inspectors use bounded queues/storage, sampling/coalescing, cancellation, and no unbounded polling; material work stays off-main. Article 31 calibration must declare representative signal/export scale, device/OS/build/tool, percentile/maximum, memory/energy/storage, and regression thresholds; no numeric budget is invented.
