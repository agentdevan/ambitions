# Ambitions Goal / Plan / Task Lifecycle

Status: Active canon consolidation layer.

Purpose: Make the Ambitions execution lifecycle explicit enough for implementation, QA, and future Codex batches. This document consolidates lifecycle truth from Product Architecture, Systems Architecture, Visual System, Intelligence Standards, the Design Constitution, and product decision Waves 1-2.

## Core Doctrine

Ambitions is not a task manager with goals attached. It is a visual life execution system where goals, plans, milestones, steps, proof, decisions, weather, and archive learning remain connected.

Wave 1 product rules:

```text
Every item has a place.
Every goal has a next step.
Every plan must be believable.
The user never feels punished for drifting.
The app stays deep, not wide.
```

Wave 2 state-language rules:

```text
Internal Dropped state renders as No Longer Relevant in normal UI.
Cancelled and Dropped are internally separate, but launch UI may simplify.
Intentional goal ending action: End Goal, then ask reason.
Intentional pause action: Park Goal. State: Parked.
Goal Weather is corrected through inputs, not direct manual override.
Internal Plan states may be strong; UI labels should be softer.
Destructive actions, external writes, and major deadline changes require confirmation.
Reversible local changes prefer receipt + undo.
```

Hierarchy:

```text
Goal = meaningful outcome that may need a plan
Path = strategic route
Plan = believable execution shape
Milestone = meaningful checkpoint
Step = contained action
Task = standalone One-Step Goal
Proof = evidence of progress
Decision = reason the path changed
Receipt = action closure
Review = learning loop
Archive = memory and learning
```

User-facing language:

```text
Task
```

Internal/design language:

```text
One-Step Goal
```

## Primary Lifecycle Loop

```text
Capture
-> Clarify / Route
-> Seed / Task / Goal / Plan / Waiting / Proof / Decision / Ritual
-> Shape Path
-> Build Plan
-> Execute Today
-> Close With Receipt
-> Create Proof
-> Reflow Reality
-> Review
-> Learn / Correct
-> Complete / Park / End / Archive
```

Every meaningful object should have:

- a visible current state
- a next possible action
- a reason it is shown
- a place or route
- a receipt after meaningful change
- a way to correct or undo where safe
- a history trail when the change matters

## Goal Lifecycle

A Goal is a meaningful outcome that may need a plan.

### Goal states

| Internal state | Preferred UI label | Meaning | User-facing behavior |
| --- | --- | --- | --- |
| Seed | Seed / Idea | Possible goal, not yet committed | Lives in Capture, Life Area, or Goal seed area; can be clarified or promoted. |
| Active | Active | Current committed outcome | Appears in Goals, Plan, Today when relevant, and Goal Detail. |
| Protected | Protected | Active goal needing defense from distraction or drift | Gets elevated in Today/Plan and Goal Weather explanation. |
| Waiting | Waiting | Goal depends on outside event/person/info | Removed from unnecessary daily pressure; remains visible as waiting. |
| Blocked | Blocked | Goal cannot move until blocker resolves | Shows blocker, recovery, and unblock path. |
| Parked | Parked | Intentionally paused | Preserved without shame; can resume later. |
| Completed | Completed | Successfully finished | Remains visibly emphasized for 30 days by default, then moves toward Archive/Completion Archive treatment. Major goals may remain emphasized longer. |
| Cancelled | Ended | Intentionally ended | User action is `End Goal`; preserves reason and learning; not treated as trash. |
| Dropped | No Longer Relevant | Ended through non-continuation or relevance loss | Preserves why it drifted/died and what was learned without judgmental wording. |
| Merged | Merged | Folded into a larger or related goal | Creates decision receipt and pointer to new owner. |
| Replaced | Replaced | Superseded by a better goal/path | Creates decision receipt and pointer to replacement. |
| Archived | Archive | Preserved historical object | Searchable/reviewable learning artifact. |

### Goal state transitions

Allowed transitions:

```text
Seed -> Active
Seed -> Parked
Seed -> Archived
Active -> Protected
Active -> Waiting
Active -> Blocked
Active -> Parked
Active -> Completed
Active -> Cancelled
Active -> Dropped
Active -> Merged
Active -> Replaced
Protected -> Active
Protected -> Waiting / Blocked / Parked / Completed / Cancelled
Waiting -> Active / Blocked / Parked / Cancelled
Blocked -> Active / Waiting / Parked / Cancelled
Parked -> Active / Cancelled / Dropped / Archived
Completed -> Archived
Cancelled -> Archived
Dropped -> Archived
Merged -> Archived
Replaced -> Archived
```

Rules:

- Every Active or Protected goal should expose one Next Visible Step unless blocked/waiting.
- Every Blocked or Waiting goal should show what it is waiting on.
- Every Parked, Cancelled, Dropped, Merged, or Replaced goal should create a Decision Trail entry.
- Completed is not the same as Cancelled or Dropped.
- Cancelled and Dropped remain internally separate, but launch UI may simplify.
- `Dropped` should usually render as `No Longer Relevant` in normal UI.
- `End Goal` is the general intentional-ending action and should ask the reason.
- `Park Goal` is the pause action and creates the Parked state.
- Archive is not trash.
- Goal recovery must never punish the user for drifting.

## Goal Weather Lifecycle

Goal Weather is the qualitative user-facing signal for goal health. It is not a separate engine.

| Weather | Meaning | Required explanation |
| --- | --- | --- |
| Clear | Direction, next action, and proof are healthy | Why it is holding. |
| Cloudy | Progress exists, but clarity or next action is weak | What needs clarification. |
| Stormy | Risk, blocker, overload, or deadline pressure is serious | What is at risk and how to recover. |
| Foggy | Missing proof, missing path, or weak signal | What Ambitions does not know. |
| Protected | Goal needs defense from distraction or schedule pressure | What is being protected and why. |

Rules:

- Weather must be explainable through Why This / Why Changed.
- Users should not manually override weather directly.
- Users should be able to correct inputs that affect weather: deadline, proof, blocker, next step, scope, waiting state, assumptions.
- Avoid fake precision.
- Do not use childish weather graphics.
- Weather should influence Plan believability and Today priority without silently mutating state.

## Path Lifecycle

Path states:

- `draft`
- `proposed`
- `active`
- `needs review`
- `forked`
- `superseded`
- `archived`

Path flow:

```text
Goal created
-> path draft
-> assumptions identified
-> milestones proposed
-> readiness checked
-> active path accepted
-> path feeds Plan
-> path changes create Decision Trail
```

Rules:

- Path assumptions must be visible when they affect recommendations.
- Path changes should not silently rewrite the user's goal.
- Major path changes create decisions and receipts.

## Plan Lifecycle

Plan states:

| Internal state | Preferred UI label | Meaning |
| --- | --- | --- |
| Draft | Draft | Plan is being shaped. |
| Believable | Believable | Plan appears to fit current constraints. |
| Tight | Tight | Plan can hold, but with pressure. |
| Fragile | Needs Protection | Plan is likely to break without change. |
| Broken | No Longer Holds | Plan no longer holds. |
| Reflowing | Adjusting | User or system is adjusting plan after reality changed. |
| Saved | Saved | Plan accepted for day/week. |
| Reviewed | Reviewed | Plan outcome was reviewed. |
| Archived | Archive | Historical plan record. |

Plan flow:

```text
Goals / Tasks / Rituals / Commitments enter Plan
-> Plan checks capacity and context
-> Plan shows believability
-> User accepts, adjusts, protects, moves, parks, or makes calendar-aware
-> Today consumes the current plan window
-> Reality changes
-> Reality Reflow proposes safer shape
-> Action Closure creates receipt
-> Review captures outcome
```

Rules:

- Every plan must communicate whether it is believable.
- Internal states can remain strong for logic and QA.
- UI should generally render `Fragile` as `Needs Protection` and `Broken` as `No Longer Holds`.
- Plan owns calendar permission.
- Plan must work without calendar access.
- Calendar write always requires explicit confirmation.
- Major deadline changes require confirmation or an explicit reviewed change flow.
- Plan should not silently reschedule.
- Major Plan Treaty changes create Decision Trail notes.
- Recovery language must stay non-shaming.

## Task / One-Step Goal Lifecycle

A Task is a standalone One-Step Goal. It can exist without a Goal.

Task states:

- `captured`
- `needs place`
- `standalone`
- `planned`
- `scheduled`
- `next`
- `doing`
- `waiting`
- `done`
- `parked`
- `attached to goal`
- `promoted to goal`
- `converted to ritual`
- `archived`

Task flow:

```text
Capture / Create
-> Needs a Place or Standalone Task
-> Attach / Plan / Schedule / Keep Standalone
-> Today or Plan surfaces it when relevant
-> Complete / Move / Park / Promote / Convert
-> Receipt
-> Review or Archive when useful
```

Rules:

- A Task is allowed to stay standalone.
- Ambitions should suggest attaching or promoting a Task when useful.
- A Task can be attached to a Goal when it supports larger direction.
- A Task can be promoted to a Goal when it has too much structure.
- A Goal can be demoted to a Task when the structure was too heavy, with a receipt.
- No top-level Tasks tab.
- Normal UI says `Task`; internal/design canon can say `One-Step Goal`.
- Mark Done, Move task, Park task, Attach task to goal, Rename Life Area, and Change display density should prefer receipt + undo.

## Step Lifecycle

Step states:

- `planned`
- `next`
- `doing`
- `waiting`
- `blocked`
- `done`
- `moved`
- `split`
- `skipped`
- `archived`

Rules:

- A Step must belong to a Goal, Path, Plan, or Milestone.
- Steps feed Next Visible Step selection.
- Completed steps can generate proof when they create evidence.
- Split, moved, skipped, or blocked steps should be receipt-backed when meaningful.

## Milestone Lifecycle

Milestone states:

- `future`
- `active`
- `at risk`
- `blocked`
- `completed`
- `skipped`
- `replaced`

Rules:

- Milestones are meaningful checkpoints, not every tiny task.
- Milestone Cards should appear before dense task detail.
- Milestone completion should create proof and optionally trigger review.

## Proof Lifecycle

Proof states:

- `captured`
- `attached`
- `verified by user`
- `used in review`
- `archived`

Rules:

- Proof should be attached to the most relevant object.
- Proof should support progress, Goal Weather, reviews, and trust.
- Proof should never become fake gamification.

## Decision Lifecycle

Decision states:

- `created`
- `explained`
- `corrected`
- `superseded`
- `archived`

Decision events:

- goal started
- scope changed
- plan changed
- deadline changed
- blocked/waiting reason added
- goal parked
- goal completed
- goal cancelled/dropped
- goal merged/replaced
- task promoted/demoted
- memory corrected

Rules:

- Decision Trail is the user-facing version of meaningful change history.
- Decisions should make changed plans feel intelligent and dignified, not shameful.
- Destructive actions, external writes, and major deadline changes require confirmation.
- Ordinary local reversible changes should prefer receipt + undo.

## Receipt Lifecycle

Receipt states:

- `visible`
- `collapsed`
- `undo available`
- `undo expired`
- `corrected`
- `searched`
- `archived`

Receipt anatomy:

- what happened
- what changed
- why it changed
- undo if safe
- correction route if relevant
- timestamp/source when useful

Receipt + undo first:

- Mark Done.
- Move task.
- Park task.
- Attach task to goal.
- Rename Life Area.
- Change display density.

Confirmation required:

- Delete memory.
- Calendar write.
- Major deadline changes.
- Other destructive actions.

Rules:

- Receipts are not generic toasts.
- Receipts are searchable trust history.
- Sensitive receipt details hide by default.
- Do not over-confirm reversible local actions.

## Review Lifecycle

