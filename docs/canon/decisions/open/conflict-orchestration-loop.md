+++
schema_version = 1
conflict_id = "CONFLICT-ORCHESTRATION-LOOP"
status = "unresolved"
severity = "P0_BLOCKER"
priority = "P0"
concepts = ["linear.decision.ambitions-moat-model", "mission.product.core-loop"]
scopes = ["complete private-life orchestration loop", "linear v3 decision 70; owner-evidence-backed migration topology", "product orchestration loop"]
recommendation = "compose"
recommendation_rationale = "Keep the complete orchestration semantics and permit a compact mnemonic only when every omitted stage remains inherited."
stronger_composition = "Own one full loop and one explicitly non-normative shorthand whose stages map one-to-one to the full loop."
proposed_canonical_law = "Ambitions MUST orchestrate Intent through Context, Path, Placement / Time Fit, Reflow / Recovery, Action, Closure / Proof, and Learning; a shorthand MUST NOT remove or reorder required behavior."
artifacts_to_supersede = ["LINEAR-CANON-V3:decision:70", "LINEAR-CANON-V3:line:51", "REPO-B11ED8716F99F213DF6470B4:line:35"]
target_requirement_status = "planned_uncreated"
target_requirement_id = ""
owner_decision = ""
allowed_resolutions = ["keep_a", "keep_b", "compose", "reject_both"]
affected_task_scopes = ["mission.orchestration", "system.private-life-runtime"]
nonclaims = "No conflict is resolved; no final Constitution or Atlas law is approved; no source, test, product, runtime, visual, accessibility, privacy, device, CloudKit, TestFlight, App Store, or release Green claim is made."
claim_ceiling = "Task 12 shadow conflict provenance, recommendation, and impact analysis only for the reviewed claims and base SHA; no source-edit or cutover authorization."

[[claims]]
claim_id = "CLAIM-LFT-0070"
source_id = "LINEAR-CANON-V3"
source_location = "decision:70"
concept = "linear.decision.ambitions-moat-model"
scope = "linear v3 decision 70; owner-evidence-backed migration topology"
modality = "INFORMATIONAL"
normalized_value = "intent → path → placement → proof → learning → reflow / recovery"
evidence_sha256 = "35b04dff867d144d268db76cff6f4d80804486112248895c0ba5ce49c6254049"
owner_approval = "linear-comment:66dcc614-511a-44b7-8e45-e30a14705c69:decision:70"
owner_evidence_text_sha256 = "e3094e250da55e6c617592b1e0ea0f3f485b9f801b45cf894405f90a19e6db04"
owner_evidence_rationale_sha256 = "946f39e46d6ccd7c77311a0778ff2c6f231d045a966aa9f719ef32dbea185bdf"

[[claims]]
claim_id = "CLAIM-MOM-0005"
source_id = "REPO-B11ED8716F99F213DF6470B4"
source_location = "line:35"
concept = "mission.product.core-loop"
scope = "complete private-life orchestration loop"
modality = "MUST"
normalized_value = "intent -> context -> path -> time fit -> reflow -> action -> proof -> learning"
evidence_sha256 = "648deb2d05fd505929f6b3459b269cafebebc8d66463959e174eecb327dc1601"
owner_approval = "active repo authority"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[claims]]
claim_id = "CLAIM-MOM-0053"
source_id = "LINEAR-CANON-V3"
source_location = "line:51"
concept = "mission.product.core-loop"
scope = "product orchestration loop"
modality = "MUST"
normalized_value = "intent -> path -> placement -> proof -> learning -> reflow / recovery"
evidence_sha256 = "35b04dff867d144d268db76cff6f4d80804486112248895c0ba5ce49c6254049"
owner_approval = "owner-approved Linear v3 source"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[impacts]]
dimension = "repo"
analysis = "Supreme mission, Product Design loop text, scenario catalogs, and future Constitution inheritance are affected."

[[impacts]]
dimension = "linear"
analysis = "Decision 70 and v3 line 51 require replacement-ID mapping after approval."

