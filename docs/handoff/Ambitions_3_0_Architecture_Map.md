# Ambitions 3.0 Architecture Map

Status: Active engineer handoff packet
Last updated: 2026-05-01

## Architecture Shape

Ambitions is a native SwiftUI iOS app with XcodeGen as project source of truth.

Core ownership:

| Layer | Owner paths | Responsibility |
| --- | --- | --- |
| App shell | `Native/Ambitions/App` | App entry, dependency container, environment injection, shell, tab routing, overlays, deep links, App Intent launch routing. |
| Domain | `Native/Ambitions/Domain` | Value models, contracts, state machines, receipts, proof, recommendation, planning, command, safe automation, and screen contracts. |
| Services | `Native/Ambitions/Services` | Service protocols and deterministic implementations. |
| Persistence | `Native/Ambitions/Persistence` | SwiftData models, repositories, portable snapshots, import/export. |
| Features | `Native/Ambitions/Features` | SwiftUI surfaces and feature-local view models for Today, Goals, Capture, Plan, You, Reviews/history support, and compatibility surfaces. |
| Shared UI | `Sources` | Design system components, theme, accessibility helpers, primitives. |
| App UI package | `AppUI/Sources` | Widget/shared app UI components. |
| Preview support | `Native/Ambitions/PreviewSupport` | Demo/preview fixtures and scenarios. |

## Destination Ownership

| Destination | User-facing label | Primary code seam | Notes |
| --- | --- | --- | --- |
| Today | Today | `Native/Ambitions/Features/Today` | Reality Rail, Step Detail, Step Session, Action Closure, proof/receipt peek. |
| Goals | Goals | `Native/Ambitions/Features/Goals` | Goals board, Goal Detail, Mission Control, path/portfolio maturity, trust/memory below strategy. |
| Capture | Capture | `Native/Ambitions/Features/Captures` | Quick capture, Needs a Place, placement preview, Grow into Goal handoff. |
| Plan | Plan | `Native/Ambitions/Features/Plan` | Day/Week/Life Shape, recovery, reflow, calendar boundaries, Plan Life Suite. |
| You | You | `Native/Ambitions/Features/Profile` | Personal System Center, Trust Center, What Ambitions Knows, settings, reviews/history support. |

There is no top-level Insights, Habits, Tasks, Calendar, Profile, Life Areas,
or AI tab.

## State And Projection Pattern

Preferred pattern:

1. Domain/services hold durable concepts and logic.
2. Feature state structs hold renderable facts only.
3. Projectors translate domain/service data into screen state.
4. SwiftUI views render state and emit typed actions.
5. Tests protect product contracts, privacy projection, routing, and copy
   boundaries.

Avoid putting domain projection logic into large SwiftUI views. Avoid adding
new behavior to extraction-required files without a written exception or a
bounded extraction.

## Shell And Routing

Canonical tabs are defined by `AppTab`.

Current shell work preserves native fallback navigation and Meridian shell
feature-flag behavior. External routes normalize legacy values into current
destinations where needed.

Important compatibility areas:

- `AppTab.habits` maps legacy route/preference compatibility into current
  Ritual/Plan handling.
- `AppTab.insights` and `InsightsRouteTarget` preserve history/contextual
  intelligence routing under current IA.
- You is user-facing, while internal feature folder/type names still use
  Profile.

## Trust, Memory, Privacy

You/Profile owns trust and memory controls:

- Trust Center
- What Ambitions Knows
- personalization consent
- source/freshness labels
- safe correction/delete/pause boundaries

Goal Detail may show goal-local trust/memory context below the strategic
layer, but You remains the control plane for broader memory and privacy.

External surfaces must be privacy-safe by default and must not expose sensitive
raw content without explicit, tested projection rules.

## Tests To Know

Representative suites:

- Shell/routing: `Native/AmbitionsTests/App/AppShellNavigationTests.swift`
- Today: `Native/AmbitionsTests/Today/TodayViewModelTests.swift`
- Goals/Goal Detail: `Native/AmbitionsTests/Goals/GoalDetailStrategicPresentationTests.swift`
- You/Profile trust-memory: `Native/AmbitionsTests/Profile/ProfileFeatureServiceTests.swift`
- Capture: `Native/AmbitionsTests/Capture`
- Plan: `Native/AmbitionsTests/Plan`
- UI smoke: `Native/AmbitionsUITests/AmbitionsUITests.swift`

UI tests should assert product contracts, stable accessibility identifiers, and
route reachability. Do not weaken tests into shallow existence checks without
replacement evidence.

## Architecture Debt Index

Highest-risk files from the latest F27.5 scan:

- `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`
- `Native/Ambitions/Features/Today/TodayFeatureService.swift`
- `Native/Ambitions/Features/Today/TodayPanels.swift`
- `Native/Ambitions/Features/Plan/PlanFeatureService.swift`
- `Native/Ambitions/Features/Profile/ProfileScreen.swift`
- `Native/Ambitions/Features/Plan/PlanScreen.swift`
- extraction-required domain and persistence model/service files

Treat this as a first-refactor map, not as permission for broad rewrites.
