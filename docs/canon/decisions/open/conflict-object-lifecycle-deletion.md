+++
schema_version = 1
conflict_id = "CONFLICT-OBJECT-LIFECYCLE-DELETION"
status = "unresolved"
severity = "P0_BLOCKER"
priority = "P0"
concepts = ["linear.decision.lifecycle-conversion-recurrence-and-deletion", "object.lifecycle.conversion-deletion-restore"]
scopes = ["linear v3 decision 197; owner-evidence-backed migration topology", "object.lifecycle"]
recommendation = "compose"
recommendation_rationale = "Retain the non-equivalence and safe conversion/deletion invariants, then require each object spec to declare supported behavior and recurrence scope."
stronger_composition = "Create a lifecycle matrix per object with valid/invalid transitions, Trash retention, restore repair, permanent deletion, tombstones, conversion lineage, receipts, and rollback."
proposed_canonical_law = "Completion, closure, archive, Trash, and permanent deletion MUST remain distinct; every supported conversion or deletion MUST preserve or explicitly retire identity lineage, relationships, history, receipts, recurrence scope, and rollback behavior."
artifacts_to_supersede = ["LINEAR-CANON-V3:decision:197", "LINEAR-CANON-V3:line:399"]
target_requirement_status = "planned_uncreated"
target_requirement_id = ""
owner_decision = ""
allowed_resolutions = ["keep_a", "keep_b", "compose", "reject_both"]
affected_task_scopes = ["object.lifecycle", "system.import-export-repair"]
nonclaims = "No conflict is resolved; no final Constitution or Atlas law is approved; no source, test, product, runtime, visual, accessibility, privacy, device, CloudKit, TestFlight, App Store, or release Green claim is made."
claim_ceiling = "Task 12 shadow conflict provenance, recommendation, and impact analysis only for the reviewed claims and base SHA; no source-edit or cutover authorization."

[[claims]]
claim_id = "CLAIM-LFT-0197"
source_id = "LINEAR-CANON-V3"
source_location = "decision:197"
concept = "linear.decision.lifecycle-conversion-recurrence-and-deletion"
scope = "linear v3 decision 197; owner-evidence-backed migration topology"
modality = "INFORMATIONAL"
normalized_value = "completion is not deletion. closure is not archive. archive is not permanent deletion. type conversion preserves identity lineage, source reference, attachments, relationships, and a receipt. soft deletion moves supported objects to trash. restore repairs valid projections. permanent deletion requires explicit scope confirmation and cloudkit tombstone handling."
evidence_sha256 = "c01ad77d09bc524835066bdb8f02696ab33f7cc9fcfa8eb6075f991831dce3de"
owner_approval = "linear-comment:8dade706-f0dd-42ab-9eca-e957bf5576ab:decision:197"
owner_evidence_text_sha256 = "f46b8feca2368cd6a321aaf1874fd49b752beae484e7b4b99f4b825c637b571a"
owner_evidence_rationale_sha256 = "951645ae876b852f2fd6e363a990cca532dfd9b391b6dd1a4b36e01d33c8332b"

[[claims]]
claim_id = "CLAIM-OBJ-029"
source_id = "LINEAR-CANON-V3"
source_location = "line:399"
concept = "object.lifecycle.conversion-deletion-restore"
scope = "object.lifecycle"
modality = "MUST"
normalized_value = "conversion preserves identity lineage, provenance, attachments, relationships, and receipt; supported soft deletion uses trash; restore repairs projections; permanent deletion confirms scope and handles cloudkit tombstones."
evidence_sha256 = "ecb0be5b832389c55c8c69caea0448faa1eb3ad368b2dbd3ecebe4cb4080818f"
owner_approval = "owner-approved:linear-v3"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[impacts]]
dimension = "repo"
analysis = "All object specs plus persistence, replay, sync, import/export, and repair standards are affected."

[[impacts]]
dimension = "linear"
analysis = "Decision 197 must be decomposed without losing recurrence, conversion, restore, or tombstone details."

[[impacts]]
dimension = "figma"
analysis = "Destructive and recovery flows need consequence, confirmation, scope, progress, failure, and undo states."

[[impacts]]
dimension = "production_source"
analysis = "ObjectStateRegistry, transactions, tombstone ledger, projections, and inspection are source-present but not proof of all object families."

[[impacts]]
dimension = "tests"
analysis = "Later require every valid/invalid transition, occurrence/series exception, conversion, Trash/restore, permanent deletion, tombstone, projection repair, and migration failure."

