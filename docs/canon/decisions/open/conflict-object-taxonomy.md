+++
schema_version = 1
conflict_id = "CONFLICT-OBJECT-TAXONOMY"
status = "unresolved"
severity = "P0_BLOCKER"
priority = "P0"
concepts = ["linear.decision.canonical-object-taxonomy", "mission.object.ecology"]
scopes = ["future implementation and design behavior", "linear v3 decision 193; owner-evidence-backed migration topology"]
recommendation = "reject_both"
recommendation_rationale = "Neither list alone supplies the complete identity-boundary and lifecycle contract required by the Atlas."
stronger_composition = "Introduce one object registry that classifies identity, role, state, relationship, and projection and links every family to its lifecycle spec."
proposed_canonical_law = "The Atlas MUST define exactly one canonical identity boundary for every user object and MUST NOT promote a role, state, projection, or implementation type into a separate object without lifecycle and migration law."
artifacts_to_supersede = ["LINEAR-CANON-V3:decision:193", "REPO-B11ED8716F99F213DF6470B4:line:112"]
target_requirement_status = "planned_uncreated"
target_requirement_id = ""
owner_decision = ""
allowed_resolutions = ["keep_a", "keep_b", "compose", "reject_both"]
affected_task_scopes = ["object.taxonomy"]
nonclaims = "No conflict is resolved; no final Constitution or Atlas law is approved; no source, test, product, runtime, visual, accessibility, privacy, device, CloudKit, TestFlight, App Store, or release Green claim is made."
claim_ceiling = "Task 12 shadow conflict provenance, recommendation, and impact analysis only for the reviewed claims and base SHA; no source-edit or cutover authorization."

[[claims]]
claim_id = "CLAIM-LFT-0193"
source_id = "LINEAR-CANON-V3"
source_location = "decision:193"
concept = "linear.decision.canonical-object-taxonomy"
scope = "linear v3 decision 193; owner-evidence-backed migration topology"
modality = "INFORMATIONAL"
normalized_value = "| object | user meaning | core relationships | lifecycle / special law | | -- | -- | -- | -- | | life area | broad editable region of life | contains goals and optional free steps/notes | active, hidden, restored, archived | | goal | desired outcome with a living route | belongs to life area; owns goal path; links steps, proof, time | draft, ready to activate, active, needs attention, recovering, paused, waiting, blocked, completed, archived, abandoned | | goal path | personal proof trail and adaptive route | ordered nodes referencing steps, proof, recovery, schedule changes | versioned, inspectable, material changes confirmed | | step | executable unit of work | optional goal/path, substeps, schedule placement, due date, proof | draft, ready, scheduled, started, waiting, blocked, completed, archived, trashed | | event | time-range commitment | schedule placement, recurrence, attendees, location, alerts, source | fixed by default; not completed like a step | | reminder | notification intent | may link to step/event/goal; optional date/time/location | does not consume capacity unless linked or converted | | note / thought | non-executable information | optional life area/goal/source/attachments | remains non-executable until promoted | | saved-for-later draft | durable uncommitted input | capture source, attachments, inferred route | saved, reviewed, promoted, archived, trashed | | proof | evidence or reflection | links to step/goal/closure | optional, suggested, or required | | attachment | durable local media/file/link record | links to object/draft/proof | local, export-controlled, deletable | | closure | honest completion/ending event | links step/goal, proof, receipt, reflection | completed, not needed, still counts, closed with risk | | schedule placement | relationship between object and time | object, range, state, reflow rule | never a duplicate object copy | | notification rule | alert behavior | object, trigger, quiet-hour behavior | editable, local-first | | receipt | user-readable record of meaningful mutation | command/history/object/source | durable and searchable | | history event | before/after mutation fact | object, actor, timestamp, source, reversal | replay/conflict/undo support | | source reference | provenance | imported/shared/captured object | inspection only after native import | | recovery segment | reality-changed path segment | goal path, missed/blocked step, recommendation | non-shaming, inspectable | | import / diff record | external-calendar review state | source event, candidate, decision, impact | unreviewed, imported, linked, kept external, ignored, replaced | every canonical object has stable local identity, creation/update timestamps, lifecycle state, provenance, privacy/sync classification, relationship metadata, and a soft-delete path where appropriate."
evidence_sha256 = "52e67ce67ff8de837ff01266fc167f9cee7ab82df4ba5b04667b244b00b4df6d"
owner_approval = "linear-comment:8dade706-f0dd-42ab-9eca-e957bf5576ab:decision:193"
owner_evidence_text_sha256 = "2ad9e3f8f946fb313c5379aac67eb1c6104e098ab7162daf1c025e02561f18d1"
owner_evidence_rationale_sha256 = "2dae1dd210609cf798d9f6ab7103192d23318ec8f7e6a72c2aa82173f091cd5e"

