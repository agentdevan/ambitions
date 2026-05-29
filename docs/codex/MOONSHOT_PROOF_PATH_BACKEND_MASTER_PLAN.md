# Moonshot Proof Path Backend Master Plan

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Active planned backend/runtime source plan. Not implementation proof.
Owner: Ambitions local runtime / Private Life Runtime moat.
Primary runnable prompt: `prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md`.
Supersedes as implementation scope: the smaller seed prompt `prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md` when the operator wants the full backend feature installed.

## 0. Purpose

This plan defines the full backend/runtime feature needed for Ambitions to handle life-scale moonshot ambitions with proof honesty.

The canonical stress test is:

```text
User says: I want to be an Olympic swimmer.
Known context: user is 32 and cannot swim.
```

A generic app would create tasks. A generic AI coach would invent a training plan. Ambitions must do something different:

1. Preserve the North Star.
2. Separate the literal dream from the active safe path.
3. Ground the starting position.
4. Produce proof gates before intensity.
5. Pick one Today-ready safe action.
6. Attach source, assumption, and receipt context.
7. Block overclaiming, unsafe planning, hidden mutation, and guarantee language.
8. Adapt through closure and recovery.

This is a moat feature because it proves Ambitions is a local intent-to-day execution engine, not a task list, chatbot, calendar clone, or motivational planner.

## 1. Backend Definition

In this plan, backend means the native local Ambitions backend/runtime layer:

- Swift domain models
- deterministic compiler/evaluator
- local runtime service
- validation gates
- repository/persistence integration where safe
- test fixtures
- proof reports
- runtime seams used by Today, Goals, Capture, Time, and You

Backend does not mean a hosted server, external API, cloud model, analytics system, user-data backend, or network dependency.

## 2. Non-Negotiable Product Laws

The feature must obey these laws:

- Local-first and deterministic by default.
- No hosted AI dependency.
- No chatbot UI.
- No automatic plan mutation.
- No hidden learning.
- No guarantee language.
- No user-facing confidence score.
- No source-sensitive claims without source/review state.
- No unsafe athletic, health, financial, legal, or professional advice.
- No top-level IA change.
- No release/App Store/TestFlight/device-readiness claim.
- North Star is not the same as active plan.
- Proof is evidence, not achievement.
- Receipts are consequence/review paths, not notifications.
- Closure is non-shaming.

## 3. Fully Mature Backend Feature Definition

The feature is mature only when the repo can prove all of these at source/test level:

### 3.1 Raw Intent Intake

The runtime can accept a typed raw ambition input containing:

- raw statement
- known age, if available
- declared starting capability signals
- declared constraints
- available context signals
- source/review state
- privacy/sensitive state
- created timestamp

It must not require natural-language perfection. It must support deterministic keyword/signal recognition for common moonshot classes while preserving unknowns for review.

### 3.2 North Star / Active Path Split

The runtime must output two distinct concepts:

```text
North Star: the literal dream the user stated.
Active Path: the safest currently actionable path supported by starting-position proof.
```

For the golden scenario:

```text
North Star: Olympic swimmer
Active Path: Become a swimmer from zero
```

The validator must reject any result where the literal North Star becomes the active plan without evidence.

### 3.3 Truth State Model

The runtime must classify truth state separately for:

- literal outcome
- active path
- current execution gate
- source requirements
- user review requirements

Expected states include:

- evidenceSupported
- plausibleButUnproven
- moonshotNotEvidenceSupportedYet
- blockedUntilSafetyProof
- sourceNeeded
- needsUserReview
- blocked

For the golden scenario:

```text
literalOutcomeTruth = moonshotNotEvidenceSupportedYet
activePathTruth = plausibleButUnproven
currentExecutionTruth = blockedUntilSafetyProof
```

### 3.4 Proof Ladder

The runtime must create ordered proof gates.

Each gate must include:

- title
- purpose
- required evidence
- missing evidence
- blocked behaviors
- next safe action
- unlocks
- source/review state
- privacy state
- receipt requirements

For the golden scenario, the first gate must be:

```text
Water safety baseline
```

It must block:

- Olympic training plan
- high-volume swim schedule
- elite benchmark comparison
- guarantee language
- unsafe training intensity

### 3.5 Start Here Projection

The runtime must produce a Today-ready candidate that can bridge into the existing Start Here / Today execution models.

For the golden scenario:

