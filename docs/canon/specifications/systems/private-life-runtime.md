+++
spec_id = "SYSTEM-PRIVATE-LIFE-RUNTIME"
title = "Private Life Runtime"
kind = "system"
status = "normative"
owner_domain = "system-private-life-runtime"
canon_revision = 1
profile = "system-v1"
owns_concepts = ["system.runtime.mutation-sequence", "system.runtime.local-orchestration"]
inherits = ["MISSION-ORCHESTRATION-LOOP-001", "RUNTIME-MUTATION-SEQUENCE-001", "LAW-RUNTIME-DURABLE-SUCCESS-001", "LAW-RUNTIME-NO-DIRECT-WRITE-001", "RUNTIME-SOURCE-OWNER-001", "LAW-OFFLINE-NO-ACCOUNT-001"]
depends_on = ["CONSTITUTION", "GLOBAL-TRUST-INSPECTION"]
source_owners = ["Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Transactions/", "Native/Ambitions/Core/LocalRuntimeOS/EventJournal/", "Native/Ambitions/Core/LocalRuntimeOS/State/", "Native/Ambitions/Core/LocalRuntimeOS/Projections/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/", "Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/", "Native/Ambitions/Quality/"]
+++

# Private Life Runtime

This shadow target specifies intended local runtime behavior. It neither activates authority nor claims app-wide mutation migration, runtime completion, privacy approval, device behavior, or release readiness.

## SYSTEM-RUNTIME-MUTATION-001 — Meaningful change follows one ordered local sequence

- **Concept:** `system.runtime.mutation-sequence`
- **Modality:** `MUST`
- **Scope:** Every meaningful private-state mutation from UI, parser, planner, scheduler, import, notification, extension, App Intent, automation, continuity, or repair entry
- **Status:** `normative`
- **Verification:** `SCENARIO-SYSTEM-RUNTIME-ATOMIC-001`, `AUDIT-RUNTIME-DIRECT-WRITE-001`
- **Supersedes:** none

Every meaningful mutation MUST: validate and authorize a typed Command; prepare the declared transaction and rollback; durably commit the canonical Event, object state, projection invalidations, Receipt metadata, History lineage, and external-effect intent atomically; materialize or invalidate Projections; finalize a truthful Receipt and replayable result; and only then attempt any external effect through a durable outbox. Rejection commits no requested object mutation. No adapter, store, callback, projection, view, extension, or external result may bypass or reorder this law.

## SYSTEM-RUNTIME-ORCHESTRATION-001 — Runtime serves contextual life orchestration

- **Concept:** `system.runtime.local-orchestration`
- **Modality:** `MUST`
- **Scope:** Intent, context, path, time fit, reflow, action, proof, learning, and recovery
- **Status:** `normative`
- **Verification:** `SCENARIO-SYSTEM-RUNTIME-ORCHESTRATION-001`
- **Supersedes:** none

The runtime MUST connect local intent and context to an inspectable path, reality-fit placement, action, closure/proof, learning, and reflow/recovery without becoming a chatbot, score, streak, dashboard, or hosted intelligence service. Recommendations expose reason, relevant source, uncertainty where material, user control, policy revision, and correction/reset behavior.

## Completeness contract

<!-- canon-section: responsibility-non-responsibility -->
The runtime governs local orchestration and canonical mutation coordination.
Owns the local orchestration and mutation contract. It does not own surface presentation, external service truth, account identity, CloudKit enablement, public references, storage technology, or release status.

<!-- canon-section: inputs-outputs -->
The contract consumes typed Commands and emits durable correlated results.
Inputs are a typed Command, actor/source, idempotency and causal identity, canonical read set, user rules, policy revision, clock/seed, authorization, and external-effect declaration. Outputs are accepted or rejected result, canonical Event/object state, Projection invalidation/materialization, Receipt/History lineage, replay cursor, rollback reference, and durable external-effect state.

<!-- canon-section: authority-boundary -->
Only `Core/LocalRuntimeOS/` owns canonical mutation policy. Surfaces and adapters propose Commands; stores persist declared state; external integrations reconcile effects. Ambitions Account, CloudKit, R2, Source Atlas, hosted AI, and server profiling never become command or private-graph authority.

<!-- canon-section: data-classification -->
The runtime handles private life graph, attachments, proofs, schedules, behavior corrections, and learned influences as local sensitive data. Minimum necessary redacted metadata alone may cross separately approved boundaries.

<!-- canon-section: state-model -->
Command states are received, validated, rejected, prepared, committed, projected, receipted, replayable, externally pending, externally succeeded/failed/reconciled, or rolled back. Stable causal IDs and policy/schema revisions bind every phase.

<!-- canon-section: failure-recovery -->
Failure handling preserves accepted intent and the last coherent local state.
Crash at any phase resumes from durable facts without duplicate acceptance, lost intent, impossible mixed state, or repeated external effect. Unknown or unverifiable state fails closed to inspection, quarantine, rollback, or repair preview; data-loss risk is P0 Red.

<!-- canon-section: local-network-boundary -->
All core mutation, orchestration, inspection, and replay work completely without account or network. Local durable commit precedes external effects; external failure preserves accepted intent and remains inspectable. Hosted AI and server-side profiling are excluded.

<!-- canon-section: determinism -->
Stable inputs and a recorded seed select one replay-equivalent outcome.
Equivalent canonical inputs, policy version, user rules, clock, and recorded seed yield equivalent accepted decisions and replay. Collection order, scheduling, network response, and hash randomization cannot alter canonical meaning.

<!-- canon-section: observability -->
Local redacted traces bind each phase to one causal chain.
Redacted traces correlate Command, transaction, Event, object revision, Projection cursor/checksum, Receipt, replay, rollback, and external-effect state without private content by default.

<!-- canon-section: source-ownership -->
Canonical target owners are exactly `Core/LocalRuntimeOS/Commands/`, `Transactions/`, `EventJournal/`, `State/`, `Projections/`, `Inspection/`, and `PrivateLifeRuntimeKernel/` for Command, Event, object-state, Projection, Receipt/History, replay, and orchestration authority; `ExternalWrites/` owns only durable outbox dispatch and reconciliation after local commit; `Quality/` owns executable proof. Current source presence and remaining direct-write, legacy-owner, cross-path replay, projection-consumption, side-effect, and app-wide coverage debt remain implementation facts outside this target.

<!-- canon-section: tests-proof -->
Required proof includes validation/rejection, authorization, transaction conflict, crash at every phase, duplicate/idempotent entry, replay equivalence, rollback, projection rebuild, receipt/history lineage, external-before-local prohibition, external retry without duplicate, offline relaunch, privacy egress denial, policy versioning, and correction/reset scenarios. This specification alone proves none of them.

<!-- canon-section: performance-resource-constraints -->
Work is bounded, cancellable, off the main actor where material, backpressured, and free of polling or unbounded queues. No numeric budget is authorized here: Article 31 calibration must declare device/OS/build, representative graph and event scale, warm/cold state, tool, percentile/maximum, energy/memory/storage measures, and regression threshold before implementation or performance Green.