[[impacts]]
dimension = "proof"
analysis = "Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven."

[[impacts]]
dimension = "privacy"
analysis = "Deletion/export/reset and tombstone payloads need explicit object data classification and legal/privacy review where applicable."

[[impacts]]
dimension = "accessibility"
analysis = "Destructive scope, consequence, confirmation, progress, failure, recovery, and undo must be fully accessible."

[[impacts]]
dimension = "migration_rollback"
analysis = "Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag."
+++

# CONFLICT-OBJECT-LIFECYCLE-DELETION

> Shadow migration decision docket. It is non-authoritative and remains unresolved until the owner records a decision.

## Competing conceptual claims

| Claim | Normalized value | Modality | Scope | Source provenance | Evidence SHA-256 |
| --- | --- | --- | --- | --- | --- |
| `CLAIM-LFT-0197` | completion is not deletion. closure is not archive. archive is not permanent deletion. type conversion preserves identity lineage, source reference, attachments, relationships, and a receipt. soft deletion moves supported objects to trash. restore repairs valid projections. permanent deletion requires explicit scope confirmation and cloudkit tombstone handling. | `INFORMATIONAL` | linear v3 decision 197; owner-evidence-backed migration topology | `LINEAR-CANON-V3:decision:197` | `c01ad77d09bc524835066bdb8f02696ab33f7cc9fcfa8eb6075f991831dce3de` |
| `CLAIM-OBJ-029` | conversion preserves identity lineage, provenance, attachments, relationships, and receipt; supported soft deletion uses trash; restore repairs projections; permanent deletion confirms scope and handles cloudkit tombstones. | `MUST` | object.lifecycle | `LINEAR-CANON-V3:line:399` | `ecb0be5b832389c55c8c69caea0448faa1eb3ad368b2dbd3ecebe4cb4080818f` |

## User consequences

Objects can be lost, resurrected, or severed from relationships if completion, closure, archive, Trash, permanent deletion, conversion, and recurrence scope are not object-specific.

## Compatibility analysis

The integrated and Decision 197 headlines are compatible, but owner evidence is broader and current object claims do not say which families support each lifecycle/deletion behavior.

## Recommendation

**Compose A and B with explicit scopes.** Retain the non-equivalence and safe conversion/deletion invariants, then require each object spec to declare supported behavior and recurrence scope.

This is a recommendation for Gate A, not an owner decision.

## Stronger composition option

Create a lifecycle matrix per object with valid/invalid transitions, Trash retention, restore repair, permanent deletion, tombstones, conversion lineage, receipts, and rollback.

## Proposed canonical law

Completion, closure, archive, Trash, and permanent deletion MUST remain distinct; every supported conversion or deletion MUST preserve or explicitly retire identity lineage, relationships, history, receipts, recurrence scope, and rollback behavior.

## Impact analysis

| Dimension | Impact |
| --- | --- |
| repo | All object specs plus persistence, replay, sync, import/export, and repair standards are affected. |
| Linear | Decision 197 must be decomposed without losing recurrence, conversion, restore, or tombstone details. |
| Figma | Destructive and recovery flows need consequence, confirmation, scope, progress, failure, and undo states. |
| production source | ObjectStateRegistry, transactions, tombstone ledger, projections, and inspection are source-present but not proof of all object families. |
| tests | Later require every valid/invalid transition, occurrence/series exception, conversion, Trash/restore, permanent deletion, tombstone, projection repair, and migration failure. |
| proof | Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven. |
| privacy | Deletion/export/reset and tombstone payloads need explicit object data classification and legal/privacy review where applicable. |
| accessibility | Destructive scope, consequence, confirmation, progress, failure, recovery, and undo must be fully accessible. |
| migration / rollback | Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag. |

## Artifacts to supersede

- `LINEAR-CANON-V3:decision:197`
- `LINEAR-CANON-V3:line:399`

## Target requirement

- Status: `planned_uncreated`
- Requirement ID: not created; it becomes mandatory only after owner resolution.

## Owner decision

- Status: unresolved
- Decision: blank
- Allowed values: `keep_a`, `keep_b`, `compose`, `reject_both`

## Explicit nonclaims and claim ceiling

- Nonclaims: No conflict is resolved; no final Constitution or Atlas law is approved; no source, test, product, runtime, visual, accessibility, privacy, device, CloudKit, TestFlight, App Store, or release Green claim is made.
- Claim ceiling: Task 12 shadow conflict provenance, recommendation, and impact analysis only for the reviewed claims and base SHA; no source-edit or cutover authorization.
