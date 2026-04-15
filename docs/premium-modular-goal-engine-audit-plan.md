# Premium Modular Goal Engine Audit Plan

Status: Historical reference only. This audit was written against older Expo/React Native assumptions and should not be treated as the source of truth for the current native SwiftUI app.

Date: April 14, 2026
Repo: `C:\Users\Devan\Documents\GitHub\ambitions`
Status: Audit only. No implementation changes included.

## Scope

This document captures the current architecture audit and a concrete implementation plan for evolving Ambitions into a premium modular goal-execution app with:

- universal goal intake
- deep goal/task breakdown into highly actionable next-step objects
- adaptive feedback collection
- untimed goals and learning goals
- delegated, child, and support goals
- premium in-app modular interface widgets/cards
- beautiful dark-mode-first, highly interactive screens

Important constraint: the current codebase is Expo/React Native, not SwiftUI. There is no native iOS SwiftUI shell in this repository today, so the practical plan preserves product momentum inside the current stack first.

## 1. Current Architecture Summary

### App shell and navigation

- The app shell is Expo/React Native with React Navigation.
- Entry points:
  - `src/bootstrap/AppRoot.tsx`
  - `src/navigation/RootNavigator.tsx`
- The information architecture is stable and tab-based:
  - Today
  - Goals
  - Plan
  - Insights
  - Profile
- Each tab has a nested native stack for drill-in detail screens.
- Current navigation is straightforward to extend and does not need replacement.

### State management and orchestration

- The app is orchestrated through a large Zustand store:
  - `src/state/useAppStore.ts`
- This store handles:
  - bootstrapping
  - goal CRUD
  - planning state
  - rituals
  - reviews
  - adaptation
  - integrations
  - account and sync
- Architectural issue:
  - The store is too broad and mixes orchestration with domain write actions.
  - This is the primary blocker to a cleaner modular UI composition layer.

### Runtime composition

- Foundation loading and derived-state assembly happen in:
  - `src/state/runtime.ts`
- This runtime layer:
  - syncs calendar state
  - loads repositories
  - builds schedules
  - derives Today view models
  - merges suggestions
  - syncs notifications
- Strength:
  - Centralized state refresh path.
- Weakness:
  - Refresh scope is coarse, making widget-level composition and partial refresh harder.

### Domain models

- Core models are already explicit and persisted:
  - `src/domain/models/goal.ts`
  - `src/domain/models/planning.ts`
  - `src/domain/models/adaptation.ts`
  - `src/domain/models/weekly.ts`
  - `src/domain/models/monthly.ts`
  - `src/domain/models/rituals.ts`
- Current domain strengths:
  - `Goal`, `GoalMilestone`, `Task`, `DailyPlan`, `TimeBlock` are real first-class records.
  - `parentGoalId` and `parentTaskId` already exist in the schema.
  - Ambitions exist as a higher-level direction layer.
- Current domain weaknesses:
  - Goal relationships are not yet treated as a true graph.
  - There is no first-class `NextStep` object.
  - Learning goals and untimed goals are only partially supported.
  - Delegation/support-goal semantics are not modeled beyond basic parent IDs.

### Goal intake and orchestration

- Goal intake starts in:
  - `src/product/goalIntake.ts`
- Goal creation orchestration lives in:
  - `src/product/planOrchestrator.ts`
- Current intake behavior:
  - natural-language goal sentence
  - inferred title
  - inferred domain
  - inferred deadline
  - inferred type/horizon
  - pace recommendation and strategy composition
- Current strengths:
  - Strong foundation for universal intake.
  - Already builds a believable first path, not just raw CRUD records.
- Current limitations:
  - Intake is still single-goal and text-first.
  - It does not normalize into a rich canonical goal brief.
  - It does not support imported or structured goal definitions.

### Engines

- Existing engine surface:
  - `src/engines/decomposition/GoalDecompositionEngine.ts`
  - `src/engines/scheduling/SchedulingEngine.ts`
  - `src/engines/replanning/ReplanningEngine.ts`
  - `src/engines/execution/ExecutionEngine.ts`
  - `src/engines/adaptation/AdaptationEngine.ts`
  - shared contracts in `src/engines/types.ts`
- This is the strongest part of the current architecture.
- The current system already separates:
  - decomposition
  - scheduling
  - execution transitions
  - replanning
  - adaptation
- This should be extended, not replaced.

### Persistence and repositories

- SQLite schema and migrations:
  - `src/data/sqlite/migrations.ts`
