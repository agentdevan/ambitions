# Goal Reality Compiler Backend Master Plan

Status: Active planned backend/runtime source plan. Not implementation proof.
Owner: Private Life Runtime / Local Intelligence Kernel.
Primary runnable prompt: `prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md`.
Related precursor: `docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md`.

## 0. Executive Thesis

Ambitions must not merely store goals, schedule tasks, or generate motivational plans. Ambitions must locally compile human ambition into safe, inspectable, proof-gated daily execution.

The Goal Reality Compiler is the backend/runtime system that gives Ambitions its moat:

```text
Ambitions does not schedule what the user says.
Ambitions locally compiles what the user means into the safest next proof of the life they want.
```

This system handles goals that are risky, vague, regulated, emotionally loaded, impossible as stated, shame-driven, coercive, source-sensitive, or irreversible.

Examples:

```text
I want to be an Olympic swimmer.
I want to lose 60 pounds in two months.
I want to quit my job and become a millionaire this year.
I want to stop my medication.
I want revenge.
I want to become famous in 90 days.
I want to work 16 hours a day until I make it.
I want to become a doctor in 2 years.
I want to move abroad next month.
I want to never fail again.
```

A generic productivity app turns these into tasks. A generic AI coach turns these into advice. Ambitions must turn them into proof-gated execution candidates with truth state, source/professional boundaries, reversible Today steps, receipts, and correction paths.

## 1. Backend Definition

In this plan, backend means the native local Ambitions runtime layer:

- Swift domain models
- deterministic compiler/evaluator
- local runtime service
- validation gates
- proof/receipt/correction contracts
- local runtime integration seams
- test fixtures and evaluation harnesses
- source-truth and implementation-truth updates

Backend does not mean:

- hosted server
- external API
- cloud LLM
- analytics system
- network dependency
- user-data backend
- chatbot runtime

The implementation must remain local-first and deterministic. Optional future source packs may provide public requirement freshness, but this plan does not authorize private user data upload or hosted intelligence.

## 2. Product Laws

The Goal Reality Compiler must obey these laws:

1. North Star is not the same as active plan.
2. The user’s dream is preserved unless it is directly harmful as stated.
3. The active path is the safest currently actionable proof path.
4. Proof comes before intensity.
5. Source-sensitive claims require source/review state.
6. Professional domains route to professional review, not app-generated professional advice.
7. Irreversible actions require review and receipt.
8. Today receives one reversible safe step, not a life overhaul.
9. Receipts explain reframes, refused assumptions, blocked behaviors, and next unlocks.
10. Corrections influence future output only through visible local learning hooks.
11. No hidden mutation.
12. No hosted AI dependency.
13. No user-facing confidence scores.
14. No guarantee language.
15. No shame, failure, or punitive overdue language.
16. No chatbot surface.
17. No broad top-level IA change.

## 3. Mature Runtime Architecture

The mature pipeline is:

```text
GoalRawIntent
  -> Intent Candidate
  -> Goal Threat Model
  -> North Star / Active Path Split
  -> Truth State Engine
  -> Risk Lane Router
  -> Proof Permission System
  -> Source / Professional Boundary Router
  -> Reversibility Engine
  -> Proof Gate Builder
  -> Today Safe Step Projector
  -> Reality Receipt
  -> Closure / Correction / Recovery Loop
  -> Local Learning Influence
```

This pipeline must produce a single backend output:

```text
GoalRealityOutput
```

That object becomes the reusable bridge between Capture, Goals, Today, Time, You, receipts, and local learning.

## 4. Core Output Contract

Recommended model shape:

```swift
struct GoalRealityOutput: Sendable, Equatable, Codable {
    let id: String
    let originalIntent: GoalRawIntent
    let northStar: GoalNorthStar
    let activePath: GoalActivePath
    let truthState: GoalTruthStateBundle
    let riskModel: GoalThreatModel
    let operatingLevel: GoalOperatingLevel
    let proofPermission: GoalProofPermission
    let proofGates: [GoalProofGate]
    let todayCandidate: GoalTodaySafeStepCandidate?
    let receipt: GoalRealityReceipt
    let reviewRequirements: [GoalReviewRequirement]
    let blockedBehaviors: [GoalBlockedBehavior]
    let correctionControls: [GoalCorrectionControl]
    let localLearningHooks: [GoalLocalLearningHook]
    let runtimeBoundary: GoalRuntimeBoundary
}
```

