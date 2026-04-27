# Ambitions Empty, Error, And Recovery States

Status: Active canon consolidation layer.

Purpose: Define product-wide state behavior so Ambitions feels polished outside the ideal path. This document expands the UX Writing Matrix into a screen-by-screen implementation reference.

## State Doctrine

Premium product quality shows up when nothing exists, something fails, or life drifts.

Every non-ideal state should answer:

1. What happened?
2. What remains safe or true?
3. What is the next useful action?
4. Can the user correct, retry, recover, or move on?

## Voice Rules

Use language that is:

- calm
- adult
- specific
- non-shaming
- action-oriented
- honest about uncertainty

Avoid:

- failed
- lazy
- behind again
- streak lost
- AI/model language
- fake certainty
- marketing claims
- blame

## Universal State Patterns

### Empty State

Required anatomy:

- short explanation of what is missing
- one useful primary action
- optional secondary action
- optional example

Example:

```text
Nothing needs a place right now.
```

Primary action:

```text
Capture
```

### Error State

Required anatomy:

- what happened
- what remains safe
- what the user can do

Example:

```text
Calendar access is unavailable. Plan still works manually.
```

Primary action:

```text
Keep Planning
```

### Loading State

Required anatomy:

- specific object/action language
- no fake intelligence theater

Example:

```text
Checking today's plan
```

Avoid:

```text
Thinking...
```

### Success State

Required anatomy:

- what happened
- where it went
- next useful route
- correction/undo where safe

Example:

```text
Saved as Task · Home · Later
```

Actions:

```text
Change
Open
```

### Recovery State

Required anatomy:

- what changed
- consequence if ignored
- safest next move
- alternatives
- receipt after action

Example:

```text
Today got tighter. One lighter version still fits.
```

Primary action:

```text
Make Lighter
```

Secondary actions:

```text
Move This
Park
Open Plan
```

## Screen State Matrix

| Surface | Empty state | Error state | Recovery state | Primary action |
| --- | --- | --- | --- | --- |
| Today | No planned work yet; explain that Today gets useful after one object exists | Could not load current plan; local data remains safe | Day drifted, no open window, overloaded, missed protected item | Capture Something / Save the Day |
| Goals | No active goals; invite first meaningful goal or Life Area | Could not load goals; existing local data remains safe | Goal stale, blocked, waiting, or no Next Visible Step | Add Goal / Review Goal |
| Goal Detail | Goal has no plan/proof/steps yet | Could not load detail; goal remains available from Goals | Goal at risk, blocked, scope too large, deadline no longer believable | Add First Step / Replan |
| Capture | Nothing needs a place | Could not save capture; preserve user input | Low-confidence route, needs clarification, failed attachment | Save / Change Route |
| Plan | No plan created yet | Calendar unavailable, plan still works manually | Week tight, fragile, broken, overloaded, conflict detected | Shape Week / Save the Week |
| You | No reviews/memory/history yet | Could not load settings/memory; core app remains usable | Memory may need review, trust item needs correction | Review Memory / Open Trust Center |
| Trust Center | No receipts or trust issues yet | Could not load trust history; privacy controls remain available | Memory stale, sync/export failed, permission denied | Inspect / Correct |
| What Ambitions Knows | No memories yet | Could not load memory; no new memory applied | Memory stale or contradicted by correction | Add Preference / Review |
| Reviews | No reviews yet | Could not build review; historical data remains safe | Carryover, drift, correction, plan no longer believable | Start Review |
| Archive | No archived learning yet | Could not load archive; active work unaffected | Restore, inspect, or learn from cancelled/dropped item | Open Item / Restore |

## Today States

### Empty Today

Copy:

```text
Today gets useful after you add one thing that matters.
```

Primary action:

```text
Capture Something
```

Secondary action:

```text
Add Goal
```

Rules:

- Do not show a blank dashboard.
- Do not imply the user is behind.
- If there are captures/goals elsewhere, show one route to pull something into Today.

### Drifted Today

Copy examples:

```text
Today changed. Protect one thing and move the rest.
```

```text
One lighter version still fits.
```

Actions:

- `Save the Day`
- `Make Lighter`
- `Move This`
- `Park`

Rules:

- Show consequence calmly.
- Do not hide deadline impact.
- Create receipt after meaningful recovery.

