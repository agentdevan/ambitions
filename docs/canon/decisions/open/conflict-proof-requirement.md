+++
schema_version = 1
conflict_id = "CONFLICT-PROOF-REQUIREMENT"
status = "unresolved"
severity = "P0_BLOCKER"
priority = "P0"
concepts = ["linear.decision.proof-and-closure-model", "object.proof.identity-level", "object.proof.requirement-level", "product.proof-and-progress-scenario-gates", "product.proof-types"]
scopes = ["active product and engineering authority migration", "linear v3 decision 87; owner-evidence-backed migration topology", "object.proof"]
recommendation = "compose"
recommendation_rationale = "Retain all three user-proof levels, prohibit surprise gating, and separate them from mandatory system receipts/proof artifacts."
stronger_composition = "Specify requirement origin, visibility timing, waiver/change policy, completion gating, automatic receipt behavior, deletion, and privacy per proof type."
proposed_canonical_law = "User-supplied Proof MAY be optional, suggested, or explicitly required before work begins; required Proof MUST NOT appear as a surprise at completion, and system mutation receipts MUST remain a separate automatic obligation."
artifacts_to_supersede = ["LINEAR-CANON-V3:decision:87", "LINEAR-CANON-V3:line:307", "REPO-43E0D80464B2869224C805D8:line:656", "REPO-AA88FA58EEA6FBA9BAB10270:line:893"]
target_requirement_status = "planned_uncreated"
target_requirement_id = ""
owner_decision = ""
allowed_resolutions = ["keep_a", "keep_b", "compose", "reject_both"]
affected_task_scopes = ["journey.closure", "object.proof"]
nonclaims = "No conflict is resolved; no final Constitution or Atlas law is approved; no source, test, product, runtime, visual, accessibility, privacy, device, CloudKit, TestFlight, App Store, or release Green claim is made."
claim_ceiling = "Task 12 shadow conflict provenance, recommendation, and impact analysis only for the reviewed claims and base SHA; no source-edit or cutover authorization."

[[claims]]
claim_id = "CLAIM-LFT-0087"
source_id = "LINEAR-CANON-V3"
source_location = "decision:87"
concept = "linear.decision.proof-and-closure-model"
scope = "linear v3 decision 87; owner-evidence-backed migration topology"
modality = "MUST"
normalized_value = "proof, source, privacy, history, and receipts are contextual inspection details. every meaningful mutation must produce durable state, visible stage change, accessibility change, safe fallback, and an appropriate proof artifact."
evidence_sha256 = "e24dca82f3389d1cd87b48ef3da8d7765d241d5eb4da814d67e6873e283681d2"
owner_approval = "linear-comment:0f57cc33-fb00-4952-9742-83230faedfca:decision:87"
owner_evidence_text_sha256 = "46f67f321f72675de5ac434cd6a2383607c334a16d2897a8601b9e335a1522de"
owner_evidence_rationale_sha256 = "5032b1c4e0c977e0b37d0c9ac34b8ae5347ea509cfc2d1d4091f67f6ceef294d"

[[claims]]
claim_id = "CLAIM-OBJ-009"
source_id = "LINEAR-CANON-V3"
source_location = "line:307"
concept = "object.proof.identity-level"
scope = "object.proof"
modality = "MAY"
normalized_value = "optional, suggested, or required evidence or reflection linked to step, goal, or closure."
evidence_sha256 = "47170c8a3417689a869133d0b69700914225c1496132aa7ceff55926c80a3ffe"
owner_approval = "owner-approved:linear-v3"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[claims]]
claim_id = "CLAIM-OBJ-034"
source_id = "REPO-43E0D80464B2869224C805D8"
source_location = "line:656"
concept = "object.proof.requirement-level"
scope = "object.proof"
modality = "MAY"
normalized_value = "optional, suggested, or required, with required proof visible before completion."
evidence_sha256 = "292a4881924241e010d55cc8c268b355c91a363333928b5cb40444d76e52c5c3"
owner_approval = "active-repo-authority:PRODUCT_DESIGN_TRUTH.md"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[claims]]
claim_id = "CLAIM-OBJ-055"
source_id = "REPO-AA88FA58EEA6FBA9BAB10270"
source_location = "line:893"
concept = "object.proof.requirement-level"
scope = "object.proof"
modality = "MUST"
normalized_value = "optional but valuable."
evidence_sha256 = "94ab358fc7ee527bfb4fa5aec1e3421876796270396020ea96ec2cf0663663d6"
owner_approval = "active-repo-authority:PRODUCT_EXPERIENCE_CANON.md"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[claims]]
claim_id = "CLAIM-STB-0500"
source_id = "REPO-AA88FA58EEA6FBA9BAB10270"
source_location = "line:2478"
concept = "product.proof-and-progress-scenario-gates"
scope = "active product and engineering authority migration"
modality = "INFORMATIONAL"
normalized_value = "proof_optional_but_attachable"
evidence_sha256 = "2e1bda9194d1ddeb28b4a83a33ebd4d29279b044f6ad5cf632204f13f4fa42ec"
owner_approval = "active-repo-authority:docs/truth/PRODUCT_EXPERIENCE_CANON.md"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[claims]]
claim_id = "CLAIM-STB-0578"
source_id = "REPO-AA88FA58EEA6FBA9BAB10270"
source_location = "line:903"
concept = "product.proof-types"
scope = "active product and engineering authority migration"
modality = "MAY"
normalized_value = "proof may include:"
evidence_sha256 = "4e7e1c487bbca083d060217260676e488cd6efc946bd7e9a708c3a72b63b2fd1"
owner_approval = "active-repo-authority:docs/truth/PRODUCT_EXPERIENCE_CANON.md"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[impacts]]
dimension = "repo"
analysis = "Product Design, Product Experience, proof scenarios, and future object/journey specs need one scoped definition."

