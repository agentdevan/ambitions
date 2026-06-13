# Any Goal Operating Mode Model

Status: AMB-692 / PLOS-070 downstream contract
Date: 2026-06-13 America/New_York
Scope: Documentation/control-plane model for Any Goal routing modes.

This artifact defines the first M07 gate: every raw goal intake must resolve to an explicit `OperatingMode` before any later phase may compile a path, propose a Recommended step, create a coverage demand, ask clarification, or block unsafe routing.

This is not Swift implementation, classifier implementation, validator automation, runtime pathing, UI, R2 transport, source pack release, privacy/legal approval, release readiness, accessibility proof, device proof, performance proof, or security certification.

## Existing Source Ownership

AMB-692 inspected these existing owners before adding this contract:

- `docs/codex/ANY_GOAL_SOLUTION_LOOP_LAW.md`
- `Native/Ambitions/Domain/SourceAtlasIntentMatchModels.swift`
- `Native/Ambitions/Domain/GoalEngine/GoalUnderstandingModels.swift`
- `Native/Ambitions/Domain/GoalEngine/GoalClarificationModels.swift`
- `Native/Ambitions/Services/GoalUnderstandingService.swift`
- `Native/Ambitions/Services/GoalClarificationService.swift`
- `artifacts/source-atlas-factory/SOURCE_AUTHORITY_INTERNAL_STATE_MACHINE.md`
- `artifacts/source-atlas-factory/SOURCE_AUTHORITY_USER_FACING_STATE_MODEL.md`
- `artifacts/source-atlas-factory/SOURCE_AUTHORITY_APPLICABILITY_ENVELOPE.md`
- `artifacts/source-atlas-factory/SOURCE_AUTHORITY_NON_READY_ROUTING.md`
- `artifacts/source-atlas-factory/SOURCE_AUTHORITY_VALIDATION_GAUNTLET.md`

These are ownership anchors and dependency inputs. They are not evidence that the new `OperatingMode` model is already implemented in app runtime.

## Model

`OperatingMode` is the required top-level routing result for Any Goal intake.

Required fields:

- `id`: stable enum id.
- `userState`: trust-light state label for later UI compression.
- `entryCriteria`: required conditions before the mode can be selected.
- `allowedOutputs`: what the runtime may produce in that mode.
- `blockedOutputs`: outputs that are forbidden in that mode.
- `sourceAuthorityRequirement`: how the mode consumes M06 Source Authority.
- `goalStateAssessmentRequirement`: required GoalStateAssessment inputs.
- `sourceNeededScaffold`: whether a local source-needed scaffold is required.
- `unsafeBlockedRoute`: whether unsafe-blocked handling is required.
- `coverageDemandAllowed`: whether abstract coverage demand may be recorded.
- `privacyClass`: default privacy boundary.
- `futureOwners`: later PLOS issue owners for implementation, fixtures, or validation.

## Operating Modes

| Mode | Entry criteria | Allowed outputs | Red stop |
|---|---|---|---|
| `fully_source_backed` | Source Authority is ready; coverage, freshness, review, jurisdiction, risk, release receipt, rollback, privacy, compatibility, and Step Quality preflight evidence are present. | Source-backed path options, candidate Steps, receipts, replay fingerprint, and source trace. | Any missing evidence is treated as Green. |
| `partial_source_backed` | Some coverage is ready but gaps remain. | Covered path slices plus explicit missing coverage/source gaps. | Partial coverage is presented as complete. |
| `starter_only` | Low-risk local starter guidance is safe while source authority is incomplete. | One or more non-authoritative starter steps with explicit boundary. | Starter step is labeled source-backed. |
| `clarification_needed` | Goal is ambiguous or feasibility-critical context is missing. | Minimal clarification prompt set and local draft preservation. | Questions are excessive or pathing guesses through ambiguity. |
| `source_needed` | Goal family is understood but source coverage is missing, stale, contradicted, revoked, incompatible, or review-needed. | Local source-needed scaffold, coverage gap record, and non-authoritative next inspection step. | Dead-end message or fake authoritative path. |
| `coverage_demand` | A reusable seed or pack gap blocks safe routing. | Local abstract `CoverageNeed` and optional consented abstract coverage request. | Raw private goal text or personal context leaves the device/R2 boundary. |
| `jurisdiction_needed` | Goal depends on law, age, location, school, employer, travel, medical, financial, or regulated rule context. | Jurisdiction prompt or guarded hold. | Universal recommendation ignores jurisdiction. |
| `high_risk_guarded` | Goal may affect safety, health, legal, financial, crisis, minors, regulated activity, or irreversible consequences. | Guarded routing, source/review requirement, narrowed safe support, or block. | Ordinary productivity pathing is allowed. |
| `local_only_draft` | User can preserve intent locally while routing remains unready. | Local draft, receipt, later clarification/retry hook. | Draft implies executable plan. |
| `unsupported_but_captured` | Ambitions cannot currently path the goal, but safe local capture is allowed. | Honest unsupported label, local preservation, recovery route. | Dead end with no recovery route. |
| `unsafe_blocked` | Requested goal/path is unsafe or disallowed. | Block unsafe path, preserve only safe local note if appropriate, no procedural help. | Unsafe content becomes unsupported-but-captured or starter-only. |
| `maintenance` | Goal is ongoing upkeep, review, relapse prevention, or lightweight continuity. | Maintenance cadence draft, proof/review prompt, source check. | Treated as a one-time checklist. |
| `decision` | Goal is a consequential choice needing options, tradeoffs, reversibility, or definition of done. | Decision frame, values/tradeoff prompt, regret/reversibility check. | Decision is converted directly into Step list. |
| `collaborative_dependency_heavy` | Goal depends materially on other people, handoffs, approvals, or shared constraints. | Dependency map, collaborator assumptions, communication/proof prompts. | Collaboration is ignored as a private solo task. |
| `expert_tracking` | Local evidence supports expert/practiced state and tracking cadence. | Advanced tracking frame, proof cadence, source refresh checks. | Expert status inferred without local evidence. |
| `beginner_guided` | Local evidence supports beginner/low-confidence state or user asks for guidance. | Guided starter scaffold, smaller steps, clarification-light support. | Beginner status is assumed for everyone. |

