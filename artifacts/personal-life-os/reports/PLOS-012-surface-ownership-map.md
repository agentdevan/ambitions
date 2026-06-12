# PLOS-012 Surface Ownership Map

Status: Green for AMB-648 mapping scope; Yellow for named future proof limits
Linear issue: AMB-648
Parent issue: AMB-609
Program phase: PLOS-M01 live runtime truth map
Updated: 2026-06-12
Branch: main

## Closeout Header

- PLOS child closeout: yes
- Linear issue: AMB-648
- Parent issue: AMB-609
- Green/Yellow/Red status: Green for source-backed surface ownership mapping; Yellow for fixture-backed Motion state, current naming drift in surface contracts, future transformation ownership, and unproven runtime behavior.
- Pushed to main: pending at report creation
- Push hash: pending at report creation
- App source changed: no
- Runtime features implemented: no
- PLOS-M00 executed: no
- Linear identifiers used: AMB issue identifiers only
- Validation run: see Validation
- Red blockers: none
- Yellow limits: Motion is fixture-backed by default; Goals and You surface-contract object names differ from current PLOS wording; some object transformations are partial or future-owned; screenshot, accessibility, performance, privacy/legal, release, TestFlight, and App Store proof are not claimed.
- Owner approval claimed: no
- Release/TestFlight/App Store readiness claimed: no
- Next recommended action: after AMB-648 commit, push, and Linear closeout, continue AMB-649 only.

## Scope

AMB-648 / PLOS-012 maps active surface ownership from live source. It does not implement UI, centralize chrome, rename surfaces, delete stale code, implement transformations, implement Source Atlas Factory, implement Step Elasticity, implement reflow, implement CloudKit/R2 behavior, run UIQL, or execute PLOS-M02+.

Existing-first proof artifacts:

- `artifacts/personal-life-os/validation/PLOS-012-native-source-files.txt`
- `artifacts/personal-life-os/validation/PLOS-012-surface-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-012-broad-surface-search-log.txt`

## Surface Owner Table

| Surface | Product object | Shell route owner | Primary view owner | Runtime/state owner | Source, receipt, trust, or proof owner | Status |
|---|---|---|---|---|---|---|
| Today | Reality Meridian / Start Here | `AmbitionsRootView.todayNavigation()` wraps `.today` in `AppShellScaffold`; `AppTab.allCases` includes `.today` as a top-level tab. | `TodayScreen` renders `RealityMeridianView` and owns step detail, closure, rejection, and replacement sheets. | `TodayViewModel` loads `TodayExperience`; `RepositoryBackedTodayService` composes goals, captures, evidence, feedback, and next-step selector state. | Today owns action and closure flows; Goals evidence and receipts feed Today explanation; shell receipt chrome displays continuity only. | Live source path proven; runtime behavior completeness is not claimed. |
| Goals | Constellation Atlas / goal direction | `AmbitionsRootView.goalsNavigation()` wraps `.goals` in a navigation path and opens `GoalDetailScreen`. | `GoalsScreen`, `GoalsConstellationAtlasStage`, and `GoalDetailScreen`. | `GoalsViewModel` and `GoalDetailViewModel` load `GoalsOverview` and `GoalDetailPresentation`; `RepositoryBackedGoalsService` owns goal creation, goal detail, proof, and receipts. | Goal detail owns proof/trust/receipt rail behavior; created-goal receipts are surfaced through shell and Goals inline message. | Live source path proven. Yellow: `AppTab` contract currently says `Direction Atlas`, while current PLOS wording expects `Constellation Atlas`. |
| Capture | Atmosphere Composer / global action | Capture is not a top-level tab. `AmbitionsRootView.shellUtilityButtons`, `AppShellCaptureAccessModel`, `ShellOverlayState`, and `DefaultShellCommandRouter` own global Capture entry and overlay routing; Time owns the support route for the Capture screen. | `AppShellActivatedCaptureSeam`, `QuietCommandSheetView`, `CaptureScreen`, and `CaptureAtmosphereComposer`. | `CaptureViewModel` owns `CaptureViewState` and draft routing; `DefaultShellCommandRouter` creates captures through `CaptureServicing`; `AmbitionsRootView.handleCreatedGoal` can attach a capture to a created goal. | Capture owns local save receipt text and route reveal; command router and shell continuity receipt surface local-only route receipts. | Live as global/support route. Yellow: `CaptureScreenShellMode.topLevelCapture` remains as compatibility-shaped code but the screen contract forbids top-level Capture. |
| Time | LifeShape Field | `AmbitionsRootView.timeNavigation()` wraps `.time`; `TimeRouteTarget` owns capture inbox, rituals, and weekly review support routes. | `TimeScreen`, `TimeLifeShapeField`, `HabitsScreen`, and `WeeklyReviewScreen`. | `TimeViewModel` loads `TimeDashboard`; `RepositoryBackedTimeService` builds life-suite, calendar-aware, pressure, availability, and dashboard state. | Time owns calendar-awareness receipt preview and schedule/context explanation; shell owns route receipt display. | Live source path proven. Yellow: schedule install and full calendar/runtime behavior remain future phase proof. |
| Motion | Motion Current | `AmbitionsRootView.motionNavigation()` wraps `.motion` in shell chrome and opens `MotionCurrentScreen`. | `MotionCurrentScreen`, `MotionCurrentField`, `MotionContextCrown`, `MotionSourceReceiptAffordance`, and `MotionContinuityDock`. | `MotionCurrentProjection.fixture(renderState: .launchArgument)` is the default projection owner in the current screen. | Motion UI names proof, recovery, re-entry, source, and receipt lanes; no production projector was proven in this child. | Yellow: active surface exists, but default state is fixture-backed, so production runtime ownership is not Green. |
| You | User System Profile | `AmbitionsRootView.youNavigation()` wraps `.you`; `YouRouteTarget` owns monthly review and history routes. | `YouScreen`, `PersonalSystemCenterRootView`, and `YouRootDetailSheet`. | `YouViewModel` loads `YouDashboard`; `RepositoryBackedYouService` builds preferences, trust, source knowledge, notification, calendar, and system profile state. | You owns trust center, history, what-Ambitions-knows, source knowledge, and cross-surface review posture. | Live source path proven. Yellow: `AppTab` contract currently says `Personal Runtime`, while current PLOS wording expects `User System Profile`. |

