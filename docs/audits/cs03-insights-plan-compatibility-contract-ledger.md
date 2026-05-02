# CS03 Insights/Plan Compatibility Contract Ledger

<!-- markdownlint-disable MD013 -->

Status: CS03A compatibility contract ledger for global order `042`.
Date: 2026-05-02

## Contract Rule

`Insights` is a compatibility and contextual-intelligence seam, not a current
top-level product destination. User-facing top-level IA remains
`Today / Goals / Capture / Plan / You`. Old `insights` raw values, route
targets, deep links, payloads, tests, and accessibility identifiers must remain
stable until a replacement map and focused proof pass.

## Ledger

| Symbol/string | File path | Current role | User-facing or internal | Route/raw-value status | Persistence/defaults status | Accessibility identifier status | Test dependency status | External/deep-link/shortcut/widget status | Contextual-intelligence status | Safe action now | Unsafe action | Required proof before retirement | Owner |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `AppTab.insights` / `insights` | `Native/Ambitions/App/AppTab.swift` | Hidden legacy tab/raw value | Internal/raw | Stable legacy value | May appear in selected/default tab storage | Not an identifier itself | Shell/external tests depend on it | Deep links and payloads may carry `insights` | Old top-level tab compatibility | Preserve; add proof | Delete or change raw value | Raw parser, selected/default tab, shell, external route, UI proof | CS03B |
| `AppTab.insights.title == "History"` | `Native/Ambitions/App/AppTab.swift` | Display helper for hidden support route | Internal/support copy | Not a raw value | None directly | May affect UI if surfaced | Tests depend on no visible top-level Insights | None directly | Analytics/review history semantics | Preserve until owner decision | Pretend it is `Plan` without behavior proof | Shell visible-title proof and product owner route decision | CS03B/CS10 |
| `InsightsRouteTarget` | `Native/Ambitions/App/AppNavigation.swift` | Monthly review/history route target | Internal route type | Stable route target | None directly | Route screens have `insights.*` ids | Shell/UI tests depend on it | `ambitions://insights/*` uses it | Review/history contextual intelligence | Preserve | Delete without adapter | Route adapter, deep-link proof, UI proof, rollback | CS03B/CS03C |
| `insightsPath` | `Native/Ambitions/App/AppNavigation.swift`, `AmbitionsRootView.swift` | Navigation path for history/monthly review | Internal navigation | Tied to `InsightsRouteTarget` | None directly | Hosts route screen IDs | Shell/UI tests | External route dispatch reaches it | Review/history support stack | Preserve | Collapse into Plan path without proof | Back/return, shell, UI route tests | CS03B/CS03C |
| `ambitions://tab/insights` | `AppExternalRouting.swift`, UI tests | Legacy top-level tab deep link | External/raw | Must remain supported | May initialize selected tab | No direct id | UI/external tests | Deep link compatibility | Old tab compatibility | Preserve | Remove or redirect silently | External route tests and visible destination proof | CS03B |
| `ambitions://insights/monthly-review` | `AppExternalRouting.swift`, UI tests | Legacy review route | External route | Must remain supported | None directly | `insights.monthly-review.screen` | UI/external tests | Deep link compatibility | Analytics/review history | Preserve | Remove without adapter | External/UI proof and destination owner | CS03B |
| `ambitions://insights/history` | `AppExternalRouting.swift`, UI tests | Legacy history route | External route | Must remain supported | None directly | `insights.history.screen` | UI/external tests | Deep link compatibility | History/proof/review | Preserve | Remove without adapter | External/UI proof and destination owner | CS03B |
| `InsightsFeatureService` / `InsightsServicing` | `AppServices.swift`, `Features/Insights` | Contextual intelligence projection | Internal service | Not raw route | Reads repositories | None directly | Service tests | None directly | Contextual intelligence/review/proof | Preserve | Rename/delete as tab cleanup | Service tests, semantics map, owner replacement | CS03C/future PD/AOS |
| `InsightsModels` | `Domain/InsightsModels.swift` | Domain models for insight dashboard/history | Internal/domain | Some model fields include routes | Possible export/persistence adjacency unknown | None directly | Service tests | None directly | Contextual intelligence semantics | Preserve | Delete semantic models | Semantic owner proof and tests | CS03C/future PD/AOS |
| `insights.*` accessibility IDs | `Features/Insights/InsightsScreen.swift` | UI automation identifiers | Accessibility/test surface | Not route raw values | None directly | Stable IDs | UI tests depend on them | External route smokes land on them | Route-screen proof | Freeze | Rename without alias/deprecation | Identifier ledger, UI proof, replacement map | CS03B/CS03C |
| Plan top-level tab | `AppTab.allCases`, shell tests | Canonical visible top-level destination | User-facing | `plan` raw value stable | Default/preferred tab can use `.plan` | Shell destination ids | Shell/UI tests | `ambitions://tab/plan` | Plan surface | Preserve | Regress or duplicate with Insights | Shell and route proof | Every CS batch |

## Route Target And External Routing Matrix

| Input / legacy assumption | Current expected resolution | Required proof owner |
| --- | --- | --- |
| `insights` raw tab value | `AppTab.insights`; canonical top-level currently `.profile`; history route opens. | CS03B |
| `InsightsRouteTarget.monthlyReview/history` | Remain compatible support routes until owner replacement exists. | CS03B/CS03C |
| external route to `ambitions://tab/insights` | Opens compatibility destination without adding top-level Insights. | CS03B |
| external route to `ambitions://insights/*` | Opens monthly review/history support route. | CS03B |
| unknown route value | Safe generic external fallback or nil route. | CS03B |
| duplicate Plan/Insights destination | Must not exist as top-level tabs. | CS03B/CS10 |
| user-facing tab label | Visible top-level shell remains `Plan`, not `Insights`. | CS03B/CS10 |

## Rollback

CS03A is docs/control only and can be reverted without app migration. CS03B
proof changes must preserve current `insights` compatibility assertions. CS03C
rename attempts must leave route, raw-value, accessibility, and semantic aliases
until all consumers are proven migrated.

## Result

Green for CS03A ledger creation with accepted Yellow: the prompt-requested
Insights-to-Plan direction conflicts with current implementation routing to
You/history support. CS03B owns focused proof and any explicit destination
decision; CS03C remains blocked.
