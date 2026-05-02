# PXOS Cross Surface Continuity System
<!-- markdownlint-disable MD013 -->

Status: PXOS future canon; not current app implementation truth
Date: 2026-05-02

## Purpose

PXOS makes Ambitions feel like one life execution system instead of five separate tabs. The continuity system defines how work can move through the canonical loop:

```text
Capture -> Place -> Plan -> Do Today -> Close / Recover -> Save Proof
```

Continuity is future user-facing canon only. It does not implement app behavior, alter routes, add persistence, change external projections, start Product Depth, or claim PXOS implementation.

## Continuity Law

Cross-surface continuity must be visible, source-bound, reversible where possible, and owned by one destination at a time.

- Visible: Ambitions may suggest a handoff, but meaningful placement, reflow, closure, proof, or preference changes must show what will happen before confirmation.
- Source-bound: every carried-forward item needs source, freshness, and privacy posture when surfaced outside its origin.
- Reversible where possible: user correction, undo, move, archive, or review paths must exist before future implementation claims.
- Owned: a handoff has one source surface, one destination owner, and one failure/recovery state. No hidden hub tab, background queue, or generic dashboard owns continuity.
- Deep-not-wide: continuity deepens Today, Goals, Capture, Plan, and You through owned drill-downs. It must not create new top-level destinations.

## Core Loop Handoffs

| Loop step | Source surface | Destination owner | User-visible handoff | Failure / recovery state | Gate before implementation |
| --- | --- | --- | --- | --- | --- |
| Capture -> Place | Capture | Capture placement review, then Goals / Plan / Today / You as chosen | Placement preview names the destination, consequence, source, and whether the item becomes a step, goal seed, plan item, review item, or discard/archive item. | `Needs a place`, `Review later`, `Not enough context`, or `Keep private`. | Privacy, source-label, and CS route/raw-value gates. |
| Place -> Plan | Goals / Capture | Plan | Plan can receive selected goals, steps, timing needs, constraints, or availability questions as suggestions. | `Does this hold together?`, capacity conflict, missing schedule context, or user rejects the suggested placement. | Plan ownership, no-silent-calendar-write, and compatibility gates. |
| Plan -> Do Today | Plan / Goals | Today | Today may show a Start here recommendation with capacity, source, and freshness labels. | Plan unavailable, over-capacity, away-time, stale context, or user chooses a lighter day. | PX09 copy, PX12 accessibility, PX13 degraded state, and AOS boundary checks. |
| Do Today -> Close / Recover | Today | Today action closure / Plan recovery / Goals proof as appropriate | Closure asks what changed, what counted, and whether to move, still count, adjust, or save proof. | Interrupted, partial, postponed, still counts, or needs smaller next step. | PX07 recovery and PX08 proof/receipt gates. |
| Close / Recover -> Save Proof | Today / Plan / Goals | Goals and You trust/proof surfaces | Receipt/proof preview shows what happened, what changed, why it counted, source, privacy, and correction path. | Sensitive proof redacted, proof declined, correction requested, rollback needed, or source stale. | Trust/proof, privacy/redaction, persistence, and CS gates. |

## Surface Relationship Rules

### Capture

Capture owns raw intent until the user places it or explicitly discards/archives it. Future continuity may suggest destinations, but it must not silently create a Goal, Step, calendar-like commitment, receipt, or memory entry.

Capture handoffs must show:

- source text or privacy-safe summary;
- proposed destination;
- consequence after confirmation;
- whether the item remains private;
- correction path if the placement is wrong.

### Goals

Goals owns ambition structure, path, vitality, proof history, and strategic decision context. Goals may send candidate next steps to Today and capacity questions to Plan. Goals must not become a task database or dashboard of disconnected cards.

Goals handoffs must show:

- which Goal or Path produced the suggestion;
- why the handoff matters now in source-and-context language;
- whether proof will attach to the Goal after closure;
- how to inspect or revise the path inside Goal Detail.

