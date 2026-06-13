# High-Risk Guarded Routing Contract

Status: AMB-701 / PLOS-079 downstream contract
Date: 2026-06-13 America/New_York
Scope: Documentation/control-plane model for high-risk guarded Any Goal routing.

This artifact defines the future `HighRiskGuardedRouting` mode downstream of AMB-692 `OperatingMode` and AMB-700 `UnsafeBlocked`. It prevents high-risk goals from receiving fake ordinary plans, disclaimer-only handling, source-needed dead ends, privacy-leaking coverage demand, or unsafe downgrade routes.

This is not Swift implementation, runtime route selection, runtime storage, executable fixture corpus, routing validator automation, generated Step behavior, UI implementation, privacy/legal approval, release readiness, accessibility proof, device proof, measured performance proof, security certification, or AMB-615 parent completion.

## Existing Source Ownership

AMB-701 inspected these existing owners before adding this contract:

- `artifacts/personal-life-os/any-goal/ANY_GOAL_OPERATING_MODE_MODEL.md`
- `artifacts/personal-life-os/any-goal/GOAL_INTENT_GEOMETRY_MODEL.md`
- `artifacts/personal-life-os/any-goal/GOAL_SHAPE_FINGERPRINT_MODEL.md`
- `artifacts/personal-life-os/any-goal/SOURCE_NEEDED_LOCAL_SCAFFOLD.md`
- `artifacts/personal-life-os/any-goal/COVERAGE_DEMAND_QUEUE_MODEL.md`
- `artifacts/personal-life-os/any-goal/ABSTRACT_COVERAGE_REQUEST_CONTRACT.md`
- `artifacts/personal-life-os/any-goal/FRESH_COVERAGE_ARRIVAL_DETECTION_CONTRACT.md`
- `artifacts/personal-life-os/any-goal/UNSUPPORTED_UNSAFE_ROUTING_CONTRACT.md`
- `docs/codex/ANY_GOAL_SOLUTION_LOOP_LAW.md`
- `docs/codex/LOCAL_DATA_CLOUD_BOUNDARY_LAW.md`
- `docs/codex/HIGH_RISK_DOMAIN_SAFETY_LAW.md`
- `artifacts/source-atlas-factory/SOURCE_ATLAS_RISK_JURISDICTION_CLASSIFICATION.md`
- `artifacts/source-atlas-factory/SOURCE_AUTHORITY_NON_READY_ROUTING.md`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSafetyTriageModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamHandlingModels.swift`
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/SourceAtlasIntentMatchModels.swift`

These are ownership anchors and dependency inputs. They are not evidence that high-risk guarded routing is implemented in app runtime.

## Mode Precedence

Every Any Goal intake must resolve to an `OperatingMode` before any Step, schedule install, share projection, source-backed path, source-needed scaffold, coverage demand, abstract request, or fresh coverage recheck is created.

When multiple modes are possible, use the most restrictive safe route:

1. `unsafe_blocked`
2. `high_risk_guarded`
3. `jurisdiction_needed`
4. `source_needed`, `coverage_demand`, `partial_source_backed`, or `starter_only` only when high-risk gates allow them
5. `unsupported_but_captured`
6. `local_only_draft`

`high_risk_guarded` is not a waiver, a disclaimer, or a temporary warning that permits ordinary pathing. It is selected when the goal may have a safe bounded route only after source authority, jurisdiction, review, privacy, professional-boundary, and unsafe-blocked checks pass.

## HighRiskGuardedRouting

`HighRiskGuardedRouting` is selected when the goal touches a domain or requested path that can materially affect health, legal standing, money, safety, regulated goods, minors/students, employment/education eligibility, immigration/civic obligations, privacy-sensitive parties, or another person's safety or rights.

Required fields:

