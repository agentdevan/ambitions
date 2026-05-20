# Ambitions Repo Audit Baseline

Date: 2026-04-14
Repo: `agentdevan/ambitions`
Status: audit only, no product behavior changes

## Precedence Notice

This audit is supporting repo-state context.
It does not override [CONTEXT_INDEX.md](CONTEXT_INDEX.md), [../../MASTER_PRODUCT_SPEC.md](../../MASTER_PRODUCT_SPEC.md), or the canonical planning docs under [../canon](../canon).
When this audit conflicts with the canonical planning stack, demote the audit claim and follow the context index.

## Purpose

This document is a repo-aware audit baseline for upcoming Ambitions implementation work in this repository.

It is intentionally repo-aware and native-first:

- The shipping app surface is the SwiftUI app under `Native/Ambitions/`.
- The repo no longer carries an active Expo / React Native / TypeScript runtime path.
- Older docs may still discuss removed paths as historical context, but they are not the source of truth for current implementation planning.

## Verified Architecture

### 1. App target and native source of truth

- `project.yml` defines the `Ambitions` iOS app target, the `AmbitionsWidgetExtension` target, and the native unit/UI test bundles.
- The shipping app target sources code from `Native/Ambitions/`.
- The widget/live-activity extension sources code from `Native/AmbitionsWidgetExtension/` plus shared snapshot contracts under `Native/Ambitions/ExternalSnapshots/`.
- The app also depends on local Swift packages:
  - `Sources/` via `AmbitionsDesignSystem`
  - `AppUI/Sources/` via `AmbitionsWidgetUI`

Verified entry and composition points:

- `Native/Ambitions/App/AppContainerFactory.swift`
- `Native/Ambitions/App/AmbitionsRootView.swift`
- `Native/Ambitions/App/AppNavigation.swift`
- `Native/Ambitions/Services/AppServices.swift`

Current bootstrap shape:

1. `AppContainerFactory.make(source:)` creates a SwiftData-backed `AmbitionsPersistenceStore`.
2. It constructs repository implementations through `AppRepositories`.
3. It creates an `ExternalSurfaceSnapshotWriter`, `LocalNotificationFoundation`, and `EventKitIntegrationService`.
4. It wraps Today and Goals services with snapshot-refresh and notification-refresh behavior.
5. It seeds starter data through `DemoSeedPipeline` when explicitly requested.
6. It prepares `AppSession` through `DefaultStartupService`.
7. It creates `AppNavigationModel` plus `DefaultAppExternalRouter`.
8. It injects repository-backed feature services and system-surface services into `AppContainer`.

### 2. Current feature pattern

The native app is already using a consistent feature pattern:

- SwiftUI screen
- `@Observable` view model
- service protocol from `AppServices.swift`
- repository-backed feature service
- preview stub service and preview scenarios

Confirmed examples:

- Today
  - screen: `Native/Ambitions/Features/Today/TodayScreen.swift`
  - view model: `Native/Ambitions/Features/Today/TodayViewModel.swift`
  - service: `Native/Ambitions/Features/Today/TodayFeatureService.swift`
- Capture
  - screen: `Native/Ambitions/Features/Capture/CaptureScreen.swift`
  - service boundary: `Native/Ambitions/Services/AppServices.swift`
  - service implementation: `Native/Ambitions/Services/CaptureService.swift`
- Goals
  - screens: `Native/Ambitions/Features/Goals/GoalsScreen.swift`, `Native/Ambitions/Features/Goals/GoalDetailScreen.swift`
  - view models: `Native/Ambitions/Features/Goals/GoalsViewModels.swift`
  - service: `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`

### 3. Persistence is native and real, not stub-only

The repo is no longer using an in-memory-only persistence boundary for live runtime.

Verified persistence stack:

- contracts: `Native/Ambitions/Persistence/PersistenceContracts.swift`
- store: `Native/Ambitions/Persistence/SwiftDataStore.swift`
- SwiftData models: `Native/Ambitions/Persistence/SwiftDataModels.swift`
- repository implementations: `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
- preferences adapter: `Native/Ambitions/Persistence/AppPreferencesStore.swift`

Current repositories:

- `SwiftDataGoalRepository`
- `SwiftDataGoalDraftRepository`
- `SwiftDataProgressEvidenceRepository`
- `SwiftDataFeedbackEventRepository`
- `SwiftDataCaptureRepository`
- `SwiftDataAppStateRepository`

### 4. Goal engine and draft compilation already exist in native code

The repo already has a native goal-intake/planning domain under `Native/Ambitions/Domain/GoalEngine/`.

Verified current orchestration points:

- intake normalization: `Native/Ambitions/Domain/GoalEngine/GoalEngineIntake.swift`
- orchestration: `Native/Ambitions/Domain/GoalEngine/GoalEngineOrchestrator.swift`
- planning: `Native/Ambitions/Domain/GoalEngine/GoalEnginePlanner.swift`
- adaptation: `Native/Ambitions/Domain/GoalEngine/GoalEngineAdaptationService.swift`
- contracts: `Native/Ambitions/Domain/GoalEngine/GoalEngineContracts.swift`
- fixture corpus: `Native/Ambitions/Domain/GoalEngine/GoalEngineFixtures.swift`

Important current behavior:

- There is native support for `GoalDraft`, `GoalPlan`, clarification, blocked planning, starter plans, delegated/support semantics, untimed goals, learning goals, and adaptation metadata.
- That logic is already wired into `GoalsFeatureService` and `TodayFeatureService`.

## Verified File Paths

### Confirmed files from the task

- `project.yml`
- `Native/Ambitions/App/AppContainerFactory.swift`
- `Native/Ambitions/Services/AppServices.swift`
- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Native/Ambitions/Features/Goals/GoalsScreen.swift`
- `Native/Ambitions/Features/Goals/GoalDetailScreen.swift`
- `Native/Ambitions/Persistence/AppPreferencesStore.swift`

### Actual current files for the requested symbols and areas

#### Today view model

- `Native/Ambitions/Features/Today/TodayViewModel.swift`

#### Goals view models

- `Native/Ambitions/Features/Goals/GoalsViewModels.swift`
  - contains `GoalsViewModel`
  - contains `GoalDetailViewModel`

#### Goal repository implementations

- `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
  - `SwiftDataGoalRepository`
  - `SwiftDataGoalDraftRepository`
  - `SwiftDataProgressEvidenceRepository`
  - `SwiftDataFeedbackEventRepository`
  - `SwiftDataAppStateRepository`

Repository contracts live in:

- `Native/Ambitions/Persistence/PersistenceContracts.swift`

#### App state repository and model

- repository contract: `Native/Ambitions/Persistence/PersistenceContracts.swift`
  - `protocol AppStateRepository`
- app state model: `Native/Ambitions/Persistence/PersistenceContracts.swift`
  - `struct AppStateSnapshot`
- SwiftData storage model: `Native/Ambitions/Persistence/SwiftDataModels.swift`
  - `final class AppStateRecord`
- repository implementation: `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
  - `struct SwiftDataAppStateRepository`

#### Preview fixture infrastructure

- `Native/Ambitions/PreviewSupport/PreviewFixtures.swift`
- `Native/Ambitions/PreviewSupport/PreviewAppContainer.swift`
- `Native/Ambitions/PreviewSupport/PreviewTodayScenarios.swift`
- `Native/Ambitions/PreviewSupport/PreviewGoalsScenarios.swift`
- `Native/Ambitions/PreviewSupport/PreviewHabitsScenarios.swift`

#### Routing and navigation model

- `Native/Ambitions/App/AppNavigation.swift`
  - `GoalRouteTarget`
  - `GoalDetailLaunchContext`
  - `AppNavigationModel`
- `Native/Ambitions/App/AmbitionsRootView.swift`
  - owns tab wiring
  - owns `NavigationStack(path: $navigation.goalsPath)` for Goals detail routing

#### Existing create-goal and draft-related flows

The native app now has a user-facing create-goal flow.

What exists:

- Goal creation UI:
  - `Native/Ambitions/Features/Goals/CreateGoalScreen.swift`
  - `Native/Ambitions/Features/Goals/CreateGoalViewModel.swift`
- Goal creation service path:
  - `Native/Ambitions/Services/AppServices.swift`
  - `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`
- Goal draft intake/orchestration:
  - `Native/Ambitions/Domain/GoalEngine/GoalEngineIntake.swift`
  - `Native/Ambitions/Domain/GoalEngine/GoalEngineOrchestrator.swift`
