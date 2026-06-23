# PRODUCT_DESIGN_TRUTH.md — Ambitions Product / Design / Runtime Canon

**Recommended path:** `docs/truth/PRODUCT_DESIGN_TRUTH.md`  
**Status:** Active product/design source of truth; canonical product-source root  
**Applies to:** native SwiftUI, iPhone-first, local-first Ambitions architecture  
**Owner posture:** Product/design truth, not implementation proof  
**Last updated:** 2026-06-22

This file is the compact canonical root. Detailed runtime-remediation canon for the 2026-06-22 device review is installed in the linked decision register, ADR, remediation law, and Codex dossiers.

---

## 0. Canon Authority

Ambitions is a premium native iPhone-first, local-first Personal Life OS. It is not a tab app, task app, calendar clone, habit tracker, chatbot, dashboard, generic AI productivity wrapper, or web-app shell.

This canon exists to prevent Ambitions from regressing into:

- static card stacks,
- verbose architecture UI,
- fake glass,
- internal runtime jargon,
- non-mutating controls,
- prototype shell chrome,
- debug-console trust language,
- hosted/cloud AI dependency,
- hosted personal-data backend assumptions,
- commodity task-app, calendar-app, notes-app, or dashboard patterns.

Root product posture:

- One native Stage.
- Four persistent surfaces.
- One global composer.
- One cross-surface motion layer.
- One inspectable trust layer.
- Local-first runtime truth.
- Visible mutation after every meaningful action.

---

## 0A. 2026-06-22 Runtime Remediation Canon Amendment

The active runtime remediation decisions are canonicalized in:

- `docs/truth/2026-06-22-runtime-remediation-decision-register.md`
- `docs/qa/remediation/2026-06-22-codex-remediation-law.md`

These decisions refine the remediation implementation path after the 2026-06-22 runtime device review and the QA project `Ambitions Runtime QA Remediation — 2026-06-22 Device Review`.

Key laws:

1. Codex must not be handed vague “fix this” issues. Every execution train requires a repo-backed implementation dossier.
2. Runtime app paths must be real. Fake success, fake placement, dead controls, and source-only closure are forbidden.
3. Ambitions may contain best-in-class task behavior as a feature. The user-facing object is Step. Free-floating Steps are valid when no Goal currently fits.
4. Capture is the global typed route graph and full-screen Stage composer for goals, steps, thoughts, proof, protected time, constraints, and attachments.
5. Goals root is a broad customizable Life Area Atlas. Goal Detail is an operational path timeline and historical journal.
6. Today is a visually rich, actionable Reality Window with state-gated actions.
7. Time is Ambitions’ native Life Calendar: calendar-grade, Apple-native, and enriched by capacity, protection, placement, proof, recovery, and goal-path intelligence.
8. Search is a local-only Find / Act / Inspect surface.
9. You is Apple iOS Settings structure + ChatGPT iOS settings clarity + Ambitions privacy/local-first cohesion.
10. Shell is Stage OS: icon-only root navigation, global gestures, route depth, safe areas, motion, haptics, and accessibility.
11. Copy must be minimal, icon-first, and progressively disclosed.
12. Root surfaces must not expose internal architecture names.
13. Proof and owner acceptance are required before Done.

If this amendment conflicts with older wording that says Ambitions must not be a task app or calendar clone, interpret the older law as brand/IA law, not capability prohibition:

- Ambitions is not framed as a task app, but it must support first-class Step/free-floating-step behavior.
- Ambitions is not a calendar clone, but Time is a first-class native Life Calendar.

---

## 1. Locked Product Law

Ambitions has four persistent Stage surfaces:

```text
Today / Goals / Time / You
```

Ambitions has one global composer:

```text
Capture
```

Ambitions has one cross-surface behavior layer:

```text
Motion
```

Ambitions has one inspectable trust layer:

```text
Proof / Source / Privacy / History / Receipts
```

Every meaningful user action must produce:

```text
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

```text
Ambitions helps life make sense, then helps the user start what fits.
```

Ambitions may contain Steps, time boundaries, routines, reminders, captures, goal planning, proof, intelligent recommendations, and task-app-grade execution capability. It must never collapse into the commodity UI or architecture patterns of those categories.

Ambitions is not:

- a task app,
- a calendar clone,
- a habit tracker,
- a chatbot,
- a dashboard,
- a generic AI planner,
- a notes app,
- a productivity scoring system,
- a web-app shell.

Correction law for 2026-06-22 remediation: Ambitions may contain best-in-class task behavior as a contained feature. The user-facing execution object is `Step`. Free-floating Steps are valid when no Goal currently fits. Ambitions must not frame itself as a task app.

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

Ambitions does not promise perfect productivity, total automation, life optimization, AI coaching, or frictionless self-improvement. It promises a calmer, more truthful relationship between intention and reality.

Codex implementation law:

```text
Every product surface must help the user place input, understand capacity, start what fits, close what changed, preserve proof, recover without shame, or control the system.
```

---

## 4. Private Life Runtime Moat

Ambitions’ moat is the Private Life Runtime: a local, inspectable, user-controlled life graph that turns intent into reality-fit action, then preserves what changed over time.

Canonical runtime continuity:

```text
Identity Direction
  -> Life Area
    -> Goal Thread
      -> Step
        -> Closure Event
          -> Proof
            -> Reflection
              -> Adaptation / Recovery
