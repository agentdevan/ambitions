# PRODUCT_DESIGN_TRUTH.md — Ambitions Object-Stage Architecture + Interaction Canon  
  
**Recommended path:** `docs/truth/PRODUCT_DESIGN_TRUTH.md`
  
**Status:** Canonical product-source root  
  
**Applies to:** iOS 26 minimum, native SwiftUI, local-first Ambitions architecture  
  
**Last updated:** 2026-06-16  
  
**Supersedes / merges:**  
  
- `Ambitions_Object_Stage_Architecture_Source.md`  
- `Ambitions Interaction Reference Synthesis.md`  

---
  
## 0. Canon authority  
  
This document is the canonical frontend architecture, interaction, design-system, QA, and Codex reference for Ambitions.  
  
Use this document whenever generating product, design, SwiftUI, Codex, QA, repo-governance, release, accessibility, privacy, or implementation guidance for Ambitions.  
  
Ambitions is a premium native iPhone-first, local-first Personal Life OS. It is not a tab app, task app, calendar clone, habit tracker, chatbot, dashboard, generic AI productivity wrapper, or web-app shell.  
  
This canon exists to prevent Ambitions from regressing into:  
  
five tabs   
static cards   
verbose architecture UI   
fake glass   
internal runtime jargon   
non-mutating controls   
prototype shell chrome   
debug-console trust language  
  
The root product posture is:  
  
One native stage.   
Four persistent surfaces.   
One global composer.   
One cross-surface motion layer.   
One inspectable trust layer.   
Local-first runtime truth.   
Visible mutation after every meaningful action.  

---
  
## 1. Locked product law  
  
Ambitions has four persistent stage surfaces:   
Today / Goals / Time / You  
  
Ambitions has one global composer:   
Capture  
  
Ambitions has one cross-surface behavior layer:   
Motion  
  
Ambitions has one inspectable trust layer:   
Proof / Source / Privacy / History / Receipts  
  
Every user action must produce:   
runtime mutation   
visible stage mutation   
accessible state change   
safe fallback   
proof artifact  
  
This is the highest-level law. Do not weaken it.  

---
  
## 2. Authority and conflict rules  
  
When this canon is used with other project sources, apply these precedence rules.  
  
If documents conflict on folder topology, this architecture tree wins.   
If documents conflict on interaction behavior, the stricter interaction law wins unless it violates product law.   
If documents conflict on user-facing language, the stricter language restriction wins.   
If documents conflict on Motion, Motion is never a top-level surface.   
If documents conflict on Capture, Capture is always Composer/Overlay, never a persistent surface.   
If documents conflict on Proof/Source/Receipts, those concepts are inspectable trust details, not primary UI.   
If documents conflict on iOS chrome, native iOS behavior wins unless a product-specific object-stage behavior is explicitly required.  
  
Codex and ChatGPT must treat this document as the source of truth unless a newer `docs/truth/` canon explicitly supersedes it.  

---
  
## 3. Product classification
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
  
  
### Product role law  
  
Today is a place.   
Goals is a place.   
Time is a place.   
You is a place.   
Capture is an act.   
Motion is behavior.   
Proof is evidence.   
Receipts are inspection.   
Source is explanation.   
Privacy is boundary.  

---
  
## 4. Core architectural thesis  
  
Ambitions should feel like one continuous native iPhone stage whose primary object changes, not like independent screens behind a tab bar.  
  
The app root is `AmbitionsStage`, not a tab controller.  
  
Persistent surfaces are stage states, not tabs.  
  
Capture is a global composer, not a persistent destination.  
  
Motion is system behavior, not a destination.  
  
Proof, Source, Privacy, History, and Receipts are inspection layers, not default top-level UI.  
  
The interface should communicate runtime intelligence through fit, timing, protection, closure, proof, and recovery — not through raw architecture labels.  

---
  
## 5. iOS 26 native platform law  
  
Ambitions targets **iOS 26 minimum**.  
  
This raises the standard. The app may use modern SwiftUI, native materials, Liquid Glass, platform accessibility behavior, and object continuity, but must not become fake Apple chrome.  
  
### iOS 26 rules  
  
Use SwiftUI-native components where they serve the product.   
Use custom chrome only when the object-stage model requires it.   
Use Liquid Glass as a functional control/navigation layer, not decoration.   
Do not create translucent blobs and call them glass.   
Every glass or blur decision must preserve legibility.   
Every morph must have a Reduce Motion fallback.   
Every transparent material must have a Reduce Transparency fallback.   
Every custom Canvas-rendered object must have a semantic accessibility mirror.   
Every surface must pass Dynamic Type, VoiceOver, High Contrast, Reduce Motion, and Reduce Transparency checks.   
Real-device rendering proof is required for shell, glass, keyboard, and capture behavior.  
  
### Native chrome policy  
  
`Stage/Chrome/NativeChromePolicy.swift` and `Stage/Chrome/LiquidGlassPolicy.swift` decide:  
  
when to use native iOS controls   
when to wrap native controls in Ambitions chrome   
when to use custom Liquid Glass   
when to avoid glass entirely   
when to hide the dock   
when to collapse the crown   
when to preserve platform back behavior   
when to present full-screen overlays  
  
