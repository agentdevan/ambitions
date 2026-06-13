# Clarification Engine Model

Status: AMB-695 / PLOS-073 downstream contract
Date: 2026-06-13 America/New_York
Scope: Documentation/control-plane model for Any Goal clarification ranking and stopping behavior.

This artifact defines `ClarificationQuestion` and `ClarificationValueRanker`, the required contract between Goal Understanding, GoalStateAssessment, AMB-692 `OperatingMode`, AMB-755 `GoalIntentGeometry`, AMB-694 `GoalShapeFingerprint`, and later source-needed, coverage-demand, pathing, Step compilation, and replay owners.

This is not Swift implementation, prompt UI implementation, runtime classifier implementation, validator automation, executable 50-goal fixture corpus, generated Step behavior, source pack content, R2 transport, privacy/legal approval, release readiness, accessibility proof, device proof, performance proof, or security certification.

## Existing Source Ownership

AMB-695 inspected these existing owners before adding this contract:

- `Native/Ambitions/Domain/GoalEngine/GoalClarificationModels.swift`
- `Native/Ambitions/Services/GoalClarificationService.swift`
- `Native/Ambitions/Domain/GoalEngine/GoalUnderstandingModels.swift`
- `Native/Ambitions/Services/GoalUnderstandingService.swift`
- `Native/Ambitions/Domain/GoalEngine/GoalEngineContracts.swift`
- `Native/Ambitions/Services/GoalContradictionService.swift`
- `artifacts/personal-life-os/any-goal/ANY_GOAL_OPERATING_MODE_MODEL.md`
- `artifacts/personal-life-os/any-goal/GOAL_INTENT_GEOMETRY_MODEL.md`
- `artifacts/personal-life-os/any-goal/GOAL_SHAPE_FINGERPRINT_MODEL.md`
- `docs/codex/ANY_GOAL_SOLUTION_LOOP_LAW.md`

These are ownership anchors and dependency inputs. They are not evidence that this AMB-695 ranking contract is already implemented in app runtime.

## Model Role

The clarification engine decides whether Ambitions should ask a user a question before later pathing, what the smallest useful question is, and when to stop asking.

Required invariant:

Raw goal intake must not go directly to Step lists. If a goal has ambiguity, missing feasibility context, source posture gaps, jurisdiction risk, consequence uncertainty, or an unclear definition of done, the engine must either ask the smallest valuable clarification, safely proceed with explicit assumptions, hold as local-only draft, route to source-needed, or block unsafe pathing.

## ClarificationQuestion Contract

Required fields:

| Field | Requirement | Red stop |
|---|---|---|
| `questionId` | Stable local id for the question contract. | ID includes raw private goal text. |
| `prompt` | Short, non-shaming user-facing question. | Prompt uses guilt, urgency, scoring, or interrogation tone. |
| `targetField` | Field the answer resolves, such as goal subject, scope, success definition, deadline semantics, ownership, resources, jurisdiction, risk, source need, or definition of done. | Question has no decision value. |
| `ambiguityTypes` | Ambiguities addressed by the question. | Ambiguity remains implicit. |
| `valueDimensions` | Ranking dimensions this question improves. | Ranking cannot explain why the question is asked. |
| `blocking` | Whether path compilation must wait. | Blocking ambiguity still generates Steps. |
| `answerEffect` | How the answer may change operating mode, geometry, fingerprint, source posture, scope, outcome, or safety route. | Answer cannot alter routing. |
| `safeSkipDefault` | Explicit default if the question can be skipped. | Skipping silently invents a plan. |
| `privacyClass` | local-only, local-user-context, abstract-gap, or blocked. | Question answer is eligible for R2 or public Source Atlas material. |
| `receipt` | Local audit metadata for why it was asked or skipped. | No local trace for the clarification decision. |

## ClarificationValueRanker Contract

`ClarificationValueRanker` chooses the smallest question set that unlocks safe routing.

Ranking dimensions:

- `unblocksOperatingMode`: answer can select or change AMB-692 OperatingMode.
- `tightensFeasibility`: answer changes scope, resources, constraints, or capacity fit.
- `establishesDefinitionOfDone`: answer prevents later steps from inventing completion criteria.
- `resolvesDeadlineSemantics`: answer distinguishes hard deadline, target date, season, rolling window, no-date exploration, or recurring maintenance.
- `negotiatesScopeOutcome`: answer can narrow, stage, choose fallback outcomes, or mark non-goals.
- `clarifiesOwnership`: answer distinguishes self, delegated, support, collaborator, caregiver, or observed-only execution.
- `reducesRiskJurisdiction`: answer affects safety, legal, medical, financial, school, age, travel, regulated, or irreversible consequence posture.
- `resolvesSourceNeed`: answer determines whether source-needed, coverage-demand, review-needed, partial-source, or local-only routing applies.
- `preservesPrivacyBoundary`: answer can be kept local and must not become public Source Atlas or R2 material.

