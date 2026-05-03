# CS05 ActiveFocus/TodayFocus Compatibility Seam Inventory

<!-- markdownlint-disable MD013 -->

Status: CS05A compatibility seam inventory for global order `044`.
Date: 2026-05-03

## Inventory Rule

`activeFocus`, `TodayFocus*`, `.focus`, and FocusNow symbols are live compatibility seams. They are not proof that user-facing Ambitions should remain focus-mode first. They preserve external snapshot schema, Today state contracts, shell command routing, App Intent / shortcut behavior, widget projection, and historical tests until a schema-versioned adapter and focused proof exist.

## Inventory

| File path | Symbol/string found | Current role | Bucket | Risk | Recommended action | Owner | Safe to rename now | Required validation before rename |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `Native/Ambitions/Domain/CanonicalNowStateModels.swift` | `activeFocus` | Runtime/domain now-state reference used by external projection. | External snapshot/schema compatibility | Red if removed | Preserve through CS05B proof. | CS05B/CS05C | No | Domain model tests, external snapshot encode/decode tests, action payload projection tests, rollback adapter. |
| `Native/Ambitions/ExternalSnapshots/ExternalSurfaceSnapshotContracts.swift` | `ExternalSurfaceNowState.activeFocus` | Codable external snapshot field. | External schema | Red if renamed or deleted | Preserve old JSON key. | CS05B/CS05C | No | Legacy JSON fixture decode, encode shape check, schema-versioned adapter proof. |
| `Native/Ambitions/ExternalSnapshots/ExternalSurfaceSnapshotBuilder.swift` | `activeFocus: nil`; `activeFocus ?? bestNextStep` | Builds external snapshot and ambient focus primary reference. | External projection/payload | Red if changed casually | Preserve fallback behavior until replacement is proven. | CS05B | No | External snapshot, widget projection, action payload tests. |
| `Native/Ambitions/ExternalSnapshots/ExternalSurfaceActionPayloads.swift` | `nowState.activeFocus ?? nowState.bestNextStep` | Chooses primary external action reference. | External action payload | Red if changed casually | Preserve or add additive adapter only. | CS05B | No | Action payload tests with old and current references. |
| `Native/Ambitions/Features/Today/TodayFeatureModels.swift` | `TodayFocusPlannedState`, `TodayFocusStarterState`, `TodayFocusClarificationState`, `TodayFocusBlockedState`, `TodayFocusState` | Today feature state for bounded execution/step posture. | Internal Today state/service seam | Red for broad rename | Preserve until Today state migration is explicitly proven. | CS05C/future PD03 | No | Today feature service/model tests, UI route tests, copy scan, file-size review. |
| `Native/Ambitions/Features/Today/TodayFeatureService.swift` | `makeFocus(...) -> TodayFocusState`; `focus:` fields | Today projection and service state assembly. | Internal Today service seam | Red for broad rename | Preserve until an owned Step Session migration exists. | CS05C/future PD03 | No | TodayFeatureService tests, TodayViewModel tests, shell route tests. |
| `Native/Ambitions/App/AppNavigation.swift` | `TodayEntryContext.focus`; `.focus` return/reason copy | Today route context for legacy focus/step posture. | Route/raw compatibility | Red if removed | Preserve legacy `.focus` context. | CS05B/CS05C | No | Shell navigation and external route tests. |
| `Native/Ambitions/App/AppExternalRouting.swift` | `.focus`, `.stepSession: .focus`, "Quick focus" | External route target and route normalization. | External/deep-link compatibility | Red if removed | Preserve route adapter behavior. | CS05B | No | ExternalRouting tests for `context=focus` and step-session compatibility. |
| `Native/Ambitions/App/ShellCommandModels.swift` | `quick_focus` | Raw shell command value for quick focus. | Raw/action compatibility | Red if renamed | Preserve raw value and user-visible copy only with product-language proof. | CS05B/CS05C | No | Shell command tests, receipt tests, no-copy-regression scan. |
| `Native/Ambitions/App/ShellCommandRouter.swift` | `navigation.selectToday(entryContext: .focus)` | Shell quick command route. | Shell/navigation compatibility | Red if changed casually | Preserve current route behavior. | CS05B | No | Shell command routing tests. |
| `Native/Ambitions/App/AppShellView.swift` | `queueTodaySelectionAfterOverlayDismiss(entryContext: .focus)` | UI command route selection after overlay. | Shell/UI route compatibility | Red if changed casually | Preserve current route behavior. | CS05B | No | App shell tests and UI route smoke if touched. |
| `AppUI/Sources/WidgetFoundation.swift` | `case focusNow` | Widget family identity. | Widget/raw compatibility | Red if deleted | Preserve until widget migration proof exists. | CS05B/CS05C | No | Widget projection tests and rendered widget proof if ever claimed. |
| `AppUI/Sources/WidgetFamiliesPrimary.swift` | `FocusNowWidget`, `FocusNowContent`, `FocusNowWidgetViewModel`, "Focus Now" | Widget UI model and view. | Widget/AppUI compatibility | Yellow/Red depending touch | Preserve in CS05A; map for later copy/widget proof. | CS05B/CS05C | No | Widget projection tests, preview proof, copy scan, compatibility adapter. |
| `AppUI/Sources/WidgetPreviews.swift` | `FocusNowWidgetViewModel` fixtures | Preview fixtures for FocusNow widget. | Test/preview fixture | Yellow | Preserve until widget family is migrated. | CS05B/CS05C | No | Preview/fixture coverage and widget tests. |
| `Native/AmbitionsTests/App/ExternalSurfaceSnapshotTests.swift` | old JSON containing `"activeFocus"` | Legacy schema decode proof. | Test fixture | Green preserve / Red delete | Keep and expand in CS05B. | CS05B | No | Focused external snapshot tests. |
| `Native/AmbitionsTests/App/ExternalSurfaceActionPayloadTests.swift` | `activeFocus: nil` constructors | Action payload fixture compatibility. | Test fixture | Yellow | Keep and refine in CS05B. | CS05B | No | Focused action payload tests. |
| `Native/AmbitionsTests/App/ExternalWidgetProjectionTests.swift` | external now/focus projection fixtures | Widget/external projection proof. | Test fixture | Yellow | Keep and refine in CS05B. | CS05B | No | Focused widget projection tests. |
| `Native/AmbitionsTests/App/AppIntentRoutingTests.swift` | `context=focus` route | App Intent / shortcut compatibility proof. | External shortcut/App Intent | Red if removed | Keep and refine in CS05B. | CS05B | No | App Intent routing tests. |
| `Native/AmbitionsTests/App/ExternalRoutingTests.swift` | `ambitions://tab/today?context=focus` | External route compatibility proof. | External route | Red if removed | Keep and refine in CS05B. | CS05B | No | External routing tests. |
| `docs/canon/Ambitions_3_0_Repo_Hygiene_And_Active_Canon_Policy.md` | `activeFocus`, `TodayFocus*` policy | Source-truth guardrail preserving seams until proof. | Documentation/canon wording | Green | Preserve policy. | CS05A/CS10 | No | Docs consistency scan. |
| `docs/audits/cs01-compatibility-seam-registry-and-risk-map-report.md` | ActiveFocus/TodayFocus risk map | CS train source truth for risk. | Documentation/canon wording | Green | Preserve and refine through CS05A. | CS05A/CS10 | No | Registry/context consistency scan. |