```text
Start here: Book adult beginner swim assessment
Estimated duration: 15 minutes
Because: the first proof gate is water safety, not Olympic training volume.
```

The Today-ready candidate must include:

- recommended step
- time estimate and source
- because line
- source/review label
- goal thread / North Star link
- proof gate link
- receipt payload
- closure prompt
- correction controls
- no hidden mutation

### 3.6 Receipt Payload

Every result must include a receipt with:

- what Ambitions preserved
- what Ambitions refused to assume
- why this step is first
- what evidence is missing
- what unlocks next
- what the user can correct
- whether source review is needed
- whether private details are hidden
- whether the result changed plans or only proposed a reviewable candidate

For the golden scenario, the receipt must make this explicit:

```text
Ambitions preserved the Olympic swimmer North Star but did not assume Olympic feasibility yet.
```

### 3.7 Safety / Overclaim Validator

The validator must reject or route review for:

- missing North Star
- missing starting position
- missing active path
- missing first proof gate
- active path not separated from North Star
- literal outcome treated as guaranteed
- training plan before safety proof
- high-volume schedule before beginner proof
- source-sensitive claim without source/review state
- missing receipt
- missing correction controls
- hidden plan mutation
- hidden commitment mutation
- external/server dependency
- exposed confidence score
- punitive closure language
- generic productivity/planner language
- unsafe athletic/health implication

### 3.8 Local Runtime Service

The feature must be exposed through a local service seam.

Preferred names:

```text
MoonshotProofPathRuntime
MoonshotProofPathCompiling
MoonshotProofPathValidator
MoonshotStartHereAdapter
```

The service must be reachable from the local Ambitions runtime without requiring network, hosted AI, or persistence writes during pure compilation.

If a new property is added to `AmbitionsRuntime`, it must have protocol abstraction and tests proving current local runtime capabilities remain local-only.

### 3.9 Persistence / Repository Maturity

A fully mature backend feature should preserve moonshot proof-path state locally when safe.

Implementation order:

1. First, implement pure value models and compiler.
2. Then inspect existing persistence and event/proof ledger records.
3. Prefer existing generic local persistence/receipt/proof structures if they can store the proposal safely.
4. Add new SwiftData schema only if necessary and only with migration, backup, rollback, tests, and implementation truth updates.
5. Never silently write a plan, schedule, commitment, or goal activation from raw input.
6. Store proposals/review candidates only after user review path exists.

If schema migration is not safe in the current batch, report Yellow and keep value-model/service maturity without false persistence claims.

### 3.10 Capture / Goal / Today Integration Maturity

Backend maturity should support these flows as source-level services or tests:

```text
Capture fragment -> Moonshot intake candidate -> reviewed proof path proposal
Goal/North Star -> proof ladder -> active path proposal
Proof path -> Today Start Here candidate
Closure result -> proof path state update candidate
Correction -> future recommendation influence candidate
```

This batch may avoid visible UI changes, but it must shape the backend so the UI can use it without inventing logic in views.

### 3.11 Test Maturity

The feature needs tests across four layers:

1. Domain tests for models and validators.
2. Runtime tests for compilation and local-only boundaries.
3. Bridge tests for Start Here / Living Dream compatibility.
4. Regression tests for bad outputs and anti-patterns.

Mandatory golden tests:

- Olympic swimmer from zero becomes proof-gated path.
- Unsafe Olympic training plan is blocked.
- Guarantee language is blocked.
- Missing starting skill routes to intake review.
- Today bridge compatibility carries receipt/proof/closure/control state.
- Pure compile performs no persistence write, network work, or plan mutation.

### 3.12 Proof Maturity

The batch must produce:

- audit report
- validation command log summary
- implementation truth update
- rollback path
- claim boundary
- next batch recommendation

## 4. Architecture

Preferred backend architecture:

```text
MoonshotAmbitionInput
  -> MoonshotIntentClassifier
  -> MoonshotStartingPositionEvaluator
  -> MoonshotTruthEvaluator
  -> MoonshotProofLadderBuilder
  -> MoonshotStartHereAdapter
  -> MoonshotProofPathValidator
  -> MoonshotProofPathResult
```

### 4.1 MoonshotAmbitionInput

Fields:

```text
id
rawStatement
knownAge
declaredStartingCapabilities
declaredConstraints
availableContextSignals
sourceState
privacyClass
createdAt
```

### 4.2 MoonshotIntentClassifier

Deterministic classification only.

Recognize moonshot signals such as:

```text
Olympic
Olympian
professional athlete
astronaut
doctor from scratch
change careers into regulated field
```

Recognize safety/starting signals such as:

```text
cannot swim
beginner
no experience
injured
no access
no coach
unknown schedule capacity
```

Unknowns must be captured, not guessed.

### 4.3 MoonshotStartingPositionEvaluator

Output:

```text
startingPositionState
knownSignals
unknownSignals
requiredClarifications
safetyReviewNeeded
sourceReviewNeeded
```

For `cannot swim`, it must require a water-safety gate before training intensity.

### 4.4 MoonshotTruthEvaluator

Output truth states for literal outcome, active path, and current gate.

Do not evaluate Olympic eligibility from internet or external sources in this feature. If official eligibility standards are needed, set `sourceNeeded`.

### 4.5 MoonshotProofLadderBuilder

Build ordered gates.

For golden scenario:

1. Water safety baseline.
2. Basic swimming competence.
3. Structured coached practice.
4. First timed competitive signal.
5. Source-reviewed elite-path comparison.

Only gate 1 should be Today-ready at the start.

### 4.6 MoonshotStartHereAdapter

Create a bridgeable Today candidate.

Must include:

```text
title
estimatedMinutes
durationSource
becauseLine
contextEdge
timeFitProof if available
goalThread
proofGateID
receipt
closurePrompt
controlActions
runtimeBoundary
```

### 4.7 MoonshotProofPathValidator

Validate both good and bad outputs.

This validator is the moat guardrail. It must be strict enough that generic goal planning fails.

## 5. Data / Persistence Strategy

Do not start with schema mutation.

Target maturity levels:

### Level A — Pure Value Model Proof

- Domain models exist.
- Runtime compiler exists.
- Golden tests pass.
- No persistence writes.

### Level B — Runtime Service Exposure

- Service is exposed through runtime factory/contract.
- App runtime can call it.
- Tests prove local-only capability.

### Level C — Review Candidate Persistence

- Reviewable candidate can be persisted using existing safe records or new schema.
- Requires migration/rollback tests if schema added.
- Must not activate goals/plans automatically.

### Level D — Cross-Surface Backend Integration

- Capture can produce moonshot intake candidates.
- Goals can show North Star / active path / proof ladder from backend state.
- Today can request Start Here candidate from backend state.
- Closure/correction can feed back as reviewable events.

This full-train prompt should attempt the highest safe level. If Level C/D requires unsafe schema or broad UI, implement Level A/B fully and report the remaining backend integration as explicit Yellow, not Green.

## 6. Golden Scenario Contract

Input:

```text
rawStatement: I want to be an Olympic swimmer.
knownAge: 32
declaredStartingCapabilities: cannot swim
```

Expected output:

```text
northStar.title: Olympic swimmer
activePath.title: Become a swimmer from zero
literalOutcomeTruth: moonshotNotEvidenceSupportedYet
activePathTruth: plausibleButUnproven
currentExecutionTruth: blockedUntilSafetyProof
firstGate.title: Water safety baseline
startHere.title: Book adult beginner swim assessment
startHere.estimatedMinutes: 15
receipt.refusedAssumptions includes Olympic feasibility and training readiness
blockedBehaviors includes Olympic training plan, high-volume swim schedule, elite benchmark comparison
validator issues: []
```

## 7. Negative Fixtures

### 7.1 Fantasy Training Plan

Reject:

```text
Start Olympic training tomorrow.
Swim 5 days per week.
Compare your times to Olympic standards.
```

Expected issues:

```text
unsafeTrainingBeforeSafetyProof
highVolumeScheduleBeforeBeginnerProof
activePathNotSeparatedFromNorthStar or literalOutcomeTreatedAsGuaranteed
```

### 7.2 Guarantee Language

Reject:

```text
You can become an Olympian if you stay consistent.
This is the best possible path.
AI confidence says this will work.
You needs review if you miss this.
```

Expected issues:

```text
guaranteeLanguage
confidenceScoreExposed
punitiveClosureLanguage
harmfulRecommendationLanguage
```

### 7.3 Missing Starting Position

Input lacks skill signal.

Expected:

```text
needsUserReview
unknowns include current skill level
no training plan generated
first step is review/clarification, not workout
```

### 7.4 Source-Sensitive Overclaim

Reject any claim that asserts official Olympic eligibility, qualification timelines, medical safety, or training prescription without source/review state.

Expected:

```text
sourceSensitiveClaimWithoutSource
needsSourceReview
```

## 8. User-Facing Copy Rules

Allowed:

```text
Start here
Recommended step
Proof gate
Water safety baseline
Needs review
Still Counts
Moved
Blocked
Waiting
Needs Recovery
Why this?
Source needs review
Private by default
```

Forbidden:

```text
Recommended step
AI confidence
guaranteed
proof signal
you needs review
needs closure
manifest
coach says
Olympic plan
```

## 9. File Plan

Preferred new files:

```text
Native/Ambitions/Domain/MoonshotProofPathModels.swift
Native/Ambitions/Runtime/MoonshotProofPathRuntime.swift
Native/AmbitionsTests/Runtime/MoonshotProofPathRuntimeTests.swift
docs/audits/moat-moonshot-backend-full-train-01-report.md
```

Potential touched files if needed:

```text
Native/Ambitions/Runtime/AmbitionsRuntimeContracts.swift
Native/Ambitions/Runtime/AmbitionsRuntimeFactory.swift
Native/Ambitions/Runtime/AmbitionsRuntimeGoalIntelligence.swift
Native/Ambitions/Features/Today/TodayExecutionProjector.swift
Native/Ambitions/Features/Today/DayRailViewState.swift
Native/Ambitions/PreviewSupport/PreviewTodayScenarios.swift
Native/AmbitionsTests/Runtime/AmbitionsRuntimeGoalIntelligenceServiceTests.swift
Native/AmbitionsTests/Domain/AmbitionsOSLivingDreamTodayBridgeModelsTests.swift
Native/AmbitionsTests/Today/TodayViewModelTests.swift
docs/truth/IMPLEMENTATION_TRUTH.md
```

Avoid touching broad surface files unless required for compile integration.

## 10. Validation Plan

Run, at minimum:

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/MoonshotProofPathRuntimeTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/AmbitionsRuntimeGoalIntelligenceServiceTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/AmbitionsOSLivingDreamTodayBridgeModelsTests
scripts/build-local.sh
git diff --check
scripts/run-doc-qa.sh || true
scripts/batch-train-gate-check.sh || true
```

If available:

```bash
scripts/cqs-product-drift-scan.sh Native/Ambitions/Domain Native/Ambitions/Runtime Native/AmbitionsTests/Runtime docs/audits/moat-moonshot-backend-full-train-01-report.md || true
scripts/cqs-prompt-built-smell-scan.sh Native/Ambitions/Domain Native/Ambitions/Runtime Native/AmbitionsTests/Runtime || true
scripts/cqs-privacy-security-claim-scan.sh Native/Ambitions/Domain Native/Ambitions/Runtime Native/AmbitionsTests/Runtime docs/audits/moat-moonshot-backend-full-train-01-report.md || true
```

## 11. Claim Boundary

Allowed after successful implementation:

```text
Moonshot proof-path backend value models are source-present.
The Olympic swimmer from zero golden scenario is unit-tested.
The runtime can compile a structured moonshot input into a proof-gated Today-ready candidate without hidden mutation, hosted AI, or server dependency.
```

Forbidden:

```text
Ambitions fully handles all dreams.
Ambitions understands all raw user intent.
Olympic swimmer flow is production-ready.
Moonshot runtime is complete.
Local AI is complete.
Personalized execution engine is complete.
```

## 12. Rollback

Rollback must be a normal commit revert.

No migration, entitlement, route, release, or hosted infrastructure rollback should be needed.

If schema changes are introduced despite preference, rollback must include migration rollback proof and backup/recovery notes.

## 13. Next Batches

If the full backend train succeeds at Level A/B but does not persist or wire Capture/Goals live, run:

```text
MOAT-MOONSHOT-CAPTURE-TO-GOAL-02
```

Purpose:

```text
Wire raw Capture and goal creation review so moonshot proof-path candidates become user-reviewed Goal/North Star proposals without automatic mutation.
```

If persistence is intentionally deferred, run:

```text
MOAT-MOONSHOT-LOCAL-PERSISTENCE-03
```

Purpose:

```text
Persist moonshot proof-path proposals and receipts through existing local storage or a migration-proven SwiftData model.
```

If Today surface wiring is intentionally deferred, run:

```text
MOAT-MOONSHOT-TODAY-START-HERE-04
```

Purpose:

```text
Expose moonshot proof-path Start Here candidates in Today without redesigning Today or adding new routes.
```

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
