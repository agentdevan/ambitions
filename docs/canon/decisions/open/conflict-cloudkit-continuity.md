+++
schema_version = 1
conflict_id = "CONFLICT-CLOUDKIT-CONTINUITY"
status = "unresolved"
severity = "P0_BLOCKER"
priority = "P0"
concepts = ["linear.decision.cloudkit-account-role", "linear.decision.sync-and-account-boundary", "moat.account.private-graph-boundary", "privacy.data-class.private-graph", "runtime.local-first.account-sync-boundary", "sync.cloudkit.article-scope", "sync.cloudkit.conflict", "sync.cloudkit.environment", "sync.cloudkit.exception", "sync.cloudkit.local-authority", "sync.cloudkit.private-graph-continuity", "sync.cloudkit.record-identity", "sync.cloudkit.restore-interaction", "sync.cloudkit.retry-failure", "sync.user-owned.approval-state"]
scopes = ["ambitions account hosted storage", "cloudkit continuity", "cloudkit environments and schema deployment", "cloudkit merge conflicts", "cloudkit private continuity", "cloudkit record schema and privacy", "cloudkit sync failure and lifecycle", "core product behavior and private-graph continuity", "linear v3 decision 38; owner-evidence-backed migration topology", "linear v3 decision 93; owner-evidence-backed migration topology", "private graph egress and continuity", "private life graph", "private-graph continuity", "private-graph data classification", "restore with active cloudkit sync", "user-owned private-data sync"]
recommendation = "compose"
recommendation_rationale = "Keep local authority and Account/R2 prohibition, approve CloudKit only as explicit user-owned optional continuity behind a complete privacy/sync contract and proof gate."
stronger_composition = "Separate intended eligibility from current implementation posture and require data-class, consent, conflict, tombstone, restore, sign-out, old-client, environment, and rollback law before enablement."
proposed_canonical_law = "Ambitions MUST remain fully usable locally without an account or network; Ambitions Account and R2 MUST NOT store the private graph, and user-owned CloudKit continuity MUST remain disabled until its explicit privacy, conflict, recovery, migration, and proof requirements are approved and satisfied."
artifacts_to_supersede = ["LINEAR-CANON-V3:decision:38", "LINEAR-CANON-V3:decision:93", "LINEAR-CANON-V3:line:133", "REPO-24AE31A618868443E87AFB86:line:249", "REPO-30F82AEBB440C03C0671AE4A", "REPO-AA88FA58EEA6FBA9BAB10270:line:1819"]
target_requirement_status = "planned_uncreated"
target_requirement_id = ""
owner_decision = ""
allowed_resolutions = ["keep_a", "keep_b", "compose", "reject_both"]
affected_task_scopes = ["system.privacy", "system.sync"]
nonclaims = "No conflict is resolved; no final Constitution or Atlas law is approved; no source, test, product, runtime, visual, accessibility, privacy, device, CloudKit, TestFlight, App Store, or release Green claim is made."
claim_ceiling = "Task 12 shadow conflict provenance, recommendation, and impact analysis only for the reviewed claims and base SHA; no source-edit or cutover authorization."

[[claims]]
claim_id = "CLAIM-LFT-0038"
source_id = "LINEAR-CANON-V3"
source_location = "decision:38"
concept = "linear.decision.cloudkit-account-role"
scope = "linear v3 decision 38; owner-evidence-backed migration topology"
modality = "INFORMATIONAL"
normalized_value = "today, goals, time, capture, search, proof, receipts, recovery, and local adaptation work without sign-in and without network access. full private-graph sync uses cloudkit / icloud when enabled. ambitions account is optional and does not store the private life graph. r2 / source atlas is public/reference/freshness infrastructure only."
evidence_sha256 = "b6b1a931da56f7668956dee531ec6c542d3aba8bf35391503676102e4260a2ea"
owner_approval = "linear-comment:7725eafb-bb05-4d4a-bd2a-65a0163df3fd:decision:38"
owner_evidence_text_sha256 = "25d749d6195935622548e94f0a7d66a9c20be7df2304fc9e1edf7b58db3b99e9"
owner_evidence_rationale_sha256 = "7793aaa58186cedf4d92156c8dbcdb954af27baa0e2c493c5af632dfff81e0f8"