The ranker must prefer one high-value question over a broad intake survey. It may ask more than one question only when independent blocking fields remain after ranking.

## Minimal Question Budget

Default budget:

- Ask at most one blocking question before the first safe route when a single answer can unblock routing.
- Ask at most two questions when deadline semantics and definition of done are both blocking and independent.
- Ask at most three questions only for high-risk, jurisdiction, delegated/collaborative, or materially consequential decisions where safety depends on distinct answers.
- Do not ask informational questions before preserving the goal locally.
- Do not keep asking after the next answer cannot change OperatingMode, GoalIntentGeometry, GoalShapeFingerprint inputs, Source Authority posture, source-needed scaffold, coverage need, or unsafe/high-risk route.

## Output States

The engine must produce one of these outputs:

- `ask`: ask the selected minimal question set.
- `skip_with_assumption`: proceed only with explicit safe defaults and local receipt.
- `hold_local_draft`: preserve the goal locally without compiling a path.
- `source_needed`: route to source-needed scaffold when ambiguity is really a source coverage gap.
- `coverage_demand_candidate`: create only an abstract local gap candidate, not raw private goal text.
- `jurisdiction_needed`: request jurisdiction context or guarded review.
- `unsafe_blocked`: block unsafe pathing and avoid procedural help.

## GoalStateAssessment Linkage

Clarification consumes GoalStateAssessment for:

- goal state: new, active, paused, recurring, maintenance, decision, collaborative, blocked, unsafe, unsupported
- ambiguity: domain, scope, timeline, success definition, ownership, resources, source, risk, jurisdiction
- deadline semantics: hard deadline, target date, season, rolling window, no-date exploration, recurring maintenance, unknown
- scope and outcome structure: narrowed, staged, fallback outcome, good-enough, preferred, stretch, explicit non-goal
- definition of done: explicit, inferred with safe default, missing, unsafe to infer
- consequence posture: reversible, costly-to-reverse, irreversible, high-risk

Clarification can change OperatingMode, GoalIntentGeometry, GoalShapeFingerprint inputs, and downstream source-needed or coverage-demand routing. If a clarification answer cannot change any downstream route, it should not be asked before the first safe local route.

## GoalIntentGeometry And Fingerprint Linkage

Clarification can update only privacy-bounded geometry fields:

- domain or specific domain
- goal state
- deadline semantics
- ambiguity state
- risk or jurisdiction posture
- source posture
- capability context branch when explicit user answer changes local evidence
- operating mode
- privacy class

Clarification answers must not become public Source Atlas, R2, Linear, coverage request, or fingerprint material as raw private text. AMB-694 fingerprints may consume only the resulting canonical fields and local version pointers, not the answer text itself.

## Fixture Corpus Linkage

AMB-695 defines clarification obligations for the later M07 fixture corpus:

- at least 50 raw goal fixtures
- every AMB-692 operating mode represented at least twice
- at least five same-goal/different-person fixture families
- clarification-needed, source-needed, jurisdiction-needed, high-risk guarded, collaborative, decision, beginner-guided, expert-tracking, unsupported, and unsafe-blocked variants
- proof that the same raw goal can ask different questions or skip questions based on explicit local evidence
- proof that the ranker does not ask excessive questions
- proof that answers change route/fingerprint/geometry only through privacy-bounded canonical fields

AMB-695 does not create the executable corpus. Later M07 owners must implement it before claiming routing validator Green.

## Red Conditions

- raw goal text goes directly to a Step list
- clarification asks broad intake questions before choosing the smallest valuable question
- question set exceeds the minimal budget without high-risk, jurisdiction, delegated/collaborative, or consequential-decision justification
- clarification cannot change operating mode, source posture, geometry, fingerprint inputs, scope, outcome structure, or definition of done
- deadline semantics treat a hard deadline and aspiration date the same
- definition of done is invented after Steps are generated
- source-needed or coverage gaps are treated as user ambiguity and solved by guessing
- high-risk or jurisdiction gaps route as ordinary productivity questions
- unsupported goals receive fake plans
- raw private goal text, private answers, personal names, proof, schedules, or sensitive freeform notes leave the local boundary

## Downstream Consumers

- AMB-696 / PLOS-074 source-needed local scaffold
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

This artifact does not claim app source change, Swift implementation, prompt UI implementation, runtime classifier implementation, validator automation, executable fixture corpus, runtime path selection, generated Step behavior, source pack creation, R2 write, coverage request transport, runtime eligibility computation, UI implementation, accessibility proof, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, device proof, measured performance proof, security certification, AMB-696/PLOS-074 execution, AMB-617/M10 runtime consumption, AMB-635/M26 production certification, or AMB-615 parent completion.