```

The moat is the continuity between:

```text
what matters
what life can hold
what fits now
what the user did
what changed
what still counts
what needs recovery
what Ambitions should remember locally
```

Source Atlas and R2 may enrich public/reference/freshness context, but they do not own or receive the private life graph.

Hard red moat failures:

```text
external LLM required for core behavior
hosted AI service required for core behavior
hosted personal-data backend
server-side user profiling
Motion as a root surface
Capture as a root surface
generic task-list-only execution
calendar-clone-only scheduling
dashboard analytics as root value
productivity scoring
streak pressure
hidden recommendation behavior
uninspectable learning
```

---

## 5. Local-Only Architecture

Core personal life data must live on-device by default. This includes goals, life areas, captures, Steps, thoughts, schedule assumptions, protected time, closure history, receipts, proof, pivots, recovery history, personalization, private user context, and recommendation history.

Private life data is local by default. Network access may enrich public/reference data, validate entitlements, support optional Ambitions Account capabilities, or support approved account recovery. Network access must not become the core runtime.

The Private Life Runtime must work without an account and without network access.

R2 is first-class infrastructure for Source Atlas/reference freshness. R2 is not a personal-data backend and must not receive the private life graph.

---

## 6. Surface Laws

### Today

Today is a visually rich, actionable Reality Window. It is not a planner, task list, dashboard, timeline clone, or CTA stack. It shows the current day’s usable reality and the Step/action that fits. Actions are state-gated. Closure appears only when a real Step has been started or is proof-eligible. Generic `Capture what changed`, Start Here/Meridian toggles, root rail copy, and nonsemantic icons are forbidden.

### Goals

Goals root is a customizable Life Area Atlas. Life areas are broad, customizable organizing regions. Goals, free-floating Steps, thoughts, proof, receipts, settings, and history live inside area drilldowns. Goal Detail is a profile + operational path surface + historical journal with a scrubbable path field, proof stitches, future-path editing, recovery, accomplishment, and Today/Time/Capture relationships.

### Time

Time is Ambitions’ native Life Calendar: as obvious as Apple Calendar, as rich as Weather, and as intelligent as the Private Life Runtime. It is a first-class calendar-grade surface enriched by open capacity, protected time, pressure, recovery, goal load, transition, proof residue, placement, and conflict proposals. It is not an anti-calendar. It must be rich, robust, Apple-native, and obvious.

### You

You is Apple iOS Settings structure plus ChatGPT iOS settings clarity/compactness plus Ambitions privacy/local-first cohesion. It is not a dashboard, product manifesto, or diagnostic console. Every visible row opens real detail or an honest unavailable state.

### Capture

Capture is the global typed route graph and full-screen Stage composer. It handles free capture, goal seed, step seed, proof, time protect, note/thought, constraints/fixed points, and attachments. Capture is not a root tab, half sheet, quick box, fake route UI, or category wall. Voice uses native keyboard dictation for this remediation. Attachments are real local capture attachments.

### Search

Search is a local-only Find / Act / Inspect surface backed by deterministic local indexing. It is not a chatbot, shallow sheet, or cloud/LLM search path. Search can navigate precisely and hand creation intent to Capture, but mutations must be state-gated and receipt-backed.

### Shell

Shell is Stage OS. It owns four icon-only root navigation buttons, route depth, global gestures, Capture/Search access, safe-area behavior, motion, haptics, accessibility actions, and semantic glyphs. Root dock appears only at root. No persistent Capture/Search buttons. No bordered dock. No visible tab labels except onboarding, long press, and accessibility.

---

## 7. ChatGPT Usage Guidance

When this file is used as ChatGPT Project Source:

- Always treat Ambitions as a premium native iPhone-first local-first Personal Life OS.
- Ground recommendations in the active product-object model.
- Do not recommend generic task-app, calendar-clone-only, dashboard, chatbot, or tab-app patterns.
- When asked about Capture, treat it as the global typed route graph and full-screen composer.
- When asked about Time, treat it as native Life Calendar.
- When asked about Motion, treat it as cross-surface behavior.
- When asked about Proof/Source/Receipts, treat them as inspectable trust details.
- When asked about R2/Source Atlas, treat it as public/reference/freshness infrastructure, not personal data storage.
- When asked for Codex prompts, include product law, architecture law, deletion/replacement law, acceptance gates, validation, proof artifacts, known-issues updates, and rollback behavior.

Default response posture:

- senior product architect,
- iOS SwiftUI engineer,
- design systems lead,
- local-first privacy architect,
- QA/release engineer,
- repo-governance operator.

Avoid weak first drafts. Do not provide a “good enough MVP” plan when the ask concerns Ambitions canon, architecture, visual system, Codex, QA, or release readiness.

---

## 8. Final Non-Negotiables

- Ambitions is one adaptive object Stage.
- Today / Goals / Time / You are the only persistent Stage surfaces.
- Capture is the global composer.
- Motion is cross-surface behavior.
- Proof / Source / Privacy / History / Receipts are inspectable trust details.
- Root dock appears only at root.
- Drilldowns use native back behavior.
- Time is clock-backed, calendar-grade, and real.
- Every meaningful action visibly mutates the stage.
- Every Canvas/product object has a semantic mirror.
- Every morph has a reduced-motion fallback.
- Every top-level surface has one primary object.
- Every top-level surface avoids raw runtime jargon.
- Every train produces proof artifacts.
- Offline core app value works with no account.
- Ambitions Accounts do not weaken offline core behavior.
- R2 is first-class for Source Atlas/reference freshness.
- R2 is not a personal-data backend.
- Hosted AI services and cloud LLMs are not core architecture.
- No canon update is Green until readback proves the file is intact.

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

- ==RootTab.swift== as root architecture
- ==TabView== as the top-level product model
- ==Surfaces/Motion/==
- ==Surfaces/Capture/==
- ==Projection/SurfaceLenses/MotionLens.swift==
- ==Projection/StageScenes/MotionStageScene.swift==
- ==Scenarios/MotionScenarios.swift== as a top-level surface scenario

---

This is the canon.

