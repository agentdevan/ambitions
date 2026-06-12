# PLOS-010 Active Runtime Path Proof

Status: Green for source-path proof and build-for-testing compile proof
Program: PLOS Runtime Master Build
Phase: PLOS-M01 / AMB-609
Child: PLOS-010 / AMB-646
Created: 2026-06-12
Branch policy: main only
App source changed: no
Runtime features implemented: no

## Scope

AMB-646 proves the current live app runtime path from app launch into the locked Ambitions shell and maps existing Step, receipt, proof, source, and trust routes. This report is read-only source proof. It does not rename surfaces, repair UI, implement Source Atlas Factory, implement Step Elasticity, implement reflow, change CloudKit/R2 behavior, or claim release readiness.

## Required Existing-First Inspection

| Command | Result |
|---|---|
| `git status --short` | Ran before inspection; only PLOS-010 validation artifacts were untracked after required log generation. |
| `find . -maxdepth 4 -type f \( -name "*.swift" -o -name "*.md" -o -name "*.yml" -o -name "*.yaml" \) \| sort > artifacts/personal-life-os/validation/PLOS-010-file-list.txt` | Produced `artifacts/personal-life-os/validation/PLOS-010-file-list.txt` with 1,625 paths. |
| `rg -n "@main\|LaunchGateView\|AmbitionsRootView\|TabView\|Today\|Goals\|Capture\|Time\|You\|Step\|Receipt\|Replay\|Proof\|Source Settings" Native Sources . --glob "*.swift" --glob "*.md" > artifacts/personal-life-os/validation/PLOS-010-runtime-search-log.txt` | Produced `artifacts/personal-life-os/validation/PLOS-010-runtime-search-log.txt` with 47,850 matches. |
| `scripts/ambitions-xcode-build-for-testing.sh --batch AMB-646` | Passed. Summary: `.codex/xcode-summaries/AMB-646/20260612T193931Z-bft-70782-12898/build-for-testing-summary.json`; result bundle: `.codex/xcode-results/AMB-646/20260612T193931Z-bft-70782-12898/build-for-testing.xcresult`; log: `.codex/xcode-logs/AMB-646/20260612T193931Z-bft-70782-12898/build-for-testing.log`. Wrapper emitted a transient missing-result-bundle line before the bundle was present; summary status is `passed` and the `.xcresult` exists. |

## App Launch Chain

| File | Type/function | Line range | Evidence excerpt | Runtime role | Confidence |
|---|---|---:|---|---|---|
| `project.yml` | `Ambitions` target | 15-24 | `targets` -> `Ambitions` application sources include `Native/Ambitions`. | Proves the app target compiles Swift under `Native/Ambitions`; excludes markdown/resources/support plist from app source. | High |
| `Native/Ambitions/App/AmbitionsApp.swift` | `@main struct AmbitionsApp: App` | 3-15 | `@main`; `struct AmbitionsApp: App`; `WindowGroup { LaunchGateView(bootstrapper: bootstrapper) }`. | Live app entry point. | High |
| `Native/Ambitions/App/AmbitionsApp.swift` | app lifecycle wiring | 16-31 | `onOpenURL`, `onAppear`, and scene phase call bootstrapper deep-link, pending app intent, external creation, and lifecycle reconciliation methods. | App lifecycle and external route ingress feed the bootstrapper. | High |
| `Native/Ambitions/App/AppBootstrapper.swift` | `AppBootstrapper.start()` | 35-50 | `AppContainerFactory.make(configuration: resolvedConfiguration)` then `phase = .ready(container)`. | Builds the live app container before root view is shown. | High |
| `Native/Ambitions/UI/LaunchGateView.swift` | `LaunchGateView.body` | 4-20 | `switch bootstrapper.phase`; `.ready(container): AmbitionsRootView(container: container)`; `.task { await bootstrapper.start() }`. | Launch gate transitions from loading/failure into the live root. | High |
| `Native/Ambitions/App/AppContainerFactory.swift` | `make(configuration:)` | 51-109 | Prepares repositories, builds `AmbitionsRuntimeFactory.make`, creates navigation, runtime services, command router, memory lens service, onboarding service, and returns `AppContainer`. | App state/store/service injection source. | High |
| `Native/Ambitions/Runtime/AmbitionsRuntimeFactory.swift` | `AmbitionsRuntimeFactory.make` | 3-14, 46-126 | Constructs local runtime services and returns `AmbitionsRuntime` with Today, Goals, Capture, Time, You, action executor, snapshot writer, kernel, and prototype runtime. | Active runtime service construction. | High |
| `Native/Ambitions/Runtime/AmbitionsRuntimeContracts.swift` | `final class AmbitionsRuntime` | 156-223 | Stores `repositories`, `todayService`, `goalsService`, `captureService`, `timeService`, `youService`, `privateLifeRuntimeKernel`, and other runtime dependencies. | Runtime model/service ownership container. | High |
| `Native/Ambitions/App/AppContainer.swift` | `final class AppContainer` | 7-43, 69-104 | Exposes shell, runtime, persistence, platform, user-system, feature-factory capabilities and services. | Dependency container passed into root and environment. | High |
| `Native/Ambitions/App/AppEnvironment.swift` | `View.appContainer(_:)` | 68-78 | Injects `appContainer`, shell, runtime, persistence, platform, user system, and feature factory capabilities into environment. | Environment injection for screens and shell. | High |
| `Native/Ambitions/App/AmbitionsRootView.swift` | `AmbitionsRootView.body` | 29-91 | ZStack contains `shellTabView`, dock, Capture seam, continuity receipt; attaches `.appContainer(container)` and `.ambitionTheme(resolvedTheme)`. | Live shell root. | High |
| `Native/Ambitions/App/AmbitionsRootView.swift` | `shellTabView` | 94-128 | `TabView(selection: $navigation.selectedTab)` with tabs for Today, Goals, Time, Motion, You. | Live SwiftUI top-level navigation container. | High |

