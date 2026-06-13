# Unsupported And Unsafe Routing Contract

Status: AMB-700 / PLOS-078 downstream contract
Date: 2026-06-13 America/New_York
Scope: Documentation/control-plane model for unsupported-but-captured and unsafe-blocked Any Goal routing.

This artifact defines the future `UnsupportedButCaptured` and `UnsafeBlocked` routing modes downstream of AMB-692 `OperatingMode`. It prevents two failure modes: unsupported but safe goals becoming fake plans, and unsafe goals being softened into starter/local-only/source-needed routes.

This is not Swift implementation, runtime route selection, runtime storage, executable fixture corpus, routing validator automation, generated Step behavior, UI implementation, privacy/legal approval, release readiness, accessibility proof, device proof, performance proof, or security certification.

## Existing Source Ownership

AMB-700 inspected these existing owners before adding this contract:

- `artifacts/personal-life-os/any-goal/ANY_GOAL_OPERATING_MODE_MODEL.md`
- `artifacts/personal-life-os/any-goal/SOURCE_NEEDED_LOCAL_SCAFFOLD.md`
- `artifacts/personal-life-os/any-goal/COVERAGE_DEMAND_QUEUE_MODEL.md`
- `artifacts/personal-life-os/any-goal/ABSTRACT_COVERAGE_REQUEST_CONTRACT.md`
- `artifacts/personal-life-os/any-goal/FRESH_COVERAGE_ARRIVAL_DETECTION_CONTRACT.md`
- `docs/codex/ANY_GOAL_SOLUTION_LOOP_LAW.md`
- `docs/codex/LOCAL_DATA_CLOUD_BOUNDARY_LAW.md`
- `docs/codex/HIGH_RISK_DOMAIN_SAFETY_LAW.md`
- `artifacts/source-atlas-factory/SOURCE_AUTHORITY_NON_READY_ROUTING.md`

These are ownership anchors and dependency inputs. They are not evidence that unsupported or unsafe routing is implemented in app runtime.

## Mode Precedence

Every Any Goal intake must resolve to an `OperatingMode` before any Step, schedule install, share projection, source-backed path, source-needed scaffold, coverage demand, or abstract request is created.

When multiple modes are possible, use the most restrictive safe route:

1. `unsafe_blocked`
2. `high_risk_guarded`
3. `jurisdiction_needed`
4. `source_needed`, `coverage_demand`, `partial_source_backed`, or `starter_only` only when safety gates allow them
5. `unsupported_but_captured`
6. `local_only_draft`

`unsafe_blocked` outranks all lower routes. It cannot be waived by user urgency, local-only wording, source-needed framing, coverage-demand framing, starter-only framing, or future fresh coverage arrival.

## UnsupportedButCaptured

`UnsupportedButCaptured` is selected when Ambitions cannot currently and safely path the goal, but the intent itself can be preserved locally without operationalizing unsafe behavior.

Required fields:

| Field | Requirement | Red stop |
|---|---|---|
| `captureId` | Stable local-only captured-intent reference. | ID includes raw private text in public/loggable material. |
| `operatingMode` | Must be `unsupported_but_captured`. | Unsupported behavior appears under source-backed, starter-only, or local-only draft without boundary. |
| `unsupportedReasonClass` | Coverage missing, unsupported domain, unsupported capability, unsupported source shape, unsupported timeframe, unsupported interaction model, or unsupported maturity. | Reason is vague or blames the user. |
| `safetyScreenState` | Must show unsafe screen did not require block. | Unsafe content is captured as merely unsupported. |
| `sourceNeededEligibility` | Whether source-needed or coverage-demand is allowed later. | Unsupported mode claims source coverage exists. |
| `allowedLocalOutputs` | Local preservation, honest unsupported boundary, retry/fresh-coverage hook, optional clarification when it can change route. | Emits path, Step list, schedule install, share projection, or source-backed receipt. |
| `blockedOutputs` | Forbidden outputs until future route changes. | Unsupported goal gets a fake plan. |
| `recoveryRoute` | Retry, clarification, coverage arrival, source import, or user-owned deletion/export route. | Dead-end message with no recovery path. |
| `coverageNeedCandidate` | Optional only when abstract and privacy-safe under AMB-697. | Raw private goal or sensitive context becomes coverage demand. |
| `receiptRef` | Local receipt explaining what was captured and what was not claimed. | User cannot inspect why Ambitions did not path the goal. |
| `privacyClass` | `local_private`, `local_abstract`, or `blocked_sensitive` when sensitive. | R2/public Source Atlas receives private user context. |

