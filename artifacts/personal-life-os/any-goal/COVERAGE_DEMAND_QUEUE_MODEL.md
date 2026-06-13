# Coverage Demand Queue Model

Status: AMB-697 / PLOS-075 downstream contract
Date: 2026-06-13 America/New_York
Scope: Documentation/control-plane model for CoverageNeed and CoverageDemand queue behavior.

This artifact defines `CoverageNeed` and the local `CoverageDemandQueue` for unsupported or under-covered Any Goal routing. The queue records abstract, reusable source or seed gaps after GoalIntentGeometry, OperatingMode, and SourceNeeded have proven that Ambitions cannot safely claim a source-backed path.

This is not Swift implementation, runtime queue storage, remote coverage request transport, source pack creation, R2 write, fresh-coverage arrival implementation, executable routing validator, UI implementation, release readiness, privacy/legal approval, accessibility proof, device proof, measured performance proof, or security certification.

## Existing Source Ownership

AMB-697 inspected these existing owners before adding this contract:

- `artifacts/personal-life-os/any-goal/ANY_GOAL_OPERATING_MODE_MODEL.md`
- `artifacts/personal-life-os/any-goal/GOAL_INTENT_GEOMETRY_MODEL.md`
- `artifacts/personal-life-os/any-goal/GOAL_SHAPE_FINGERPRINT_MODEL.md`
- `artifacts/personal-life-os/any-goal/CLARIFICATION_ENGINE_MODEL.md`
- `artifacts/personal-life-os/any-goal/SOURCE_NEEDED_LOCAL_SCAFFOLD.md`
- `docs/codex/ANY_GOAL_SOLUTION_LOOP_LAW.md`
- `docs/codex/SEED_BASED_PLANNING_LAW.md`
- `docs/codex/LOCAL_DATA_CLOUD_BOUNDARY_LAW.md`
- `docs/codex/SOURCE_ATLAS_AUTHORITY_LAW.md`
- `artifacts/source-atlas-factory/SOURCE_AUTHORITY_NON_READY_ROUTING.md`

These are ownership anchors and dependency inputs. They are not evidence that `CoverageNeed` or `CoverageDemandQueue` is implemented in app runtime.

## Model Role

Coverage demand is the safe loop for gaps Ambitions cannot resolve locally or from current source authority. It must preserve the user goal locally, classify the missing reusable coverage abstractly, block fake authoritative output, and optionally feed a later consented abstract coverage request.

Required invariant:

The queue may describe what public reusable source or seed coverage is missing. It must not contain raw private goal text, exact schedules, private proof, personal names, relationship context, sensitive notes, user identifiers, precise private location, or secrets.

## CoverageNeed Required Fields

| Field | Requirement | Red stop |
|---|---|---|
| `coverageNeedId` | Stable local id derived from non-private references. | ID includes raw private goal text or user identifier. |
| `goalIntentGeometryRef` | Local reference to AMB-755 `GoalIntentGeometry`. | Queue bypasses geometry or stores raw intake. |
| `goalShapeFingerprintRef` | Optional local AMB-694 replay reference when already produced. | Fingerprint becomes a public tracking key. |
| `sourceNeededScaffoldRef` | Optional AMB-696 scaffold reference when the need came from source-needed. | Source-needed route is disconnected from retry/fresh-coverage path. |
| `operatingMode` | `coverage_demand`, `source_needed`, `partial_source_backed`, `starter_only`, `jurisdiction_needed`, or `high_risk_guarded` only when the mode explicitly permits abstract gap recording. | Fully source-backed mode records coverage demand without contradiction or stale proof. |
| `goalFamily` | Abstract reusable family. | Exact private goal phrase is stored. |
| `domain` | Coarse domain. | Domain encodes private person, place, employer, school, or medical/legal detail. |
| `specificDomain` | Optional only when non-identifying and reusable. | Specific domain leaks sensitive or unique intent. |
| `missingSourceType` | Missing public source, pack, seed, review, freshness, jurisdiction, release receipt, rollback receipt, compatibility, or high-risk review class. | Missing class blames the user or becomes vague "AI could not plan." |
| `seedGapCategory` | Abstract reusable seed gap category. | Queue requests finished private Steps. |
| `riskJurisdictionClass` | Low, standard, jurisdiction-needed, high-risk-review, unsafe-blocked, or unknown-risk. | High-risk or jurisdiction gap is treated as ordinary coverage. |
| `freshnessReviewClass` | Current missing, stale, review-needed, source-changed, revoked, contradicted, unreviewed, or unknown. | Stale/revoked/contradicted source is hidden. |
| `blockerReason` | Why source-backed pathing is blocked or degraded. | Unsupported goal gets fake authoritative pathing. |
| `priorityClass` | Local triage priority derived from reusable coverage value and safety. | Priority is based on urgency pressure or private sensitivity. |
| `lifecycleState` | Current queue state from the lifecycle table. | Need appears resolved without coverage proof. |
| `privacyClass` | CoverageDemand privacy class from this contract. | Private context is allowed into R2/public Source Atlas. |
| `consentState` | Local consent state for any later optional remote abstract request. | Remote request proceeds without explicit consent. |
| `dedupeKey` | Abstract non-private dedupe key. | Deduping key contains raw goal or user identifier. |
| `receiptRef` | Local receipt explaining the gap and no-claim boundary. | User cannot inspect why pathing was limited. |

## CoverageDemand Privacy Classes