Runtime path diagram:

```text
Ambitions target (project.yml)
  -> AmbitionsApp @main
  -> WindowGroup
  -> LaunchGateView
  -> AppBootstrapper.start()
  -> AppContainerFactory.make()
  -> AmbitionsRuntimeFactory.make()
  -> AppContainer
  -> AmbitionsRootView
  -> SwiftUI TabView
  -> Today / Goals / Time / Motion / You NavigationStacks
  -> environment-injected shell/runtime/persistence/platform/user-system/feature-factory capabilities
```

## Locked IA Proof

| Surface | Live route evidence | Classification |
|---|---|---|
| Today | `AmbitionsRootView.shellTabView` renders `Tab(AppTab.today.title...)` at lines 97-99; `todayNavigation()` wraps `TodayScreen` in `NavigationStack` at lines 144-154. | Live top-level tab. |
| Goals | `shellTabView` renders Goals at lines 101-103; `goalsNavigation()` wraps `GoalsScreen` and `GoalDetailScreen` destinations at lines 157-177. | Live top-level tab. |
| Time | `shellTabView` renders Time at lines 105-107; `timeNavigation()` wraps `TimeScreen` and Time route destinations at lines 180-229. | Live top-level tab. |
| Motion | `shellTabView` renders Motion at lines 109-111; `motionNavigation()` wraps `MotionCurrentScreen` at lines 233-244. | Live top-level tab. |
| You | `shellTabView` renders You at lines 113-115; `youNavigation()` wraps `YouScreen` and You route destinations at lines 247-283. | Live top-level tab. |
| Capture | `AppTab` keeps a `.capture` case for compatibility at lines 6-15, but `AppTab.allCases` is only `[.today, .goals, .time, .motion, .you]`; `AmbitionsRootView.shellTabView` omits Capture. Capture opens through `shellUtilityButtons` and activated command sheet at lines 286-318 and 451-456. | Global action / compatibility route, not a current top-level tab. |

## Primary Object Proof

| Product object | Live owner | Evidence | Classification |
|---|---|---|---|
| Reality Meridian | Today | `TodayScreen` loads `RealityMeridianView` at lines 150-169; `RealityMeridianView` is documented as Today's primary object at `TodayDayRailPanels.swift` lines 19-20. | Live. |
| Constellation Atlas | Goals | `GoalsScreen` loads `GoalsConstellationAtlasStage` at lines 51-57; `GoalComponents.swift` identifies `stageName: "Constellation Atlas"` and `productObject: "Constellation Atlas + Orbital Lens"` at lines 17-22. | Live. Note: `AppTab` surface contract still says "Direction Atlas" for Goals at lines 131-136 and 180-186; classify as stale/compatibility naming debt for later map work, not active report truth. |
| Atmosphere Composer | Global Capture | `CaptureScreen` contract identifies `ownerSurface: "Global Capture"` and `productObject: "Atmosphere Composer"` at lines 21-25; activated shell seam has `CaptureRoutingPrimitiveStage` titled `Atmosphere Composer` at `AppShellView.swift` lines 946-963. | Live global action/support route. |
| LifeShape Field | Time | `TimeScreen` loads `TimeLifeShapeField` at lines 42-49; `TimeLifeShapeFieldItem` exposes LifeShape inspection summaries at lines 75-95. | Live. |
| Motion Current | Motion | `MotionCurrentScreen` contract identifies `productObject: "Motion Current"` at lines 16-20 and renders `MotionCurrentField`/source receipt affordance at lines 57-85. | Live. |
| User System Profile / Personal Runtime | You | `YouScreen` loads `PersonalSystemCenterRootView` at lines 42-46; `YouRootSurface.swift` contract identifies `productObject: "Personal Runtime / User System Profile"` at lines 79-83. | Live with dual name. |

