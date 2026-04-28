# Ambitions Plan, Calendar, And Believability

Status: Active canon consolidation layer.

Purpose: Consolidate Plan, calendar-aware planning, daily schedule, rituals, overload recovery, and believability decisions into one implementation-readable reference. This document reflects Wave 6 product decisions.

## Core Plan Doctrine

Plan is not a calendar clone. Plan is the Ambitions surface that shapes a believable day/week and builds the daily schedule needed to make goals executable.

Plan's core job:

```text
Shape a believable day/week.
Build the daily schedule as part of making goals executable.
```

Main Plan question:

```text
Can this week actually hold?
```

Supporting daily question:

```text
What daily schedule makes this hold?
```

Rules:

- Weekly believability is the main Plan question.
- Daily schedule construction is an important sub-job of Plan.
- Plan should show the truth when the week cannot hold.
- Plan should make goals executable without becoming a raw calendar UI.

## Plan Visual / IA Direction

Resolved direction:

```text
Plan-first with optional calendar awareness.
```

Plan should not look calendar-first at launch.

Rules:

- Calendar views can support Plan, but they do not own Plan.
- A weekly calendar view can come later if it serves believability and execution.
- Plan is not only a due-soon list.
- Plan is not only a daily schedule builder.
- Plan owns day/week shaping, capacity truth, rituals, and recovery.

## Calendar-Aware Meaning

Calendar-aware means Ambitions can:

```text
Read calendar events.
Suggest open windows.
Compare Ambitions plan against real commitments.
Write calendar events only after explicit user confirmation.
```

Rules:

- Calendar read permission is requested only from Plan after the user asks for calendar-aware planning.
- Calendar writes require confirmation every time.
- No silent calendar writes.
- Calendar-derived patterns require memory confirmation before becoming Memory.
- Calendar access improves Plan, but Plan must still work manually without access.

## Calendar Permission CTA

Primary CTA:

```text
Make Plan calendar-aware
```

Supporting phrase:

```text
Find real open windows
```

Avoid as primary CTA:

```text
Sync Calendar
```

Rationale:

- `Make Plan calendar-aware` explains the product value.
- `Find real open windows` explains the immediate use case.
- `Sync Calendar` sounds technical and can imply two-way syncing before the user understands the boundary.

## Calendar Write Boundary

Calendar write behavior:

```text
Only after user confirms each write.
```

Rules:

- Do not write to calendar automatically.
- Do not rely on broad automation enablement for silent writes.
- Calendar write confirmation should say what will be written and where.
- If calendar write fails, Plan should preserve the Ambitions plan and say the calendar block was not created.

Failure copy pattern:

```text
Saved locally. Calendar block was not created.
```

## Believability Definition

Believable means:

```text
Enough time exists.
It fits energy and context.
The user has done similar before where evidence exists.
It does not conflict with real commitments.
No fake precision.
```

Rules:

- Believability should be evidence-aware and correction-friendly.
- Believability should not use fake exact scoring unless a later verified model supports it.
- Believability should explain why the plan holds or does not hold.
- Believability should distinguish known evidence from assumptions.
- Believability is not just time math.

## Plan States

Internal states may use strong language. UI labels should be softer.

| Internal state | Preferred UI label | Meaning |
| --- | --- | --- |
| Believable | Believable | The plan appears to hold. |
| Tight | Tight | The plan can hold, but with pressure. |
| Fragile | Needs Protection | The plan is likely to break without change. |
| Broken | No Longer Holds | The plan no longer holds without a change. |

Rules:

- UI should generally render `Fragile` as `Needs Protection`.
- UI should generally render `Broken` as `No Longer Holds`.
- State language should be serious without being punitive.
- State changes should create receipts or review prompts when meaningful.

## Daily Schedule Role

Plan should build the daily schedule as part of making goals executable.

A useful daily schedule should:

- show what matters today
- protect the most important work
- account for known commitments where available
- include rituals/routines where useful
- show what can move when reality changes
- support recovery when the day no longer holds

Rules:

- Daily schedule is derived from goals, tasks, rituals, deadlines, capacity, and commitments.
- Daily schedule should not become a standalone calendar clone.
- Today consumes the current execution shape; Plan shapes and repairs it.

## Overload Behavior

When the week is overloaded, Plan should:

```text
Suggest a lighter plan.
Ask what to protect.
```

Rules:

- Do not only show a warning.
- Do not automatically move tasks.
- Do not pretend impossible weeks are fine.
- Recovery should stay non-shaming.
- Protecting priority should be explicit.

Recommended overload actions:

- `Make Lighter`
- `Protect Priority`
- `Move Flexible Work`
- `Park for Later`
- `Review Week`

## Rituals / Routines

Resolved direction:

```text
Plan includes rituals/routines, but not as a standalone Habits tab.
```

Rules:

- Rituals belong in Plan, Today, Goal Detail, and You/Reviews where useful.
- Do not recreate a standalone Habits tab.
- Rituals should support believable planning, not become streak pressure.
- Rituals should be adjustable without shame when the plan no longer holds.

## Plan Must Never

Plan must never:

```text
Shame the user.
Silently reschedule.
Pretend impossible weeks are fine.
Become a raw calendar clone.
```

Implementation red flags:

- Calendar permission requested during onboarding.
- Calendar write without explicit confirmation.
- Overload screen only warns and provides no recovery path.
- Plan uses exact believability percentages without verified basis.
- Plan hides conflicts to keep the UI optimistic.
- Plan turns into a due-date list.
- Plan rebuilds a standalone Habits tab.

## Trust And Memory Boundary

Calendar-derived patterns require confirmation before becoming Memory.

Rules:

- Calendar data can support planning decisions after permission.
- Calendar-derived memory must be confirmed.
- Calendar details should not be copied broadly into unrelated surfaces.
- Sensitive Life Area details should remain hidden in notifications/widgets and collapsed on Today.

## QA Acceptance Criteria

Plan is acceptable when:

- It answers `Can this week actually hold?`.
- It can build a daily schedule as part of making goals executable.
- It remains plan-first, not calendar-first.
- Calendar-aware planning can read events, suggest open windows, and compare against commitments where permission exists.
- Calendar writes require explicit confirmation every time.
- First calendar CTA uses `Make Plan calendar-aware` with `Find real open windows` as supporting phrase.
- Overload suggests a lighter plan and asks what to protect.
- Rituals/routines are supported without creating a standalone Habits tab.
- Believability considers time, energy/context, prior evidence where available, real commitments, and avoids fake precision.
- Plan does not shame, silently reschedule, pretend impossible weeks are fine, or become a raw calendar clone.

## Open Questions For Future Waves

- Should Plan default to day-first or week-first visual entry?
- Should daily schedule use blocks, list sections, or hybrid strips?
- How should Plan represent energy/context without feeling pseudoscientific?
- Should rituals be user-created only, suggested, or inferred from repeated plans?
- What exact confirmation copy should calendar writes use?
