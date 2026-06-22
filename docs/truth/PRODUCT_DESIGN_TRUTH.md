# PRODUCT_DESIGN_TRUTH.md — Ambitions Object-Stage Architecture + Interaction Canon  
  
**Recommended path:** `docs/truth/PRODUCT_DESIGN_TRUTH.md`  
  
**Status:** Active product/design source of truth; canonical product-source root  
  
**Applies to:** iOS 26 minimum, native SwiftUI, local-first Ambitions architecture  
  
**Last updated:** 2026-06-16  
  
**Owner posture:** Product/design truth, not implementation proof  
  
**Supersedes / merges:**  
  
- `Ambitions_Object_Stage_Architecture_Source.md`  
- `Ambitions Interaction Reference Synthesis.md`  
- Prior `docs/truth/PRODUCT_DESIGN_TRUTH.md` content where this file is newer, stricter, or more specific  

---
  
# Layer 1 — Non-negotiable Product Law  
  
Layer 1 defines the product laws that all implementation, design, Codex, QA, release, and ChatGPT guidance must obey.  

---
  
## 0. Canon Authority  
  
This document is the canonical frontend architecture, interaction, design-system, QA, privacy, and Codex reference for Ambitions.  
  
Use this document whenever generating product, design, SwiftUI, Codex, QA, repo-governance, release, accessibility, privacy, or implementation guidance for Ambitions.  
  
Ambitions is a premium native iPhone-first, local-first Personal Life OS. It is not a tab app, task app, calendar clone, habit tracker, chatbot, dashboard, generic AI productivity wrapper, or web-app shell.  
  
This canon exists to prevent Ambitions from regressing into:  
  
- five tabs  
- static cards  
- verbose architecture UI  
- fake glass  
- internal runtime jargon  
- non-mutating controls  
- prototype shell chrome  
- debug-console trust language  
- cloud-AI dependency  
- hosted personal-data backend assumptions  
  
The root product posture is:  
  
- One native stage.  
- Four persistent surfaces.  
- One global composer.  
- One cross-surface motion layer.  
- One inspectable trust layer.  
- Local-first runtime truth.  
- Visible mutation after every meaningful action.  

---
  
## 1. Locked Product Law  
  
Ambitions has four persistent stage surfaces:  
  
```
Today / Goals / Time / You

```
  
  
Ambitions has one global composer:  
  
```
Capture

```
  
  
Ambitions has one cross-surface behavior layer:  
  
```
Motion

```
  
  
Ambitions has one inspectable trust layer:  
  
```
Proof / Source / Privacy / History / Receipts

```
  
  
Every meaningful user action must produce:  
  
```
runtime mutation
visible stage mutation
accessible state change
safe fallback
proof artifact

```
  
  
This is the highest-level law. Do not weaken it.  

---
  
## 2. Strategic Product Identity  
  
Ambitions is a premium iPhone-first, local-first Personal Life OS for organizing life, shaping time, grounding goals in daily reality, adapting when reality changes, and helping the user make meaningful progress through calm, personalized, inspectable, non-shaming support.  
  
Short product thesis:  
  
```
Ambitions helps life make sense, then helps the user start what fits.

```
  
  
Ambitions may contain Steps, time boundaries, routines, reminders, captures, goal planning, proof, and intelligent recommendations, but it must never collapse into the commodity UI or architecture patterns of those categories.  
  
Ambitions is not:  
  
- a task app  
- a calendar clone  
- a habit tracker  
- a chatbot  
- a dashboard  
- a generic AI planner  
- a notes app  
- a productivity scoring system  
- a web-app shell  

---
  
## 3. Product Promise  
  
Ambitions promises to turn life input into a private local system that keeps direction, capacity, action, closure, proof, and recovery connected.  
  
Ambitions should help the user:  
  
1. Put life inputs somewhere safe.  
2. See what reality can hold.  
3. Connect long-range direction to daily action.  
4. Start with the Step that fits now.  
5. Adjust without losing the thread.  
6. Close loops without shame.  
7. Preserve proof of meaningful progress.  
8. Recover when capacity changes.  
9. Keep personal intelligence local and inspectable.  
10. Stay in control of the system.  
  
Ambitions does not promise perfect productivity, total automation, life optimization, AI coaching, or frictionless self-improvement.  
  
Ambitions promises a calmer, more truthful relationship between intention and reality.  
  
Codex implementation law:  
  
```
Every product surface must help the user place input, understand capacity, start what fits, close what changed, preserve proof, recover without shame, or control the system.

```
  
  
Any feature that does not support this promise must justify its existence or be removed.  

---
  
## 4. Private Life Runtime Moat  
  
Ambitions’ moat is the Private Life Runtime: a local, inspectable, user-controlled life graph that turns intent into reality-fit action, then preserves what changed over time.  
  
Canonical moat hierarchy:  
  
```
Identity Direction
  -> Life Area
    -> Ambition
      -> Outcome
        -> Goal Thread
          -> Commitment
            -> Step
              -> Closure Event
                -> Proof
                  -> Reflection
                    -> Adaptation / Recovery

```
  
  
Proof lets progress survive imperfect days, pivots, recovery, and changing capacity.  
  
The moat is not a generic productivity workflow. It is the continuity between:  
  
```
what matters
what life can hold
what fits now
what the user did
what changed
what still counts
what needs recovery
what Ambitions should remember locally

```
  
  
The Private Life Runtime compounds value when local history improves fit, timing, closure, recovery, and future recommendations without turning the app into a cloud AI assistant, dashboard, task manager, calendar clone, or productivity scoring system.  
  
Motion expresses movement across this hierarchy. Motion is not a destination.  
  
Source Atlas and R2 may enrich public/reference/freshness context, but they do not own the private life graph.  
  
Ambitions Accounts may provide identity, entitlement, R2 reference-pack access, recovery/support, and future paid identity capabilities, but they do not authorize hosted storage of the private life graph under this canon.  
  
Hard red moat failures:  
  
```
external LLM required for core behavior
hosted AI service required for core behavior
hosted personal-data backend
server-side user profiling
Motion as a root surface
Capture as a root surface
generic task-list execution
calendar-clone scheduling
dashboard analytics
productivity scoring
streak pressure
hidden recommendation behavior
uninspectable learning

```
  

---
  
## 5. Local-Only Architecture  
  
Core personal life data must live on-device by default.  
  
This includes:  
  
- goals  
- life areas  
- captures  
- held items  
- planning defaults  
- schedule assumptions  
- protected time  
- closure history  
- receipts  
- proof  
- pivots  
- recovery history  
- personalization  
- personal context  
- recommendation history  
- user-specific learning  
  
Private life data is local by default. Network access may enrich reference data, validate entitlements, support an optional Ambitions Account, or support approved account recovery. Network access must not become the core runtime.  
  
The Private Life Runtime must work without an account and without network access.  

---
  
## 6. Account, Sync, R2, and Source Atlas Law  
  
Ambitions supports custom Ambitions Accounts at launch.  
  
The app must remain fully usable without an account.  
  
No account means:  
  
```
100% offline core app
no Ambitions hosted account
no personal backend
no network dependency for core value
Private Life Runtime runs fully on-device
bundled/local reference packs only
local goals, captures, closures, proof, preferences, and personalization

```
  
  
Ambitions Account means:  
  
```
optional account layer
Sign in with Apple support
Google Sign-In support
R2 freshness/reference-pack access
entitlement-gated reference updates
account recovery/support
future paid identity layer
future approved network features

```
  
  
Authentication provider choice does not change the privacy law. Sign in with Apple and Google Sign-In authenticate the Ambitions Account; they do not authorize hosted storage of the private life graph.  
  
The Ambitions Account must not store the private life graph unless a future canon explicitly approves a user-owned sync architecture.  
  
The private life graph includes:  
  
```
goals
life areas
captures
held items
schedule assumptions
calendar-derived personal context
planning defaults
protected time
closures
receipts
proof
pivots
recovery history
personalization
behavior patterns
inferred priorities
recommendation history
private user context

```
  
  
R2 is first-class infrastructure for Source Atlas freshness/reference packs.  
  
R2 may host:  
  
```
public dates
public deadlines
public rules
public requirements
public templates
public planning packs
non-personal Source Atlas metadata
read-only reference packs

```
  
  
R2 must never receive:  
  
```
goals
captures
calendar data
schedule assumptions
life areas
receipts
proof
closure history
personalization data
behavior patterns
inferred priorities
private user context
the private life graph

```
  
  
R2 is not a user-data backend.  
  
Network access may enrich reference data, validate entitlements, support account recovery, or enable future approved paid identity features. Network access must not become the core runtime.  
  
Core Ambitions value must work offline.  

---
  
## 7. Account Mode / Entitlement Matrix
| Mode | Account required | Network required | R2 access | Personal backend | Core app value | Canon status |
| -------------------------- | ---------------- | ------------------------ | ------------------------------------ | -------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- | ------------------------------ |
| Offline Core | No | No | No live R2; bundled/local packs only | No | Full local Private Life Runtime | Required at launch |
| Ambitions Account | Yes | Yes for account features | Yes, entitlement-gated | No private life graph storage | Adds reference freshness, account recovery/support, entitlement access | Required at launch |
| Platform Sign-In | Yes | Yes | Depends on account entitlement | No private life graph storage | Sign in with Apple and Google Sign-In authenticate the Ambitions Account | Required at launch |
| Source Atlas Freshness | Yes by default | Yes | Yes | No | Pulls public/reference/freshness packs from R2 | Required at launch if R2 ships |
| Future Paid Identity Layer | Yes | Yes | Yes, entitlement-gated | No private life graph storage unless future canon approves user-owned sync | Paid entitlements, account continuity, premium reference-pack access, support paths | Reserved future strategy |
| Future User-Owned Sync | Yes | Yes | Maybe | Only if future canon explicitly approves | Cross-device user-owned continuity | Not approved by this canon |
  
  
Hard rules:  
  
```
No account may be required for the core local app.
No hosted account may be required for Today / Goals / Time / You core value.
No hosted account may be required for Capture, local Steps, local closure, local proof, or local personalization.
No Ambitions backend may store the private life graph under this canon.
No R2 request may include private user context.
No R2 pack may require uploading goals, captures, calendar data, or behavioral history.

```
  
  
Launch authentication providers:  
  
```
Sign in with Apple
Google Sign-In

```
  
  
Email/password, passkey-only, or other identity providers are not product truth until separately approved.  

---
  
## 8. Source Atlas Contract  
  
Source Atlas provides public, non-personal reference and freshness packs that can improve planning context without becoming a hosted planning engine.  
  
Source Atlas may inform:  
  
- public dates  
- public deadlines  
- public rules  
- public requirements  
- public templates  
- public planning references  
- non-personal setup guidance  
- public calendar/freshness context  
- Step shaping where only public data is needed  
- Time horizon facts where no private data is uploaded  
  