[[claims]]
claim_id = "CLAIM-MOM-0010"
source_id = "REPO-B11ED8716F99F213DF6470B4"
source_location = "line:112"
concept = "mission.object.ecology"
scope = "future implementation and design behavior"
modality = "SHOULD"
normalized_value = "lifeintent, goal, goalpath, milestone, step, onestepgoal, habit/ritual, reminder, timeblock, commitment, proof, correction, outcome, learningrecord"
evidence_sha256 = "68f1d89f0bb6cdfccb1b627629a1bb2b47506589be2177305f307ea416462733"
owner_approval = "active repo authority"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[impacts]]
dimension = "repo"
analysis = "Mission ecology and object-boundary truth become provenance to one object registry after approval."

[[impacts]]
dimension = "linear"
analysis = "Decision 193 remains primary migration evidence but not automatic final taxonomy."

[[impacts]]
dimension = "figma"
analysis = "Object diagrams must reference stable requirement IDs and cannot create object identity."

[[impacts]]
dimension = "production_source"
analysis = "Core/Domain and LocalRuntimeOS types are implementation evidence only and may embody additional compatibility types."

[[impacts]]
dimension = "tests"
analysis = "Later require identity, relationship, transition, recurrence, Trash/restore, import/export, and projection tests per object."

[[impacts]]
dimension = "proof"
analysis = "Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven."

[[impacts]]
dimension = "privacy"
analysis = "Every canonical object needs explicit local, sync, export, deletion, and diagnostic classification."

[[impacts]]
dimension = "accessibility"
analysis = "Every object needs a stable accessible name, state, actions, and relationship representation."

[[impacts]]
dimension = "migration_rollback"
analysis = "Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag."
+++

# CONFLICT-OBJECT-TAXONOMY

> Shadow migration decision docket. It is non-authoritative and remains unresolved until the owner records a decision.

## Competing conceptual claims

