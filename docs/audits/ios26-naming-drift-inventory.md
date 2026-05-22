# IOS26 Naming Drift Inventory

Status: docs-only drift inventory; not implementation proof
Generated: 2026-05-22

## Scope

This inventory classifies naming drift hits from the batch scan and a small set of focused source reads. It does not claim implementation completeness or release readiness.

## Method

Inputs used:

- Batch prompt grep over `Native`, `Sources`, `AppUI`, `docs`, and `prompts`
- Focused `rg`/`nl` reads for the main compatibility seams
- Active truth files for product and implementation classification

Truth files consulted:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`

## Inventory Summary

| Classification | What showed up | Current read |
| --- | --- | --- |
| Active user-facing | `Today`, `Goals`, `Capture`, `Time`, `You`, `Start here`, `Reality Meridian`, `LifeShape Field` | Canonical surface language is active and should stay primary. |
| Active compatibility | `Plan`, `Profile`, `captures`, `Habits`, `Insights`, `Mission Control` | Present as aliases, raw-value compatibility, or internal/legacy seams. |
| Test proof | `AppShellNavigationTests`, `YouFeatureServiceTests`, `StartHereProductKernelTests`, `AccessibilityNutritionChecklistTests` | These tests help lock the naming boundary and catch regressions. |
| Supporting doc | `docs/truth/*`, `docs/codex/*`, old batch prompts and reports | Helpful for context, but not source proof. |
| Historical | `DayTimelineRail`, `Hero Step`, older `Plan/Profile/Habits/Insights` batch docs | Historical or compatibility-only wording; do not restore as active IA. |
| Pre-shell / pre-release | `Task` in capture routing, goal routing, and proof flow language | Mostly internal object vocabulary or Swift concurrency syntax, not a top-level tab. |

## Selected Source Evidence

| Term | Classification | Evidence |
| --- | --- | --- |
| `Plan` | Active compatibility | [`Native/Ambitions/App/AppTab.swift`](../../Native/Ambitions/App/AppTab.swift), [`Native/Ambitions/Features/Capture/CapturePlacementReviewState.swift`](../../Native/Ambitions/Features/Capture/CapturePlacementReviewState.swift) |
| `Profile` | Active compatibility | [`Native/Ambitions/App/AppTab.swift`](../../Native/Ambitions/App/AppTab.swift), [`Native/Ambitions/Features/You/YouFeatureService.swift`](../../Native/Ambitions/Features/You/YouFeatureService.swift) |
| `captures` | Active compatibility | [`Native/Ambitions/App/AppTab.swift`](../../Native/Ambitions/App/AppTab.swift) |
| `Habits` | Active compatibility / historical | [`Native/Ambitions/App/AppTab.swift`](../../Native/Ambitions/App/AppTab.swift), test coverage in `Native/AmbitionsTests/App/AppShellNavigationTests.swift` |
| `Insights` | Active compatibility / historical | [`Native/Ambitions/App/AppTab.swift`](../../Native/Ambitions/App/AppTab.swift), test coverage in `Native/AmbitionsTests/App/AppShellNavigationTests.swift` |
| `Mission Control` | Active compatibility | [`Native/Ambitions/Features/Goals/GoalMissionControlLanePrimitives.swift`](../../Native/Ambitions/Features/Goals/GoalMissionControlLanePrimitives.swift) |
| `Today / Goals / Capture / Time / You` | Active user-facing | [`Native/Ambitions/App/AppTab.swift`](../../Native/Ambitions/App/AppTab.swift), [`Native/Ambitions/App/AmbitionsRootView.swift`](../../Native/Ambitions/App/AmbitionsRootView.swift) |
| `Start here` | Active user-facing | [`Native/Ambitions/Features/Today/TodayStartHereSurface.swift`](../../Native/Ambitions/Features/Today/TodayStartHereSurface.swift) |
| `Reality Meridian` | Active user-facing | `Native/Ambitions/Features/Today/*` and top-level shell composition in `Native/Ambitions/App/AmbitionsRootView.swift` |
| `LifeShape Field` | Active user-facing | `Native/Ambitions/Features/Time/TimeLifeShapeField.swift` and related `Time/*` surfaces |
| `What Ambitions Knows` / `User System Profile` | Active user-facing / compatibility seam | `Native/Ambitions/Features/You/YouFeatureService.swift` and the You surface stack |
| `Task` | Pre-shell / pre-release | [`Native/Ambitions/Features/Capture/CapturePlacementReviewState.swift`](../../Native/Ambitions/Features/Capture/CapturePlacementReviewState.swift), [`Native/Ambitions/Features/Capture/CaptureAtmosphereComposer.swift`](../../Native/Ambitions/Features/Capture/CaptureAtmosphereComposer.swift), [`Native/Ambitions/Features/Goals/GoalsFeatureModels.swift`](../../Native/Ambitions/Features/Goals/GoalsFeatureModels.swift) |

## Classification Notes

- `Plan` remains an internal compatibility seam in source and should not be promoted back to top-level IA.
- `Profile` is currently a compatibility label for the You surface and related trust/history language.
- `captures` survives as a raw value / legacy routing compatibility term.
- `Habits` and `Insights` still appear in source and tests, but their active user-facing titles are `Rituals` and `History` in the compatibility shell.
- `Mission Control` remains an internal Goals depth term. It is not a top-level shell destination.
- `DayTimelineRail` and `Hero Step` are historical terms in the current canon and should remain quarantined to supporting/history material.
- `Task` is overloaded. Most grep hits are Swift concurrency `Task { ... }`; the remaining product-facing hits are internal object vocabulary such as Task/Today routing, not a user-facing top-level noun.

## Proof Boundary

This file does not prove implementation, build success, test success, accessibility conformance, performance, release readiness, or API adoption.