### Plan

Plan owns capacity, pressure, timing, life shape, and reflow decisions. Plan may inform Today recommendations and may receive placement or reflow requests from Capture, Goals, and closure outcomes.

Plan handoffs must show:

- source of the time/capacity signal;
- what changes if the user accepts the reflow;
- which schedule or availability context is missing or stale;
- confirmation before any calendar-adjacent, timing, or availability assumption is treated as active.

Calendar permission remains Plan-owned. Onboarding, Capture, Today, and Goals must not request OS calendar permission.

### Today

Today owns the daily execution orientation object and the immediate Start here decision. Today may receive planned work, goal-derived steps, recovery prompts, or placement follow-ups, but it should show one primary daily object rather than a stacked list of cross-surface cards.

Today handoffs must show:

- why this appeared today;
- source and freshness labels;
- whether the item is private or redacted;
- visible alternatives such as move, lighten, close, review later, or inspect source.

### You

You owns user control, trust, setup, memory review, preferences, and receipt/proof inspection. It does not become a feed of every cross-surface event. It is where the user can review what Ambitions knows, correct stale assumptions, pause or delete sensitive memory, and inspect trust history.

You handoffs must show:

- source and freshness status;
- whether Ambitions is using the information now;
- correction, pause, delete, or export/review options when future implementation supports them;
- clear boundaries between current app behavior and future canon.

## Source And Freshness Continuity

Every future cross-surface projection needs a compact provenance envelope before it can be implemented:

- origin surface;
- origin object type;
- last user confirmation or correction;
- freshness label;
- privacy posture;
- destination owner;
- rollback or correction path;
- degraded-state copy when source truth is missing.

Freshness labels follow the trust canon: `Current`, `May Need Review`, and `Based on Older Context`. These labels are user-facing trust cues, not model confidence or hidden scoring.

## Privacy And Redaction Continuity

Cross-surface continuity must default to privacy-safe projection. Sensitive captured text, proof, receipt detail, calendar-like context, memory, or personal preference may appear on another surface only when the destination has a clear user value and the projection is redacted or explicitly user-approved.

Top-level surfaces should prefer summaries such as private item, source hidden, or review in You when detail would expose sensitive context. Full detail belongs in owned drill-downs with correction controls.

## Rollback And Correction Paths

Future implementation cannot claim continuity Green unless each meaningful handoff has one of these paths:

- undo the most recent confirmed change;
- move the item back to Capture or review;
- edit the destination assignment;
- correct the source assumption in You or the owning surface;
- archive or discard without shaming copy;
- mark Still Counts when reality changed but progress is valid;
- show why rollback is unavailable and what the user can do instead.

## Compatibility Gates

Cross-surface continuity must pass CS gates before touching:

- route identifiers;
- raw values;
- App Intent destinations;
- widgets;
- Live Activities;
- notification payloads;
- deep links;
- import/export formats;
- SwiftData schema or migration behavior;
- compatibility labels such as Profile-to-You, Insights contextualization, or Habits/Ritual history.

No docs-only PXOS batch may retire or rename these seams.

## Review Checklist For Future UI Batches

Future UI or implementation batches that claim cross-surface continuity must answer:

- What is the source surface?
- What is the destination owner?
- What does the user see before a meaningful change happens?
- What source/freshness/privacy labels travel with the item?
- What happens when source truth is stale, private, missing, or contradicted?
- What is the rollback or correction path?
- Which ME/CS/AOS gates apply?
- Does the top-level surface remain visual orientation instead of a stacked-card container?
- Does the copy avoid fake certainty, AI theater, shame language, and generic productivity framing?

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

## PX15 Evidence Status

PX15 may claim this future-canon continuity system is documented after its batch evidence is committed. It may not claim that cross-surface continuity is implemented, shipped, user-tested, App Store ready, TestFlight ready, platform proven, physical-device proven, or publicly accessibility proven.