Custom chrome must feel native in:  
  
hit targets   
safe areas   
keyboard behavior   
VoiceOver order   
focus restoration   
scroll-edge behavior   
reduced transparency   
increased contrast   
motion reduction   
haptics   
performance  

---
  
## 6. Product translation law  
  
Borrow interaction grammar, not product identity.  

| Reference app | Borrow | Do not borrow |
| --------------- | ------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------- |
| Apple Reminders | Today clarity, date grouping, drilldown discipline, quick metadata controls, completed/flagged/urgent organization | Generic reminder/task-list identity, floating global add button, plain reminder semantics |
| Microsoft To Do | Nested steps, grouping, simple completion, notes/files, native export/share, constrained theming ideas | Generic checklist/task app model |
| ChatGPT | Composer quality, keyboard choreography, attachment/mic/voice integration, expanding field, settings organization | Chatbot framing, “ask AI” as product center |
| Apple Calendar | Live now marker, day/week/month/list orientation, Today anchor, year/month/day morphing, pinch/zoom detail density | Calendar clone, event-block visual dominance |
  
  
Ambitions translation table  

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
  
## 7. Final architecture tree  
  
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
  
```
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

```
  
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
  
```
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

```
  
Projection/   
SurfaceLenses/   
SurfaceLens.swift   
TodayLens.swift   
GoalsLens.swift   
TimeLens.swift   
YouLens.swift  
  
```
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

```
  
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
  
```
SemanticMirrors/
  MeridianSemanticModel.swift
  ConstellationSemanticModel.swift
  LifeShapeSemanticModel.swift
  MotionSemanticModel.swift

```
  
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
  
```
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

```
  
Surfaces/   
SurfaceContract.swift   
SurfacePrimaryObject.swift   
SurfaceActionContract.swift   
SurfaceDisclosureContract.swift   
SurfaceLaw.swift   
SurfaceLawAudit.swift  
  
```
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

```
  
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
  
```
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

```
  
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
  
### Explicitly removed architecture  
  
Do not reintroduce:   
RootTab.swift as root architecture   
TabView as the top-level product model   
Surfaces/Motion/   
Surfaces/Capture/   
Projection/SurfaceLenses/MotionLens.swift   
Projection/StageScenes/MotionStageScene.swift   
Scenarios/MotionScenarios.swift as a top-level surface scenario  

---
  
## 8. App layer canon  
  
### Responsibility  
  
`App/` owns launch, root environment, dependency injection, feature flags, and root stage hosting.  
  
### Required behavior  
  
The app launches into AmbitionsStageHost.   
The root is the object stage, not isolated screen prototypes.   
Feature flags cannot expose unfinished debug or internal surfaces in release.   
Environment injects clock, local store, runtime, permission coordinator, copy policy, and design policies.   
Root scene supports persistent surfaces, overlays, drilldowns, and route restoration.  
  
### Acceptance gates  
  
No release build launches into a screen prototype.   
No release build exposes Motion as a root destination.   
No release build exposes Capture as a persistent surface tab.   
No debug fixture UI appears in release.  

---
  
## 9. Stage layer canon  
  
### Responsibility  
  
`Stage/` owns the operating-system-like shell: root surfaces, overlays, transitions, chrome, safe areas, focus, gestures, effects, and mutation animations.  
  
### Required root surfaces  
  
`AmbitionsSurface` must include only:  
  
enum AmbitionsSurface: String, CaseIterable, Identifiable, Codable, Hashable {   
case today   
case goals   
case time   
case you  
  
```
var id: String { rawValue }

```
  
}  
  
No `motion`. No `capture`.  
  
### Required overlay model  
  
`StageOverlay` owns temporary/global experiences:  
  
enum StageOverlay: Equatable {   
case none   
case capture(CaptureContext)   
case search(SearchContext)   
case closure(ClosureContext)   
case inspection(InspectionContext)   
}  
  
### Required action flow  
  
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
  
### Required route types  
  
rootSurface   
surfaceDrilldown   
objectDetail   
modalOverlay   
composerOverlay   
inspectionOverlay   
searchOverlay   
closureOverlay  
  
Chrome policy matrix  

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
  
  
### Stage acceptance gates  
  
Root dock appears only on Today / Goals / Time / You root surfaces.   
Root dock is absent on every drilldown screenshot.   
Back gesture works on every drilldown.   
Top-left back arrow appears on detail routes.   
Keyboard never traps composer between dock and keyboard.   
No duplicate navigation shelf appears.   
No content hides behind chrome.   
Stage morphs maintain object continuity.   
Reduce Motion replaces morphs with restrained non-motion alternatives.   
VoiceOver focus moves predictably after surface changes, overlays, and mutations.  

---
  
## 10. Motion layer canon  
  
Motion is not a destination. Motion is a cross-surface behavior layer.  
  
### Motion appears when  
  
Step starts   
Step completes   
Step is blocked   
Step is moved   
Proof is attached   
Capture is routed   
Goal thread re-enters Today   
Time capacity changes   
Recovery is needed   
Protected boundary is created   
User undoes a mutation  
  
### Required files  
  
