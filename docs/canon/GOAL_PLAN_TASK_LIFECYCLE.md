# Ambitions Goal / Plan / Task Lifecycle

Status: Active canon consolidation layer.

Purpose: Make the Ambitions execution lifecycle explicit enough for implementation, QA, and future Codex batches. This document consolidates lifecycle truth from Product Architecture, Systems Architecture, Visual System, Intelligence Standards, and the Design Constitution.

## Core Doctrine

Ambitions is not a task manager with goals attached. It is a visual life execution system where goals, plans, milestones, steps, proof, decisions, weather, and archive learning remain connected.

Hierarchy:

```text
Goal = direction
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
-> Complete / Park / Cancel / Archive
```

Every meaningful object should have:

- a visible current state
- a next possible action
- a reason it is shown
- a receipt after meaningful change
- a way to correct or undo where safe
- a history trail when the change matters

## Goal Lifecycle

### Goal states

| State | Meaning | User-facing behavior |
| --- | --- | --- |
| Seed | Possible goal, not yet committed | Lives in Capture, Life Area, or Goal seed area; can be clarified or promoted. |
| Active | Current committed outcome | Appears in Goals, Plan, Today when relevant, and Goal Detail. |
| Protected | Active goal needing defense from distraction or drift | Gets elevated in Today/Plan and Goal Weather explanation. |
| Waiting | Goal depends on outside event/person/info | Removed from unnecessary daily pressure; remains visible as waiting. |
| Blocked | Goal cannot move until blocker resolves | Shows blocker, recovery, and unblock path. |
| Parked | Intentionally paused | Preserved without shame; can resume later. |
| Completed | Successfully finished | Moves to Completion Archive with proof and final review. |
| Cancelled | Intentionally ended | Preserves reason and learning; not treated as trash. |
| Dropped | Ended through non-continuation or relevance loss | Preserves why it drifted/died and what was learned. |
| Merged | Folded into a larger or related goal | Creates decision receipt and pointer to new owner. |
| Replaced | Superseded by a better goal/path | Creates decision receipt and pointer to replacement. |
| Archived | Preserved historical object | Searchable/reviewable learning artifact. |

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
- Archive is not trash.

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

| State | Meaning |
| --- | --- |
| Draft | Plan is being shaped. |
| Believable | Plan appears to fit current constraints. |
| Tight | Plan can hold, but with pressure. |
| Fragile | Plan is likely to break without change. |
| Broken | Plan no longer holds. |
| Reflowing | User or system is adjusting plan after reality changed. |
| Saved | Plan accepted for day/week. |
| Reviewed | Plan outcome was reviewed. |
| Archived | Historical plan record. |

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

- Plan owns calendar permission.
- Plan must work without calendar access.
- Calendar write always requires explicit confirmation.
- Plan should not silently reschedule.
- Major Plan Treaty changes create Decision Trail notes.

## Task / One-Step Goal Lifecycle

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
- A Task can be attached to a Goal when it supports larger direction.
- A Task can be promoted to a Goal when it has too much structure.
- A Goal can be demoted to a Task when the structure was too heavy, with a receipt.
- No top-level Tasks tab.

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

Rules:

- Receipts are not generic toasts.
- Receipts are searchable trust history.
- Sensitive receipt details hide by default.

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

## Acceptance Criteria

A lifecycle implementation is acceptable only when:

- Every major state is visible or intentionally hidden with a safe collapsed signal.
- State changes create receipts when meaningful.
- Major path/goal/plan changes create decisions.
- Top-level screens remain calm and do not expose lifecycle machinery as clutter.
- Detail screens provide explanation and correction.
- Archived/completed/cancelled/dropped objects preserve learning.
- QA can distinguish implemented behavior from planned canon.

## Open Questions For Future Waves

- Should `Dropped` be user-facing, or should user-facing copy say `No Longer Relevant`?
- Should `Cancelled` and `Dropped` be separate at launch?
- Which state changes require confirmation versus receipt + undo?
- How long should completed goals remain visible before archive emphasis changes?
- Should Goal Weather be manually overrideable?
- Should Plan states use `Tight / Fragile / Broken` or softer labels?
