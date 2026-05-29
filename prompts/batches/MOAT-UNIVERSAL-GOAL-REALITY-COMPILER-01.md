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

# MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01 — Universal Local Goal Reality Compiler Core

## Batch ID

`MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01`

## Runner Command

```bash
scripts/ambitions-codex-train.sh MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01 prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md
```

Equivalent:

```bash
make batch BATCH=MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01 PROMPT=prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md
```

## Objective

Install the first production-quality backend/runtime core for Ambitions’ Universal Goal Reality Compiler: a deterministic, local-only intelligence kernel that converts risky, vague, moonshot, regulated, impossible-as-stated, shame-driven, coercive, financially dangerous, health-sensitive, or emotionally loaded goals into safe proof-gated execution candidates.

This batch must prove the moat:

```text
Ambitions does not schedule what the user says.
Ambitions locally compiles what the user means into the safest next proof of the life they want.
```

This is not a UI batch. It is the backend/runtime foundation for a system that could eventually power Capture, Goals, Today, Time, You, receipts, closure, correction, and local learning.

## Active Source Truth To Inspect

Inspect before editing:

```text
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/CODEX_PROCESS_TRUTH.md

docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md
docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md

docs/canon/Ambitions_Intelligence_Runtime.md
docs/canon/AmbitionsOS_Runtime_Contract.md
docs/canon/Ambitions_Found_Life_Layer.md

Native/Ambitions/Runtime/AmbitionsRuntimeContracts.swift
Native/Ambitions/Runtime/AmbitionsRuntimeFactory.swift
Native/Ambitions/Runtime/AmbitionsRuntimeGoalIntelligence.swift
Native/Ambitions/Runtime/MoonshotProofPathRuntime.swift
Native/Ambitions/Domain/MoonshotProofPathModels.swift

Native/Ambitions/Domain/AmbitionsOSLivingDreamStartingPositionPrivacyIntakeModels.swift
Native/Ambitions/Domain/AmbitionsOSLivingDreamPathPortfolioModels.swift
Native/Ambitions/Domain/AmbitionsOSLivingDreamCapacityBridgeModels.swift
Native/Ambitions/Domain/AmbitionsOSLivingDreamTodayBridgeModels.swift
Native/Ambitions/Domain/AmbitionsOSRecommendationStartHereModels.swift

Native/AmbitionsTests/Runtime/MoonshotProofPathRuntimeTests.swift
Native/AmbitionsTests/Runtime/AmbitionsRuntimeGoalIntelligenceServiceTests.swift
Native/AmbitionsTests/Domain/AmbitionsOSLivingDreamTodayBridgeModelsTests.swift
Native/AmbitionsTests/Domain/InspectableIntelligenceGoldenScenarioTests.swift
```

If any listed file is absent, record that and use the closest active source seam. Do not fail solely because a prior planned file is absent.

Implementation truth wins over plans. Source/test evidence wins over audit docs. Docs-only canon does not prove implementation.

## Allowed Scope

Preferred new production files:

```text
Native/Ambitions/Domain/GoalRealityModels.swift
Native/Ambitions/Domain/GoalRealityRiskModels.swift
Native/Ambitions/Domain/GoalRealityProofModels.swift
Native/Ambitions/Domain/GoalRealityReceiptModels.swift
Native/Ambitions/Runtime/GoalRealityCompiler.swift
Native/Ambitions/Runtime/GoalRealityValidator.swift
Native/Ambitions/Runtime/GoalRealityFixtureLab.swift
```

Preferred new tests:

```text
Native/AmbitionsTests/Runtime/GoalRealityCompilerCoreTests.swift
Native/AmbitionsTests/Runtime/GoalRealityGoldenFixtureTests.swift
Native/AmbitionsTests/Runtime/GoalRealityNegativeFixtureTests.swift
Native/AmbitionsTests/Runtime/GoalRealityRuntimeBoundaryTests.swift
Native/AmbitionsTests/Runtime/GoalRealityReceiptTests.swift
```

Allowed docs/proof files:

```text
docs/audits/moat-universal-goal-reality-compiler-01-report.md
docs/audits/goal-reality-golden-fixture-matrix.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/codex/BATCH_REGISTRY.md
docs/codex/CONTEXT_INDEX.md
.codex/reports/current-run-state.md
.codex/reports/current-batch-train-state.md
```

Touch existing runtime/factory files only if needed and safe. This first batch should prefer pure value-model/runtime core over app launch wiring.

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
notifications/widgets/Live Activities/App Intents
broad UI redesign
SwiftData schema migrations unless explicitly proven safe with rollback
```

Do not create:

```text
chatbot UI
generic dream planner
generic AI coach
motivation score
proof signal
user-facing confidence score
hard-coded Olympic-only implementation
automatic schedule mutation
hidden plan activation
unsafe athletic/health advice
medical dosage/taper plan
legal/immigration advice
financial speculation advice as income replacement
relationship coercion plan
revenge/retaliation plan
```

## Required Backend Model Core

Install the core compiler grammar from the master plan.

At minimum, implement:

```text
GoalRawIntent
GoalContextSignal
GoalIntentSourceSurface
GoalPrivacyClass
GoalSourceState
GoalNorthStar
GoalActivePath
GoalAmbitionClass
GoalEmotionalJob
GoalRiskLane
GoalThreatModel
GoalHarmVector
GoalReversibilityLevel
GoalProfessionalBoundary
GoalSourceBoundary
GoalPrivacyBoundary
GoalOperatingLevel
GoalTruthState
GoalTruthStateBundle
GoalProofPermission
GoalAllowedAction
GoalBlockedBehavior
GoalProofRequirement
GoalProofGate
GoalReceiptRequirement
GoalReviewRequirement
GoalTodaySafeStepCandidate
GoalSafeStepAction
GoalClosurePrompt
GoalRealityReceipt
GoalCorrectionControl
GoalLocalLearningHook
GoalRuntimeBoundary
GoalRealityOutput
GoalRealityIssue
GoalRealityReadiness
```

Models must be:

```text
Sendable
Equatable
Codable where appropriate
small and domain-owned
UI-agnostic
local-runtime safe
```

Do not over-engineer with persistence or app-route dependencies in this batch.

## Required Compiler Core

Implement:

```swift
struct GoalRealityCompiler {
    func compile(_ input: GoalRawIntent) -> GoalRealityOutput
}
```

The compiler must deterministically classify and transform at least the following goal classes:

```text
Olympic swimmer from zero
rapid weight loss
stopping medication
day trading full time
quit job and become millionaire
become doctor in 2 years
move abroad next month
revenge
make partner change
work 16 hours daily
become famous in 90 days
be perfect / never fail
```

For each, the compiler must produce:

```text
North Star
Active Path
Truth State Bundle
Risk Lane(s)
Operating Level
Proof Permission
Proof Gate(s) when applicable
Today Safe Step Candidate if allowed
Blocked Behaviors
Receipt
Correction Controls
Local-only runtime boundary
```

Unknowns must be preserved, not guessed.

## Required Validator Core

Implement:

```swift
struct GoalRealityValidator {
    func validate(_ output: GoalRealityOutput) -> [GoalRealityIssue]
}
```

The validator must detect:

```text
missingNorthStar
missingActivePath
northStarCollapsedIntoActivePlan
missingTruthState
missingThreatModel
missingProofPermission
missingProofGate
missingReceipt
missingCorrectionControl
sourceSensitiveClaimWithoutSource
professionalAdviceGenerated
unsafeMedicalPlan
unsafeFinancialPlan
unsafePhysicalTrainingPlan
coerciveRelationshipPlan
revengeOrHarmPlan
irreversibleActionWithoutReview
hiddenPlanMutation
hiddenCommitmentMutation
remoteIntelligenceDependency
externalUserDataServerDependency
confidenceScoreExposed
guaranteeLanguage
punitiveClosureLanguage
genericProductivityLanguage
```

Issue naming may differ only if equally explicit and stable. Tests must assert exact issues.

## Required Golden Fixtures

Create a fixture lab that supports at least these 12 fixtures in this first batch:

```text
1. Olympic swimmer from zero
2. Lose 60 pounds in 2 months
3. Stop medication
4. Day trade full time
5. Quit job and become millionaire
6. Become doctor in 2 years
7. Move abroad next month
8. Revenge
9. Make partner change
10. Work 16 hours daily
11. Become famous in 90 days
12. Be perfect / never fail
```

Each golden fixture must assert:

```text
North Star preserved or safely blocked
Active Path safe
Truth State honest
Risk Lane correct
Operating Level correct
Proof Gate exists when needed
Today Step reversible when allowed
Unsafe behaviors blocked
Receipt present
Correction controls present
No guarantee language
No confidence score
No shame language
No hidden mutation
Local-only boundary preserved
```

If time/scope allows, add the remaining master-plan fixtures:

```text
Drop out and start company
Buy house while broke
Start family while unstable
Never feel anxious again
Cut everyone off and start over
Make $10k/month from music
Become fluent in Japanese in 3 months
Become billionaire
```

## Required Negative Fixtures

Add negative tests proving the validator rejects at least:

```text
Olympic training plan before water safety proof
rapid weight-loss extreme restriction plan
medication taper/stop plan
trade full time / replace income with day trading
quit job before runway/revenue proof
fake doctor timeline without source review
move abroad irreversible step without visa/source review
revenge or retaliation execution plan
coercive partner-change plan
16-hour recurring overwork plan
fame guarantee
never-fail / shame plan
```

Each negative fixture must assert exact validation issues.

## Canonical Expected Outputs

### Olympic swimmer from zero

Input:

```text
I want to be an Olympic swimmer.
Context: age 32, cannot swim.
```

Expected:

```text
North Star: Olympic swimmer
Active Path: Become a swimmer from zero
Risk Lane: athleticPhysicalSafety
Operating Level: proofGate
Truth: moonshotNotEvidenceSupportedYet / safetyReviewNeeded
First Gate: Water safety baseline
Today: Book adult beginner swim assessment
Blocked: Olympic training plan, high-volume swim schedule, elite benchmark comparison
Receipt: preserved dream, refused Olympic feasibility assumption, no plan mutation
```

### Stop medication

Expected:

```text
Risk Lane: medicationMedical
Operating Level: professionalReview
Today: Write down medication concerns for your provider
Blocked: dosage change, taper schedule, abrupt stop
Receipt: Ambitions does not provide medical instructions
```

### Revenge

Expected:

```text
Risk Lane: revengeHarmCoercion
Operating Level: holdOnly or blocked
Today Candidate: absent unless safe closure/protection step is generated
Blocked: retaliation, harassment, intimidation, harm
Receipt: Ambitions preserved need for closure/protection but refused revenge execution
```

## Phase Plan

### Phase 0 — Authority Map

Inspect active truth, existing runtime, moonshot runtime, Living Dream models, recommendation validators, and tests.

Record in the audit report:

```text
existing source seams
new files created
runtime wiring decision
persistence decision
why UI is or is not touched
```

### Phase 1 — Model Install

Install domain models only. No UI, no persistence, no network.

### Phase 2 — Compiler Install

Install deterministic compiler with fixture-backed classification and transformation.

### Phase 3 — Validator Install

Install strict validator and issue taxonomy.

### Phase 4 — Fixture Lab Install

Install golden/negative fixture helpers and tests.

### Phase 5 — Runtime Boundary Tests

Prove local-only, no hidden mutation, no server dependency, no remote intelligence, no persistence write during compile.

### Phase 6 — Receipt Tests

Prove receipts include original intent, preserved North Star, active path reason, refused assumptions, blocked behaviors, missing evidence, correction controls, mutation flags, and local-only state.

### Phase 7 — Optional Bridge Review

If safe, add a minimal adapter result compatible with existing Start Here / Today concepts. Do not wire live UI unless small and clearly safe.

### Phase 8 — Truth / Audit Updates

Create audit report and conservative implementation-truth update.

## Validation Expectations

Run:

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealityCompilerCoreTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealityGoldenFixtureTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealityNegativeFixtureTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealityRuntimeBoundaryTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealityReceiptTests
scripts/build-local.sh
git diff --check
scripts/run-doc-qa.sh || true
scripts/batch-train-gate-check.sh || true
```

