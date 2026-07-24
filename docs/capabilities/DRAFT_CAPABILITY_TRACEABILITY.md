# Ambitions Draft Capability Traceability

Status: **non-normative Phase F traceability**

Baseline: `5670f24fb82adefd27cffee5ddf8fb70676ed049`

This map connects each proposed product promise to available canon, objects, systems, surfaces, runtime source, tests, and proof. It applies a strict evidence ceiling:

- Normative canon establishes intended behavior, not implementation.
- Source presence establishes narrower implementation evidence, not complete fulfillment.
- Tests establish only the scenarios they execute.
- Audits establish only their documented scope.
- Missing or contradictory evidence remains a gap.

The machine-readable companion is `draft-capability-traceability.json`.

## Portfolio summary

| Capability | Canon/spec posture | Runtime/test evidence | Current proof ceiling |
|---|---|---|---|
| Skill Transference | Adjacent local-learning and privacy law | Learning signals and narrower candidate tests | No explicit transfer model or reviewed journey |
| Contextual Generative Goal Pathing | Strong object/system/surface canon | Planner, compiler, projections, and focused tests | Not proven as one contextually unique end-to-end capability |
| Alternate Career Path Simulation | Strong branch design intent | Declared ownership targets | Specifications explicitly state current implementation is not proven |
| Adaptive Step Placement Reflow | Strong journey/system/object canon | Domain, projection, and focused reflow tests | Exact new-Step journey and device proof remain incomplete |
| Ambitions Native Search and Command | Strong global/journey canon | Strong local Search source, tests, and acceptance audits | Final interaction quality, grounded Ask breadth, performance, and app-wide coverage remain |
| Appearance Studio | Partial You and design-system authority | Settings/token infrastructure | No first-class studio contract or proof |
| Content Share Studio | Privacy/export primitives only | Isolated export-adjacent evidence | No authoritative studio, format, audience, or end-to-end output proof |
| Goal-Attached Files and Knowledge | Strong Attachment object law and storage primitives | Storage and projection tests | Goal relationship and complete file experience unproven |
| Local-First Operational Continuity | Strong degraded-state and offline law | Repair/diagnostic owners and audit evidence | App-wide interruption/recovery/device proof incomplete |

## Capability links

### `CAP-CONTEXT-001` — Skill Transference

**Canon:** Local Learning, Privacy and Data Classification, Goal Path.

**Key requirements:** `SYSTEM-LEARNING-LOCAL-001`, `SYSTEM-LEARNING-CONTROL-001`, `SYSTEM-LEARNING-CAPABILITY-RETENTION-001`, `SYSTEM-PRIVACY-CLASSIFICATION-001`, `SYSTEM-PRIVACY-EGRESS-001`.

**Objects and systems:** Goal, Goal Path, Step, Proof, History Event; Local Learning, Private Life Runtime, Trust Inspection.

**Evidence:** `PersonalRuntimeLearningSignal.swift`, `StepCandidateFieldGeneratorTests.swift`, and You feature-service tests establish narrower learning and candidate behavior.

**Assessment:** **Not demonstrated as a product capability.** No explicit cross-domain transfer identity, evidence model, correction flow, or reviewed person-facing journey exists.

### `CAP-PATH-001` — Contextual Generative Goal Pathing

**Canon:** Goal Path, Local Learning, Scheduling and Capacity, Goals, Today, Time, Search.

**Key requirements:** Goal Path identity, Receipt, adaptation triggers, strategy, adaptation boundary, and accessibility requirements.

**Objects and systems:** Goal, Goal Path, Step, Proof, Schedule Placement, Recovery Segment, Receipt, History; Planning, Learning, Scheduling, Commands, Inspection, Replay.

**Evidence:** `GoalPathPlanner.swift`, `GoalPathCompilerService.swift`, compiler models, Goals projections, compiler/service/planning/projector tests, and Goals acceptance material.

**Assessment:** **Substantial evidence; capability not verified.** The remaining ceiling is the complete quality of personalization, context use, cross-surface coherence, privacy, revisions, and device-level person experience.

### `CAP-SIMULATION-001` — Alternate Career Path Simulation

**Canon:** Life Branch, Branch Viability Certificate, Life Branch Reconciliation, Certified Executable Branch Reconciliation, privacy law.

**Key requirements:** Life Branch identity/delta/lineage/authority and Branch Certificate identity/dependency/gate/conflict requirements.

**Objects and systems:** Life Branch, Branch Viability Certificate, canonical Goals/Paths/Steps/placements, Receipt, History; Planning, Scheduling, Inspection.

**Evidence:** The specifications define strong future contracts but explicitly state that current implementation, certificate computation, lifecycle behavior, performance, accessibility, and runtime integration are not proven.

**Assessment:** **Design intent only.** Career-specific assumptions, reference data, comparison presentation, adoption flow, and executable tests remain absent.

