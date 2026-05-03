# CS04 Habits/Ritual/Plan Compatibility Seam Inventory

<!-- markdownlint-disable MD013 -->

Status: CS04A compatibility inventory for global order `043`.
Date: 2026-05-02

## Scope

CS04A maps the current Habits/Ritual/Plan seam before any rename, deletion, or retirement. No Swift, tests, routes, raw values, persistence/defaults, accessibility identifiers, dependencies, workflows, or product behavior are changed by this inventory.

## Source Truth Summary

- Top-level visible tabs are `Today / Goals / Capture / Plan / You`.
- `AppTab.habits` remains a hidden raw compatibility value with raw value `habits`.
- `AppTab.habits.canonicalTopLevelTab == .plan` and `AppTab.habits.title == "Rituals"`.
- `AppNavigationModel(selectedTab: .habits)` normalizes to `.plan` and opens `planPath = [.habits]`.
- `PlanRouteTarget.habits` is the current Plan-owned support route.
- `ambitions://tab/habits`, `ambitions://plan/habits`, and widget/notification payloads with `tab=habits` are compatibility surfaces.
- `Native/Ambitions/Features/Habits/**` still owns the Plan-owned Rituals route UI and service projection.
- `RitualModels` and `RitualOrchestrationService` are current semantic owners for recurring support-loop planning and must not be deleted as naming cleanup.

## Bucket Inventory

| Bucket | Current evidence | Risk | Recommended action | Owner |
| --- | --- | --- | --- | --- |
| User-facing copy that should stay canon-aligned | Shell visible tabs exclude Habits; Plan route button and support route show `Rituals`. | Green | Preserve `Plan` top-level and `Rituals` support copy. | CS04B/CS10 |
| Internal Swift type/file name that can remain `Habits` temporarily | `HabitsModels`, `HabitsFeatureService`, `HabitsScreen`, `HabitsViewModel`, `HabitComponents`, `PreviewHabitsScenarios`. | Yellow | Keep until route/raw/accessibility/test/domain proof says rename is safe. | CS04C/future owner |
| Route/raw value that must remain stable | `AppTab.habits.rawValue == "habits"`; `AppTab(rawValue: "habits") == .habits`; `PlanRouteTarget.habits`; `ambitions://tab/habits`; `ambitions://plan/habits`. | Red if changed now | Preserve and test old values before any retirement. | CS04B |
| Persistence/default value that must support compatibility | `AppState.preferredTab`, SwiftData `preferredTabRaw`, portable snapshots, imports, and profile preferences use `AppTab` raw values and canonicalization. | Yellow/Red if touched | Do not change defaults or raw values in CS04A; prove `.habits` canonicalizes to `.plan` in CS04B. | CS04B |
| Accessibility identifier that must remain stable | `habits.screen`, `habits.return-to-plan`, `habits.open-weekly-review`, `habits.empty.return-plan`, `plan.open-plan-habits-button`, `plan.open-habits-button`. | Red if renamed without proof | Freeze identifiers; document alias before any UI/test changes. | CS04B/CS04C |
| Test fixture or preview name | App shell, external routing, Plan, Habits, Ritual, UI tests, and preview scenarios. | Yellow | Keep as compatibility proof; only strengthen assertions. | CS04B |
| Documentation/canon wording | Active canon says Habits are absorbed into Rituals, Plan, Today, Reviews, and You; no top-level Habits tab. | Yellow | Mark CS04 as staged compatibility repair, not direct retirement. | CS04A |
| External shortcut/widget/deep-link assumption | `tab=habits`, `ambitions://tab/habits`, `ambitions://plan/habits`, `routePayload(.openPlanRoute(.habits))`. | Red if changed without proof | Preserve until external tests prove replacement. | CS04B |
| Ritual/Plan semantic reference | Habit-like goals, Ritual orchestration, Plan support route, weekly review references, external ritual cues. | Yellow/Red if deleted | Map each semantic owner before any rename. | CS04A/CS04C |
| Dead/obsolete reference | No active Habits source symbol is proven dead by CS04A discovery. | Yellow | Treat as live until tests and owner proof say otherwise. | CS04C |
| Unsafe/unclear reference requiring owner | Whether `Habits` folder/type names should eventually become `Rituals` conflicts with route/raw/accessibility compatibility and test names. | Yellow | Defer naming retirement to CS04C after CS04B proof. | CS04C/CS10 |

