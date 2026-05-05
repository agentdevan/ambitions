# Ambitions 10/10 Flagship Completion Plan
<!-- markdownlint-disable MD013 -->

Status: Active-scope planning truth / docs-only source truth. No production Swift implementation in this file.
Date: 2026-05-05
Train: FCP01-FCP30 Flagship Completion Plan

## 0. Purpose

This file defines the exact product-object standard and implementation instructions for raising Ambitions to a 10/10 flagship iPhone-native life operating system.

Ambitions must remain a premium iPhone-native life operating system for turning long-term goals into grounded daily execution. It must feel familiar at the macro shell level, invented at the chrome/component/object level, native at the interaction level, expensive at the material level, adaptive at the state level, emotionally mature at the recovery/trust level, living and evolving without gimmicks, and impossible to mistake for generic Codex-generated SwiftUI.

This file is not implementation. It authorizes later named FCP batches to implement only within the boundaries defined by the FCP train, gate matrix, scorecard, and file-boundary map.

## 1. Binding Product Laws

### 1.1 Locked top-level tabs

The only top-level tabs are:

- Today
- Goals
- Capture
- Plan
- You

No FCP batch may add a sixth tab, rename the canonical user-facing tabs, or create a parallel top-level destination.

### 1.2 Locked primary object direction

- Today owns Reality Rail and Start Here Surface.
- Goals owns LifePath View and MissionControlTimeSpine.
- Capture owns text-first Capture Atmosphere Composer and Placement Resolver.
- Plan owns LifeShape Map / LifeShape Contour, Reflow Decision, Pressure Field, and Recovery Loop.
- You owns Personal System Center, Availability Center, Memory Lens, Appearance Studio, Trust History, and user controls.

### 1.3 Top-level composition law

Top-level tabs are visual orientation surfaces, not detail containers. They must pass:

- Glance test: main state is understandable in three seconds.
- One-primary-object test: the dominant object is obvious.
- Drill-down discipline test: detail not needed for orientation or next action goes behind a deliberate tap.

### 1.4 Anti-generic law

Stop on any implementation that creates:

- same-size stacked cards as a dominant top-level structure
- dashboard grids as primary product surfaces
- generic settings dumps outside You details
- AI chatbot wrappers
- notes app / inbox / feed modes
- habit tracker / streak / trophy mechanics
- calendar-clone grids as Plan's primary object
- project-management boards / kanban / OKR dashboards
- fake AI confidence scores
- silent plan mutation
- decorative motion that carries meaning

## 2. 10/10 Flagship Object Standard

A 10/10 Ambitions object must be:

- immediately understandable
- native iPhone believable
- visually premium
- proprietary to Ambitions
- useful in daily life
- emotionally mature
- accessible
- reduced-motion safe
- not dependent on color alone
- not a generic card stack
- not a dashboard tile
- not AI theater
- not over-automated
- trustable
- source-aware
- privacy-safe
- recovery-aware
- composable in SwiftUI
- maintainable
- testable
- scalable across empty, loading, blocked, recovery, private, source-stale, high-pressure, and reduced-motion states
- capable of feeling living/evolving without becoming gimmicky

Any object that is only a renamed card, chip stack, grid, generic row list, or status panel fails the FCP bar.

## 3. Flagship Object Vocabulary

FCP standardizes the following Ambitions-native object language:

- Surface: dominant product object for a tab or major drill-down.
- Rail: ordered execution over time.
- Spine: proof, mission, or continuity structure.
- Thread: compressed relationship between a step, goal, proof, and next action.
- Edge: context-bearing perimeter or side treatment.
- Fold: progressive disclosure for explanation, source, or decision.
- Drawer: reviewable receipt/proof layer.
- Pocket: protected execution or availability area.
- Field: ambient pressure/capacity area.
- Receipt: user-visible record of action, source, privacy, and reversibility.
- Proof: evidence that progress happened.
- Closure: user-owned resolution of an action.
- Lens: controlled view into memory/source context.
- Resolver: placement/correction object.
- Center: user-control surface.

These are implementation objects, not decorative names. Each must have product purpose, state model, accessibility behavior, reduced-motion behavior, and test proof.

## 4. Object Implementation Requirements

### 4.1 Start Here Surface / Hero Step Panel

Current weakness: existing implementation can still resolve to a hero card. Target is a flagship Start Here Surface.

Required primitives:

- StartHereSurface
- StartHereSurfaceState
- ContextEdge
- TimeFitProof
- GoalThread
- StartHereBecauseLine
- StartHereReceiptDrawerPreview

Required anatomy:

1. User-facing label: Start here.
2. Step title.
3. Source-quality because line.
4. Time-fit and buffer proof.
5. Proprietary context edge.
6. Compressed goal thread.
7. Source freshness and privacy state.
8. Primary action: Start now or Open step.
9. Secondary action: Adjust plan or Why this?.
10. Receipt drawer seam.

Required states: normal, tight day, overloaded day, private item, protected time, source stale, missing duration, no schedule, recovery needed, blocked/waiting, reduced motion, accessibility Dynamic Type.

Acceptance:

- Existing Hero Step implementation is replaced or wrapped by StartHereSurface.
- It is not structurally a generic card.
- It can explain why now, why this goal, why this duration fits, and what source it used.
- It shows no confidence percentage and makes no unsupported AI claim.
- It opens Step Detail; Start now opens Step Session.
- Private state hides sensitive title while preserving role, time, and control.
- VoiceOver order is Start here, title, why now, time fit, source/privacy, primary action, receipt status.
- Reduced Motion uses static hierarchy and direct focus/navigation.

Forbidden: AI suggestion card, motivational panel, generic task card, confidence score, hidden source details.

### 4.2 Reality Rail / DayTimelineRail

Target: Reality Rail 3.0. Start Here, Now/Next/Later, closure, proof, and pressure must form one continuous day object.

Required primitives: RealityRail, RealityRailSegment, RealityRailNode, RealityRailKnot, RailProofMarker, RailClosurePrompt, RailPressureEdge.

Required behavior:

- Start Here is the active node.
- Now/Next/Later are rail segments, not separate equal-card sections.
- Missed/unclosed prior steps appear as soft closure knots.
- Proof receipts appear as rail markers.
- Pressure appears as a rail edge, not decoration.
- Empty day is calm and useful.
- Overloaded day collapses detail and emphasizes the smallest safe next step.

Forbidden: agenda clone, calendar timeline, equal-card rail, shame/overdue framing.

### 4.3 Ambition Meridian Shell

Target: a familiar native tab shell with proprietary Ambitions chrome.

Required primitives: AmbitionMeridianShell, MeridianContextLine, SurfaceCrest, ReceiptOverlayZone, CompactContextHeader, SurfaceReturnPath.

Required behavior:

- Native tab navigation remains familiar.
- No hidden navigation.
- Shell chrome is obvious but restrained.
- Receipt overlay zone is globally consistent.
- Selected tab remains primary location signal.
- Context header is compact, safe-area-aware, and accessible.

Forbidden: sci-fi shell, radial nav, floating command dashboard, hidden nav gestures, custom shell that fights iOS.

### 4.4 LifePath View

Target: LifePath Thread, not path cards.

Required primitives: LifePathThread, LifePathThreadNode, ProofBead, RiskPinch, AlternateRouteFold, GoalPathSourceFold.

Required behavior:

- Path is a thread.
- Proof attaches as beads.
- Risk creates a pinch/attention mark.
- Alternate route appears as a branch fold.
- Private mode hides content while preserving path roles.
- Current, next, proof, and blocker states are non-color encoded.

Forbidden: roadmap board, timeline clone, generic goal cards, progress ring as primary object.

### 4.5 MissionControlTimeSpine / Mission Control Lanes

Target: replace Mission Control's primary grid with MissionControlTimeSpine.

Required primitives: MissionControlTimeSpine, MissionControlSpineLane, MissionControlLaneInspector, SpineProofMarker, SpineBlockerKnot, SpineAlternateBranch, SpineNextStepAnchor.

Required behavior:

- Primary object is spine-based, not grid-based.
- Lanes attach to the spine.
- Visible order preserves Completed / Now / Friction / Next / Horizon.
- Proof, blocker, alternate path, and next step are spatially connected.
- Tapping a lane inspects it without adding a destination.
- Reduced Motion presents a static selected lane detail.

Forbidden: dashboard metrics grid, kanban, enterprise PM lanes, sparkline-as-product.

### 4.6 Capture Atmosphere Composer

Target: Capture Atmosphere Composer 2.0 with Placement Shelf.

Required primitives: CapturePlacementShelf, ComposerAtmosphereField, PlacementReceiptSeam, CaptureRouteChoicePill, CaptureLocalSourceFold.