- Repository interfaces and implementations:
  - `src/repositories/*.ts`
  - `src/repositories/sqlite/*.ts`
- Current strengths:
  - additive migrations
  - repository abstraction
  - local-first persistence
  - sync-compatible entity metadata
- Current weakness:
  - repositories are designed for current tables, not graph queries, widget hydration, or feedback snapshot retrieval.

### Screen composition

- Current key screens:
  - `src/screens/today/TodayScreen.tsx`
  - `src/screens/goals/GoalComposerScreen.tsx`
  - `src/screens/goals/GoalDetailScreens.tsx`
  - `src/screens/plan/PlanScreen.tsx`
- Current screen style:
  - card-heavy
  - layered
  - dark-mode aware
  - already moving toward premium presentation
- Existing primitives:
  - `Screen`
  - `Surface`
  - `Pill`
  - `Button`
  - `SelectionCard`
  - `DetailSummaryStrip`
  - `MetricCard`
- This is enough to bootstrap a modular widget system without a UI rewrite.

### Theme system, tokens, and visual language

- Theme and tokens:
  - `src/product/theme.ts`
  - `src/design/theme/index.ts`
  - `src/design/tokens/colors.ts`
  - `src/design/tokens/spacing.ts`
  - `src/design/tokens/type.ts`
  - `src/design/tokens/radius.ts`
- Current strengths:
  - clear token layer
  - appearance mode support
  - accent themes
  - dark mode support
  - strong card/elevation styling
- Current weakness:
  - no formal design-system component contracts for widgets/modules
  - no motion tokens
  - no dashboard layout system

### Progress and charting

- Current progress logic:
  - `src/services/goals/progress.ts`
- Current progress visuals:
  - `src/components/ui/ProgressBar.tsx`
  - `src/components/history/ActivityTimeline.tsx`
- Strength:
  - progress truth is conceptually strong
  - ambition representation logic already exists
- Weakness:
  - visuals are bespoke and lightweight
  - there is no generalized chart/widget framework

### Motion and interactivity

- Current motion patterns are minimal:
  - press scale/translate on buttons, chips, rows
  - reduce-motion support exists
- There is no meaningful use of:
  - layout choreography
  - advanced Reanimated transitions
  - staged screen entrance patterns
  - modular widget transition behavior

## 2. Gap Analysis

### Universal goal intake

Current state:

- partially present via `goalIntake.ts`
- strong text inference path

Missing:

- canonical goal brief object
- structured intake variants
- support for imported/programmatic intake
- learning-goal intake mode
- delegated/support-goal intake mode

### Deep goal/task breakdown into actionable next-step objects

Current state:

- decomposition engine already outputs milestones and tasks

Missing:

- explicit `NextStep` model
- actionability scoring
- dependency semantics
- prerequisite/context/equipment gating
- clarity/confidence fields
- review-trigger fields

### Adaptive feedback collection

Current state:

- daily rituals
- weekly review
- monthly review
- adaptation profile

Missing:

- goal-scoped feedback snapshots
- learning-loop feedback
- feedback tied to modules/widgets
- reusable feedback prompts driven by engine state

### Untimed goals and learning goals

Current state:

- `targetDate` can be null
- some no-deadline language exists in the planner

Missing:

- explicit untimed goal mode
- explicit learning goal mode
- mastery, repetition, or curriculum modeling
- progress truth that is not deadline-centric

### Delegated, child, and support goals

Current state:

- `parentGoalId` exists
- `ambitionId` exists

Missing:

- graph semantics
- support-goal relationships
- delegated-goal ownership/status rules
- roll-up progress and dependency views
- UI for child/support relationships

### Premium modular widgets/cards

Current state:

- existing card primitives are good
- screens are manually assembled

Missing:

- widget registry
- widget contracts
- dashboard layout composition
- per-screen module containers
- persistent widget preferences/layouts

### Beautiful dark-mode-first highly interactive screens

Current state:

- dark mode is solid
- premium surfaces already exist

Missing:

- deeper motion system
- stronger hierarchy across hero, module, and supporting cards
- generalized reusable premium modules
- SwiftUI/native shell, if that remains a long-term goal

### Technical debt blocking premium UI composition

- `src/state/useAppStore.ts`
  - too large
  - mixes state, domain writes, orchestration, and refresh logic
- `src/state/runtime.ts`
  - broad refresh boundaries
- `src/state/viewModels/today.ts`
  - dense and valuable, but mixes decision logic with presentation shaping
- repository interfaces
  - not yet designed for graph/module/widget query patterns