Stage/Motion/StageMotionState.swift   
Stage/Motion/StageMotionEvent.swift   
Stage/Motion/StageMotionLayer.swift   
Stage/Motion/StageMotionCoordinator.swift   
Stage/Motion/StageMotionRenderer.swift   
Stage/Motion/StageMotionAccessibility.swift   
Stage/Motion/StageMotionReductionPolicy.swift  
  
### Required motion states  
  
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
  
### Motion law  
  
Motion must clarify consequence, not decorate.   
Motion must reduce copy, not require copy.   
Motion must work without animation.   
Motion must have VoiceOver announcements.   
Motion must never become a root destination.   
Motion must never hide failed runtime mutations.  
  
### Motion reduced-mode law  
  
When Reduce Motion is enabled:  
  
replace morph trails with static state changes   
replace zooming with crossfade/instant hierarchy change   
replace animated proof stitches with visible final proof state   
replace moving recovery bands with stable recovery indicators   
announce meaningful state changes through accessibility  

---
  
## 11. Core domain canon  
  
`Core/Domain/` defines Ambitions-native product objects.  
  
### Step.swift must support  
  
title   
optional note   
life area   
goal thread   
scheduled date/time   
deadline   
reminder   
alarm reminder   
recurrence   
location condition   
flag / pinned state   
urgency   
substeps   
attachments   
completion state   
closure state   
proof events   
recovery impact   
source confidence   
privacy classification   
undo availability  
  
### GoalThread.swift must support  
  
goal identity   
life area   
active step chain   
recommended step relationship   
substeps / milestones   
pinned state   
blocked state   
waiting state   
proof history   
source confidence   
recovery state   
Today feed eligibility   
Time capacity pressure  
  
### RealityWindow.swift must support  
  
start time   
end time   
current fit   
fixed points   
open capacity   
protected boundary   
transition friction   
energy fit   
recommended step eligibility   
recovery requirement  
  
### CapacityShape.swift must support  
  
fixed points   
open windows   
protected windows   
pressure seams   
energy fit   
transition friction   
recovery requirement   
future horizon buckets   
past-due pressure   
capacity confidence  
  
### CaptureIntake.swift must support  
  
text   
voice transcript   
photo   
file   
scan text   
scan document   
location   
date intent   
reminder intent   
repeat intent   
goal intent   
step intent   
proof intent   
routing confidence   
needs review   
privacy classification  
  
### ClosureOutcome.swift default options  
  
Done   
Still counts   
Move it   
Blocked   
Not needed  
  
### ClosureOutcome.swift advanced options  
  
Add proof   
Add note   
Needs recovery   
Review later   
Change Goal   
Undo  
  
### UserSystemProfile.swift must support  
  
profile identity   
planning defaults   
notification preferences   
appearance preferences   
privacy preferences   
permissions   
connected sources   
history preferences   
export/share preferences   
security controls   
local authentication settings  

---
  
## 12. Core time canon  
  
`Core/Time/` makes time real, reliable, testable, and previewable.  
  
### Time law  
  
Today and Time must never show hardcoded current time.   
No production surface may render current time from fixtures.   
All current-time behavior must flow through AmbitionsClock.   
Previews and snapshots must freeze time through PreviewClock.   
Day boundary changes must not require app relaunch.   
Time zone changes must be handled deliberately.  
  
### Acceptance gates  
  
Today live now marker matches SystemClock.   
Time live now marker matches SystemClock.   
Preview scenarios use PreviewClock.   
Snapshot tests freeze time.   
Day boundary scheduler updates Today state.   
No hardcoded “Now” appears in production UI.  

---
  
## 13. Runtime canon  
  
`Core/Runtime/` converts goals, captures, context, proof, and capacity into deterministic local projections.  
  
### Runtime produces  
  
recommended step   
why it fits   
what time can hold   
what is protected   
what changed   
what needs review   
what proof exists   
what can be undone   
what requires confirmation   
what recovery is needed  
  
### UI displays  
  
Start here   
Recommended step   
Fits now   
Protected   
Done   
Move it   
Blocked   
Review   
Undo  
  
### UI must not expose by default  
  
source unavailable   
receipt before save   
proof seam   
runtime-backed   
route reveal   
local projection pipeline   
mutation validator  
  
### Runtime acceptance gates  
  
Runtime mutation is deterministic.   
Runtime validation happens before visible mutation.   
Failed runtime mutations do not animate as success.   
Proof artifacts are created for meaningful actions.   
Privacy boundary is enforced before persistence or inspection.   
Recovery output can be shown through Motion without requiring a Motion surface.  

---
  
## 14. Persistence and permissions canon  
  
### Persistence  
  
`Core/Persistence/` owns SwiftData models, repositories, migrations, local store, and store health.  
  
Required laws:  
  
Domain models do not become SwiftData models directly unless intentionally bridged.   
Migrations must be tested before release.   
StoreHealthCheck must identify broken local persistence before runtime projection depends on it.   
Local-first does not mean invisible failure.  
  
### Permissions  
  
`Core/Permissions/` owns all user permission state.  
  
Required permissions:  
  
CalendarPermission.swift   
SpeechPermission.swift   
NotificationPermission.swift   
LocalAuthenticationPolicy.swift   
PermissionCoordinator.swift  
  