If available:

```bash
scripts/cqs-product-drift-scan.sh Native/Ambitions/Domain Native/Ambitions/Runtime Native/AmbitionsTests/Runtime docs/audits/moat-universal-goal-reality-compiler-01-report.md || true
scripts/cqs-prompt-built-smell-scan.sh Native/Ambitions/Domain Native/Ambitions/Runtime Native/AmbitionsTests/Runtime || true
scripts/cqs-privacy-security-claim-scan.sh Native/Ambitions/Domain Native/Ambitions/Runtime Native/AmbitionsTests/Runtime docs/audits/moat-universal-goal-reality-compiler-01-report.md || true
```

If a script is unavailable, record unavailable. Do not claim it passed.

## Visual Proof Expectations

No visual proof is required if no UI/preview is changed.

If a preview or Today surface is touched, provide a screenshot/preview artifact and explicitly state that final visual/device/accessibility/release quality remains unproven.

## Implementation Truth Update

Update `docs/truth/IMPLEMENTATION_TRUTH.md` conservatively.

Allowed wording:

```text
Goal Reality Compiler value models and deterministic compiler tests are source-present.
Selected high-risk goal fixtures compile into proof-gated, receipt-backed, local-only execution candidates.
The current implementation does not prove full raw Capture-to-persistence-to-Today live product flow.
```