[[claims]]
claim_id = "CLAIM-LFT-0093"
source_id = "LINEAR-CANON-V3"
source_location = "decision:93"
concept = "linear.decision.sync-and-account-boundary"
scope = "linear v3 decision 93; owner-evidence-backed migration topology"
modality = "INFORMATIONAL"
normalized_value = "today, goals, time, capture, search, proof, receipts, recovery, and local adaptation work without sign-in and without network access. full private-graph sync uses cloudkit / icloud when enabled. ambitions account is optional and does not store the private life graph. r2 / source atlas is public/reference/freshness infrastructure only."
evidence_sha256 = "b6b1a931da56f7668956dee531ec6c542d3aba8bf35391503676102e4260a2ea"
owner_approval = "linear-comment:6666ad60-68b1-4a65-960b-33591e6fa094:decision:93"
owner_evidence_text_sha256 = "21479315ff93016d5d0f229f9666d1f1da37f5c55fbbb2663f88eff70b4cc1db"
owner_evidence_rationale_sha256 = "1ca614dd6acccec9aedf03808557064e725189bbb2410fa243fd0f734a214141"

[[claims]]
claim_id = "CLAIM-MOM-0043"
source_id = "REPO-24AE31A618868443E87AFB86"
source_location = "line:249"
concept = "moat.account.private-graph-boundary"
scope = "ambitions account hosted storage"
modality = "MUST NOT"
normalized_value = "the private life graph"
evidence_sha256 = "2222e19a0f122f61eb46b4dccb3dc7ee6dc9e0973c899964fae4aab5548069b1"
owner_approval = "active repo authority"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[claims]]
claim_id = "CLAIM-RPPS-0001"
source_id = "LINEAR-CANON-V3"
source_location = "line:133"
concept = "runtime.local-first.account-sync-boundary"
scope = "core product behavior and private-graph continuity"
modality = "MUST"
normalized_value = "offline and no-account core; optional user-owned cloudkit private-graph continuity; no ambitions account or r2 private-graph ownership."
evidence_sha256 = "b6b1a931da56f7668956dee531ec6c542d3aba8bf35391503676102e4260a2ea"
owner_approval = "Linear v3 owner metadata and closed Decisions 1-201"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[claims]]
claim_id = "CLAIM-RPPS-0014"
source_id = "LINEAR-CANON-V3"
source_location = "line:949"
concept = "sync.cloudkit.private-graph-continuity"
scope = "private-graph continuity"
modality = "MAY"
normalized_value = "optional user-owned private-graph continuity"
evidence_sha256 = "6120ff2717bbdac91e40d6788a964593624a1db1d558e0a2d13f16bfd4991a3d"
owner_approval = "Linear v3 owner metadata and closed Decisions 1-201"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[claims]]
claim_id = "CLAIM-RPPS-0017"
source_id = "LINEAR-CANON-V3"
source_location = "line:958"
concept = "privacy.data-class.private-graph"
scope = "private-graph data classification"
modality = "MUST"
normalized_value = "local only by default, with optional user-private cloudkit"
evidence_sha256 = "bb6b2a0618aea09460d5d0d0c5945a38b855f0bac66892cf983bcf1e51b978fd"
owner_approval = "Linear v3 owner metadata and closed Decisions 1-201"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[claims]]
claim_id = "CLAIM-RPPS-0018"
source_id = "LINEAR-CANON-V3"
source_location = "line:977"
concept = "sync.cloudkit.exception"
scope = "private graph egress and continuity"
modality = "MAY"
normalized_value = "explicit user-owned private-graph continuity through icloud"
evidence_sha256 = "733c75e5def607e7042c49072c92f52adab8996e1beeedc02eba9edc8355e126"
owner_approval = "Linear v3 owner metadata and closed Decisions 1-201"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[claims]]
claim_id = "CLAIM-RPPS-0050"
source_id = "REPO-30F82AEBB440C03C0671AE4A"
source_location = "line:1"
concept = "sync.cloudkit.article-scope"
scope = "cloudkit private continuity"
modality = "INFORMATIONAL"
normalized_value = "active cloudkit continuity requirements"
evidence_sha256 = "84857b0f1e9b5e3e93eb44eefbc34b330bee38b74026326fd60d4aa84cda0607"
owner_approval = "active tracked constitution authority"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[claims]]
claim_id = "CLAIM-RPPS-0051"
source_id = "REPO-30F82AEBB440C03C0671AE4A"
source_location = "line:5"
concept = "sync.cloudkit.local-authority"
scope = "cloudkit continuity"
modality = "MUST NOT"
normalized_value = "the only readable copy, a local-core gate, or canonical command authority"
evidence_sha256 = "1f16221ae169dbdfa525ab3120dd24f6d6f1ff17df5a1db64fae70c559dcc650"
owner_approval = "active tracked constitution authority"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[claims]]
claim_id = "CLAIM-RPPS-0052"
source_id = "REPO-30F82AEBB440C03C0671AE4A"
source_location = "line:9"
concept = "sync.cloudkit.record-identity"
scope = "cloudkit record schema and privacy"
modality = "MUST"
normalized_value = "canonical identity, versions, causality, tombstones, attachments, and user-private container boundary"
evidence_sha256 = "c1759894fc77ec18bf84eb462d6a781a2c558b7fef36a5c14a4ec4eae2333c3e"
owner_approval = "active tracked constitution authority"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[claims]]
claim_id = "CLAIM-RPPS-0053"
source_id = "REPO-30F82AEBB440C03C0671AE4A"
source_location = "line:13"
concept = "sync.cloudkit.conflict"
scope = "cloudkit merge conflicts"
modality = "MUST NOT"
normalized_value = "silent last-write-wins data loss"
evidence_sha256 = "0c7d2837a957466a1a753bc1ce6c02b1337f0f5f75f3c387f38b13c788988ae6"
owner_approval = "active tracked constitution authority"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[claims]]
claim_id = "CLAIM-RPPS-0054"
source_id = "REPO-30F82AEBB440C03C0671AE4A"
source_location = "line:17"
concept = "sync.cloudkit.retry-failure"
scope = "cloudkit sync failure and lifecycle"
modality = "MUST"
normalized_value = "retry, batching, quotas, token expiry, partial failure, network/icloud/account changes, old clients, and device removal"
evidence_sha256 = "2c6a8326368342d6a54ee82fe6001df386dd20e1c9a471b7463496d7933cd7fe"
owner_approval = "active tracked constitution authority"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[claims]]
claim_id = "CLAIM-RPPS-0055"
source_id = "REPO-30F82AEBB440C03C0671AE4A"
source_location = "line:21"
concept = "sync.cloudkit.environment"
scope = "cloudkit environments and schema deployment"
modality = "MUST"
normalized_value = "environment separation and reviewed production migration/rollback"
evidence_sha256 = "a08243fe8ccbe0009d94a09d7bf5e2d3bb9c1bbf6a36edf241d687acd205eb30"
owner_approval = "active tracked constitution authority"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[claims]]
claim_id = "CLAIM-RPPS-0056"
source_id = "REPO-30F82AEBB440C03C0671AE4A"
source_location = "line:25"
concept = "sync.cloudkit.restore-interaction"
scope = "restore with active cloudkit sync"
modality = "MUST"
normalized_value = "duplicate prevention, causal reset, transfer precedence, and consequence review"
evidence_sha256 = "648b8148e6c8c61a95dbba7bfcd26c744dc4794e4ef2876c5713e3614c5666b0"
owner_approval = "active tracked constitution authority"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[claims]]
claim_id = "CLAIM-RPPS-0058"
source_id = "REPO-110D0BFC2660AF72E0673BBF"
source_location = "document"
concept = "privacy.data-class.private-graph"
scope = "private life graph"
modality = "MUST"
normalized_value = "local storage or user-private cloudkit only; never public reference, account storage, or default logs"
evidence_sha256 = "32ca5bee34c7f81f430c3e624971dd3902f2ff96c9d5eeeffddc826218f18823"
owner_approval = "active tracked constitution authority"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[claims]]
claim_id = "CLAIM-RPPS-0065"
source_id = "REPO-43E0D80464B2869224C805D8"
source_location = "line:2084"
concept = "sync.cloudkit.private-graph-continuity"
scope = "private-graph continuity"
modality = "MAY"
normalized_value = "optional continuity preserving local authority, offline core, explicit state, deterministic conflict review, no silent loss, and local-data-retaining sign-out"
evidence_sha256 = "5ddbc78791ec57909e6b0eed4bcd5dbd9a22362b385bc4f55aa4288f8ac63b4a"
owner_approval = "active highest-order product design canon"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[claims]]
claim_id = "CLAIM-RPPS-0067"
source_id = "REPO-AA88FA58EEA6FBA9BAB10270"
source_location = "line:1727"
concept = "sync.user-owned.approval-state"
scope = "user-owned private-data sync"
modality = "MAY"
normalized_value = "future expansion only when separately approved"
evidence_sha256 = "a281aa717553e1cda25a1242c3177254ba1670c3978bc79afe3d52638309d277"
owner_approval = "active product experience canon"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[claims]]
claim_id = "CLAIM-RPPS-0068"
source_id = "REPO-AA88FA58EEA6FBA9BAB10270"
source_location = "line:1819"
concept = "sync.user-owned.approval-state"
scope = "user-owned private-data sync"
modality = "MAY"
normalized_value = "future expansion requiring separate privacy/sync canon"
evidence_sha256 = "c54ce8564959d6c8ec3aa37787140ae8b4b65061871b576be48e2bb3869d8890"
owner_approval = "active product experience canon"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[impacts]]
dimension = "repo"
analysis = "Product Design/Experience/Moat, Article 34, data classification, implementation truth, and future sync specs require scoped reconciliation."

