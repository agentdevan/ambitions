# CS04 Habits/Ritual/Plan Compatibility Contract Ledger

<!-- markdownlint-disable MD013 -->

Status: CS04A compatibility contract ledger for global order `043`.
Date: 2026-05-02

## Contract Rule

`Habits` is a compatibility seam, not a current top-level product destination. User-facing top-level IA remains `Today / Goals / Capture / Plan / You`. The Plan-owned support route may say `Rituals`. Old `habits` raw values, route targets, deep links, payloads, tests, model owners, and accessibility identifiers must remain stable until a replacement map and focused proof pass.

## Ledger

| Symbol/string | File path | Current role | User-facing or internal | Route/raw-value status | Persistence/defaults status | Accessibility identifier status | Test dependency status | External/deep-link/shortcut/widget status | Ritual/Plan semantic status | Safe action now | Unsafe action | Required proof before retirement | Owner |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `AppTab.habits` / `habits` | `Native/Ambitions/App/AppTab.swift` | Hidden legacy tab/raw value | Internal/raw | Stable legacy value | May appear in selected/preferred/default tab storage | Not an id itself | Shell/external tests depend on it | Deep links and payloads may carry `habits` | Old top-level tab compatibility | Preserve; add proof | Delete or change raw value | Raw parser, selected/default tab, shell, external route, UI proof | CS04B |
| `AppTab.habits.title == "Rituals"` | `AppTab.swift` | Display helper for hidden support route | Support copy | Not a raw value | None directly | May affect UI if surfaced | Tests assert Ritual copy | None directly | Ritual support semantics | Preserve | Revert to visible Habits product copy | Shell visible-title proof and product owner decision | CS04B/CS10 |
| `PlanRouteTarget.habits` | `AppNavigation.swift` | Plan support route target | Internal route type | Stable route target | None directly | Leads to `habits.*` route screen ids | Shell/UI tests depend on it | `ambitions://plan/habits` uses it | Plan-owned Rituals route | Preserve | Delete without adapter | Route adapter, deep-link proof, UI proof, rollback | CS04B/CS04C |
| `planPath = [.habits]` | `AppNavigation.swift`, `AmbitionsRootView.swift` | Navigation path for Rituals support route | Internal navigation | Tied to `PlanRouteTarget.habits` | None directly | Hosts `habits.screen` | Shell/UI tests | External route dispatch reaches it | Plan support route stack | Preserve | Collapse or rename without proof | Back/return, shell, UI route tests | CS04B/CS04C |
| `ambitions://tab/habits` | `AppExternalRouting.swift`, tests | Legacy top-level tab deep link | External/raw | Must remain supported | May initialize selected tab | No direct id | UI/external tests | Deep link compatibility | Old tab compatibility | Preserve | Remove or redirect silently | External route tests and visible destination proof | CS04B |
| `ambitions://plan/habits` | `AppExternalRouting.swift`, generated deep links | Plan-owned Rituals route | External route | Must remain supported | None directly | `habits.screen` | External/UI tests | Deep link compatibility | Ritual/Plan support | Preserve | Remove without adapter | External/UI proof and destination owner | CS04B |
| widget/notification `tab=habits` | `AppExternalRouting.swift`, tests | Legacy payload route | External payload | Must remain supported | None directly | No direct id | External tests | Widget/notification compatibility | Old tab compatibility | Preserve | Remove without migration | Widget/notification route proof | CS04B |
| `HabitsFeatureService` / `HabitsServicing` | `AppServices.swift`, `Features/Habits` | Rituals support route projection | Internal service | Not raw route | Reads repositories; action writes evidence/feedback | None directly | Habits tests depend on it | None directly | Recurring goal support semantics | Preserve | Rename/delete as tab cleanup | Service tests, semantic map, owner replacement | CS04C/future PD/SI |
| `HabitsModels` / `Habit*` | `Domain/HabitsModels.swift` | Route/service state and action models | Internal/domain | Some action ids use raw kind values | Evidence notes may include Rituals copy | None directly | Habits tests | None directly | Route/service state semantics | Preserve | Delete semantic models | Semantic owner proof and tests | CS04C/future PD/SI |
| `RitualModels` / `RitualOrchestrationService` | `Domain/RitualModels.swift`, `Services/RitualOrchestrationService.swift` | Current recurring-loop semantic model and planner | Internal/domain | Not route raw values | Codable ritual cue models may affect external snapshots | None directly | Ritual tests and snapshot tests | External snapshot ritual cues | Ritual/Plan semantics | Preserve | Delete as Habits cleanup | Ritual, snapshot, Plan tests and owner replacement | future PD/AOS |
| `habits.*` accessibility IDs | `Features/Habits/HabitsScreen.swift` | UI automation identifiers for Plan-owned Rituals route | Accessibility/test surface | Not route raw values | None directly | Stable ids | UI tests depend on them | External route smokes may land on them | Route-screen proof | Freeze | Rename without alias/deprecation | Identifier ledger, UI proof, replacement map | CS04B/CS04C |
| `plan.open-plan-habits-button` / `plan.open-habits-button` | `PlanScreen.swift`, UI tests | Plan entry to Rituals route | Accessibility/test surface | Not raw value | None directly | Stable ids | UI tests depend on them | None directly | Plan support route | Freeze | Rename as copy cleanup | UI proof and replacement map | CS04B/CS04C |
| Plan top-level tab | `AppTab.allCases`, shell tests | Canonical visible top-level destination | User-facing | `plan` raw value stable | Default/preferred tab can use `.plan` | Shell destination ids | Shell/UI tests | `ambitions://tab/plan` | Plan surface | Preserve | Regress or duplicate with Habits | Shell and route proof | Every CS batch |

## Route Target And External Routing Matrix

| Input / legacy assumption | Current expected resolution | Required proof owner |
| --- | --- | --- |
| `habits` raw tab value | `AppTab.habits`; canonical top-level `.plan`; Plan route `.habits` opens. | CS04B |
| `PlanRouteTarget.habits` | Remains compatible Plan-owned Rituals route. | CS04B/CS04C |
| external route to `ambitions://tab/habits` | Opens Plan-owned Rituals route without adding top-level Habits. | CS04B |
| external route to `ambitions://plan/habits` | Opens Plan-owned Rituals route. | CS04B |
| widget/notification payload `tab=habits` | Opens legacy Habits compatibility path. | CS04B |
| preferred/default tab `.habits` | Canonicalizes to `.plan`; no visible Habits default. | CS04B |
| unknown route value | Safe generic external fallback or nil route. | CS04B |
| duplicate Habits/Rituals destination | Must not exist as top-level tabs. | CS04B/CS10 |
| user-facing tab label | Visible top-level shell remains `Plan`, not `Habits`. | CS04B/CS10 |

## Rollback

CS04A is docs/control only and can be reverted without app migration. CS04B proof changes must preserve current `habits` compatibility assertions. CS04C rename attempts must leave route, raw-value, accessibility, and semantic aliases until all consumers are proven migrated.

## Result

Green for CS04A ledger creation with accepted Yellow: internal `Habits` names remain live compatibility surfaces. CS04B owns focused proof; CS04C remains blocked.
