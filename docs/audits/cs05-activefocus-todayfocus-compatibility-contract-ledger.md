# CS05 ActiveFocus/TodayFocus Compatibility Contract Ledger

<!-- markdownlint-disable MD013 -->

Status: CS05A compatibility contract ledger for global order `044`.
Date: 2026-05-03

## Contract Rule

Today user-facing product direction is Step/Start-now oriented, but `activeFocus`, `TodayFocus*`, `.focus`, `quick_focus`, and FocusNow remain compatibility surfaces. Old snapshot fields, raw route contexts, widget families, App Intent routes, and Today state contracts must remain stable until CS05B focused proof and a CS05C retirement decision prove a narrower seam is safe.

## Ledger

| Symbol/string | File path | Current role | User-facing or internal | Route/raw-value status | Persistence/defaults status | Accessibility identifier status | Test dependency status | External/deep-link/shortcut/widget status | Today step semantic status | Safe action now | Unsafe action | Required proof before retirement | Owner |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `activeFocus` | `Native/Ambitions/Domain/CanonicalNowStateModels.swift` | Runtime now-state compatibility field | Internal/schema-adjacent | Not a route raw value | External snapshot persistence-like payload risk | Not an id | Domain and snapshot tests construct it | Feeds external projection | Can coexist with step-first semantics | Preserve | Rename/delete | Domain, snapshot, widget, action payload tests and schema adapter | CS05B/CS05C |
| `ExternalSurfaceNowState.activeFocus` | `Native/Ambitions/ExternalSnapshots/ExternalSurfaceSnapshotContracts.swift` | Codable external snapshot field | External schema | Not a route raw value | Old JSON decode compatibility | Not an id | Legacy JSON tests | External payload field | Not user-facing copy | Preserve old key | Rename/delete key | Legacy decode, encode shape, schema versioning, rollback | CS05B/CS05C |
| `activeFocus ?? bestNextStep` | `ExternalSurfaceSnapshotBuilder.swift`, `ExternalSurfaceActionPayloads.swift` | Primary reference fallback | Internal projection | Not raw | Payload behavior risk | Not an id | Payload/projection tests | Widget/action payload behavior | Supports current step recommendation | Preserve | Change fallback order without proof | Payload and widget tests with active and nil focus | CS05B |
| `TodayFocusState` and nested states | `TodayFeatureModels.swift` | Today execution/blocked/clarification state | Internal state | Not raw itself | None directly | State can drive UI labels/ids | Today tests depend on it | None directly | Broad bounded step posture | Preserve | Broad rename/delete | Today state/service/UI tests and file-size review | CS05C/future PD03 |
| `makeFocus(...)` | `TodayFeatureService.swift` | Builds Today focus/step state | Internal service | Not raw itself | None directly | Can drive UI state | TodayFeatureService tests depend on it | None directly | Broad Today projection | Preserve | Broad rename/delete | Today service tests and visual/product proof | CS05C/future PD03 |
| `.focus` / `TodayEntryContext.focus` | `AppNavigation.swift`, `AppExternalRouting.swift`, shell/router files | Today route context | Internal/raw route | Stable legacy route context | None directly | Route may affect automation landing | Shell/external tests | Deep links and App Intent URLs | Opens current step posture | Preserve | Remove/change raw routing | Shell, external routing, App Intent tests | CS05B/CS05C |
| `ambitions://tab/today?context=focus` | `AppExternalRouting.swift`, tests | External route | External route | Stable legacy deep link | None directly | No direct id | External routing tests | Deep link compatibility | Today step posture route | Preserve | Remove without adapter | External route proof and fallback matrix | CS05B |
| `quick_focus` | `ShellCommandModels.swift` | Raw command identifier | Raw/action compatibility | Stable raw value | None directly | Command UI may expose labels | Shell command tests | Command payload/action surface | Routes to Today step posture | Preserve raw; review visible title separately | Rename raw value | Shell command route/receipt proof | CS05B/CS05C |
| `FocusNowWidget` / `focusNow` | `AppUI/Sources/Widget*` | Widget family/view identity | Widget/AppUI | Widget family raw value | Widget snapshot compatibility risk | Widget UI labels may be automation-facing | Widget tests/previews | Widget compatibility | External Today support object | Preserve | Delete or rename without alias | Widget projection tests and rendered widget proof before claim | CS05B/CS05C |
| `Focus step ready`, `Open Focus`, `Focus when ready` | `ExternalSurfaceSnapshotBuilder.swift`, `NextStepActivityAttributes.swift` | External surface fallback copy | User-facing external surface copy | Not raw | External snapshot/rendered surface risk | May be spoken/rendered | Snapshot tests may assert indirectly | Widget/live activity surface | Legacy copy debt | Inventory; do not change in CS05A | Copy sweep without rendered proof | CS05B copy scan, widget/snapshot proof, release-claim review | CS05B/future SI |

## Route, Schema, And External Routing Matrix

| Input / legacy assumption | Current expected resolution | Required proof owner |
| --- | --- | --- |
| old snapshot field `activeFocus` | Decodes and projects without data loss. | CS05B |
| old snapshot with no `activeFocus` | Decodes using optional field and safe fallback. | CS05B |
| `ExternalSurfaceActionPayload` with now state | Uses compatible primary reference fallback. | CS05B |
| `ambitions://tab/today?context=focus` | Opens Today with focus/step posture. | CS05B |
| `OpenAmbitionsDestinationIntent` quick focus/start next/mark done | Produces compatible Today route. | CS05B |
| shell `quick_focus` command | Selects Today focus/step posture and stable receipt behavior. | CS05B |
| `WidgetFamily.focusNow` | Projects compatible FocusNow widget state. | CS05B |
| duplicate Focus/Step Session destination | Must not exist as separate top-level destinations. | CS05B/CS10 |
| user-facing active app copy | Must remain Step/Start-now oriented where current active app surfaces own copy. | CS05B/CS10 |

## Rollback

CS05A is docs/control only and can be reverted without app migration. CS05B proof changes must preserve current `activeFocus`, `.focus`, `quick_focus`, and `focusNow` compatibility assertions. CS05C rename attempts must leave schema, route, widget, and command aliases until all consumers are proven migrated.

## Result

Green for CS05A ledger creation with accepted Yellow: no current `activeFocus`, `TodayFocus*`, `.focus`, or FocusNow seam is safe to retire yet. CS05B owns focused proof; CS05C remains blocked.
