# CS05 ActiveFocus/TodayFocus Accessibility, Route, And Payload Ledger

<!-- markdownlint-disable MD013 -->

Status: CS05A accessibility/route/payload ledger for global order `044`.
Date: 2026-05-03

## Freeze Policy

Accessibility identifiers, deep-link values, action payload values, widget family identifiers, App Intent route URLs, and external snapshot keys are compatibility surfaces. CS05A changes none of them. CS05B may add tests proving they remain stable. CS05C may only retire a value after CS05A and CS05B prove an adapter, alias, fallback, and rollback path.

## Route And Raw Values

| Surface | Legacy value | Current role | Safe CS05A action | Unsafe action | Proof owner |
| --- | --- | --- | --- | --- | --- |
| Today route context | `.focus` | Opens current Today focus/step posture. | Preserve and document. | Delete, rename, or remap without route tests. | CS05B |
| External route | `ambitions://tab/today?context=focus` | Legacy deep link and App Intent route target. | Preserve and document. | Remove or change fallback without tests. | CS05B |
| Shell command raw value | `quick_focus` | Quick command identifier. | Preserve raw value. | Rename raw command. | CS05B/CS05C |
| App Intent route | route URL containing `context=focus` | Shortcut/App Intent compatibility. | Preserve. | Replace without App Intent test proof. | CS05B |
| Widget family | `focusNow` | Widget family identity. | Preserve. | Rename/delete family without alias. | CS05B/CS05C |

## External Snapshot And Payload Values

| Surface | Legacy field/value | Current role | Safe CS05A action | Unsafe action | Proof owner |
| --- | --- | --- | --- | --- | --- |
| External snapshot now state | `activeFocus` | Codable external field. | Preserve old key. | Rename/delete key. | CS05B/CS05C |
| Canonical now state | `activeFocus` | Runtime projection field feeding external surfaces. | Preserve. | Rename without adapter. | CS05B/CS05C |
| Action payload fallback | `activeFocus ?? bestNextStep` | Chooses primary external action reference. | Preserve. | Change without focused tests. | CS05B |
| External ambient variant | `.focus` | External surface variant state. | Preserve. | Delete without widget/snapshot proof. | CS05B/CS05C |
| Live Activity fallback copy | `Focus step ready` | Fallback external surface copy. | Inventory only. | Copy sweep without rendered/projection proof. | CS05B/future SI |

## Accessibility Identifier Inventory

CS05A discovery did not find a direct `activeFocus` accessibility identifier that is safe to rename. Focus-related automation risk is route/payload/widget driven rather than a single known identifier. If CS05B touches any Today, AppUI, widget, or shell view code, it must run an identifier scan and either preserve every touched identifier or document an alias/deprecation strategy with tests.

| Identifier family | Current classification | CS05A action | CS05B/CS05C requirement |
| --- | --- | --- | --- |
| Today route/shell identifiers containing `focus` | Unknown / route-adjacent | Freeze. | Inventory exact touched ids before code edits. |
| Widget identifiers or labels for FocusNow | Widget compatibility surface | Freeze. | Add proof before rename or copy change. |
| Shell command labels | Automation/user-facing risk | Freeze raw values; copy proof later. | Preserve raw command and test visible behavior. |
| External snapshot keys | Schema compatibility surface | Freeze. | Legacy JSON decode/encode proof before migration. |

## Default And Persistence Behavior

CS05A did not identify a direct default-tab migration target analogous to Profile/Insights/Habits. The persistence-like risk is external snapshot JSON, widget payloads, App Intent URLs, and command payloads. Any future persistence/default behavior touching Today focus context must prove:

- old `context=focus` routes still resolve;
- missing `activeFocus` payloads still decode;
- present `activeFocus` payloads still decode;
- unknown contexts fall back safely;
- no new top-level destination appears.

## Result

Green for CS05A ledger creation. Accepted Yellow remains for unresolved exact identifier aliasing because CS05A touches no identifiers and CS05B owns focused proof before any identifier/code change.