Key source anchors:

- `Native/Ambitions/App/AmbitionsRootView.swift:94` shows the live `TabView` includes Today, Goals, Time, Motion, and You only.
- `Native/Ambitions/App/AppTab.swift:13` makes `AppTab.allCases` exactly Today, Goals, Time, Motion, You.
- `Native/Ambitions/App/AppTab.swift:60` canonicalizes `.capture` to `.today`, preventing Capture from being a canonical top-level tab.
- `Native/Ambitions/App/AmbitionsRootView.swift:286` owns the shell Capture button for each active tab.
- `Native/Ambitions/App/ShellCommandModels.swift:228` owns the Capture access model and surface-specific Capture entry sources.
- `Native/Ambitions/App/ShellCommandRouter.swift:102` routes `.capture` and Capture inbox requests into compatibility/support routes instead of a top-level tab.
- `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:53` defaults Motion to a fixture projection.

## Shell And Chrome Ownership

| Shell/chrome object | Owner | Evidence | Boundary |
|---|---|---|---|
| Root shell | `AmbitionsRootView` | Owns container injection, top-level `TabView`, shell dock/backdrop, activated Capture seam, overlay sheet, and continuity receipt. | Shell ownership is mapped only; no shell refactor was made. |
| Top-level tab list | `AppTab` plus `AmbitionsRootView.shellTabView` | `AppTab.allCases` excludes Capture; `TabView` declares Today, Goals, Time, Motion, You. | Historical `.capture` remains a compatibility enum case, not active IA. |
| Header rail and context crown | `AppShellScaffold` and `AppShellHeaderRail` | Root surfaces are wrapped in shell scaffold with title, subtitle, posture, and trailing utility buttons. | Per-surface standalone toolbars can still exist when `showsNavigationChrome` is true; root shell passes false for Today, Goals, Time, and You. |
| Global Capture button | `AppShellCaptureAccessModel` and `AmbitionsRootView.shellUtilityButtons` | Source mapping is per canonical tab, and toolbar IDs use `shell.<tab>.capture-button`. | Capture entry is global/contextual, not a tab. |
| Activated Capture seam | `AppShellActivatedCaptureSeam` | Rendered only when `navigation.activeOverlay?.isActivatedCaptureComposer == true`. | This is overlay chrome, not a root destination. |
| Sheet overlays | `ShellOverlayState`, `AppNavigationModel`, and `AppShellOverlayView` | Command sheet, memory lens, and create-goal overlays are owned by shell navigation. | Per-surface detail sheets remain surface-owned. |
| Custom bottom dock | `AppMeridianDestinationRail` via `AmbitionsRootView.shellVisibleDock` | Uses `navigation.selectedTab` and top-level tab selection. | No dock behavior or visuals changed. |
| Continuity receipt chrome | `AmbitionsRootView.shellContinuityReceipt` | Displays `navigation.continuityReceipt` through `AmbitionActionClosureTray`. | Display-only shell receipt; source/replay wiring stays with runtime/proof owners. |
| Trust/history/source drill-downs | Per-surface plus You | Today, Goals, Capture, Time, and Motion own local trust/proof states; You owns system-wide trust/history/source surfaces. | No single global trust route is proven complete in this child. |

