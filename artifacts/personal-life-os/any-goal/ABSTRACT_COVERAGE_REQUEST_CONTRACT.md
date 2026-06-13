# Abstract Coverage Request Contract

Status: AMB-698 / PLOS-076 downstream contract
Date: 2026-06-13 America/New_York
Scope: Documentation/control-plane model for optional anonymous abstract coverage request behavior.

This artifact defines the optional `AbstractCoverageRequest` contract that can be created only from an AMB-697 `CoverageNeed` whose privacy class is safe for a consented abstract request. It is a request for reusable public source or seed coverage, not remote personal planning and not a user-specific Step request.

This is not Swift implementation, runtime request transport, Cloudflare/R2 configuration, live R2 write, network call, source pack creation, fresh coverage arrival implementation, executable routing validator, UI implementation, privacy/legal approval, release readiness, accessibility proof, device proof, measured performance proof, or security certification.

## Existing Source Ownership

AMB-698 inspected these existing owners before adding this contract:

- `artifacts/personal-life-os/any-goal/COVERAGE_DEMAND_QUEUE_MODEL.md`
- `artifacts/personal-life-os/any-goal/COVERAGE_DEMAND_QUEUE_MODEL.json`
- `artifacts/personal-life-os/any-goal/SOURCE_NEEDED_LOCAL_SCAFFOLD.md`
- `artifacts/personal-life-os/any-goal/GOAL_INTENT_GEOMETRY_MODEL.md`
- `artifacts/personal-life-os/any-goal/ANY_GOAL_OPERATING_MODE_MODEL.md`
- `docs/codex/ANY_GOAL_SOLUTION_LOOP_LAW.md`
- `docs/codex/LOCAL_DATA_CLOUD_BOUNDARY_LAW.md`
- `docs/codex/SEED_BASED_PLANNING_LAW.md`
- `artifacts/personal-life-os/reports/PLOS-025-r2-source-only-boundary-matrix.md`

These are ownership anchors and dependency inputs. They are not evidence that `AbstractCoverageRequest` is implemented in app runtime or sent anywhere.

## Request Role

An abstract coverage request is optional and user-consented. It may ask the public Source Atlas foundry for reusable coverage categories such as a goal family seed, starter seed, proof seed, recovery seed, elasticity seed, jurisdiction seed, replacement seed, source freshness review, source review, compatibility metadata, rollback metadata, or release receipt coverage.

It must never contain or imply the user's raw private goal, schedule, proof, relationship context, sensitive notes, private location, personal identifiers, local learning, or private source-needed narrative.

## Eligibility Gates

All gates must pass before a future runtime can build a request payload:

1. The source `CoverageNeed` exists locally and is linked to GoalIntentGeometry.
2. The `CoverageNeed` privacy class is `remote_abstract_allowed`.
3. User consent is explicit, current, revocable, and scoped to an abstract request only.
4. Redaction proof shows no forbidden material in the payload, key, log, receipt, or Linear/support artifact.
5. The request asks for reusable source or seed coverage, not finished private Steps.
6. High-risk, jurisdiction-needed, unsafe, revoked, contradicted, or blocked gaps are not sent as ordinary requests.
7. The request has a local receipt explaining what was sent, what was not sent, and how to revoke future requests.

If any gate is missing, the request remains local-only or blocked.

## Required Fields

| Field | Requirement | Red stop |
|---|---|---|
| `requestId` | Local request id derived from non-private request metadata. | ID contains raw private goal text or user identifier. |
| `coverageNeedRef` | Local AMB-697 CoverageNeed id. | Request is created without a queue record. |
| `requestClass` | `abstract_seed_gap`, `abstract_source_gap`, `abstract_review_gap`, `abstract_jurisdiction_gap`, or `abstract_compatibility_gap`. | Request asks for exact user-specific Steps. |
| `seedGapCategory` | AMB-697 abstract seed-gap category. | Category includes private target or personal detail. |
| `goalFamily` | Optional coarse reusable family. | Family is raw private goal phrasing. |
| `domain` | Optional coarse domain. | Domain identifies a person, account, location, school, employer, medical/legal fact, or private circumstance. |
| `riskJurisdictionClass` | `standard`, `jurisdiction_review_needed`, `high_risk_review_needed`, or `blocked_not_requestable`. | High-risk request is treated as ordinary coverage. |
| `sourceAuthorityNeed` | Missing source, review, freshness, compatibility, rollback, release receipt, or jurisdiction class. | Revoked/contradicted material is requested as if usable. |
| `privacyClass` | Must be `remote_abstract_allowed` before payload build. | Local/private or blocked-sensitive material is sent. |
| `consentReceiptRef` | Local consent receipt. | Request is sent without consent proof. |
| `redactionProofRef` | Local proof that forbidden material was excluded. | No redaction evidence exists. |
| `transportState` | `not_implemented`, `blocked`, `ready_for_future_transport`, `sent_by_future_owner`, or `revoked`. | AMB-698 claims live transport. |
| `localRetryRef` | Local retry/fresh-coverage hook. | Request has no local recovery or revoke route. |