## Step Route Proof

| Route / capability | Evidence | Classification | Follow-up owner if incomplete |
|---|---|---|---|
| Recommended step / Start here | `TodayDayRailPanels.swift` lines 417-459 render `Start here` and `Recommended step`; lines 914-922 map primary action title to `Open step`, `Still counts`, or `Start now`. | Live Today route. | None for path proof. |
| Open step detail | `TodayScreen` stores `selectedStepDetail` and presents `TodayStepDetailSheet` at lines 61-69; `TodayStepDetailSheet` uses `NavigationStack`, title `Open step`, source/goal/proof/receipt sections at lines 16-44 and 62-153. | Live sheet route. | None for path proof. |
| Start now / Step Session | `TodayScreen.handleAction` routes `.startStepSession` to `shell.navigation.selectToday(entryContext: .stepSession)` at lines 211-215; `DayRailStepDetailState.reservedStartNowAction` emits `Start now` at lines 86-89. | Live route signal. | M10/M14/M26 own end-to-end Step Session behavior proof. |
| Step completion / closure | `TodayScreen.handleAction` routes `.closeActionClosure` to `TodayActionClosureSheetState` at lines 228-230; `TodayActionClosureSheet` renders close-loop, outcome, receipt preview, and confirm sections at lines 15-80. | Live closure sheet. | M10/M16 own consequence/reflow proof. |
| Step proof / receipt | `TodayStepDetailSheet` renders `Proof and receipt` at lines 116-153; `TodayDayRailPanels.swift` trust line includes Source/Freshness/Receipt/Privacy items at lines 765-840. | Live proof/receipt affordance. | M17/M26 own deep drill-down and accessibility proof. |
| Step replacement | `TodayScreen` presents `TodayStepReplacementSheet` at lines 94-112; `TodayStepReplacementSheetState.make` records source Step, candidate, context fingerprint, impact, and no-silent-change receipt labels at lines 108-152. | Live replacement UI/proof route. | M14 owns Step Elasticity Engine proof; current replacement route is not proof of full elasticity. |
| Step Elasticity | Searches found Step replacement, action kinds, StepCandidate field models, reflow references, and governance law anchors, but no single proven complete Step Elasticity engine behavior in this child. | Partial/stubbed by current live route evidence; not claimed complete. | AMB-621 / PLOS-M14 and AMB-627 / PLOS-M09. |

## Source, Trust, Receipt, Proof, Replay Routes

| Route | Evidence | Classification | Follow-up owner |
|---|---|---|---|
| Source Settings | `YouRootDetail.sourceSettings` title at `YouRootSurface.swift` lines 28-60; History & Trust rows include Source Settings at lines 219-228. | Live You detail route. | M17/M26 for deep route proof/accessibility. |
| Receipts & History | `YouRootDetail.receiptsHistory` title at lines 10 and 42; priority rows and History & Trust rows include Receipts & History at lines 180-185 and 219-225. | Live You detail route. | M17/M26. |
| Proof | `YouRootDetail.proof` at lines 13 and 45; History & Trust row includes Proof at lines 219-226. | Live You detail route. | M17/M26. |
| Replay / ReplayTrace | `AppTab` runtime inspection requirements include `ReplayTrace` at lines 123-129; Today execution search log includes replay trace copy in Today projection. No dedicated live Replay detail route was proven in this child. | Requirement present; dedicated route unknown. | M17/M26. |
| What Ambitions knows | `ShellCommandModels` exposes memory lens title; `AppNavigation.presentMemoryLens` records destination label `What Ambitions knows` at lines 252-274. You also maps local context controls to `whatAmbitionsKnows` rows at `YouRootSurface.swift` lines 199-205. | Live overlay/detail route. | M17/M26. |
| Trust & Automation | `YouRootDetail.automationTrust` title at lines 17 and 49; priority rows include Trust & Automation at lines 180-185. | Live You detail route. | M17/M26. |
| Personal Runtime | `YouRootDetail.personalRuntime` title at lines 6 and 37; priority rows include Personal Runtime at lines 180-184. | Live You detail route. | M17/M26. |
| Local Data Controls | `YouRootDetail.localDataControls` title at lines 29 and 60; History & Trust rows include Local Data Controls at lines 219-228. | Live You detail route. | M02/M17/M26. |
| Shell continuity receipt | `AmbitionsRootView.shellContinuityReceipt` renders display-only receipt chrome and explicitly says SourceRecord/ReplayTrace wiring stays in runtime/proof owners at lines 347-363. | Live display-only receipt chrome; deeper source/replay ownership remains runtime/proof. | M17/M26. |

## Preview, Fixture, Stale, And Compatibility Boundaries