## Surface-To-Surface Object Transformations

| Transformation | Current owner | Source proof | Status |
|---|---|---|---|
| Capture Item -> Held Item / Step / Goal Thread | Capture + shell command router + Goals | Capture overlay saves through `captureService.createCapture`; Capture and shell can call `presentCreateGoal`; `AmbitionsRootView.handleCreatedGoal` attaches a capture to a created goal when possible. | Partial/live. Goal creation and capture binding exist; full Source Atlas/Step transformation quality is future-owned. |
| Goal Thread -> Recommended step | Goals + Today | `RepositoryBackedTodayService` loads active goals and uses next-step selector state to produce Today experience. | Partial/live. Specific Step Quality Firewall and Source Atlas authority proof remain later PLOS scope. |
| Step -> Active Step / Closure Event / Receipt | Today + Goals | `TodayScreen` owns step detail, session, closure, rejection, and replacement sheets; Goals evidence/receipts feed Today state. | Partial/live. Full receipt/replay and Step Elasticity behavior are not claimed. |
| Time Block -> Open / Goal Time / Protected / Pressure | Time | `RepositoryBackedTimeService` builds Time dashboard, availability, pressure, week days, and calendar-aware state. | Partial/live. Schedule Install Kernel remains future-owned. |
| Day -> Reality Meridian state | Today | `TodayViewModel` loads `TodayExperience`; `RealityMeridianView` renders loaded Today state. | Live source path proven; runtime behavior proof not claimed. |
| Closure Event -> Proof | Today + Goals + Motion | Today owns closure UI; Goals owns evidence/proof detail; Motion presents proof lane language. | Partial. Motion proof lane is fixture-backed by default. |
| Pivot -> Proof Transfer / Recovery Thread | Today + Motion + Goals | Today owns replacement/rejection/recovery flows; Motion projection names recovery and proof-transfer lanes. | Partial. Production runtime proof-transfer ownership is future-owned. |
| Receipt -> Trust history | Shell + You + Goals | Shell displays continuity receipt; Goals owns goal receipts; You owns trust/history and source knowledge projections. | Partial. Global receipt history and replay proof remain later PLOS scope. |
| Proof / Recovery / Change -> Year / history / sharing later | You + future PLOS owners | You owns history routes; current M20/M21 later phases own sharing and Year systems. | Future-owned. No sharing or Year runtime claim. |

## UI Drift Risks

| Risk | Severity | Evidence | Current boundary |
|---|---|---|---|
| Capture could be misread as a top-level tab because `.capture` exists in `AppTab`. | Red if treated as active IA; controlled now. | `AppTab.allCases` excludes Capture and `canonicalTopLevelTab` maps Capture to Today. | Keep compatibility classification explicit; do not create Capture tab. |
| Capture screen has a `topLevelCapture` shell mode name. | Yellow. | `CaptureScreenShellMode` includes compatibility-shaped top-level language while `CaptureObjectStagePrimitiveContract` forbids top-level tab patterns. | Classify as drift risk; do not rename in AMB-648. |
| Goals object naming drift. | Yellow. | Current `AppTab` contract says `Direction Atlas`; active PLOS issue expects `Constellation Atlas`. | Record for future source/copy harmonization; no source edit in this child. |
| You object naming drift. | Yellow. | Current `AppTab` contract says `Personal Runtime`; active PLOS issue expects `User System Profile`. | Record for future source/copy harmonization; no source edit in this child. |
| Legacy IA route compatibility can be mistaken for active IA. | Red if used as current truth. | `LegacyIARouteCompatibility` maps `pulse`, `plan`, `habits`, `profile`, and `insights` into active destinations. | Treat as compatibility only. |
| Standalone per-surface navigation chrome can duplicate shell chrome if root flags change. | Yellow. | Root shell passes `showsNavigationChrome: false`, but surface screens retain optional navigation titles/toolbars. | Current root is controlled; future UI work should preserve the shell contract. |
| Motion can look production-owned because the surface is live in the tab shell. | Yellow. | `MotionCurrentScreen` defaults to `MotionCurrentProjection.fixture(renderState: .launchArgument)`. | Surface path is live; production model ownership is not Green. |
| Trust/receipt ownership is distributed. | Yellow. | Shell displays continuity receipts, while Today/Goals/You/Capture/Motion own local proof/trust semantics. | Later runtime model and production-vs-fixture children must separate owners before runtime Green. |