| Claim | Normalized value | Modality | Scope | Source provenance | Evidence SHA-256 |
| --- | --- | --- | --- | --- | --- |
| `CLAIM-LFT-0193` | &#124; object &#124; user meaning &#124; core relationships &#124; lifecycle / special law &#124; &#124; -- &#124; -- &#124; -- &#124; -- &#124; &#124; life area &#124; broad editable region of life &#124; contains goals and optional free steps/notes &#124; active, hidden, restored, archived &#124; &#124; goal &#124; desired outcome with a living route &#124; belongs to life area; owns goal path; links steps, proof, time &#124; draft, ready to activate, active, needs attention, recovering, paused, waiting, blocked, completed, archived, abandoned &#124; &#124; goal path &#124; personal proof trail and adaptive route &#124; ordered nodes referencing steps, proof, recovery, schedule changes &#124; versioned, inspectable, material changes confirmed &#124; &#124; step &#124; executable unit of work &#124; optional goal/path, substeps, schedule placement, due date, proof &#124; draft, ready, scheduled, started, waiting, blocked, completed, archived, trashed &#124; &#124; event &#124; time-range commitment &#124; schedule placement, recurrence, attendees, location, alerts, source &#124; fixed by default; not completed like a step &#124; &#124; reminder &#124; notification intent &#124; may link to step/event/goal; optional date/time/location &#124; does not consume capacity unless linked or converted &#124; &#124; note / thought &#124; non-executable information &#124; optional life area/goal/source/attachments &#124; remains non-executable until promoted &#124; &#124; saved-for-later draft &#124; durable uncommitted input &#124; capture source, attachments, inferred route &#124; saved, reviewed, promoted, archived, trashed &#124; &#124; proof &#124; evidence or reflection &#124; links to step/goal/closure &#124; optional, suggested, or required &#124; &#124; attachment &#124; durable local media/file/link record &#124; links to object/draft/proof &#124; local, export-controlled, deletable &#124; &#124; closure &#124; honest completion/ending event &#124; links step/goal, proof, receipt, reflection &#124; completed, not needed, still counts, closed with risk &#124; &#124; schedule placement &#124; relationship between object and time &#124; object, range, state, reflow rule &#124; never a duplicate object copy &#124; &#124; notification rule &#124; alert behavior &#124; object, trigger, quiet-hour behavior &#124; editable, local-first &#124; &#124; receipt &#124; user-readable record of meaningful mutation &#124; command/history/object/source &#124; durable and searchable &#124; &#124; history event &#124; before/after mutation fact &#124; object, actor, timestamp, source, reversal &#124; replay/conflict/undo support &#124; &#124; source reference &#124; provenance &#124; imported/shared/captured object &#124; inspection only after native import &#124; &#124; recovery segment &#124; reality-changed path segment &#124; goal path, missed/blocked step, recommendation &#124; non-shaming, inspectable &#124; &#124; import / diff record &#124; external-calendar review state &#124; source event, candidate, decision, impact &#124; unreviewed, imported, linked, kept external, ignored, replaced &#124; every canonical object has stable local identity, creation/update timestamps, lifecycle state, provenance, privacy/sync classification, relationship metadata, and a soft-delete path where appropriate. | `INFORMATIONAL` | linear v3 decision 193; owner-evidence-backed migration topology | `LINEAR-CANON-V3:decision:193` | `52e67ce67ff8de837ff01266fc167f9cee7ab82df4ba5b04667b244b00b4df6d` |
| `CLAIM-MOM-0010` | lifeintent, goal, goalpath, milestone, step, onestepgoal, habit/ritual, reminder, timeblock, commitment, proof, correction, outcome, learningrecord | `SHOULD` | future implementation and design behavior | `REPO-B11ED8716F99F213DF6470B4:line:112` | `68f1d89f0bb6cdfccb1b627629a1bb2b47506589be2177305f307ea416462733` |

## User consequences

Treating roles or states as first-class objects creates duplicate identity, lifecycle, deletion, recurrence, and sync behavior.

## Compatibility analysis

The mission ecology may be illustrative while Decision 193 is exhaustive, but that scope distinction is not yet canonical. Implementation names remain non-normative.

## Recommendation

**Reject both and introduce a stronger third law.** Neither list alone supplies the complete identity-boundary and lifecycle contract required by the Atlas.

This is a recommendation for Gate A, not an owner decision.

## Stronger composition option

Introduce one object registry that classifies identity, role, state, relationship, and projection and links every family to its lifecycle spec.

## Proposed canonical law

The Atlas MUST define exactly one canonical identity boundary for every user object and MUST NOT promote a role, state, projection, or implementation type into a separate object without lifecycle and migration law.

## Impact analysis

| Dimension | Impact |
| --- | --- |
| repo | Mission ecology and object-boundary truth become provenance to one object registry after approval. |
| Linear | Decision 193 remains primary migration evidence but not automatic final taxonomy. |
| Figma | Object diagrams must reference stable requirement IDs and cannot create object identity. |
| production source | Core/Domain and LocalRuntimeOS types are implementation evidence only and may embody additional compatibility types. |
| tests | Later require identity, relationship, transition, recurrence, Trash/restore, import/export, and projection tests per object. |
| proof | Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven. |
| privacy | Every canonical object needs explicit local, sync, export, deletion, and diagnostic classification. |
| accessibility | Every object needs a stable accessible name, state, actions, and relationship representation. |
| migration / rollback | Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag. |

## Artifacts to supersede

- `LINEAR-CANON-V3:decision:193`
- `REPO-B11ED8716F99F213DF6470B4:line:112`

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
