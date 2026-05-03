# CS05 ActiveFocus TodayFocus Dry-Run Red Report

<!-- markdownlint-disable MD013 -->

Status: STOPPED ON RED.
Date: 2026-05-02

## Batch

- Formal batch ID: `CS05`
- Global order number: `044`
- Active prompt:
  `docs/codex/batches/CS05_ActiveFocus_TodayFocus_Retirement_Prompt.md`
- Dry-run result: Execution allowed: NO.

## Why Execution Is Blocked

CS05 is currently framed as a compatibility retirement batch for
`activeFocus`, `TodayFocus*`, and `.focus` Today compatibility. Source-truth
discovery shows this is not a narrow retirement seam yet. The seam currently
touches:

- external snapshot schema fields such as `activeFocus`;
- widget and external-surface projections;
- App Intent, shortcut, notification, and payload assumptions documented by
  CS01 and CS07;
- Today feature service/model state such as `TodayFocusState`;
- domain and runtime models such as `CanonicalNowState`;
- focused tests for external snapshots, widgets, notifications, Today state,
  and runtime projection;
- historical FAANG handoff and repo-hygiene ledgers that explicitly preserve
  `activeFocus` and `TodayFocus*` until a schema-versioned adapter or broad
  Today migration exists.

The current CS05 prompt requires replacement maps, route/deep-link review,
schema/persistence review, widget/App Intent/Shortcut review, import/export
review, focused tests, rollback, and release-claim review before deletion.
Those ledgers and proof matrices do not exist yet for CS05.

## Red Classification

| Red | Evidence | Required repair |
| --- | --- | --- |
| External schema uncertainty | `activeFocus` appears in external snapshot contracts/builders, widget projections, payload tests, and compatibility reports. | Split CS05 into map/proof/retirement stages before implementation. |
| Today model/service owner ambiguity | `TodayFocus*` appears across Today feature models, service projection, tests, and historical migration ledgers. | Create a TodayFocus compatibility inventory and owner map before any rename. |
| Route/payload proof missing | CS05 depends on CS07 proof, but no CS05-specific activeFocus/TodayFocus compatibility matrix exists. | Add focused proof for legacy payloads and current Step/Today semantics first. |
| Deletion-before-proof risk | The prompt's compatibility action is `retires`; current evidence is not strong enough to retire anything. | Preserve old fields, names, and compatibility paths until focused proof and rollback exist. |

## Non-Claims

This report does not claim CS05 is complete, does not retire `activeFocus`,
`TodayFocus*`, `.focus`, external snapshot schema, widgets, App Intents,
shortcuts, notifications, Today state, routes, payloads, accessibility
identifiers, imports/exports, or persistence behavior, and does not claim
release, TestFlight, App Store, physical-device, public accessibility, PXOS,
Signature Interface, Product Depth, or AmbitionsOS implementation proof.

## Recommended Repair Prompt

Next prompt path:
`docs/codex/batches/CS05_ActiveFocus_TodayFocus_Retirement_Prompt.md`

Recommended next action:
Repair CS05 by splitting it into internal stages:

- CS05A: ActiveFocus/TodayFocus compatibility map, schema ledger, and
  retirement risk map only.
- CS05B: focused external snapshot/widget/App Intent/Today state compatibility
  proof only.
- CS05C: narrow retirement only if CS05A and CS05B prove a seam is safe.

The formal Ambitions 4.0 batch count remains `113`; CS05A/CS05B/CS05C should
be internal repair stages only, mirroring CS02, CS03, and CS04.