Review states:

- `prompted`
- `started`
- `completed`
- `carried forward`
- `corrected`
- `archived`

Review types:

- Recovery Review
- Daily Receipt
- Weekly Life OS Receipt
- Goal Review
- Memory Review
- Correction Review

Rules:

- Reviews primarily live under You -> Reviews.
- Reviews can be triggered contextually from Today, Plan, and Goal Detail.
- Reviews should be short when recovery is urgent and deeper when intentionally opened.

## Recovery Lifecycle

Recovery flow:

```text
Drift detected
-> explain what changed
-> offer safest recovery option
-> user chooses lighter / move / park / protect / replan / review
-> Reality Reflow updates representation
-> receipt closes action
-> Review learns if useful
```

Rules:

- Recovery must be non-shaming.
- The app should make slipping feel fixable.
- Recovery should never hide deadline impact.
- Unsupported recovery commands must fail safely without fake state changes.

## Life Area Lifecycle

Life Areas are inferred/recommended and correctable, not mandatory friction.

Default Life Areas:

```text
Career
Creative
Finance
Health
Home
Relationships
Education
Personal
Admin
```

Rules:

- Life Areas should help every item have a place.
- User-facing names can be renamed.
- Internal canonical type should remain stable for routing and intelligence.
- Items can temporarily exist without confirmed Life Area when routing is uncertain.
- Smart Attachment receipts should allow Life Area correction.
- Renaming Life Area should prefer receipt + undo, not confirmation.

## Archive / Completion Archive

Product/design language:

```text
Completion Archive
```

Normal UI language:

```text
Archive
```

Rules:

- Archive preserves learning; it is not trash.
- Completed goals remain visibly emphasized for 30 days by default.
- Major completed goals may remain emphasized longer depending on importance.
- Cancelled, No Longer Relevant, Merged, Replaced, and Parked histories should preserve reason, proof, and decision trail.

## Acceptance Criteria

A lifecycle implementation is acceptable only when:

- Every major state is visible or intentionally hidden with a safe collapsed signal.
- State changes create receipts when meaningful.
- Major path/goal/plan changes create decisions.
- Top-level screens remain calm and do not expose lifecycle machinery as clutter.
- Detail screens provide explanation and correction.
- Archived/completed/cancelled/no-longer-relevant objects preserve learning.
- QA can distinguish implemented behavior from planned canon.
- The user can recover from drift without punitive language.
- New depth is added through drill-downs/contextual intelligence rather than unnecessary top-level surfaces.

## Resolved Wave 1 Questions

- A Goal is a meaningful outcome that may need a plan.
- User-facing standalone action language is Task; internal/design term is One-Step Goal.
- A Task can exist without a Goal and should be attachable/promotable when useful.
- Life Areas are inferred/recommended and correctable.
- Default Life Areas are Career, Creative, Finance, Health, Home, Relationships, Education, Personal, Admin.
- Default Life Areas can be renamed while keeping canonical type.

## Resolved Wave 2 Questions

- Internal `Dropped` renders as `No Longer Relevant` in normal UI.
- Cancelled and Dropped remain internally separate; launch UI may simplify.
- Intentional goal ending action is `End Goal`, followed by a reason.
- Intentional pause action is `Park Goal`; state is Parked.
- Goal Weather is corrected through inputs, not direct manual override.
- Internal Plan states can be strong; UI should use `Needs Protection` and `No Longer Holds`.
- Destructive actions, external writes, and major deadline changes require confirmation.
- Mark Done, Move task, Park task, Attach task to goal, Rename Life Area, and Change display density prefer receipt + undo.
- Completed goals stay visibly emphasized for 30 days by default; major goals may remain emphasized longer.
- Product/design language is Completion Archive; normal UI language is Archive.

## Open Questions For Future Waves

- Which state changes should create a visible Decision Trail entry versus only a receipt?
- How detailed should the End Goal reason picker be?
- How long should undo remain available by action type?
- Which memories require explicit confirmation before use?
