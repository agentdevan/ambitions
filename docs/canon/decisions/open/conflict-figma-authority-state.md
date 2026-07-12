+++
schema_version = 1
conflict_id = "CONFLICT-FIGMA-AUTHORITY-STATE"
status = "unresolved"
severity = "P0_BLOCKER"
priority = "P1"
concepts = ["proof.screenshot.limit", "visual.figma.authority-state"]
scopes = ["proof.visual", "visual.figma"]
recommendation = "compose"
recommendation_rationale = "Register direction and final package as distinct visual-authority records with explicit precedence and unchanged proof ceilings."
stronger_composition = "Use one visual authority topology that records frame role, owner approval, successor node, canon requirements, implementation state, accessibility variants, and proof status."
proposed_canonical_law = "Figma visual authority MUST distinguish approved direction from approved final package and implementation proof; node 250:104 MUST NOT be treated as the final target when successor package node 257:93 applies."
artifacts_to_supersede = ["FIGMA:SWtHm9ouHTPbEFfNrrtZwv:250:104", "FIGMA:SWtHm9ouHTPbEFfNrrtZwv:257:93", "REPO-85E8FCCE72F548DEDB08341B:line:265"]
target_requirement_status = "planned_uncreated"
target_requirement_id = ""
owner_decision = ""
allowed_resolutions = ["keep_a", "keep_b", "compose", "reject_both"]
affected_task_scopes = ["visual.vsp-07", "visual.wake-stack"]
nonclaims = "No conflict is resolved; no final Constitution or Atlas law is approved; no source, test, product, runtime, visual, accessibility, privacy, device, CloudKit, TestFlight, App Store, or release Green claim is made."
claim_ceiling = "Task 12 shadow conflict provenance, recommendation, and impact analysis only for the reviewed claims and base SHA; no source-edit or cutover authorization."

[[claims]]
claim_id = "CLAIM-NAV-127"
source_id = "REPO-85E8FCCE72F548DEDB08341B"
source_location = "line:265"
concept = "proof.screenshot.limit"
scope = "proof.visual"
modality = "MUST"
normalized_value = "accessibility, performance, privacy, release, or device correctness."
evidence_sha256 = "aa81961732fd467956cdc900afe9f304ca0d7099a8f25970b5a742f6f7e357d6"
owner_approval = "active-repo-authority:RELEASE_TRUTH.md"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[claims]]
claim_id = "CLAIM-NAV-128"
source_id = "FIGMA-VSP07-PART02-OPTION-A-R1"
source_location = "document"
concept = "visual.figma.authority-state"
scope = "visual.figma"
modality = "INFORMATIONAL"
normalized_value = "owner-approved vsp-07 part 02 visual direction/evidence with a yellow ceiling, while the frame is labeled exploration on a candidate page."
evidence_sha256 = "17cb1a722177ba93e0d1cfa5b85c4dcd52520d96d2b25ce3a45ef36a50080dbb"
owner_approval = "owner-approved:2026-07-01"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[impacts]]
dimension = "repo"
analysis = "VSP-07 manifests, owner approvals, provenance registry, proof registry, and future visual-authority manifest require one topology."

[[impacts]]
dimension = "linear"
analysis = "Implementation issues must reference requirement IDs and the correct final visual node without copying product law."

[[impacts]]
dimension = "figma"
analysis = "Retain file SWtHm9ouHTPbEFfNrrtZwv node 250:104 as direction and node 257:93 plus package children as later approved target until Gate C."

[[impacts]]
dimension = "production_source"
analysis = "Trust/Inspection/wake UI paths are only impact candidates; no implementation mapping or parity is proven."

[[impacts]]
dimension = "tests"
analysis = "Later require exact SwiftUI parity, state coverage, snapshot/rendered evidence, interaction, accessibility, and device validation."

[[impacts]]
dimension = "proof"
analysis = "Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven."

[[impacts]]
dimension = "privacy"
analysis = "Contextual proof/source/privacy/history/receipt visuals must not leak private graph content or become root surfaces."

[[impacts]]
dimension = "accessibility"
analysis = "The package accessibility matrix is design evidence only; live VoiceOver, Dynamic Type, contrast, Reduce Motion/Transparency, and device proof remain required."

[[impacts]]
dimension = "migration_rollback"
analysis = "Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag."
+++

# CONFLICT-FIGMA-AUTHORITY-STATE

> Shadow migration decision docket. It is non-authoritative and remains unresolved until the owner records a decision.

## Competing conceptual claims

| Claim | Normalized value | Modality | Scope | Source provenance | Evidence SHA-256 |
| --- | --- | --- | --- | --- | --- |
| `CLAIM-NAV-127` | accessibility, performance, privacy, release, or device correctness. | `MUST` | proof.visual | `REPO-85E8FCCE72F548DEDB08341B:line:265` | `aa81961732fd467956cdc900afe9f304ca0d7099a8f25970b5a742f6f7e357d6` |
| `CLAIM-NAV-128` | owner-approved vsp-07 part 02 visual direction/evidence with a yellow ceiling, while the frame is labeled exploration on a candidate page. | `INFORMATIONAL` | visual.figma | `FIGMA-VSP07-PART02-OPTION-A-R1:document` | `17cb1a722177ba93e0d1cfa5b85c4dcd52520d96d2b25ce3a45ef36a50080dbb` |

## User consequences

Codex may implement an exploration as final visual law or ignore approved direction, while reviewers may mistake either artifact for live SwiftUI or accessibility proof.

## Compatibility analysis

Node 250:104 is owner-approved bounded direction despite EXPLORATION/CANDIDATE labels. Later node 257:93 is the approved final package target. Both remain Yellow and neither proves SwiftUI parity, accessibility, device behavior, or release readiness.

## Recommendation

**Compose A and B with explicit scopes.** Register direction and final package as distinct visual-authority records with explicit precedence and unchanged proof ceilings.

This is a recommendation for Gate A, not an owner decision.

## Stronger composition option

Use one visual authority topology that records frame role, owner approval, successor node, canon requirements, implementation state, accessibility variants, and proof status.

## Proposed canonical law

Figma visual authority MUST distinguish approved direction from approved final package and implementation proof; node 250:104 MUST NOT be treated as the final target when successor package node 257:93 applies.

## Impact analysis

| Dimension | Impact |
| --- | --- |
| repo | VSP-07 manifests, owner approvals, provenance registry, proof registry, and future visual-authority manifest require one topology. |
| Linear | Implementation issues must reference requirement IDs and the correct final visual node without copying product law. |
| Figma | Retain file SWtHm9ouHTPbEFfNrrtZwv node 250:104 as direction and node 257:93 plus package children as later approved target until Gate C. |
| production source | Trust/Inspection/wake UI paths are only impact candidates; no implementation mapping or parity is proven. |
| tests | Later require exact SwiftUI parity, state coverage, snapshot/rendered evidence, interaction, accessibility, and device validation. |
| proof | Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven. |
| privacy | Contextual proof/source/privacy/history/receipt visuals must not leak private graph content or become root surfaces. |
| accessibility | The package accessibility matrix is design evidence only; live VoiceOver, Dynamic Type, contrast, Reduce Motion/Transparency, and device proof remain required. |
| migration / rollback | Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag. |

## Artifacts to supersede

- `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:250:104`
- `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:257:93`
- `REPO-85E8FCCE72F548DEDB08341B:line:265`

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