| Field | Requirement | Red stop |
|---|---|---|
| `guardId` | Stable local guarded-route receipt reference. | ID leaks raw private text, user identity, precise location, or sensitive facts into public/loggable material. |
| `operatingMode` | Must be `high_risk_guarded`. | High-risk content appears under source-backed, starter-only, source-needed, coverage-demand, unsupported, or local-only draft without guard. |
| `riskClass` | Medical/health, legal/civic, financial, crisis/safety, regulated goods, cannabis, minors/students, sensitive private, immigration, education/certification eligibility, employment, housing, harassment/stalking/fraud/evasion, harm-to-others, dangerous fitness/recovery, deadline-sensitive, or unknown risk. | Risk class is missing, downgraded to generic productivity, or hidden behind disclaimer copy. |
| `reviewRequirement` | Required source review, human/professional review, jurisdiction review, freshness review, or future safety-owner review. | High-risk route proceeds with no review requirement. |
| `jurisdictionRequirement` | Required when law, civic, immigration, regulated goods, benefits, education, licensing, medical scope, or local safety rules could change by place. | Jurisdiction-sensitive route assumes a generic answer. |
| `sourceAuthorityRequirement` | Required source, freshness, revocation, contradiction, release receipt, rollback, and applicability posture before any source-backed output. | Missing, stale, unreviewed, revoked, contradicted, incompatible, or source-needed material drives Steps. |
| `professionalBoundaryState` | Whether the route must remain educational/supportive, refer to professional judgment, or block advice. | Ambitions gives medical/legal/financial/professional instructions as personal advice. |
| `unsafeBlockedEscalation` | Explicit link to AMB-700 `UnsafeBlocked` when requested action is unsafe, illegal, exploitative, evasive, crisis-sensitive, or harmful. | Unsafe content remains merely high-risk guarded. |
| `allowedGuardedOutputs` | Guarded hold, source-needed/review-required/jurisdiction-needed explanation, non-procedural education/support, minimal route-changing clarification, local receipt, or privacy-safe abstract CoverageNeed only when allowed. | Emits Recommended step, Step list, schedule install, share projection, or authoritative instructions before gates pass. |
| `blockedOutputs` | Forbidden outputs until future source/review/jurisdiction/safety gates pass. | Guarded route creates ordinary pathing by adding disclaimer text. |
| `coverageNeedEligibility` | Only abstract high-risk review/source/jurisdiction/freshness gap when privacy-safe and not unsafe. | Raw private goal or sensitive facts become CoverageNeed, abstract request, R2 object, Linear text, or public Source Atlas material. |
| `privacyClass` | `local_private`, `high_risk_review_only`, `blocked_sensitive`, or `remote_abstract_allowed` only after AMB-698 consent/redaction gates. | Sensitive high-risk intent leaves the local boundary. |
| `receiptRef` | Local receipt explaining high-risk boundary, missing evidence, blocked outputs, and recovery route. | User cannot inspect why Ambitions did not path the goal. |
| `retentionProjectionState` | Store minimal safe route state, redact details, discard unsafe detail, or require future delete/export hook. | Sensitive or unsafe procedural details are preserved as plan content or public evidence. |

## Risk Classes

High-risk guarded routing applies to at least these classes:

- health, medical, medication, treatment, diagnosis, recovery, dangerous fitness, nutrition under medical conditions, or clinical decisions
- legal, civic, immigration, benefits, licensing, taxes, contracts, tenant/landlord, employment rights, or deadline-sensitive compliance
- financial, investing, debt, insurance, tax, benefits, loans, gambling, or irreversible money movement
- crisis, self-harm, harm to others, violence, abuse, coercion, exploitation, or urgent safety
- regulated goods and activities, including cannabis, weapons, controlled substances, age-restricted goods, and unsafe operational instructions
- minors, students, education eligibility, certification, accommodations, discipline, admissions, or safeguarding
- stalking, harassment, fraud, evasion, surveillance, impersonation, manipulation, or bypassing rules
- sensitive private third-party facts, exact locations, relationship context, protected-class data, identity documents, health records, finances, or support notes
- unknown-risk domains where the route cannot prove low risk from current local evidence

## Allowed Outputs

High-risk guarded may produce only:

- guarded hold with clear local receipt
- source-needed, review-required, jurisdiction-needed, or professional-boundary explanation
- non-procedural safe education or support when the active safety law allows it
- minimal clarification only when the answer can change safety, jurisdiction, source, review, or route eligibility
- local-only non-actionable draft framing when it cannot be mistaken for advice, instruction, Step, schedule, or share projection
- privacy-safe abstract CoverageNeed for high-risk review/source/jurisdiction/freshness gap only when AMB-697 gates pass
- optional abstract request only after AMB-698 consent/redaction gates and only when the gap is reusable public coverage, not private personal planning

## Blocked Outputs

High-risk guarded must not produce:

- authoritative medical, legal, financial, civic, immigration, regulated, or safety advice
- instructions that enable self-harm, harm to others, evasion, fraud, harassment, stalking, violence, exploitation, illegal activity, or unsafe operational behavior
- crisis-to-productivity route, ordinary habit/productivity plan, or shame/streak framing
- Recommended step, Step list, schedule install, share projection, or source-backed path before source/review/jurisdiction/safety gates pass
- disclaimer-only route that still performs ordinary pathing
- abstract request containing raw private goal text, exact schedule, names, relationship context, health/legal/financial facts, precise location, identifiers, proof, support data, logs, or secrets
- R2/public Source Atlas object, Linear comment, public log, or support artifact containing private high-risk intent

## UnsafeBlocked Linkage

