+++
schema_version = 1
conflict_id = "CONFLICT-ROOT-BRANDED-NAMING"
status = "unresolved"
severity = "P0_BLOCKER"
priority = "P1"
concepts = ["linear.decision.root-nav-labels-icons", "moat.surface.goals.anti-commodity", "moat.surface.naming-authority", "visual.object.naming"]
scopes = ["goals surface moat requirements", "linear v3 decision 28; owner-evidence-backed migration topology", "surface naming and product interpretation", "visual.figma"]
recommendation = "compose"
recommendation_rationale = "Keep plain root/object language and explicitly classify branded or visual anatomy as internal unless owner-approved copy says otherwise."
stronger_composition = "Create a naming matrix for visible copy, accessibility labels, internal identifiers, and Figma annotations."
proposed_canonical_law = "Root navigation and canonical objects MUST use plain comprehensible user language; icon-only visual treatment MUST retain accessible labels, and internal branded anatomy MUST NOT silently become product copy."
artifacts_to_supersede = ["LINEAR-CANON-V3:decision:28", "REPO-24AE31A618868443E87AFB86:line:186", "REPO-24AE31A618868443E87AFB86:line:198", "REPO-8AD090B849C0D640D8D8B4B1:line:238"]
target_requirement_status = "planned_uncreated"
target_requirement_id = ""
owner_decision = ""
allowed_resolutions = ["keep_a", "keep_b", "compose", "reject_both"]
affected_task_scopes = ["shell.root-navigation", "surface.goals"]
nonclaims = "No conflict is resolved; no final Constitution or Atlas law is approved; no source, test, product, runtime, visual, accessibility, privacy, device, CloudKit, TestFlight, App Store, or release Green claim is made."
claim_ceiling = "Task 12 shadow conflict provenance, recommendation, and impact analysis only for the reviewed claims and base SHA; no source-edit or cutover authorization."

[[claims]]
claim_id = "CLAIM-LFT-0028"
source_id = "LINEAR-CANON-V3"
source_location = "decision:28"
concept = "linear.decision.root-nav-labels-icons"
scope = "linear v3 decision 28; owner-evidence-backed migration topology"
modality = "INFORMATIONAL"
normalized_value = "the root dock contains four icon-only root controls and appears only at root depth. drilldowns use a top-left back control and the native edge-swipe gesture. capture and search are context-appropriate top actions; they are not persistent floating buttons and do not occupy a fifth dock position."
evidence_sha256 = "af2d63cb62f27ff6db7f3c73c8d779cb5940397cf50b8274910d30ca7f0fcfe2"
owner_approval = "linear-comment:ae021cae-1f3a-4dfc-80ea-119db7e8c481:decision:28"
owner_evidence_text_sha256 = "7147da5ad9d33ceecb05b4da26fc9be4af5b68b5298fb57a7a49a86a2c99b46f"
owner_evidence_rationale_sha256 = "5be0fc157bd805404e3b8eab28d02eb026924420fe89521ac985446f9df0e10d"

[[claims]]
claim_id = "CLAIM-MOM-0041"
source_id = "REPO-24AE31A618868443E87AFB86"
source_location = "line:186"
concept = "moat.surface.naming-authority"
scope = "surface naming and product interpretation"
modality = "MUST NOT"
normalized_value = "current product design truth"
evidence_sha256 = "671154dab58170e25889c3967747ea35f9d721e3fbf7092ce7271821085dc704"
owner_approval = "active repo authority"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[claims]]
claim_id = "CLAIM-MOM-0055"
source_id = "REPO-24AE31A618868443E87AFB86"
source_location = "line:198"
concept = "moat.surface.goals.anti-commodity"
scope = "goals surface moat requirements"
modality = "MUST"
normalized_value = "life areas, goal threads, proof trail, and direction continuity over score cards, dashboards, or generic lists"
evidence_sha256 = "87959f926738aa4570c5e12329b4db1610474a0b96d1b87711360fa44dec5be8"
owner_approval = "active repo authority"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[claims]]
claim_id = "CLAIM-NAV-034"
source_id = "REPO-8AD090B849C0D640D8D8B4B1"
source_location = "line:238"
concept = "visual.object.naming"
scope = "visual.figma"
modality = "MUST"
normalized_value = "direction field / life area row / completed-total relationship."
evidence_sha256 = "d4fba9a26bc96d86057a839955e63bb279caa380d9daa1c273feb58c5b1f2087"
owner_approval = "active-repo-authority:FIGMA_PRODUCTION_GATE_ADDENDUM.md"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[impacts]]
dimension = "repo"
analysis = "Product Moat, AGENTS naming, shell/Goals truth, and copy standards require one scoped vocabulary."

[[impacts]]
dimension = "linear"
analysis = "Decision 28 icon/label evidence and root-navigation clauses need exact disposition."