Required behavior:

- Bottom composer remains text-first.
- Route reveal becomes a placement shelf.
- Placement Shelf shows destination, consequence, privacy, local source, correction.
- Mic button must either work or honestly remain unavailable.
- No inbox/feed mode.
- No automatic goal creation.
- No hidden learning.

Forbidden: inbox, notes feed, command palette as primary Capture, hidden personalization.

### 4.7 Placement Resolver / Capture Correction

Target: Resolver Fold.

Required primitives: PlacementResolverFold, PlacementCorrectionReceipt, RouteConsequencePreview, PlacementReviewState.

Required behavior:

- Every placement shows what Ambitions thinks and why.
- Every correction creates a correction receipt.
- User can choose place somewhere else, not a goal, not now, decide later, and discard/archive only if supported.
- No hidden memory update unless implemented and disclosed.
- No user-facing model confidence.

Forbidden: auto-routing without review, confidence percentages, hidden learning copy.

### 4.8 LifeShape Map

Target: LifeShape Contour Map.

Required primitives: LifeShapeContourMap, CapacityContour, ProtectedPocket, PressureField, RecoveryPocket, MilestoneRidge, CommitmentLoadContour.

Required behavior:

- No calendar grid.
- No bar chart as the primary object.
- Day/week/month/life shape appears as contour.
- Protected time appears as pockets.
- Pressure appears as field.
- Recovery appears as space, not warning.
- Milestones appear as ridges or anchors.
- Manual fallback and no-silent-changes boundary remain visible.

Forbidden: calendar clone, analytics chart dashboard, dense event grid, fake precision.

### 4.9 Reflow Decision

Target: Decision Fold.

Required primitives: ReflowDecisionFold, BeforeAfterShapePreview, ProtectedTimeImpactLabel, CapacityImpactProof, PlanMutationReceiptPreview.

Required behavior:

- Shows before and after.
- Shows what changed and why.
- Shows affected steps.
- Shows protected-time impact.
- Requires accept/edit/decline.
- No silent rearrangement.
- No calendar write.

Forbidden: optimized-for-you without proof, hidden mutation, silent reflow.

### 4.10 Pressure / Recovery Review

Target: shared Recovery Loop and Pressure Field behavior.

Required primitives: RecoveryLoop, ReliefPath, PressureField, SmallerStepAnchor, RecoveryReceiptPreview.

Required behavior:

- Recovery is not failure.
- Late start offers lighter path.
- Overloaded day makes the next step smaller.
- Protected time is not sacrificed silently.
- Still Counts remains supported.
- Recovery receipts explain what changed and what did not.

Forbidden: overdue shame, failed labels, productivity score, streak rescue.

### 4.11 Trust Receipt Layer / EvidenceLabel / ProofPulse

Target: system-wide Receipt Drawer.

Required primitives: ReceiptDrawer, ReceiptDrawerState, SourceFold, ReceiptActionRow, ReceiptPrivacyLine, ReceiptUndoCorrectionControls.

Every meaningful action must answer:

- What happened?
- Why?
- Based on what source?
- How fresh is the source?
- What stayed private?
- Did anything change?
- Can the user undo, correct, or review it?

Forbidden: toast-only trust, hidden mutation, generic saved snackbar, source-less AI explanation.

### 4.12 Evidence Ledger / Proof Spine

Target: shared Proof Spine.

Required primitives: ProofSpine, ProofBead, ProofFreshnessLabel, ProofCorrectionMark, ProofPrivacyRedaction.

Required behavior:

- Proof appears on Today Rail, Mission Control, Goal Detail, and You history.
- Proof has source/freshness/privacy.
- Corrected proof remains marked.
- Stale proof does not drive recommendations without review.
- No trophy/gamification.

Forbidden: trophy shelf, analytics ledger, activity feed dump.

### 4.13 Action Closure Diamond

Target: Action Closure Diamond.

Required primitives: ActionClosureDiamond, ClosureQuadrant, ClosureReceiptPreview, ClosureRecoveryPrompt, ClosureOutcomeFold.

Required quadrants:

1. Completed.
2. Still Counts.
3. Moved / Rescheduled.
4. Blocked / Waiting.

Secondary fold: Skipped / Not Needed, Needs Recovery, Needs Review.

Required behavior:

- Default selected outcome is safe and non-shaming.
- Receipt preview updates before confirmation.
- Outcome copy names consequence.
- Proof indicator appears only when outcome creates proof.
- Private state redacts detail.