AMB-700 `UnsafeBlocked` outranks high-risk guarded. The route must escalate to `unsafe_blocked` or future crisis/professional-boundary owner when the request involves:

- self-harm, crisis, violence, harm to others, abuse, coercion, exploitation, or urgent danger
- stalking, harassment, doxxing, evasion, fraud, impersonation, theft, surveillance abuse, or bypassing rules
- illegal or harmful regulated-goods handling
- medical/legal/financial instructions that would be dangerous without professional review
- requests to hide, delete, falsify, or evade evidence, safeguards, supervision, law, or platform rules
- any route where the safe alternative would become procedural assistance for unsafe behavior

If escalated to `unsafe_blocked`, the route cannot create ordinary CoverageNeed, abstract request, source-needed scaffold, fresh coverage recheck, local-only actionable draft, Step, schedule install, or share projection.

## CoverageNeed, Source, And Privacy Linkage

High-risk guarded may create AMB-697 `CoverageNeed` only when all are true:

1. The route is not unsafe-blocked.
2. The gap can be expressed as abstract reusable coverage, such as high-risk review, jurisdiction review, source freshness, source review, compatibility, rollback, release receipt, or professional-boundary category.
3. The record contains no raw private goal text, exact schedule, proof, names, relationship context, health/legal/financial facts, precise location, identifiers, local learning, support data, logs, or secrets.
4. The receipt says the user has not received a source-backed path, Step, schedule install, share projection, professional advice, or high-risk approval.
5. Any remote abstract request waits for AMB-698 consent/redaction gates and is blocked for sensitive or private facts.

Fresh coverage arrival from AMB-699 can reopen high-risk guarded only as a local route recheck. It cannot unlock ordinary routing until source authority, review, jurisdiction, freshness, release receipt, rollback, compatibility, privacy, and unsafe-blocked checks pass again.

## Fixture Matrix

AMB-701 defines fixture obligations for later M07 validation:

- high-risk health goal without reviewed source routes to guarded hold, not Step list
- high-risk legal/civic goal with jurisdiction gap routes to jurisdiction-needed
- high-risk financial goal with stale or unreviewed source routes to review-required/source-needed
- regulated goods/cannabis route blocks operational instructions unless a future owner proves lawful bounded education path
- crisis/self-harm goal escalates away from ordinary productivity and does not generate Steps
- stalking/harassment/fraud/evasion/harm-to-others goal escalates to unsafe-blocked
- minor/student-sensitive route stays local-private and cannot create ordinary coverage demand
- same raw goal can be low-risk for one user state and guarded for another only when explicit local evidence differs
- fresh coverage candidate rechecks locally and remains guarded until all gates pass
- abstract high-risk review CoverageNeed contains only reusable safe gap fields
- private high-risk details never enter R2, public Source Atlas, Linear, logs, screenshots, support bundles, or public artifacts
- disclaimer-only ordinary pathing is Red

AMB-701 does not create the executable 50-goal corpus or routing validator.

## Red Conditions

- high-risk goal gets fake ordinary plan
- disclaimer-only route still emits Step, schedule, share, or source-backed path
- source-needed or coverage-demand becomes a dead end with no receipt/recovery route
- unsafe request remains high-risk guarded instead of unsafe-blocked
- jurisdiction-sensitive route assumes generic global advice
- professional advice is provided without source/review/jurisdiction/professional boundary proof
- crisis or harm request routes to productivity
- high-risk route leaks sensitive intent into CoverageNeed, abstract request, R2, public Source Atlas, Linear, logs, screenshots, support bundles, or public artifacts
- fresh coverage arrival unlocks ordinary high-risk routing without full gate recheck
- fixture/test/generated/preview material is treated as production runtime proof

## Downstream Consumers

- AMB-617 / PLOS-M10 Golden vertical slice runtime consumption
- AMB-619 / PLOS-M12 Multi-Path Lattice
- AMB-620 / PLOS-M13 Step Graph Compiler
- AMB-623 / PLOS-M16 Life Consequence / Cross-Goal Reflow Engine
- AMB-625 / PLOS-M18 high-risk safety, legality, and jurisdiction
- AMB-635 / PLOS-M26 certification gauntlets

## Non-Claims

This artifact does not claim app source change, Swift/domain implementation, runtime route selection, runtime storage, runtime classifier implementation, routing validator automation, executable fixture corpus, runtime path selection, generated Step behavior, replay implementation, UI implementation, screenshots, accessibility proof, source pack creation, R2 write, coverage request transport, fresh coverage runtime recheck, runtime eligibility computation, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, device proof, measured performance proof, security certification, AMB-617/M10 runtime consumption, AMB-625/M18 completion, AMB-635/M26 production certification, or AMB-615 parent completion.