## Bucket Summary

| Bucket | Current classification |
| --- | --- |
| User-facing copy that should align with Step/Start-now canon | Current active app surfaces should avoid restoring `Start Focus` or generic focus-mode posture; widget/support copy requires CS05B proof before any change. |
| Internal Swift type/file names that can remain temporarily | `TodayFocus*`, FocusNow widget types, shell command internal names, and `.focus` route context can remain intentionally. |
| Route/raw values that must remain stable or be migrated with alias | `.focus`, `context=focus`, `quick_focus`, `focusNow`, and external route target mappings. |
| Persistence/default values | No direct default-tab migration target found in CS05A discovery; external snapshot JSON is the live schema-like compatibility surface. |
| Accessibility identifiers | No direct `activeFocus` identifier inventory hit in CS05A; focus/widget/Today route identifiers must be frozen if touched. |
| Test fixtures/previews | External snapshot, payload, widget, App Intent, external routing, Today feature, and widget preview fixtures. |
| Documentation/canon wording | Active policy says preserve these seams until schema-versioned adapter or broad Today migration proof exists. |
| External shortcut/widget/deep-link assumptions | `ambitions://tab/today?context=focus`, App Intent route URLs, `quick_focus`, `focusNow`, FocusNow widget family. |
| Unsafe/unclear references requiring Yellow owner | Whether FocusNow widget names can ever be user-facing-renamed without compatibility alias; whether `TodayFocus*` can narrow-retire before PD03 Step Session depth. |

## Result

CS05A inventory is Green for mapping and accepted Yellow for retained seams. No symbol is safe to retire during CS05A.
