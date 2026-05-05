# Ambitions Live Activities / ActivityKit Strategy
<!-- markdownlint-disable MD013 -->

Status: Active PFC15 platform strategy; not implementation approval
Date: 2026-05-05

## Purpose

This strategy defines when Ambitions may use Live Activities and ActivityKit,
what may appear on the Lock Screen / Dynamic Island, what must stay private,
and what proof is required before any readiness claim.

It does not implement or approve new Live Activity behavior.

## Current Repo Reality

Current source includes:

- `Native/Ambitions/ExternalSnapshots/NextStepActivityAttributes.swift`
- `Native/Ambitions/Notifications/NextStepLiveActivityService.swift`
- `Native/AmbitionsWidgetExtension/NextStepLiveActivityWidget.swift`
- existing external-surface snapshot, route, widget, and privacy tests/reports

Current evidence proves source/test privacy posture only. It does not prove
Lock Screen rendering, Dynamic Island lifecycle, physical-device behavior,
signed-archive behavior, App Store review posture, public accessibility
conformance, or release readiness.

## Allowed Launch Candidate

The only allowed launch candidate is:

`Active Step Focus Window`

Meaning:

- one bounded next step that the user is actively executing;
- privacy-safe title/detail derived from the external snapshot projection;
- freshness, local-state, and private-detail labels;
- deep link back into Ambitions for detail and closure;
- no broad day overview, goal list, review surface, analytics, ads, promotion,
  or motivational pressure.

This candidate maps to the current `NextStepActivityAttributes` and
`NextStepLiveActivityWidget` shape, but PFC15 does not claim that the runtime
start/update/end lifecycle is release-ready.

## Deferred Candidates

These remain deferred until a named implementation/proof batch approves them:

| Candidate | Status | Required owner before implementation |
| --- | --- | --- |
| Step Session timer | Deferred; timer must remain secondary | Step Session / Today owner plus PFC16 |
| Protected block | Deferred | Plan / Availability owner plus PFC16 |
| Recovery window | Deferred | Today / Plan recovery owner plus PFC16 |
| Commute or travel block | Deferred / not launch default | Plan owner plus privacy/legal review |
| Weekly Life Sweep | Not allowed as Live Activity by default | Future proof only |

## Explicitly Not Allowed

Live Activities must not show:

- full goal lists;
- full day agendas;
- private Found Life details;
- raw calendar event titles;
- memory or receipt history;
- review summaries;
- motivational pressure;
- promotional copy;
- ads;
- social proof;
- background intelligence claims;
- sensitive content by default.

## Start Rules

A Live Activity may start only when all are true:

- the user begins or confirms an active bounded execution window;
- the snapshot has a concrete goal/step reference;
- the surface can be rendered with privacy-safe labels;
- the app can end or update the activity when the session is no longer current;
- ActivityKit authorization is available;
- no sensitive detail is required to understand the Lock Screen state.

No silent background start is allowed for future broad recommendations,
planning changes, memory signals, or unconfirmed suggested work.

## Update Rules

Updates must be lightweight and local:

- update only from the current privacy-safe external snapshot;
- carry freshness / local-state labels;
- avoid high-frequency refresh loops;
- avoid network/account/sync assumptions;
- keep Dynamic Island text short and privacy-safe;
- deep link back into Ambitions for details.

## End / Stale Rules

The Live Activity must end or degrade when:

- no concrete active step exists;
- the active window ends;
- the user closes or recovers from the step;
- the snapshot becomes unavailable;
- the state becomes stale and the user needs to open Ambitions to confirm.

Current code uses a 45-minute stale date and a one-hour `endsAt` label for the
existing next-step shape. PFC16 may keep or adjust that only with focused tests,
privacy proof, and rendering proof.

## Privacy Boundary

Lock Screen / Dynamic Island content must default to privacy-safe summaries.

Required:

- hide sensitive/private detail by default;
- never show raw goal IDs or step IDs as visible text;
- never show raw calendar titles;
- never show memory/private receipt content;
- include a privacy label when detail is hidden;
- route to the app for full context;
- use local-only wording unless sync is explicitly implemented and proved.

## Accessibility / Reduced Motion Boundary

Future proof must include:

- Dynamic Type and truncation review;
- VoiceOver label/value/hint review;
- non-color meaning for urgency/freshness;
- Reduce Motion-safe behavior;
- Lock Screen and Dynamic Island readability proof where tooling permits;
- human/device proof stop when Codex cannot verify platform presentation.

## Performance / Battery Boundary

Future implementation must prove:

- no high-frequency update loop;
- bounded update cadence;
- no heavy computation in widget/Live Activity rendering;
- privacy-safe snapshot precomputation;
- Live Activity update budget;
- battery/thermal proof or explicit human/device proof stop.

## Required PFC16 Proof Before Implementation Claim

PFC16 or any later implementation batch must produce:

- ActivityKit lifecycle tests where feasible;
- source tests for start/update/end/stale/unavailable behavior;
- privacy/redaction tests for visible strings and accessibility labels;
- deep-link proof;
- rendered Lock Screen / Dynamic Island screenshots or operator checklist;
- Dynamic Type / Reduce Motion / VoiceOver proof or operator checklist;
- no-claim boundary for App Store, TestFlight, release, physical-device,
  legal/privacy, and public accessibility claims.

## Launch Decision

PFC15 strategy decision:

- Allowed as future launch candidate: Active Step Focus Window.
- Deferred: Step Session timer, protected block, recovery window, commute/travel
  block.
- Not authorized: broad day/goal/review/activity surfaces or any sensitive
  Lock Screen content.

If the Active Step Focus Window cannot meet privacy, accessibility, rendering,
and device proof gates later, the safe launch decision is `no Live Activity`.
