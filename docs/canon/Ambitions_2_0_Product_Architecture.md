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

## Primary Operating Loop

Ambitions 2.0 is organized around one daily life operating loop:

1. Life enters through Capture.
2. Life objects connect through Life Graph.
3. Ambitions selects one believable next move.
4. Reality changes.
5. Ambitions reflows the plan safely.
6. Every action closes with a receipt.
7. The user can correct assumptions, memory, recommendations, and actions.
8. Memory learns only from evidence and user-confirmed signals.
9. Reviews convert experience into future behavior.
10. Sync, export/import, widgets, Live Activities, App Intents, and returning-user states preserve continuity.

Future surface work must show how it contributes to continuity, believability, proof, recovery, correction, trust, memory, focus, strategic pathing, or calmness. A batch that only polishes a tab without strengthening the loop is not enough.

Future surface work must also state which maturity gate from [Ambitions_2_0_RC_Maturity_Plan.md](Ambitions_2_0_RC_Maturity_Plan.md) it advances. A surface is not release-candidate ready until it has a useful v1, cross-surface integration, trust/correction/degraded behavior, performance/accessibility proof, and representative scenario validation where relevant.

## Primary Flow: Goal -> Path -> Plan -> Today -> Action -> Recovery -> Review

1. User creates or refines a goal.
2. Path Intelligence proposes a believable path with assumptions and broad domain fit.
3. Plan turns the path into scheduled or unscheduled work based on capacity and calendar availability when allowed.
4. Today selects the next believable action from Canonical Now State.
5. The user acts, delays, splits, skips, asks why, or corrects the recommendation.
6. Action Closure produces a receipt for what happened, what changed, why it changed, whether undo is safely available, and what can be corrected.
7. Reality Reflow converts disruption into a safe recovery path without silent rescheduling.
8. Review captures what happened, what changed, what was protected, what remains believable, and what the system should learn.

## Primary Flow: Capture -> Triage -> Goal / Plan / Seed / Waiting / Archive

1. User captures a thought quickly.
2. Capture classifies the item as raw, goal candidate, plan patch, seed, waiting, or archive.
3. User confirms or changes the route.
4. Goal-bound items attach to Goals or Goal Detail.
5. Plan-bound items become plan seeds, schedule candidates, or rituals.
6. Commitment and waiting items attach to a lightweight Person, Commitment, Waiting item, Follow-Up, or sensitivity marker where useful without becoming generic tasks.
7. Resource and proof items attach to Life Graph as files, links, notes, evidence, external references, documents, project artifacts, or reflections.
8. Waiting/archive items remain retrievable through Capture and You memory surfaces.

## Primary Flow: Plan -> Calendar-Aware Mode -> Scheduled Block -> Recovery / Review

1. Plan shows believable planning without calendar access.
2. User taps `Make Plan calendar-aware` or `Find real open windows`.
3. Permission rationale explains local-first calendar use.
4. Calendar read enables open-window and conflict detection.
5. Calendar write creates user-confirmed blocks only.
6. Calendar writes produce Action Closure receipts and undo where safely supported.
7. Scheduled blocks feed Now State, Today, and review.
8. Missed or disrupted blocks enter Reality Reflow, recovery, and later review.

## Global Shell / Chrome Architecture

Global chrome is the persistent app frame around every screen. It is not feature content and must not create new top-level navigation.

Global chrome owns:

- status-bar and safe-area background behavior
- global app canvas color
- top header and navigation bar behavior
- logo treatment
- page title behavior
- Mode Lens pill behavior
- notification, back, and overflow button treatment
- bottom tab bar active/inactive states
- scroll-edge behavior
- sheet/modal header style
- shared spacing from screen edges
- how content panels sit inside the shell
- how rich panels visually relate to the background
- command/result receipt placement
- continuity/status messaging placement

The dedicated global chrome batch should establish the permanent shell, contextual top header, optional Continuity Ribbon / Anti-Plan strip, and Action Closure Tray presentation before the later Goals, Plan, You, Reviews, and external-surface batches consume those patterns.

## Shell Inventions

- Mode Lens: a visible shell pill or contextual treatment for Focus, Triage, Plan, Recover, and Review. It changes emphasis, not navigation, and must not create hidden tabs or duplicate ownership.
- Continuity Ribbon: a compact, calm strip under the header that shows the one continuity fact the user most needs.
- Action Closure Tray: a premium receipt panel for meaningful commands, not a generic toast system.
- Save the Day entry: a reachable rescue affordance that returns one protected must-do, one move/drop/shrink action, and one recovery explanation.
- Ambient Status Orb: a reusable qualitative marker for states such as Clear, Steady, Tight, Fragile, At risk, Recovered, and Protected.
- Life Graph Breadcrumb: a drill-down aid showing where an object lives in the user's life system; it should not clutter top-level screens.
- Mission Control Lanes: an object-level detail pattern for Path, Now, Proof, and Risk first, with People, Resources, and Decisions later when supported.
- Not Today / Anti-Plan strip: a protective treatment for work intentionally parked away from today.
- Proof Rail: a compact proof-artifact rail for Goal Detail, Reviews, Path Builder, and top-level Goals summaries where useful.
- Trust Badge / Trust status: a small trust treatment for You and Trust Center, surfaced globally only when action is needed.

Mode Lens changes emphasis, priority, and presentation only. It must not change object ownership, create hidden tabs, hide required actions, create separate state, duplicate navigation, or change the source of truth.

## Reviews Architecture

Reviews live primarily under `You -> Reviews` with contextual entry from Today, Plan, and Goal Detail.

Reviews include:

- Recovery Review
- Daily Receipt
- Weekly Life OS Receipt
- Goal Review
- Memory Review
- Correction Review
- Review Constellation narrative memory
- accessibility summary after verification
- memory and change summaries

Reviews are not generic analytics. Recovery Review should be immediate and 30-90 seconds, Weekly Life OS Receipt is the main recurring review, Goal Review is object-specific, Memory Review lives under You, and Correction Review audits wrong assumptions, never-suggest feedback, and memory corrections. Each review must answer what happened, what changed, what remains believable, and what action follows.

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