Required invariants:

- `northStar.title` may preserve an extreme dream.
- `activePath.title` must be bounded by current proof.
- `truthState` must distinguish emotional preservation from evidence support.
- `operatingLevel` must control what kind of execution is allowed.
- `todayCandidate` must be absent when the goal is blocked as stated.
- `receipt` must always exist.
- `runtimeBoundary.localOnly == true` for core behavior.
- No output may imply production readiness, official source truth, or professional advice.

## 5. Raw Intent Contract

Recommended shape:

```swift
struct GoalRawIntent: Sendable, Equatable, Codable {
    let id: String
    let rawStatement: String
    let createdAt: String
    let sourceSurface: GoalIntentSourceSurface
    let userKnownContext: [GoalContextSignal]
    let privacyClass: GoalPrivacyClass
    let sourceState: GoalSourceState
}
```

The raw statement must be preserved. Reframes must never erase original language.

Context signals may include:

```text
age
current skill
current access
timeline
budget
capacity
health-sensitive signal
relationship-sensitive signal
financial-risk signal
legal-source signal
professional-review signal
```

Unknowns must be preserved as unknowns, not guessed.

## 6. North Star / Active Path Split

Recommended shape:

```swift
struct GoalNorthStar: Sendable, Equatable, Codable {
    let title: String
    let userLanguage: String
    let ambitionClass: GoalAmbitionClass
    let emotionalJob: GoalEmotionalJob
    let preservedReason: String
}

struct GoalActivePath: Sendable, Equatable, Codable {
    let title: String
    let pathType: GoalActivePathType
    let allowedBecause: String
    let notAllowedYet: [String]
}
```

Examples:

```text
Raw: I want to be an Olympic swimmer.
North Star: Olympic swimmer.
Active Path: Become a swimmer from zero.

Raw: I want to quit my job and become a millionaire this year.
North Star: Financial independence.
Active Path: Validate an income lane while protecting runway.

Raw: I want to stop my medication.
North Star: Feel stable with less medication burden.
Active Path: Prepare a clinician discussion.
```

The validator must reject outputs that collapse North Star into active plan without proof.

## 7. Goal Operating Levels

Recommended enum:

```swift
enum GoalOperatingLevel: String, Codable, Sendable, CaseIterable {
    case holdOnly
    case clarify
    case sourceReview
    case proofGate
    case safeExecution
    case scaling
    case irreversibleDecisionReview
    case blocked
}
```

Level definitions:

| Level | Meaning | Example |
| --- | --- | --- |
| holdOnly | Hold safely, no execution plan. | revenge, harm, unsafe medical command |
| clarify | More starting-position truth needed. | become famous, move abroad |
| sourceReview | Official requirements needed. | immigration, regulated career |
| proofGate | Small real-world proof needed. | business, athlete, creator |
| safeExecution | Bounded plan allowed. | proof exists, risk controlled |
| scaling | Larger investment allowed. | repeated proof exists |
| irreversibleDecisionReview | Consequential step requires review. | quit job, move country |
| blocked | As-stated goal cannot be planned. | retaliation or unsafe action |

Goals may not skip levels without proof and receipt.

## 8. Universal Risk Lanes

Recommended enum:

```swift
enum GoalRiskLane: String, Codable, Sendable, CaseIterable {
    case generalAmbition
    case healthBody
    case medicationMedical
    case mentalHealthCrisisAdjacent
    case financialSpeculation
    case debtHousingMajorPurchase
    case legalImmigration
    case regulatedCareerEducation
    case athleticPhysicalSafety
    case creatorFameValidation
    case relationshipControl
    case familyLifeDecision
    case revengeHarmCoercion
    case burnoutOverwork
    case perfectionismShame
    case identityLifeReset
    case businessEntrepreneurship
}
```

Routing examples:

```text
medicationMedical -> professionalReviewRequired, no dosage plan
financialSpeculation -> riskBoundaryRequired, no income replacement claim
revengeHarmCoercion -> holdOnly or blockedAsStated
athleticPhysicalSafety -> baseline assessment before intensity
regulatedCareerEducation -> sourceReviewRequired
legalImmigration -> official source review before commitment
creatorFameValidation -> controllable publishing proof, no fame guarantee
perfectionismShame -> recovery-capable execution, no never-fail plan
```