[[impacts]]
dimension = "figma"
analysis = "Direction Field and Life Area Row may remain visual annotations only if the approved mapping says so."

[[impacts]]
dimension = "production_source"
analysis = "ContinuityDock and Goals projectors contain source-present labels; Task 12 does not rewrite UI or localization."

[[impacts]]
dimension = "tests"
analysis = "Later verify visible labels, accessibility labels, localization, route identity, and Goals first-viewport hierarchy."

[[impacts]]
dimension = "proof"
analysis = "Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven."

[[impacts]]
dimension = "privacy"
analysis = "No direct privacy-law change; private Goal content must still be absent from inappropriate labels and snapshots."

[[impacts]]
dimension = "accessibility"
analysis = "VoiceOver labels, focus, hit targets, and large Dynamic Type comprehension are mandatory regardless of visual icon treatment."

[[impacts]]
dimension = "migration_rollback"
analysis = "Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag."
+++

# CONFLICT-ROOT-BRANDED-NAMING

> Shadow migration decision docket. It is non-authoritative and remains unresolved until the owner records a decision.

## Competing conceptual claims

| Claim | Normalized value | Modality | Scope | Source provenance | Evidence SHA-256 |
| --- | --- | --- | --- | --- | --- |
| `CLAIM-LFT-0028` | the root dock contains four icon-only root controls and appears only at root depth. drilldowns use a top-left back control and the native edge-swipe gesture. capture and search are context-appropriate top actions; they are not persistent floating buttons and do not occupy a fifth dock position. | `INFORMATIONAL` | linear v3 decision 28; owner-evidence-backed migration topology | `LINEAR-CANON-V3:decision:28` | `af2d63cb62f27ff6db7f3c73c8d779cb5940397cf50b8274910d30ca7f0fcfe2` |
| `CLAIM-MOM-0041` | current product design truth | `MUST NOT` | surface naming and product interpretation | `REPO-24AE31A618868443E87AFB86:line:186` | `671154dab58170e25889c3967747ea35f9d721e3fbf7092ce7271821085dc704` |
| `CLAIM-MOM-0055` | life areas, goal threads, proof trail, and direction continuity over score cards, dashboards, or generic lists | `MUST` | goals surface moat requirements | `REPO-24AE31A618868443E87AFB86:line:198` | `87959f926738aa4570c5e12329b4db1610474a0b96d1b87711360fa44dec5be8` |
| `CLAIM-NAV-034` | direction field / life area row / completed-total relationship. | `MUST` | visual.figma | `REPO-8AD090B849C0D640D8D8B4B1:line:238` | `d4fba9a26bc96d86057a839955e63bb279caa380d9daa1c273feb58c5b1f2087` |

## User consequences

Users can receive unlabeled root navigation or internal design nouns as primary copy, undermining comprehension and plain object meaning.

## Compatibility analysis

Visible root labels, icon glyphs, accessibility labels, canonical object names, and internal/Figma anatomy are different scopes. Anti-commodity wording describes product meaning, not necessarily user-facing copy.

## Recommendation

**Compose A and B with explicit scopes.** Keep plain root/object language and explicitly classify branded or visual anatomy as internal unless owner-approved copy says otherwise.

This is a recommendation for Gate A, not an owner decision.

## Stronger composition option

Create a naming matrix for visible copy, accessibility labels, internal identifiers, and Figma annotations.

## Proposed canonical law

Root navigation and canonical objects MUST use plain comprehensible user language; icon-only visual treatment MUST retain accessible labels, and internal branded anatomy MUST NOT silently become product copy.

## Impact analysis

| Dimension | Impact |
| --- | --- |
| repo | Product Moat, AGENTS naming, shell/Goals truth, and copy standards require one scoped vocabulary. |
| Linear | Decision 28 icon/label evidence and root-navigation clauses need exact disposition. |
| Figma | Direction Field and Life Area Row may remain visual annotations only if the approved mapping says so. |
| production source | ContinuityDock and Goals projectors contain source-present labels; Task 12 does not rewrite UI or localization. |
| tests | Later verify visible labels, accessibility labels, localization, route identity, and Goals first-viewport hierarchy. |
| proof | Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven. |
| privacy | No direct privacy-law change; private Goal content must still be absent from inappropriate labels and snapshots. |
| accessibility | VoiceOver labels, focus, hit targets, and large Dynamic Type comprehension are mandatory regardless of visual icon treatment. |
| migration / rollback | Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag. |

## Artifacts to supersede

- `LINEAR-CANON-V3:decision:28`
- `REPO-24AE31A618868443E87AFB86:line:186`
- `REPO-24AE31A618868443E87AFB86:line:198`
- `REPO-8AD090B849C0D640D8D8B4B1:line:238`

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
