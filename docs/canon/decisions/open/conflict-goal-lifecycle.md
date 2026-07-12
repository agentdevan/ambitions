+++
schema_version = 1
conflict_id = "CONFLICT-GOAL-LIFECYCLE"
status = "unresolved"
severity = "P0_BLOCKER"
priority = "P0"
concepts = ["object.goal.identity-lifecycle", "object.goal.lifecycle"]
scopes = ["object.goal.lifecycle"]
recommendation = "keep_b"
recommendation_rationale = "Separate user-controlled lifecycle from advisory runtime state and use humane Ended language, while retaining compatible state provenance."
stronger_composition = "Define lifecycle, advisory, constraint, closure, and archive axes with valid/invalid transitions and receipts."
proposed_canonical_law = "Goal lifecycle MUST be user-controlled and distinct from advisory or constraint state; the product MUST use Ended rather than Abandoned and MUST preserve resume, archive, history, and rollback semantics."
artifacts_to_supersede = ["LINEAR-CANON-V3:line:300", "REPO-43E0D80464B2869224C805D8:line:1134"]
target_requirement_status = "planned_uncreated"
target_requirement_id = ""
owner_decision = ""
allowed_resolutions = ["keep_a", "keep_b", "compose", "reject_both"]
affected_task_scopes = ["object.goal"]
nonclaims = "No conflict is resolved; no final Constitution or Atlas law is approved; no source, test, product, runtime, visual, accessibility, privacy, device, CloudKit, TestFlight, App Store, or release Green claim is made."
claim_ceiling = "Task 12 shadow conflict provenance, recommendation, and impact analysis only for the reviewed claims and base SHA; no source-edit or cutover authorization."

[[claims]]
claim_id = "CLAIM-OBJ-002"
source_id = "LINEAR-CANON-V3"
source_location = "line:300"
concept = "object.goal.identity-lifecycle"
scope = "object.goal.lifecycle"
modality = "MUST"
normalized_value = "draft, ready to activate, active, needs attention, recovering, paused, waiting, blocked, completed, archived, abandoned."
evidence_sha256 = "fe3a1c9e9276ab53ce14453a20837b53240dbb7dcc64fdb4012b0cc8bb9af5b4"
owner_approval = "owner-approved:linear-v3"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[claims]]
claim_id = "CLAIM-OBJ-038"
source_id = "REPO-43E0D80464B2869224C805D8"
source_location = "line:1134"
concept = "object.goal.lifecycle"
scope = "object.goal.lifecycle"
modality = "MUST"
normalized_value = "user-controlled lifecycle is distinct from advisory runtime state and uses ended rather than abandoned."
evidence_sha256 = "52cb44aec788adcb760ff3eac6b3a2c3a63f5a3b8679652af0140202c91693d2"
owner_approval = "active-repo-authority:PRODUCT_DESIGN_TRUTH.md"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[impacts]]
dimension = "repo"
analysis = "Product Design Goal law should own the axes; older mixed-state lists become provenance."

[[impacts]]
dimension = "linear"
analysis = "The v3 object matrix lifecycle row requires supersession after owner approval."

[[impacts]]
dimension = "figma"
analysis = "Goal state frames must distinguish user action from advisory condition and use approved humane copy."

[[impacts]]
dimension = "production_source"
analysis = "GoalLifecycleState and GoalPortfolioLifecycleState are source-present drift and require later versioned migration, not Task 12 edits."

[[impacts]]
dimension = "tests"
analysis = "Later require full transition matrix, invalid transitions, receipts, projections, deletion/restore, reload, and migration tests."

[[impacts]]
dimension = "proof"
analysis = "Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven."

[[impacts]]
dimension = "privacy"
analysis = "Lifecycle and advisory history remain private graph data and must not leak through diagnostics."

[[impacts]]
dimension = "accessibility"
analysis = "Labels and actions must distinguish condition from lifecycle without shame and announce consequences and undo."

[[impacts]]
dimension = "migration_rollback"
analysis = "Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag."
+++

# CONFLICT-GOAL-LIFECYCLE

> Shadow migration decision docket. It is non-authoritative and remains unresolved until the owner records a decision.

## Competing conceptual claims

| Claim | Normalized value | Modality | Scope | Source provenance | Evidence SHA-256 |
| --- | --- | --- | --- | --- | --- |
| `CLAIM-OBJ-002` | draft, ready to activate, active, needs attention, recovering, paused, waiting, blocked, completed, archived, abandoned. | `MUST` | object.goal.lifecycle | `LINEAR-CANON-V3:line:300` | `fe3a1c9e9276ab53ce14453a20837b53240dbb7dcc64fdb4012b0cc8bb9af5b4` |
| `CLAIM-OBJ-038` | user-controlled lifecycle is distinct from advisory runtime state and uses ended rather than abandoned. | `MUST` | object.goal.lifecycle | `REPO-43E0D80464B2869224C805D8:line:1134` | `52cb44aec788adcb760ff3eac6b3a2c3a63f5a3b8679652af0140202c91693d2` |

## User consequences

The app may infer an ending, use shaming Abandoned language, or confuse a temporary blocked condition with a user-controlled lifecycle action.

## Compatibility analysis

Needs Attention, Recovering, Waiting, and Blocked can coexist only on an orthogonal advisory axis; Ended and Abandoned are not equivalent user meanings. Live source has two narrower enum axes and matches neither proposal.

## Recommendation

**Keep B; supersede A.** Separate user-controlled lifecycle from advisory runtime state and use humane Ended language, while retaining compatible state provenance.

This is a recommendation for Gate A, not an owner decision.

## Stronger composition option

Define lifecycle, advisory, constraint, closure, and archive axes with valid/invalid transitions and receipts.

## Proposed canonical law

Goal lifecycle MUST be user-controlled and distinct from advisory or constraint state; the product MUST use Ended rather than Abandoned and MUST preserve resume, archive, history, and rollback semantics.

## Impact analysis

| Dimension | Impact |
| --- | --- |
| repo | Product Design Goal law should own the axes; older mixed-state lists become provenance. |
| Linear | The v3 object matrix lifecycle row requires supersession after owner approval. |
| Figma | Goal state frames must distinguish user action from advisory condition and use approved humane copy. |
| production source | GoalLifecycleState and GoalPortfolioLifecycleState are source-present drift and require later versioned migration, not Task 12 edits. |
| tests | Later require full transition matrix, invalid transitions, receipts, projections, deletion/restore, reload, and migration tests. |
| proof | Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven. |
| privacy | Lifecycle and advisory history remain private graph data and must not leak through diagnostics. |
| accessibility | Labels and actions must distinguish condition from lifecycle without shame and announce consequences and undo. |
| migration / rollback | Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag. |

## Artifacts to supersede

- `LINEAR-CANON-V3:line:300`
- `REPO-43E0D80464B2869224C805D8:line:1134`

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