[[impacts]]
dimension = "linear"
analysis = "Decisions 38 and 93 plus v3 sync clauses must distinguish target law from current posture."

[[impacts]]
dimension = "figma"
analysis = "Sync/account/conflict UI authority must show consent, status, repair, conflict review, and accessibility variants without implying implementation."

[[impacts]]
dimension = "production_source"
analysis = "CloudKitContinuityClient exists, while SyncEnvelope and authority gates deny private graph payloads; no Task 12 source or schema change is allowed."

[[impacts]]
dimension = "tests"
analysis = "Later require transport, classification, conflict/quarantine, tombstone, retry/quota, restore, sign-out, old-client, device/network fault, and migration tests."

[[impacts]]
dimension = "proof"
analysis = "Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven."

[[impacts]]
dimension = "privacy"
analysis = "This is a private-data egress P0 requiring explicit user ownership, minimization, encryption/container review, no Account/R2 ownership, and legal/privacy review."

[[impacts]]
dimension = "accessibility"
analysis = "Consent, status, conflict, repair, sign-out, and restore consequences need VoiceOver, Dynamic Type, Reduce Motion, and non-color equivalents."

[[impacts]]
dimension = "migration_rollback"
analysis = "Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag."
+++

# CONFLICT-CLOUDKIT-CONTINUITY

