# Ambitions 2.0 Product Architecture

## Purpose

This document defines the product architecture for Ambitions 2.0. It governs surface responsibilities, drill-down rules, flow ownership, Insights demotion, Habits absorption, calendar permission behavior, and local-first calendar insight policy.

## Surface Responsibilities

### Today

- Owns immediate execution.
- Shows one dominant hero decision panel.
- Presents the best next action, fixed/flexible time pressure, recovery, and contextual insight.
- Routes to Goal Detail, Plan adjustments, Capture, and review prompts only when they help today's action.

### Goals

- Owns goal inventory, active direction, goal health, path progress, and Goal Detail entry.
- Shows goal status without becoming an analytics dashboard.
- Goal Detail owns deeper explanation, evidence, path inspection, and history.

### Capture

- Owns fast intake and triage.
- Accepts raw thought, task, goal seed, plan seed, waiting item, and archive item.
- Routes capture outputs to goal, plan, seed, waiting, or archive states.
- Does not become a long-term inbox that competes with Plan.

### Plan

- Owns day/week shaping, believability, rituals, absorbed habits, calendar-aware mode, scheduled blocks, and recovery/review prompts.
- Works without calendar permission.
- Requests calendar access only from an explicit Plan action.

### You

- Owns reviews, memory, trust, accessibility, sync/export, preferences, integrations, and account-style settings if needed.
- `You -> Reviews` becomes the main home for historical insight.
- `You -> Accessibility` may show user-facing Accessibility Nutrition only after verification.

## Top-Level vs Drill-Down Rules

- Top-level screens show one dominant hero panel and one or two supporting panels above the fold.
- Top-level screens do not expose audit trails, dense charts, full histories, long settings lists, or raw debug evidence in the first screenful.
- Drill-down screens can be denser when tied to one object or decision.
- Explanation depth appears in sheets, detail panels, review routes, or `Why This` / `Why Changed` surfaces.
- A top-level tab must represent a daily mental model, not a data category.

## What Never Appears On Top-Level Screens

- Full event ledgers.
- Raw calendar event lists.
- Source-audit tables.
- Dense habit trackers.
- Multi-week analytics dashboards.
- HealthKit, food/calorie sync, household/shared-life, or non-phone hardware controls.
- Model/debug terminology.
- Unverified accessibility claims.
- Calendar permission prompts without a user-initiated Plan action.

## Primary Flow: Goal -> Path -> Plan -> Today -> Action -> Recovery -> Review

1. User creates or refines a goal.
2. Path Intelligence proposes a believable path with assumptions and broad domain fit.
3. Plan turns the path into scheduled or unscheduled work based on capacity and calendar availability when allowed.
4. Today selects the next believable action from Canonical Now State.
5. The user acts, delays, splits, skips, or asks why.
6. Execution Resilience converts disruption into a recovery path.
7. Review captures what happened, what changed, and what the system should learn.

## Primary Flow: Capture -> Triage -> Goal / Plan / Seed / Waiting / Archive

1. User captures a thought quickly.
2. Capture classifies the item as raw, goal candidate, plan patch, seed, waiting, or archive.
3. User confirms or changes the route.
4. Goal-bound items attach to Goals or Goal Detail.
5. Plan-bound items become plan seeds, schedule candidates, or rituals.
6. Waiting/archive items remain retrievable through Capture and You memory surfaces.

## Primary Flow: Plan -> Calendar-Aware Mode -> Scheduled Block -> Recovery / Review

1. Plan shows believable planning without calendar access.
2. User taps `Make Plan calendar-aware` or `Find real open windows`.
3. Permission rationale explains local-first calendar use.
4. Calendar read enables open-window and conflict detection.
5. Calendar write creates user-confirmed blocks only.
6. Scheduled blocks feed Now State, Today, and review.
7. Missed or disrupted blocks enter recovery and later review.

## Reviews Architecture

Reviews live primarily under `You -> Reviews` with contextual entry from Today, Plan, and Goal Detail.

Reviews include:

- daily recovery/re-entry review
- weekly planning review
- goal review
- pattern reflection
- accessibility summary after verification
- memory and change summaries

Reviews are not generic analytics. Each review must answer what happened, what changed, what remains believable, and what action follows.

## Insights Demotion Architecture

Insights becomes a service and presentation pattern, not a tab.

Insight placement:

- Today: contextual insight panels tied to today's action.
- Goals: goal health, path explanation, and Goal Detail evidence.
- Plan: believability, calendar evidence, overload, open windows, and review prompts.
- You: reviews, memory, patterns, trust, and accessibility summaries.
- Sheets: `Why This` and `Why Changed`.

No feature should recreate a standalone Insights destination without a later canon decision.

## Habits Absorption Architecture

Habit-shaped work becomes:

- rituals in Plan
- repeatable actions in Today
- pattern evidence in Reviews
- goal-supporting routines in Goal Detail

Habits must not create a separate planning model. Repeat behavior consumes shared plan, memory, execution, and review systems.

## Plan Permission Flow

Plan is the only place to request calendar access.

Allowed triggers:

- `Make Plan calendar-aware`
- `Find real open windows`
- a comparable explicit Plan action that clearly names calendar value

Required behavior:

- explain what calendar data improves
- explain that Plan works without access
- request only after user action
- degrade cleanly if denied
- request write only when the user confirms creating calendar blocks

## Local-First Calendar-Derived Insight Policy

- Calendar-derived insight data remains local-first.
- Calendar data should be summarized for planning decisions, not copied into unrelated feature stores.
- Store only the minimum derived information required for believability, conflict, open-window, recovery, and review.
- User-facing copy must distinguish calendar-derived context from Ambitions-created plan data.
- Export/import must preserve user trust without implying cloud sync is required.
