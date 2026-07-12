+++
schema_version = 1
conflict_id = "CONFLICT-SAVED-FOR-LATER"
status = "unresolved"
severity = "P0_BLOCKER"
priority = "P0"
concepts = ["linear.decision.save-for-later", "linear.decision.saved-for-later-ownership"]
scopes = ["linear v3 decision 181; owner-evidence-backed migration topology", "linear v3 decision 41; owner-evidence-backed migration topology"]
recommendation = "compose"
recommendation_rationale = "Keep Saved for Later as a durable state/object contract, forbid root destination identity, and define intentional reachability and promotion."
stronger_composition = "Specify ownership, save/reopen/promote/reject/archive/Trash/restore lifecycle, routes, source/history, offline/relaunch, and compatibility naming."
proposed_canonical_law = "Saved for Later MUST be a durable, locally recoverable unresolved-input state with explicit reachability and promotion; it MUST NOT become a root Inbox, Today clutter, notes feed, or generic backlog."
artifacts_to_supersede = ["LINEAR-CANON-V3:decision:181", "LINEAR-CANON-V3:decision:41"]
target_requirement_status = "planned_uncreated"
target_requirement_id = ""
owner_decision = ""
allowed_resolutions = ["keep_a", "keep_b", "compose", "reject_both"]
affected_task_scopes = ["global.capture", "object.saved-for-later-draft"]
nonclaims = "No conflict is resolved; no final Constitution or Atlas law is approved; no source, test, product, runtime, visual, accessibility, privacy, device, CloudKit, TestFlight, App Store, or release Green claim is made."
claim_ceiling = "Task 12 shadow conflict provenance, recommendation, and impact analysis only for the reviewed claims and base SHA; no source-edit or cutover authorization."

[[claims]]
claim_id = "CLAIM-LFT-0041"
source_id = "LINEAR-CANON-V3"
source_location = "decision:41"
concept = "linear.decision.saved-for-later-ownership"
scope = "linear v3 decision 41; owner-evidence-backed migration topology"
modality = "INFORMATIONAL"
normalized_value = "| saved for later | review uncommitted input | what should i do with this later? | promote | durable saved inputs | source/history | root inbox / today clutter |"
evidence_sha256 = "5ec0fe9158ba50ab27e0826f823d6962593ff3485c90b1950363d900b0a6c5fc"
owner_approval = "linear-comment:7725eafb-bb05-4d4a-bd2a-65a0163df3fd:decision:41"
owner_evidence_text_sha256 = "d90d7b68dd97ab534b5e2c9d43cb7f2b314b576db07260d2cf935b0101ea0552"
owner_evidence_rationale_sha256 = "22b3265c76ec1b22feaada3606a714860eb76048612e00cbe72d3b96c0a656d7"

[[claims]]
claim_id = "CLAIM-LFT-0181"
source_id = "LINEAR-CANON-V3"
source_location = "decision:181"
concept = "linear.decision.save-for-later"
scope = "linear v3 decision 181; owner-evidence-backed migration topology"
modality = "INFORMATIONAL"
normalized_value = "4. later, user opens the inbox from capture/search/you."
evidence_sha256 = "bedfba8ecb7170a81a1aef6f8bc0d16d08e63f2ce1c7649f5694b054caf28b75"
owner_approval = "linear-comment:164ce20b-85a8-45a8-bbd2-db4b8505a2dc:decision:181"
owner_evidence_text_sha256 = "34d49cc3d07a07d1368517eec28bebb260727535f3cf511a03e5ebecf9621d6d"
owner_evidence_rationale_sha256 = "595cb7e8374e4e94818a1d29e1641e83c4f737a623e6d312a06d17380e64f9e9"

[[impacts]]
dimension = "repo"
analysis = "Capture, Search, You, object/lifecycle, and copy truth require one owner."

[[impacts]]
dimension = "linear"
analysis = "Decisions 41 and 181 require scope-specific replacement mapping."

[[impacts]]
dimension = "figma"
analysis = "Capture flows must show save confirmation, later reachability, promotion, rejection/archive, and accessibility states without a fifth root."

