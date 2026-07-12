+++
schema_version = 1
conflict_id = "CONFLICT-GRAPH-HIERARCHY-PROJECTIONS"
status = "unresolved"
severity = "P0_BLOCKER"
priority = "P0"
concepts = ["linear.decision.graph-relationships-and-surface-projections", "object.graph.single-canonical"]
scopes = ["linear v3 decision 195; owner-evidence-backed migration topology", "object.graph"]
recommendation = "compose"
recommendation_rationale = "Keep one canonical local identity graph and define surfaces as projections/lenses without leaking runtime taxonomy into user language."
stronger_composition = "Specify identity owner, relationships, projection derivation, replay/rebuild, source-of-truth direction, and user-facing hierarchy separately."
proposed_canonical_law = "Ambitions MUST maintain one canonical local identity graph; surfaces and search MUST be derived projections or lenses and MUST NOT become independent object stores or mutation authorities."
artifacts_to_supersede = ["LINEAR-CANON-V3:decision:195", "LINEAR-CANON-V3:line:340"]
target_requirement_status = "planned_uncreated"
target_requirement_id = ""
owner_decision = ""
allowed_resolutions = ["keep_a", "keep_b", "compose", "reject_both"]
affected_task_scopes = ["object.graph", "system.projections"]
nonclaims = "No conflict is resolved; no final Constitution or Atlas law is approved; no source, test, product, runtime, visual, accessibility, privacy, device, CloudKit, TestFlight, App Store, or release Green claim is made."
claim_ceiling = "Task 12 shadow conflict provenance, recommendation, and impact analysis only for the reviewed claims and base SHA; no source-edit or cutover authorization."

[[claims]]
claim_id = "CLAIM-LFT-0195"
source_id = "LINEAR-CANON-V3"
source_location = "decision:195"
concept = "linear.decision.graph-relationships-and-surface-projections"
scope = "linear v3 decision 195; owner-evidence-backed migration topology"
modality = "INFORMATIONAL"
normalized_value = "there is one canonical local graph. surfaces are lenses, not separate data stores:"
evidence_sha256 = "b1e8ac9ffd835e730117df7e1f8ab3ad01c0eb779f8820dc88e0246b8aa28d73"
owner_approval = "linear-comment:8dade706-f0dd-42ab-9eca-e957bf5576ab:decision:195"
owner_evidence_text_sha256 = "c247db767180784f7de001295095cc9b84a3f24997beb876e334361f49363e56"
owner_evidence_rationale_sha256 = "116dd1d6c623dceff196cd442b49d36c347aa6bb3ede4a21786435839e5c4a79"

[[claims]]
claim_id = "CLAIM-OBJ-024"
source_id = "LINEAR-CANON-V3"
source_location = "line:340"
concept = "object.graph.single-canonical"
scope = "object.graph"
modality = "MUST"
normalized_value = "one canonical local graph; surfaces are lenses rather than separate data stores."
evidence_sha256 = "b1e8ac9ffd835e730117df7e1f8ab3ad01c0eb779f8820dc88e0246b8aa28d73"
owner_approval = "owner-approved:linear-v3"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[impacts]]
dimension = "repo"
analysis = "Object, LocalRuntimeOS state/projection, surface, and architecture specs require exact owners."

[[impacts]]
dimension = "linear"
analysis = "Decision 195 richer relationship evidence must be decomposed into object and projection requirements without semantic loss."

[[impacts]]
dimension = "figma"
analysis = "Object diagrams may visualize relationships but cannot define storage or projection authority."

[[impacts]]
dimension = "production_source"
analysis = "Domain, ObjectStateRegistry, Transactions, Projections, Inspection, and surface lenses are source-present candidates without exact requirement traceability."

[[impacts]]
dimension = "tests"
analysis = "Later require identity uniqueness, relationship integrity, projection rebuild, replay equivalence, command-only mutation, source/history links, and migration tests."

[[impacts]]
dimension = "proof"
analysis = "Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven."

[[impacts]]
dimension = "privacy"
analysis = "Projection minimization and data classification must prevent surfaces, widgets, logs, or external adapters from copying the full private graph."

[[impacts]]
dimension = "accessibility"
analysis = "User-visible relationships and projection state need plain accessible representation without architecture jargon."

[[impacts]]
dimension = "migration_rollback"
analysis = "Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag."
+++

# CONFLICT-GRAPH-HIERARCHY-PROJECTIONS

> Shadow migration decision docket. It is non-authoritative and remains unresolved until the owner records a decision.

## Competing conceptual claims

| Claim | Normalized value | Modality | Scope | Source provenance | Evidence SHA-256 |
| --- | --- | --- | --- | --- | --- |
| `CLAIM-LFT-0195` | there is one canonical local graph. surfaces are lenses, not separate data stores: | `INFORMATIONAL` | linear v3 decision 195; owner-evidence-backed migration topology | `LINEAR-CANON-V3:decision:195` | `b1e8ac9ffd835e730117df7e1f8ab3ad01c0eb779f8820dc88e0246b8aa28d73` |
| `CLAIM-OBJ-024` | one canonical local graph; surfaces are lenses rather than separate data stores. | `MUST` | object.graph | `LINEAR-CANON-V3:line:340` | `b1e8ac9ffd835e730117df7e1f8ab3ad01c0eb779f8820dc88e0246b8aa28d73` |

## User consequences

Duplicate object stores or ambiguous projection ownership can corrupt identity, relationships, replay, proof, and source/history links.

## Compatibility analysis

The one-graph headline is equivalent, but plain user hierarchy, canonical domain graph, and runtime projection topology are distinct levels. Decision 195 owner evidence contains richer relationships than the integrated claim.

## Recommendation

**Compose A and B with explicit scopes.** Keep one canonical local identity graph and define surfaces as projections/lenses without leaking runtime taxonomy into user language.

This is a recommendation for Gate A, not an owner decision.

## Stronger composition option

Specify identity owner, relationships, projection derivation, replay/rebuild, source-of-truth direction, and user-facing hierarchy separately.

## Proposed canonical law

Ambitions MUST maintain one canonical local identity graph; surfaces and search MUST be derived projections or lenses and MUST NOT become independent object stores or mutation authorities.

## Impact analysis

| Dimension | Impact |
| --- | --- |
| repo | Object, LocalRuntimeOS state/projection, surface, and architecture specs require exact owners. |
| Linear | Decision 195 richer relationship evidence must be decomposed into object and projection requirements without semantic loss. |
| Figma | Object diagrams may visualize relationships but cannot define storage or projection authority. |
| production source | Domain, ObjectStateRegistry, Transactions, Projections, Inspection, and surface lenses are source-present candidates without exact requirement traceability. |
| tests | Later require identity uniqueness, relationship integrity, projection rebuild, replay equivalence, command-only mutation, source/history links, and migration tests. |
| proof | Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven. |
| privacy | Projection minimization and data classification must prevent surfaces, widgets, logs, or external adapters from copying the full private graph. |
| accessibility | User-visible relationships and projection state need plain accessible representation without architecture jargon. |
| migration / rollback | Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag. |

## Artifacts to supersede

- `LINEAR-CANON-V3:decision:195`
- `LINEAR-CANON-V3:line:340`

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