[[impacts]]
dimension = "figma"
analysis = "Journey frames must show the approved loop and recovery branches without claiming runtime proof."

[[impacts]]
dimension = "production_source"
analysis = "GoalEngine, Planning, Scheduling, runtime, and projection paths are source-present but do not prove the whole loop."

[[impacts]]
dimension = "tests"
analysis = "Later require end-to-end journey, recovery, proof, learning, offline, and interruption/resume tests with current results."

[[impacts]]
dimension = "proof"
analysis = "Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven."

[[impacts]]
dimension = "privacy"
analysis = "Each stage must preserve local/private data classification and prevent unapproved egress."

[[impacts]]
dimension = "accessibility"
analysis = "Every user-visible stage and recovery transition needs an accessible equivalent and announcement."

[[impacts]]
dimension = "migration_rollback"
analysis = "Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag."
+++

# CONFLICT-ORCHESTRATION-LOOP

> Shadow migration decision docket. It is non-authoritative and remains unresolved until the owner records a decision.

## Competing conceptual claims

| Claim | Normalized value | Modality | Scope | Source provenance | Evidence SHA-256 |
| --- | --- | --- | --- | --- | --- |
| `CLAIM-LFT-0070` | intent → path → placement → proof → learning → reflow / recovery | `INFORMATIONAL` | linear v3 decision 70; owner-evidence-backed migration topology | `LINEAR-CANON-V3:decision:70` | `35b04dff867d144d268db76cff6f4d80804486112248895c0ba5ce49c6254049` |
| `CLAIM-MOM-0005` | intent -> context -> path -> time fit -> reflow -> action -> proof -> learning | `MUST` | complete private-life orchestration loop | `REPO-B11ED8716F99F213DF6470B4:line:35` | `648deb2d05fd505929f6b3459b269cafebebc8d66463959e174eecb327dc1601` |
| `CLAIM-MOM-0053` | intent -> path -> placement -> proof -> learning -> reflow / recovery | `MUST` | product orchestration loop | `LINEAR-CANON-V3:line:51` | `35b04dff867d144d268db76cff6f4d80804486112248895c0ba5ce49c6254049` |

## User consequences

Omitting Context, Time Fit, Action, or correctly placed Reflow changes what Ambitions promises and which recovery, proof, and learning behavior Codex implements.

## Compatibility analysis

The shorter Linear loop can coexist only as a labeled summary. Product Design contains a third expanded wording, while current implementation truth does not prove any complete end-to-end loop.

## Recommendation

**Compose A and B with explicit scopes.** Keep the complete orchestration semantics and permit a compact mnemonic only when every omitted stage remains inherited.

This is a recommendation for Gate A, not an owner decision.

## Stronger composition option

Own one full loop and one explicitly non-normative shorthand whose stages map one-to-one to the full loop.

## Proposed canonical law

Ambitions MUST orchestrate Intent through Context, Path, Placement / Time Fit, Reflow / Recovery, Action, Closure / Proof, and Learning; a shorthand MUST NOT remove or reorder required behavior.

## Impact analysis

| Dimension | Impact |
| --- | --- |
| repo | Supreme mission, Product Design loop text, scenario catalogs, and future Constitution inheritance are affected. |
| Linear | Decision 70 and v3 line 51 require replacement-ID mapping after approval. |
| Figma | Journey frames must show the approved loop and recovery branches without claiming runtime proof. |
| production source | GoalEngine, Planning, Scheduling, runtime, and projection paths are source-present but do not prove the whole loop. |
| tests | Later require end-to-end journey, recovery, proof, learning, offline, and interruption/resume tests with current results. |
| proof | Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven. |
| privacy | Each stage must preserve local/private data classification and prevent unapproved egress. |
| accessibility | Every user-visible stage and recovery transition needs an accessible equivalent and announcement. |
| migration / rollback | Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag. |

## Artifacts to supersede

- `LINEAR-CANON-V3:decision:70`
- `LINEAR-CANON-V3:line:51`
- `REPO-B11ED8716F99F213DF6470B4:line:35`

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
