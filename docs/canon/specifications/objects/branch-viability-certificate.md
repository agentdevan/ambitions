+++
spec_id = "OBJECT-BRANCH-VIABILITY-CERTIFICATE"
title = "Branch Viability Certificate"
kind = "object"
status = "normative"
owner_domain = "object-branch-viability-certificate"
canon_revision = 1
profile = "object-v1"
owns_concepts = ["object.branch-certificate.identity", "object.branch-certificate.dependency-index", "object.branch-certificate.operational-gate", "object.branch-certificate.conflict-core"]
inherits = ["OBJECT-CANONICAL-GRAPH-001", "MISSION-REFLOW-001", "CONST-RUNTIME-MUTATION-001", "CONST-PROOF-EVIDENCE-001"]
depends_on = ["CONSTITUTION", "OBJECT-LIFE-BRANCH", "SYSTEM-CERTIFIED-EXECUTABLE-BRANCH-RECONCILIATION", "SYSTEM-SCHEDULING-CAPACITY", "GLOBAL-TRUST-INSPECTION"]
source_owners = ["Native/Ambitions/Core/LocalRuntimeOS/Planning/", "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Quality/"]
+++

# Branch Viability Certificate

The Branch Viability Certificate is immutable evidence for one branch revision
and an operational gate for active or promotable status. It is not a user
score, model confidence, or legal/patentability opinion.

## OBJ-BRANCH-CERTIFICATE-IDENTITY-001 — Certificate binds exact inputs

- **Concept:** `object.branch-certificate.identity`
- **Modality:** `MUST`
- **Scope:** Certificate identity, branch revision, evaluation, and fingerprint
- **Status:** `normative`
- **Verification:** `TEST-OBJ-BRANCH-CERTIFICATE-IDENTITY-001`
- **Supersedes:** none

A certificate MUST bind one branch identifier and base graph revision to the
evaluation time, bounded horizon, source/fact revision IDs, policy revision,
authority result, capacity result, protected-invariant results, unresolved
questions, invalidation conditions, status, and deterministic fingerprint.
Equivalent inputs and seed MUST produce the same certificate fingerprint.

## OBJ-BRANCH-CERTIFICATE-DEPENDENCY-001 — Dependency index is explicit

- **Concept:** `object.branch-certificate.dependency-index`
- **Modality:** `MUST`
- **Scope:** Certificate components, branch operations, and changed revisions
- **Status:** `normative`
- **Verification:** `TEST-OBJ-BRANCH-CERTIFICATE-DEPENDENCY-001`
- **Supersedes:** none

Each certificate component and branch operation MUST expose the revisioned
conditions it depends on and whether each relation is hard or relaxable. A
revision event MUST identify the dependent component set through this index;
absence of an index is a conservative invalidation, not permission to reuse
stale evidence.

## OBJ-BRANCH-CERTIFICATE-GATE-001 — Certificate status gates branch status

- **Concept:** `object.branch-certificate.operational-gate`
- **Modality:** `MUST`
- **Scope:** Valid, fragile, blocked, invalid, stale, and superseded certificates
- **Status:** `normative`
- **Verification:** `SCENARIO-OBJ-BRANCH-CERTIFICATE-GATE-001`
- **Supersedes:** none

Only a current `valid` certificate may gate an active or promotable branch.
`fragile` and `blocked` results remain inspectable and may produce bounded
repair candidates, but they cannot be represented as a valid success. A stale
or superseded certificate cannot authorize mutation.

## OBJ-BRANCH-CERTIFICATE-CONFLICT-001 — Conflicts explain bounded repair

- **Concept:** `object.branch-certificate.conflict-core`
- **Modality:** `MUST`
- **Scope:** Infeasibility, conflict cores, correction sets, and unresolved questions
- **Status:** `normative`
- **Verification:** `TEST-OBJ-BRANCH-CERTIFICATE-CONFLICT-001`
- **Supersedes:** none

When a certificate is blocked or invalid, the result MUST preserve sufficient
conflicting conditions, fixed conditions, relaxable conditions, minimality
posture, and a plain-language explanation. Correction sets MUST identify
required authority, protected invariants, sacrificed invariants, expected
typed delta kinds, and semantic fingerprint. Unknowns remain explicit rather
than being converted to a confidence number.

## Completeness contract

<!-- canon-section: status-model -->
Certificate lifecycle is building, valid, fragile, blocked, invalid, stale,
or superseded. Status transitions append inspection evidence and never mutate
an earlier certificate in place.

<!-- canon-section: authority-and-privacy -->
Certificate inputs are private local facts, policies, authority states,
capacity, and protected boundaries. External availability may be represented
as a labeled condition, but an external system cannot certify local truth.
Generative models may propose conditions or narratives only; deterministic
owners evaluate, gate, and record the result.

<!-- canon-section: failure-recovery -->
Missing, contradictory, stale, or unauthorized inputs produce blocked or
invalid results with a bounded recovery route. Revalidation after user choice
must be against the current branch and graph revisions; a previous valid
certificate cannot be silently reused.

<!-- canon-section: inspection -->
Trust/You exposes source revisions, assumptions, protected and relaxable
conditions, authority partitions, unresolved questions, result, fingerprint,
candidate relationship, Receipt, and rollback lineage. A certificate does not
replace user Proof or History.

<!-- canon-section: proof-ceiling -->
This object specification establishes the contract for future design and
testing. It does not prove certificate computation, performance, accessibility,
or runtime integration in the current repository.
