# Ambitions 2.0 Intelligence Standards

Adoption date: 2026-04-24

## Purpose

This document locks the product intelligence standards for Ambitions 2.0. It exists so future Codex batches do not implement Ambitions as a generic task app with attractive screens. Ambitions must become intelligent, purposeful, and feature-rich without becoming crowded.

Ambitions should combine:

- Calendar-style scheduling
- Reminders-style commitments
- Things-style task/project execution
- Capture-based intake
- visible short-term and long-term goal timelines
- recovery intelligence
- explainable recommendations

The sellable reason to use Ambitions is:

> Drop your life into Ambitions, and it shows what matters now, where it fits, why it matters, and how it connects to the bigger map.

## Non-Negotiable Product Standard

Every user-created item must have an obvious destination and lifecycle.

- One-time tasks go to Plan and Today.
- Goal-supporting tasks attach to Goal Detail.
- Raw ideas go to Capture and Seed.
- Waiting items go to Waiting.
- Scheduled work goes to Plan.
- Completed, changed, moved, delayed, removed, or recovered work writes to Memory / Event Ledger.

Every major surface must answer one question immediately:

- Today: What should I do now?
- Goals: Where am I headed and what needs attention?
- Capture: What do I need to get out of my head?
- Plan: Does my real week have room?
- You: Can I trust and tune this system?

A new user should understand what a screen is for within five seconds. Advanced capability must appear through drill-downs, explanation, and progressive disclosure instead of top-level clutter.

## Layered Object Model

Ambitions must not force every item into the same shape. The system should operate in distinct layers:

1. Life Domain
   - Work, Creative, Finance, Health, Home, Personal, Education, Career, Admin.
2. Context Lens
   - Work, Personal, Free Time, Admin, Creative, Recovery, Deep Focus, All.
3. Path
   - Long-range direction, strategy, stages, prerequisites, alternate routes.
4. Goal Container
   - A living shell for a meaningful outcome.
5. Milestone
   - A major checkpoint inside a goal or path.
6. Deliverable
   - A concrete output, such as a song, spreadsheet, crib assembly, application, or room setup.
7. Action / Commitment
   - A task, one-time deadline item, recurring ritual, waiting item, or next step.
8. Scheduled Block
   - Time placed into Plan or Calendar.
9. Event Ledger Entry
   - What happened, changed, moved, completed, removed, deferred, displaced, or recovered.

This layering prevents stale, forced, or impersonal plans. A one-time work item does not need to become a goal. A song can be a deliverable inside an album goal. A crib can be a high-priority home deliverable with a hard deadline. Piano can be a passive long-term learning goal.

## Priority Reality Model

Priority is not a single high/medium/low flag. Ambitions must eventually reason about priority using multiple dimensions:

- Importance: how much it matters to the user.
- Urgency: how soon it matters.
- Deadline: hard, soft, flexible, or none.
- Consequence: what happens if it slips.
- Effort: time, energy, and focus required.
- Context fit: work, free time, home, creative, admin, errands, deep focus.
- Goal relationship: standalone task, goal-supporting action, deliverable, milestone, ritual, or path step.
- User preference: explicit user-stated priority or domain preference.
- Capacity: what actually fits in the user’s available time.
- Recovery state: whether the plan is already compressed, missed, displaced, or fragile.

Ambitions must not treat all goals or tasks as equal.

Example distinction:

- Build the baby crib before the due date: high importance, hard deadline, high consequence, home/free-time context, should displace lower-priority free-time goals.
- Learn piano: meaningful but passive, flexible timeline, low immediate consequence, should appear gradually and never crowd out urgent life commitments.

Future surfaces should explain priority decisions in plain language, such as:

- "This is first because it has a hard deadline and high consequence."
- "Piano is still active, but it can move slowly without breaking the plan."
- "This was displaced because the crib deadline has less slack."

## Context Lens Standard

Today must eventually support context-aware views similar to iOS Focus modes.

Supported lenses should include:

- Work
- Personal
- Free Time
- Admin
- Creative
- Recovery
- Deep Focus
- All

The current lens may be inferred from:

- scheduled work hours when provided
- calendar context when permission is granted
- goal/task domain
- commitment type
- deadline urgency
- user preference
- recent behavior
- manual override

Users without a fixed work schedule must still be supported. For salaried users, flexible schedules, gig work, caregivers, founders, students, and people who work around the clock, Ambitions should rely on domains, manual lens defaults, calendar/task context, and explicit controls such as `Show work now`, `Show personal now`, or `Show all`.

Today should never hide urgent cross-context commitments completely. It may collapse them into a safe escape hatch such as `Outside this lens` or `Urgent outside work`.

## Commitment Capture Standard

Capture must understand one-time commitments without forcing them into full goals.

Example:

> Create spreadsheet and send it to Kaylee by EOD Tuesday.

Future expected interpretation:

- item type: one-time deadline commitment
- likely domain: Work
- likely route: Plan
- due: Tuesday EOD
- scheduling need: work block before deadline
- Today visibility: Work Lens when relevant, or outside-lens urgent summary if needed
- Event Ledger: commitment captured, commitment routed, item scheduled, action completed or recovered

Capture should classify or ask for confirmation when confidence is low. The user must be able to correct route, domain, deadline, priority, or context without feeling trapped.

## Living Goal Container Standard

A goal like `Create an Album` should be a living container, not a frozen checklist.

A Goal Container may contain:

- deliverables, such as songs or spreadsheet outputs
- milestones
- actions
- sessions
- references
- blockers
- waiting items
- optional items
- removed items
- completed items
- scope changes
- review notes

Adding or removing a song from an album should update:

- roadmap
- progress
- believability
- remaining work
- review history
- Today recommendations
- Plan suggestions
- Memory / Event Ledger

The user must be able to adjust scope without making the system feel stale, locked, or punitive.

## Obvious Destination Rules

When the user creates or captures something, Ambitions must make its destination obvious.

- A captured one-time commitment should say when it will matter and where it went.
- A goal-supporting task should show the goal it attaches to.
- A new deliverable should appear inside its Goal Container.
- A scheduled block should appear in Plan and influence Today.
- A waiting item should remain findable without polluting Today.
- A passive/someday item should not compete with urgent work.

If Ambitions cannot confidently route an item, it should ask one clear question rather than expose a complex triage dashboard.

## Explanation Requirements

Every intelligent recommendation should be explainable by the Recommendation Explanation Model.

Explanations should be able to describe:

- why this item is shown now
- why this item belongs in this context lens
- why this item was routed to Plan, Goals, Capture, Waiting, or Seed
- why this item was prioritized
- why another item was deferred
- why a lower-priority item was displaced
- why a goal changed
- why a deadline or consequence changed the plan
- whether evidence came from user input, calendar context, event ledger history, assumptions, or defaults
- what the user can correct

The explanation must distinguish evidence from assumption. It should prefer adult, practical language over technical model terms.

## Batch Mapping

These standards must influence all future batches, especially:

- Batch 66: Recommendation Explanation Model must explain priority, context, commitment routing, deadlines, consequence, scope changes, and displacement.
- Batch 67: Canonical Now State must include context lens, best action for that lens, urgent outside-lens items, priority pressure, and passive versus active goal pressure.
- Batch 68: Command Pipeline must route commitments, context changes, priority changes, deliverable changes, scheduling commands, and recovery commands through one path.
- Batch 69: Capture 2.0 must classify one-time commitments, deadline tasks, goal seeds, plan seeds, waiting items, deliverables, and optional/someday items.
- Batch 70: Reality Model must place commitments into real time and understand work/free-time/context fit.
- Batch 71: Believability, Capacity, and Goal Health must weigh priority, urgency, consequence, available time, passive versus active status, and deadline credibility.
- Batch 72: Execution Resilience must handle missed high-priority items, displaced lower-priority tasks, deadline compression, and too many commitments for available context/time.
- Batch 73: Today 2.0 must expose the current lens, one best next move, urgent outside-lens items, and why-this-now without becoming a dashboard.
- Batch 74: Goals and Goal Detail 2.0 must support living goal containers, deliverables, scope changes, visible roadmaps, completed work, remaining work, and passive versus active goals.
- Batch 75: Plan 2.0 must show context blocks, calendar-aware fit, priority conflicts, displaced items, protected high-priority work, and calmly deferred lower-priority work.
- Batch 76: You 2.0 must make preferences, memory, trust, review, and correction paths visible without becoming a junk drawer.
- Batch 77: Contextual insights and reviews must explain what changed, what remains believable, and what action follows.
- Batch 81-82: Path Intelligence and Path Builder must connect long-range paths to living goal containers, deliverables, milestones, and daily actions.

## Anti-Patterns

Do not build:

- a generic task list with a goal label
- a calendar clone with extra cards
- a separate habit tracker hidden in Plan
- a dashboard where all goals compete equally
- a capture inbox that becomes a graveyard
- a priority flag that ignores deadline, consequence, effort, and context
- a rigid goal checklist that cannot accept scope changes
- a system that hides where an item went
- a screen that requires the user to understand app architecture before getting value

## Success Test

Ambitions passes this standard when a user can:

1. Capture `Create spreadsheet and send it to Kaylee by EOD Tuesday` and understand where it went, when it matters, and what to do next.
2. Create `Build the baby crib before the due date` and see it prioritized over lower-consequence free-time goals.
3. Keep `Learn piano` active as a passive long-term goal without it crowding urgent commitments.
4. Create `Create an Album`, add or remove songs, and see the roadmap, remaining work, and daily plan update without starting over.
5. Open Today during work time and see the Work Lens, while still being able to switch to Free Time or All.
6. Open the app cold and understand the purpose of the current screen within five seconds.