## Allowed Payload Fields

Only these payload fields are allowed in a future request body:

- `schemaVersion`
- `requestClass`
- `seedGapCategory`
- `goalFamily`
- `domain`
- `riskJurisdictionClass`
- `sourceAuthorityNeed`
- `localeOrJurisdictionClass` only when coarse and non-identifying
- `appCompatibilityClass` only when non-user-specific
- `requestCreatedAtBucket` as coarse date bucket, not exact user activity time

Forbidden payload fields:

- raw private goal text
- exact schedule or deadline from the user
- personal names or relationship context
- private proof or receipts
- sensitive notes, answers, or captures
- precise location or private institution/employer/account
- user id, device id, iCloud id, email, phone, account, IP-derived identity, or analytics identifier
- local learning summaries or behavior patterns
- secrets, credentials, tokens, support data, or logs

## Consent And Revocation

Consent must be:

- explicit
- scoped to abstract reusable coverage only
- separated from general app usage
- revocable before future sends when not yet sent
- recorded in a local receipt
- export/delete/reset aware under the local data lifecycle rules

Consent must not say or imply that Ambitions uploads the user's goal for personalized planning. If the future transport cannot preserve that boundary, the request remains blocked.

## Privacy Redaction Matrix

| Source material | Request handling |
|---|---|
| Raw goal text | Always excluded. |
| GoalIntentGeometry abstract family/domain | Allowed only if non-identifying. |
| SourceNeeded boundary reason | Converted to abstract source authority need; private narrative excluded. |
| CoverageNeed seed gap | Allowed when category is reusable and non-identifying. |
| Exact schedule/deadline | Excluded; may become coarse urgency class only if non-identifying and future issue authorizes it. |
| Private proof/receipt | Excluded. |
| Names/relationship context | Excluded. |
| Precise location/institution/employer/account | Excluded. |
| High-risk facts | Blocked or review-only; ordinary request forbidden. |
| Local learning/capability evidence | Excluded; routing remains local. |

## Fixture Matrix

AMB-698 defines fixture obligations for later M07 validation:

- local-private CoverageNeed cannot build request
- local-abstract CoverageNeed requires consent before request
- remote-abstract allowed request contains only allowed fields
- raw private goal text is redacted
- exact schedule is redacted
- names and relationship context are redacted
- private proof and receipts are redacted
- high-risk review gap blocks ordinary request
- jurisdiction gap routes to review-only request class
- revoked or contradicted source cannot request usable coverage as current
- optional request can be denied, revoked, or left unsent without blocking local source-needed support
- same-goal/different-person variants do not leak local personalization slots

AMB-698 does not create the executable 50-goal corpus, transport, network validation, R2 object, or routing validator.

## Downstream Consumers

- AMB-699 / PLOS-077 fresh coverage arrival detection
- AMB-700 / PLOS-078 unsupported and unsafe modes
- AMB-701 / PLOS-079 high-risk guarded routing
- AMB-617 / PLOS-M10 Golden vertical slice runtime consumption
- AMB-619 / PLOS-M12 Multi-Path Lattice
- AMB-620 / PLOS-M13 Step Graph Compiler
- AMB-623 / PLOS-M16 Life Consequence / Cross-Goal Reflow Engine
- AMB-635 / PLOS-M26 certification gauntlets

## Red Conditions

- raw goals are sent remotely
- private context can enter request payloads
- coverage demand leaks sensitive intent
- request payload contains user identifiers, exact schedules, private proof, names, relationship context, sensitive notes, precise private location, secrets, or local learning
- high-risk, jurisdiction-needed, unsafe, revoked, or contradicted gaps are sent as ordinary coverage
- consent is missing, bundled, stale, non-revocable, or misleading
- AMB-698 claims live R2/network transport or production readiness
- fixture/test/generated/preview material is treated as production runtime proof

## Non-Claims

This artifact does not claim app source change, Swift/domain implementation, runtime request storage, network transport, Cloudflare/R2 configuration, live R2 write, source pack creation, fresh coverage arrival implementation, executable fixture corpus, routing validator automation, runtime path selection, generated Step behavior, UI implementation, accessibility proof, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, device proof, measured performance proof, security certification, AMB-699/PLOS-077 execution, AMB-617/M10 runtime consumption, AMB-635/M26 production certification, or AMB-615 parent completion.
