# Fresh Coverage Arrival Detection Contract

Status: AMB-699 / PLOS-077 downstream contract
Date: 2026-06-13 America/New_York
Scope: Documentation/control-plane model for fresh coverage arrival detection.

This artifact defines the future `FreshCoverageArrival` detection contract that can turn an unresolved AMB-697 `CoverageNeed` into a local route recheck only after new public Source Atlas coverage is detected through abstract metadata. It is a privacy-safe unlock contract, not network transport, not R2 configuration, not runtime fetch/cache implementation, and not a source-backed pathing claim.

This is not Swift implementation, runtime arrival storage, Cloudflare/R2 configuration, live R2 write, network call, source pack creation, executable routing validator, UI implementation, privacy/legal approval, release readiness, accessibility proof, device proof, measured performance proof, or security certification.

## Existing Source Ownership

AMB-699 inspected these existing owners before adding this contract:

- `artifacts/personal-life-os/any-goal/COVERAGE_DEMAND_QUEUE_MODEL.md`
- `artifacts/personal-life-os/any-goal/COVERAGE_DEMAND_QUEUE_MODEL.json`
- `artifacts/personal-life-os/any-goal/ABSTRACT_COVERAGE_REQUEST_CONTRACT.md`
- `artifacts/personal-life-os/any-goal/ABSTRACT_COVERAGE_REQUEST_CONTRACT.json`
- `artifacts/personal-life-os/any-goal/SOURCE_NEEDED_LOCAL_SCAFFOLD.md`
- `artifacts/source-atlas-factory/SOURCE_AUTHORITY_NON_READY_ROUTING.md`
- `docs/codex/ANY_GOAL_SOLUTION_LOOP_LAW.md`
- `docs/codex/SOURCE_ATLAS_AUTHORITY_LAW.md`
- `docs/codex/SEED_BASED_PLANNING_LAW.md`
- `docs/codex/LOCAL_DATA_CLOUD_BOUNDARY_LAW.md`

These are ownership anchors and dependency inputs. They are not evidence that fresh coverage arrival detection is implemented in app runtime.

## Detection Role

Fresh coverage arrival is the privacy-safe bridge between a local unresolved `CoverageNeed` and later public reusable coverage. A future runtime may detect that a new public source pack, seed pack, review result, compatibility manifest, release receipt, rollback target, freshness update, or jurisdiction/high-risk review artifact could satisfy an abstract gap. The runtime still must re-run Source Authority, freshness, review, jurisdiction, risk, release receipt, rollback, compatibility, Step Quality, and local personalization checks before any route changes.

Required invariant:

Arrival detection may compare only abstract coverage metadata and local references. It must never upload, query with, log, or match against raw private goal text, exact schedules, private proof, relationship context, names, local learning, precise location, identifiers, secrets, or sensitive freeform answers.

## Required Inputs

| Input | Requirement | Red stop |
|---|---|---|
| `coverageNeedRef` | Local AMB-697 CoverageNeed id. | Arrival check starts without a local gap record. |
| `coverageNeedDedupeKey` | Abstract non-identifying dedupe key. | Key contains raw goal, user id, schedule, or private context. |
| `goalFamily` | Coarse reusable family when non-identifying. | Family is raw private goal phrasing. |
| `domain` | Coarse domain. | Domain identifies a person, account, location, employer, school, medical/legal fact, or private circumstance. |
| `seedGapCategory` | AMB-697 abstract seed-gap category. | Finished user-specific Step or personal plan is requested. |
| `sourceAuthorityNeed` | Missing source, review, freshness, compatibility, rollback, release receipt, or jurisdiction class. | Revoked or contradicted material is treated as current. |
| `riskJurisdictionClass` | Low/standard/jurisdiction-needed/high-risk-review/unsafe-blocked/unknown-risk. | High-risk or jurisdiction gap is unlocked as ordinary coverage. |
| `freshnessReviewClass` | Current missing, stale, review-needed, source-changed, revoked, contradicted, unreviewed, or unknown. | Stale/revoked/contradicted state is hidden. |
| `privacyClass` | AMB-697 CoverageDemand privacy class. | Local/private or blocked-sensitive data is sent to public Source Atlas or R2. |
| `requestRef` | Optional AMB-698 AbstractCoverageRequest ref when one exists. | Arrival depends on a remote request as the only local recovery path. |
| `localReceiptRef` | Receipt explaining the prior source-needed/coverage gap. | User cannot inspect why routing changed. |

## Arrival Candidate Fields

Fresh coverage arrival may create only a local `FreshCoverageCandidate` with these fields:

- `candidateId`
- `coverageNeedRef`
- `sourcePackOrManifestRef`
- `sourceAuthorityState`
- `sourceFreshnessState`
- `reviewState`
- `riskJurisdictionState`
- `releaseReceiptRef`
- `rollbackReceiptRef`
- `compatibilityState`
- `matchedAbstractFields`
- `blockedReason`
- `routeRecheckState`
- `receiptRef`

The candidate is local-only until future source/release owners prove a public-safe artifact can be distributed. It is not a source-backed route by itself.

## Abstract Matching Rules

Allowed match fields:

