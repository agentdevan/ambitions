# Source Needed Local Scaffold Model

Status: AMB-696 / PLOS-074 downstream contract
Date: 2026-06-13 America/New_York
Scope: Documentation/control-plane model for source-needed Any Goal local scaffold behavior.

This artifact defines `SourceNeeded`, the local scaffold used when Ambitions understands enough about a goal family to preserve intent and offer safe non-authoritative support, but Source Authority, coverage, freshness, review, jurisdiction, or risk evidence is not ready to drive a Recommended step, schedule install, share projection, or source-backed path.

This is not Swift implementation, runtime source-needed UI, runtime classifier implementation, validator automation, executable fixture corpus, generated Step behavior, source pack creation, R2 transport, privacy/legal approval, release readiness, accessibility proof, device proof, performance proof, or security certification.

## Existing Source Ownership

AMB-696 inspected these existing owners before adding this contract:

- `Native/Ambitions/Domain/SourceAtlasIntentMatchModels.swift`
- `Native/Ambitions/Runtime/SourceAtlasRuntimeBridgeReplay.swift`
- `Native/Ambitions/Domain/GoalEngine/GoalIntentCompilerModels.swift`
- `Native/Ambitions/Domain/GoalEngine/GoalClarificationModels.swift`
- `Native/Ambitions/Services/GoalClarificationService.swift`
- `artifacts/source-atlas-factory/SOURCE_AUTHORITY_NON_READY_ROUTING.md`
- `artifacts/personal-life-os/any-goal/ANY_GOAL_OPERATING_MODE_MODEL.md`
- `artifacts/personal-life-os/any-goal/GOAL_INTENT_GEOMETRY_MODEL.md`
- `artifacts/personal-life-os/any-goal/GOAL_SHAPE_FINGERPRINT_MODEL.md`
- `artifacts/personal-life-os/any-goal/CLARIFICATION_ENGINE_MODEL.md`
- `docs/codex/ANY_GOAL_SOLUTION_LOOP_LAW.md`
- `docs/codex/SOURCE_ATLAS_AUTHORITY_LAW.md`

These are ownership anchors and dependency inputs. They are not evidence that `SourceNeeded` is implemented in app runtime.

## Model Role

`SourceNeeded` keeps the user moving safely when source-backed pathing is unavailable.

Required invariant:

Source-needed is not a dead end and not a fake plan. It must preserve the goal locally, explain the missing source or coverage boundary, provide only safe non-authoritative local support when allowed, create an abstract coverage need candidate when appropriate, and leave a retry/fresh-coverage hook for later phases.

## Required Fields

| Field | Requirement | Red stop |
|---|---|---|
| `scaffoldId` | Stable local scaffold id. | ID includes raw private goal text. |
| `goalIntentGeometryRef` | Local reference to AMB-755 GoalIntentGeometry. | Scaffold bypasses geometry. |
| `operatingMode` | Must be `source_needed`, `coverage_demand`, `partial_source_backed`, `starter_only`, or another mode that explicitly permits source-needed scaffold behavior. | Source-needed behavior appears under fully source-backed mode without proof. |
| `sourceAuthorityRoute` | M06 non-ready route such as source-needed, review-required, stale, revoked, contradicted, jurisdiction-needed, high-risk review, local-only, or blocked. | Non-ready source posture is hidden. |
| `missingEvidenceClass` | Abstract class of missing evidence, source, review, freshness, jurisdiction, compatibility, release receipt, rollback receipt, or pack coverage. | Missing evidence is described as user failure. |
| `userFacingBoundary` | Trust-light explanation that the path is not source-backed yet. | Copy claims full plan, current source, or AI certainty. |
| `localDraftRef` | Local-only preserved goal/draft reference. | Goal is dropped or uploaded. |
| `safeStarterBoundary` | Whether a low-risk starter action, inspection step, or local clarification is allowed. | Starter is labeled source-backed. |
| `allowedLocalOutputs` | Allowed local support outputs. | Scaffold emits authoritative Steps. |
| `blockedOutputs` | Forbidden outputs until source authority passes. | Schedule install or share projection proceeds. |
| `coverageNeedCandidate` | Optional abstract gap candidate for AMB-697. | Raw private goal text becomes coverage demand. |
| `retryTrigger` | Fresh coverage, source review, user clarification, jurisdiction resolution, or source import condition that can reopen routing. | No recovery path exists. |
| `receipt` | Local receipt explaining source-needed route and no-claim boundary. | User cannot inspect why pathing was limited. |
| `privacyClass` | local-only, local-user-context, abstract-gap, or blocked. | R2/public Source Atlas receives private context. |

## Allowed Local Outputs

`SourceNeeded` may produce only these local outputs before later source authority gates pass:

- local draft preservation
- short source-needed explanation
- one safe inspection or clarification prompt when AMB-695 permits it
- optional non-authoritative starter support only when risk, jurisdiction, and source posture permit
- abstract coverage need candidate for AMB-697
- retry/fresh-coverage hook
- receipt and source/settings drill-down link

`SourceNeeded` must not produce:

- source-backed path
- authoritative Recommended step
- schedule install
- share projection
- hard deadline pressure invented by the app
- high-risk procedural guidance
- R2 upload containing raw goal text or private context
- public Source Atlas pack content derived from private user goals

## OperatingMode Linkage

AMB-692 `OperatingMode` controls when this scaffold can appear:

- `source_needed`: required local scaffold.
- `coverage_demand`: required local scaffold plus abstract coverage need candidate.
- `partial_source_backed`: scaffold missing portions while covered portions stay explicitly bounded.
- `starter_only`: may use scaffold boundary copy when source-backed pathing is not claimed.
- `jurisdiction_needed` and `high_risk_guarded`: scaffold can hold locally but must not create ordinary starter outputs unless safety owners allow it.
- `unsupported_but_captured`: may preserve locally but must not claim source-needed coverage exists.
- `unsafe_blocked`: cannot downgrade to source-needed.

## CoverageNeed Linkage

When coverage is missing and safe to record abstractly, `SourceNeeded` may emit a `coverageNeedCandidate` with:

- goal family
- domain
- specific domain when non-identifying
- missing source type
- missing seed family such as starter, proof, elasticity, recovery, jurisdiction, replacement, or high-risk review
- risk/jurisdiction class
- freshness/review class
- blocker reason
- privacy class

Forbidden coverage need material:

- raw private goal text
- exact schedule
- private proof
- personal names
- relationship context
- private location
- sensitive freeform notes
- user identifiers
- secrets or credentials

AMB-696 does not implement `CoverageNeed`; AMB-697 owns the queue model.

## Offline And Bundled Coverage Behavior

Source-needed must remain useful before network fetch, before pack arrival, or when no matching coverage exists:

- Use bundled/local source posture first.
- Show explicit non-authoritative boundary.
- Keep local draft and retry hook.
- Offer safe clarification or inspection only when it can change route readiness.
- Never claim that missing source coverage is current, reviewed, or authoritative.

## Fixture Matrix

AMB-696 defines fixture obligations for later M07 validation:

- source-needed with no matching pack
- source-needed because source is stale
- source-needed because review is missing
- source-needed because jurisdiction is unresolved
- source-needed because high-risk review is missing
- source-needed with safe starter allowed
- source-needed with starter blocked
- partial source-backed with missing coverage slice
- coverage-demand candidate with abstract gap
- unsupported-but-captured without fake source-needed coverage
- unsafe-blocked not downgraded to source-needed
- same-goal/different-person variants that differ by local evidence and source posture

AMB-696 does not create the executable corpus. Later M07 owners must implement it before claiming routing validator Green.

## Red Conditions

- source-needed is a dead end
- unsupported goal gets a fake plan
- source-needed emits authoritative Recommended steps
- schedule install or share projection proceeds from non-ready source posture
- source-needed hides stale, revoked, contradicted, incompatible, jurisdiction-needed, review-needed, high-risk, or local-only source states
- coverage demand leaks sensitive intent or private context
- safe starter is labeled source-backed
- unsafe-blocked is downgraded to source-needed
- private goal text, answer text, proof, schedule, names, location, or sensitive notes leave the local boundary
- fixture/test/generated/preview assets are treated as production runtime proof

## Downstream Consumers

- AMB-697 / PLOS-075 Coverage Demand Queue
- AMB-698 / PLOS-076 optional anonymous abstract coverage request
- AMB-699 / PLOS-077 fresh coverage arrival detection
- AMB-700 / PLOS-078 unsupported/unsafe modes
- AMB-701 / PLOS-079 high-risk guarded routing
- AMB-617 / PLOS-M10 Golden vertical slice runtime consumption
- AMB-619 / PLOS-M12 Multi-Path Lattice
- AMB-620 / PLOS-M13 Step Graph Compiler
- AMB-623 / PLOS-M16 Life Consequence / Cross-Goal Reflow Engine
- AMB-635 / PLOS-M26 certification gauntlets

## Non-Claims

This artifact does not claim app source change, Swift implementation, runtime source-needed UI implementation, runtime classifier implementation, validator automation, executable fixture corpus, runtime path selection, generated Step behavior, source pack creation, R2 write, coverage request transport, runtime eligibility computation, UI implementation, accessibility proof, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, device proof, measured performance proof, security certification, AMB-697/PLOS-075 execution, AMB-617/M10 runtime consumption, AMB-635/M26 production certification, or AMB-615 parent completion.