Source Atlas must not contain:  
  
- user goals  
- captures  
- calendar data  
- schedule assumptions  
- closure history  
- proof  
- personalization  
- behavioral history  
- inferred priorities  
- private user context  
- the private life graph  
  
Source Atlas may support Ambitions Account entitlements and R2 freshness packs, but it does not own the Private Life Runtime.  

---
  
## 9. No Hosted AI / No Cloud LLM Law  
  
External LLMs, hosted AI services, and cloud model APIs are excluded from Ambitions core architecture.  
  
No core Ambitions feature may require:  
  
- external LLM  
- hosted AI service  
- cloud model API  
- custom hosted personal-data backend  
- server-side user profiling  
  
Core intelligence must be:  
  
- local-first  
- deterministic  
- inspectable  
- user-controlled  
- testable without network AI  
- expressed through product behavior  
  
Ambitions may feel intelligent through fit, timing, source awareness, closure, recovery, reflow, and proof. It must not depend on cloud AI to be useful.  

---
  
## 10. What This File Does Not Prove  
  
This file does not prove:  
  
- implementation exists  
- implementation is correct  
- tests pass  
- accessibility has been validated  
- VoiceOver has been validated  
- Dynamic Type has been validated  
- Reduce Motion has been validated  
- Reduce Transparency has been validated  
- performance has been validated  
- persistence has been validated  
- sync exists  
- R2 packs exist  
- local intelligence exists  
- App Store readiness  
- production readiness  
- release readiness  
  
This file is product/design truth. Proof requires code, previews, tests, device validation, accessibility validation, performance validation, and explicit evidence.  

---
  
## 11. Final Red-Line Summary  
  
Codex must stop and repair if:  
  
1. A fifth persistent surface appears.  
2. Plan returns as a top-level surface.  
3. Capture becomes a top-level surface, inbox, notes feed, chatbot, category grid, persistent floating button, or cloud classification theater.  
4. Motion becomes a destination, analytics dashboard, activity feed, XP system, score, streak, social timeline, or progress tab.  
5. Today becomes a task list, calendar timeline, focus widget, stack of cards, or detached Start Here card.  
6. Goals becomes a KPI dashboard, ranked score, habit ring system, astrology map, decorative constellation, or generic goals list.  
7. Time becomes a calendar clone, agenda clone, free/busy surface, heatmap dashboard, productivity score, or AI scheduling surface.  
8. You becomes a social profile, admin console, AI settings wall, generic profile page, or settings dump without User System Profile.  
9. Celestial flavor becomes wallpaper, spectacle, or decoration.  
10. Meaning relies only on color, glow, trace, position, motion, haptic, or constellation geometry.  
11. Meaningful change lacks visible mutation and proof.  
12. Recommendation lacks source, reason, control, uncertainty when relevant, and receipt behavior.  
13. Hosted AI or cloud LLM becomes required.  
14. Hosted personal-data backend appears.  
15. R2 receives user-private data.  
16. Product docs claim implementation/readiness without evidence.  

---
  
## 12. Canon Change Protocol  
  
Canon changes must be additive/merged unless the user explicitly approves replacement.  
  
Any canon update must preserve active product law or explicitly state the supersession.  
  
Before changing this file, verify:  
  
- the current `docs/truth/PRODUCT_DESIGN_TRUTH.md` content  
- the intended source material  
- the exact sections being replaced or inserted  
- no old top-level IA is revived  
- no Motion destination is reintroduced  
- no Capture destination is reintroduced  
- no hosted AI/core LLM dependency is introduced  
- no R2 personal-data path is introduced  
  
After updating this file, verify:  
  
- expected section count is present  
- final architecture tree is present  
- final non-negotiables are present  
- the file ends with `This is the canon.`  
- the active product law still reads `Today / Goals / Time / You`  
- Motion is still behavior  
- Capture is still global composer  
  
A canon file update that cannot be verified is Yellow or Red. Do not report Green without readback proof.  

---
  
# Layer 2 — Architecture and Interaction Canon  
  
Layer 2 defines the operating architecture, interaction model, surface behavior, state contracts, quality gates, and implementation obligations.  

---
  
13. Product Classification  

| Concept | Role | Canonical location | User model |
| -------- | ---------------------------- | ------------------ | -------------------------------------------------------------------------------------- |
| Today | Persistent stage surface | Surfaces/Today | What fits now |
| Goals | Persistent stage surface | Surfaces/Goals | What matters over time |
| Time | Persistent stage surface | Surfaces/Time | What life can hold |
| You | Persistent stage surface | Surfaces/You | The personal system profile |
| Capture | Global composer | Composer/Capture | Add what changed / add intent / add proof |
| Motion | Cross-surface behavior layer | Stage/Motion | The system showing change, recovery, return, completion, blockage, proof, and re-entry |
| Proof | Inspection layer | Trust | Evidence when requested |
| Source | Inspection layer | Trust | Why Ambitions thinks something, when requested or required |
| Privacy | Inspection layer | Trust | What stays local and protected |
| History | Inspection layer | Trust | What changed over time |
| Receipts | Inspection layer | Trust | Internal proof artifacts, user-inspectable only when appropriate |
  
  
Product role law:  
  
- Today is a place.  
- Goals is a place.  
- Time is a place.  
- You is a place.  
- Capture is an act.  
- Motion is behavior.  
- Proof is evidence.  
- Receipts are inspection.  
- Source is explanation.  
- Privacy is boundary.  

---
  
## 14. Core Architectural Thesis  
  
Ambitions should feel like one continuous native iPhone stage whose primary object changes, not like independent screens behind a tab bar.  
  
The app root is `AmbitionsStage`, not a tab controller.  
  
Persistent surfaces are stage states, not tabs.  
  
Capture is a global composer, not a persistent destination.  
  
Motion is system behavior, not a destination.  
  
Proof, Source, Privacy, History, and Receipts are inspection layers, not default top-level UI.  
  
The interface should communicate runtime intelligence through fit, timing, protection, closure, proof, and recovery — not through raw architecture labels.  

---
  
## 15. iOS 26 Native Platform Law  
  
Ambitions targets **iOS 26 minimum**.  
  
This raises the standard. The app may use modern SwiftUI, native materials, Liquid Glass, platform accessibility behavior, and object continuity, but must not become fake Apple chrome.  
  
Rules:  
  
- Use SwiftUI-native components where they serve the product.  
- Use custom chrome only when the active product-object model requires it.  
- Use Liquid Glass as a functional control/navigation layer, not decoration.  
- Do not create translucent blobs and call them glass.  
- Every glass or blur decision must preserve legibility.  
- Every morph must have a Reduce Motion fallback.  
- Every transparent material must have a Reduce Transparency fallback.  
- Every custom Canvas-rendered object must have a semantic accessibility mirror.  
- Every surface must pass Dynamic Type, VoiceOver, High Contrast, Reduce Motion, and Reduce Transparency checks.  
- Real-device rendering proof is required for shell, glass, keyboard, and capture behavior.  
  
`Stage/Chrome/NativeChromePolicy.swift` and `Stage/Chrome/LiquidGlassPolicy.swift` decide:  
  
- when to use native iOS controls  
- when to wrap native controls in Ambitions chrome  
- when to use custom Liquid Glass  
- when to avoid glass entirely  
- when to hide the dock  
- when to collapse the crown  
- when to preserve platform back behavior  
- when to present full-screen overlays  
  
Custom chrome must feel native in:  
  
- hit targets  
- safe areas  
- keyboard behavior  
- VoiceOver order  
- focus restoration  
- scroll-edge behavior  
- reduced transparency  
- increased contrast  
- motion reduction  
- haptics  
- performance  

---
  
## 16. Product Translation Law  
  
Borrow interaction grammar, not product identity.  

| Reference app | Borrow | Do not borrow |
| --------------- | ------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------- |
| Apple Reminders | Today clarity, date grouping, drilldown discipline, quick metadata controls, completed/flagged/urgent organization | Generic reminder/task-list identity, floating global add button, plain reminder semantics |
| Microsoft To Do | Nested steps, grouping, simple completion, notes/files, native export/share, constrained theming ideas | Generic checklist/task app model |
| ChatGPT | Composer quality, keyboard choreography, attachment/mic/voice integration, expanding field, settings organization | Chatbot framing, “ask AI” as product center |
| Apple Calendar | Live now marker, day/week/month/list orientation, Today anchor, year/month/day morphing, pinch/zoom detail density | Calendar clone, event-block visual dominance |
  
  
Ambitions translation table:  

| External pattern | Ambitions-native translation |
| -------------------- | -------------------------------------------------------- |
| Reminder / task | Step |
| Task list | Reality Meridian / Constellation Atlas / LifeShape Field |
| Add button | Capture Access Point / Atmosphere Composer |
| Calendar event block | Fixed point / boundary / capacity constraint |
| Completed task | Closure + proof stitch |
| Settings | User System Profile |
| Future schedule | LifeShape Field horizon |
| Chat input | Atmosphere Composer Field |
| Activity log | Inspection / History / Receipts |
| Undo history | MutationUndo / ReceiptInspectionView |
  
  
This table is translation law, not cloning law.  

---
  
## 17. Final Architecture Tree  
  
