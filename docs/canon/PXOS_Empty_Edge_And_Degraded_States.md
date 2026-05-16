# Empty Edge And Degraded States
<!-- markdownlint-disable MD013 -->

> Historical/supporting note: This PXOS file is retained for traceability and may still contain compatible degraded-state concepts.
> It is not active product, implementation, release, or Codex process authority.
> Current authority starts in `docs/truth/README.md`; active frontend/product authority must reconcile through `docs/truth/*`, `frontend/README.md`, and `docs/status/*`.
> Use this only after reconciling against `docs/status/old-canon-classification-index.md`.

Status: Supporting historical PXOS degraded-state reference; not current app implementation truth
Date: 2026-05-02

## Purpose

PXOS must define calm, believable behavior for first day, no goals, no schedule, no free time detected, no recommended step, calendar denied, reminders denied, stale source, offline mode, low battery, model unavailable, ambiguous capture, blocked goal, overwhelming day, late start, missed day, vacation/away, weekend trip, ignored app all day, finished early, changed mind, conflicting commitments, sensitive/private goal, rejected recommendation, disabled automation, denied personalization, too many commitments, no proof, stale proof, and long-gap return.

Do not hide uncertainty, invent certainty, or punish the user for missing a plan.

Every degraded state needs:

- state name;
- source label or missing-source explanation;
- calm user-facing copy;
- one available next action or an honest no-action state;
- owner surface or drill-down;
- recovery path when recovery is possible;
- privacy posture when sensitive information is involved;
- proof/receipt boundary when proof is absent, stale, or local-only.

## State Families

Empty states:

- first day;
- no captured items;
- no goals;
- no plan yet;
- no proof yet;
- no setup defaults.

Edge states:

- late start;
- finished early;
- changed mind;
- ignored app all day;
- vacation / away time;
- weekend trip;
- overwhelming day;
- too many commitments;
- conflicting commitments;
- sensitive/private goal.

Degraded states:

- calendar denied or unavailable;
- reminders denied or unavailable;
- schedule source stale;
- offline mode;
- model/runtime unavailable;
- personalization disabled;
- source needs review;
- no recommendation;
- ambiguous capture;
- blocked goal;
- stale proof;
- proof unavailable.

## Surface Ownership

Today owns degraded states that affect what to do now: no recommended step,
late start, overwhelming day, ignored app all day, closure needed, and no proof
for today's work.

Goals owns degraded states that affect direction: no goals, blocked goal,
stale assumptions, rejected recommendation, sensitive/private goal, and proof
or path needing review.

Capture owns intake ambiguity: ambiguous capture, private/sensitive input,
placement unavailable, grow-into-goal uncertainty, and import/skip ambiguity.

Plan owns time and capacity degradation: no schedule, calendar denied, stale
schedule, no free time detected, conflicting commitments, vacation/away, and
too many commitments.

You owns setup/trust degradation: personalization disabled, automation paused,
source/freshness review, privacy controls, import/export status, and setup
incompleteness.

## Fallback Copy Patterns

Use copy that names the state without blaming the user:

- `Nothing needs action here yet.`
- `This needs a place.`
- `Source needs review.`
- `No recommendation right now.`
- `This still works without calendar access.`
- `You can keep going offline.`
- `Make this lighter.`
- `Review later.`
- `Close the loop.`
- `Still Counts.`
- `No proof saved yet.`

Avoid failure framing, fake certainty, hidden platform assumptions, and
optimization language.

## Recommended Actions

Each degraded state should choose one of:

- create or capture the first useful object;
- review source;
- adjust plan;
- make the day lighter;
- choose a different step;
- close the loop;
- save or skip proof;
- keep working offline;
- set up later;
- no action needed.

If no safe action exists, say that directly and explain what still works.

## Source And Trust Labels

Use source/freshness labels from PX08/PX09/PX12:

- `Based on your plan`
- `Based on your schedule`
- `Based on recent choices`
- `Changed by you`
- `Current`
- `May Need Review`
- `Based on Older Context`
- `Source needs review`
- `Stored on this device`
- `No silent changes`

Do not describe missing, denied, unavailable, stale, or offline inputs as if
Ambitions knows more than it can prove.

## Non-Hidden Degradation

Model/runtime/platform unavailability must not be hidden behind generic
loading, magic, or confidence language. Future implementation may say what is
unavailable, what still works locally, and what the user can do next.

Calendar, reminder, import/export, widget, App Intent, sync, hosted model, or
external platform unavailability must not become an implementation claim. If a
future feature is unavailable, say so and route to the owned setup or fallback
surface.

## Accessibility And Cognitive Load

Degraded states must keep the primary action visible, preserve Dynamic Type,
avoid color-only severity, provide non-visual summaries for visual state, and
offer `Make this lighter` when a state is overloaded.

Do not put every edge-state explanation on a top-level tab. Move detail into
owned drill-downs, receipts/history, proof detail, setup flows, or trust review.

## Non-Claims

PX13 does not prove offline behavior, model runtime behavior, platform
permission behavior, import/export, notifications, widgets, App Intents,
calendar/reminder integration, physical-device behavior, public accessibility
conformance, or app implementation.

## Required Source Stack

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_3_0_Front_End_Redesign_Index.md`
- `docs/canon/Ambitions_3_0_Primitive_Architecture.md`
- `docs/canon/Ambitions_Beyond_3_0_Roadmap.md`
- `docs/canon/Ambitions_Beyond_3_0_Continuity_Rules.md`
- `docs/canon/Ambitions_Product_Experience_OS_Index.md`
- `docs/canon/AmbitionsOS_Index.md`
- `docs/codex/PXOS_TRAIN_CONTROL_SYSTEM.md`
- `docs/codex/PXOS_PRODUCT_DECISION_LEDGER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`

## Gates

- Product Decision Lock Gate: major choices must be locked by source truth or recorded as open/deferred.
- Surface Ownership Gate: every future UI change names Today, Goals, Capture, Plan, You, or a drill-down owner.
- Deep-Not-Wide Gate: deepen existing surfaces before creating new surface area.
- Accessibility / Cognitive Load Gate: future UI must specify Dynamic Type, VoiceOver, Reduce Motion, no color-only meaning, and cognitive-load expectations.
- Release Claim Gate: no release/platform/AI/personalization claim without evidence.
- ME Gate: no large UI expansion in known large-file zones without extraction review.
- CS Gate: no route/raw-value/external-surface/persistence breakage.

## Implementation Boundary

This is future canon and process guidance only. It does not implement app behavior, change production Swift, start PXOS, start AOS/ME/CS/REC02, retire compatibility seams, add dependencies, change workflows, add backend/sync/cloud/model runtime, or create release/platform readiness claims.