| Class | Meaning | Allowed destination |
|---|---|---|
| `local_private` | Contains or references private user intent, proof, schedule, or context. | Local device only. |
| `local_abstract` | Abstracted but still user-derived and not consented for remote request. | Local device only. |
| `remote_abstract_allowed` | Non-identifying abstract category that user explicitly allowed for optional remote coverage request. | Future AMB-698 request path only. |
| `blocked_sensitive` | Sensitive, high-risk, identifying, or unsafe material that cannot become coverage demand. | Local blocked receipt only. |
| `high_risk_review_only` | Requires high-risk or jurisdiction review before ordinary coverage handling. | Local guarded queue only. |

Default privacy class is `local_private` until a future owner proves abstraction, consent, and transport boundaries.

## Abstract Seed-Gap Categories

Coverage demand may use only reusable gap categories:

- `goal_family`
- `capability`
- `starter`
- `proof`
- `elasticity`
- `recovery`
- `jurisdiction`
- `replacement`
- `high_risk_review`
- `source_freshness`
- `source_review`
- `compatibility`
- `rollback`
- `release_receipt`

The queue must request reusable source or seed coverage. It must not request exact user-specific finished Steps, schedules, proof outcomes, or personal plans.

## Queue Lifecycle

| State | Meaning | Required transition guard |
|---|---|---|
| `local_detected` | Geometry/source-needed found a gap. | Geometry and operating mode references exist. |
| `queued_local` | Need is stored locally for retry/review. | Privacy class is local-safe. |
| `merged_or_deduped` | Equivalent abstract gap already exists. | Dedupe key is abstract and non-identifying. |
| `optional_request_pending_consent` | A later AMB-698 path may ask to send an abstract request. | Request body is not built until consent. |
| `abstract_request_allowed` | User allowed a non-identifying abstract request. | Privacy class is `remote_abstract_allowed`. |
| `waiting_for_coverage` | Need remains unresolved while public coverage may arrive later. | No fake plan or source-backed path is emitted. |
| `coverage_arrived_candidate` | A later source/freshness owner found potential public coverage. | Source authority, freshness, review, jurisdiction, and release receipts still need verification. |
| `route_recheck` | Local routing can be retried against fresh coverage. | Re-run geometry/source authority pathing locally. |
| `resolved` | Gap no longer blocks after verified public coverage and local recheck. | Exact source authority and freshness proof exists. |
| `blocked` | Need cannot proceed due to safety, privacy, jurisdiction, or source Red. | Block receipt exists. |
| `expired` | Need is no longer relevant or source posture changed. | Expiration reason and receipt exist. |
| `archived` | Historical local record retained under user data lifecycle rules. | Retention/delete/export policy respected. |

## Forbidden Material

CoverageNeed, CoverageDemandQueue, abstract requests, search logs, reports, Linear comments, R2 objects, and public Source Atlas material must not contain:

- raw private goal text
- exact schedules or calendar reality
- personal names or relationship context
- private proof details
- sensitive notes or freeform answers
- precise private location
- user identifiers or account data
- secrets, credentials, tokens, or support data
- medical/legal/financial facts that identify the user's situation

## Fixture Matrix

AMB-697 defines fixture obligations for later M07 validation:

- source-needed no matching pack becomes local CoverageNeed
- partial source-backed path records only the missing slice
- stale source coverage routes to `source_freshness` gap
- review-needed source routes to `source_review` gap
- jurisdiction unresolved routes to `jurisdiction` or `high_risk_review`
- high-risk review missing uses `high_risk_review_only`, not ordinary coverage
- starter seed missing routes to `starter`
- proof seed missing routes to `proof`
- elasticity seed missing routes to `elasticity`
- recovery seed missing routes to `recovery`
- replacement seed missing routes to `replacement`
- revoked or contradicted source cannot create resolved coverage
- same-goal/different-person variants produce different local queue decisions when explicit local evidence differs
- unsafe-blocked does not create ordinary coverage demand
- optional abstract request waits for AMB-698 consent and transport contract

AMB-697 does not create the executable 50-goal corpus or routing validator. Later M07 and M26 owners must implement them before claiming validator Green.

## Downstream Consumers

- AMB-698 / PLOS-076 optional anonymous abstract coverage request
- AMB-699 / PLOS-077 fresh coverage arrival detection
- AMB-700 / PLOS-078 unsupported and unsafe modes
- AMB-701 / PLOS-079 high-risk guarded routing
- AMB-617 / PLOS-M10 Golden vertical slice runtime consumption
- AMB-619 / PLOS-M12 Multi-Path Lattice
- AMB-620 / PLOS-M13 Step Graph Compiler
- AMB-623 / PLOS-M16 Life Consequence / Cross-Goal Reflow Engine
- AMB-635 / PLOS-M26 certification gauntlets

## Red Conditions

- coverage demand leaks sensitive intent or private context
- raw goals are sent remotely
- unsupported goals get fake plans
- high-risk, jurisdiction-needed, revoked, contradicted, or unsafe gaps become ordinary coverage
- queue marks coverage arrived or resolved without source authority, freshness, review, jurisdiction, release receipt, and rollback proof
- remote abstract request proceeds without explicit consent and AMB-698 transport contract
- dedupe keys, ids, logs, Linear comments, R2 keys, or public Source Atlas objects contain private user material
- fixture/test/generated/preview material is treated as production runtime proof

## Non-Claims

This artifact does not claim app source change, Swift/domain implementation, runtime queue storage, remote request implementation, coverage arrival implementation, executable fixture corpus, routing validator automation, runtime path selection, generated Step behavior, UI implementation, accessibility proof, source pack creation, R2 write, coverage request transport, runtime eligibility computation, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, device proof, measured performance proof, security certification, AMB-698/PLOS-076 execution, AMB-617/M10 runtime consumption, AMB-635/M26 production certification, or AMB-615 parent completion.
