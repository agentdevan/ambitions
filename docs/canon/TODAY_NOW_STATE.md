# Ambitions Today And Now State

Status: Active canon consolidation layer.

Purpose: Consolidate Today, Now State, recommended step, current/next schedule, rituals, recovery, empty state, and sensitive-item behavior into one implementation-readable reference. This document reflects Wave 8 product decisions plus the post-canon human-language correction layer in `HUMAN_LANGUAGE_REVIEW.md` and the v2 master direction in `Ambitions_Master_Product_Visual_System_Spec_v2.md`.

## Core Today Doctrine

Today exists to help the user know what matters now.

Core job:

```text
Help the user know what matters now.
```

Internal/product concept:

```text
One recommended step.
```

Preferred normal UI copy:

```text
Start here.
```

Today is not:

- a task dump
- a calendar clone
- an analytics dashboard
- a motivation quote wall
- a generic reminders list

## Today Priority Order

Recommended top-level priority:

1. `Start here` / one recommended step.
2. Plain explanation: `Why this now`.
3. Current or next schedule slice.
4. Full daily schedule below the main action.
5. Relevant rituals/routines if they matter now.
6. Recovery affordance when the day no longer works.
7. Capture action for empty or uncertain states.

Rules:

- The full daily schedule can appear, but it should not outrank the next thing to do.
- Today should not lead with a long task list.
- Today should not expose full analytics.
- Today should use the plainest language in the app.

## Human Language Rule For Today

Today must sound like a calm person helping the user decide what still matters.

Use:

```text
Start here.
Recommended step.
Most important today.
Too much for today.
Make today doable.
Adjust plan.
Keep this on today.
What should stay on today?
If there is time.
Nothing moved automatically.
```

Avoid normal UI copy such as:

```text
Best Next Action.
Protected.
Protection.
Protect this.
Protect later.
Today’s anchor.
Execution context.
Optimize.
AI.
Model.
Confidence.
```

Internal docs may still use terms such as Best Next Action or Now State when describing systems. Normal UI should translate them into plain language.

## Full Daily Schedule Behavior

Resolved direction:

```text
Show the full daily schedule below the main action.
```

Rules:

- The daily schedule supports action clarity.
- The daily schedule should stay secondary to the current/next decision.
- Plan shapes the schedule; Today shows what helps right now.
- Schedule display should not become a raw calendar clone.

## Now State Meaning

Internal concept:

```text
Best current execution context.
```

Preferred normal UI copy:

```text
Right now.
Why this now.
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

- Now State should help explain why this next action is shown.
- Now State should be explainable through plain language.
- Avoid fake precision.
- Avoid mood inference unless explicitly supported by user input or future verified feature.
- Do not expose `execution context` as normal UI copy.

## Broken Day / Recovery Behavior

When the day breaks, Today should:

```text
Offer recovery.
Ask what should stay on today.
```

Main recovery action:

```text
Save the Day
```

Preferred plain recovery CTA:

```text
Make today doable
```

Rules:

- Do not only warn.
- Do not auto-reschedule.
- Do not hide missed work.
- Keep recovery non-shaming.
- Recovery should explain what changed, what no longer fits, and what can still fit.
- Do not use `protect/protected/protection` language unless the feature is literally about privacy or security.

Recommended recovery copy:

```text
Too much for today.
Pick what still needs to happen, and move the rest later.
```

Recommended recovery actions:

- `Make today doable`
- `Adjust plan`
- `Keep this on today`
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

## Do This Next

The next-action area should answer:

- What matters now?
- Why this, not everything else?
- What is the smallest useful next step?
- What happens if the day no longer works?

Rules:

- The next action should be one dominant recommendation or action.
- Alternatives can exist below, but should not dilute the main decision.
- The user should be able to inspect `Why This` or similar explanation.
- Sensitive items should respect private-item behavior.
- Normal UI should say `Start here` and `Recommended step`, not `Best Next Action`.

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
- One next action is prioritized first.
- Normal UI says `Start here`, `Recommended step`, or equivalent plain copy.
- Full daily schedule appears below the main action, not above it.
- Broken-day behavior offers recovery and asks what should stay on today.
- Recovery uses plain copy such as `Too much for today` and `Make today doable`.
- `protect/protected/protection`, `anchor`, `execution context`, `AI`, `model`, and `confidence` do not appear in normal Today UI copy.
- Main recovery concept remains `Save the Day`, but supporting copy stays human and obvious.
- Rituals/routines appear only if relevant now.
- Sensitive/private items collapse as `Private item` at launch.
- Empty Today asks user to capture something, with goal suggestion secondary.
- Now State remains an internal concept for best current execution context and appears to users as plain `Right now` / `Why this now` copy.
- Today does not become a task dump, calendar clone, analytics dashboard, or motivation quote wall.

## Open Questions For Future Waves

- What exact card design should the next-action area use?
- Should Today show one recovery rail or a compact recovery sheet?
- How much of the daily schedule should be visible above the fold?
- Should Now State have named labels, or stay descriptive and contextual?
- Should Today show goal portfolio signals only when they affect now?