Permission behavior law:  
  
Permission prompts must be contextual.   
Permission denial must leave a useful fallback.   
Permission status must not create ugly top-level warnings.   
Capture controls must explain permission state when tapped or disabled.   
You owns permission management surfaces.  

---
  
## 15. Projection canon  
  
`Projection/` translates runtime/domain state into user-facing Stage scenes, overlays, commands, and mutations.  
  
Surface lenses  

| Lens | Required product translation |
| --------------- | -------------------------------------------------------------------------------------- |
| TodayLens.swift | Now, Start Here, current window, upcoming fixed points, urgent, protected, completed |
| GoalsLens.swift | Life areas, goal threads, active step chains, pinned goals, completed milestones |
| TimeLens.swift | Day/week/month/year capacity, live now, future buckets, protected windows, pressure |
| YouLens.swift | Settings/profile sections, status summaries, permissions, privacy, appearance, history |
  
  
Overlay lenses  

| Lens | Required product translation |
| -------------------- | -------------------------------------------------------------------- |
| CaptureLens.swift | Composer state, input metadata, routing preview, review requirements |
| SearchLens.swift | Scoped search results and global expansion |
| ClosureLens.swift | Fast closure, advanced outcome options, proof note, undo state |
| InspectionLens.swift | Trust details only when requested or required |
  
  
### Mutation contract  
  
Every `StageMutation` must define:  
  
runtime mutation id   
before snapshot   
after snapshot   
target surface   
affected object ids   
visible user-facing change   
motion event   
accessibility announcement   
haptic intent   
undo availability   
proof artifact   
safe fallback if effect fails  
  
### Projection acceptance gates  
  
No lens emits forbidden top-level terms into primary UI.   
Every scene has a primary object.   
Every overlay has a clear exit.   
Every mutation has a visible consequence.   
Every mutation has an accessibility announcement or deliberate no-announcement reason.   
Every undoable mutation exposes undo.   
Every non-undoable mutation discloses that before execution.  

---
  
## 16. Language canon  
  
Language was a major failure mode. This folder must be enforcement, not decoration.  
  
### Approved primary language  
  
Use these terms prominently:  
  
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
Move it   
Blocked   
Not needed   
Waiting   
Protected   
Review   
Undo  
  
### Restricted to inspection/trust surfaces  
  
source   
proof   
receipt   
privacy boundary   
history   
local data   
why this   
changed by  
  
### Forbidden in top-level surfaces  
  
runtime-backed   
fixture-only   
route reveal   
receipt before save   
proof seam   
open seam   
local projection   
mutation pipeline   
source unavailable   
review before reflow   
ready before change   
blocked-pending-model   
correction-shaped ledger  
  
Copy budget  

| Surface    | First viewport copy budget                       |
| ---------- | ------------------------------------------------ |
| Today      | 30–45 words outside Step content                 |
| Goals      | 45–70 words outside goal titles                  |
| Time       | 45–70 words outside time labels                  |
| You        | 80–120 words across visible settings rows        |
| Capture    | 15–30 words before user input                    |
| Closure    | 20–40 words before outcome choices               |
| Inspection | Higher allowed; user explicitly requested detail |
  
  
### Native clarity law  
  
Every surface must be understandable before Ambitions-specific language is read.  
  
A user should understand:  
  
Where am I?   
What is current?   
What can I do?   
What changes if I act?   
How do I go back?   
How do I search?   
How do I capture?  
  
before they encounter deeper concepts such as proof, source, receipt, runtime, seam, continuity, or reflow.  

---
  
## 17. Trust canon  
  
`Trust/` makes Ambitions inspectable without making primary UI feel like an audit console.  
  
### Trust appears when  
  
user asks why   
a risky change will happen   
a source is missing and affects behavior   
a permission is required   
a mutation needs confirmation   
history/receipt/proof is opened   
privacy-sensitive data is involved  
  
### Disclosure levels  
  
none   
quiet status   
inline reason   
confirmation detail   
full inspection  
  
Top-level surfaces default to `none` or `quiet status`.  
  
### Trust law  
  
Trust is accessible, not ambient.   
Proof is evidence, not decoration.   
Receipts are inspectable, not primary UI.   
Source is explanation, not error copy.   
Privacy is behavior, not marketing copy.  

---
  
## 18. Interaction canon  
  
`Interaction/` owns gestures, manipulation, keyboard behavior, and haptics.  
  
Required gestures  

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
  
  
### Haptics  
  
Use restrained haptics for:  
  
Start step   
Complete step   
Protect window   
Pin goal   
Capture saved   
Undo mutation   
Zoom level snap  
  
Do not use haptic spam during scrolling, decorative motion, or passive state changes.  
  
### Direct manipulation law  
  
Every visible object must answer:  
  
tap does what?   
long press does what?   
drag does what?   
VoiceOver activate does what?   
keyboard equivalent does what?   
undo path is what?  

---
  
## 19. Rendering canon  
  
`Rendering/` renders flagship product objects and their semantic mirrors.  
  
Ambitions cannot keep using static card stacks. Rendering must make product objects legible.  
  
### Renderer responsibilities  
  
### MeridianRenderer.swift  
  
