+++
schema_version = 1
conflict_id = "CONFLICT-PRIVACY-VISIBILITY"
status = "unresolved"
severity = "P0_BLOCKER"
priority = "P0"
concepts = ["linear.decision.privacy-visibility", "product.trust-005-privacy-seam"]
scopes = ["active product and engineering authority migration", "linear v3 decision 39; owner-evidence-backed migration topology"]
recommendation = "compose"
recommendation_rationale = "Centralize global control and repair in You while requiring quiet contextual disclosure exactly at trust boundaries."
stronger_composition = "Define ownership, status/repair, contextual trigger list, forbidden ambient exposure, degraded fallback, redaction, and route/accessibility law."
proposed_canonical_law = "You MUST own discoverable global privacy controls, status, and repair; privacy explanation MUST appear contextually at permission, egress, legal, and destructive-data boundaries and MUST NOT become ambient sensitive status or root noise."
artifacts_to_supersede = ["LINEAR-CANON-V3:decision:39", "REPO-43E0D80464B2869224C805D8:line:2039"]
target_requirement_status = "planned_uncreated"
target_requirement_id = ""
owner_decision = ""
allowed_resolutions = ["keep_a", "keep_b", "compose", "reject_both"]
affected_task_scopes = ["global.trust", "standard.security-privacy", "surface.you"]
nonclaims = "No conflict is resolved; no final Constitution or Atlas law is approved; no source, test, product, runtime, visual, accessibility, privacy, device, CloudKit, TestFlight, App Store, or release Green claim is made."
claim_ceiling = "Task 12 shadow conflict provenance, recommendation, and impact analysis only for the reviewed claims and base SHA; no source-edit or cutover authorization."

[[claims]]
claim_id = "CLAIM-LFT-0039"
source_id = "LINEAR-CANON-V3"
source_location = "decision:39"
concept = "linear.decision.privacy-visibility"
scope = "linear v3 decision 39; owner-evidence-backed migration topology"
modality = "INFORMATIONAL"
normalized_value = "proof, source, privacy, history, and receipts are contextual inspection details. every meaningful mutation must produce durable state, visible stage change, accessibility change, safe fallback, and an appropriate proof artifact."
evidence_sha256 = "e24dca82f3389d1cd87b48ef3da8d7765d241d5eb4da814d67e6873e283681d2"
owner_approval = "linear-comment:7725eafb-bb05-4d4a-bd2a-65a0163df3fd:decision:39"
owner_evidence_text_sha256 = "b0a0b7aa9521c54146302fea15e297ab7634dc7861ad2f5276615b090d5b2e94"
owner_evidence_rationale_sha256 = "bf462d0116549cdcb7f29869eec887bdbf0ea315c3d3b9c2c29d883c949eb5aa"

[[claims]]
claim_id = "CLAIM-STB-0179"
source_id = "REPO-43E0D80464B2869224C805D8"
source_location = "line:2039"
concept = "product.trust-005-privacy-seam"
scope = "active product and engineering authority migration"
modality = "INFORMATIONAL"
normalized_value = "privacy is quiet by default and explicit at trust boundaries:"
evidence_sha256 = "ce09a71c1aa879ba92a2c335cbdd775afb6f18d05e662e38c56beb99e8c72126"
owner_approval = "active-repo-authority:docs/truth/PRODUCT_DESIGN_TRUTH.md"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[impacts]]
dimension = "repo"
analysis = "You, Trust, privacy, permissions, egress, and destructive-state specs require one visibility model."

[[impacts]]
dimension = "linear"
analysis = "Decision 39 and related Decisions 90-92/172 require replacement mapping; Decision 87 remains in the separate Proof docket."

[[impacts]]
dimension = "figma"
analysis = "Trust, privacy, permission, export/delete, and repair flows need scoped authority and redacted states."

[[impacts]]
dimension = "production_source"
analysis = "You, Trust, Permissions, LocalRuntimeOS privacy/security, and destructive action paths are source-present candidates without exact proof."