```
Ambitions/
  App/
    AmbitionsApp.swift
    AmbitionsRootScene.swift
    AmbitionsStageHost.swift
    AppEnvironment.swift
    AppDependencies.swift
    AppFeatureFlags.swift

  Stage/
    AmbitionsStage.swift
    AmbitionsStageModel.swift
    AmbitionsSurface.swift

    StageState.swift
    StageStore.swift
    StageAction.swift
    StageScene.swift
    StageObject.swift
    StageOverlay.swift
    StageChrome.swift
    StageContext.swift
    StageRoute.swift
    StagePathStore.swift

    StageReducer.swift
    StageEffect.swift
    StageEffectRunner.swift

    StageMorphCoordinator.swift
    StageTransitionSpec.swift
    StageMutationAnimator.swift
    StageFocusCoordinator.swift
    StageSafeAreaPolicy.swift

    Chrome/
      NativeChromePolicy.swift
      LiquidGlassPolicy.swift
      DockBehaviorPolicy.swift
      CrownBehaviorPolicy.swift

    Motion/
      StageMotionState.swift
      StageMotionEvent.swift
      StageMotionLayer.swift
      StageMotionCoordinator.swift
      StageMotionRenderer.swift
      StageMotionAccessibility.swift
      StageMotionReductionPolicy.swift

  Core/
    Domain/
      Step.swift
      GoalThread.swift
      LifeArea.swift
      RealityWindow.swift
      CapacityShape.swift
      CaptureIntake.swift
      ClosureOutcome.swift
      ProofEvent.swift
      RecoveryState.swift
      UserSystemProfile.swift

    Time/
      AmbitionsClock.swift
      SystemClock.swift
      PreviewClock.swift
      TimeZoneProvider.swift
      DayBoundaryScheduler.swift
      RuntimeTickPolicy.swift

    Runtime/
      PrivateLifeRuntime.swift
      RuntimeSnapshot.swift
      RuntimeProjectionPipeline.swift
      RecommendationEngine.swift
      CapacityEngine.swift
      ClosureEngine.swift
      RecoveryEngine.swift
      ProofLedger.swift
      PrivacyBoundary.swift
      RuntimeMutation.swift
      RuntimeValidator.swift

    Persistence/
      SwiftDataModels/
      Repositories/
      Migrations/
      LocalStore.swift
      StoreHealthCheck.swift

    Permissions/
      PermissionState.swift
      PermissionCoordinator.swift
      CalendarPermission.swift
      SpeechPermission.swift
      NotificationPermission.swift
      LocalAuthenticationPolicy.swift

  Projection/
    SurfaceLenses/
      SurfaceLens.swift
      TodayLens.swift
      GoalsLens.swift
      TimeLens.swift
      YouLens.swift

    StageScenes/
      TodayStageScene.swift
      GoalsStageScene.swift
      TimeStageScene.swift
      YouStageScene.swift

    OverlayLenses/
      CaptureLens.swift
      SearchLens.swift
      ClosureLens.swift
      InspectionLens.swift

    OverlayScenes/
      CaptureStageScene.swift
      SearchStageScene.swift
      ClosureStageScene.swift
      InspectionStageScene.swift

    Commands/
      AmbitionsCommand.swift
      CommandRouter.swift
      CommandResult.swift
      CommandValidation.swift

    Mutations/
      StageMutation.swift
      UserVisibleMutation.swift
      MutationProof.swift
      MutationReceipt.swift
      MutationUndo.swift
      MutationAccessibilityAnnouncement.swift

  Language/
    UserFacingLanguage.swift
    RuntimeVocabulary.swift
    SurfaceCopyPolicy.swift
    ForbiddenTopLevelTerms.swift
    CopyBudget.swift

  Trust/
    InspectionSurface.swift
    ProofInspectionView.swift
    SourceInspectionView.swift
    PrivacyInspectionView.swift
    HistoryInspectionView.swift
    ReceiptInspectionView.swift
    RuntimeExplanationPolicy.swift
    TrustDisclosureLevel.swift

  Interaction/
    GestureGrammar.swift
    DirectManipulationPolicy.swift
    SurfaceGestureMap.swift
    KeyboardPolicy.swift
    HapticPolicy.swift

  Rendering/
    CanvasPrimitives/
      MeridianRenderer.swift
      ConstellationRenderer.swift
      LifeShapeRenderer.swift
      MotionCurrentRenderer.swift
      MorphGeometry.swift
      RenderPerformanceProbe.swift

    SemanticMirrors/
      MeridianSemanticModel.swift
      ConstellationSemanticModel.swift
      LifeShapeSemanticModel.swift
      MotionSemanticModel.swift

  DesignSystem/
    Foundations/
      AmbitionsColor.swift
      AmbitionsTypography.swift
      AmbitionsSpacing.swift
      AmbitionsMaterial.swift
      AmbitionsLighting.swift
      AmbitionsDepth.swift
      AmbitionsMotion.swift
      AmbitionsHaptics.swift

    Accessibility/
      AccessibilityLabelPolicy.swift
      VoiceOverFocusPolicy.swift
      DynamicTypePolicy.swift
      ReduceMotionPolicy.swift
      ReduceTransparencyPolicy.swift
      ContrastPolicy.swift

    StagePrimitives/
      ObjectStage.swift
      ContextCrown.swift
      ContinuityDock.swift
      CaptureAccessPoint.swift
      SurfaceMorphBackdrop.swift
      TrustSeam.swift
      ReceiptSurface.swift

    ProductObjects/
      RealityMeridianView.swift
      StartHereToken.swift
      ConstellationAtlasView.swift
      ConstellationNode.swift
      AtmosphereComposerField.swift
      LifeShapeFieldView.swift
      MotionCurrentView.swift
      ProofStitchView.swift
      RecoveryBand.swift
      UserSystemProfileView.swift
      NativeSettingsGroup.swift
      NativeSettingsRow.swift

  Surfaces/
    SurfaceContract.swift
    SurfacePrimaryObject.swift
    SurfaceActionContract.swift
    SurfaceDisclosureContract.swift
    SurfaceLaw.swift
    SurfaceLawAudit.swift

    Today/
      TodaySurface.swift
      TodayObjectView.swift
      TodayInteractions.swift
      TodayAccessibility.swift

    Goals/
      GoalsSurface.swift
      GoalsObjectView.swift
      GoalsInteractions.swift
      GoalsAccessibility.swift

    Time/
      TimeSurface.swift
      TimeObjectView.swift
      TimeInteractions.swift
      TimeAccessibility.swift

    You/
      YouSurface.swift
      YouObjectView.swift
      YouInteractions.swift
      YouAccessibility.swift

  Composer/
    Capture/
      CaptureSurface.swift
      CaptureObjectView.swift
      CaptureInteractions.swift
      CaptureAccessibility.swift
      CaptureInputModel.swift
      CaptureRoutingPreview.swift

  Scenarios/
    RuntimeScenario.swift
    ScenarioCatalog.swift
    ScenarioMatrix.swift

    SurfaceScenarios/
      TodayScenarios.swift
      GoalsScenarios.swift
      TimeScenarios.swift
      YouScenarios.swift

    OverlayScenarios/
      CaptureScenarios.swift
      SearchScenarios.swift
      ClosureScenarios.swift
      InspectionScenarios.swift

    MotionScenarios/
      StageMotionScenarios.swift
      CrossSurfaceMotionScenarios.swift
      PostMutationMotionScenarios.swift
      RecoveryMotionScenarios.swift

    StressScenarios/
      AccessibilityScenarios.swift
      BrokenSourceScenarios.swift
      EmptyStateScenarios.swift
      DenseStateScenarios.swift
      PostMutationScenarios.swift

  Diagnostics/
    RuntimeDiagnostics.swift
    StageDiagnostics.swift
    RenderDiagnostics.swift
    StoreDiagnostics.swift
    CrashTriageNotes.swift

  Quality/
    SnapshotMatrix.swift
    AccessibilityAudit.swift
    PerformanceBudgets.swift
    VisualRegressionHarness.swift
    MotionReductionAudit.swift
    ShellChromeAudit.swift
    ForbiddenLanguageAudit.swift
    SafeAreaAudit.swift
    DynamicTypeAudit.swift
    RealDeviceRenderChecklist.swift

```
  
  
Explicitly removed architecture:  
  
- `RootTab.swift` as root architecture  
- `TabView` as the top-level product model  
- `Surfaces/Motion/`  
- `Surfaces/Capture/`  
- `Projection/SurfaceLenses/MotionLens.swift`  
- `Projection/StageScenes/MotionStageScene.swift`  
- `Scenarios/MotionScenarios.swift` as a top-level surface scenario  

---
  
## 18. Product Quality Bar  
  
A screen is not complete because it compiles.  
  
A surface is complete only when it proves:  
  
- one primary product object  
- one clear primary action  
- real runtime-backed state  
- visible mutation after meaningful action  
- useful empty, dense, broken-source, and recovery states  
- accessible nonvisual meaning  
- native iPhone interaction behavior  
- safe-area correctness  
- source/trust behavior where relevant  
- no old-canon drift  
- no generic productivity UI  
  
If a surface does not prove object, state, action, mutation, accessibility, and native behavior, it is not done.  

---
  
## 19. App Layer Canon  
  
`App/` owns launch, root environment, dependency injection, feature flags, and root stage hosting.  
  
Required behavior:  
  
- The app launches into `AmbitionsStageHost`.  
- The root is the object stage, not isolated screen prototypes.  
- Feature flags cannot expose unfinished debug or internal surfaces in release.  
- Environment injects clock, local store, runtime, permission coordinator, copy policy, design policies, and account/R2 entitlement policy.  
- Root scene supports persistent surfaces, overlays, drilldowns, and route restoration.  
  
Acceptance gates:  
  
- No release build launches into a screen prototype.  
- No release build exposes Motion as a root destination.  
- No release build exposes Capture as a persistent surface tab.  
- No debug fixture UI appears in release.  
- No account requirement blocks core offline use.  

---
  
## 20. Stage Layer Canon  
  
`Stage/` owns the operating-system-like shell: root surfaces, overlays, transitions, chrome, safe areas, focus, gestures, effects, and mutation animations.  
  
`AmbitionsSurface` must include only:  
  
```
enum AmbitionsSurface: String, CaseIterable, Identifiable, Codable, Hashable {
    case today
    case goals
    case time
    case you

    var id: String { rawValue }
}

```
  
  
No `motion`. No `capture`.  
  
`StageOverlay` owns temporary/global experiences:  
  
```
enum StageOverlay: Equatable {
    case none
    case capture(CaptureContext)
    case search(SearchContext)
    case closure(ClosureContext)
    case inspection(InspectionContext)
}

```
  
  
Required action flow:  
  
```
StageAction
→ StageReducer
→ CommandValidation
→ AmbitionsCommand
→ RuntimeValidator
→ RuntimeMutation
→ StageMutation
→ UserVisibleMutation
→ StageMotionEvent
→ StageEffect
→ visible stage result
→ accessibility announcement
→ proof artifact

```
  
  
Required route types:  
  
```
rootSurface
surfaceDrilldown
objectDetail
modalOverlay
composerOverlay
inspectionOverlay
searchOverlay
closureOverlay

```
  
  
Chrome policy matrix:  

| Route depth | Root dock | Context crown | Back arrow | Capture access | Search |
| --------------- | --------- | ------------- | -------------- | -------------- | ---------- |
| Root Today | Yes | Yes | No | Yes | Yes |
| Root Goals | Yes | Yes | No | Yes | Yes |
| Root Time | Yes | Yes | No | Yes | Yes |
| Root You | Yes | Yes | No | Yes | Yes |
| Object detail | No | Reduced | Yes | Contextual | Contextual |
| Full composer | No | No | Close/collapse | Primary | No |
| Search overlay | No | No | Close | No | Primary |
| Closure overlay | No | Reduced | Close/back | No | No |
| Inspection | No | Reduced | Yes | No | No |
  
  
Stage acceptance gates:  
  
- Root dock appears only on Today / Goals / Time / You root surfaces.  
- Root dock is absent on every drilldown screenshot.  
- Back gesture works on every drilldown.  
- Top-left back arrow appears on detail routes.  
- Keyboard never traps composer between dock and keyboard.  
- No duplicate navigation shelf appears.  
- No content hides behind chrome.  
- Stage morphs maintain object continuity.  
- Reduce Motion replaces morphs with restrained non-motion alternatives.  
- VoiceOver focus moves predictably after surface changes, overlays, and mutations.  

---
  
## 21. Motion Layer Canon  
  
