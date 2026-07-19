# Frontend Screen Route Registry

Status: Current-main route registry / Implemented Yellow
Date: 2026-07-05
Scope: AMB-1751
Baseline SHA: `9885e8fbd32089c872376b47ff2aa8ab9b338afd`

## Registry

| Screen / route | Owner | Entry point | Classification | Current evidence | Proof gap |
| --- | --- | --- | --- | --- | --- |
| App launch | `App/` | `AmbitionsApp` -> `AmbitionsRootScene` -> `LaunchGateView` | implemented-source-present | `Native/Ambitions/App/AmbitionsApp.swift:3`, `Native/Ambitions/App/AmbitionsRootScene.swift:8` | No current launch screenshot or runtime boot proof in this pass. |
| Stage host | `App/` and `Stage/` | `AmbitionsStageHost` -> `AmbitionsStage` | implemented-source-present | `Native/Ambitions/App/AmbitionsStageHost.swift:5`, `Native/Ambitions/Stage/AmbitionsStage.swift:4` | No current rendered shell proof in this pass. |
| Root shell switch | `App/` | `navigation.selectedTab` switch | implemented-source-present | `Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift:11` | Runtime route proof not executed in this pass. |
| Today root | `Surfaces/Today/` | root switch case `.today` -> `TodaySurface` | implemented-source-present | `Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift:27`, `Native/Ambitions/Surfaces/Today/TodaySurface.swift:6` | Needs current rendered Start here journey proof. |
| Today detail sheets | `Surfaces/Today/Overlays/` | Today step detail, closure, rejection, replacement, protection, and time-shape sheets | partial-source-present | `Native/Ambitions/Surfaces/Today/TodaySurface.swift:52` | Needs current journey proof for each state-gated action before frontend Green. |
| Goals root | `Surfaces/Goals/` | root switch case `.goals` -> `GoalsSurface` | implemented-source-present | `Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift:41`, `Native/Ambitions/Surfaces/Goals/GoalsSurface.swift:4` | Needs current Goals screenshot and route proof. |
| Goal detail | `Surfaces/Goals/` | `GoalRouteTarget` in Goals navigation path | implemented-source-present | `Native/Ambitions/Stage/StageRoute.swift:8`, `Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift:55` | Needs current goal-detail runtime proof. |
| Life area detail | `Surfaces/Goals/` | `GoalRouteTarget.lifeAreaID` -> `AreaDetailScreen` | implemented-source-present | `Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift:55`, `Native/Ambitions/Surfaces/Goals/GoalsSurface.swift:129` | Needs current runtime route proof. |
| Create goal | `Surfaces/Goals/` | `ShellOverlayState.createGoal` -> `CreateGoalScreen` | implemented-source-present | `Native/Ambitions/Stage/Overlays/AppShellOverlayView.swift:13` | Needs current create-goal journey proof. |
| Time root | `Surfaces/Time/` | root switch case `.time` -> `TimeSurface` | implemented-source-present | `Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift:74`, `Native/Ambitions/Surfaces/Time/TimeSurface.swift:7` | Needs current Time screenshot and Life Calendar proof. |
| Time rituals | `Surfaces/Time/` | `TimeRouteTarget.rituals` -> `TimeRitualsSurface` | implemented-source-present | `Native/Ambitions/Stage/StageRoute.swift:37`, `Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift:84` | Needs runtime route proof. |
| Weekly review | `Surfaces/Time/` | `TimeRouteTarget.weeklyReview` -> `WeeklyReviewScreen` | implemented-source-present | `Native/Ambitions/Stage/StageRoute.swift:37`, `Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift:97` | Needs runtime route proof. |
| You root | `Surfaces/You/` | root switch case `.you` -> `YouSurface` | implemented-source-present | `Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift:116`, `Native/Ambitions/Surfaces/You/YouSurface.swift:8` | Needs current You screenshot and settings/control proof. |
| You detail routes | `Surfaces/You/` | `YouRouteTarget` -> `YouRootDetailRouteSurface` | partial-source-present | `Native/Ambitions/Stage/StageRoute.swift:44`, `Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift:126` | Needs per-row journey proof and unavailable-state proof. |
| You monthly review | `Surfaces/You/` | `YouRouteTarget.monthlyReview` -> `YouMonthlyReviewSurface` | implemented-source-present | `Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift:128` | Needs runtime route proof. |
| History inspection | `Trust/` and `Surfaces/You/` | `YouRouteTarget.history` -> `HistoryInspectionView` | implemented-source-present / contextual | `Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift:139`, `Native/Ambitions/Trust/HistoryInspectionView.swift:4` | Needs current history/return-route journey proof. |
| Proof inspection | `Trust/` | `ProofInspectionView` -> `InspectionSurface(kind: .proof)` | partial-source-present | `Native/Ambitions/Trust/ProofInspectionView.swift:3`, `Native/Ambitions/Trust/InspectionSurface.swift:63` | Needs actual invocation path proof beyond wrapper source. |
| Source inspection | `Trust/` | `SourceInspectionView` | partial-source-present | `Native/Ambitions/Trust/SourceInspectionView.swift:4` | Needs current source-inspection screenshot/accessibility proof. |
| Privacy inspection | `Trust/` | `PrivacyInspectionView` -> `InspectionSurface(kind: .privacy)` | partial-source-present | `Native/Ambitions/Trust/PrivacyInspectionView.swift:3` | Needs current invocation path proof. |
| Receipt inspection | `Trust/` | `ReceiptInspectionView` -> `InspectionSurface(kind: .receipt)` | partial-source-present | `Native/Ambitions/Trust/ReceiptInspectionView.swift:3` | Needs current receipt invocation and undo/state proof. |
| Global Capture composer | `Composer/Capture/` and `Stage/Overlays/` | Capture overlay/seam -> `CaptureComposerSurface` / `AppShellActivatedCaptureSeam` | implemented-source-present / overlay | `Native/Ambitions/Composer/Capture/CaptureSurface.swift:3`, `Native/Ambitions/Composer/Capture/CaptureComposerSurface.swift:5`, `Native/Ambitions/App/AppShellActivatedCaptureSeam.swift:4` | Needs current keyboard, save, placement, and dismissal journey proof. |
| Typed Capture route | `Composer/Capture/` | `CapturePresentation` and `CaptureTypedRoute` overlay state | partial-source-present | `Native/Ambitions/Stage/Overlays/CapturePresentationRoute.swift:9`, `Native/Ambitions/Stage/StageStore.swift:261` | Needs current route-review proof. |
| Search / Memory Lens | `Stage/Overlays/` and `Surfaces/You/Projection/` | `ShellOverlayState.memoryLens` -> `QuietCommandSheetView.memoryLensBody` | implemented-source-present / overlay | `Native/Ambitions/Stage/Overlays/ShellOverlayState.swift:75`, `Native/Ambitions/Stage/Overlays/QuietCommandMemoryLensOverlay.swift:4` | Needs current search results, trusted handoff, and no-result Capture proof. |
| Motion behavior routes | `Stage/Motion/` | `MotionCurrentAction` -> `routeStageMotionAction` | partial-source-present / behavior only | `Native/Ambitions/Stage/AmbitionsStage.swift:357`, `Native/Ambitions/Stage/SurfaceOwnershipRegistry.swift:42` | Needs rendered/reduced-motion proof before any visual motion claim. |
| External deep links | `App/` | `AppDeepLinkRegistry` -> `DefaultAppExternalRouter.dispatch` | partial-source-present | `Native/Ambitions/App/AppDeepLinkRegistry.swift:57`, `Native/Ambitions/App/AppExternalRouting.swift:37` | Needs runtime external-route proof for each source before release claims. |
| Widget and share extension entry | `Projection/ExternalSnapshots/`, `Native/AmbitionsWidgetExtension`, `Native/AmbitionsShareExtension` | XcodeGen active targets | partial-source-present / external surface | `project.yml:38`, `project.yml:63` | External UI and route proof remains outside this pass. |
| Preview support and screenshot fixtures | `Native/Ambitions/PreviewSupport`, `Native/AmbitionsUITests/`, `docs/qa/evidence/` | dev assets, UI tests, historical evidence | preview-only / test-only / docs-only | `project.yml:31`, `docs/audits/amb-1749-frontend-evidence-harness.md:74` | Cannot prove current runtime UI without a new run. |

## Dead Root Route Result

No active production source route was found that exposes `Plan`, `Pulse`,
`Profile`, `Captures`, `Motion`, or `Capture` as a root tab. Stale/historical
labels remain in tests, policy copy, or fixtures and are classified in
`docs/audits/frontend-deletion-quarantine-candidates.md`.
