# CS03 Insights/Plan Compatibility Seam Inventory

<!-- markdownlint-disable MD013 -->

Status: CS03A compatibility inventory for global order `042`.
Date: 2026-05-02

## Scope

CS03A maps the current Insights seam before any rename, deletion, or retirement.
No Swift, tests, routes, raw values, persistence/defaults, accessibility
identifiers, dependencies, workflows, or product behavior are changed by this
inventory.

## Source Truth Adjustment

The repair prompt names an Insights-to-Plan direction. Current repo truth is
more specific:

- the active top-level tabs are `Today / Goals / Capture / Plan / You`;
- `Insights` is not a top-level tab;
- `AppTab.insights` remains a hidden raw compatibility value;
- current navigation normalizes `.insights` to `.profile` and opens
  `insightsPath = [.history]`;
- `InsightsRouteTarget` routes monthly review and history support screens under
  the You/Profile navigation stack today;
- Plan owns weekly review and planning surfaces, but current `insights` route
  compatibility is not yet proven to be a direct Plan migration.

CS03 must therefore preserve `insights` compatibility and contextual
intelligence semantics first. Any future Plan-owned migration requires focused
proof rather than assumption.

## Bucket Inventory

| Bucket | Current evidence | Risk | Recommended action | Owner |
| --- | --- | --- | --- | --- |
| User-facing copy that should say `Plan` | `AppTab.allCases` visible titles are `Today`, `Goals`, `Capture`, `Plan`, `You`; tests reject a top-level `Insights` tab. | Green | Preserve visible `Plan`; do not add `Insights` to top-level shell. | CS03B/CS10 |
| Internal Swift type/file name that can remain `Insights` temporarily | `Native/Ambitions/Domain/InsightsModels.swift`; `Native/Ambitions/Features/Insights/**`; `InsightsFeatureService`; `InsightsScreen`; `InsightsViewModel`; `InsightsServicing`. | Yellow | Keep as contextual-intelligence/history support owners until semantics and destinations are replaced with proof. | CS03C or future PD/AOS owner |
| Route/raw value that must remain stable | `AppTab.insights.rawValue == "insights"`; `AppTab(rawValue: "insights") == .insights`; `InsightsRouteTarget.monthlyReview/history`; `ambitions://tab/insights`; `ambitions://insights/monthly-review`; `ambitions://insights/history`. | Red if renamed now | Preserve and test old values before any retirement. | CS03B |
| Persistence/default value that must support compatibility | `AppNavigationModel(selectedTab: .insights)` normalizes to `.profile` and opens history; app preferences may encode `AppTab` raw values. | Yellow/Red if touched | Do not change defaults or raw values in CS03A; add default/selected-tab proof in CS03B if touched. | CS03B |
| Accessibility identifier that must remain stable | `insights.screen`, `insights.monthly-review.screen`, `insights.history.screen`, `insights.hero-card`, `insights.history-layer`, related route/action identifiers. | Red if renamed without alias proof | Freeze identifiers; document replacement map before any UI/test changes. | CS03B/CS03C |
| Test fixture or preview name | `AppShellNavigationTests`, `ExternalRoutingTests`, `AmbitionsUITests`, `InsightsFeatureServiceTests`, degraded-state tests. | Yellow | Keep tests as compatibility proof; only strengthen assertions. | CS03B |
| Documentation/canon wording | Active docs reject top-level Insights; older docs preserve Insights as history/contextual intelligence. | Yellow | Mark current CS03 as staged compatibility repair, not direct retirement. | CS03A |
| External shortcut/widget/deep-link assumption | Deep links and payloads can carry `tab=insights`; external routing supports explicit `insights` host routes. | Red if changed without proof | Preserve until external tests prove replacement. | CS03B |
| Contextual-intelligence semantic reference | Insights models and service encode review/history/pattern/proof/goal/plan handoff semantics. | Yellow/Red if deleted | Map semantics to You, Plan, PD, or AOS owner before renaming. | CS03A/CS03C |
| Dead/obsolete reference | No active `Insights` source symbol is proven dead by CS03A discovery. | Yellow | Treat as live until tests and owner proof say otherwise. | CS03C |
| Unsafe/unclear reference requiring owner | Whether legacy Insights should ultimately normalize to Plan instead of You/Profile conflicts with current implementation. | Yellow | Defer destination-change decision to CS03B proof or CS10 handoff; no code change in CS03A. | CS03B/CS10 |

## High-Risk File Map

| File path | Symbol/string found | Current role | Risk | Safe to rename now? | Required validation before rename |
| --- | --- | --- | --- | --- | --- |
| `Native/Ambitions/App/AppTab.swift` | `case insights`, title `History`, canonical tab `.profile` | Hidden raw compatibility tab. | Red if raw value removed | No | App tab, default-tab, shell, external route, UI proof. |
| `Native/Ambitions/App/AppNavigation.swift` | `InsightsRouteTarget`, `insightsPath`, `openInsightsRoute` | You/Profile support route stack for history/monthly review. | Red if deleted | No | Route map, shell tests, UI tests, rollback. |
| `Native/Ambitions/App/AppExternalRouting.swift` | `.openInsightsRoute`, `ambitions://insights/*`, route payloads | Deep-link/payload compatibility. | Red if changed | No | External route/widget/notification proof. |
| `Native/Ambitions/App/AmbitionsRootView.swift` | `NavigationStack(path: $navigation.insightsPath)` | Hosts Insights route screens under the selected shell. | Yellow | No | UI navigation and accessibility proof. |
| `Native/Ambitions/Domain/InsightsModels.swift` | `Insights*` models | Contextual intelligence/review/history domain models. | Yellow/Red if semantic loss | No | Semantics map and focused service tests. |
| `Native/Ambitions/Features/Insights/**` | `InsightsScreen`, route screens, identifiers | Contextual intelligence/history UI. | Yellow/Red if broad rename | No | UI/accessibility identifier and service proof. |
| `Native/AmbitionsTests/App/AppShellNavigationTests.swift` | `.insights` hidden-tab assertions | Compatibility proof. | Green dependency | Do not weaken | Add stronger proof in CS03B. |
| `Native/AmbitionsTests/App/ExternalRoutingTests.swift` | Insights route/payload tests | External compatibility proof. | Green dependency | Do not weaken | Add explicit legacy-route matrix in CS03B. |
| `Native/AmbitionsUITests/AmbitionsUITests.swift` | Legacy Insights UI route smokes | Rendered route compatibility proof. | Yellow | Do not weaken | Run only if UI/identifier changes occur. |
| `Native/AmbitionsTests/Insights/InsightsFeatureServiceTests.swift` | `InsightsFeatureServiceTests` | Semantic/contextual-intelligence service proof. | Green dependency | No | Rerun before semantic rename/deletion. |

## CS03A Result

Green for docs/protocol mapping with accepted Yellow. The original direct
retirement remains unsafe. CS03B may add focused proof that current `insights`
compatibility, visible `Plan`, and no top-level Insights can coexist. CS03C
remains blocked until CS03B and semantic owner proof are Green or accepted
Yellow.