> Shadow migration decision docket. It is non-authoritative and remains unresolved until the owner records a decision.

## Competing conceptual claims

| Claim | Normalized value | Modality | Scope | Source provenance | Evidence SHA-256 |
| --- | --- | --- | --- | --- | --- |
| `CLAIM-LFT-0038` | today, goals, time, capture, search, proof, receipts, recovery, and local adaptation work without sign-in and without network access. full private-graph sync uses cloudkit / icloud when enabled. ambitions account is optional and does not store the private life graph. r2 / source atlas is public/reference/freshness infrastructure only. | `INFORMATIONAL` | linear v3 decision 38; owner-evidence-backed migration topology | `LINEAR-CANON-V3:decision:38` | `b6b1a931da56f7668956dee531ec6c542d3aba8bf35391503676102e4260a2ea` |
| `CLAIM-LFT-0093` | today, goals, time, capture, search, proof, receipts, recovery, and local adaptation work without sign-in and without network access. full private-graph sync uses cloudkit / icloud when enabled. ambitions account is optional and does not store the private life graph. r2 / source atlas is public/reference/freshness infrastructure only. | `INFORMATIONAL` | linear v3 decision 93; owner-evidence-backed migration topology | `LINEAR-CANON-V3:decision:93` | `b6b1a931da56f7668956dee531ec6c542d3aba8bf35391503676102e4260a2ea` |
| `CLAIM-MOM-0043` | the private life graph | `MUST NOT` | ambitions account hosted storage | `REPO-24AE31A618868443E87AFB86:line:249` | `2222e19a0f122f61eb46b4dccb3dc7ee6dc9e0973c899964fae4aab5548069b1` |
| `CLAIM-RPPS-0001` | offline and no-account core; optional user-owned cloudkit private-graph continuity; no ambitions account or r2 private-graph ownership. | `MUST` | core product behavior and private-graph continuity | `LINEAR-CANON-V3:line:133` | `b6b1a931da56f7668956dee531ec6c542d3aba8bf35391503676102e4260a2ea` |
| `CLAIM-RPPS-0014` | optional user-owned private-graph continuity | `MAY` | private-graph continuity | `LINEAR-CANON-V3:line:949` | `6120ff2717bbdac91e40d6788a964593624a1db1d558e0a2d13f16bfd4991a3d` |
| `CLAIM-RPPS-0017` | local only by default, with optional user-private cloudkit | `MUST` | private-graph data classification | `LINEAR-CANON-V3:line:958` | `bb6b2a0618aea09460d5d0d0c5945a38b855f0bac66892cf983bcf1e51b978fd` |
| `CLAIM-RPPS-0018` | explicit user-owned private-graph continuity through icloud | `MAY` | private graph egress and continuity | `LINEAR-CANON-V3:line:977` | `733c75e5def607e7042c49072c92f52adab8996e1beeedc02eba9edc8355e126` |
| `CLAIM-RPPS-0050` | active cloudkit continuity requirements | `INFORMATIONAL` | cloudkit private continuity | `REPO-30F82AEBB440C03C0671AE4A:line:1` | `84857b0f1e9b5e3e93eb44eefbc34b330bee38b74026326fd60d4aa84cda0607` |
| `CLAIM-RPPS-0051` | the only readable copy, a local-core gate, or canonical command authority | `MUST NOT` | cloudkit continuity | `REPO-30F82AEBB440C03C0671AE4A:line:5` | `1f16221ae169dbdfa525ab3120dd24f6d6f1ff17df5a1db64fae70c559dcc650` |
| `CLAIM-RPPS-0052` | canonical identity, versions, causality, tombstones, attachments, and user-private container boundary | `MUST` | cloudkit record schema and privacy | `REPO-30F82AEBB440C03C0671AE4A:line:9` | `c1759894fc77ec18bf84eb462d6a781a2c558b7fef36a5c14a4ec4eae2333c3e` |
| `CLAIM-RPPS-0053` | silent last-write-wins data loss | `MUST NOT` | cloudkit merge conflicts | `REPO-30F82AEBB440C03C0671AE4A:line:13` | `0c7d2837a957466a1a753bc1ce6c02b1337f0f5f75f3c387f38b13c788988ae6` |
| `CLAIM-RPPS-0054` | retry, batching, quotas, token expiry, partial failure, network/icloud/account changes, old clients, and device removal | `MUST` | cloudkit sync failure and lifecycle | `REPO-30F82AEBB440C03C0671AE4A:line:17` | `2c6a8326368342d6a54ee82fe6001df386dd20e1c9a471b7463496d7933cd7fe` |
| `CLAIM-RPPS-0055` | environment separation and reviewed production migration/rollback | `MUST` | cloudkit environments and schema deployment | `REPO-30F82AEBB440C03C0671AE4A:line:21` | `a08243fe8ccbe0009d94a09d7bf5e2d3bb9c1bbf6a36edf241d687acd205eb30` |
| `CLAIM-RPPS-0056` | duplicate prevention, causal reset, transfer precedence, and consequence review | `MUST` | restore with active cloudkit sync | `REPO-30F82AEBB440C03C0671AE4A:line:25` | `648b8148e6c8c61a95dbba7bfcd26c744dc4794e4ef2876c5713e3614c5666b0` |
| `CLAIM-RPPS-0058` | local storage or user-private cloudkit only; never public reference, account storage, or default logs | `MUST` | private life graph | `REPO-110D0BFC2660AF72E0673BBF:document` | `32ca5bee34c7f81f430c3e624971dd3902f2ff96c9d5eeeffddc826218f18823` |
| `CLAIM-RPPS-0065` | optional continuity preserving local authority, offline core, explicit state, deterministic conflict review, no silent loss, and local-data-retaining sign-out | `MAY` | private-graph continuity | `REPO-43E0D80464B2869224C805D8:line:2084` | `5ddbc78791ec57909e6b0eed4bcd5dbd9a22362b385bc4f55aa4288f8ac63b4a` |
| `CLAIM-RPPS-0067` | future expansion only when separately approved | `MAY` | user-owned private-data sync | `REPO-AA88FA58EEA6FBA9BAB10270:line:1727` | `a281aa717553e1cda25a1242c3177254ba1670c3978bc79afe3d52638309d277` |
| `CLAIM-RPPS-0068` | future expansion requiring separate privacy/sync canon | `MAY` | user-owned private-data sync | `REPO-AA88FA58EEA6FBA9BAB10270:line:1819` | `c54ce8564959d6c8ec3aa37787140ae8b4b65061871b576be48e2bb3869d8890` |