Forbidden: binary done/failed, overdue guilt, streak break, hidden plan mutation.

### 4.14 Personal System Center

Target: You root becomes Personal System Center, not settings/card pile.

Required primitives: PersonalSystemCenter, SystemProfilePanel, TrustControlSurface, DataMemoryControlSurface, PlanningSetupSurface, ReceiptHistorySurface, PersonalDefaultsSurface.

Required behavior:

- You root shows one primary system center.
- Top section shows identity/setup completeness/trust posture.
- Planning Setup is prominent.
- Trust/Data/Memory are user-owned controls.
- Receipts History is reviewable and non-technical.
- Details may use native grouped navigation; root must not be a generic settings dump.

Forbidden: generic settings dump, diagnostics console, account-admin UI as primary product.

### 4.15 Appearance Studio

Target: Appearance Studio as a curated preview surface.

Required primitives: AppearanceStudio, AppearanceAccentPreview, MaterialDepthPreview, ReducedMotionPreview, ContrastPreview, ObjectSampleStrip.

Required behavior:

- Shows mini previews of Start Here, Reality Rail, LifeShape, and Receipt Drawer.
- Accent preview updates actual object samples.
- Reduced Motion preview shows static equivalents.
- Appearance never implies behavior/personalization changes unless true.

Forbidden: cosmetic skin shop, neon/gamified themes, AI personality claim.

### 4.16 Loading / Empty / Degraded States

Target: object-specific Honest State Objects.

Required primitives: ObjectEmptyState, ObjectLoadingState, ObjectDegradedState, SurfaceStateResolver, SafeNextAction.

Required behavior:

- Today empty means rail gap / Start Here unavailable.
- Goals empty means path not formed.
- Capture empty means needs a place.
- Plan empty means shape unavailable.
- You empty means setup/control unavailable.
- Trust degraded means stale, partial, denied, conflict, or local-only source.

Forbidden: skeleton spam, fake progress, vague error copy.

### 4.17 Iconography / Status Grammar

Target: complete SF Symbols and status grammar system.

Required primitives: AmbitionsStatusGrammar, StatusGlyph, StatusShape, StatusCopy, NonColorMeaningLabel.

Every state requires:

- SF Symbol.
- Shape/pattern.
- Text label.
- VoiceOver meaning.
- Reduced Motion equivalent.
- Allowed placement.

Forbidden: emoji-like symbols, color-only status, arbitrary icon drift.

### 4.18 Motion / Haptics System

Target: object-specific motion and haptics proof.

Required primitives: AmbitionsMotionIntent, AmbitionsHapticIntent, ObjectMotionPolicy, ReducedMotionEquivalent.

Motion may only mean:

- state settled
- receipt confirmed
- proof attached
- rail advanced
- drawer opened
- fold revealed
- closure resolved

Forbidden: confetti, sci-fi sweep, bouncing attention animation, ambient motion carrying meaning.

### 4.19 Dynamic Adaptive Visual Primitives

Target: split and mature visual primitives into state-bearing object anatomy.

Required primitives: LivingSurfaceMaterial, ContextAtmosphere, PressureField, ProofPulse, EvidenceLabel, SourceFold, ObjectEdgeMaterial.

Required behavior:

- Visual state changes object anatomy, not only tint.
- Pressure modifies edge/field.
- Proof attaches to spine/rail.
- Privacy redacts and protects.
- Stale source triggers review fold.

Forbidden: wallpaper-first product, glow-only state, decorative material excess.

### 4.20 Memory Lens / External Brain Visual Layer

Target: user-facing Memory Lens without creepy or unsupported claims.

Required primitives: MemoryLens, MemorySourceAge, MemoryConfidenceLanguage, MemoryCorrectionHandle, MemoryPrivacyShutter, WhyRememberedFold.

Required behavior:

- Shows what Ambitions remembers.
- Shows why it matters.
- Shows source/freshness.
- Allows correction/rejection only where implemented.
- Redacts sensitive memory.
- Does not claim durable sync/export/delete unless implemented.

Forbidden: brain graphic gimmick, omniscient copy, hidden inference.

### 4.21 Step Detail

Target: Step Decision Fold.

Required primitives: StepDecisionFold, StepSourceFold, StepGoalThread, StepClosurePreview, StepReceiptAccess.

Required behavior:

- Explains why this step.
- Shows goal connection.
- Shows duration source.
- Shows what counts.
- Shows closure/proof path.
- Launches Step Session.
- Can adjust plan when needed.

Forbidden: generic task-detail modal, hidden AI explanation, unsupported proof claim.

### 4.22 Step Session

Target: Execution Pocket.

Required primitives: ExecutionPocket, SessionGoalThread, SessionProofSlot, SessionClosureHandoff, OptionalTimerControl.

Required behavior:

- Timer secondary, never mandatory.
- Goal connection visible.
- Proof capture slot visible where applicable.
- Pause/stop do not mutate plan.
- Close loop leads to Closure Diamond.
- Private state protects detail.

Forbidden: Pomodoro clone, surveillance tracker, gamified focus mode.

### 4.23 Grow Into Goal

Target: Goal Seed Incubator.

Required primitives: GoalSeedIncubator, GoalSeedReview, StartingPositionProof, FirstMilestoneAnchor, PromotionConfirmationFold.

Required behavior:

- Captured idea can mature into a goal.
- No automatic goal creation.
- Shows why it may be a goal.
- Shows starting position.
- Shows first milestone and first step.
- Requires explicit promotion.

Forbidden: auto-goals, project wizard, habit conversion.

### 4.24 Cross-Surface Proof / Review Integration

Target: Continuity Receipt Mesh.

Required primitives: ContinuityReceiptMesh, CrossSurfaceProofMarker, ReviewRequiredMarker, ReceiptReturnPath, ProofReviewEntryPoint.

Required behavior:

- Capture receipt can surface in You.
- Today closure proof can surface in Goals.
- Plan reflow receipt can surface in Today/You.
- Goal proof can surface in Today Start Here.
- Review-required state is consistent.
- No activity feed dump.

Forbidden: analytics feed, generic history log, cross-surface spaghetti.

### 4.25 Schedule / Availability / Defaults Depth

Target: Availability Center.

Required primitives: AvailabilityCenter, HardContextStack, ProtectedPocketMap, PlanningDefaultsSurface, AutomationTrustControl, DurationSourceProof, VacationAwayBehaviorFold.

Required behavior:

- Work, school, protected time, sleep, commute/buffers, vacation/away are hard context.
- Open time is not automatically free work time.
- Vacation is not free time unless marked available.
- Guided automation is default.
- Duration source is explicit.
- Defaults explain how they affect Today and Plan.

Forbidden: calendar clone, auto-scheduler black box, generic preferences dump, treating all open time as available.

## 5. App-Wide Deep Review Scope

FCP28 must audit every other part of the app against the same flagship standard, including:

- information architecture and route ownership
- navigation and shell continuity
- design system primitives
- copy and product language
- trust, privacy, and source behavior
- accessibility and cognitive load
- performance, rendering, battery, and file size
- state/data flow
- tests, previews, and visual QA
- release-claim safety

No part of Ambitions may remain below 10/10 merely because it is outside the named 25-object list.

## 6. Validation Baseline For Every Implementation Batch

Every implementation FCP batch must run or explicitly justify inability to run:

- `git status --short`
- `git diff --check`
- `xcodegen generate` if project generation may be affected
- focused `xcodebuild` tests for changed owner files
- `scripts/build-local.sh`
- product drift scan
- copy/release-claim scan
- accessibility and Reduce Motion advisory scan
- file-size/diff-size review
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

Docs-only planning batches must verify no production Swift, route/raw-value, persistence/schema, workflow, dependency, signing, entitlement, or CI/config file changed.

## 7. Stop Conditions

Stop immediately on:

- new top-level tab
- top-level dashboard/grid/card-stack structure
- unsupported AI/runtime/privacy/accessibility/release claim
- weak or missing validation
- source-truth conflict
- unbounded broad refactor
- route/raw/persistence/schema breakage
- file-size Red without extraction plan
- hidden mutation or silent automation
- color-only meaning
- motion-only meaning
- user-facing confidence score

## 8. Completion Standard

The FCP train is complete only when:

- all 25 objects have object-specific implementation proof
- all top-level surfaces pass one-primary-object law
- all major objects have normal/loading/empty/degraded/private/stale/blocked/recovery/reduced-motion/Dynamic Type previews
- all major objects have focused tests
- all cross-surface proof/review paths are connected or explicitly deferred with Yellow owner
- human visual/device/accessibility proof packet exists or remains explicitly unclaimed
- no release/platform claims exceed evidence