## 9. Goal Threat Model

Recommended shape:

```swift
struct GoalThreatModel: Sendable, Equatable, Codable {
    let riskLanes: [GoalRiskLane]
    let harmVectors: [GoalHarmVector]
    let irreversibility: GoalReversibilityLevel
    let professionalBoundary: GoalProfessionalBoundary
    let sourceBoundary: GoalSourceBoundary
    let privacyBoundary: GoalPrivacyBoundary
    let blockedBehaviors: [GoalBlockedBehavior]
    let requiredProofBeforeExecution: [String]
}
```

The threat model answers:

```text
What could go wrong if Ambitions executed this literally?
What needs proof first?
What requires a professional?
What requires official sources?
What must not be scheduled yet?
What is reversible today?
```

## 10. Truth State Engine

Recommended shape:

```swift
struct GoalTruthStateBundle: Sendable, Equatable, Codable {
    let northStarTruth: GoalTruthState
    let activePathTruth: GoalTruthState
    let currentGateTruth: GoalTruthState
    let timelineTruth: GoalTruthState
    let sourceTruth: GoalTruthState
}

enum GoalTruthState: String, Codable, Sendable {
    case evidenceSupported
    case plausibleButUnproven
    case moonshotNotEvidenceSupportedYet
    case timelineUnsafe
    case sourceNeeded
    case professionalReviewNeeded
    case safetyReviewNeeded
    case blockedAsStated
    case needsUserReview
}
```

Truth state is not emotional judgment. It is execution permission.

## 11. Proof Permission System

Recommended shape:

```swift
struct GoalProofPermission: Sendable, Equatable, Codable {
    let currentLevel: GoalOperatingLevel
    let allowedActions: [GoalAllowedAction]
    let blockedActions: [GoalBlockedBehavior]
    let unlockRequirements: [GoalProofRequirement]
}
```

Rule:

```text
A goal cannot become a plan until it earns proof permission.
```

Example:

```text
Quit job and become millionaire.
Allowed: calculate runway, identify income lane, run first revenue experiment.
Blocked: resign, rely on projected income, make millionaire timeline claim.
Unlock: runway proof, revenue proof, replacement-income proof.
```

## 12. Proof Gate Builder

Recommended shape:

```swift
struct GoalProofGate: Sendable, Equatable, Codable, Identifiable {
    let id: String
    let title: String
    let purpose: String
    let sequence: Int
    let requiredEvidence: [GoalProofRequirement]
    let missingEvidence: [String]
    let allowedActions: [GoalAllowedAction]
    let blockedBehaviors: [GoalBlockedBehavior]
    let unlocks: [String]
    let receiptRequirement: GoalReceiptRequirement
    let reviewRequirement: GoalReviewRequirement?
}
```

Every risky goal must have at least one gate before planning intensity.

Olympic swimmer example:

```text
Gate 1: Water safety baseline.
Purpose: Establish safe beginner swimming context.
Allowed: book assessment, research adult lessons.
Blocked: Olympic training plan, high-volume schedule, elite benchmark comparison.
```

## 13. Source / Professional Boundary Router

Recommended shape:

```swift
struct GoalBoundaryRouter {
    func route(_ threatModel: GoalThreatModel) -> [GoalReviewRequirement]
}

enum GoalReviewRequirement: String, Codable, Sendable {
    case userClarification
    case sourceReview
    case professionalReview
    case safetyReview
    case financialRiskReview
    case legalReview
    case privacyReview
    case crisisSupport
}
```

Rule:

```text
If an active step would require licensed professional judgment, Ambitions cannot generate the professional content. It can help prepare for or schedule review.
```

## 14. Autonomy-Preserving Reframe Engine

Recommended shape:

```swift
struct GoalReframeRecord: Sendable, Equatable, Codable {
    let originalUserLanguage: String
    let preservedNorthStar: String
    let reframedActivePath: String
    let reasonForReframe: String
    let refusedAssumptions: [String]
    let userCorrectionAvailable: Bool
}
```

This avoids paternalism. The app must show exactly what it changed and why.

## 15. Reversibility Engine

Recommended enum:

```swift
enum GoalReversibilityLevel: String, Codable, Sendable {
    case harmlessExploration
    case smallReversibleAction
    case reversibleWithCost
    case hardToReverse
    case irreversible
    case harmRisk
}
```

Today should prefer harmless exploration or small reversible action.

Examples:

```text
Move abroad -> identify visa path, not book flight.
Quit job -> calculate runway, not resign.
Stop meds -> prepare provider discussion, not taper plan.
Day trade -> define risk policy, not fund account with needed money.
Revenge -> safe closure/protection, not retaliation.
Olympic swimmer -> book beginner assessment, not swim five days per week.
```

## 16. Today Safe Step Projector

Recommended shape:

```swift
struct GoalTodaySafeStepCandidate: Sendable, Equatable, Codable {
    let title: String
    let subtitle: String
    let estimatedMinutes: Int
    let durationSource: GoalDurationSource
    let becauseLine: String
    let proofGateID: String
    let operatingLevel: GoalOperatingLevel
    let riskLanes: [GoalRiskLane]
    let sourceLabel: String
    let primaryAction: GoalSafeStepAction
    let secondaryActions: [GoalSafeStepAction]
    let closurePrompt: GoalClosurePrompt
    let receiptID: String
}
```

Today gets one safe candidate, not a full plan.

## 17. Reality Receipt Ledger

Recommended shape:

```swift
struct GoalRealityReceipt: Sendable, Equatable, Codable {
    let id: String
    let originalIntentID: String
    let preservedNorthStar: String
    let activePathCreated: String
    let reasonForActivePath: String
    let refusedAssumptions: [String]
    let blockedBehaviors: [GoalBlockedBehavior]
    let missingEvidence: [String]
    let sourceReviewState: GoalSourceState
    let professionalReviewState: GoalProfessionalBoundary
    let userCorrectionControls: [GoalCorrectionControl]
    let didMutatePlan: Bool
    let didWritePersistence: Bool
    let localOnly: Bool
}
```

Receipt requirements:

- preserve original intent
- explain the reframe
- list refused assumptions
- list blocked behaviors
- list missing evidence
- show whether plan changed
- show local-only state
- show correction controls

## 18. Local Learning Influence

Recommended shape:

```swift
struct GoalLocalLearningHook: Sendable, Equatable, Codable {
    let signalKey: String
    let influenceType: GoalLearningInfluenceType
    let sourceReceiptID: String
    let localOnly: Bool
    let resettable: Bool
    let userVisible: Bool
}
```

Corrections must influence future output only when visible, local, resettable, and receipt-backed.

No hidden learning.

## 19. Validator Contract

Recommended shape:

```swift
struct GoalRealityValidator {
    func validate(_ output: GoalRealityOutput) -> [GoalRealityIssue]
}
```

Required issues:

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

The validator should make generic planners fail.

## 20. Golden Fixture Lab

Required golden fixtures:

1. Olympic swimmer from zero.
2. Lose 60 pounds in 2 months.
3. Stop medication.
4. Day trade full time.
5. Quit job and become millionaire.
6. Become doctor in 2 years.
7. Move abroad next month.
8. Revenge.
9. Make partner change.
10. Work 16 hours daily.
11. Become famous in 90 days.
12. Drop out and start company.
13. Buy house while broke.
14. Start family while unstable.
15. Never feel anxious again.
16. Be perfect / never fail.
17. Cut everyone off and start over.
18. Make $10k/month from music.
19. Become fluent in Japanese in 3 months.
20. Become billionaire.

Each fixture must assert:

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

## 21. Negative Fixture Lab

Every golden fixture needs at least one negative fixture.

The negative fixtures must prove the system blocks:

```text
guarantee language
AI confidence language
productivity score language
overdue/failure shame language
unsafe medical advice
financial speculation as income replacement
legal/immigration claims without source
regulated career claims without source
relationship coercion
revenge/retaliation
irreversible decisions without review
high-volume physical training before baseline
```

## 22. Implementation Sequence

### Batch 1 — Compiler Core

`MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01`

Installs pure value models, compiler, validator, and minimum golden fixtures. No persistence. No UI.

### Batch 2 — Fixture Lab

`MOAT-GOAL-REALITY-FIXTURE-LAB-02`

Expands to all 20 golden fixtures and 20 negative fixtures.