- Draft persistence:
  - `Native/Ambitions/Persistence/PersistenceContracts.swift`
  - `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
- Goals list integration:
  - `Native/Ambitions/Features/Goals/GoalsScreen.swift`

Current native write path summary:

- The Goals surface can present `CreateGoalScreen`, submit `CreateGoalRequest`, and navigate into `GoalDetailScreen` via `GoalRouteTarget`.
- Goal creation still reuses the native goal-engine and repository path rather than reviving old TypeScript runtime flows.
- Drafts, clarification-required outcomes, and planned goals continue to resolve through the native goal-engine/service pipeline.

## Remaining Gaps That Still Matter For Implementation Planning

These are verified gaps or caution areas in the native implementation/docs, not guesses.

### 1. Cross-surface capture ingress is only partially wired

Verified current truth:

- Capture persistence exists in native code.
- Today quick capture writes real captures.
- The Captures tab reads from `captureService.listCaptures()`.
- Domain/tests already recognize capture sources such as notification, share extension text/URL, and app intent.

Remaining caution:

- Share Extension and App Intents targets are not yet the active native source of truth in this repo.
- Future cross-surface capture work should extend the existing capture boundary rather than invent a second ingestion path.

### 2. External-surface code exists, but environment validation still matters

Verified current truth:

- `AppExternalRouting` handles deep links, notification payloads, and widget payloads.
- `LocalNotificationFoundation` performs category registration, authorization requests, and schedule refresh.
- `EventKitIntegrationService` exists in the live app container.
- `project.yml` defines `AmbitionsWidgetExtension`, and the repo includes widget/live-activity code plus shared snapshot contracts.

Remaining caution:

- This audit did not run a simulator/device validation pass.
- Do not collapse "implemented in code" into "fully validated shipping behavior" without the build/runtime checks.

### 3. App-state write surface is still coarse

`AppStateSnapshot` contains:

- preferred tab
- user display name
- review cadence
- local-only mode
- bootstrap metadata
- import metadata
- `goalPriorityOrder`
- `lastOpenedGoalID`

But the repository only exposes:

- `loadState()`
- `saveState(_:)`

There are no finer-grained app-state APIs yet for:

- updating only manual priorities
- updating review cadence
- updating local-only mode
- setting feature flags or roadmap settings

### 4. Create-goal presentation is local to Goals, not yet a shared app-level route

Verified current truth:

- `GoalsScreen` can present `CreateGoalScreen`.
- Submission returns a `GoalRouteTarget` that opens detail.

Remaining caution:

- The create-goal flow is not a generalized app-wide route yet.
- If future work needs cross-tab or external entry into create-goal, extend navigation deliberately instead of assuming that route already exists.

### 5. Preview infrastructure is static, scenario-driven, and manual

The preview system is solid, but it is not data-composition infrastructure yet.

Missing:

- shared factory helpers for drafting arbitrary persisted goal states
- generic preview repository builders
- reusable scenario builders for new intake/create-goal flows

### 6. Some repo docs are still stale relative to the code

Verified mismatch:

- `README.md` correctly states the native SwiftUI pivot and says `Native/Ambitions/` is the source of truth.
- `docs/premium-modular-goal-engine-audit-plan.md` was stale for current implementation planning because it described the repo as Expo/React Native without a native shell.

That older plan has since been removed from the active repo and should not be reintroduced as a roadmap implementation source.

### 7. Sync/auth/backend account flows remain non-shipping

Verified current state:

- The native repo is still local-first.
- Sync/auth/account deletion should remain documented as non-shipping unless a later task explicitly revives them.

## Exact Recommended Implementation Points

These are the current extension points later phases should attach to.

### 1. New goal/capture behavior should attach at the current service boundary, not directly in screens

Recommended insertion points:

- extend `GoalsServicing`, `CaptureServicing`, or other existing protocols in `Native/Ambitions/Services/AppServices.swift`
- implement behavior in the current repository-backed feature/service layer
- keep orchestration delegated to the native domain and persistence stack already in place

Why:

- This preserves the existing screen -> view model -> service -> repository pattern.
- It avoids duplicating orchestration logic in SwiftUI views.

### 2. App-level routing changes should extend `AppNavigationModel` and `AppExternalRouting` deliberately

Recommended insertion points:

- `Native/Ambitions/App/AppNavigation.swift`
- `Native/Ambitions/App/AmbitionsRootView.swift`
- `Native/Ambitions/App/AppExternalRouting.swift`

Add later:

- new app-level route types only when the flow truly needs cross-screen or external entry
- explicit routing translations for new OS-surface payloads

Do not invent parallel routing paths outside the current navigation/external-router layer.

### 3. Goal creation and follow-up work should reuse native goal-engine code, not the old TS composer flow

Recommended insertion points:

- `Native/Ambitions/Domain/GoalEngine/GoalEngineOrchestrator.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`

Use current native primitives:

- `GoalEngineOrchestrationContext`
- `GoalOrchestrationResult`
- `PersistedGoalDraft`

Do not rebuild intake by reviving removed TypeScript runtime paths for shipping native work.

### 4. Goal detail follow-up work should continue to hang off `GoalRouteTarget`

Recommended insertion points:

- `Native/Ambitions/App/AppNavigation.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`
- `Native/Ambitions/Features/Goals/GoalDetailScreen.swift`

Current routing already supports:

- `goalID`
- `draftID`
- `launchContext`

That is the right place to extend detail-opening behavior for new flows.

### 5. Manual priority and app state work should continue through `AppStateSnapshot`

Recommended insertion points:

- `Native/Ambitions/Persistence/PersistenceContracts.swift`
- `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`

Current priority ordering already lives in:

- `AppStateSnapshot.goalPriorityOrder`

So future roadmap work that needs persisted portfolio ordering should build from that field rather than inventing a separate ordering store.

### 6. Preview support should continue to extend `PreviewAppContainerFactory` and scenario files

Recommended insertion points:

- `Native/Ambitions/PreviewSupport/PreviewAppContainer.swift`
- `Native/Ambitions/PreviewSupport/PreviewGoalsScenarios.swift`
- add new preview scenario files in `Native/Ambitions/PreviewSupport/` only if needed

Why:

- The current preview pattern already mirrors the production service boundary.
- That keeps creation-flow previews aligned with the real native architecture.

## Explicit "Do Not Assume" Notes

These are the highest-risk incorrect assumptions a later engineer could make from older docs or roadmap language.

### Do not assume the repo is still Expo-first

Current shipping implementation surface is native SwiftUI under `Native/Ambitions/`.

### Do not assume `TodayViewModel`, `GoalsViewModel`, and `GoalDetailViewModel` live in a shared state/store layer

They are local native `@Observable` view models:

- `Native/Ambitions/Features/Today/TodayViewModel.swift`
- `Native/Ambitions/Features/Goals/GoalsViewModels.swift`

### Do not assume app state is a domain model under `Native/Ambitions/Domain`

The current app state model is `AppStateSnapshot` in:

- `Native/Ambitions/Persistence/PersistenceContracts.swift`

### Do not assume goal repositories are in `src/repositories` for the native app

For native implementation work, the actual repository contracts and implementations are under:

- `Native/Ambitions/Persistence/`

### Do not assume missing-foundation docs are still correct

Several older implementation notes still describe captures, create-goal, routing, notifications, widgets, or EventKit as future work.

They are no longer safe to treat as current architecture truth without re-checking code first.

### Do not assume `GoalDetailScreen` only renders persisted goals

It renders either:

- a persisted `Goal`
- a `PersistedGoalDraft`
- or both, resolved through `GoalRouteTarget`

### Do not assume manual priority has its own repository/table

It currently persists through:

- `AppStateSnapshot.goalPriorityOrder`

### Do not assume preview support is repository-backed

Current previews use scenario fixtures and stub services, not a preview SwiftData store.

### Do not assume all current docs agree with the code

They do not.

For implementation planning, prefer:

1. `project.yml`
2. `Native/Ambitions/`
3. `README.md`
4. this audit doc

Treat any older Expo-first roadmap language as historical/reference-only unless explicitly refreshed.

## Native vs Legacy Boundary

The active repo is native SwiftUI only.

Removed legacy runtime paths such as `src/`, Expo config, and React Native screen/runtime code are no longer part of the implementation surface and should not be recreated for shipping work.

## Practical Next-Step Guidance

If a later phase asks for native implementation work, the safest sequence is:

1. Verify whether the requested behavior already exists in native code before planning a new foundation.
2. Extend the current service boundary and domain/persistence path rather than inventing a second seam.
3. Route app-entry changes through `AppNavigationModel` and `AppExternalRouting`.
4. Add or refine SwiftUI screens only after the service/routing truth is clear.
5. Keep preview scenarios aligned with the real native service boundary.

That sequence matches the current architecture and keeps diffs native, local, and focused.