- screen files
  - several are large enough that extracting modules is now the correct next step

## 3. Proposed Module Breakdown

### GoalEngine

Purpose:

- normalize intake into a canonical goal brief
- manage goal graph relationships
- generate highly actionable next-step objects
- support untimed, learning, child, delegated, and support goals

Approach:

- extend current `goalIntake` and decomposition pipeline
- do not replace current engine architecture

### Planner

Purpose:

- convert goal graph and next-step objects into daily/weekly shape
- protect capacity
- decide scheduling vs review vs defer

Approach:

- keep existing scheduling engine
- extend task inputs and selection metadata

### FeedbackEngine

Purpose:

- collect and normalize adaptive feedback
- derive prompts and review recommendations
- feed both planner and premium UI modules

Approach:

- build on rituals, adaptation profile, history, and review state

### ProgressEngine

Purpose:

- unify goal progress truth
- unify ambition representation
- support untimed and learning progress reads
- support child/support/delegated rollups

Approach:

- expand current progress service into a broader engine layer

### AmbitionsDesignSystem

Purpose:

- formalize tokens, surfaces, charts, module shells, hero cards, and motion behavior
- standardize dark-mode-first premium composition

Approach:

- extend existing token/theme/primitives
- avoid broad UI replacement

### DashboardWidgets

Purpose:

- enable modular reusable cards on Today and Plan
- support premium composition and future customization

Examples:

- GoalFocusWidget
- OpenWindowWidget
- MomentumWidget
- PressureWidget
- ReviewQueueWidget
- LearningLoopWidget
- DelegationWidget

### GoalDetailModules

Purpose:

- break goal detail into reusable modules driven by engine outputs

Examples:

- NextStepModule
- ProgressTruthModule
- LearningModule
- SupportGoalsModule
- FeedbackModule

## 4. Exact Files To Create Or Modify

### Create

- `src/domain/models/goalEngine.ts`
- `src/domain/models/nextStep.ts`
- `src/domain/models/feedback.ts`
- `src/domain/models/widgets.ts`
- `src/engines/goalEngine/GoalEngine.ts`
- `src/engines/goalEngine/intakeNormalizer.ts`
- `src/engines/goalEngine/goalGraph.ts`
- `src/engines/goalEngine/nextStepBuilder.ts`
- `src/engines/feedback/FeedbackEngine.ts`
- `src/engines/progress/ProgressEngine.ts`
- `src/services/goals/goalGraphSelectors.ts`
- `src/services/goals/nextStepSelectors.ts`
- `src/services/widgets/widgetRegistry.ts`
- `src/state/viewModels/dashboard.ts`
- `src/components/widgets/WidgetSurface.tsx`
- `src/components/widgets/WidgetStack.tsx`
- `src/components/widgets/GoalFocusWidget.tsx`
- `src/components/widgets/MomentumWidget.tsx`
- `src/components/widgets/PressureWidget.tsx`
- `src/components/widgets/ReviewQueueWidget.tsx`
- `src/components/goals/modules/NextStepModule.tsx`
- `src/components/goals/modules/ProgressTruthModule.tsx`
- `src/components/goals/modules/LearningModule.tsx`
- `src/components/goals/modules/SupportGoalsModule.tsx`
- `src/components/goals/modules/FeedbackModule.tsx`

### Modify

- `src/domain/models/goal.ts`
- `src/domain/models/planning.ts`
- `src/engines/types.ts`
- `src/product/goalIntake.ts`
- `src/product/types.ts`
- `src/product/planOrchestrator.ts`
- `src/engines/decomposition/GoalDecompositionEngine.ts`
- `src/engines/decomposition/planning/types.ts`
- `src/services/goals/progress.ts`
- `src/repositories/GoalRepository.ts`
- `src/repositories/TaskRepository.ts`
- `src/repositories/sqlite/SQLiteGoalRepository.ts`
- `src/repositories/sqlite/SQLiteTaskRepository.ts`
- `src/data/sqlite/migrations.ts`
- `src/state/runtime.ts`
- `src/state/useAppStore.ts`
- `src/screens/goals/GoalComposerScreen.tsx`
- `src/screens/goals/GoalDetailScreens.tsx`
- `src/screens/today/TodayScreen.tsx`
- `src/screens/plan/PlanScreen.tsx`
- `src/components/ui/Surface.tsx`
- `src/components/ui/Screen.tsx`
- `src/components/detail/DetailPrimitives.tsx`
- `src/product/theme.ts`
- `src/design/theme/index.ts`