### Batch 3 — Runtime Service Integration

`MOAT-GOAL-REALITY-RUNTIME-SERVICE-03`

Exposes compiler through local runtime service and factory seams.

### Batch 4 — Capture Bridge

`MOAT-GOAL-REALITY-CAPTURE-BRIDGE-04`

Turns raw Capture fragments into reviewable Goal Reality candidates.

### Batch 5 — Goals Bridge

`MOAT-GOAL-REALITY-GOALS-BRIDGE-05`

Lets Goals show North Star, Active Path, Truth State, Proof Gates, blocked assumptions, and receipts.

### Batch 6 — Today Bridge

`MOAT-GOAL-REALITY-TODAY-BRIDGE-06`

Lets Today surface one safe Start Here candidate from the compiler.

### Batch 7 — Receipt / Closure / Correction Loop

`MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07`

Connects receipts, closure states, corrections, and visible local learning.

### Batch 8 — Local Persistence

`MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08`

Persists reviewable candidates and receipts only after migration/rollback proof.

### Batch 9 — Source Packs

`MOAT-GOAL-REALITY-SOURCE-PACKS-09`

Adds public read-only source-pack hooks for regulated/source-sensitive requirements. No user data upload.

### Batch 10 — Evaluation Harness

`MOAT-GOAL-REALITY-EVAL-HARNESS-10`

Adds regression scoring across truth honesty, risk routing, proof quality, receipt completeness, non-shaming language, local-only boundary, no hidden mutation, no guarantee language, and Today reversibility.

## 23. File Architecture

Recommended production files:

```text
Native/Ambitions/Domain/GoalRealityModels.swift
Native/Ambitions/Domain/GoalRealityRiskModels.swift
Native/Ambitions/Domain/GoalRealityProofModels.swift
Native/Ambitions/Domain/GoalRealityReceiptModels.swift
Native/Ambitions/Runtime/GoalRealityCompiler.swift
Native/Ambitions/Runtime/GoalRealityValidator.swift
Native/Ambitions/Runtime/GoalRealityRuntimeService.swift
Native/Ambitions/Runtime/GoalRealityFixtureLab.swift
```

Recommended tests:

```text
Native/AmbitionsTests/Runtime/GoalRealityCompilerCoreTests.swift
Native/AmbitionsTests/Runtime/GoalRealityGoldenFixtureTests.swift
Native/AmbitionsTests/Runtime/GoalRealityNegativeFixtureTests.swift
Native/AmbitionsTests/Runtime/GoalRealityRuntimeBoundaryTests.swift
Native/AmbitionsTests/Runtime/GoalRealityReceiptTests.swift
Native/AmbitionsTests/Runtime/GoalRealityTodayBridgeTests.swift
```

Recommended docs:

```text
docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md
docs/audits/moat-universal-goal-reality-compiler-01-report.md
docs/audits/goal-reality-golden-fixture-matrix.md
```

## 24. What Not To Build

Do not implement this as:

```text
LLM prompt
chatbot
giant SwiftUI switch statement
task-template generator
risk disclaimer layer
moderation-only layer
productivity-score system
motivational coach
public-source scraper
hosted backend
generic planner
```

The intelligence belongs in the local runtime grammar:

```text
risk -> truth -> permission -> proof -> safe Today step -> receipt -> correction
```

## 25. Validation Requirements

At minimum for Batch 1:

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealityCompilerCoreTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealityGoldenFixtureTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealityNegativeFixtureTests
scripts/build-local.sh
git diff --check
scripts/run-doc-qa.sh || true
scripts/batch-train-gate-check.sh || true
```

## 26. Claim Boundary

Allowed claim after core implementation and tests:

```text
Ambitions has source-present local Goal Reality Compiler value models and deterministic tests proving selected risky goals become proof-gated execution candidates with receipts and local-only boundaries.
```

Forbidden claims:

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

## 27. Mature Claim

When all ten batches are complete and proven, the honest mature claim is:

```text
Ambitions has a local Goal Reality Compiler that converts risky, vague, moonshot, regulated, or emotionally loaded ambitions into proof-gated execution candidates with source/professional boundaries, reversible Today steps, non-shaming closure, and inspectable receipts.
```

The sharper moat claim is:

```text
Ambitions knows what proof is missing before it is allowed to help you execute.
```
