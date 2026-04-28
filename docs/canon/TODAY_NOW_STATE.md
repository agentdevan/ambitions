# Ambitions Today And Now State

Status: Active canon consolidation layer.

Purpose: Consolidate Today, Now State, best next action, current/next schedule, rituals, recovery, empty state, and sensitive-item behavior into one implementation-readable reference. This document reflects Wave 8 product decisions.

## Core Today Doctrine

Today exists to help the user know what matters now.

Core job:

```text
Help the user know what matters now.
```

Today should prioritize first:

```text
One best next action.
```

Today is not:

- a task dump
- a calendar clone
- an analytics dashboard
- a motivation quote wall
- a generic reminders list

## Today Priority Order

Recommended top-level priority:

1. Best Next Action.
2. Why this matters now / Now State explanation.
3. Current or next schedule slice.
4. Full daily schedule below the main next action.
5. Relevant rituals/routines if they matter now.
6. Recovery affordance when the day no longer holds.
7. Capture action for empty or uncertain states.

Rules:

- The full daily schedule can appear, but it should not outrank the best next action.
- Today should not lead with a long task list.
- Today should not expose full analytics.

## Full Daily Schedule Behavior

Resolved direction:

```text
Show the full daily schedule below the main next action.
```

Rules:

- The daily schedule supports action clarity.
- The daily schedule should stay secondary to the current/next decision.
- Plan shapes the schedule; Today consumes the current execution shape.
- Schedule display should not become a raw calendar clone.

## Now State Meaning

Now State means:

```text
Best current execution context.
```

Now State is not only:

- current task
- time of day
- user mood
- calendar status

Now State should combine relevant signals from:

- goals
- plan
- daily schedule
- tasks
- rituals/routines
- commitments
- blockers/waiting items
- recovery state
- sensitive/privacy rules

Rules:

- Now State should help explain why the best next action is shown.
- Now State should be explainable through plain language.
- Avoid fake precision.
- Avoid mood inference unless explicitly supported by user input or future verified feature.

## Broken Day / Recovery Behavior

When the day breaks, Today should:

```text
Offer recovery.
Ask what to protect.
```

Main recovery action:

```text
Save the Day
```

Rules:

- Do not only warn.
- Do not auto-reschedule.
- Do not hide missed work.
- Keep recovery non-shaming.
- Recovery should explain what changed, what is at risk, and what can still fit.

Recommended recovery actions:

- `Save the Day`
- `Make Lighter`
- `Protect This`
- `Move This`
- `Park`
- `Open Plan`

## Rituals / Routines In Today

Resolved direction:

```text
Today includes rituals/routines only if relevant now.
```

Rules:

- Rituals can appear in Today when they affect the current/next slice.
- Today should not become a habit tracker or routine dashboard.
- Rituals should support execution, not streak pressure.
- Rituals that are not relevant now belong in Plan, Goal Detail, or You/Reviews.

## Sensitive / Private Items In Today

Resolved launch behavior:

```text
Sensitive/private items collapse as Private item.
```

Rules:

- Do not expose sensitive Life Area details in Today compact surfaces.
- Do not require Face ID at launch unless implemented and verified.
- Use generic labels such as `Private item` for compact sensitive summaries.
- Offer a privacy route where appropriate.

## Empty Today

When there is nothing planned, Today should:

```text
Ask user to capture something.
Suggest a goal.
```

Priority:

```text
Capture is primary.
Goal suggestion is secondary.
```

Recommended copy:

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

- Do not show an empty dashboard.
- Do not show a motivational quote wall.
- Do not imply the user is behind.
- If user skipped onboarding, land in Today with this empty state and Capture action.

## Best Next Action

Best Next Action should answer:

- What matters now?
- Why this, not everything else?
- What is the smallest useful next move?
- What happens if the day no longer holds?

Rules:

- Best Next Action should be one dominant recommendation or action.
- Alternatives can exist below, but should not dilute the main decision.
- The user should be able to inspect `Why This` or similar explanation.
- Sensitive items should respect private-item behavior.

## Today Must Never Become

Today must never become:

```text
Task dump.
Calendar clone.
Analytics dashboard.
Motivation quote wall.
```

## QA Acceptance Criteria

Today / Now State is acceptable when:

- Today helps the user know what matters now.
- One best next action is prioritized first.
- Full daily schedule appears below the main next action, not above it.
- Broken day behavior offers recovery and asks what to protect.
- Main recovery action is `Save the Day`.
- Rituals/routines appear only if relevant now.
- Sensitive/private items collapse as `Private item` at launch.
- Empty Today asks user to capture something, with goal suggestion secondary.
- Now State means best current execution context.
- Now State does not collapse to only current task, time of day, mood, or calendar status.
- Today does not become a task dump, calendar clone, analytics dashboard, or motivation quote wall.

## Open Questions For Future Waves

- What exact card design should Best Next Action use?
- Should Today show one recovery rail or a compact recovery sheet?
- How much of the daily schedule should be visible above the fold?
- Should Now State have named labels, or stay descriptive and contextual?
- Should Today show goal portfolio signals only when they affect now?