## GoalStateAssessment Linkage

`GoalStateAssessment` is the future upstream input that must answer:

- goal state: new, active, paused, recurring, maintenance, decision, collaborative, blocked, unsafe, or unsupported
- ambiguity: domain, scope, timeline, success definition, ownership, resources, or risk
- deadline semantics: hard deadline, target date, season, rolling window, no-date exploration
- definition of done: explicit, inferred, missing, or unsafe to infer
- consequence posture: reversible, costly-to-reverse, irreversible, high-risk
- local capability posture: unknown, beginner, guided, practiced, expert-tracking, collaborative-supported
- source posture: ready, partial, source-needed, review-needed, stale, revoked, contradicted, jurisdiction-needed, blocked

No operating mode may bypass GoalStateAssessment once M07 implementation owners add it.

## SourceNeeded Scaffold Linkage

When `source_needed` or `coverage_demand` is selected, the future `SourceNeeded` scaffold must include:

- local draft preservation
- reason the source is needed
- current missing evidence class
- safe starter boundary, if any
- coverage gap id, if any
- no-authoritative-step flag
- retry/fresh-coverage trigger
- receipt and privacy boundary

Source-needed mode must stay useful, but it cannot become a fake plan.

## UnsafeBlocked Linkage

`unsafe_blocked` must be selected when the requested goal or requested path requires refusal or strict guarding. Required outputs:

- blocked reason class
- safe alternative boundary, if allowed
- crisis/escalation boundary where relevant
- no procedural unsafe assistance
- local retention decision
- receipt that the route was blocked

Unsafe-blocked is not a harsher form of source-needed; it outranks source, coverage, and starter routing.

## Fixture Corpus Linkage

AMB-692 defines the mode coverage obligations for the later 50-goal M07 fixture corpus:

- at least 50 raw goal fixtures
- every operating mode above represented at least twice
- at least five same-goal/different-person fixture families
- beginner/guided/practiced/expert/collaborative local-state variants
- high-risk, jurisdiction-needed, source-needed, coverage-demand, unsupported, and unsafe-blocked variants
- proof that the same raw goal can route differently based on explicit local evidence
- proof that raw private goal text is not emitted in abstract coverage requests

AMB-692 does not create the full executable corpus. Later M07 owners must implement it before claiming routing validator Green.

## Red Conditions

- raw goal text goes directly to a Step list before `OperatingMode`
- unsupported goal gets a fake plan
- source-needed is a dead end
- clarification asks more than the smallest valuable question set
- coverage demand leaks sensitive intent or personal context
- same raw goal always produces the same route regardless of local user state
- high-risk or unsafe material routes as ordinary starter/local-only
- beginner or expert status is inferred without local evidence
- production R2 or runtime eligibility is claimed from this contract alone

## Downstream Consumers

- AMB-755 / PLOS-071 `GoalIntentGeometry`
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

This artifact does not claim app source change, Swift implementation, classifier implementation, validator automation, executable fixture corpus, runtime path selection, generated Step behavior, source pack creation, R2 write, coverage request transport, runtime eligibility, UI implementation, accessibility proof, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, device proof, measured performance proof, security certification, AMB-693/AMB-755 execution, or AMB-615 parent completion.
