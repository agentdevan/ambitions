+++
schema_version = 1
conflict_id = "CONFLICT-PERSISTENCE-SOURCE-OWNER"
status = "unresolved"
severity = "P0_BLOCKER"
priority = "P0"
concepts = ["persistence.source-owner", "runtime.source-owner"]
scopes = ["canonical private-data persistence source ownership", "new backend/runtime authority"]
recommendation = "keep_b"
recommendation_rationale = "Preserve the binding LocalRuntimeOS owner and treat legacy persistence paths only as migration debt or adapters."
stronger_composition = "Name exact storage, transaction, migration, and adapter owners and require direct-write denial plus removal targets."
proposed_canonical_law = "Canonical private-data mutation and storage authority MUST live under Core/LocalRuntimeOS; Core/Persistence MUST NOT gain new authority and MAY remain only as bounded migration scaffolding with a removal target."
artifacts_to_supersede = ["LINEAR-CANON-V3:line:942", "REPO-504B995D79E2B7561D320F50:line:34"]
target_requirement_status = "planned_uncreated"
target_requirement_id = ""
owner_decision = ""
allowed_resolutions = ["keep_a", "keep_b", "compose", "reject_both"]
affected_task_scopes = ["system.persistence-replay", "system.private-life-runtime"]
nonclaims = "No conflict is resolved; no final Constitution or Atlas law is approved; no source, test, product, runtime, visual, accessibility, privacy, device, CloudKit, TestFlight, App Store, or release Green claim is made."
claim_ceiling = "Task 12 shadow conflict provenance, recommendation, and impact analysis only for the reviewed claims and base SHA; no source-edit or cutover authorization."

[[claims]]
claim_id = "CLAIM-RPPS-0010"
source_id = "LINEAR-CANON-V3"
source_location = "line:942"
concept = "persistence.source-owner"
scope = "canonical private-data persistence source ownership"
modality = "MUST"
normalized_value = "core/persistence"
evidence_sha256 = "8f89bf6eb80c056075b40cedf6cc97f03539bd0b6d9bf5cbca5edc00e07348e2"
owner_approval = "Linear v3 owner metadata and closed Decisions 1-201"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[claims]]
claim_id = "CLAIM-RPPS-0070"
source_id = "REPO-504B995D79E2B7561D320F50"
source_location = "line:34"
concept = "runtime.source-owner"
scope = "new backend/runtime authority"
modality = "MUST"
normalized_value = "core/localruntimeos/"
evidence_sha256 = "dfe3c31ee6df2cd9fd9ec0a962070f0e6ad8898f3107b77cad6c3443bbdf95f7"
owner_approval = "retained active runtime engineering skill"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[impacts]]
dimension = "repo"
analysis = "Final Architecture Tree, AGENTS remediation law, Article 25, source maps, and v3 path wording require reconciliation."

[[impacts]]
dimension = "linear"
analysis = "V3 line 942 must be superseded by an exact owner requirement."

[[impacts]]
dimension = "figma"
analysis = "No visual authority effect beyond truthful failure/recovery presentation."

[[impacts]]
dimension = "production_source"
analysis = "LocalRuntimeOS/Storage owns migrated object storage while Core/Persistence still exists; Task 12 moves no source."

[[impacts]]
dimension = "tests"
analysis = "Later require storage ownership, direct-write audit, adapter routing, transaction, migration, corruption, backup/restore, and old-owner-removal tests."

[[impacts]]
dimension = "proof"
analysis = "Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven."

[[impacts]]
dimension = "privacy"
analysis = "Storage ownership includes file protection, backup/export/delete classification, diagnostics redaction, and no hosted egress."

[[impacts]]
dimension = "accessibility"
analysis = "Any exposed migration/failure/recovery state must be understandable and operable, though source ownership itself is nonvisual."

[[impacts]]
dimension = "migration_rollback"
analysis = "Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag."
+++

# CONFLICT-PERSISTENCE-SOURCE-OWNER

> Shadow migration decision docket. It is non-authoritative and remains unresolved until the owner records a decision.

## Competing conceptual claims

| Claim | Normalized value | Modality | Scope | Source provenance | Evidence SHA-256 |
| --- | --- | --- | --- | --- | --- |
| `CLAIM-RPPS-0010` | core/persistence | `MUST` | canonical private-data persistence source ownership | `LINEAR-CANON-V3:line:942` | `8f89bf6eb80c056075b40cedf6cc97f03539bd0b6d9bf5cbca5edc00e07348e2` |
| `CLAIM-RPPS-0070` | core/localruntimeos/ | `MUST` | new backend/runtime authority | `REPO-504B995D79E2B7561D320F50:line:34` | `dfe3c31ee6df2cd9fd9ec0a962070f0e6ad8898f3107b77cad6c3443bbdf95f7` |

## User consequences

Codex can add canonical writes to legacy Core/Persistence and split mutation/storage authority from LocalRuntimeOS.

## Compatibility analysis

Core/Persistence may remain compatibility scaffolding, but path presence is not normative ownership. The Final Architecture Tree assigns new storage/mutation authority to Core/LocalRuntimeOS.

## Recommendation

**Keep B; supersede A.** Preserve the binding LocalRuntimeOS owner and treat legacy persistence paths only as migration debt or adapters.

This is a recommendation for Gate A, not an owner decision.

## Stronger composition option

Name exact storage, transaction, migration, and adapter owners and require direct-write denial plus removal targets.

## Proposed canonical law

Canonical private-data mutation and storage authority MUST live under Core/LocalRuntimeOS; Core/Persistence MUST NOT gain new authority and MAY remain only as bounded migration scaffolding with a removal target.

## Impact analysis

| Dimension | Impact |
| --- | --- |
| repo | Final Architecture Tree, AGENTS remediation law, Article 25, source maps, and v3 path wording require reconciliation. |
| Linear | V3 line 942 must be superseded by an exact owner requirement. |
| Figma | No visual authority effect beyond truthful failure/recovery presentation. |
| production source | LocalRuntimeOS/Storage owns migrated object storage while Core/Persistence still exists; Task 12 moves no source. |
| tests | Later require storage ownership, direct-write audit, adapter routing, transaction, migration, corruption, backup/restore, and old-owner-removal tests. |
| proof | Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven. |
| privacy | Storage ownership includes file protection, backup/export/delete classification, diagnostics redaction, and no hosted egress. |
| accessibility | Any exposed migration/failure/recovery state must be understandable and operable, though source ownership itself is nonvisual. |
| migration / rollback | Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag. |

## Artifacts to supersede

- `LINEAR-CANON-V3:line:942`
- `REPO-504B995D79E2B7561D320F50:line:34`

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
