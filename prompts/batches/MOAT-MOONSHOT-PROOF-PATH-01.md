<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# MOAT-MOONSHOT-PROOF-PATH-01 — Local Proof-Gated Moonshot Runtime

## Batch ID

`MOAT-MOONSHOT-PROOF-PATH-01`

## Runner Command

```bash
scripts/ambitions-codex-train.sh MOAT-MOONSHOT-PROOF-PATH-01 prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md
```

Equivalent:

```bash
make batch BATCH=MOAT-MOONSHOT-PROOF-PATH-01 PROMPT=prompts/batches/MOAT-MOONSHOT-PROOF-PATH-01.md
```

## Objective

Install a deterministic, local-first, proof-gated runtime slice proving Ambitions can convert a raw life-scale moonshot ambition into a grounded, inspectable, receipt-backed, Today-ready execution path without fantasy planning, guarantee language, hosted AI, hidden mutation, unsafe recommendations, or source-sensitive overclaiming.

This batch must prove the moat:

> Ambitions converts user intent into personalized, inspectable, capacity-aware daily execution through local proof, truth state, review gates, closure, and recovery.

Primary golden scenario:

```text
User intent:
“I want to be an Olympic swimmer.”

Known starting context:
- user is 32
- user cannot swim

Expected Ambitions behavior:
- preserve the North Star without dismissing it
- separate literal North Star from active safe path
- mark literal Olympic outcome as not evidence-supported yet
- detect that the first job is not training, but proof
- create a first proof gate around water safety / beginner swim assessment
- create a Today-ready Start Here candidate: “Book adult beginner swim assessment”
- attach a receipt explaining why this is first, what evidence is missing, and what unlocks next
- block Olympic training plans, guarantee language, high-volume schedules, and elite benchmark comparisons until safety and skill proof exist
```

## Product Standard

This must feel like Ambitions, not a generic goal planner.

The runtime must preserve:

- native iPhone-first product posture
- local-first / deterministic runtime behavior
- no external LLM dependency
- no chatbot surface
- proof before plan intensity
- source/review boundaries before source-sensitive claims
- North Star preservation without false promise
- non-shaming closure and recovery
- inspectable receipts
- user-correctable assumptions
- no automatic plan mutation

## Active Source Truth To Inspect

Inspect these before editing:

```text
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/CODEX_PROCESS_TRUTH.md

docs/canon/Ambitions_Intelligence_Runtime.md
docs/canon/AmbitionsOS_Runtime_Contract.md
docs/canon/Ambitions_Found_Life_Layer.md

Native/Ambitions/Runtime/AmbitionsRuntimeContracts.swift
Native/Ambitions/Runtime/AmbitionsRuntimeFactory.swift
Native/Ambitions/Runtime/AmbitionsRuntimeGoalIntelligence.swift

Native/Ambitions/Domain/AmbitionsOSLivingDreamStartingPositionPrivacyIntakeModels.swift
Native/Ambitions/Domain/AmbitionsOSLivingDreamPathPortfolioModels.swift
Native/Ambitions/Domain/AmbitionsOSLivingDreamCapacityBridgeModels.swift
Native/Ambitions/Domain/AmbitionsOSLivingDreamTodayBridgeModels.swift
Native/Ambitions/Domain/AmbitionsOSRecommendationStartHereModels.swift

Native/Ambitions/Features/Today/TodayExecutionProjector.swift
Native/Ambitions/Features/Today/DayRailViewState.swift
Native/Ambitions/PreviewSupport/PreviewTodayScenarios.swift

Native/AmbitionsTests/Runtime/AmbitionsRuntimeGoalIntelligenceServiceTests.swift
Native/AmbitionsTests/Domain/AmbitionsOSLivingDreamTodayBridgeModelsTests.swift
Native/AmbitionsTests/Domain/InspectableIntelligenceGoldenScenarioTests.swift
Native/AmbitionsTests/Today/TodayViewModelTests.swift
```

Implementation truth wins over plans. If a document claims behavior exists but live Swift source/tests do not prove it, classify it as planned/scaffolded, not implemented.

## Allowed Scope

Prefer a narrow vertical runtime slice. Add source only where needed.

Allowed production files:

```text
Native/Ambitions/Domain/MoonshotProofPathModels.swift
Native/Ambitions/Runtime/MoonshotProofPathRuntime.swift
Native/Ambitions/Runtime/AmbitionsRuntimeContracts.swift
Native/Ambitions/Runtime/AmbitionsRuntimeFactory.swift
Native/Ambitions/Runtime/AmbitionsRuntimeGoalIntelligence.swift
Native/Ambitions/Features/Today/TodayExecutionProjector.swift
Native/Ambitions/Features/Today/DayRailViewState.swift
Native/Ambitions/PreviewSupport/PreviewTodayScenarios.swift
```

Allowed test files:

```text
Native/AmbitionsTests/Runtime/MoonshotProofPathRuntimeTests.swift
Native/AmbitionsTests/Runtime/AmbitionsRuntimeGoalIntelligenceServiceTests.swift
Native/AmbitionsTests/Domain/AmbitionsOSLivingDreamTodayBridgeModelsTests.swift
Native/AmbitionsTests/Today/TodayViewModelTests.swift
```

Allowed docs/proof files:

```text
docs/audits/moat-moonshot-proof-path-01-report.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/codex/BATCH_REGISTRY.md
docs/codex/CONTEXT_INDEX.md
.codex/reports/current-run-state.md
.codex/reports/current-batch-train-state.md
```

Only update `IMPLEMENTATION_TRUTH.md` with conservative wording. Do not claim production readiness.

## Forbidden Scope

Do not add or modify:

```text
.github/
.github/workflows/
entitlements
PrivacyInfo.xcprivacy
CloudKit/iCloud sync
Cloudflare R2 client/source-pack fetching
OpenAI/API/cloud LLM dependencies
hosted backend
network client
analytics/telemetry
release/App Store/TestFlight claims
signing/export configuration
new top-level tabs/routes
persistent schema migrations
notifications/widgets/Live Activities/App Intents
broad UI redesign
```

Do not create:

- chatbot UI
- generic “dream planner”
- generic “AI coach”
- motivation score
- proof signal
- user-facing confidence score
- hard-coded Olympic-only implementation
- automatic schedule mutation
- hidden plan activation
- unsafe athletic/health advice
- source-sensitive Olympic eligibility claims without Source Atlas/state review

## Required Runtime Shape

Create a deterministic value-model runtime with these concepts.

### 1. Moonshot Intent Input

Add a small typed input model.

Required fields:

```swift
rawStatement
knownAge
declaredStartingCapabilities
declaredConstraints
availableContextSignals
createdAt
```

The model must support the golden scenario:

```text
rawStatement: “I want to be an Olympic swimmer.”
knownAge: 32
declaredStartingCapabilities: cannot swim
```

### 2. North Star vs Active Path Split

The runtime must separate:

```text
North Star:
Olympic swimmer

Active path:
Become a swimmer from zero

Current gate:
Water safety baseline
```

This split is mandatory. If the active path equals the literal North Star without proof, validation must fail.

### 3. Truth State

Add an enum similar to:

```swift
enum MoonshotTruthState {
    case evidenceSupported
    case plausibleButUnproven
    case moonshotNotEvidenceSupportedYet
    case blockedUntilSafetyProof
    case sourceNeeded
    case needsUserReview
}
```

For the golden scenario, expected truth states:

```text
literalOutcomeTruth: moonshotNotEvidenceSupportedYet
activePathTruth: plausibleButUnproven
currentExecutionTruth: blockedUntilSafetyProof
```

### 4. Proof Ladder

Add typed proof gates.

Required first gate for golden scenario:

```text
Gate:
Water safety baseline

Required proof:
- adult beginner swim assessment scheduled or completed
- safe pool/instructor context identified
- basic water safety/breathing/floating assessment reviewed

Blocked behaviors:
- no Olympic training plan
- no high-volume swim schedule
- no elite benchmark comparison
- no guarantee language
- no unsafe training intensity

Next safe action:
Book adult beginner swim assessment
```

### 5. Start Here Adapter

Add a mapper from the moonshot proof path into existing Start Here / Today bridge-compatible state.

The golden scenario must produce a Today-ready candidate:

```text
title: Book adult beginner swim assessment
kind: recommendedStep
estimatedMinutes: 15
becauseLine: Because the first proof gate is water safety, not Olympic training volume.
sourceQualityLabel: User-stated starting position / needs review
receipt: why this, missing evidence, blocked assumptions, next unlock
closurePrompt: Completed / Still Counts / Moved / Blocked / Waiting / Needs Recovery
```

If the existing `AmbitionsOSLivingDreamTodayBridge` can be used cleanly, use it. Otherwise create a minimal adapter result that can later be bridged into Today without persistence or route changes.

### 6. Receipt Contract

Every moonshot proof path must include a receipt payload with:

```text
what Ambitions preserved
what Ambitions refused to assume
why this step is first
what evidence is missing
what unlocks next
what the user can correct
whether any source review is needed
```

For the golden scenario, the receipt must explicitly say the product did not assume Olympic feasibility yet.

### 7. Safety / Overclaim Validator

Add a validator that blocks:

```text
literal outcome treated as guaranteed
North Star used as active plan without proof
training plan before safety proof
high-volume schedule before beginner proof
source-sensitive requirement claim without source/review state
missing proof gate
missing receipt
missing correction control
automatic plan mutation
hidden commitment mutation
external/server dependency
confidence score exposed
punitive closure language
```

The validator must return stable typed issues. Tests must assert exact issues for negative fixtures.

## Required Golden Tests

Add focused unit tests. These are mandatory.

### Test 1 — Olympic swimmer from zero becomes proof-gated path

Input:

```text
“I want to be an Olympic swimmer.”
age: 32
cannot swim: true
```

Assert:

```text
northStar.title == "Olympic swimmer"
activePath.title == "Become a swimmer from zero"
literalOutcomeTruth == .moonshotNotEvidenceSupportedYet
currentGate.title == "Water safety baseline"
startHere.title == "Book adult beginner swim assessment"
receipt contains "first proof gate is water safety"
blockedBehaviors contains no Olympic training plan
validator issues == []
```

### Test 2 — unsafe Olympic training plan is blocked

Construct a bad output that recommends:

```text
Start Olympic training tomorrow
Swim 5 days per week
Compare times to Olympic standards
```

Assert validator emits:

```text
unsafeTrainingBeforeSafetyProof
literalOutcomeTreatedAsGuaranteed or activePathNotSeparatedFromNorthStar
missingFirstProofGate if applicable
```

### Test 3 — no guarantee language

Bad language samples:

```text
“You can become an Olympian if you stay consistent.”
“This is the best possible path.”
“AI confidence says this will work.”
“You needs review if you miss this.”
```

Assert blocked.

### Test 4 — missing starting position requires intake review

Input lacks swimming ability / beginner status.

Expected:

```text
readiness == needsUserReview
unknowns include current skill level
no training plan generated
first Today step is a clarification/review step, not a workout
```

### Test 5 — Today bridge compatibility

Assert the Start Here candidate can be bridged into a Today-compatible value model with:

```text
recommendedStep
proof/review support
closure prompt
receipt behavior
control actions
no hidden mutation
no user-data server
valueModelOnly runtime boundary
```

### Test 6 — local-only / deterministic boundary

Assert:

```text
no network dependency
no remote intelligence backend
no persistence write during pure compile
no automatic schedule mutation
no external projection
```

## Implementation Design Guidance

Prefer this structure:

```swift
struct MoonshotProofPathRuntime {
    func compile(_ input: MoonshotAmbitionInput) -> MoonshotProofPathResult
}

struct MoonshotProofPathValidator {
    func validate(_ result: MoonshotProofPathResult) -> [MoonshotProofPathIssue]
}

struct MoonshotStartHereAdapter {
    func makeStartHereCandidate(from result: MoonshotProofPathResult) -> MoonshotStartHereCandidate
}
```

Keep the first version deterministic and rules-based.

Use small domain-specific recognizers only when safe:

```text
Olympic / Olympian / elite athlete / pro athlete → moonshot signal
cannot swim / don’t know how to swim / beginner → water safety gate
```

Do not overbuild natural language parsing. The value is the proof pipeline, not NLP sophistication.

## Product Copy Requirements

Use Ambitions-native copy:

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

## Visual Proof Expectations

This batch is runtime-first. UI changes are optional and should be avoided unless necessary.