- abstract goal family
- coarse domain
- reusable seed gap category
- source authority need class
- coarse jurisdiction or locale class when non-identifying
- risk/review class
- compatibility class
- release receipt class
- rollback class
- pack kind and schema version

Forbidden match fields:

- raw private goal text
- exact user schedule, deadline, or calendar reality
- private proof, receipts, captures, or closure history
- names, relationship context, or private collaborators
- precise private location, employer, school, institution, account, or protected context
- user id, device id, iCloud id, email, phone, IP-derived identity, analytics id, or support id
- local learning, behavior patterns, capability evidence, or private personalization slots
- secrets, credentials, tokens, support bundles, or logs

## Lifecycle

| State | Meaning | Required guard |
|---|---|---|
| `not_checked` | No arrival check has run. | CoverageNeed remains local. |
| `candidate_detected` | Abstract public coverage may satisfy the gap. | Match uses only allowed abstract fields. |
| `source_authority_pending` | Candidate still needs authority/freshness/review/risk checks. | No route unlock yet. |
| `blocked_by_privacy` | Candidate or match would require private context. | Keep local receipt and do not query/send private data. |
| `blocked_by_source` | Source is stale, revoked, contradicted, missing receipt, incompatible, or unreviewed. | Keep source-needed/coverage-demand route. |
| `blocked_by_risk` | Jurisdiction/high-risk/unsafe review blocks ordinary unlock. | Route to guarded review owner. |
| `ready_for_route_recheck` | Candidate has enough source-authority evidence for a local route recheck. | Re-run routing locally; do not mark source-backed yet. |
| `route_rechecked` | Local routing was recomputed against the candidate. | Receipt records prior and new route. |
| `resolved` | Gap no longer blocks after local recheck and all required source gates pass. | Exact source/release/rollback/freshness proof exists. |
| `expired` | Candidate no longer applies. | Expiration receipt exists. |

## Unlock Rules

Fresh coverage arrival can only move a CoverageNeed toward `ready_for_route_recheck` when all of these are true:

1. The matching Source Atlas artifact is public, reusable, non-user-specific, and source-bound.
2. The match uses only abstract allowed fields from the CoverageNeed or AbstractCoverageRequest.
3. Source Authority state is eligible or candidate-eligible for the scoped recheck.
4. Freshness, review, jurisdiction, risk, compatibility, release receipt, and rollback receipt checks are present or explicitly not applicable.
5. No revocation, contradiction, quarantine, high-risk ordinary-route gap, private-data leak, or unsupported schema is present.
6. The local receipt can explain that the route is being rechecked because fresh coverage is available, not because private context was uploaded.

If any gate fails, the CoverageNeed stays unresolved with the correct blocked state.

## Fixture Matrix

AMB-699 defines fixture obligations for later M07 validation:

- fresh public starter seed matches source-needed local gap
- fresh proof seed matches abstract proof gap
- fresh elasticity seed matches abstract elasticity gap
- source freshness update unlocks stale source candidate
- review receipt unlocks review-needed candidate only after review passes
- release receipt missing keeps candidate blocked
- rollback receipt missing keeps candidate blocked for release-sensitive coverage
- revoked source does not unlock
- contradicted source does not unlock
- incompatible manifest does not unlock
- high-risk review gap routes to guarded review, not ordinary coverage
- jurisdiction-needed gap remains guarded until jurisdiction class is resolved
- same-goal/different-person variants recheck locally without uploading personalization slots
- abstract request denied/revoked/unsent can still benefit from public fresh coverage
- arrival candidate never contains raw private goal text, exact schedule, proof, names, local learning, identifiers, logs, or secrets

AMB-699 does not create the executable 50-goal corpus, runtime fetch, network validation, R2 object, or routing validator.

## Downstream Consumers

- AMB-700 / PLOS-078 unsupported and unsafe modes
- AMB-701 / PLOS-079 high-risk guarded routing
- AMB-617 / PLOS-M10 Golden vertical slice runtime consumption
- AMB-619 / PLOS-M12 Multi-Path Lattice
- AMB-620 / PLOS-M13 Step Graph Compiler
- AMB-623 / PLOS-M16 Life Consequence / Cross-Goal Reflow Engine
- AMB-635 / PLOS-M26 certification gauntlets

## Red Conditions

- arrival detection requires uploaded private goal content
- fresh coverage creates fake source-backed coverage without Source Authority proof
- route unlock uses raw private goal text, exact schedule, proof, names, relationship context, precise private location, identifiers, local learning, support data, logs, or secrets
- high-risk, jurisdiction-needed, revoked, contradicted, quarantined, incompatible, or missing-receipt material unlocks ordinary routing
- source-needed becomes a dead end when fresh public coverage exists
- route changes happen without a local receipt
- fixture/test/generated/preview material is treated as production runtime proof

## Non-Claims

This artifact does not claim app source change, Swift/domain implementation, runtime arrival storage, runtime fetch/cache/quarantine implementation, network transport, Cloudflare/R2 configuration, live R2 write, source pack creation, executable fixture corpus, routing validator automation, runtime path selection, generated Step behavior, UI implementation, accessibility proof, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, device proof, measured performance proof, security certification, AMB-700/PLOS-078 execution, AMB-617/M10 runtime consumption, AMB-635/M26 production certification, or AMB-615 parent completion.