Live now marker   
Current window   
Fixed points   
Recommended step fit   
Urgent pressure   
Protected boundary   
Completed stitches   
Scrollable day orientation  
  
### ConstellationRenderer.swift  
  
Life areas   
Goal threads   
Pinned goals   
Active step chain   
Proof history hints   
Completed milestones   
No decorative meaningless nodes  
  
### LifeShapeRenderer.swift  
  
Year/month/week/day/now hierarchy   
Capacity fields   
Fixed points   
Pressure seams   
Protected windows   
Pinch detail density   
Contextual Today anchor  
  
### MotionCurrentRenderer.swift  
  
Proof stitch movement   
Recovery band appearance   
Re-entry path   
Blocked state signal   
Completion consequence   
Undo reversal   
Reduced-motion final-state equivalents  
  
### Semantic mirrors  
  
Canvas output must have accessible equivalents:  
  
VoiceOver order   
Dynamic Type fallback   
Reduced Motion fallback   
High Contrast fallback   
Text-only fallback   
Actionable semantic elements  
  
Required semantic mirror files:  
  
MeridianSemanticModel.swift   
ConstellationSemanticModel.swift   
LifeShapeSemanticModel.swift   
MotionSemanticModel.swift  

---
  
## 20. Design system canon  
  
The design system owns the visual system, product objects, accessibility policies, and native components.  
  
Product object requirements  

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
  
  
### Visual laws  
  
No generic dashboard stacks.   
No excessive borders.   
No heavy card nesting.   
No unreadable tiny metadata columns.   
No decorative lines that do not encode meaning.   
No bottom chrome covering content.   
No modal trapped between keyboard and dock.   
No fake Apple clone controls.   
No neon HUD.   
No scenic space wallpaper.   
No decorative stars.   
No web-app chrome.  
  
### Visual target  
  
70% Apple quiet luxury   
20% intelligence clarity   
10% executive command surface   
Dark graphite/OLED   
Restrained celestial atmosphere   
Premium native iPhone realism   
Calm recovery-aware tone  

---
  
## 21. Surface contracts  
  
Every surface must define:  
  
Primary object   
Default state   
Empty state   
Dense state   
Broken-source state   
Primary action   
Secondary actions   
Disclosure behavior   
Search behavior   
Accessibility behavior   
Motion behavior   
Safe-area behavior  
  
Every top-level surface must obey:  
  
one primary object in first viewport   
one primary action max in first viewport   
no raw runtime terminology   
no generic repeated card stack as primary composition   
no dock in drilldowns   
no hidden content under chrome   
no static fake fixture state  

---
  
## 22. Today surface law  
  
Today is not a task list.  
  
Today is:  
  
Reality Meridian   
Start Here Token   
Current window   
Protected boundary   
Closure/proof feedback  
  
### Today must show  
  
Live now   
Recommended step   
Current window   
Next fixed point   
Urgent pressure   
Protected boundary   
Completed closure   
Waiting/blocked   
Later today  
  
### Today visible groups  
  
Today may support these visible groups without becoming a task list:  
  
Start here   
Now   
Next fixed point   
Urgent   
Later today   
Protected   
Waiting   
Completed  
  
### Today must not show by default  
  
source unavailable   
receipt status   
route reveal   
runtime explanation   
large CTA stack   
static hardcoded time  
  
### Today acceptance gates  
  
Live now marker matches AmbitionsClock.   
Start Here appears only when meaningful.   
No-step state is quiet and clear.   
Completing a Step visibly mutates Today.   
Protected windows are understandable without paragraphs.   
Urgent pressure is visible without becoming a red alert dashboard.   
Completed state leaves a proof stitch without overwhelming the surface.  

---
  
## 23. Goals surface law  
  
Goals is not a list manager.  
  
Goals is:  
  
Constellation Atlas   
Life areas   
Goal threads   
Step chains   
Proof history  
  
### Goals must show  
  
Life areas   
Active goal threads   
Pinned goals   
Recommended step feeding Today   
Upcoming step chains   
Completed milestones   
Blocked/waiting threads  
  
### Goals must support  
  
Step substeps   
Notes   
Attachments   
Due dates   
Reminders   
Repeaters   
Proof   
Native share/export later  
  
### Goals acceptance gates  
  
Life areas are visible without becoming dashboard tiles.   
Goal threads are spatial/relational, not a plain list.   
Opening a goal hides root dock.   
Step chains are understandable.   
Pinned/urgent/completed states are meaningful.   
Recommended Step relationship to Today is visible.  

---
  
## 24. Time surface law  
  
Time is not a calendar clone.  
  
Time is:  
  
LifeShape Field   
Capacity object   
Pressure map   
Protected-boundary system  
  
### Time must always orient around  
  
Now   
Today   
Next fixed point   
Open capacity   
Protected time   
Past due pressure   
Future horizon  
  
### Time must show  
  
Live now marker   
Current date   
Fixed points   
Open capacity   
Protected windows   
Pressure seams   
Future buckets   
Day/week/month/year zoom   
View mode switcher   
Today anchor  
  
### Time horizon buckets  
  
Past due   
Today   
Tomorrow   
This week   
Rest of month   
Next month   
Quarter   
Year   
Later  
  