If a preview is added or updated, provide visual proof only as a lightweight preview artifact and do not claim final UI quality.

If Today preview is touched, it must show:

```text
Start here
Book adult beginner swim assessment
Because the first proof gate is water safety...
Receipt / Why this seam
No training-plan language
```

Do not redesign Today.

## Validation Expectations

Run:

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

Also run relevant scans if available:

```bash
scripts/cqs-product-drift-scan.sh Native/Ambitions/Domain Native/Ambitions/Runtime Native/AmbitionsTests/Runtime docs/audits/moat-moonshot-proof-path-01-report.md || true
scripts/cqs-prompt-built-smell-scan.sh Native/Ambitions/Domain Native/Ambitions/Runtime Native/AmbitionsTests/Runtime || true
scripts/cqs-privacy-security-claim-scan.sh Native/Ambitions/Domain Native/Ambitions/Runtime Native/AmbitionsTests/Runtime docs/audits/moat-moonshot-proof-path-01-report.md || true
```

If a script does not exist, record it as unavailable rather than failing the batch for script absence.

## Proof Report Requirements

Create:

```text
docs/audits/moat-moonshot-proof-path-01-report.md
```

Include:

```text
Result: Green / Yellow / Red
Files read
Files changed
Runtime behavior added
Golden scenario result
Negative safety fixture result
Validation commands
Validation results
Known unproven areas
Claim boundary
Rollback path
Next recommended batch
```

The report must clearly state:

```text
This batch proves a deterministic value-model slice for moonshot proof-gated handling.
It does not prove full natural language understanding, production release readiness, device validation, source-pack freshness, athletic/medical advice, or external eligibility correctness.
```

## Implementation Truth Update

Update `docs/truth/IMPLEMENTATION_TRUTH.md` conservatively.

Allowed wording:

```text
Moonshot proof-path value models are source-present.
The Olympic swimmer golden scenario is unit-tested as a deterministic local fixture.
The runtime can compile a structured moonshot input into a proof-gated Today-ready candidate without hidden mutation or remote intelligence.
Full raw Capture-to-persistence-to-Today live app flow remains unproven unless separately wired and validated.
```

Forbidden wording:

```text
Ambitions fully handles all dreams.
Ambitions understands any user intent.
Olympic swimmer flow is production-ready.
Moonshot runtime is complete.
Local AI is complete.
Personalized execution engine is complete.
```

## Hard Red Stop Conditions

Stop and report Red if any of these are required to proceed:

```text
external LLM/API/network call
hosted backend/user-data server
schema migration
automatic plan mutation
new top-level route/tab
release/App Store/TestFlight claim
unsafe athletic or health advice
source-sensitive Olympic eligibility claim without source/review state
guarantee language cannot be removed
tests require disabling existing safety validators
implementation requires broad Today redesign
```

If a Hard Red occurs, do not patch around it. Report exact file/path/reason and propose the smallest safe next batch.

## Rollback Expectations

All production changes must be reversible by reverting this batch.

No persistence/schema migration should be introduced.

Rollback must remove:

```text
MoonshotProofPathModels.swift
MoonshotProofPathRuntime.swift
MoonshotProofPathRuntimeTests.swift
any Today preview fixture changes
audit/report updates
truth-file additions
```

No user data migration, entitlement rollback, route rollback, or release rollback should be needed.

## Expected Final Status

Preferred result:

```text
Green with possible Yellow advisories
```

Acceptable Yellow advisories:

```text
Raw Capture input is not yet wired into this runtime.
The result is value-model-only, not persisted.
Today live UI does not yet surface this scenario outside preview/test.
Source Atlas official Olympic requirements are not included.
```

Unacceptable Yellow disguised as Green:

```text
No golden test
No negative safety fixture
No receipt
No validator
No Start Here adapter
No proof-gate model
No local-only boundary assertion
```

## Next Batch After This

If this batch succeeds, recommend:

```text
MOAT-MOONSHOT-CAPTURE-TO-GOAL-02
```

Purpose:

```text
Wire Capture / goal creation review so a raw captured moonshot can become a reviewed MoonshotProofPath candidate without automatic mutation, then expose the candidate in Goals and Today through existing review surfaces.
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
