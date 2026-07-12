+++
spec_id = "APP-DEGRADED-STATES"
title = "App Degraded States"
kind = "app"
status = "normative"
owner_domain = "app-degraded-states"
canon_revision = 1
profile = "system-v1"
owns_concepts = [
  "app.degraded.failure-taxonomy",
  "app.degraded.input-preservation",
  "app.degraded.presentation",
  "app.degraded.recovery",
  "app.degraded.state",
]
inherits = [
  "LAW-OFFLINE-NO-ACCOUNT-001",
  "CONTROL-UNDO-RECOVERY-001",
  "LAW-RUNTIME-DURABLE-SUCCESS-001",
  "LAW-DATA-LOSS-STOP-SHIP-001",
  "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001",
  "CONST-PROOF-EVIDENCE-001",
]
depends_on = ["CONSTITUTION"]
source_owners = [
  "Native/Ambitions/DesignSystem/",
  "Native/Ambitions/Core/LocalRuntimeOS/Repair/",
  "Native/Ambitions/Core/LocalRuntimeOS/Diagnostics/",
  "Native/Ambitions/Diagnostics/",
  "Native/Ambitions/Surfaces/Today/",
  "Native/Ambitions/Surfaces/Goals/",
  "Native/Ambitions/Surfaces/Time/",
  "Native/Ambitions/Surfaces/You/",
  "Native/Ambitions/Quality/",
]
+++

# App Degraded States

This shadow specification defines a shared classification and presentation contract for whole-app degradation. Owning features retain their specific failure semantics. This file does not assert that current recovery, data safety, diagnostics, or UI proof is complete.

## APP-DEGRADED-FAILURE-TAXONOMY-001 — Failures keep distinct user consequences

- **Concept:** `app.degraded.failure-taxonomy`
- **Modality:** `MUST`
- **Scope:** App-visible availability, freshness, continuity, external integration, local storage, and partial-operation failures
- **Status:** `normative`
- **Verification:** `AUDIT-APP-DEGRADED-TAXONOMY-001`, `SCENARIO-APP-DEGRADED-CLASSIFY-001`
- **Supersedes:** none

App-visible failure handling MUST distinguish at least: offline but locally healthy, stale external source, continuity pending, continuity conflict, import failure, external-write failure, local-store degradation, partial operation, and unavailable permission. These classes cannot collapse into a generic error because they differ in canonical-state safety, what remains usable, whether retry is safe, and what recovery the user controls.

No class implies that optional CloudKit continuity, account, R2, Source Atlas, external import, or side-effect behavior is enabled or proven. Feature specifications may add narrower subclasses without redefining these shared consequences.

## APP-DEGRADED-PRESENTATION-001 — Degradation is calm, scoped, and actionable

- **Concept:** `app.degraded.presentation`
- **Modality:** `MUST`
- **Scope:** Inline, object-detail, surface, and launch-level degraded presentation
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-DEGRADED-PRESENTATION-001`, `PROOF-APP-DEGRADED-A11Y-001`
- **Supersedes:** none

A degraded presentation MUST state what is affected, what remains available, whether displayed information is current, and the safest next action. It appears at the narrowest level that explains the consequence and does not turn private status, diagnostics, or architecture vocabulary into ambient root chrome. Color, motion, or spatial position may not be the sole carrier of severity or recovery state.

## APP-DEGRADED-PRESERVE-001 — Failure preserves accepted input and local truth

- **Concept:** `app.degraded.input-preservation`
- **Modality:** `MUST`
- **Scope:** Drafts, accepted mutations, local canonical objects, pending external effects, and partial results
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-DEGRADED-PRESERVE-001`, `PROOF-APP-DEGRADED-NO-DATA-LOSS-001`
- **Supersedes:** none

Failure MUST preserve original input, accepted local intent, canonical object identity, and truthful pending or failed external-effect state. An external, permission, network, import, projection, or presentation failure cannot erase a durable local acceptance or relabel it as fully succeeded. Partial results remain identifiable and safe to retry, reconcile, quarantine, export, undo, or repair according to the owning contract.

## APP-DEGRADED-RECOVERY-001 — Recovery is class-specific and reversible