Motion is not a destination. Motion is a cross-surface behavior layer.  
  
Motion appears when:  
  
- Step starts  
- Step completes  
- Step is blocked  
- Step is moved  
- Proof is attached  
- Capture is routed  
- Goal thread re-enters Today  
- Time capacity changes  
- Recovery is needed  
- Protected boundary is created  
- User undoes a mutation  
  
Required files:  
  
- `Stage/Motion/StageMotionState.swift`  
- `Stage/Motion/StageMotionEvent.swift`  
- `Stage/Motion/StageMotionLayer.swift`  
- `Stage/Motion/StageMotionCoordinator.swift`  
- `Stage/Motion/StageMotionRenderer.swift`  
- `Stage/Motion/StageMotionAccessibility.swift`  
- `Stage/Motion/StageMotionReductionPolicy.swift`  
  
Required motion states:  
  
```
idle
stepStarted
stepCompleted
proofAttached
blocked
recovering
reentering
timeShifted
captureRouted
protectedWindowCreated
mutationUndone

```
  
  
Motion law:  
  
- Motion must clarify consequence, not decorate.  
- Motion must reduce copy, not require copy.  
- Motion must work without animation.  
- Motion must have VoiceOver announcements.  
- Motion must never become a root destination.  
- Motion must never hide failed runtime mutations.  
  
Motion reduced-mode law:  
  
- replace morph trails with static state changes  
- replace zooming with crossfade/instant hierarchy change  
- replace animated proof stitches with visible final proof state  
- replace moving recovery bands with stable recovery indicators  
- announce meaningful state changes through accessibility  

---
  
## 22. Core Domain Canon  
  
`Core/Domain/` defines Ambitions-native product objects.  
  
`Step.swift` must support:  
  
- title  
- optional note  
- life area  
- goal thread  
- scheduled date/time  
- deadline  
- reminder  
- alarm reminder  
- recurrence  
- location condition  
- flag / pinned state  
- urgency  
- substeps  
- attachments  
- completion state  
- closure state  
- proof events  
- recovery impact  
- source confidence  
- privacy classification  
- undo availability  
  
`GoalThread.swift` must support:  
  
- goal identity  
- life area  
- active step chain  
- recommended step relationship  
- substeps / milestones  
- pinned state  
- blocked state  
- waiting state  
- proof history  
- source confidence  
- recovery state  
- Today feed eligibility  
- Time capacity pressure  
  
`RealityWindow.swift` must support:  
  
- start time  
- end time  
- current fit  
- fixed points  
- open capacity  
- protected boundary  
- transition friction  
- energy fit  
- recommended step eligibility  
- recovery requirement  
  
`CapacityShape.swift` must support:  
  
- fixed points  
- open windows  
- protected windows  
- pressure seams  
- energy fit  
- transition friction  
- recovery requirement  
- future horizon buckets  
- past-due pressure  
- capacity confidence  
  
`CaptureIntake.swift` must support:  
  
- text  
- voice transcript  
- photo  
- file  
- scan text  
- scan document  
- location  
- date intent  
- reminder intent  
- repeat intent  
- goal intent  
- step intent  
- proof intent  
- routing confidence  
- needs review  
- privacy classification  
  
`ClosureOutcome.swift` default options:  
  
- Done  
- Still counts  
- Move it  
- Blocked  
- Not needed  
  
`ClosureOutcome.swift` advanced options:  
  
- Add proof  
- Add note  
- Needs recovery  
- Review later  
- Change Goal  
- Undo  
  
`UserSystemProfile.swift` must support:  
  
- profile identity  
- planning defaults  
- notification preferences  
- appearance preferences  
- privacy preferences  
- permissions  
- connected sources  
- history preferences  
- export/share preferences  
- security controls  
- local authentication settings  
- account state  
- R2 entitlement/reference-pack state  

---
  
## 23. Core Time Canon  
  
`Core/Time/` makes time real, reliable, testable, and previewable.  
  
Time law:  
  
- Today and Time must never show hardcoded current time.  
- No production surface may render current time from fixtures.  
- All current-time behavior must flow through `AmbitionsClock`.  
- Previews and snapshots must freeze time through `PreviewClock`.  
- Day boundary changes must not require app relaunch.  
- Time zone changes must be handled deliberately.  
  
Acceptance gates:  
  
- Today live now marker matches `SystemClock`.  
- Time live now marker matches `SystemClock`.  
- Preview scenarios use `PreviewClock`.  
- Snapshot tests freeze time.  
- Day boundary scheduler updates Today state.  
- No hardcoded “Now” appears in production UI.  

---
  
## 24. Runtime Canon  
  
`Core/Runtime/` converts goals, captures, context, proof, and capacity into deterministic local projections.  
  
Runtime produces:  
  
- recommended step  
- why it fits  
- what time can hold  
- what is protected  
- what changed  
- what needs review  
- what proof exists  
- what can be undone  
- what requires confirmation  
- what recovery is needed  
  
UI displays:  
  
- Start here  
- Recommended step  
- Fits now  
- Protected  
- Done  
- Move it  
- Blocked  
- Review  
- Undo  
  
UI must not expose by default:  
  
- source unavailable  
- receipt before save  
- proof seam  
- runtime-backed  
- route reveal  
- local projection pipeline  
- mutation validator  
  
Runtime acceptance gates:  
  
- Runtime mutation is deterministic.  
- Runtime validation happens before visible mutation.  
- Failed runtime mutations do not animate as success.  
- Proof artifacts are created for meaningful actions.  
- Privacy boundary is enforced before persistence or inspection.  
- Recovery output can be shown through Motion without requiring a Motion surface.  

---
  
## 25. Persistence and Permissions Canon  
  
`Core/Persistence/` owns SwiftData models, repositories, migrations, local store, and store health.  
  
Required laws:  
  
- Domain models do not become SwiftData models directly unless intentionally bridged.  
- Migrations must be tested before release.  
- `StoreHealthCheck` must identify broken local persistence before runtime projection depends on it.  
- Local-first does not mean invisible failure.  
  
`Core/Permissions/` owns all user permission state.  
  
Required permissions:  
  
- `CalendarPermission.swift`  
- `SpeechPermission.swift`  
- `NotificationPermission.swift`  
- `LocalAuthenticationPolicy.swift`  
- `PermissionCoordinator.swift`  
  
Permission behavior law:  
  
- Permission prompts must be contextual.  
- Permission denial must leave a useful fallback.  
- Permission status must not create ugly top-level warnings.  
- Capture controls must explain permission state when tapped or disabled.  
- You owns permission management surfaces.  

---
  
## 26. Projection Canon  
  
`Projection/` translates runtime/domain state into user-facing Stage scenes, overlays, commands, and mutations.  
  
Surface lenses:  

| Lens | Required product translation |
| --------------- | -------------------------------------------------------------------------------------------------------------------- |
| TodayLens.swift | Now, Start Here, current window, upcoming fixed points, urgent, protected, completed |
| GoalsLens.swift | Life areas, goal threads, active step chains, pinned goals, completed milestones |
| TimeLens.swift | Day/week/month/year capacity, live now, future buckets, protected windows, pressure |
| YouLens.swift | Settings/profile sections, status summaries, permissions, privacy, appearance, history, account/R2 entitlement state |
  
  
Overlay lenses:  

| Lens | Required product translation |
| -------------------- | -------------------------------------------------------------------- |
| CaptureLens.swift | Composer state, input metadata, routing preview, review requirements |
| SearchLens.swift | Scoped search results and global expansion |
| ClosureLens.swift | Fast closure, advanced outcome options, proof note, undo state |
| InspectionLens.swift | Trust details only when requested or required |
  
  
Every `StageMutation` must define:  
  
- runtime mutation id  
- before snapshot  
- after snapshot  
- target surface  
- affected object ids  
- visible user-facing change  
- motion event  
- accessibility announcement  
- haptic intent  
- undo availability  
- proof artifact  
- safe fallback if effect fails  
  
Projection acceptance gates:  
  
- No lens emits forbidden top-level terms into primary UI.  
- Every scene has a primary object.  
- Every overlay has a clear exit.  
- Every mutation has a visible consequence.  
- Every mutation has an accessibility announcement or deliberate no-announcement reason.  
- Every undoable mutation exposes undo.  
- Every non-undoable mutation discloses that before execution.  

---
  
## 27. Language Canon  
  
Language is enforcement, not decoration.  
  
Approved primary language:  
  
- Start here  
- Recommended step  
- Start now  
- Open step  
- Step  
- Today  
- Goal  
- Time  
- Capture  
- You  
- Done  
- Move it  
- Blocked  
- Not needed  
- Waiting  
- Protected  
- Review  
- Undo  
  
Restricted to inspection/trust surfaces:  
  
- source  
- proof  
- receipt  
- privacy boundary  
- history  
- local data  
- why this  
- changed by  
  
Forbidden in top-level surfaces:  
  
- runtime-backed  
- fixture-only  
- route reveal  
- receipt before save  
- proof seam  
- open seam  
- local projection  
- mutation pipeline  
- source unavailable  
- review before reflow  
- ready before change  
- blocked-pending-model  
- correction-shaped ledger  
  
Copy budget:  

| Surface    | First viewport copy budget                       |
| ---------- | ------------------------------------------------ |
| Today      | 30–45 words outside Step content                 |
| Goals      | 45–70 words outside goal titles                  |
| Time       | 45–70 words outside time labels                  |
| You        | 80–120 words across visible settings rows        |
| Capture    | 15–30 words before user input                    |
| Closure    | 20–40 words before outcome choices               |
| Inspection | Higher allowed; user explicitly requested detail |
  
  
Native clarity law:  
  
Every surface must be understandable before Ambitions-specific language is read.  
  
A user should understand:  
  
- Where am I?  
- What is current?  
- What can I do?  
- What changes if I act?  
- How do I go back?  
- How do I search?  
- How do I capture?  
  
before they encounter deeper concepts such as proof, source, receipt, runtime, seam, continuity, or reflow.  

---
  
## 28. Trust Canon  
  
`Trust/` makes Ambitions inspectable without making primary UI feel like an audit console.  
  
Trust appears when:  
  
- user asks why  
- a risky change will happen  
- a source is missing and affects behavior  
- a permission is required  
- a mutation needs confirmation  
- history/receipt/proof is opened  
- privacy-sensitive data is involved  
- account/R2 entitlement affects available reference freshness  
  
Disclosure levels:  
  
- none  
- quiet status  
- inline reason  
- confirmation detail  
- full inspection  
  
Top-level surfaces default to `none` or `quiet status`.  
  
Trust law:  
  
- Trust is accessible, not ambient.  
- Proof is evidence, not decoration.  
- Receipts are inspectable, not primary UI.  
- Source is explanation, not error copy.  
- Privacy is behavior, not marketing copy.  
- Account/R2 status is settings/inspection context, not top-level noise.  

---
  
## 29. Interaction Canon  
  