### Time must not become  
  
calendar clone   
block-only event grid   
verbose policy report   
generic time dashboard  
  
### Calendar translation  
  
Calendar event block:  
  
9:00–10:00 Meeting  
  
Ambitions-native translation:  
  
9:00–10:00 fixed point   
10:10–10:40 usable light window   
Recommended step fits here   
Recovery needed before next hard edge  
  
### Time acceptance gates  
  
Live now marker is accurate.   
Today anchor is obvious.   
Day/week/month/year hierarchy preserves orientation.   
Pinch zoom has explicit non-gesture alternative.   
Fixed points read as constraints, not calendar events.   
Open windows read as capacity.   
Protected windows read as boundaries.  

---
  
## 25. You surface law  
  
You is not a runtime manual.  
  
You is:  
  
User System Profile   
Settings   
Command center   
Security/privacy center   
Appearance studio   
Planning defaults   
History and export  
  
### You must show  
  
Profile header   
Personal system   
Planning defaults   
Sources & permissions   
Privacy & security   
Receipts & history   
Appearance   
Notifications   
Export & share   
Help   
About  
  
### You must use  
  
NativeSettingsGroup   
NativeSettingsRow   
Full-screen drilldowns   
Toggles where direct   
Chevrons where deeper   
Status labels where useful   
Minimal top-level scrolling  
  
### You must not show top-level  
  
runtime-backed   
fixture-only   
blocked-pending-model   
product constitution cards   
large explanatory policy cards  
  
### You acceptance gates  
  
Most major areas are visible without long scrolling.   
Rows feel native, not custom dashboard cards.   
Details hide the root dock.   
Privacy and permissions are actionable.   
Appearance Studio is controlled and premium.   
Export/share is available where appropriate.  

---
  
## 26. Capture composer law  
  
Capture is not an add sheet.  
  
Capture is:  
  
Atmosphere Composer   
Open Field   
Routing preview   
Review when needed  
  
### Capture field states  
  
Collapsed   
Focused   
Keyboard raised   
Multi-line growing   
Max-height scrolling   
Expanded full-screen   
Routing preview visible   
Ready to place   
Needs review   
Saved  
  
### Capture control tray  
  
Capture must support:  
  
Camera   
Photos   
Files   
Scan Document   
Scan Text   
Voice   
Mic dictation   
Date   
Reminder   
Alarm reminder   
Repeat   
Location   
Goal   
Flag   
Attachment   
Full-screen details  
  
### Capture routes  
  
Capture may route to:  
  
Step   
Goal   
Time boundary   
Proof   
Note   
Planning default   
User profile memory   
Review queue  
  
### Allowed placeholder examples  
  
Capture what changed…   
What should Ambitions remember?   
Add a step, change, note, or proof…  
  
### Disallowed placeholder examples  
  
Capture Anything   
Route reveal   
Receipt before save   
Needs a place   
Local receipt  
  
### Capture acceptance gates  
  
Composer slides above keyboard.   
Composer expands with text.   
Composer scrolls internally at max height.   
Expand icon appears only when useful.   
Full-screen composer has collapse and save/place controls.   
Attachment menu is clear and animated.   
Mic and voice controls are permission-aware.   
Root dock is hidden or safely displaced during keyboard entry.   
Capture never crashes when expanding.   
Capture never exposes routing internals as primary copy.  

---
  
## 27. Closure law  
  
Closure must be fast by default and deep only when needed.  
  
### Default closure options  
  
Done   
Still counts   
Move it   
Blocked   
Not needed  
  
### Advanced closure options  
  
Add proof   
Add note   
Needs recovery   
Review later   
Change Goal   
Undo  
  
### Closure acceptance gates  
  
The current Step identity is visible.   
Default outcome choices are immediately reachable.   
Advanced outcome choices are available without cluttering default closure.   
Saving closure visibly mutates Today.   
Closure can create StageMotionEvent.   
Closure can create MutationProof.   
Undo is available when safe.   
No closure sheet reads like a system report.  

---
  
## 28. Search law  
  
Search is shell-scoped and context-aware.  
  
### Search may scope to  
  
Today   
Goals   
Time   
You   
All Ambitions  
  
### Search must return  
  
Steps   
Goal threads   
Captures   
Proof/history items   
Settings/profile areas   
Time windows  
  
### Search acceptance gates  
  
Search opens as overlay, not root surface.   
Search has clear close behavior.   
Search does not expose raw runtime object names.   
Search result rows are actionable.   
Search respects privacy boundaries.  

---
  
## 29. Scenarios canon  
  
Scenarios codify the product law into testable states.  
  
### Today scenarios  
  
today_live_now_marker_matches_clock   
today_empty_state_collapses_quietly   
today_start_here_available_step   
today_urgent_pressure_visible   
today_completed_section_visible   
today_protected_window_visible   
today_later_today_grouping   
today_waiting_or_blocked_visible   
today_drilldown_hides_root_dock  
  
### Goals scenarios  
  
goals_life_area_grouping   
goals_goal_thread_with_substeps   
goals_pinned_goal   
goals_completed_milestone   
goals_blocked_thread   
goals_step_attachment   
goals_step_note   
goals_goal_detail_hides_root_dock   
goals_recommended_step_feeds_today  
  