[[impacts]]
dimension = "production_source"
analysis = "CaptureRoute.captureInbox and Open Field item are source-present compatibility posture, not approved user-facing ownership."

[[impacts]]
dimension = "tests"
analysis = "Later require save, relaunch, direct lookup, reopen, promote, archive/reject, Trash/restore, source/history, offline, and route tests."

[[impacts]]
dimension = "proof"
analysis = "Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven."

[[impacts]]
dimension = "privacy"
analysis = "Raw unresolved capture content and attachments remain local, redacted from logs/external surfaces, and covered by delete/export law."

[[impacts]]
dimension = "accessibility"
analysis = "Save confirmation, route names, state, actions, recovery, and promotion consequences need clear labels and focus behavior."

[[impacts]]
dimension = "migration_rollback"
analysis = "Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag."
+++

# CONFLICT-SAVED-FOR-LATER

> Shadow migration decision docket. It is non-authoritative and remains unresolved until the owner records a decision.

## Competing conceptual claims

| Claim | Normalized value | Modality | Scope | Source provenance | Evidence SHA-256 |
| --- | --- | --- | --- | --- | --- |
| `CLAIM-LFT-0041` | &#124; saved for later &#124; review uncommitted input &#124; what should i do with this later? &#124; promote &#124; durable saved inputs &#124; source/history &#124; root inbox / today clutter &#124; | `INFORMATIONAL` | linear v3 decision 41; owner-evidence-backed migration topology | `LINEAR-CANON-V3:decision:41` | `5ec0fe9158ba50ab27e0826f823d6962593ff3485c90b1950363d900b0a6c5fc` |
| `CLAIM-LFT-0181` | 4. later, user opens the inbox from capture/search/you. | `INFORMATIONAL` | linear v3 decision 181; owner-evidence-backed migration topology | `LINEAR-CANON-V3:decision:181` | `bedfba8ecb7170a81a1aef6f8bc0d16d08e63f2ce1c7649f5694b054caf28b75` |

## User consequences

A forbidden root inbox can emerge, unresolved drafts can become unreachable, or Capture can degrade into a notes/backlog feed.

## Compatibility analysis

Capture may create/confirm the durable unresolved state while Search and You expose filtered reachability; an internal capture_inbox compatibility route does not establish a user-facing Inbox destination.

## Recommendation

**Compose A and B with explicit scopes.** Keep Saved for Later as a durable state/object contract, forbid root destination identity, and define intentional reachability and promotion.

This is a recommendation for Gate A, not an owner decision.

## Stronger composition option

Specify ownership, save/reopen/promote/reject/archive/Trash/restore lifecycle, routes, source/history, offline/relaunch, and compatibility naming.

## Proposed canonical law

Saved for Later MUST be a durable, locally recoverable unresolved-input state with explicit reachability and promotion; it MUST NOT become a root Inbox, Today clutter, notes feed, or generic backlog.

## Impact analysis

| Dimension | Impact |
| --- | --- |
| repo | Capture, Search, You, object/lifecycle, and copy truth require one owner. |
| Linear | Decisions 41 and 181 require scope-specific replacement mapping. |
| Figma | Capture flows must show save confirmation, later reachability, promotion, rejection/archive, and accessibility states without a fifth root. |
| production source | CaptureRoute.captureInbox and Open Field item are source-present compatibility posture, not approved user-facing ownership. |
| tests | Later require save, relaunch, direct lookup, reopen, promote, archive/reject, Trash/restore, source/history, offline, and route tests. |
| proof | Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven. |
| privacy | Raw unresolved capture content and attachments remain local, redacted from logs/external surfaces, and covered by delete/export law. |
| accessibility | Save confirmation, route names, state, actions, recovery, and promotion consequences need clear labels and focus behavior. |
| migration / rollback | Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag. |

## Artifacts to supersede

- `LINEAR-CANON-V3:decision:181`
- `LINEAR-CANON-V3:decision:41`

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