`Interaction/` owns gestures, manipulation, keyboard behavior, and haptics.  
  
Required gestures:  

| Gesture | Surface/context | Behavior |
| ----------------------- | --------------- | ------------------------------------------ |
| Edge swipe | Drilldowns | Native back |
| Pinch | Time | Zoom day/week/month/year density |
| Pinch | Goals | Zoom life area / goal / thread detail |
| Vertical scroll | Today | Move through one-day Reality Meridian |
| Tap Today anchor | Time | Return to current date/detail level |
| Long press Step | Today / Goals | Open action menu |
| Drag Step | Time | Preview move only; confirm before mutation |
| Composer focus | Capture | Slide above keyboard |
| Composer expand | Capture | Full-screen composer |
| Search button / gesture | Shell | Open scoped search |
  
  
Haptics:  
  
Use restrained haptics for:  
  
- Start step  
- Complete step  
- Protect window  
- Pin goal  
- Capture saved  
- Undo mutation  
- Zoom level snap  
  
Do not use haptic spam during scrolling, decorative motion, or passive state changes.  
  
Direct manipulation law:  
  
Every visible object must answer:  
  
- tap does what?  
- long press does what?  
- drag does what?  
- VoiceOver activate does what?  
- keyboard equivalent does what?  
- undo path is what?  

---
  
## 30. Rendering Canon  
  
`Rendering/` renders flagship product objects and their semantic mirrors.  
  
Ambitions cannot keep using static card stacks. Rendering must make product objects legible.  
  
`MeridianRenderer.swift` renders:  
  
- Live now marker  
- Current window  
- Fixed points  
- Recommended step fit  
- Urgent pressure  
- Protected boundary  
- Completed stitches  
- Scrollable day orientation  
  
`ConstellationRenderer.swift` renders:  
  
- Life areas  
- Goal threads  
- Pinned goals  
- Active step chain  
- Proof history hints  
- Completed milestones  
- No decorative meaningless nodes  
  
`LifeShapeRenderer.swift` renders:  
  
- Year/month/week/day/now hierarchy  
- Capacity fields  
- Fixed points  
- Pressure seams  
- Protected windows  
- Pinch detail density  
- Contextual Today anchor  
  
`MotionCurrentRenderer.swift` renders:  
  
- Proof stitch movement  
- Recovery band appearance  
- Re-entry path  
- Blocked state signal  
- Completion consequence  
- Undo reversal  
- Reduced-motion final-state equivalents  
  
Canvas output must have accessible equivalents:  
  
- VoiceOver order  
- Dynamic Type fallback  
- Reduced Motion fallback  
- High Contrast fallback  
- Text-only fallback  
- Actionable semantic elements  
  
Required semantic mirror files:  
  
- `MeridianSemanticModel.swift`  
- `ConstellationSemanticModel.swift`  
- `LifeShapeSemanticModel.swift`  
- `MotionSemanticModel.swift`  

---
  
## 31. Design System Canon  
  
The design system owns the visual system, product objects, accessibility policies, and native components.  
  
Product object requirements:  

| Component | Requirement |
| ----------------------------- | --------------------------------------------------------- |
| ObjectStage.swift | Full-screen integrated object canvas, not card container |
| ContextCrown.swift | Contextual shell header with search/capture/view controls |
| ContinuityDock.swift | Root-only dock; absent in drilldowns |
| CaptureAccessPoint.swift | Native capture affordance, not generic FAB |
| SurfaceMorphBackdrop.swift | Seamless atmospheric transition layer |
| TrustSeam.swift | Quiet trust hint, not exposed architecture |
| ReceiptSurface.swift | Detail-only confirmation/history surface |
| RealityMeridianView.swift | Today primary object |
| StartHereToken.swift | The recommended Step that fits now |
| ConstellationAtlasView.swift | Goals primary object |
| AtmosphereComposerField.swift | Capture primary input |
| LifeShapeFieldView.swift | Time primary object |
| UserSystemProfileView.swift | You primary object |
| NativeSettingsGroup.swift | iOS-native settings section |
| NativeSettingsRow.swift | iOS-native row with icon/status/chevron/toggle |
  
  
Visual laws:  
  
- No generic dashboard stacks.  
- No excessive borders.  
- No heavy card nesting.  
- No unreadable tiny metadata columns.  
- No decorative lines that do not encode meaning.  
- No bottom chrome covering content.  
- No modal trapped between keyboard and dock.  
- No fake Apple clone controls.  
- No neon HUD.  
- No scenic space wallpaper.  
- No decorative stars.  
- No web-app chrome.  
  
Visual target:  
  
- 70% Apple quiet luxury  
- 20% intelligence clarity  
- 10% executive command surface  
- Dark graphite/OLED  
- Restrained celestial atmosphere  
- Premium native iPhone realism  
- Calm recovery-aware tone  

---
  
## 32. Surface Contracts  
  
Every surface must define:  
  
- Primary object  
- Default state  
- Empty state  
- Dense state  
- Broken-source state  
- Primary action  
- Secondary actions  
- Disclosure behavior  
- Search behavior  
- Accessibility behavior  
- Motion behavior  
- Safe-area behavior  
  
Every top-level surface must obey:  
  
- one primary object in first viewport  
- one primary action max in first viewport  
- no raw runtime terminology  
- no generic repeated card stack as primary composition  
- no dock in drilldowns  
- no hidden content under chrome  
- no static fake fixture state  

---
  
## 33. Today Surface Law  
  
Today is not a task list.  
  
Today is:  
  
- Reality Meridian  
- Start Here Token  
- Current window  
- Protected boundary  
- Closure/proof feedback  
  
Today must show:  
  
- Live now  
- Recommended step  
- Current window  
- Next fixed point  
- Urgent pressure  
- Protected boundary  
- Completed closure  
- Waiting/blocked  
- Later today  
  
Today may support these visible groups without becoming a task list:  
  
- Start here  
- Now  
- Next fixed point  
- Urgent  
- Later today  
- Protected  
- Waiting  
- Completed  
  
Today must not show by default:  
  
- source unavailable  
- receipt status  
- route reveal  
- runtime explanation  
- large CTA stack  
- static hardcoded time  
  
Today acceptance gates:  
  
- Live now marker matches `AmbitionsClock`.  
- Start Here appears only when meaningful.  
- No-step state is quiet and clear.  
- Completing a Step visibly mutates Today.  
- Protected windows are understandable without paragraphs.  
- Urgent pressure is visible without becoming a red alert dashboard.  
- Completed state leaves a proof stitch without overwhelming the surface.  

---
  
## 34. Goals Surface Law  
  
Goals is not a list manager.  
  
Goals is:  
  
- Constellation Atlas  
- Life areas  
- Goal threads  
- Step chains  
- Proof history  
  
Goals must show:  
  
- Life areas  
- Active goal threads  
- Pinned goals  
- Recommended step feeding Today  
- Upcoming step chains  
- Completed milestones  
- Blocked/waiting threads  
  
Goals must support:  
  
- Step substeps  
- Notes  
- Attachments  
- Due dates  
- Reminders  
- Repeaters  
- Proof  
- Native share/export later  
  
Goals acceptance gates:  
  
- Life areas are visible without becoming dashboard tiles.  
- Goal threads are spatial/relational, not a plain list.  
- Opening a goal hides root dock.  
- Step chains are understandable.  
- Pinned/urgent/completed states are meaningful.  
- Recommended Step relationship to Today is visible.  

---
  
## 35. Time Surface Law  
  
Time is not a calendar clone.  
  
Time is:  
  
- LifeShape Field  
- Capacity object  
- Pressure map  
- Protected-boundary system  
  
Time must always orient around:  
  
- Now  
- Today  
- Next fixed point  
- Open capacity  
- Protected time  
- Past due pressure  
- Future horizon  
  
Time must show:  
  
- Live now marker  
- Current date  
- Fixed points  
- Open capacity  
- Protected windows  
- Pressure seams  
- Future buckets  
- Day/week/month/year zoom  
- View mode switcher  
- Today anchor  
  
Time horizon buckets:  
  
- Past due  
- Today  
- Tomorrow  
- This week  
- Rest of month  
- Next month  
- Quarter  
- Year  
- Later  
  
Time must not become:  
  
- calendar clone  
- block-only event grid  
- verbose policy report  
- generic time dashboard  
  
Calendar translation:  
  
```
Calendar event block:
9:00–10:00 Meeting

Ambitions-native translation:
9:00–10:00 fixed point
10:10–10:40 usable light window
Recommended step fits here
Recovery needed before next hard edge

```
  
  
Time acceptance gates:  
  
- Live now marker is accurate.  
- Today anchor is obvious.  
- Day/week/month/year hierarchy preserves orientation.  
- Pinch zoom has explicit non-gesture alternative.  
- Fixed points read as constraints, not calendar events.  
- Open windows read as capacity.  
- Protected windows read as boundaries.  

---
  
## 36. You Surface Law  
  
You is not a runtime manual.  
  
You is:  
  
- User System Profile  
- Settings  
- Command center  
- Security/privacy center  
- Appearance studio  
- Planning defaults  
- History and export  
- Account/reference-pack control center  
  
You must show:  
  
- Profile header  
- Personal system  
- Planning defaults  
- Sources & permissions  
- Ambitions Account  
- Source Atlas / R2 reference packs  
- Privacy & security  
- Receipts & history  
- Appearance  
- Notifications  
- Export & share  
- Help  
- About  
  
You must use:  
  
- `NativeSettingsGroup`  
- `NativeSettingsRow`  
- Full-screen drilldowns  
- Toggles where direct  
- Chevrons where deeper  
- Status labels where useful  
- Minimal top-level scrolling  
  
You must not show top-level:  
  
- runtime-backed  
- fixture-only  
- blocked-pending-model  
- product constitution cards  
- large explanatory policy cards  
  
You acceptance gates:  
  
- Most major areas are visible without long scrolling.  
- Rows feel native, not custom dashboard cards.  
- Details hide the root dock.  
- Privacy and permissions are actionable.  
- Account/R2 status is actionable but not noisy.  
- Appearance Studio is controlled and premium.  
- Export/share is available where appropriate.  

---
  
## 37. Capture Composer Law  
  
Capture is not an add sheet.  
  
Capture is:  
  
- Atmosphere Composer  
- Open Field  
- Routing preview  
- Review when needed  
  
Capture field states:  
  
- Collapsed  
- Focused  
- Keyboard raised  
- Multi-line growing  
- Max-height scrolling  
- Expanded full-screen  
- Routing preview visible  
- Ready to place  
- Needs review  
- Saved  
  
Capture control tray:  
  
- Camera  
- Photos  
- Files  
- Scan Document  
- Scan Text  
- Voice  
- Mic dictation  
- Date  
- Reminder  
- Alarm reminder  
- Repeat  
- Location  
- Goal  
- Flag  
- Attachment  
- Full-screen details  
  