## 5. Migration Strategy

### Guiding rules

- Preserve existing working screens.
- Preserve existing progress/history.
- Prefer additive extension over replacement.
- Avoid broad refactors before the new module boundaries are in place.

### Data migration

- Use additive SQLite migrations only.
- Keep current core tables in place:
  - `goals`
  - `goal_milestones`
  - `tasks`
  - `daily_plans`
  - `time_blocks`
  - rituals/reviews/history tables
- Add new nullable columns and new tables for:
  - goal graph relationships
  - next-step objects
  - feedback snapshots
  - widget preferences/layouts

### Domain migration

- Treat the new `GoalEngine` as an adapter over the current intake/decomposition flow at first.
- Existing goal creation should continue to work unchanged while richer goal metadata is introduced.

### UI migration

- Keep route structure unchanged initially.
- Refactor internals screen by screen:
  1. Goal detail modules
  2. Today widgets
  3. Plan widgets
- Do not attempt a whole-app premium UI rewrite in one pass.

### Progress preservation

- Backfill any new progress/feedback structures from:
  - `activity_events`
  - `time_blocks`
  - `daily_ritual_states`
  - `weekly_review_states`
  - `monthly_review_states`

### Platform strategy

- Do not introduce SwiftUI during the first migration.
- If a native SwiftUI shell is still desired later, first extract stable engine contracts so a native layer could consume:
  - goal graph snapshots
  - next-step snapshots
  - progress snapshots
  - feedback snapshots

## 6. Ordered Build Plan With Dependencies

### Phase 1: Add schema and contracts

Dependencies:

- none

Tasks:

- define `GoalGraph`, `NextStep`, `FeedbackSnapshot`, and widget contracts
- add additive migrations

Output:

- richer domain contract layer without breaking current app behavior

### Phase 2: Extend repositories

Dependencies:

- Phase 1

Tasks:

- add repository methods for:
  - goal relationships
  - next-step reads/writes
  - feedback snapshot reads/writes
  - widget preferences

Output:

- persistence support for modular engine work

### Phase 3: Build GoalEngine adapter

Dependencies:

- Phase 1
- Phase 2

Tasks:

- normalize current intake into canonical goal brief
- generate richer next-step outputs from decomposition
- preserve current goal creation path

Output:

- universal intake foundation without rewrite risk

### Phase 4: Build ProgressEngine

Dependencies:

- Phase 1
- Phase 2

Tasks:

- unify goal and ambition progress truth
- support untimed goals
- support learning and roll-up progress semantics

Output:

- reusable progress snapshots for screens and widgets

### Phase 5: Build FeedbackEngine

Dependencies:

- Phase 1
- Phase 2
- Phase 4

Tasks:

- derive adaptive feedback snapshots
- connect rituals, review states, and execution signals

Output:

- reusable feedback layer for planner and UI

### Phase 6: Introduce AmbitionsDesignSystem

Dependencies:

- Phase 1

Tasks:

- formalize widget shells
- formalize module shells
- refine dark-mode-first surface hierarchy
- add motion contracts

Output:

- premium UI foundation that still fits current screens

### Phase 7: Introduce GoalDetailModules

Dependencies:

- Phase 3
- Phase 4
- Phase 5
- Phase 6

Tasks:

- break `GoalDetailScreens.tsx` into modular reusable sections

Output:

- cleaner goal detail surface and better architecture for future screens

### Phase 8: Introduce DashboardWidgets

Dependencies:

- Phase 4
- Phase 5
- Phase 6

Tasks:

- refactor Today and Plan screens to render widget-based sections

Output:

- premium modular card composition without navigation changes

### Phase 9: Expand goal modes

Dependencies:

- Phase 3
- Phase 4
- Phase 5

Tasks:

- untimed goals
- learning goals
- child goals
- delegated goals
- support goals

Output:

- richer goal engine behaviors across planner, progress, and feedback

### Phase 10: Motion and polish

Dependencies:

- Phase 6
- Phase 7
- Phase 8

Tasks:

- add layout transitions
- richer entrance/expansion motion
- premium visual polish

Output:

- premium feel after architecture is stable

## Recommendation

The correct path is:

1. keep the current Expo/TypeScript engine core
2. add a real goal graph plus next-step and feedback layers
3. recompose Today, Plan, and Goal Detail into modular premium cards
4. treat SwiftUI as a later shell decision, not the first implementation step

This preserves current product momentum while creating a credible path to a premium modular goal-execution app.