### Missed Protected Item

Copy:

```text
This slipped. Protect a smaller version or move it with context.
```

Actions:

- `Make Lighter`
- `Move This`
- `Open Plan`

Rules:

- Avoid shame.
- Preserve the reason it mattered.

## Goals States

### No Goals

Copy:

```text
Start with one direction you want to make real.
```

Primary action:

```text
Add Goal
```

Secondary action:

```text
Capture Idea
```

### Goal Missing Next Step

Copy:

```text
This goal needs one clear next step.
```

Primary action:

```text
Choose Next Step
```

### Goal Foggy

Copy:

```text
Ambitions needs more proof or direction before this goal is clear.
```

Actions:

- `Add Proof`
- `Shape Path`
- `Review Goal`

### Goal Stormy

Copy:

```text
This goal is at risk under the current plan.
```

Actions:

- `Replan`
- `Protect`
- `Move Deadline`

## Capture States

### Empty Capture

Copy:

```text
Nothing needs a place right now.
```

Primary action:

```text
Capture
```

### Save Failed

Copy:

```text
This did not save. Your text is still here.
```

Actions:

- `Try Again`
- `Copy Text`

Rules:

- Preserve input.
- Do not discard raw user thought.

### Low Confidence Route

Copy:

```text
Ambitions is not sure where this belongs.
```

Actions:

- `Task`
- `Goal`
- `Idea`
- `Needs a Place`

Rules:

- Ask one clear question.
- Do not open a complex triage dashboard.

## Plan States

### No Plan

Copy:

```text
Shape a week that can actually hold.
```

Primary action:

```text
Shape Week
```

### Calendar Denied

Copy:

```text
Calendar access is off. Plan still works manually.
```

Actions:

- `Keep Planning`
- `Review Access`

### Week Tight

Copy:

```text
This week can hold, but it is tighter than usual.
```

Actions:

- `Protect Priority`
- `Move Flexible Work`
- `Save Week`

### Week Broken

Copy:

```text
This week no longer holds without a change.
```

Actions:

- `Save the Week`
- `Make Lighter`
- `Move Work`

Rules:

- Broken is serious but not punitive.
- Always offer a recovery path.

## You / Trust / Memory States

### No Memory

Copy:

```text
Ambitions will show what it learns here after you confirm useful patterns.
```

Primary action:

```text
Add Preference
```

Rules:

- Do not claim memory exists before it does.
- Do not imply cloud memory unless implemented.

### Memory Needs Review

Copy:

```text
This may be based on older context.
```

Actions:

- `Update This`
- `Keep`
- `Delete`

### Export Failed

Copy:

```text
Export did not complete. Your Ambitions data is still local.
```

Actions:

- `Try Again`
- `Review Export`

## Archive States

### Empty Archive

Copy:

```text
Completed and ended goals will appear here as learning, not trash.
```

### Cancelled / Dropped Goal

Copy:

```text
This ended intentionally. The reason is preserved so future plans get smarter.
```

Actions:

- `Review`
- `Restore`
- `Open Decision Trail`

## Receipt Failure States

If an action partially succeeds:

```text
Saved locally. Calendar block was not created.
```

Actions:

- `Open Plan`
- `Try Calendar Again`

If an action is unsupported:

```text
This action is not available yet. Nothing changed.
```

Actions:

- `Keep Planning`

If action needs confirmation:

```text
This changes your calendar. Confirm before Ambitions writes it.
```

Actions:

- `Confirm`
- `Cancel`

## QA Acceptance Criteria

Every screen-level state must satisfy:

- no blank dead ends
- no shame language
- one clear next action
- safe fallback when data/permission fails
- preserved user input where relevant
- correction or route change where relevant
- receipt after meaningful change
- Dynamic Type support
- VoiceOver labels/values/hints
- no color-only meaning
- no hidden required gestures
- no unverified claims

## Open Questions For Future Waves

- Should the app use the word `Broken` for Plan state, or a softer label?
- Should Capture low-confidence choices be Task / Goal / Idea, or Task / Goal / Later?
- Should Today empty state emphasize Capture or Goal creation first?
- Which errors deserve inline treatment versus full-screen state?
- Should archived cancelled/dropped goals be recoverable by default?