Capture routes:  
  
- Step  
- Goal  
- Time boundary  
- Proof  
- Note  
- Planning default  
- User profile memory  
- Review queue  
  
Allowed placeholder examples:  
  
- Capture what changed…  
- What should Ambitions remember?  
- Add a step, change, note, or proof…  
  
Disallowed placeholder examples:  
  
- Capture Anything  
- Route reveal  
- Receipt before save  
- Needs a place  
- Local receipt  
  
Capture acceptance gates:  
  
- Composer slides above keyboard.  
- Composer expands with text.  
- Composer scrolls internally at max height.  
- Expand icon appears only when useful.  
- Full-screen composer has collapse and save/place controls.  
- Attachment menu is clear and animated.  
- Mic and voice controls are permission-aware.  
- Root dock is hidden or safely displaced during keyboard entry.  
- Capture never crashes when expanding.  
- Capture never exposes routing internals as primary copy.  
- Capture works offline.  

---
  
## 38. Closure Law  
  
Closure must be fast by default and deep only when needed.  
  
Default closure options:  
  
- Done  
- Still counts  
- Move it  
- Blocked  
- Not needed  
  
Advanced closure options:  
  
- Add proof  
- Add note  
- Needs recovery  
- Review later  
- Change Goal  
- Undo  
  
Closure acceptance gates:  
  
- The current Step identity is visible.  
- Default outcome choices are immediately reachable.  
- Advanced outcome choices are available without cluttering default closure.  
- Saving closure visibly mutates Today.  
- Closure can create `StageMotionEvent`.  
- Closure can create `MutationProof`.  
- Undo is available when safe.  
- No closure sheet reads like a system report.  

---
  
## 39. Search Law  
  
Search is shell-scoped and context-aware.  
  
Search may scope to:  
  
- Today  
- Goals  
- Time  
- You  
- All Ambitions  
  
Search must return:  
  
- Steps  
- Goal threads  
- Captures  
- Proof/history items  
- Settings/profile areas  
- Time windows  
- Source Atlas/reference-pack entries when account/R2 access is enabled  
  
Search acceptance gates:  
  
- Search opens as overlay, not root surface.  
- Search has clear close behavior.  
- Search does not expose raw runtime object names.  
- Search result rows are actionable.  
- Search respects privacy boundaries.  

---
  
## 40. Object Transformation Rules  
  
Ambitions should feel alive because durable objects transform.  
  
Canonical transformations:  
  
- Capture intake -> Held Object / Step / Goal Thread / Proof / Review queue  
- Goal Thread -> Recommended Step  
- Step -> Active Step / Closure Outcome / Proof Event  
- Closure Outcome -> StageMutation / MutationProof / optional Undo  
- RealityWindow -> Open / Protected / Pressure / Recovery  
- CapacityShape -> Time fit / Future horizon / Reflow preview  
- Proof Event -> Trust inspection / History / future recommendation context  
- RecoveryState -> lighter Step / protected boundary / re-entry signal  
  
Motion expresses these transformations across the Stage. Motion is not a surface.  

---
  
## 41. Persistent Context Model  
  
Stage carries persistent context across Ambitions.  
  
Persistent context may include:  
  
- current Day  
- active Step  
- active Goal Thread  
- current horizon  
- current RealityWindow  
- recent proof/receipt  
- source state  
- automation level  
- account state  
- R2/Source Atlas freshness state  
- protected time  
- pressure state  
- held Capture input  
- closure need  
- recovery state  
  
Persistent context appears through:  
  
- Context Crown  
- Continuity Dock  
- Trust Seam  
- Receipt Surface  
- object-origin transitions  
- source labels  
- subtle Meridian Edge state  
  
Persistent context must not appear as:  
  
- red badges  
- notification counts  
- urgency banners  
- assistant bubbles  
- streak pressure  
- social alerts  
- sportsbook-style urgency  

---
  
## 42. Planning Horizons  
  
Planning horizons are depth inside Time, not root navigation.  
  
Today owns current action and closure.  
  
Time owns capacity, pressure, protected windows, and horizon shaping.  
  
Week is the default Time horizon.  
  
Month shows life shape, milestones, pressure periods, and protected blocks.  
  
Year is directional and reflective.  
  
Life Range is long-range directional context, not a roadmap dashboard.  
  
Do not create root surfaces for Day, Week, Month, Year, Review, or Calendar.  

---
  
## 43. Personalization and Learning Safety  
  
Personal Runtime may learn from:  
  
- explicit planning defaults  
- preferred Step durations  
- closure choices  
- protected time  
- capture routing corrections  
- accepted/rejected recommendations  
- blocked/waiting patterns  
- recovery behavior  
- manual adjustments  
  
Personal Runtime must not learn through:  
  
- server-side profiling  
- cloud AI inference  
- hidden psychological scoring  
- protected/sensitive identity inference  
- manipulative engagement loops  
- social comparison  
- opaque productivity scoring  
  
Ambitions learns behaviors and corrections, not identity labels.  
  
User correction is product data, but it remains local and inspectable.  

---
  
## 44. Receipts, Proof, and Trust Behavior  
  
Receipts are calm proof that a meaningful change happened.  
  
Receipts are not:  
  
- notifications  
- achievements  
- badges  
- streaks  
- feed items  
- alerts  
  
Receipt required when Ambitions:  
  
- moves a Step  
- adjusts a plan  
- places Capture intake  
- records Still Counts  
- connects a Goal Thread  
- protects time  
- changes automation settings  
- records meaningful source-unavailable state  
- creates a pivot  
- transfers proof  
- applies an approved reflow  
- updates account/R2 entitlement state when user action causes it  
  
Every receipt includes:  
  
- action taken  
- affected object  
- source when relevant  
- time/reference  
- inspect control  
- undo/revert when available  
- archive path when needed  
  
Receipt levels:  
  
```
Compact / Peek / Open / Archive

```
  
  
Receipt archive:  
  
```
You -> Receipts & History

```
  

---
  
## 45. Source Labels  
  
Approved source labels:  
  
- You entered  
- Calendar  
- Planning default  
- Goal thread  
- Recent capture  
- Protected block  
- Manual adjustment  
- Automation setting  
- Local inference  
- Public reference  
- Source Atlas  
  
Forbidden source labels:  
  
- AI knows  
- Smart recommendation  
- Optimized by Ambitions  
- Best next move engine  
- Productivity model  
- Life score  
- Model confidence  

---
  
## 46. Global State Model  
  
Global state vocabulary:  
  
- Manual  
- Suggest  
- Preview Reflow  
- Calendar not requested  
- Calendar denied  
- Calendar limited  
- Calendar granted  
- Calendar stale  
- Source Needed  
- Local-only  
- Account signed out  
- Account signed in  
- Account entitlement active  
- Account entitlement unavailable  
- Sync available  
- Sync disabled  
- R2 freshness available  
- R2 freshness unavailable  
- R2 gated by account  
- Protected  
- Pressure  
- Waiting  
- Blocked  
- Needs Recovery  
- Needs Review  
- Held  
- Offline  
- Online reference unavailable  
  
No primary object may ship with only happy-path state.  

---
  
## 47. Empty / Loading / Error / Recovery States  
  
Non-ideal states must be calm and useful.  
  
Empty states explain what the surface can hold or do. They must not imply failure.  
  
Loading states are native, brief, and non-theatrical. No AI-thinking animation.  
  
Error states explain what is unavailable and what still works.  
  
Preferred patterns:  
  
- Calendar unavailable. Manual planning is still available.  
- Reference update unavailable. Local planning still works.  
- Reality changed. This still has a path.  
- Make today lighter.  
- Needs closure. Still counts, move it, or let it go.  
  
Hard red:  
  
- blocking Capture because Calendar is unavailable  
- blocking Goals because permissions are denied  
- blocking core local use because account is signed out  
- blocking core local use because R2 is unavailable  
- shaming missed Steps  
- hiding manual fallback  
- presenting source failure as user failure  

---
  
## 48. Accessibility Detail  
  
Accessibility is product architecture.  
  
Every primary object must provide:  
  
- object-level VoiceOver summary  
- semantic grouping  
- accessible actions  
- Dynamic Type support  
- Reduce Motion support  
- Reduce Transparency support  
- Increase Contrast support  
- Differentiate Without Color support  
- minimum 44 pt tap targets  
- larger preferred primary controls where useful  
- expanded hit areas for small nodes, proof marks, and traces  
- non-color state indicators  
- keyboard/focus equivalent where relevant  
- source/trust path access  
- closure/recovery access  
  
Dynamic Type collapse order:  
  
1. atmospheric detail  
2. decorative trace  
3. secondary metadata  
4. dense readings  
5. optional labels  
  
Never collapse first:  
  
- primary object  
- primary action  
- source/trust path  
- closure/recovery  
- route state  
- receipt/proof  
- manual fallback  
  
No state may rely only on:  
  
- color  
- glow  
- trace  
- position  
- animation  
- haptic  
- constellation geometry  

---
  
## 49. Scenarios Canon  
  
Scenarios codify the product law into testable states.  
  
Today scenarios:  
  
- `today_live_now_marker_matches_clock`  
- `today_empty_state_collapses_quietly`  
- `today_start_here_available_step`  
- `today_urgent_pressure_visible`  
- `today_completed_section_visible`  
- `today_protected_window_visible`  
- `today_later_today_grouping`  
- `today_waiting_or_blocked_visible`  
- `today_drilldown_hides_root_dock`  
  
Goals scenarios:  
  
- `goals_life_area_grouping`  
- `goals_goal_thread_with_substeps`  
- `goals_pinned_goal`  
- `goals_completed_milestone`  
- `goals_blocked_thread`  
- `goals_step_attachment`  
- `goals_step_note`  
- `goals_goal_detail_hides_root_dock`  
- `goals_recommended_step_feeds_today`  
  
Time scenarios:  
  
- `time_day_view_live_now`  
- `time_list_view_today_anchor`  
- `time_week_future_buckets`  
- `time_month_to_day_morph`  
- `time_year_to_month_morph`  
- `time_pinch_zoom_density`  
- `time_fixed_point_as_boundary`  
- `time_protected_window`  
- `time_no_calendar_block_clone`  
  
Capture scenarios:  
  
- `capture_composer_keyboard_choreography`  
- `capture_multiline_expansion`  
- `capture_max_height_internal_scroll`  
- `capture_full_screen_expansion`  
- `capture_plus_menu_sources`  
- `capture_date_reminder_repeat_location_controls`  
- `capture_scan_document`  
- `capture_scan_text`  
- `capture_mic_permission_denied`  
- `capture_voice_permission_granted`  
- `capture_routing_preview_needs_review`  
- `capture_expansion_no_crash`  
  
You scenarios:  
  
