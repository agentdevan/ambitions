+++
spec_id = "SYSTEM-LOCAL-LEARNING"
title = "Local Learning"
kind = "system"
status = "normative"
owner_domain = "system-local-learning"
canon_revision = 1
profile = "system-v1"
owns_concepts = ["system.learning.local-inspectable", "system.learning.user-control"]
inherits = ["MISSION-MOAT-CONTINUITY-001", "CONTROL-FORCE-NOTHING-001", "LAW-LOCAL-AUTHORITY-001", "LAW-OFFLINE-NO-ACCOUNT-001", "CONST-PROOF-EVIDENCE-001"]
depends_on = ["CONSTITUTION", "SYSTEM-PRIVATE-LIFE-RUNTIME", "SYSTEM-PRIVACY-DATA-CLASSIFICATION", "SURFACE-YOU", "GLOBAL-TRUST-INSPECTION"]
source_owners = ["Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/", "Native/Ambitions/Core/LocalRuntimeOS/Planning/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/", "Native/Ambitions/Surfaces/You/", "Native/Ambitions/Quality/"]
+++

# Local Learning

This shadow target defines intended inspectable local adaptation, not a model-training claim, intelligence-quality proof, or current implementation completion.

## SYSTEM-LEARNING-LOCAL-001 — Learning remains local, evidence-linked, and non-judgmental

- **Concept:** `system.learning.local-inspectable`
- **Modality:** `MUST`
- **Scope:** Timing, duration, context, reminder tolerance, proof friction, reschedule/completion patterns, capacity, explicit corrections, and recommendation fit
- **Status:** `normative`
- **Verification:** `SCENARIO-SYSTEM-LEARNING-LOCAL-001`
- **Supersedes:** none

Learning MUST derive locally from canonical observations and explicit corrections, retain evidence/policy lineage and uncertainty, and influence only declared inspectable decisions. It MUST NOT create emotional labels, productivity scores, streak pressure, hidden personality profiles, server-side profiling, hosted-model dependency, or certainty unsupported by context.

## SYSTEM-LEARNING-CONTROL-001 — The user can inspect, correct, disable, reset, archive, and delete influences

- **Concept:** `system.learning.user-control`
- **Modality:** `MUST`
- **Scope:** Learned factors, explicit Life Capital, recommendations, correction history, and automation
- **Status:** `normative`
- **Verification:** `SCENARIO-SYSTEM-LEARNING-CONTROL-001`
- **Supersedes:** none

Every learned influence MUST expose what changed, evidence category, where it is used, and controls appropriate to inspect, correct, disable, reset, archive, or delete it. Correction is a runtime mutation with Receipt/history; deletion has explicit downstream consequence and never silently rewrites historical truth. Passive learning may suggest but cannot silently make material commitments.

## Completeness contract

<!-- canon-section: responsibility-non-responsibility -->
Owns local observation-to-influence derivation, evidence lineage, uncertainty, decay/retention policy, correction/reset, and declared decision use. It does not own user identity, emotional assessment, clinical inference, cloud training, surface commitments, or autonomous material change.

<!-- canon-section: inputs-outputs -->
The contract consumes local observations and emits inspectable bounded influences.
Inputs are canonical completion/reschedule/proof/reminder/context observations, explicit Life Capital and corrections, policy revision, clock, consent/settings, and data availability. Outputs are versioned influence with evidence references/uncertainty/expiry, explanation, bounded recommendation input, correction/reset Command, and Receipt/history.

<!-- canon-section: authority-boundary -->
Learning proposes typed influences; Planning/Scheduling/Runtime policy decides declared use and Commands own changes. Surfaces present controls. Ambitions Account, R2, Source Atlas, telemetry, hosted AI, and server profilers never receive or own learning data.

<!-- canon-section: data-classification -->
Observations, factors, patterns, corrections, uncertainty, inferred fit, and recommendation history are private graph data. Diagnostics contain only redacted categories and correlation IDs; public references cannot be personalized through private payloads.

<!-- canon-section: state-model -->
Influences are candidate, active, uncertain, user-confirmed, corrected, disabled, archived, reset, deleted/tombstoned, or expired under a versioned retention policy. Explicit user facts remain distinct from inferred patterns.

<!-- canon-section: failure-recovery -->
Failure handling preserves evidence and selects quiet neutral behavior.
Sparse, contradictory, stale, deleted, or corrupt evidence yields quiet/neutral behavior and inspectable missing context, never fabricated certainty. Rebuild is deterministic from retained evidence; correction/reset is reversible where declared and preserves Receipt/history.

<!-- canon-section: local-network-boundary -->
Learning and all controls work locally without account/network. No observation, feature vector, embedding, profile, prompt, or derived influence is sent to hosted AI, backend profiling, R2, or Source Atlas.

<!-- canon-section: determinism -->
Stable retained evidence and an injected seed select one equivalent influence set.
Equivalent retained evidence, explicit settings/corrections, policy revision, clock, and seed yield equivalent influences and explanations. Order-independent aggregation uses stable causal ordering.

<!-- canon-section: observability -->
Local inspection binds each influence to evidence categories and user controls.
User inspection shows plain-language evidence categories, use, uncertainty, last revision, and controls. Redacted developer traces show influence/policy/correlation IDs and rebuild/correction result without private values.

<!-- canon-section: source-ownership -->
Exact targets are `Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/`, `Planning/`, `Inspection/`, and `PrivacySecurity/`; `Surfaces/You/` owns settings presentation and `Quality/` owns scenarios. Current learning names/source presence do not prove app-wide consumption, explanation quality, user control, retention, privacy, or runtime behavior.

<!-- canon-section: tests-proof -->
Cover sparse/no evidence, different users with same intent, correction, disable/reset/archive/delete, contradictory/stale evidence, relaunch/rebuild/replay, policy migration, recommendation explanation, no emotional/scoring language, no material silent action, privacy egress attacks, offline/no-account, and accessibility of controls.

<!-- canon-section: performance-resource-constraints -->
Observation ingestion, rebuild, explanation, and influence evaluation are bounded, cancellable, incremental where safe, off-main where material, and use bounded retention. Article 31 calibration must define representative history/factor scale, device/OS/build/tool, warm/cold, percentile/maximum, memory/energy/storage, and regression threshold; no invented numeric target or performance proof appears here.