Allowed outputs:

- local captured-intent preservation
- honest unsupported boundary
- local receipt
- retry/fresh-coverage hook
- optional clarification only if it can change route readiness
- optional abstract CoverageNeed candidate only when AMB-697 privacy gates pass

Forbidden outputs:

- source-backed path
- Recommended step
- Step list
- schedule install
- share projection
- high-risk procedural guidance
- abstract request without AMB-698 consent and redaction gates
- R2/public Source Atlas object derived from raw private goal text

## UnsafeBlocked

`UnsafeBlocked` is selected when the requested goal or requested path is unsafe, disallowed, exploitative, crisis-sensitive, illegal, harmful, evasive, harassing, fraudulent, regulated without safe boundary, or otherwise cannot be supported.

Required fields:

| Field | Requirement | Red stop |
|---|---|---|
| `blockId` | Stable local block receipt reference. | ID leaks private text or user identifier into public/loggable material. |
| `operatingMode` | Must be `unsafe_blocked`. | Unsafe material is routed as unsupported, starter-only, source-needed, coverage-demand, or local-only draft. |
| `blockedReasonClass` | Illegal/harmful, crisis/self-harm, harm-to-others, stalking/harassment, fraud/evasion, dangerous health/fitness, regulated professional domain, minor/student sensitive, privacy-sensitive, source-sensitive, professional boundary, or unsupported unsafe path. | Block reason is hidden or converted to generic unsupported. |
| `nonWaivable` | Always true for unsafe-blocked route. | User can override the block to generate Steps. |
| `safeAlternativeBoundary` | Optional allowed safe support category, such as crisis support, professional-boundary suggestion, or benign adjacent education. | Safe alternative becomes procedural unsafe assistance. |
| `retentionDecision` | Store only safe local receipt or discard unsafe details under future data lifecycle policy. | Unsafe procedural details are preserved as actionable plan content. |
| `blockedOutputs` | Forbidden outputs until a future owner explicitly proves a safer route. | Blocked content produces Step list, schedule install, share projection, source-backed path, or coverage request. |
| `receiptRef` | Local receipt explaining blocked route and no-claim boundary. | Block is invisible or uninspectable. |
| `privacyClass` | `blocked_sensitive` by default. | Private or unsafe context leaves device/R2 boundary. |

Unsafe-blocked may produce only:

- block receipt
- non-procedural safe alternative boundary when allowed
- crisis or professional-boundary route when relevant and future owners implement it
- local retention/delete/export decision hooks

Unsafe-blocked must not produce:

- procedural unsafe help
- source-backed plan
- starter Step
- local-only actionable draft
- source-needed scaffold
- ordinary CoverageNeed
- abstract coverage request
- fresh-coverage route recheck
- schedule install
- share projection

## OperatingMode Linkage

AMB-692 controls both modes:

- `unsupported_but_captured` is for safe local preservation when Ambitions lacks current pathing authority.
- `unsafe_blocked` is a blocking route that outranks unsupported, starter, source-needed, coverage-demand, jurisdiction, and fresh-coverage loops.
- A future runtime may move from unsupported to source-needed, coverage-demand, clarification-needed, starter-only, partial-source-backed, or fully-source-backed only after local re-evaluation and required source/safety gates pass.
- A future runtime may move from unsafe-blocked only after a future safety owner proves the original unsafe request is no longer present or has been reframed into a separate safe intent; it cannot be user-waived in place.