- `you_profile_header`  
- `you_native_settings_groups`  
- `you_privacy_security_drilldown`  
- `you_appearance_studio`  
- `you_planning_defaults`  
- `you_sources_permissions`  
- `you_receipts_history`  
- `you_export_share`  
- `you_detail_hides_root_dock`  
- `you_minimal_scroll_top_level`  
- `you_account_signed_out_core_still_available`  
- `you_account_signed_in_r2_available`  
  
Motion scenarios:  
  
- `stage_motion_step_completed`  
- `stage_motion_step_blocked`  
- `stage_motion_proof_attached`  
- `stage_motion_recovery_band_visible`  
- `stage_motion_reentry_visible`  
- `stage_motion_mutation_undone`  
- `cross_surface_motion_today_to_goals`  
- `cross_surface_motion_goals_to_time`  
- `post_mutation_today_updates`  
- `recovery_motion_reduce_motion_fallback`  
  
Stress scenarios:  
  
- `dynamic_type_xxxl_today`  
- `dynamic_type_xxxl_you_settings`  
- `voiceover_today_meridian`  
- `voiceover_capture_composer`  
- `reduce_motion_time_morph`  
- `reduce_transparency_shell`  
- `dark_graphite_high_contrast`  
- `keyboard_safe_area_capture`  
- `broken_calendar_permission`  
- `empty_goals`  
- `dense_today`  
- `dense_time_month`  
- `post_mutation_today_updates`  
- `offline_core_no_account`  
- `r2_unavailable_local_core_continues`  

---
  
## 50. Quality Canon  
  
Quality turns product law into automated gates and proof artifacts.  
  
Required audits:  
  
`ShellChromeAudit.swift`  
  
- Root dock only appears on root surfaces.  
- No duplicate bottom navigation shelf exists.  
- Root dock does not obscure content.  
- Drilldowns use back arrow and gesture back.  
- Composer is keyboard-safe.  
  
`ForbiddenLanguageAudit.swift`  
  
- Scans primary UI strings for forbidden top-level terms.  
- Allows restricted terms only inside Trust/Inspection surfaces.  
- Fails release build if forbidden strings appear in primary surfaces.  
  
`SafeAreaAudit.swift`  
  
- No shell header leaks into status bar.  
- No bottom dock covers scroll content.  
- Keyboard entry does not trap composer between dock and keyboard.  
- All overlays respect safe area.  
  
`DynamicTypeAudit.swift`  
  
- No vertical letter wrapping.  
- No clipped controls.  
- No unreadable metadata columns.  
- Settings rows remain usable.  
- Composer remains usable.  
  
`MotionReductionAudit.swift`  
  
- All morph transitions have Reduce Motion alternatives.  
- Pinch/zoom states have non-gesture alternatives.  
- Mutation animations do not become required for comprehension.  
  
`VisualRegressionHarness.swift`  
  
- Captures root and drilldown surfaces.  
- Captures graphite/OLED default.  
- Captures empty, dense, broken-source, post-mutation states.  
- Captures keyboard and composer states.  
  
`RealDeviceRenderChecklist.swift`  
  
- Validates on real iPhone hardware.  
- Validates OLED graphite rendering.  
- Validates keyboard behavior.  
- Validates haptics.  
- Validates VoiceOver.  
- Validates Reduce Motion.  
- Validates Reduce Transparency.  
- Validates Dynamic Type.  
- Validates safe area and status bar.  

---
  
## 51. Required Proof Artifacts  
  
Every implementation train touching this canon must produce:  
  
Root screenshots:  
  
- Today  
- Goals  
- Time  
- You  
  
Drilldown screenshots:  
  
- Goal detail  
- Step detail  
- Time day detail  
- You settings detail  
- Appearance Studio  
- Privacy/Security  
- Ambitions Account / Source Atlas settings when touched  
  
Overlay screenshots:  
  
- Capture collapsed  
- Capture focused with keyboard  
- Capture expanded  
- Capture source menu  
- Search  
- Closure  
- Inspection  
  
Accessibility proof:  
  
- VoiceOver transcript or notes  
- Dynamic Type screenshots  
- Reduce Motion screenshots/video  
- Reduce Transparency check  
- High Contrast check  
  
Mutation proof:  
  
- Before action  
- Action  
- After visible state change  
- Undo if supported  
  
Quality proof:  
  
- ShellChromeAudit result  
- SafeAreaAudit result  
- ForbiddenLanguageAudit result  
- DynamicTypeAudit result  
- MotionReductionAudit result  
- VisualRegressionHarness result  
- RealDeviceRenderChecklist result  
  
If proof artifacts cannot be produced, the train is Yellow or Red. Do not report Green without proof.  

---
  
## 52. Green / Yellow / Red Acceptance Model  

Status claims must follow `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md`.

Do not use one unqualified `Green` for implementation work.

Use scoped statuses:

- Source Green
- Runtime Green
- Interaction Green
- Visual Green
- Release Green

Codex may not self-certify Visual Green or Release Green.

Visual Green requires an approved positive target, reviewable actual screenshot, target-versus-actual critique, independent visual acceptance, and physical-device proof when visual quality is claimed.

A named SwiftUI component, a source-string test, a screenshot path, or a self-attested visual review is not product proof.

Root surfaces must prove one dominant product object in the first viewport. A vertical stack of canonical components is Red. A report panel as the primary object is Red. Duplicate shell/object ownership is Red.
  
Green:  
  
The implementation is acceptable when:  
  
- User can understand the primary action on every root surface in under 3 seconds.  
- Today uses live device time.  
- Capture opens, expands, and saves without crash.  
- Drilldowns hide the root dock.  
- The keyboard never collides with shell chrome.  
- You resembles a premium native settings/profile surface.  
- Time can move between day/week/month/list without losing orientation.  
- Goals supports life area grouping and Step chains.  
- Forbidden top-level language audit passes.  
- Dynamic Type, VoiceOver, Reduce Motion, Reduce Transparency, and safe-area audits pass.  
- Post-mutation Today visibly updates.  
- Offline core still works with no account.  
  
Yellow:  
  
Conditionally acceptable when:  
  
- A feature works but visual polish is below target.  
- A morph has a fallback but not final animation quality.  
- Some advanced metadata is available only in detail surfaces.  
- A trust explanation exists but needs copy refinement.  
- A scenario passes in preview but needs real-device proof.  
- A validation command was not available but the limitation is documented.  
  
Yellow may merge only with documented follow-up and proof artifacts.  
  
Red:  
  
The implementation fails if:  
  
- Capture crashes.  
- Mic/voice controls appear but do not function or explain permission state.  
- Today shows stale or hardcoded time.  
- Root dock appears in drilldowns.  
- Duplicate bottom nav/shelf is visible.  
- Text wraps into unreadable vertical columns.  
- Primary UI exposes forbidden runtime language.  
- A save/closure action causes no visible state change.  
- Keyboard traps the composer.  
- A top-level surface reads as internal documentation.  
- Motion is reintroduced as a root surface.  
- Capture is reintroduced as a persistent surface.  
- Account sign-in is required for core local use.  
- R2 failure blocks local core value.  
  
Red cannot ship.  

---
  
## 53. Implementation Priority Order  
  
P0 — Make the app operable:  
  
- Fix live time.  
- Fix Capture crash.  
- Fix keyboard/dock layering.  
- Remove dock from drilldowns.  
- Remove duplicate bottom navigation artifact.  
- Make closure visibly mutate Today.  
- Add forbidden language gate.  
- Fix unreadable text wrapping.  
- Preserve offline core with no account.  
  
P1 — Make core surfaces native and clear:  
  
- Rebuild Today around Reality Meridian + Start Here.  
- Rebuild Capture around Atmosphere Composer.  
- Rebuild You around native settings/profile groups.  
- Rebuild Time around LifeShape Field with live now and mode switcher.  
- Rebuild Goals around Constellation Atlas and Step chains.  
  
P2 — Add living-object transitions:  
  
- Time year/month/week/day morph.  
- Goals life area/goal/thread/step morph.  
- Today meridian/current-window/step-detail morph.  
- Capture collapsed/full-screen morph.  
- Cross-surface proof/recovery/re-entry Motion.  
  
P3 — Add advanced interaction depth:  
  
- Pinch zoom.  
- Direct manipulation previews.  
- Share/export.  
- Advanced themes.  
- Location-aware capture.  
- Scan document/text flows.  
- Advanced proof/history inspection.  
- Account-gated Source Atlas freshness when R2 path is ready.  

---
  
# Layer 3 — Strategic Appendices for Codex / ChatGPT  
  
Layer 3 gives Codex and ChatGPT the strategic product, visual, vocabulary, and governance context needed to avoid bad implementation choices.  

---
  
## 54. Daily Use Feel  
  
At rest, Ambitions should feel:  
  
```
calm
premium
human
stateful
private
organized
quietly alive

```
  
  
During action, it should feel:  
  
```
decisive
specific
grounded
easy to adjust

```
  
  
During recovery, it should feel:  
  
```
non-shaming
practical
lighter
still worth continuing

```
  
  
During planning, it should feel:  
  
```
realistic
capacity-aware
editable
source-aware

```
  
  
During review, it should feel:  
  
```
proof-based
calm
useful
not judgmental

```
  

---
  
## 55. Strategic Benchmark Translation  
  
Benchmarks are quality references, not product identity.  
  
Ambitions may learn:  
  
- object depth from Real  
- persistent action context from DraftKings-style transaction surfaces  
- current-state awareness from Flighty  
- dominant canvas/timeframe depth from TradingView  
- durable proof history from Strava  
- headline-state-first design from Oura/WHOOP  
- compact live density from FotMob/Sofascore  
- interaction polish and fast stateful controls from top fantasy/sportsbook apps  
  
Ambitions must not copy:  
  
- betting  
- odds  
- social feeds  
- leaderboards  
- public comparison  
- fantasy mechanics  
- health-score identity  
- productivity scoring  
- live alert anxiety  
  
Benchmark mechanics are translated only when they become Ambitions-native object behavior.  

---
  
## 56. Visual Thesis  
  
Canonical visual thesis:  
  
```
Quiet Object Instruments under a North Star Field

```
  
  
This is visual strategy, not architecture.  
  
Priority order:  
  
1. Object state  
2. Native iPhone restraint  
3. Tactile instrument clarity  
4. Inspectable local runtime trust  
5. North Star / celestial orientation  
6. Atmospheric depth  
  
Object state and native restraint always outrank atmosphere.  
  
The existing visual target remains:  
  
```
70% Apple quiet luxury
20% intelligence clarity
10% executive command surface

```
  

---
  
## 57. Celestial Intensity  
  
Celestial intensity levels:  
  
Dust:  
  
- rest states  
- dense states  
- You  
- settings  
- background atmosphere  
  
Compass:  
  
- orientation  
- Today  
- Time  
- current-state direction  
  
Constellation:  
  
- selected relationships  
- Goals relationship field  
- focused threads  
  
North Star:  
  
- major direction  
- proof  
- horizon  
- selected ambition  
  