### Time scenarios  
  
time_day_view_live_now   
time_list_view_today_anchor   
time_week_future_buckets   
time_month_to_day_morph   
time_year_to_month_morph   
time_pinch_zoom_density   
time_fixed_point_as_boundary   
time_protected_window   
time_no_calendar_block_clone  
  
### Capture scenarios  
  
capture_composer_keyboard_choreography   
capture_multiline_expansion   
capture_max_height_internal_scroll   
capture_full_screen_expansion   
capture_plus_menu_sources   
capture_date_reminder_repeat_location_controls   
capture_scan_document   
capture_scan_text   
capture_mic_permission_denied   
capture_voice_permission_granted   
capture_routing_preview_needs_review   
capture_expansion_no_crash  
  
### You scenarios  
  
you_profile_header   
you_native_settings_groups   
you_privacy_security_drilldown   
you_appearance_studio   
you_planning_defaults   
you_sources_permissions   
you_receipts_history   
you_export_share   
you_detail_hides_root_dock   
you_minimal_scroll_top_level  
  
### Motion scenarios  
  
stage_motion_step_completed   
stage_motion_step_blocked   
stage_motion_proof_attached   
stage_motion_recovery_band_visible   
stage_motion_reentry_visible   
stage_motion_mutation_undone   
cross_surface_motion_today_to_goals   
cross_surface_motion_goals_to_time   
post_mutation_today_updates   
recovery_motion_reduce_motion_fallback  
  
### Stress scenarios  
  
dynamic_type_xxxl_today   
dynamic_type_xxxl_you_settings   
voiceover_today_meridian   
voiceover_capture_composer   
reduce_motion_time_morph   
reduce_transparency_shell   
dark_graphite_high_contrast   
keyboard_safe_area_capture   
broken_calendar_permission   
empty_goals   
dense_today   
dense_time_month   
post_mutation_today_updates  

---
  
## 30. Quality canon  
  
Quality turns product law into automated gates and proof artifacts.  
  
### Required audits  
  
### ShellChromeAudit.swift  
  
Root dock only appears on root surfaces.   
No duplicate bottom navigation shelf exists.   
Root dock does not obscure content.   
Drilldowns use back arrow and gesture back.   
Composer is keyboard-safe.  
  
### ForbiddenLanguageAudit.swift  
  
Scans primary UI strings for forbidden top-level terms.   
Allows restricted terms only inside Trust/Inspection surfaces.   
Fails release build if forbidden strings appear in primary surfaces.  
  
### SafeAreaAudit.swift  
  
No shell header leaks into status bar.   
No bottom dock covers scroll content.   
Keyboard entry does not trap composer between dock and keyboard.   
All overlays respect safe area.  
  
### DynamicTypeAudit.swift  
  
No vertical letter wrapping.   
No clipped controls.   
No unreadable metadata columns.   
Settings rows remain usable.   
Composer remains usable.  
  
### MotionReductionAudit.swift  
  
All morph transitions have Reduce Motion alternatives.   
Pinch/zoom states have non-gesture alternatives.   
Mutation animations do not become required for comprehension.  
  
### VisualRegressionHarness.swift  
  
Captures root and drilldown surfaces.   
Captures graphite/OLED default.   
Captures empty, dense, broken-source, post-mutation states.   
Captures keyboard and composer states.  
  
### RealDeviceRenderChecklist.swift  
  
Validates on real iPhone hardware.   
Validates OLED graphite rendering.   
Validates keyboard behavior.   
Validates haptics.   
Validates VoiceOver.   
Validates Reduce Motion.   
Validates Reduce Transparency.   
Validates Dynamic Type.   
Validates safe area and status bar.  

---
  
## 31. Required proof artifacts  
  
Every implementation train touching this canon must produce:  
  
Root screenshots:   
Today   
Goals   
Time   
You  
  
Drilldown screenshots:   
Goal detail   
Step detail   
Time day detail   
You settings detail   
Appearance Studio   
Privacy/Security  
  
Overlay screenshots:   
Capture collapsed   
Capture focused with keyboard   
Capture expanded   
Capture source menu   
Search   
Closure   
Inspection  
  
Accessibility proof:   
VoiceOver transcript or notes   
Dynamic Type screenshots   
Reduce Motion screenshots/video   
Reduce Transparency check   
High Contrast check  
  
Mutation proof:   
Before action   
Action   
After visible state change   
Undo if supported  
  
Quality proof:   
ShellChromeAudit result   
SafeAreaAudit result   
ForbiddenLanguageAudit result   
DynamicTypeAudit result   
MotionReductionAudit result   
VisualRegressionHarness result   
RealDeviceRenderChecklist result  
  
If proof artifacts cannot be produced, the train is Yellow or Red. Do not report Green without proof.  

---
  
## 32. Green / Yellow / Red acceptance model  
  
### Green  
  
The implementation is acceptable when:  
  
