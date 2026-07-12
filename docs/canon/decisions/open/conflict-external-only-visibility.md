+++
schema_version = 1
conflict_id = "CONFLICT-EXTERNAL-ONLY-VISIBILITY"
status = "unresolved"
severity = "P0_BLOCKER"
priority = "P0"
concepts = ["linear.decision.external-only-bridge-visibility", "product.time-import-004-visibility-versus-planning-capacity"]
scopes = ["active product and engineering authority migration", "linear v3 decision 146; owner-evidence-backed migration topology"]
recommendation = "compose"
recommendation_rationale = "Keep external candidates out of primary native-object presentation until import while preserving explicit, privacy-filtered capacity awareness and review."
stronger_composition = "Define candidate, capacity-only, imported, linked, ignored, rejected, and source-removed states with lineage and rollback."
proposed_canonical_law = "External-only calendar items MUST NOT appear as Ambitions Events before user-approved import or link, but Time MUST preserve an explicit privacy-filtered capacity/review model so hidden commitments cannot silently cause overbooking."
artifacts_to_supersede = ["LINEAR-CANON-V3:decision:146", "REPO-43E0D80464B2869224C805D8:line:1491"]
target_requirement_status = "planned_uncreated"
target_requirement_id = ""
owner_decision = ""
allowed_resolutions = ["keep_a", "keep_b", "compose", "reject_both"]
affected_task_scopes = ["journey.external-calendar-import", "surface.time"]
nonclaims = "No conflict is resolved; no final Constitution or Atlas law is approved; no source, test, product, runtime, visual, accessibility, privacy, device, CloudKit, TestFlight, App Store, or release Green claim is made."
claim_ceiling = "Task 12 shadow conflict provenance, recommendation, and impact analysis only for the reviewed claims and base SHA; no source-edit or cutover authorization."

[[claims]]
claim_id = "CLAIM-LFT-0146"
source_id = "LINEAR-CANON-V3"
source_location = "decision:146"
concept = "linear.decision.external-only-bridge-visibility"
scope = "linear v3 decision 146; owner-evidence-backed migration topology"
modality = "INFORMATIONAL"
normalized_value = "5. external-only items remain absent from time."
evidence_sha256 = "444bffff25cfbc44e738d02c1eff565034d3ab56551ade926a67bdde99819a0f"
owner_approval = "linear-comment:2b17d9c0-3cb4-4300-a3c0-17a9c20cf225:decision:146"
owner_evidence_text_sha256 = "b77490c182e2ecd8c6d3a84a743a916a5aacbe8290d12bbadc10122ab2399621"
owner_evidence_rationale_sha256 = "fc80df562f66d77d317d64f4ad014b5679b6f55f4695c709bd76f14a5eff02e5"

[[claims]]
claim_id = "CLAIM-STB-0140"
source_id = "REPO-43E0D80464B2869224C805D8"
source_location = "line:1491"
concept = "product.time-import-004-visibility-versus-planning-capacity"
scope = "active product and engineering authority migration"
modality = "INFORMATIONAL"
normalized_value = "external candidate visibility and capacity awareness are separate."
evidence_sha256 = "727756402df7704064674238c86532b58ebb96a1d1349d7a461996b426f8880c"
owner_approval = "active-repo-authority:docs/truth/PRODUCT_DESIGN_TRUTH.md"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[impacts]]
dimension = "repo"
analysis = "Time import, external-change, capacity, privacy, and degraded-state specs require one distinction."

[[impacts]]
dimension = "linear"
analysis = "Decision 146 and Decisions 139-145 require disposition to the scoped visibility/capacity requirements."

[[impacts]]
dimension = "figma"
analysis = "Time authority needs candidate badge, review, capacity-only, import/link/ignore/reject, and failure states."

[[impacts]]
dimension = "production_source"
analysis = "EventKit and TimeCalendarAwarenessSupport use external events for conflicts but do not prove the complete review disposition model."

[[impacts]]
dimension = "tests"
analysis = "Later require permission denial, capacity without title leakage, import/link identity, duplicates, recurrence, changes, ignore/reject, source removal, rollback, and offline behavior."

[[impacts]]
dimension = "proof"
analysis = "Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven."

[[impacts]]
dimension = "privacy"
analysis = "Titles, attendees, locations, invite metadata, and provenance must be minimized; capacity may be represented without exposing content."

[[impacts]]
dimension = "accessibility"
analysis = "Hidden-versus-capacity state and review actions require nonvisual explanation without disclosing private external text."

[[impacts]]
dimension = "migration_rollback"
analysis = "Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag."
+++

# CONFLICT-EXTERNAL-ONLY-VISIBILITY

> Shadow migration decision docket. It is non-authoritative and remains unresolved until the owner records a decision.

## Competing conceptual claims

| Claim | Normalized value | Modality | Scope | Source provenance | Evidence SHA-256 |
| --- | --- | --- | --- | --- | --- |
| `CLAIM-LFT-0146` | 5. external-only items remain absent from time. | `INFORMATIONAL` | linear v3 decision 146; owner-evidence-backed migration topology | `LINEAR-CANON-V3:decision:146` | `444bffff25cfbc44e738d02c1eff565034d3ab56551ade926a67bdde99819a0f` |
| `CLAIM-STB-0140` | external candidate visibility and capacity awareness are separate. | `INFORMATIONAL` | active product and engineering authority migration | `REPO-43E0D80464B2869224C805D8:line:1491` | `727756402df7704064674238c86532b58ebb96a1d1349d7a461996b426f8880c` |

## User consequences

Hidden external commitments can cause overbooking, while silent visibility/import can pull external private data into the graph without user control.

## Compatibility analysis

Primary Time visibility, review-badge visibility, capacity awareness, import/link, and Ignore for planning are distinct scopes. Capacity reservation need not create an Ambitions Event.

## Recommendation

**Compose A and B with explicit scopes.** Keep external candidates out of primary native-object presentation until import while preserving explicit, privacy-filtered capacity awareness and review.

This is a recommendation for Gate A, not an owner decision.

## Stronger composition option

Define candidate, capacity-only, imported, linked, ignored, rejected, and source-removed states with lineage and rollback.

## Proposed canonical law

External-only calendar items MUST NOT appear as Ambitions Events before user-approved import or link, but Time MUST preserve an explicit privacy-filtered capacity/review model so hidden commitments cannot silently cause overbooking.

## Impact analysis

| Dimension | Impact |
| --- | --- |
| repo | Time import, external-change, capacity, privacy, and degraded-state specs require one distinction. |
| Linear | Decision 146 and Decisions 139-145 require disposition to the scoped visibility/capacity requirements. |
| Figma | Time authority needs candidate badge, review, capacity-only, import/link/ignore/reject, and failure states. |
| production source | EventKit and TimeCalendarAwarenessSupport use external events for conflicts but do not prove the complete review disposition model. |
| tests | Later require permission denial, capacity without title leakage, import/link identity, duplicates, recurrence, changes, ignore/reject, source removal, rollback, and offline behavior. |
| proof | Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven. |
| privacy | Titles, attendees, locations, invite metadata, and provenance must be minimized; capacity may be represented without exposing content. |
| accessibility | Hidden-versus-capacity state and review actions require nonvisual explanation without disclosing private external text. |
| migration / rollback | Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag. |

## Artifacts to supersede

- `LINEAR-CANON-V3:decision:146`
- `REPO-43E0D80464B2869224C805D8:line:1491`

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
