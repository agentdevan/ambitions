+++
spec_id = "OBJECT-LIFE-BRANCH"
title = "Life Branch"
kind = "object"
status = "normative"
owner_domain = "object-life-branch"
canon_revision = 1
profile = "object-v1"
owns_concepts = ["object.life-branch.identity", "object.life-branch.delta", "object.life-branch.lineage", "object.life-branch.authority-partition"]
inherits = ["OBJECT-CANONICAL-GRAPH-001", "MISSION-REFLOW-001", "CONST-RUNTIME-MUTATION-001", "CONTROL-MATERIAL-CONFIRMATION-001", "CONTROL-UNDO-RECOVERY-001"]
depends_on = ["CONSTITUTION", "OBJECT-GOAL", "OBJECT-GOAL-PATH", "OBJECT-STEP", "OBJECT-SCHEDULE-PLACEMENT", "OBJECT-RECEIPT", "OBJECT-HISTORY-EVENT", "SYSTEM-CERTIFIED-EXECUTABLE-BRANCH-RECONCILIATION"]
source_owners = ["Native/Ambitions/Core/Domain/", "Native/Ambitions/Core/LocalRuntimeOS/Planning/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Transactions/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Quality/"]
+++

# Life Branch

Life Branch is a revision-bound, inspectable semantic delta over the
canonical personal-state graph. It is not a second Goal, Goal Path, Step,
placement, or private graph.

## OBJ-LIFE-BRANCH-IDENTITY-001 — Stable branch identity and lineage

- **Concept:** `object.life-branch.identity`
- **Modality:** `MUST`
- **Scope:** Branch identity, revision, horizon, trigger, status, and lineage
- **Status:** `normative`
- **Verification:** `TEST-OBJ-LIFE-BRANCH-IDENTITY-001`
- **Supersedes:** none

A Life Branch MUST have a stable identifier, parent branch or source identity,
base graph revision, bounded horizon, explicit trigger, governing policy
revision, certificate reference, status, and lineage. A branch lifecycle MUST
distinguish candidate, selected, committing, active-local, active, stale,
superseded, rolled-back, and expired states where those states apply.

## OBJ-LIFE-BRANCH-DELTA-001 — Typed operations target canonical objects

- **Concept:** `object.life-branch.delta`
- **Modality:** `MUST`
- **Scope:** Prospective branch operations
- **Status:** `normative`
- **Verification:** `TEST-OBJ-LIFE-BRANCH-DELTA-001`
- **Supersedes:** none

Branch deltas MUST be typed, ordered, revision-aware operations against
existing canonical object identities. Each operation records its human
consequence, protected invariants, dependency conditions, authority owner,
materiality, and reversibility. Untyped payloads, duplicate object authority,
silent object copies, and timeslot-only alternatives are invalid.

## OBJ-LIFE-BRANCH-LINEAGE-001 — Prior decisions remain inspectable

- **Concept:** `object.life-branch.lineage`
- **Modality:** `MUST`
- **Scope:** Selection, promotion, supersession, rollback, and recovery
- **Status:** `normative`
- **Verification:** `SCENARIO-OBJ-LIFE-BRANCH-LINEAGE-001`
- **Supersedes:** none

Promotion, supersession, rollback, and expiry MUST retain prior branch
identity, certificate, decision basis, user confirmation, Receipt, History
Event, replay fingerprint, and rollback or compensation target. Later facts may
invalidate a branch but may not rewrite the historical reason it was accepted.

## OBJ-LIFE-BRANCH-AUTHORITY-001 — Effects remain partitioned

- **Concept:** `object.life-branch.authority-partition`
- **Modality:** `MUST`
- **Scope:** User-owned, recipient-owned, joint, and external effects
- **Status:** `normative`
- **Verification:** `TEST-OBJ-LIFE-BRANCH-AUTHORITY-001`
- **Supersedes:** none

Every material branch operation MUST identify the authority partition it would
affect. User-owned effects may be committed only through the local mutation
sequence; recipient-owned effects remain proposals; external effects remain
post-commit outbox intents. No branch status may imply completion of an effect
owned by another principal or system.

## Completeness contract

<!-- canon-section: identity -->
Life Branch owns branch identity, delta lifecycle, status, lineage, and effect
partition. Goal, Goal Path, Step, placement, event, proof, receipt, and history
identities remain owned by their existing object specifications.

<!-- canon-section: lifecycle -->
Materializing → candidate-feasible/candidate-fragile/candidate-blocked →
selected → committing → active-local/active is permitted only after current
certificate and authority validation. Any changed base revision marks the
branch stale until recertified. Superseded, rolled-back, and expired branches
remain inspectable according to retention and privacy law.

<!-- canon-section: privacy -->
Branch deltas, assumptions, conflicts, policies, capacity, and lineage are
private local graph data. Export is explicit and provenance-bearing. R2,
Source Atlas, hosted AI, and external adapters receive only separately
authorized minimum fields, never the private branch graph.

<!-- canon-section: accessibility-and-surfaces -->
Every branch consequence, alternative, state, authority partition, and
recovery action has a semantic ordered representation. Goals, Today, Time,
and You/Trust present the same canonical branch identity without creating
projection-owned mutation authority.

<!-- canon-section: proof-ceiling -->
This object specification records design intent only; it does not prove that
the current source implements Life Branch or any branch lifecycle.
