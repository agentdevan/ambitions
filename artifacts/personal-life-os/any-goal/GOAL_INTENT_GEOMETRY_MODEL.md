# Goal Intent Geometry Model

Status: AMB-755 / PLOS-071 downstream contract
Date: 2026-06-13 America/New_York
Scope: Documentation/control-plane model for the Any Goal intent geometry classifier boundary.

This artifact defines `GoalIntentGeometry`, the required deterministic geometry object between raw goal understanding and any later Goal Shape Fingerprint, coverage need, source-needed scaffold, clarification, or path compilation. It prevents raw private goal text from flowing directly into Step lists, generic templates, coverage demand, or unsupported fake plans.

This is not Swift implementation, classifier implementation, validator automation, executable fixture corpus, runtime pathing, UI, source pack content, R2 transport, privacy/legal approval, release readiness, accessibility proof, device proof, performance proof, or security certification.

## Existing Source Ownership

AMB-755 inspected these existing owners before adding this contract:

- `docs/codex/ANY_GOAL_SOLUTION_LOOP_LAW.md`
- `artifacts/personal-life-os/any-goal/ANY_GOAL_OPERATING_MODE_MODEL.md`
- `Native/Ambitions/Domain/GoalEngine/GoalUnderstandingModels.swift`
- `Native/Ambitions/Services/GoalUnderstandingService.swift`
- `Native/Ambitions/Domain/GoalEngine/GoalClarificationModels.swift`
- `Native/Ambitions/Services/GoalClarificationService.swift`
- `Native/Ambitions/Domain/GoalEngine/GoalIntentCompilerModels.swift`
- `Native/Ambitions/Domain/SourceAtlasIntentMatchModels.swift`
- `artifacts/source-atlas-factory/SOURCE_ATLAS_REUSABLE_SEED_TAXONOMY.md`
- `artifacts/source-atlas-factory/SOURCE_ATLAS_SEED_FAMILY_GENERATION.md`
- `artifacts/source-atlas-factory/SOURCE_AUTHORITY_VALIDATION_GAUNTLET.md`

These are ownership anchors and dependency inputs. They are not evidence that `GoalIntentGeometry` is implemented in app runtime.

## Model Role

`GoalIntentGeometry` is the normalized, receipt-ready shape of a user goal after local understanding and before path generation.

Required invariant:

Raw goal intake must pass through Goal Understanding, GoalStateAssessment, OperatingMode, and GoalIntentGeometry before any later phase can create a GoalShapeFingerprint, CoverageNeed, source-needed scaffold, Recommended step, Start now route, Open step route, schedule install, or unsupported/unsafe block receipt.

## Required Fields

| Field | Requirement | Red stop |
|---|---|---|
| `geometryId` | Stable local id derived without exposing raw private text. | ID is raw goal text or personal context. |
| `normalizedIntent` | Short local semantic summary for routing only. | Summary becomes public source or R2 material. |
| `domain` | Broad domain family such as health, learning, money, home, career, relationship, creative, administration, care, travel, safety, or unknown. | Unknown domain is forced into a generic plan. |
| `specificDomain` | Optional narrower local domain if explicit or source-supported. | Narrow domain is inferred from stereotypes or weak context. |
| `skillSlice` | Current skill/capability slice: beginner, guided, practiced, expert-tracking, collaborative-supported, or unknown. | Beginner/expert is inferred without local evidence. |
| `role` | User role relative to the goal: owner, learner, caregiver, collaborator, dependent, decision-maker, maintainer, or unknown. | Collaborative or dependent context is collapsed to solo tasking. |
| `riskClass` | Safety/jurisdiction/reversibility posture linked to M05/M06 risk and source authority. | High-risk or jurisdiction-needed goal routes as ordinary productivity. |
| `deadlineSemantics` | Hard deadline, target date, season, rolling window, no-date exploration, recurring maintenance, or unknown. | Missing deadline is silently invented. |
| `ambiguityState` | Clear, missing success definition, missing scope, missing resources, missing ownership, missing deadline, missing jurisdiction, or unsafe to infer. | Ambiguity is bypassed with guessed Steps. |
| `capabilityContextBranch` | Local evidence branch for same-goal/different-person routing. | Same raw goal always maps to one route. |
| `localCapabilityEvidence` | Local-only evidence references, never raw private text for public material. | Evidence leaks to CoverageNeed or R2. |
| `sourcePosture` | Ready, partial, source-needed, review-needed, stale, revoked, contradicted, jurisdiction-needed, local-only-private, or blocked. | Non-ready posture still produces authoritative Steps. |
| `operatingMode` | Required AMB-692 mode id. | Geometry exists without OperatingMode. |
| `goalStateAssessment` | Required upstream assessment summary. | Goal state is implicit or skipped. |
| `coverageNeedCandidate` | Optional abstract coverage need candidate with privacy class. | Raw private goal text becomes coverage demand. |
| `goalShapeFingerprintInputs` | Non-private fields that AMB-694 may consume for GoalShapeFingerprint. | Fingerprint consumes raw private text or hidden assumptions. |
| `privacyClass` | local-only, local-user-context, public-source-reference, abstract-gap, or blocked. | Public/R2 path lacks privacy classification. |
| `audit` | Local receipt metadata for inputs, assumptions, blocked fields, and no-claim status. | No trace for inferred route or blocked route. |