- **Concept:** `app.degraded.recovery`
- **Modality:** `MUST`
- **Scope:** Retry, reconciliation, conflict review, quarantine, export, rollback, repair preview, and destructive reset
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-DEGRADED-RECOVERY-001`, `SCENARIO-APP-DEGRADED-RETRY-IDEMPOTENCY-001`
- **Supersedes:** none

Recovery MUST match the failure class and current canonical state. Retry revalidates preconditions and is idempotent. Conflicts require human-meaningful review; quarantine isolates suspect data without silently deleting it; repair previews consequences before commit; export preserves user agency where feasible. Destructive reset is a separately confirmed last resort and cannot be presented as routine recovery for an unclassified failure.

## APP-DEGRADED-STATE-001 — Degraded state retains scope and freshness

- **Concept:** `app.degraded.state`
- **Modality:** `MUST`
- **Scope:** Shared degraded-state representation and transition
- **Status:** `normative`
- **Verification:** `AUDIT-APP-DEGRADED-STATE-001`, `SCENARIO-APP-DEGRADED-RESTORE-001`
- **Supersedes:** none

Each degraded state MUST carry the affected capability or object scope, failure class, local-authority health, freshness, retry safety, available recovery actions, and whether user attention is required. Resolution clears only the affected degraded state after current facts are re-read; it does not discard unresolved history, receipt, conflict, or repair evidence.

## Completeness contract

<!-- canon-section: responsibility-non-responsibility -->
This system owns shared failure classes, cross-app degraded presentation rules, input-preservation invariants, and recovery vocabulary. It does not own feature-specific failures, persistence repair algorithms, continuity enablement, permission policy, or a generic central error store that replaces owning state.

<!-- canon-section: inputs-outputs -->
Inputs are owning-system failure facts, affected scope, local-authority health, freshness, accepted-input state, partial results, retry safety, and recovery capabilities. Outputs are a classified degraded state, scoped presentation model, allowed recovery actions, and resolution/reconciliation request.

<!-- canon-section: authority-boundary -->
Owning systems remain authoritative for facts and recovery execution. This shared contract composes their user consequences and cannot mutate canonical data, override privacy/control law, or turn diagnostics into product policy.

<!-- canon-section: data-classification -->
Degraded state uses minimum necessary local metadata. User-visible and diagnostic representations redact private titles, proof, notes, attachments, schedules, and inferred context unless the owning object view explicitly requires that content to explain a direct consequence.

<!-- canon-section: state-model -->
The degraded record uses explicit fields for scope, health, freshness, operation, and recovery.

State records failure class, scope, local health, freshness, operation phase, retry safety, user-attention need, recovery set, and resolution status. Offline-healthy is distinct from stale, pending, conflicted, failed, partial, unavailable, quarantined, and local-store degraded.

<!-- canon-section: failure-recovery -->
Every classified failure exposes only recovery actions valid for its current facts.

Unknown failures fail closed to input preservation and non-destructive inspection. Classified failures offer only recovery valid for current state. Repeated failure remains visible with escalation to export, quarantine, diagnostics, or repair rather than endless retry.

<!-- canon-section: local-network-boundary -->
Offline-healthy local behavior remains usable and is not displayed as product failure. Recovery requiring an optional external service waits without blocking unrelated local core behavior or changing local authority.

<!-- canon-section: determinism -->
The same owning facts produce the same failure class, presentation scope, and allowed recovery set. Severity is based on user consequence and data safety, not arbitrary source names or transient error strings.

<!-- canon-section: observability -->
Redacted evidence identifies the failure class, affected scope, and recovery result.

Evidence records class, scope, local health, freshness, operation phase, preserved-input status, retry count/result, recovery chosen, and resolution with private content redacted. Evidence age and source revision remain explicit.

<!-- canon-section: source-ownership -->
Canonical target ownership is exact: `Core/LocalRuntimeOS/Repair/` and `Core/LocalRuntimeOS/Diagnostics/` own repair and health facts; `DesignSystem/` owns shared degraded-state product components; each owning root under `Surfaces/Today/`, `Goals/`, `Time/`, or `You/` owns contextual placement; app `Diagnostics/` owns redacted diagnostic presentation; and `Quality/` owns scenario and accessibility proof. Current `Surfaces/SurfaceLaw/DegradedStateModels.swift` and `DegradedStateOrchestrator.swift` locations are non-canonical architecture debt and current implementation mappings, not target owners. A source repair must move or collapse their authority into the exact owners above.

<!-- canon-section: tests-proof -->
The scenario matrix executes every shared failure class and recovery outcome.

Required proof exercises every taxonomy class, unknown failure, offline-healthy operation, stale data, partial results, idempotent retry, conflict review, quarantine, repair preview, preserved drafts/local objects, redaction, VoiceOver semantics/actions, Dynamic Type, Reduce Motion, contrast, and focus recovery.

<!-- canon-section: performance-resource-constraints -->
With 100 simultaneous health signals across 25 affected scopes, classification MUST complete within 10 ms at P95 and shared presentation-model derivation within 16 ms at P95 across 1,000 evaluations. The active degraded-state queue MUST cap at 128 records and coalesce repeated facts by scope; each redacted diagnostic record MUST remain at or below 4 KiB. One thousand retained records MUST add no more than 4 MiB resident memory. Classification performs zero synchronous disk or network I/O. Automatic retry is capped at 3 attempts per operation with delays of at least 1, 5, and 30 seconds; further action requires user intent or an owning repair contract. No degraded-state classifier may poll or run an unbounded background loop. Current device, latency, storage, memory, retry-energy, and repair-throughput proof is not claimed.