## SourceNeeded, CoverageNeed, And Fresh Coverage Linkage

Unsupported-but-captured may feed AMB-696 `SourceNeeded` or AMB-697 `CoverageNeed` only when all of these are true:

1. The route is not unsafe-blocked.
2. The coverage gap can be abstracted without raw private goal text or sensitive context.
3. The source-needed or coverage-demand path will not imply a source-backed plan.
4. A local receipt records that Ambitions captured an unsupported goal and may retry later.

Fresh coverage arrival from AMB-699 can reopen unsupported routing only as a local route recheck. It cannot unlock unsafe-blocked, high-risk ordinary routing, source-backed pathing, Step generation, or schedule install without the later required source authority and safety gates.

## Fixture Matrix

AMB-700 defines fixture obligations for later M07 validation:

- safe unsupported goal is captured locally without Step generation
- unsupported domain creates honest boundary and retry hook
- unsupported capability does not create fake source-needed coverage
- unsupported timeframe does not invent schedule install
- unsupported interaction model remains local until a future owner adds support
- source-needed eligible unsupported goal can create abstract CoverageNeed only when privacy-safe
- unsupported goal with fresh public coverage rechecks locally before any route change
- unsafe illegal/harmful request blocks non-waivably
- crisis/self-harm request blocks ordinary productivity route and uses crisis/professional-boundary owner when future scoped
- harassment/stalking/fraud/evasion request blocks without local actionable draft
- dangerous health/fitness or regulated professional request does not become starter-only
- minor/student-sensitive unsafe route does not become coverage demand
- same raw goal can be unsupported for one local state and source-needed or starter-only for another only when explicit local evidence and safety/source gates differ
- unsafe-blocked never creates ordinary CoverageNeed, abstract request, fresh coverage recheck, Step, schedule install, or share projection
- raw private goal text, exact schedule, proof, names, relationship context, precise location, identifiers, local learning, support data, logs, and secrets never leave local boundary

AMB-700 does not create the executable 50-goal corpus or routing validator.

## Red Conditions

- unsupported goal gets a fake plan
- unsafe-blocked is waivable
- raw goals go straight to Step lists
- unsafe-blocked downgrades to unsupported-but-captured, source-needed, coverage-demand, starter-only, or local-only draft
- high-risk or jurisdiction-needed material routes as ordinary unsupported without guard
- unsupported capture is a dead end with no recovery route
- coverage demand leaks sensitive intent or private context
- fresh coverage arrival unlocks unsafe or high-risk ordinary routing
- private user data, unsafe procedural details, logs, support bundles, identifiers, secrets, exact schedules, proof, names, relationship context, or local learning leave the local boundary
- fixture/test/generated/preview material is treated as production runtime proof

## Downstream Consumers

- AMB-701 / PLOS-079 high-risk guarded routing
- AMB-617 / PLOS-M10 Golden vertical slice runtime consumption
- AMB-619 / PLOS-M12 Multi-Path Lattice
- AMB-620 / PLOS-M13 Step Graph Compiler
- AMB-623 / PLOS-M16 Life Consequence / Cross-Goal Reflow Engine
- AMB-625 / PLOS-M18 high-risk safety, legality, and jurisdiction
- AMB-635 / PLOS-M26 certification gauntlets

## Non-Claims

This artifact does not claim app source change, Swift/domain implementation, runtime route selection, runtime storage, runtime classifier implementation, routing validator automation, executable fixture corpus, runtime path selection, generated Step behavior, replay implementation, UI implementation, screenshots, accessibility proof, source pack creation, R2 write, coverage request transport, fresh coverage runtime recheck, runtime eligibility computation, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, device proof, measured performance proof, security certification, AMB-701/PLOS-079 execution, AMB-617/M10 runtime consumption, AMB-635/M26 production certification, or AMB-615 parent completion.