Forbidden wording:

```text
Ambitions fully handles every goal.
Ambitions understands all raw intent.
Ambitions provides medical/legal/financial advice.
Goal Reality Compiler is production complete.
Local AI is complete.
Personalized execution engine is complete.
Release-ready.
Device-verified.
```

## Audit Report Requirements

Create:

```text
docs/audits/moat-universal-goal-reality-compiler-01-report.md
```

Include:

```text
Result: Green / Yellow / Red
Files read
Files changed
Runtime architecture installed
Golden fixtures installed
Negative fixtures installed
Validation commands
Validation results
Known unproven areas
Claim boundary
Rollback path
Next recommended batch
```

Also create or update:

```text
docs/audits/goal-reality-golden-fixture-matrix.md
```

The fixture matrix must list each fixture, risk lane, operating level, first proof gate, Today candidate, blocked behaviors, and test coverage.

## Hard Red Stop Conditions

Stop and report Red if implementation requires:

```text
external LLM/API/network call
hosted backend/user-data server
schema migration without rollback proof
automatic plan mutation
hidden commitment mutation
new top-level route/tab
release/App Store/TestFlight claim
unsafe athletic/health advice
medical dosage/taper plan
legal/immigration advice
financial speculation advice as income replacement
coercive relationship behavior
revenge/retaliation plan
guarantee language that cannot be removed
tests require disabling existing safety validators
broad Today redesign
```

## Rollback Expectations

Rollback must be a normal commit revert.

If no schema is added, rollback removes:

```text
GoalReality*.swift production files
GoalReality*.swift test files
audit/truth/registry updates
optional minimal runtime wiring
```

No entitlement, route, release, server, or migration rollback should be needed.

## Expected Status

Preferred:

```text
Green with accepted Yellow advisories
```

Acceptable Yellow advisories:

```text
Only 12 fixtures installed in Batch 1; full 20-fixture lab deferred.
Raw Capture-to-runtime live flow deferred.
Persistence deferred.
Today live UI surfacing deferred.
Source Atlas official requirement packs deferred.
Physical-device proof unavailable.
```

Unacceptable as Green:

```text
No compiler
No validator
No golden fixtures
No negative fixtures
No receipts
No local-only boundary tests
No implementation truth update
No audit report
```

## Next Recommended Batch

After this batch, recommend:

```text
MOAT-GOAL-REALITY-FIXTURE-LAB-02
```

Purpose:

```text
Expand Goal Reality Compiler coverage to the full 20 golden fixtures and matching negative fixtures, then install evaluation scoring for truth honesty, risk routing, proof-gate quality, receipt completeness, local-only boundary, no hidden mutation, no guarantee language, and Today step reversibility.
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