- `Native/Ambitions/PreviewSupport/PreviewAppContainer.swift` is preview support and not the live launch root. Live root is `AmbitionsApp -> LaunchGateView -> AmbitionsRootView -> TabView`.
- `MotionCurrentScreen` defaults to `.fixture(renderState: .launchArgument)` at lines 51-55. This is live source but fixture-backed projection behavior; AMB-648/AMB-649/AMB-651 should classify Motion data ownership and production-vs-fixture status.
- `AppTab.capture` exists for legacy compatibility, but `allCases` and the live `TabView` prove Capture is not top-level IA.
- `AppTab` currently records Goals primary object as `Direction Atlas` while live Goals components present `Constellation Atlas + Orbital Lens`. This is a stale/compatibility naming mismatch for M01 stale/duplicate mapping, not a license to rename source in AMB-646.
- Several route names remain compatibility/internal labels: Plan appears as a Time support context (`LivingSurfaceBackground(context: .plan...)`) and Time-owned routing; this report does not classify all stale Plan references. AMB-650 owns stale/duplicate map.

## Unknowns And Owners

| Unknown / gap | Boundary | Owner |
|---|---|---|
| Dedicated Replay detail route not proven. | Requirement and copy exist; route needs deeper proof before runtime/UI claims. | AMB-624 / PLOS-M17 and AMB-635 / PLOS-M26. |
| Full Step Elasticity engine behavior not proven. | Replacement UI exists; engine completeness is not claimed. | AMB-621 / PLOS-M14 and AMB-627 / PLOS-M09. |
| Motion Current production-vs-fixture runtime source not fully classified. | `MotionCurrentScreen` fixture-backed projection requires M01 mapping. | AMB-648 / PLOS-012 and AMB-651 / PLOS-015. |
| Goals primary-object naming mismatch between surface contract and live component. | No source edit in AMB-646; classify as stale/compatibility debt. | AMB-650 / PLOS-014. |
| Build/run behavior of mapped routes. | AMB-646 source proof is not simulator, screenshot, UI, or accessibility proof. | AMB-635 / PLOS-M26, or active future source-changing child when scoped. |

## Validation Summary

Verified:

- Live launch path is `AmbitionsApp -> LaunchGateView -> AppBootstrapper/AppContainerFactory -> AmbitionsRuntimeFactory/AppContainer -> AmbitionsRootView -> SwiftUI TabView`.
- Live top-level `TabView` contains Today, Goals, Time, Motion, and You only.
- Capture is global action / activated composer / compatibility route, not a current top-level tab.
- Primary surface owners and object names are mapped from source with line evidence.
- Step detail, Start now, closure, proof/receipt, replacement, and source/trust routes are mapped without app source changes.
- `scripts/ambitions-xcode-build-for-testing.sh --batch AMB-646` completed with summary status `passed` and `Test Build Succeeded` in the wrapper output.

Not claimed:

- No runtime feature implementation.
- No Source Atlas Factory implementation.
- No Step Elasticity Engine completion.
- No reflow, CloudKit, R2, UI reconstruction, release, TestFlight, App Store, accessibility, performance, or privacy/legal readiness.

## PLOS Child Closeout Draft

PLOS child closeout

Linear issue: AMB-646
Parent issue: AMB-609
Green/Yellow/Red status: Green for AMB-646 source-path proof and build-for-testing compile proof; Yellow only for non-claimed runtime behavior, screenshot, accessibility, Replay detail route, full Step Elasticity, and production-vs-fixture classification owned by later PLOS issues.
Pushed to main: pending commit/push
Push hash: pending commit/push
App source changed: no
Runtime features implemented: no
PLOS-M00 executed: no, already complete before this AMB-609 run
Linear identifiers used: AMB issue identifiers only
Validation run: git status --short --branch --ahead-behind; git pull --ff-only; required AMB-646 find file inventory; required AMB-646 rg runtime search log; python3 -m json.tool artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.json; python3 -m json.tool artifacts/plos-runtime/PLOS_LINEAR_ISSUE_MAP.json; git diff --check; python3 scripts/codex/plos-readiness-validate.py; scripts/codex/program-preflight.sh plos; scripts/codex/program-phase-gate.sh plos M01; python3 scripts/codex/linear-closeout-validate.py --self-test; scripts/ambitions-xcode-build-for-testing.sh --batch AMB-646.
Red blockers: none for AMB-646 scope.
Yellow limits: no runtime feature, Source Atlas Factory, Step Elasticity Engine, reflow, UIQL, release, TestFlight, App Store, accessibility certification, privacy/legal, or performance claim.
Owner approval claimed: no
Release/TestFlight/App Store readiness claimed: no
Next recommended action: after AMB-646 push and Linear closeout, continue AMB-647 / PLOS-011 only; do not execute PLOS-M02+.