## User consequences

Private graph data could move without approved consent/recovery law, or multi-device continuity could be promised while current source deliberately denies private-graph payloads.

## Compatibility analysis

Offline/no-account core, Account/R2 prohibition, and optional Apple-user-owned continuity are compatible scopes. Approval state is not: Product Experience says future separate approval while v3/Article 34 state active intent. Live source allows metadata envelopes but denies private graph payloads, a third implementation posture.

## Recommendation

**Compose A and B with explicit scopes.** Keep local authority and Account/R2 prohibition, approve CloudKit only as explicit user-owned optional continuity behind a complete privacy/sync contract and proof gate.

This is a recommendation for Gate A, not an owner decision.

## Stronger composition option

Separate intended eligibility from current implementation posture and require data-class, consent, conflict, tombstone, restore, sign-out, old-client, environment, and rollback law before enablement.

## Proposed canonical law

Ambitions MUST remain fully usable locally without an account or network; Ambitions Account and R2 MUST NOT store the private graph, and user-owned CloudKit continuity MUST remain disabled until its explicit privacy, conflict, recovery, migration, and proof requirements are approved and satisfied.

## Impact analysis

| Dimension | Impact |
| --- | --- |
| repo | Product Design/Experience/Moat, Article 34, data classification, implementation truth, and future sync specs require scoped reconciliation. |
| Linear | Decisions 38 and 93 plus v3 sync clauses must distinguish target law from current posture. |
| Figma | Sync/account/conflict UI authority must show consent, status, repair, conflict review, and accessibility variants without implying implementation. |
| production source | CloudKitContinuityClient exists, while SyncEnvelope and authority gates deny private graph payloads; no Task 12 source or schema change is allowed. |
| tests | Later require transport, classification, conflict/quarantine, tombstone, retry/quota, restore, sign-out, old-client, device/network fault, and migration tests. |
| proof | Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven. |
| privacy | This is a private-data egress P0 requiring explicit user ownership, minimization, encryption/container review, no Account/R2 ownership, and legal/privacy review. |
| accessibility | Consent, status, conflict, repair, sign-out, and restore consequences need VoiceOver, Dynamic Type, Reduce Motion, and non-color equivalents. |
| migration / rollback | Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag. |

## Artifacts to supersede

- `LINEAR-CANON-V3:decision:38`
- `LINEAR-CANON-V3:decision:93`
- `LINEAR-CANON-V3:line:133`
- `REPO-24AE31A618868443E87AFB86:line:249`
- `REPO-30F82AEBB440C03C0671AE4A`
- `REPO-AA88FA58EEA6FBA9BAB10270:line:1819`

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
