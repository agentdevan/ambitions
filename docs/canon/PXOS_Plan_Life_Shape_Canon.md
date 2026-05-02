# Plan Life Shape Canon
<!-- markdownlint-disable MD013 -->

Status: PXOS future canon; PX05 complete; not current app implementation truth
Date: 2026-05-02

## Purpose

Plan is the time, capacity, and Life Shape surface. It should feel like the shape of the user's life and a believable planning system, not a calendar clone, dense planner, task dump, or scheduling spreadsheet.

Plan owns Day / Week / Month scope chip, contextual default view, active-day Day view, planning/review Week view, Month/Life Shape for long-range planning, scheduled items, free time, protected time, work, school, vacation/away, commute/buffers, pressure, capacity, evidence labels, planning setup prompts, schedule/availability links, planning defaults links, Life Shape month view, pressure weeks, milestones, protected blocks, reflow suggestions, commitment load, recovery space, availability confidence, and missing schedule state.

Vacation/away is not free time unless explicitly marked available. Month is not a generic grid; it emphasizes life areas, pressure weeks, protected time, milestones, capacity, recovery space, and commitments.

## PX05 Top-Level Orientation Surface

Plan answers one question first:

```text
Does this hold together?
```

The first viewport should orient around one dominant object: Life Shape. Life
Shape is the visible form of capacity, commitments, pressure, recovery room,
protected time, and meaningful goals across the user's day, week, and longer
horizon. It is not a calendar clone, task scheduler, due-date grid, analytics
dashboard, or automatic optimization surface.

The top-level Plan composition is:

1. Life Shape / active shape object: day, week, or month depending on context.
2. Capacity and pressure state with source/freshness labels.
3. One consequence or decision prompt only when the plan needs user attention.
4. One primary action: review, adjust, protect, or confirm.
5. Secondary detail behind Plan detail views, Life Shape drill-downs, reflow
   review, recovery review, or planning defaults.

Plan should show whether the shape is believable before it shows every event.
Detailed schedules, diagnostics, receipts, conflict lists, and full source
explanations belong behind owned detail flows.

## Primary Object And Action

Primary object: the current Life Shape or planning shape that needs attention.

Primary action: a confirmation-oriented planning action. Preferred action labels
include `Review shape`, `Adjust plan`, `Protect time`, `Review pressure`,
`Make room`, `Confirm change`, or `Set defaults`.

Plan should show one primary action at a time:

- `Review shape` opens the relevant Plan detail view.
- `Adjust plan` opens reflow review, not silent rescheduling.
- `Protect time` opens protected-time review.
- `Review pressure` opens pressure, conflict, or commitment-load detail.
- `Make room` opens recovery or capacity review.
- `Confirm change` applies only after visible consequence copy.
- `Set defaults` opens You-owned planning behavior only when setup is needed.

## Plan States

| State | Meaning | Top-level Plan behavior |
| --- | --- | --- |
| Day Shape | near-term capacity and pressure | show what can honestly fit today |
| Week Shape | commitment and recovery pattern | show pressure, buffers, and risks |
| Life Shape | long-range capacity and goals | show seasons, milestones, and protected blocks |
| No calendar | Ambitions has no calendar source | use manual defaults and explain limits |
| Calendar denied | permission is unavailable | suggest Plan-owned setup, do not shame |
| Overloaded | the plan does not hold together | show consequence and recovery path |
| Conflicting | commitments collide | show conflict owner and review action |
| Changed plan | a change needs confirmation or receipt | show what changed before applying |
| Away/protected | time is not automatically available | avoid treating away time as free |

## Detail Ownership

Plan top level owns orientation. Detail belongs behind owned flows:

- Plan detail views own full schedule, source detail, conflict diagnostics, and
  receipt review.
- Life Shape drill-downs own longer-range patterns, pressure weeks, milestones,
  protected blocks, and capacity envelopes.
- Reflow review owns proposed changes, alternatives, and consequences.
- Recovery review owns disrupted days/weeks and humane repair paths.
- You owns planning defaults, schedule availability, calendar permission setup,
  and guided automation preferences.

## Calendar And Automation Boundaries

Plan owns calendar permission. Capture and onboarding must not request calendar
access. Plan may explain why calendar context would improve planning, but it
must preserve manual/no-calendar modes and avoid making platform integration
claims without proof.

No future Plan experience may silently reschedule, write to the calendar, mark
away/vacation as free time, or hide tradeoffs. Suggestions remain suggestions
until the user confirms a visible consequence.

## Recovery And Consequence Copy

Plan language should be calm and consequence-oriented:

- what changed;
- why the shape no longer holds;
- what can move;
- what should stay protected;
- what requires confirmation;
- what remains uncertain.

Plan must avoid shame language, fake certainty, automatic optimization claims,
and productivity-score framing.

## Visual Orientation Examples

Good Plan:

- one Life Shape object dominates the first viewport;
- capacity, pressure, and protected time are visually legible;
- one decision or consequence is clear;
- schedule detail is available behind a tap;
- calendar permission/setup lives in Plan or You-owned flows;
- recovery paths are visible without blame.

Bad Plan:

- a generic calendar grid as the primary model;
- dense list of every event and task;
- dashboard of pressure cards and metrics;
- silent rescheduling suggestions;
- treating vacation or away blocks as free capacity;
- onboarding calendar permission prompts.

## Accessibility And Cognitive Load

Plan must support Dynamic Type, VoiceOver summaries for Life Shape, capacity,
pressure, protected time, and primary action, Reduce Motion alternatives for
shape/reflow motion, no color-only pressure or conflict meaning, visible
alternatives for gestures, and a first viewport that asks for only one planning
decision at a time.

The 3-second glance test passes only when the user can identify whether the
plan holds together, what pressure matters, and the next safe planning action
without reading a full schedule.

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