Open Field:  
  
- activated Capture only  
  
Celestial flavor must express orientation, relationship, horizon, proof, or safe placement. It must not become wallpaper, spectacle, or decoration.  

---
  
## 58. Semantic Material System  
  
Core semantic materials:  
  
Celestial Field:  
  
- atmospheric orientation surface  
- never wallpaper  
  
Graphite Recess:  
  
- embedded depth and instrument bed  
- never generic card  
  
Luminous Trace:  
  
- state, proof, route, relationship, receipt resolve  
- never neon decoration  
  
Quiet Glass:  
  
- restrained control material  
- never generic glassmorphism  
  
These are semantic material roles, not freeform visual effects.  

---
  
## 59. Primitive Approval Boundary  
  
No new visual primitive may be added unless it proves:  
  
- missing capability  
- semantic product role  
- owning surface/object  
- accessibility mirror  
- Reduce Motion fallback  
- Reduce Transparency fallback  
- performance budget  
- snapshot coverage  
- rollback path  
  
Forbidden without explicit approval:  
  
- new glass system  
- particle engine  
- Metal shader  
- decorative Canvas layer  
- new North Star primitive  
- one-off object frame  
- one-off capture canvas  
- one-off atlas canvas  

---
  
## 60. High-Density but Not Wide  
  
Ambitions should be high-density but not wide.  
  
This means:  
  
- more state inside fewer objects  
- more depth inside fewer surfaces  
- more useful context inside fewer controls  
  
It does not mean:  
  
- more cards  
- more tabs  
- more widgets  
- more metrics  
- more labels  
- more visual noise  
  
Before adding a new visible module, ask which existing object should absorb that state.  

---
  
## 61. Third-Party Dependency Posture  
  
Ambitions is Apple-native and repo-owned first.  
  
New runtime dependencies require explicit issue-level approval.  
  
Not approved by default:  
  
- analytics SDKs  
- telemetry SDKs  
- third-party crash SDKs  
- cloud model SDKs  
- backend SDKs  
- sync SDKs outside approved Ambitions Account scope  
- remote config SDKs  
- cross-platform app frameworks  
- UI libraries replacing SwiftUI/product-owned primitives  
- visual animation SDKs  
  
Dependencies may not redefine product architecture.  

---
  
## 62. Diagnostics Posture  
  
Diagnostics are Apple-first and user-respecting.  
  
Approved diagnostic evidence:  
  
- MetricKit  
- os.Logger  
- signposts  
- Xcode crash reports  
- TestFlight crash reports when a gated TestFlight path is approved  
- local diagnostic bundles  
- user-initiated support export  
  
Diagnostics must not become:  
  
- third-party analytics  
- behavioral tracking  
- server-side profiling  
- silent telemetry  
- product-decision surveillance  
  
No third-party telemetry, crash, analytics, or session replay SDK is approved by default.  

---
  
## 63. Terminology Appendix  
  
Ambitions language has four exposure levels.  
  
The purpose of this appendix is to prevent Codex, ChatGPT, and future implementation work from exposing internal architecture as primary user interface.  
  
### A. Primary user-facing language  
  
These terms may appear prominently on root surfaces and primary actions.  
  
```
Start here
Recommended step
Start now
Open step
Step
Today
Goal
Time
Capture
You
Done
Still counts
Move it
Blocked
Waiting
Not needed
Protected
Review
Undo
Manual

```
  
  
Primary user-facing language must be plain, native, and understandable without learning Ambitions architecture.  
  
### B. Contextual user-facing language  
  
These terms may appear when attached to a clear object, state, or action.  
  
```
Fits now
Reality changed
Make today lighter
This week can hold
Open time
Goal time
Needs review
Needs a place
Ready to place
Held for review
Saved locally
Saved safely
Calendar unavailable
Reference update available
Your Direction
Your System
Shape time

```
  
  
Contextual language must not appear as abstract standalone labels. It must be attached to a visible Step, Goal, RealityWindow, CapacityShape, Capture input, setting, or closure state.  
  
### C. Inspection-only language  
  
These terms belong inside Trust, inspection, explanation, receipt, privacy, source, history, or explicit “Why this?” surfaces.  
  
```
Why this?
Source
Proof
Receipt
Receipts & History
History
Privacy
Local data
Public reference
Source Atlas
Changed by
R2 freshness
Account entitlement
Privacy boundary

```
  
  
Inspection-only language must not dominate first-viewport root surfaces.  
  
Root surfaces may show quiet trust hints, but full source/proof/receipt language belongs behind user intent, confirmation, or inspection.  
  
### D. Internal architecture language  
  
These terms may appear in source code, architecture docs, debug-only tooling, implementation plans, and Codex closeouts. They should not appear as ordinary user-facing labels unless an explicit onboarding/help/inspection context translates them.  
  
```
Private Life Runtime
Stage
RuntimeSnapshot
RuntimeMutation
StageMutation
SurfaceLens
StageScene
Reality Meridian
Constellation Atlas
LifeShape Field
Atmosphere Composer
User System Profile
Trust Seam
Receipt Surface
Semantic mirror
Projection
RuntimeProjectionPipeline
MutationProof
StageMotionEvent

```
  
  
Internal architecture language must be translated before it reaches primary UI.  
  
### Avoid in active top-level UI  
  
Do not use these terms in active root surfaces, primary CTAs, empty states, or ordinary user-facing copy.  
  
```
Dashboard
Assistant
AI recommends
AI coach
Chatbot
best next move
next best move
optimize your day
optimize your life
productivity score
life score
habit score
streak
XP
overdue
failed
streak broken
Capture Anything
Close Today
Motion Current
Plan tab
Motion tab
Capture tab
Profile tab
route reveal
receipt before save
proof seam
runtime-backed
fixture-only
local projection
mutation pipeline
blocked-pending-model
correction-shaped ledger
model confidence
AI confidence
smart capture
classification theater
GPT

```
  
  
### Translation law  
  
Use this conversion before writing UI:  
  
```
task -> Step
calendar event -> fixed point / boundary
free time -> open capacity
completed task -> closure + proof
AI suggestion -> Recommended step + Why this?
activity log -> History / Receipts
settings -> You / User System Profile
error -> what is unavailable + what still works

```
  
  
Final language rule:  
  
If a phrase sounds like it belongs in a product spec, architecture diagram, debug console, AI assistant, task app, calendar app, dashboard, or productivity score system, it does not belong in primary Ambitions UI.  

---
  
## 64. Codex Implementation Rules  
  
When Codex implements against this canon:  
  
- Work from product law first.  
- Inspect live source before editing.  
- Do not assume file names prove behavior.  
- Do not create placeholder folders without functional contracts.  
- Do not reintroduce `RootTab` as root architecture.  
- Do not create `Surfaces/Motion`.  
- Do not create `Surfaces/Capture`.  
- Do not leak runtime vocabulary into top-level UI.  
- Do not use generic cards as the primary visual grammar.  
- Do not report Green without screenshots and validation.  
- Do not claim tests passed unless commands were run.  
- Do not silently skip accessibility, safe-area, or Dynamic Type checks.  
- Do not make account sign-in required for core local use.  
- Do not make R2 required for core local value.  
  
Every closeout should include:  
  
```
Status: Green / Yellow / Red
Scope completed:
Files changed:
Product law preserved:
Validation run:
Validation not run:
Proof artifacts:
Known risks:
Follow-up required:
Rollback plan:

```
  

---
  
## 65. Codex Frontend Checklist  
  
Before implementing any frontend object, Codex must answer:  
  
1. What product object is this?  
2. Which surface owns it?  
3. Which user job does it serve?  
4. What states does it support?  
5. What is the empty state?  
6. What is the dense state?  
7. What is the broken-source state?  
8. What is the recovery state?  
9. What source/trust behavior is required?  
10. What receipt/proof behavior is required?  
11. What closure behavior is required?  
12. What accessibility summary is required?  
13. What Reduce Motion equivalent is required?  
14. What Dynamic Type behavior is required?  
15. What anti-patterns must be avoided?  
16. Which primitive should be reused?  
17. Does this create a primitive that needs approval?  
18. Does this revive obsolete canon?  
19. Does this require hosted AI, cloud AI, or personal-data backend?  
20. Does this still feel native on iPhone?  
21. Does this preserve offline core behavior without account sign-in?  
22. Does this keep R2/reference data separate from the private life graph?  

---
  
## 66. ChatGPT Usage Guidance  
  
When this file is used as a ChatGPT Project Source:  
  
- Always treat Ambitions as a premium native iPhone-first local-first Personal Life OS.  
- Assume iOS 26 minimum.  
- Assume SwiftUI native-first architecture.  
- Assume the user wants senior-level, paste-ready guidance.  
- Ground recommendations in the active product-object model.  
- Do not recommend generic task-app, calendar, dashboard, chatbot, or tab-app patterns.  
- When asked for frontend architecture, preserve the final tree unless explicitly asked to revise it.  
- When asked for UI direction, use Today / Goals / Time / You as persistent surfaces.  
- When asked about Capture, treat it as Composer/Overlay.  
- When asked about Motion, treat it as Stage/Motion behavior.  
- When asked about Proof/Source/Receipts, treat them as Trust inspection details.  
- When asked about R2/Source Atlas, treat it as public/reference/freshness infrastructure, not personal data storage.  
- When asked about accounts, treat Ambitions Accounts as optional launch identity/entitlement infrastructure that does not weaken offline core behavior.  
- When asked for Codex prompts, include acceptance gates, validation, proof artifacts, and rollback behavior.  
  
Default response posture:  
  
- senior product architect  
- iOS SwiftUI engineer  
- design systems lead  
- local-first privacy architect  
- QA/release engineer  
- repo-governance operator  
  
Avoid weak first drafts. Do not provide a “good enough MVP” plan when the ask concerns Ambitions canon, architecture, visual system, or release readiness.  

---
  
## 67. Final Non-Negotiables  
  
- Ambitions is one adaptive object stage.  
- Today / Goals / Time / You are the only persistent stage surfaces.  
- Capture is the global composer.  
- Motion is cross-surface behavior.  
- Proof / Source / Privacy / History / Receipts are inspectable trust details.  
- Root dock appears only at root.  
- Drilldowns use native back behavior.  
- Time is real and clock-backed.  
- Every meaningful action visibly mutates the stage.  
- Every Canvas object has a semantic mirror.  
- Every morph has a reduced-motion fallback.  
- Every top-level surface has one primary object.  
- Every top-level surface avoids raw runtime jargon.  
- Every train produces proof artifacts.  
- Offline core app value works with no account.  
- Ambitions Accounts launch with Sign in with Apple and Google Sign-In.  
- R2 is first-class for Source Atlas/reference freshness.  
- R2 is not a personal-data backend.  
- Hosted AI services and cloud LLMs are not core architecture.  
- No canon update is Green until readback proves the full file is intact.  
  
This is the canon.  