[[impacts]]
dimension = "linear"
analysis = "Decision 87 and v3 Proof rows require mapping to separate user-proof and system-proof requirements."

[[impacts]]
dimension = "figma"
analysis = "Completion flows must show requirement timing, satisfied/missing states, alternatives, and contextual inspection."

[[impacts]]
dimension = "production_source"
analysis = "ProofEvent, ProofLedger, MutationProof, and ProofStitchView are source-present candidates without exact current traceability."

[[impacts]]
dimension = "tests"
analysis = "Later verify optional attach, suggested prompt, required absence, no-surprise timing, waiver/change, offline/relaunch, receipt separation, and deletion."

[[impacts]]
dimension = "proof"
analysis = "Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven."

[[impacts]]
dimension = "privacy"
analysis = "Proof media and reflection are sensitive, local, export-controlled, deletable, and redacted from logs and external surfaces."

[[impacts]]
dimension = "accessibility"
analysis = "Requirement state, missing/satisfied status, alternatives, and completion consequences need nonvisual and non-color equivalents."

[[impacts]]
dimension = "migration_rollback"
analysis = "Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag."
+++

# CONFLICT-PROOF-REQUIREMENT

> Shadow migration decision docket. It is non-authoritative and remains unresolved until the owner records a decision.

## Competing conceptual claims

| Claim | Normalized value | Modality | Scope | Source provenance | Evidence SHA-256 |
| --- | --- | --- | --- | --- | --- |
| `CLAIM-LFT-0087` | proof, source, privacy, history, and receipts are contextual inspection details. every meaningful mutation must produce durable state, visible stage change, accessibility change, safe fallback, and an appropriate proof artifact. | `MUST` | linear v3 decision 87; owner-evidence-backed migration topology | `LINEAR-CANON-V3:decision:87` | `e24dca82f3389d1cd87b48ef3da8d7765d241d5eb4da814d67e6873e283681d2` |
| `CLAIM-OBJ-009` | optional, suggested, or required evidence or reflection linked to step, goal, or closure. | `MAY` | object.proof | `LINEAR-CANON-V3:line:307` | `47170c8a3417689a869133d0b69700914225c1496132aa7ceff55926c80a3ffe` |
| `CLAIM-OBJ-034` | optional, suggested, or required, with required proof visible before completion. | `MAY` | object.proof | `REPO-43E0D80464B2869224C805D8:line:656` | `292a4881924241e010d55cc8c268b355c91a363333928b5cb40444d76e52c5c3` |
| `CLAIM-OBJ-055` | optional but valuable. | `MUST` | object.proof | `REPO-AA88FA58EEA6FBA9BAB10270:line:893` | `94ab358fc7ee527bfb4fa5aec1e3421876796270396020ea96ec2cf0663663d6` |
| `CLAIM-STB-0500` | proof_optional_but_attachable | `INFORMATIONAL` | active product and engineering authority migration | `REPO-AA88FA58EEA6FBA9BAB10270:line:2478` | `2e1bda9194d1ddeb28b4a83a33ebd4d29279b044f6ad5cf632204f13f4fa42ec` |
| `CLAIM-STB-0578` | proof may include: | `MAY` | active product and engineering authority migration | `REPO-AA88FA58EEA6FBA9BAB10270:line:903` | `4e7e1c487bbca083d060217260676e488cd6efc946bd7e9a708c3a72b63b2fd1` |

## User consequences

Users may encounter surprise completion blocks, coerced reflection, or missing evidence continuity if user proof and automatic mutation proof are conflated.

## Compatibility analysis

Optional, suggested, owner-configured required user evidence, automatic receipts, and mutation proof are different scopes. Existing proof source and an older Partial scenario do not establish current behavior.

## Recommendation

**Compose A and B with explicit scopes.** Retain all three user-proof levels, prohibit surprise gating, and separate them from mandatory system receipts/proof artifacts.

This is a recommendation for Gate A, not an owner decision.

## Stronger composition option

Specify requirement origin, visibility timing, waiver/change policy, completion gating, automatic receipt behavior, deletion, and privacy per proof type.

## Proposed canonical law

User-supplied Proof MAY be optional, suggested, or explicitly required before work begins; required Proof MUST NOT appear as a surprise at completion, and system mutation receipts MUST remain a separate automatic obligation.

## Impact analysis

| Dimension | Impact |
| --- | --- |
| repo | Product Design, Product Experience, proof scenarios, and future object/journey specs need one scoped definition. |
| Linear | Decision 87 and v3 Proof rows require mapping to separate user-proof and system-proof requirements. |
| Figma | Completion flows must show requirement timing, satisfied/missing states, alternatives, and contextual inspection. |
| production source | ProofEvent, ProofLedger, MutationProof, and ProofStitchView are source-present candidates without exact current traceability. |
| tests | Later verify optional attach, suggested prompt, required absence, no-surprise timing, waiver/change, offline/relaunch, receipt separation, and deletion. |
| proof | Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven. |
| privacy | Proof media and reflection are sensitive, local, export-controlled, deletable, and redacted from logs and external surfaces. |
| accessibility | Requirement state, missing/satisfied status, alternatives, and completion consequences need nonvisual and non-color equivalents. |
| migration / rollback | Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag. |

## Artifacts to supersede

- `LINEAR-CANON-V3:decision:87`
- `LINEAR-CANON-V3:line:307`
- `REPO-43E0D80464B2869224C805D8:line:656`
- `REPO-AA88FA58EEA6FBA9BAB10270:line:893`

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