[[impacts]]
dimension = "tests"
analysis = "Later require discoverability, contextual triggers, denial fallback, repair, redaction, screenshot/background behavior, export/delete, and no ambient leakage."

[[impacts]]
dimension = "proof"
analysis = "Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven."

[[impacts]]
dimension = "privacy"
analysis = "This docket owns visibility of sensitive privacy state and must minimize disclosure while keeping controls inspectable."

[[impacts]]
dimension = "accessibility"
analysis = "Controls/status/repair and contextual explanations require clear VoiceOver labels, reading order, Dynamic Type, non-color state, and focus recovery."

[[impacts]]
dimension = "migration_rollback"
analysis = "Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag."
+++

# CONFLICT-PRIVACY-VISIBILITY

> Shadow migration decision docket. It is non-authoritative and remains unresolved until the owner records a decision.

## Competing conceptual claims

| Claim | Normalized value | Modality | Scope | Source provenance | Evidence SHA-256 |
| --- | --- | --- | --- | --- | --- |
| `CLAIM-LFT-0039` | proof, source, privacy, history, and receipts are contextual inspection details. every meaningful mutation must produce durable state, visible stage change, accessibility change, safe fallback, and an appropriate proof artifact. | `INFORMATIONAL` | linear v3 decision 39; owner-evidence-backed migration topology | `LINEAR-CANON-V3:decision:39` | `e24dca82f3389d1cd87b48ef3da8d7765d241d5eb4da814d67e6873e283681d2` |
| `CLAIM-STB-0179` | privacy is quiet by default and explicit at trust boundaries: | `INFORMATIONAL` | active product and engineering authority migration | `REPO-43E0D80464B2869224C805D8:line:2039` | `ce09a71c1aa879ba92a2c335cbdd775afb6f18d05e662e38c56beb99e8c72126` |

## User consequences

Privacy controls can become hard to find, ambient badges can expose sensitive status, or permission/destructive moments can lack timely explanation and fallback.

## Compatibility analysis

You can own global privacy controls/status while object inspection and legal, permission, egress, or destructive boundaries show narrowly contextual explanations. Decision 39 and Decision 87 must not be merged because privacy-control placement and proof/completion obligations are distinct.

## Recommendation

**Compose A and B with explicit scopes.** Centralize global control and repair in You while requiring quiet contextual disclosure exactly at trust boundaries.

This is a recommendation for Gate A, not an owner decision.

## Stronger composition option

Define ownership, status/repair, contextual trigger list, forbidden ambient exposure, degraded fallback, redaction, and route/accessibility law.

## Proposed canonical law

You MUST own discoverable global privacy controls, status, and repair; privacy explanation MUST appear contextually at permission, egress, legal, and destructive-data boundaries and MUST NOT become ambient sensitive status or root noise.

## Impact analysis

| Dimension | Impact |
| --- | --- |
| repo | You, Trust, privacy, permissions, egress, and destructive-state specs require one visibility model. |
| Linear | Decision 39 and related Decisions 90-92/172 require replacement mapping; Decision 87 remains in the separate Proof docket. |
| Figma | Trust, privacy, permission, export/delete, and repair flows need scoped authority and redacted states. |
| production source | You, Trust, Permissions, LocalRuntimeOS privacy/security, and destructive action paths are source-present candidates without exact proof. |
| tests | Later require discoverability, contextual triggers, denial fallback, repair, redaction, screenshot/background behavior, export/delete, and no ambient leakage. |
| proof | Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven. |
| privacy | This docket owns visibility of sensitive privacy state and must minimize disclosure while keeping controls inspectable. |
| accessibility | Controls/status/repair and contextual explanations require clear VoiceOver labels, reading order, Dynamic Type, non-color state, and focus recovery. |
| migration / rollback | Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag. |

## Artifacts to supersede

- `LINEAR-CANON-V3:decision:39`
- `REPO-43E0D80464B2869224C805D8:line:2039`

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
