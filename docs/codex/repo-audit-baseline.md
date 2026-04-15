# Ambitions Repo Audit Baseline

Date: 2026-04-14
Repo: `agentdevan/ambitions`
Status: audit only, no product behavior changes

## Purpose

This document is the current truth source for upcoming Ambitions implementation work in this repository.

It is intentionally repo-aware and native-first:

- The shipping app surface is the SwiftUI app under `Native/Ambitions/`.
- Older Expo/React Native code still exists in the repo, but it is no longer the implementation target unless a later task explicitly says otherwise.
- Some older docs still describe the repo as Expo-first. They are not the source of truth for current implementation planning.

## Verified Architecture

### 1. App target and native source of truth

- `project.yml` defines a single iOS application target named `Ambitions`.
- That target sources code from `Native/Ambitions/`.
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
3. It seeds starter data through `DemoSeedPipeline`.
4. It prepares `AppSession` through `DefaultStartupService`.
5. It creates `AppNavigationModel`.
6. It injects repository-backed feature services into `AppContainer`.

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

#### Existing create-goal or draft-related flows

There is no native SwiftUI create-goal/composer screen today.

What does exist:

- Goal draft intake/orchestration:
  - `Native/Ambitions/Domain/GoalEngine/GoalEngineIntake.swift`
  - `Native/Ambitions/Domain/GoalEngine/GoalEngineOrchestrator.swift`
- Draft persistence:
  - `Native/Ambitions/Persistence/PersistenceContracts.swift`
  - `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
- Draft materialization from clarification answers:
  - `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`
  - `materializeDraft(...)`
- Seeded draft creation:
  - `Native/Ambitions/Persistence/DemoSeedPipeline.swift`
- Legacy import into goals + drafts:
  - `Native/Ambitions/Persistence/LegacyImportService.swift`

Current native write path summary:

- A draft can be created by domain orchestration or seed/import code.
- A draft can be recompiled into a blocked, clarification-required, starter, or planned result inside `GoalsFeatureService.materializeDraft(...)`.
- There is not yet a native user-facing goal composer flow that captures freeform input and saves a new `PersistedGoalDraft`.

## Missing Capabilities For Upcoming Roadmap Work

These are verified gaps in the native implementation, not guesses.

### 1. No native create-goal UI flow

Missing:

- no `CreateGoalScreen`
- no native composer route
- no feature service method for creating a new draft from fresh user input
- no action in `GoalsScreen` that launches intake

What exists instead:

- domain-level compile/orchestration
- seed/import paths
- clarification-answer write-back on an existing draft

### 2. No dedicated draft list or draft-first intake surface

Current `GoalsScreen` can render draft-backed items inside the portfolio, but there is:

- no separate draft queue surface
- no draft creation entry point
- no draft editing screen before detail

### 3. App-state write surface is coarse

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

### 4. Navigation only covers goal detail drill-in

Current navigation model only directly supports:

- tab selection
- `goalsPath`
- opening a `GoalDetailScreen`

Missing:

- explicit routes for create-goal
- draft composer/editing
- modal flows
- deeper nested multi-step creation/navigation state

### 5. Preview infrastructure is static, scenario-driven, and manual

The preview system is solid, but it is not data-composition infrastructure yet.

Missing:

- shared factory helpers for drafting arbitrary persisted goal states
- generic preview repository builders
- reusable scenario builders for new intake/create-goal flows

### 6. Some repo docs are stale relative to the code

Verified mismatch:

- `README.md` correctly states the native SwiftUI pivot and says `Native/Ambitions/` is the source of truth.
- `docs/premium-modular-goal-engine-audit-plan.md` is stale for current implementation planning because it describes the repo as Expo/React Native without a native shell.

That older plan should be treated as historical/reference context, not as a roadmap implementation source.

### 7. README understates current native persistence

`README.md` still says native persistence is placeholder/in-memory in the "Current placeholder scope" section.

That is no longer fully true.

Verified current state:

- live bootstrap uses `AmbitionsPersistenceStore(inMemory: false)` for non-preview boot
- SwiftData repositories are in use for goals, drafts, evidence, feedback, and app state

What is still fair to call incomplete:

- account/auth
- sync
- analytics history beyond the current native scope
- user-facing create-goal flow

## Exact Recommended Implementation Points

These are the current extension points later phases should attach to.

### 1. New create-goal intake should attach at the service boundary, not directly in screens

Recommended insertion points:

- add create-draft API to `GoalsServicing` in `Native/Ambitions/Services/AppServices.swift`
- implement it in `RepositoryBackedGoalsService` in `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`
- keep orchestration delegated to `GoalEngineOrchestrator`
- persist through `GoalDraftRepository`

Why:

- This preserves the existing screen -> view model -> service -> repository pattern.
- It avoids duplicating draft orchestration logic in SwiftUI views.

### 2. New create-goal navigation should extend `AppNavigationModel`

Recommended insertion points:

- `Native/Ambitions/App/AppNavigation.swift`
- `Native/Ambitions/App/AmbitionsRootView.swift`

Add later:

- a route type for create-goal flow
- path or modal state for intake
- goal/draft creation completion handoff into `GoalDetailScreen`

Do not attach creation flow to `TodayScreen` or `GoalsScreen` with local-only state.

### 3. Fresh draft creation should reuse native goal engine code, not the old TS composer flow

Recommended insertion points:

- `Native/Ambitions/Domain/GoalEngine/GoalEngineOrchestrator.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`

Use current native primitives:

- `GoalEngineOrchestrationContext`
- `GoalOrchestrationResult`
- `PersistedGoalDraft`

Do not rebuild intake using old `src/product/goalIntake.ts` for shipping native work.

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

### 6. Preview support for new goal-creation work should extend `PreviewAppContainerFactory` and scenario files

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

### Do not assume there is already a native goal composer screen

There is not.

Draft creation currently exists only through:

- seed pipeline
- legacy import
- domain orchestration
- clarification re-materialization on existing drafts

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

Treat older Expo-first roadmap docs as reference-only unless explicitly refreshed.

## Native vs Legacy Boundary

This repo contains both native and older React Native/Expo code.

For this roadmap, ignore the following unless a task explicitly asks for them:

- `src/`
- `App.tsx`
- Expo config and React Native navigation
- old TypeScript screen implementations
- old Zustand/runtime/store composition as an implementation target

What can still be used from the old code:

- behavioral reference
- contract/reference notes
- migration context

Do not use old React Native surfaces as the place to implement new shipping product work for Ambitions.

## Practical Next-Step Guidance

If a later phase asks for native implementation work, the safest sequence is:

1. Extend `GoalsServicing` and `RepositoryBackedGoalsService` for new goal/draft creation behavior.
2. Extend `AppNavigationModel` and `AmbitionsRootView` for the route.
3. Add the new SwiftUI screen under `Native/Ambitions/Features/Goals/`.
4. Reuse `GoalEngineOrchestrator` and `GoalDraftRepository` rather than inventing a second intake path.
5. Add preview scenarios in `Native/Ambitions/PreviewSupport/`.

That sequence matches the current architecture and keeps diffs native, local, and focused.