User can understand the primary action on every root surface in under 3 seconds.   
Today uses live device time.   
Capture opens, expands, and saves without crash.   
Drilldowns hide the root dock.   
The keyboard never collides with shell chrome.   
You resembles a premium native settings/profile surface.   
Time can move between day/week/month/list without losing orientation.   
Goals supports life area grouping and Step chains.   
Forbidden top-level language audit passes.   
Dynamic Type, VoiceOver, Reduce Motion, Reduce Transparency, and safe-area audits pass.   
Post-mutation Today visibly updates.  
  
### Yellow  
  
Conditionally acceptable when:  
  
A feature works but visual polish is below target.   
A morph has a fallback but not final animation quality.   
Some advanced metadata is available only in detail surfaces.   
A trust explanation exists but needs copy refinement.   
A scenario passes in preview but needs real-device proof.   
A validation command was not available but the limitation is documented.  
  
Yellow may merge only with documented follow-up and proof artifacts.  
  
### Red  
  
The implementation fails if:  
  
Capture crashes.   
Mic/voice controls appear but do not function or explain permission state.   
Today shows stale or hardcoded time.   
Root dock appears in drilldowns.   
Duplicate bottom nav/shelf is visible.   
Text wraps into unreadable vertical columns.   
Primary UI exposes forbidden runtime language.   
A save/closure action causes no visible state change.   
Keyboard traps the composer.   
A top-level surface reads as internal documentation.   
Motion is reintroduced as a root surface.   
Capture is reintroduced as a persistent surface.  
  
Red cannot ship.  

---
  
## 33. Implementation priority order  
  
### P0 — Make the app operable  
  
Fix live time.   
Fix Capture crash.   
Fix keyboard/dock layering.   
Remove dock from drilldowns.   
Remove duplicate bottom navigation artifact.   
Make closure visibly mutate Today.   
Add forbidden language gate.   
Fix unreadable text wrapping.  
  
### P1 — Make core surfaces native and clear  
  
Rebuild Today around Reality Meridian + Start Here.   
Rebuild Capture around Atmosphere Composer.   
Rebuild You around native settings/profile groups.   
Rebuild Time around LifeShape Field with live now and mode switcher.   
Rebuild Goals around Constellation Atlas and Step chains.  
  
### P2 — Add living-object transitions  
  
Time year/month/week/day morph.   
Goals life area/goal/thread/step morph.   
Today meridian/current-window/step-detail morph.   
Capture collapsed/full-screen morph.   
Cross-surface proof/recovery/re-entry Motion.  
  
### P3 — Add advanced interaction depth  
  
Pinch zoom.   
Direct manipulation previews.   
Share/export.   
Advanced themes.   
Location-aware capture.   
Scan document/text flows.   
Advanced proof/history inspection.  

---
  
## 34. Codex implementation rules  
  
When Codex implements against this canon:  
  
Work from product law first.   
Inspect live source before editing.   
Do not assume file names prove behavior.   
Do not create placeholder folders without functional contracts.   
Do not reintroduce RootTab as root architecture.   
Do not create Surfaces/Motion.   
Do not create Surfaces/Capture.   
Do not leak runtime vocabulary into top-level UI.   
Do not use generic cards as the primary visual grammar.   
Do not report Green without screenshots and validation.   
Do not claim tests passed unless commands were run.   
Do not silently skip accessibility, safe-area, or Dynamic Type checks.  
  
### Codex report format  
  
Every closeout should include:  
  
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

---
  
## 35. ChatGPT usage guidance  
  
When this file is used as a ChatGPT Project Source:  
  
Always treat Ambitions as a premium native iPhone-first local-first Personal Life OS.   
Assume iOS 26 minimum.   
Assume SwiftUI native-first architecture.   
Assume the user wants senior-level, paste-ready guidance.   
Ground recommendations in the object-stage model.   
Do not recommend generic task-app, calendar, dashboard, chatbot, or tab-app patterns.   
When asked for frontend architecture, preserve the final tree unless explicitly asked to revise it.   
When asked for UI direction, use Today / Goals / Time / You as persistent surfaces.   
When asked about Capture, treat it as Composer/Overlay.   
When asked about Motion, treat it as Stage/Motion behavior.   
When asked about Proof/Source/Receipts, treat them as Trust inspection details.   
When asked for Codex prompts, include acceptance gates, validation, proof artifacts, and rollback behavior.  
  
### Default response posture  
  
Responses should act as:  
  
senior product architect   
iOS SwiftUI engineer   
design systems lead   
local-first privacy architect   
QA/release engineer   
repo-governance operator  
  
Avoid weak first drafts. Do not provide a “good enough MVP” plan when the ask concerns Ambitions canon, architecture, visual system, or release readiness.  

---
  
## 36. Final non-negotiables  
  
Ambitions is one adaptive object stage.   
Today / Goals / Time / You are the only persistent stage surfaces.   
Capture is the global composer.   
Motion is cross-surface behavior.   
Proof / Source / Privacy / History / Receipts are inspectable trust details.   
Root dock appears only at root.   
Drilldowns use native back behavior.   
Time is real and clock-backed.   
Every meaningful action visibly mutates the stage.   
Every Canvas object has a semantic mirror.   
Every morph has a reduced-motion fallback.   
Every top-level surface has one primary object.   
Every top-level surface avoids raw runtime jargon.   
Every train produces proof artifacts.  
  
This is the canon.  
