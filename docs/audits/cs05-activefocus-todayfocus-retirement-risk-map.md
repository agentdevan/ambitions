# CS05 ActiveFocus/TodayFocus Retirement Risk Map

<!-- markdownlint-disable MD013 -->

Status: CS05A retirement risk map for global order `044`.
Date: 2026-05-03

## Summary

No CS05 seam is safe to retire during CS05A. The seam is split across external schema, route/raw values, widget family identity, App Intent URLs, shell commands, and broad Today state/service ownership.

## Risk Map

| Seam | Risk | Why | Safe action now | Retirement blocker | Owner |
| --- | --- | --- | --- | --- | --- |
| `activeFocus` external snapshot key | Red | Old JSON and external snapshot contracts depend on the key. | Preserve and test. | Schema-versioned adapter and old-payload proof missing. | CS05B/CS05C |
| `ExternalSurfaceNowState.activeFocus` | Red | Codable contract is external-facing and persistence-like. | Preserve. | Encode/decode compatibility proof missing. | CS05B/CS05C |
| `CanonicalNowState.activeFocus` | Red | Runtime field feeds external projections and tests. | Preserve. | Replacement model and projection tests missing. | CS05B/CS05C |
| `TodayFocusState` / `TodayFocus*` | Red | Broad Today feature state/service seam. | Preserve. | Step Session migration is broad and not owned by CS05A. | CS05C/future PD03 |
| `.focus` Today entry context | Red | Shell, external routing, App Intent, and return behavior use it. | Preserve. | Route adapter and route smoke proof missing. | CS05B/CS05C |
| `quick_focus` command raw value | Red | Raw command compatibility surface. | Preserve raw value. | Command route/receipt proof and alias plan missing. | CS05B/CS05C |
| `FocusNowWidget` / `focusNow` | Red | Widget identity and AppUI preview compatibility. | Preserve. | Widget migration, preview proof, and rendered proof missing. | CS05B/CS05C |
| External fallback copy containing `Focus` | Yellow | Product-language debt, but copy may be rendered in external surfaces. | Inventory; do not sweep in CS05A. | Rendered/widget/snapshot proof and copy owner missing. | CS05B/future SI |
| Exact focus-related accessibility identifiers | Yellow | No direct safe-to-rename id found; touched identifiers would be automation surfaces. | Freeze. | Touched-id inventory and alias tests missing. | CS05B/CS05C |

## Safe To Retire Later

Nothing is currently classified safe to retire. CS05C may only proceed if CS05B proves a specific seam has:

- an adapter or alias;
- focused tests covering old and current values;
- no route/raw/default/accessibility/widget/schema break;
- no user-facing product-language regression;
- clear rollback path;
- reviewable diff size.

## Must Preserve

- `activeFocus` JSON key and Codable contract.
- `.focus` Today route context.
- `quick_focus` raw command value.
- `focusNow` widget family and `FocusNowWidget` identity.
- `TodayFocus*` state/service names until a broad Today Step Session migration is proven safe.
- Old external route payloads and App Intent URLs.

## Unknown / Defer

- Whether FocusNow widget user-facing copy should be migrated before SI visual/preview gates.
- Whether `TodayFocusState` should eventually become Step Session state in CS05C or PD03.
- Whether external snapshot schema should add a new key before deprecating `activeFocus`.

## Rollback

CS05A rolls back by reverting docs/control changes. CS05B and CS05C must preserve old tests and adapters so rollback never requires deleting compatibility proof.

## Result

PASS WITH YELLOW for CS05A risk mapping. Yellow is accepted because retained legacy names protect compatibility and are explicitly owned by CS05B/CS05C/future PD03 rather than silently claimed retired.