## M10 Golden Slice Surface Priority

1. Capture intake: Global Capture / Atmosphere Composer must create or hold context without becoming a top-level tab, with local receipt and route explanation.
2. Goal path: Goals / Constellation Atlas and Goal Detail must convert a seed into an inspectable goal thread without claiming unsupported source authority.
3. Recommended step: Today / Reality Meridian must show one Recommended step, reason, source, time/capacity context, and recovery boundary.
4. Time context: Time / LifeShape Field must show open, goal, protected, and pressure state that can explain why the Recommended step fits now.
5. Trust drill-down: You / User System Profile must expose source, receipt, what-Ambitions-knows, history, and correction controls.
6. Proof and recovery: Motion / Motion Current should become production-backed before it can carry proof-transfer or recovery-thread Green.
7. Later share/year outputs: Progress Story and Year outputs remain future PLOS-M20/M21 scope and must not be claimed by M10 until proof, redaction, and sharing laws are satisfied.

## Validation

Commands run for AMB-648:

- `git status --short --branch --ahead-behind`
- `git pull --ff-only`
- Linear issue fetch for `AMB-648`
- Linear status update for `AMB-648` to In Progress
- `find Native Sources -maxdepth 5 -type f | sort > artifacts/personal-life-os/validation/PLOS-012-native-source-files.txt`
- `rg -n "Today|Reality Meridian|Goals|Constellation|Capture|Atmosphere|Time|LifeShape|You|User System|TabView|NavigationStack|Receipt|Proof|Trust|Source Settings|toolbar|header|tab" Native Sources docs > artifacts/personal-life-os/validation/PLOS-012-surface-search-log.txt`
- `rg -n "struct .*View|enum .*Tab|TabView|NavigationStack|Today|Reality Meridian|Goals|Constellation|Capture|Atmosphere|Time|LifeShape|You|User System|Source Settings|Receipt|Trust|Proof|Context Crown|Continuity Dock|toolbar|header|tab" Native Sources . --glob "*.swift" --glob "*.md" > artifacts/personal-life-os/validation/PLOS-012-broad-surface-search-log.txt`
- Focused source inspection over root shell, app tabs, navigation, command router, shell overlays, Today, Goals, Capture, Time, Motion, You, services, and proof/trust routes.

Validation to run before commit closeout:

- `git diff --check`
- `git diff --cached --check`
- `python3 -m json.tool artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.json`
- `scripts/codex/program-preflight.sh plos`
- `scripts/codex/program-phase-gate.sh plos M01`
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-012-surface-ownership-map.md`
- `bash scripts/codex/program-proof-index.sh plos`

Not run:

- Build/test/screenshot/accessibility/performance validation was not run because AMB-648 is a read-only source mapping/proof artifact child and no app source, project, UI, runtime, or test source files were changed. No release, UI, accessibility, or runtime behavior claim is made.

## Verdict

Green for AMB-648 scope: the active surfaces, shell/chrome ownership, object transformations, drift risks, and M10 priority surfaces are mapped from live source and validation artifacts.

Yellow limits remain: Motion production state ownership is not Green; current Goals/You object names in source contract differ from PLOS wording; distributed trust/receipt ownership needs AMB-649/AMB-651 classification; transformations are partial or future-owned; runtime behavior, screenshot, accessibility, performance, privacy/legal, release, TestFlight, and App Store readiness are not claimed.

Red blockers: none.
