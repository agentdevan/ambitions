# Ambitions Living Dream Compiler Upgrade Architecture
<!-- markdownlint-disable MD013 -->

Status: HPS08 source truth / docs-LDI architecture. No production Swift implementation.
Date: 2026-05-06
Train: HPS01-HPS12 Human Progress Systems Upgrade

## Purpose

The Living Dream Compiler defines how Ambitions should convert raw dreams,
vague wishes, symbolic aspirations, regulated goals, impossible plans, unsafe
inputs, and source-backed ambitions into the safest useful handling path.

The compiler must turn a dream into safe meaning, requirements, path portfolio,
proof needed, capacity fit, next evidence, and a possible Today step only when
the source, safety, privacy, and user-review gates allow it.

HPS08 is architecture only. It does not implement LDI runtime, capture
classification, source packs, requirement extraction, path generation,
recommendation behavior, persistence, schema, sync, cloud, AI runtime, UI,
professional advice, crisis support service, or external handoff behavior.

## Product Boundary

The Living Dream Compiler must remain:

- local-first in posture
- source-bound
- safety-first
- privacy-aware
- proof-aware
- capacity-aware
- user-reviewable
- fallback-safe
- non-shaming
- honest about uncertainty

The compiler must not become:

- motivational text without requirements
- professional advice
- unsafe dream operationalization
- guaranteed path generation
- hidden commitment mutation
- source certainty without evidence
- hosted user-data processing
- a sixth tab
- a broad answer surface

## Compiler Input Families

| Input family | Purpose | Default posture |
|---|---|---|
| `VagueDreamInput` | Broad desire without enough detail. | Clarify or scaffold. |
| `ConcreteGoalInput` | User names a goal with actionable direction. | Source and capacity review. |
| `SymbolicDreamInput` | Fantasy, metaphor, identity, or impossible literal statement. | Safe meaning extraction. |
| `RegulatedPathInput` | Education, career, legal, health, financial, licensing, or professional domain. | Boundary and source review first. |
| `UnsafeInput` | Self-harm, harm-to-others, exploitation, illegal, coercive, or dangerous literal plan. | Block unsafe operationalization and redirect safely. |
| `CrisisInput` | Crisis-coded input requiring support-oriented handling. | Support path, not normal goal routing. |
| `SourceBackedInput` | User provides a source, requirement, deadline, or pack-backed path. | Source/freshness review. |
| `PrivateLifeInput` | Sensitive identity, relationship, location, minor, family, health, finance, or legal context. | Private by default. |

## Compiler Output Families

| Output family | Meaning | Activation posture |
|---|---|---|
| `ParkedThought` | Save without execution pressure. | User-controlled. |
| `ClarificationNeeded` | Ask one bounded question before routing. | No hidden activation. |
| `QuickStep` | One safe step can be proposed. | Requires user review. |
| `ProjectPlanScaffold` | A plan outline exists but lacks source/proof/capacity proof. | Draft only. |
| `SourceBackedPlanCandidate` | Sources and requirements support a reviewable plan. | Activation requires approval. |
| `ProfessionalBoundaryScaffold` | Regulated or professional domain requires human/source review. | No advice claim. |
| `NorthStarExtraction` | Safe meaning extracted from symbolic or impossible dream. | Option value, not literal validation. |
| `UnsafeBlockedRedirect` | Unsafe operationalization is blocked. | Safe redirect only. |
| `CrisisSupportPath` | Crisis-coded handling path. | Support-oriented, no productivity routing. |
| `SourceReviewNeeded` | Source/freshness/conflict blocks action. | Review first. |
| `UserReviewRequired` | Action is possible only after explicit approval. | No silent mutation. |

## Required Compiler Fields

Every compiler output that may affect Capture, Goals, Plan, Today, You, AOS,
LDI, proof, source review, recommendations, or export must carry:

- `id`
- `inputFamily`
- `primaryHandlingLane`
- `secondaryLaneFlags`
- `seriousnessState`
- `domainState`
- `safetyState`
- `feasibilityState`
- `sourceState`
- `freshnessState`
- `requirementState`
- `proofNeedState`
- `capacityFitState`
- `privacyClass`
- `professionalBoundaryState`
- `northStarSummary`
- `pathPortfolioState`
- `mutationPermissionState`
- `blastRadiusState`
- `reviewState`
- `receipts`
- `correctionPath`

## Seriousness Ladder

The compiler must distinguish:

- `parkedThought`
- `curiosity`
- `somedayDream`
- `activeInterest`
- `seriousGoal`
- `timeSensitiveGoal`
- `regulatedGoal`
- `urgentSafetyConcern`
- `crisisConcern`

Seriousness is a routing signal, not proof that a plan exists.

## Dream-To-Domain Classifier

Domain classification must name the domain and its boundary:

- personal life
- creative
- learning
- education
- career
- health-adjacent
- legal-adjacent
- financial-adjacent
- relationship
- family/minor-sensitive
- location/jurisdiction-sensitive
- safety-sensitive
- symbolic/impossible
- unsupported or unknown

Regulated, professional, minor, source-sensitive, and safety-sensitive domains
must degrade to review or safe redirect before any action plan appears.

## Feasibility Spectrum

Feasibility states:

- `actionableNow`
- `actionableAfterClarification`
- `sourceNeeded`
- `proofNeeded`
- `capacityNeeded`
- `requirementNeeded`
- `humanReviewNeeded`
- `symbolicOnly`
- `unsafeLiteral`
- `unsupported`
- `unknown`

Feasibility must not become a guarantee. It is a review posture.

## Safe Symbolic Translation

Symbolic, fantasy, or impossible dreams may be translated into safe meaning
only when the literal plan is not validated.

Required output:

- literal statement
- unsafe or impossible literal boundary
- safe meaning
- possible values
- possible adjacent domains
- source/proof needs
- user review question
- rejected unsafe interpretation

## Source Trust Bridge

The compiler inherits HPS04 source truth rules. It must carry claim state,
source quality, freshness, uncertainty, jurisdiction, and review owner before a
source-sensitive dream can become a plan candidate.

Unsupported, stale, conflicting, inferred, or unknown claims must produce a
source review path, not confident action.

## Requirement Graph Bridge

The compiler must map dream paths into requirement graph posture:

- known requirements
- missing requirements
- proof needs
- blockers
- conflicts
- deadlines
- jurisdiction or institution scope
- human review requirements

No requirement may be treated as official or satisfied without source,
freshness, proof, and any required human review.

## Capacity Bridge

The compiler must reject fantasy schedules and preserve recovery.

Required capacity outputs:

- available time posture
- energy/cognitive load posture
- commitment conflict posture
- smallest safe next evidence
- no-available-capacity fallback
- user decision needed

## Mutation Permissions And Blast Radius

Compiler outputs may propose changes, but they must not silently mutate goals,
paths, commitments, plans, requirements, proof, privacy state, notifications,
calendar state, widgets, exports, or external surfaces.

Blast radius states:

- `noMutation`
- `localReceiptOnly`
- `goalDraftOnly`
- `planDraftOnly`
- `proofMappingDraft`
- `commitmentImpactReview`
- `sourceImpactReview`
- `privacyImpactReview`
- `externalSurfaceBlocked`
- `requiresHumanReview`

## Next Evidence Recommendation

When action is not yet safe, the compiler should recommend the next evidence
step rather than pretend the plan is ready.

Next evidence examples:

- clarify intent
- attach a source
- review a stale requirement
- save proof
- check capacity
- park the dream
- extract North Star
- ask for human review
- choose not to continue

## Safe Refusal And Redirect

Unsafe, illegal, exploitative, coercive, crisis-coded, or professional-boundary
inputs must not be operationalized.

Safe refusal output must include:

- blocked literal action
- reason category
- safe redirect
- support path when relevant
- privacy posture
- receipt/correction path
- no normal productivity routing for crisis-coded inputs

## API Contract Families

These are architecture contracts, not implemented Swift APIs in HPS08.

### Dream Intake Classification API

Purpose: classify raw input into input family, seriousness, domain, safety, and
privacy posture.

Required output:

- input family
- seriousness state
- domain state
- safety state
- privacy class
- clarification need
- unsafe redirect if needed

### Dream Compiler API

Purpose: produce the safest useful handling lane and draft path context.

Required output:

- primary handling lane
- secondary flags
- feasibility state
- requirement/proof/source needs
- capacity fit
- North Star summary when applicable
- review owner
- rejected unsafe handling

### Compiler Bridge API

Purpose: bridge compiler output into source, requirement, proof, option value,
recommendation, and Today contracts.

Required output:

- source claim links
- requirement links
- proof needs
- option-value links
- recommendation eligibility posture
- Today step posture
- mutation permission state

### Recompiler Impact API

Purpose: classify what must be reviewed when source, proof, capacity,
jurisdiction, user intent, or path state changes.

Required output:

- impacted paths
- impact level
- blast radius state
- commitments affected
- user approval required
- safe fallback

### Dream Handling Receipt API

Purpose: record classification, refusal, parking, North Star extraction,
source review, activation approval, or mutation decision.

Required output:

- receipt id
- handling lane
- source/proof/capacity posture
- safety/professional boundary posture
- user decision
- correction path

## Surface Projection

Projection rules:

- Capture owns raw input, clarification, handling review, and parking.
- Goals owns plan candidates, path portfolios, requirements, proof, and North
  Star review.
- Plan owns capacity impact and recompiler review.
- Today receives only a bounded next evidence step when safe.
- You owns privacy, source pack, correction, deletion, export, and review
  controls.
- External surfaces receive redacted summaries only.

## Regression Oracle

Future LDI implementation must be tested against:

- vague dream with one-question clarification
- impossible dream translated into North Star
- unsafe literal dream blocked and redirected
- crisis-coded input routed to support posture
- regulated career/education input source-reviewed first
- legal/medical/financial/professional boundary input
- minor/student-data sensitivity
- stale source blocks plan activation
- source conflict blocks recommendation
- no capacity blocks Today step
- user rejects compiler assumption
- source change triggers blast-radius review
- proof change updates path posture without silent mutation
- private dream redacted from external surfaces

## No-Claim Boundary

This document does not implement LDI runtime, AOS runtime, capture
classification, source packs, requirement extraction, path generation,
recommendation behavior, model behavior, personalization, persistence, schema,
sync, cloud, analytics, UI, external projection behavior, export behavior,
professional advice, crisis support service, legal/privacy compliance, App
Store readiness, TestFlight readiness, release readiness, physical-device
behavior, public accessibility conformance, or acquisition outcome.