## GoalStateAssessment Linkage

`GoalStateAssessment` is the required upstream assessment for:

- state: new, active, paused, recurring, maintenance, decision, collaborative, blocked, unsafe, or unsupported
- ambiguity: domain, scope, timeline, success definition, ownership, resources, risk, or jurisdiction
- deadline semantics and consequence posture
- local capability posture and explicit evidence branch
- source posture and Source Authority state

`GoalIntentGeometry` may compress this assessment for later phases, but it must not replace it or hide missing evidence.

## OperatingMode Linkage

AMB-692 `OperatingMode` remains the outer routing mode. `GoalIntentGeometry` explains why that mode was selected and what later phases may consume.

Examples:

- `source_needed` plus high source gap yields abstract `CoverageNeed` candidate, not a fake path.
- `clarification_needed` plus missing success definition yields a minimal question set, not broad intake.
- `high_risk_guarded` plus jurisdiction-needed blocks ordinary starter routing.
- `beginner_guided` requires explicit local evidence or direct user request.
- `expert_tracking` requires local evidence, not inferred status.

## GoalShapeFingerprint Linkage

AMB-694 / PLOS-072 may consume only `goalShapeFingerprintInputs`.

Allowed fingerprint inputs:

- domain and specific domain
- goal state
- deadline semantics
- ambiguity state
- risk class and jurisdiction posture
- source posture
- capability context branch
- operating mode
- privacy class

Forbidden fingerprint inputs:

- raw private goal text
- exact schedule
- private proof detail
- private location or identifiers
- unredacted collaborator names
- raw source-needed narrative
- secret, credential, token, or support data

## CoverageNeed Linkage

`CoverageNeed` can be created only when:

- OperatingMode is `coverage_demand`, `source_needed`, `partial_source_backed`, or another future mode that explicitly permits abstract gap recording.
- The coverage need is abstract and non-identifying.
- The need records domain, missing source type, risk/jurisdiction class, freshness/review class, and why local routing is blocked or degraded.
- Raw goal text, local proof, schedule, personal names, and private context are excluded.

## Fixture Corpus Linkage

AMB-755 defines geometry obligations for the later M07 fixture corpus:

- at least 50 raw goal fixtures
- every AMB-692 operating mode represented at least twice
- at least five same-goal/different-person fixture families
- explicit local-state variants for beginner, guided, practiced, expert-tracking, collaborative-supported, high-risk, jurisdiction-needed, source-needed, coverage-demand, unsupported, and unsafe-blocked
- proof that same raw goals route differently when local evidence differs
- proof that coverage demand emits abstract gaps, not raw private goal text

AMB-755 does not create the executable corpus. Later M07 owners must implement it before claiming routing validator Green.

## Red Conditions

- raw goal text goes directly to a Step list
- unsupported or source-needed goal gets a fake plan
- coverage demand leaks sensitive intent, private context, exact schedule, personal identifiers, or proof
- same raw goal collapses to one generic route for different local states
- beginner, expert, collaborator, caregiver, or high-risk state is inferred without explicit evidence
- high-risk, jurisdiction-needed, revoked, contradicted, stale-critical, blocked, or local-only-private source posture drives ordinary Steps
- GoalShapeFingerprint consumes raw private text
- source pack, R2, public Source Atlas, or Linear material receives private user data

## Downstream Consumers

- AMB-694 / PLOS-072 `GoalShapeFingerprint`
- AMB-695 / PLOS-073 clarification engine
- AMB-696 / PLOS-074 source-needed local scaffold
- AMB-697 / PLOS-075 Coverage Demand Queue
- AMB-698 / PLOS-076 optional anonymous abstract coverage request
- AMB-699 / PLOS-077 fresh coverage arrival detection
- AMB-700 / PLOS-078 unsupported/unsafe modes
- AMB-701 / PLOS-079 high-risk guarded routing
- AMB-617 / PLOS-M10 Golden vertical slice runtime consumption
- AMB-635 / PLOS-M26 certification gauntlets

## Non-Claims

This artifact does not claim app source change, Swift implementation, classifier implementation, validator automation, executable fixture corpus, GoalShapeFingerprint implementation, CoverageNeed implementation, runtime path selection, generated Step behavior, source pack creation, R2 write, coverage request transport, runtime eligibility computation, UI implementation, accessibility proof, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, device proof, measured performance proof, security certification, AMB-694/PLOS-072 execution, AMB-617/M10 runtime consumption, AMB-635/M26 production certification, or AMB-615 parent completion.
