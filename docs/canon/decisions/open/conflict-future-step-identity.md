+++
schema_version = 1
conflict_id = "CONFLICT-FUTURE-STEP-IDENTITY"
status = "unresolved"
severity = "P0_BLOCKER"
priority = "P1"
concepts = ["object.future-step.identity", "product.future-steps"]
scopes = ["active product and engineering authority migration", "object.future-step"]
recommendation = "reject_both"
recommendation_rationale = "Do not canonize a noun until identity and lifecycle boundaries are complete."
stronger_composition = "Prefer a Step role or placement state if it preserves one Step identity; create a separate object only if unique lifecycle law requires it."
proposed_canonical_law = "Future Step MUST be specified as exactly one canonical Step role, placement state, path-node subtype, or distinct object before implementation; it MUST NOT create duplicate identity or lineage."
artifacts_to_supersede = ["REPO-AA88FA58EEA6FBA9BAB10270:line:2011", "REPO-AA88FA58EEA6FBA9BAB10270:line:500"]
target_requirement_status = "planned_uncreated"
target_requirement_id = ""
owner_decision = ""
allowed_resolutions = ["keep_a", "keep_b", "compose", "reject_both"]
affected_task_scopes = ["object.future-step", "object.step"]
nonclaims = "No conflict is resolved; no final Constitution or Atlas law is approved; no source, test, product, runtime, visual, accessibility, privacy, device, CloudKit, TestFlight, App Store, or release Green claim is made."
claim_ceiling = "Task 12 shadow conflict provenance, recommendation, and impact analysis only for the reviewed claims and base SHA; no source-edit or cutover authorization."

[[claims]]
claim_id = "CLAIM-OBJ-058"
source_id = "REPO-AA88FA58EEA6FBA9BAB10270"
source_location = "line:2011"
concept = "object.future-step.identity"
scope = "object.future-step"
modality = "MUST"
normalized_value = "a scheduled flexible future step planning node."
evidence_sha256 = "0ab4ea73eee828f2acba38f445a11bec4195dc2827459d9c46c609d7b0e5f895"
owner_approval = "active-repo-authority:PRODUCT_EXPERIENCE_CANON.md"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[claims]]
claim_id = "CLAIM-STB-0551"
source_id = "REPO-AA88FA58EEA6FBA9BAB10270"
source_location = "line:500"
concept = "product.future-steps"
scope = "active product and engineering authority migration"
modality = "INFORMATIONAL"
normalized_value = "user-facing term:"
evidence_sha256 = "2667c61841ade3549e744601f0adf3f72e0d0dafcd63b12c70e699aa44f67fe9"
owner_approval = "active-repo-authority:docs/truth/PRODUCT_EXPERIENCE_CANON.md"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[impacts]]
dimension = "repo"
analysis = "Product Experience references become provisional provenance until an object/role specification owns the term."

[[impacts]]
dimension = "linear"
analysis = "The canonical object taxonomy must record whether Future Step is omitted intentionally or represented by Step law."

[[impacts]]
dimension = "figma"
analysis = "Future-path nodes require provisional/committed and time-window semantics plus accessible non-color distinction."

[[impacts]]
dimension = "production_source"
analysis = "Current generic Step timing and planning fields are source-present, not a FutureStep implementation."

[[impacts]]
dimension = "tests"
analysis = "Later require identity, path/stage links, time windows, edit impact, deletion/restore, recurrence, persistence, and migration tests."

[[impacts]]
dimension = "proof"
analysis = "Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven."

[[impacts]]
dimension = "privacy"
analysis = "Any role or object inherits Step private-graph classification unless separately approved."

[[impacts]]
dimension = "accessibility"
analysis = "Provisional/future state and time window need plain labels and non-color/non-motion equivalents."

[[impacts]]
dimension = "migration_rollback"
analysis = "Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag."
+++

# CONFLICT-FUTURE-STEP-IDENTITY

> Shadow migration decision docket. It is non-authoritative and remains unresolved until the owner records a decision.

## Competing conceptual claims

| Claim | Normalized value | Modality | Scope | Source provenance | Evidence SHA-256 |
| --- | --- | --- | --- | --- | --- |
| `CLAIM-OBJ-058` | a scheduled flexible future step planning node. | `MUST` | object.future-step | `REPO-AA88FA58EEA6FBA9BAB10270:line:2011` | `0ab4ea73eee828f2acba38f445a11bec4195dc2827459d9c46c609d7b0e5f895` |
| `CLAIM-STB-0551` | user-facing term: | `INFORMATIONAL` | active product and engineering authority migration | `REPO-AA88FA58EEA6FBA9BAB10270:line:500` | `2667c61841ade3549e744601f0adf3f72e0d0dafcd63b12c70e699aa44f67fe9` |

## User consequences

A separate Future Step object can duplicate identity and break Goal Path, schedule, deletion, recurrence, and receipt relationships.

## Compatibility analysis

Both accepted claims support the noun; the conflict is its omission from v3 taxonomy and whether it is an object, Step role, placement state, or path-node subtype. No dedicated production type or proof exists.

## Recommendation

**Reject both and introduce a stronger third law.** Do not canonize a noun until identity and lifecycle boundaries are complete.

This is a recommendation for Gate A, not an owner decision.

## Stronger composition option

Prefer a Step role or placement state if it preserves one Step identity; create a separate object only if unique lifecycle law requires it.

## Proposed canonical law

Future Step MUST be specified as exactly one canonical Step role, placement state, path-node subtype, or distinct object before implementation; it MUST NOT create duplicate identity or lineage.

## Impact analysis

| Dimension | Impact |
| --- | --- |
| repo | Product Experience references become provisional provenance until an object/role specification owns the term. |
| Linear | The canonical object taxonomy must record whether Future Step is omitted intentionally or represented by Step law. |
| Figma | Future-path nodes require provisional/committed and time-window semantics plus accessible non-color distinction. |
| production source | Current generic Step timing and planning fields are source-present, not a FutureStep implementation. |
| tests | Later require identity, path/stage links, time windows, edit impact, deletion/restore, recurrence, persistence, and migration tests. |
| proof | Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven. |
| privacy | Any role or object inherits Step private-graph classification unless separately approved. |
| accessibility | Provisional/future state and time window need plain labels and non-color/non-motion equivalents. |
| migration / rollback | Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag. |

## Artifacts to supersede

- `REPO-AA88FA58EEA6FBA9BAB10270:line:2011`
- `REPO-AA88FA58EEA6FBA9BAB10270:line:500`

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