### `CAP-TIME-001` — Adaptive Step Placement Reflow

**Canon:** Schedule Reflow, Scheduling and Capacity, Schedule Placement, Step, Goal Path, Time.

**Key requirements:** `JOURNEY-TIME-DIRECT-MANIPULATION-001`, material confirmation, undo/recovery, and core reflow law.

**Objects and systems:** Step, Placement, Goal Path, Event, Recovery Segment, Receipt, History; Scheduling, Commands, External Writes, Inspection, Replay.

**Evidence:** `TimeContextAvailabilityAndReflow.swift`, `TimeRealityReflowProjection.swift`, Time surface assembly, quiet-reflow tests, time-context tests, mutation-permission tests, and Time acceptance material.

**Assessment:** **Substantial evidence; capability not verified.** New-Step-specific reflow, selective acceptance, protected-boundary behavior, rollback, accessibility parity, and device proof remain open.

### `CAP-SEARCH-001` — Ambitions Native Search and Command

**Canon:** Global Search, Find/Act/Inspect, Find/Ask/Act/Inspect, Trust Inspection.

**Key requirements:** private command-layer law, Search command contract, and Search scenario contract.

**Objects and systems:** canonical object projections, Receipt, History; FTS Index, Semantic Local Index, ranking, command routing, Trust, privacy.

**Evidence:** `FindActInspectContract.swift`, `FTSIndex.swift`, `SemanticLocalIndex.swift`, `SearchActionValidator.swift`, `ResultRanker.swift`, Search tests, acceptance audit, repair gate, and remediation dossier.

**Assessment:** **Strongest implementation evidence in the draft atlas; still not fully verified.** Raycast-grade invocation and interaction quality, grounded Ask completeness, app-wide action coverage, performance calibration, and final device proof remain.

### `CAP-APPEARANCE-001` — Appearance Studio

**Canon:** You appearance ownership, Visual System R1, surface/journey closure, accessibility stress closure.

**Objects and systems:** local appearance preferences, design-token selections, preference Receipts; You, Design Tokens, Accessibility, Motion Reduction.

**Evidence:** You projections, generated design-system recipe/surface IDs, You tests, and the You capability inventory.

**Assessment:** **Partial settings and infrastructure evidence; no studio proof.** A first-class authoring contract, live preview, supported dimensions, persistence semantics, product-wide application, and accessibility tests are missing.

### `CAP-SHARING-001` — Content Share Studio

**Canon:** Privacy and Data Classification, Import/Export Repair, Attachment, Trust Inspection.

**Objects and systems:** export candidate, Attachment, Receipt, History; classification, redaction, local rendering, export repair, system share integration.

**Evidence:** only isolated export/share-adjacent runtime assertions were found.

**Assessment:** **Not demonstrated as a capability.** There is no authoritative Share Studio specification, audience model, format matrix, transformation pipeline, exact-preview contract, or end-to-end output proof.

### `CAP-KNOWLEDGE-001` — Goal-Attached Files and Knowledge

**Canon:** Attachment, Goal, Import/Export Repair, Search, storage owner map.

**Key requirements:** `OBJ-ATTACHMENT-IDENTITY-001` and Attachment lifecycle scenario contract.

**Objects and systems:** Attachment, Goal, Proof, Receipt, History; Storage, Commands, Inspection, Search, import/export, privacy.

**Evidence:** Storage owner presence, mutation registry, Storage Tier tests, and LocalRuntimeOS projection tests.

**Assessment:** **Object contract and storage evidence; no Goal-attached experience proof.** Goal relationships, ingest/recovery UI, Search indexing, shared-link deletion, quotas/resource pressure, and complete device behavior remain gaps.

### `CAP-RESILIENCE-001` — Local-First Operational Continuity

**Canon:** App Degraded States, Today, Search, Persistence and Replay, Privacy and Data Classification.

**Key requirements:** offline/no-account law, undo/recovery, durable-success law, data-loss stop-ship law, degraded command contract.

**Objects and systems:** canonical local objects, Receipt, History, external outbox result, recovery checkpoint; Replay, Repair, Diagnostics, External Writes, Search, Privacy.

**Evidence:** Repair and Diagnostics ownership, local Search index, persistence/offline/recovery audit, scenario gates, and known-issues register.

**Assessment:** **Broad contract and partial evidence; app-wide capability not verified.** Interruption/resume, all-surface degraded states, external reconciliation, restoration, accessibility, and clean-device proof remain incomplete.

## Result

- Proposed capabilities traced: **9 / 9**
- Capabilities declared fully verified: **0**
- Capabilities with substantial implementation evidence: **3** — Goal Pathing, Reflow, Search
- Capabilities supported mainly by design intent or primitives: **6**

This is the intended outcome of a truthful Phase F pass. Traceability exposes what exists and what remains; it does not promote maturity by implication.