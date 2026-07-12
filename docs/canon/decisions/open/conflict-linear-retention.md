+++
schema_version = 1
conflict_id = "CONFLICT-LINEAR-RETENTION"
status = "unresolved"
severity = "P0_BLOCKER"
priority = "P0"
concepts = ["history.external.linear-retention", "history.generated-state.retention"]
scopes = ["history.external.linear", "history.generated-state"]
recommendation = "compose"
recommendation_rationale = "Preserve provenance, not duplicate product law; perform deletion only at Gate C after exact extraction, rewrites, review, rollback, and owner approval."
stronger_composition = "Define retained provenance fields and a destruction eligibility manifest separately from execution/status retention."
proposed_canonical_law = "The migration MUST preserve decision provenance through stable IDs, hashes, dispositions, replacement requirements, supersession metadata, and rollback history; superseded external doctrine MUST NOT remain an active authority after owner-approved destructive cleanup."
artifacts_to_supersede = ["LINEAR-CANON-V3:line:1283", "LINEAR-DOC:5a259a56-ce24-46f3-bb36-f7e12ae2417f", "LINEAR-DOC:95eae2b4-603f-49bb-b241-90fb8871c396", "LINEAR-DOC:96b93346-271d-46fc-beab-43ff7e286b5d"]
target_requirement_status = "planned_uncreated"
target_requirement_id = ""
owner_decision = ""
allowed_resolutions = ["keep_a", "keep_b", "compose", "reject_both"]
affected_task_scopes = ["governance.external-authority", "governance.purge"]
nonclaims = "No conflict is resolved; no final Constitution or Atlas law is approved; no source, test, product, runtime, visual, accessibility, privacy, device, CloudKit, TestFlight, App Store, or release Green claim is made."
claim_ceiling = "Task 12 shadow conflict provenance, recommendation, and impact analysis only for the reviewed claims and base SHA; no source-edit or cutover authorization."

[[claims]]
claim_id = "CLAIM-PRC-033"
source_id = "REPO-8E5E95467C0AAC813830AA24"
source_location = "line:311"
concept = "history.generated-state.retention"
scope = "history.generated-state"
modality = "MUST"
normalized_value = "ignored by default and not retained as history."
evidence_sha256 = "f81baeb98d9b5ebf71fb2fa315a648df6e7b1f5ba17abec46662a71bfea82ac7"
owner_approval = "active-repo-authority:CODEX_PROCESS_TRUTH.md"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[claims]]
claim_id = "CLAIM-PRC-079"
source_id = "LINEAR-CANON-V3"
source_location = "line:1283"
concept = "history.external.linear-retention"
scope = "history.external.linear"
modality = "SHOULD"
normalized_value = "traceability artifacts."
evidence_sha256 = "64b9a3c80740aa8b3377138e28dcd4936f9e8eaff6b68739b9264be2599e6971"
owner_approval = "linear-document:96b93346-271d-46fc-beab-43ff7e286b5d owner:Devan Warner"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[impacts]]
dimension = "repo"
analysis = "Source catalog, disposition graph, supersession ledger, purge manifest, inbound references, and Git tags are affected."

[[impacts]]
dimension = "linear"
analysis = "V3 document 96b93346-271d-46fc-beab-43ff7e286b5d, input ledger, decisions/comments, and v2 require an exact Gate C manifest before mutation."

[[impacts]]
dimension = "figma"
analysis = "Annotations citing Linear decision numbers require replacement requirement IDs before any cleanup."

[[impacts]]
dimension = "production_source"
analysis = "No production Swift behavior is affected; only compiler purge/reference verification later changes."

[[impacts]]
dimension = "tests"
analysis = "Later require unique-content extraction, inbound-reference scan, replacement resolution, connector manifest, rollback, and independent-review tests."

[[impacts]]
dimension = "proof"
analysis = "Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven."

[[impacts]]
dimension = "privacy"
analysis = "Tracked provenance must exclude owner email, raw private text, attachment URLs, credentials, and connector payloads."

[[impacts]]
dimension = "accessibility"
analysis = "No direct app behavior; deleted external artifacts must not remain cited as accessibility evidence."

[[impacts]]
dimension = "migration_rollback"
analysis = "Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag."
+++

# CONFLICT-LINEAR-RETENTION

> Shadow migration decision docket. It is non-authoritative and remains unresolved until the owner records a decision.

## Competing conceptual claims

| Claim | Normalized value | Modality | Scope | Source provenance | Evidence SHA-256 |
| --- | --- | --- | --- | --- | --- |
| `CLAIM-PRC-033` | ignored by default and not retained as history. | `MUST` | history.generated-state | `REPO-8E5E95467C0AAC813830AA24:line:311` | `f81baeb98d9b5ebf71fb2fa315a648df6e7b1f5ba17abec46662a71bfea82ac7` |
| `CLAIM-PRC-079` | traceability artifacts. | `SHOULD` | history.external.linear | `LINEAR-CANON-V3:line:1283` | `64b9a3c80740aa8b3377138e28dcd4936f9e8eaff6b68739b9264be2599e6971` |

## User consequences

Premature deletion loses decision provenance; indefinite retention preserves duplicate active authority that can re-enter implementation work.

## Compatibility analysis

Traceability can survive as stable IDs, hashes, dispositions, replacement requirements, compact supersession entries, and Git history without retaining the active Linear doctrine document.

## Recommendation

**Compose A and B with explicit scopes.** Preserve provenance, not duplicate product law; perform deletion only at Gate C after exact extraction, rewrites, review, rollback, and owner approval.

This is a recommendation for Gate A, not an owner decision.

## Stronger composition option

Define retained provenance fields and a destruction eligibility manifest separately from execution/status retention.

## Proposed canonical law

The migration MUST preserve decision provenance through stable IDs, hashes, dispositions, replacement requirements, supersession metadata, and rollback history; superseded external doctrine MUST NOT remain an active authority after owner-approved destructive cleanup.

## Impact analysis

| Dimension | Impact |
| --- | --- |
| repo | Source catalog, disposition graph, supersession ledger, purge manifest, inbound references, and Git tags are affected. |
| Linear | V3 document 96b93346-271d-46fc-beab-43ff7e286b5d, input ledger, decisions/comments, and v2 require an exact Gate C manifest before mutation. |
| Figma | Annotations citing Linear decision numbers require replacement requirement IDs before any cleanup. |
| production source | No production Swift behavior is affected; only compiler purge/reference verification later changes. |
| tests | Later require unique-content extraction, inbound-reference scan, replacement resolution, connector manifest, rollback, and independent-review tests. |
| proof | Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven. |
| privacy | Tracked provenance must exclude owner email, raw private text, attachment URLs, credentials, and connector payloads. |
| accessibility | No direct app behavior; deleted external artifacts must not remain cited as accessibility evidence. |
| migration / rollback | Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag. |

## Artifacts to supersede

- `LINEAR-CANON-V3:line:1283`
- `LINEAR-DOC:5a259a56-ce24-46f3-bb36-f7e12ae2417f`
- `LINEAR-DOC:95eae2b4-603f-49bb-b241-90fb8871c396`
- `LINEAR-DOC:96b93346-271d-46fc-beab-43ff7e286b5d`

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