## High-Risk File Map

| File path | Symbol/string found | Current role | Risk | Safe to rename now? | Required validation before rename |
| --- | --- | --- | --- | --- | --- |
| `Native/Ambitions/App/AppTab.swift` | `case habits`, title `Rituals`, canonical tab `.plan` | Hidden raw compatibility tab. | Red if raw value removed | No | App tab, default/preferred-tab, shell, external route, UI proof. |
| `Native/Ambitions/App/AppNavigation.swift` | `PlanRouteTarget.habits`, `openHabits`, `planPath = [.habits]` | Plan support route stack. | Red if deleted | No | Route map, shell tests, UI tests, rollback. |
| `Native/Ambitions/App/AppExternalRouting.swift` | `.openPlanRoute(.habits)`, `ambitions://plan/habits`, `tab=habits` parsing | Deep-link/payload compatibility. | Red if changed | No | External route/widget/notification proof. |
| `Native/Ambitions/App/AmbitionsRootView.swift` | `case .habits`, `HabitsScreen()`, title `Rituals` | Hosts Plan-owned support route. | Yellow/Red if broad rename | No | UI navigation and accessibility proof. |
| `Native/Ambitions/Domain/HabitsModels.swift` | `Habit*`, `HabitsDashboard` | Route/service state models. | Yellow/Red if renamed | No | Service tests, preview proof, compatibility aliases. |
| `Native/Ambitions/Domain/RitualModels.swift` | `Ritual*` models | Current recurring-loop semantic model. | Green dependency | No deletion | Ritual service tests. |
| `Native/Ambitions/Services/RitualOrchestrationService.swift` | `RitualPlan`, `RitualRecommendation` | Plan/Today support-loop orchestration. | Yellow/Red if deleted | No | Ritual tests and semantic owner map. |
| `Native/Ambitions/Features/Habits/**` | `HabitsScreen`, `HabitsFeatureService`, `habits.*` ids | Plan-owned Rituals support route. | Red if renamed without alias proof | No | Habits service tests and UI identifier proof. |
| `Native/Ambitions/Features/Plan/**` | `PlanRouteTarget.habits`, `plan-habits`, `Rituals` support route | Plan support route and copy. | Yellow | Do not weaken | Plan tests and shell tests. |
| `Native/AmbitionsTests/App/AppShellNavigationTests.swift` | `.habits` hidden-tab/default proof | Compatibility proof. | Green dependency | Do not weaken | Add stronger CS04B proof if needed. |
| `Native/AmbitionsTests/App/ExternalRoutingTests.swift` | `tab=habits`, `.openTab(.habits)` proof | External compatibility proof. | Green dependency | Do not weaken | Add explicit legacy matrix in CS04B. |
| `Native/AmbitionsTests/Habits/**` | Habits service tests with Ritual copy assertions | Semantic/copy proof. | Green dependency | Do not weaken | Rerun in CS04B. |
| `Native/AmbitionsTests/Plan/**` | Plan-owned Ritual route tests | Plan support-route proof. | Green dependency | Do not weaken | Rerun in CS04B. |
| `Native/AmbitionsUITests/AmbitionsUITests.swift` | no Habits tab; Plan opens Rituals route | Rendered UI compatibility proof. | Yellow | Do not weaken | Run only if UI/identifier changes occur. |

## CS04A Result

Green for docs/protocol mapping with accepted Yellow. The original direct retirement remains unsafe. CS04B may add focused proof that current `habits` compatibility, visible Plan canon, and Plan-owned Rituals route can coexist. CS04C remains blocked until CS04B and semantic owner proof are Green or accepted Yellow.
