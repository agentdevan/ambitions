# Ambitions Empty, Error, And Recovery States

Status: Active canon consolidation layer.

Purpose: Define product-wide state behavior so Ambitions feels polished outside the ideal path. This document expands the UX Writing Matrix into a screen-by-screen implementation reference and reflects product decision Waves 1-4.

## State Doctrine

Premium product quality shows up when nothing exists, something fails, or life drifts.

Every non-ideal state should answer:

1. What happened?
2. What remains safe or true?
3. What is the next useful action?
4. Can the user correct, retry, recover, or move on?

## Wave 2 State Language Rules

- Internal `Dropped` should render as `No Longer Relevant` in normal UI.
- Cancelled and Dropped are internally separate, but launch UI may simplify.
- Intentional ending action: `End Goal`, then ask reason.
- Pause action: `Park Goal`; state is `Parked`.
- Goal Weather is corrected through inputs, not direct manual override.
- UI Plan labels should prefer `Believable`, `Tight`, `Needs Protection`, and `No Longer Holds`.
- Destructive actions, external writes, and major deadline changes require confirmation.
- Reversible local changes should prefer receipt + undo.
- Product/design language is `Completion Archive`; normal UI language is `Archive`.

## Wave 3 Trust / Memory State Rules

- Low-risk memories may be auto-created with visibility.
- Sensitive/high-impact memories should be suggested for confirmation first.
- Health, relationship/family, financial, location, calendar-derived, and sensitive Life Area memories require confirmation.
- Users can pause memory learning globally and by category.
- User can mark any Life Area sensitive.
- Sensitive launch behavior: hide details in notifications/widgets, collapse details on Today, and use generic labels such as `Private item`.
- No numerical Trust Score at launch.
- Trust Center top status: `You are in control`.
- User-facing memory section: `What Ambitions Knows`.
- Object/type name: `Memory`.
- Delete all memory requires confirmation and export/reminder first.

## Wave 4 Onboarding State Rules

- Onboarding shows a static premium preview at launch; animation can come later.
- First prompt: `What do you want to organize?`
- First object creation shows the receipt inside the destination.
- Display density is not asked during onboarding; default is `Balanced + Comfortable`.
- Life Area is inferred when possible and asked only when uncertain.
- Notifications are requested only after reminder/protected-block value.
- Calendar access is requested only from Plan after calendar-aware planning action.
- If onboarding is skipped, land in Today with a strong empty state and Capture action.
- First-run success metric is any useful object created.

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
- broken as normal user-facing plan copy
- dropped as normal user-facing goal copy
- AI/model language
- fake certainty
- marketing claims
- blame
- numerical Trust Score language at launch

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
| Onboarding | Static preview + first prompt | Preserve input and allow retry/skip | Uncertain route or Life Area | Organize This / Skip |
| Today | No planned work yet; explain that Today gets useful after one object exists | Could not load current plan; local data remains safe | Day drifted, no open window, overloaded, missed protected item, sensitive item collapsed | Capture Something / Save the Day |
| Goals | No active goals; invite first meaningful goal or Life Area | Could not load goals; existing local data remains safe | Goal stale, blocked, waiting, or no Next Visible Step | Add Goal / Review Goal |
| Goal Detail | Goal has no plan/proof/steps yet | Could not load detail; goal remains available from Goals | Goal at risk, blocked, scope too large, deadline no longer believable | Add First Step / Replan |
| Capture | Nothing needs a place | Could not save capture; preserve user input | Low-confidence route, needs clarification, failed attachment | Save / Change Route |
| Plan | No plan created yet | Calendar unavailable, plan still works manually | Week tight, needs protection, no longer holds, overloaded, conflict detected | Shape Week / Save the Week |
| You | No reviews/memory/history yet | Could not load settings/memory; core app remains usable | Memory may need review, trust item needs correction | Review Memory / Open Trust Center |
| Trust Center | No receipts or trust issues yet; top status says You are in control | Could not load trust history; privacy controls remain available | Memory stale, sync/export failed, permission denied, learning paused | Inspect / Correct |
| What Ambitions Knows | No memories yet | Could not load memory; no new memory applied | Memory stale, contradicted by correction, needs confirmation, learning paused | Add Preference / Review |
| Reviews | No reviews yet | Could not build review; historical data remains safe | Carryover, drift, correction, plan no longer holds | Start Review |
| Archive | No archived learning yet | Could not load archive; active work unaffected | Restore, inspect, or learn from ended/no-longer-relevant item | Open Item / Restore |

## Onboarding States

### Static Preview

Copy:

```text
Organize what matters. Know what to do next.
```

Primary action:

```text
Start
```

Rules:

- Static premium preview at launch.
- No animation requirement.
- Do not request permissions here.
- VoiceOver must describe the preview meaningfully.

### First Prompt

Copy:

```text
What do you want to organize?
```

Primary action:

```text
Organize This
```

Rules:

- User can create any useful object.
- First-run success is not limited to Goal creation.

### Onboarding Save Failed

Copy:

```text
This did not save. Your text is still here.
```

Actions:

- `Try Again`
- `Skip for Now`

Rules:

- Preserve input.
- Never discard first-run text.

### Onboarding Route Receipt

Copy pattern:

```text
Saved as Goal · Creative
Next: Shape the first milestone
Change
```

Rules:

- Receipt appears inside the destination.
- Life Area is correctable from receipt.
- Do not show detached confirmation interstitial.

### Skipped Onboarding

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
Use Example
```

Rules:

- Land in Today.
- Strong empty state with Capture action.
- No permission prompt.

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

### Sensitive Item Collapsed

Copy:

```text
Private item
```

Supporting copy:

```text
Details are hidden here.
```

Actions:

- `Open`
- `Privacy`

Rules:

- Use this for sensitive Life Areas on Today at launch.
- Do not expose sensitive details in compact summaries.
- Do not claim Face ID/screenshot hiding/export exclusion until implemented and verified.

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

### Goal Ended

Copy:

```text
This goal ended intentionally. The reason is preserved so future plans get smarter.
```

Actions:

- `Review`
- `Open Decision Trail`
- `Restore`

Rules:

- Use `End Goal` as the action before this state.
- Ask for reason before finalizing when practical.
- Preserve proof, decision trail, and learning.

### Goal No Longer Relevant

Copy:

```text
This is no longer relevant. Ambitions will keep what was learned.
```

Actions:

- `Review`
- `Open Decision Trail`
- `Archive`

Rules:

- Use `No Longer Relevant` in UI instead of `Dropped`.
- Avoid judgmental wording.

### Goal Parked

Copy:

```text
This is parked for later.
```

Actions:

- `Resume`
- `Review`
- `Archive`

Rules:

- Parked means intentionally paused.
- Parked does not mean failed.

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

### Calendar Pattern Memory Needs Confirmation

Copy:

```text
Ambitions noticed a calendar pattern. Confirm before it becomes memory.
```

Actions:

- `Confirm`
- `Not Now`
- `What This Uses`

Rules:

- Calendar-derived patterns require confirmation before becoming memory.
- Explain how it will be used.

### Week Tight

Copy:

```text
This week can hold, but it is tighter than usual.
```

Actions:

- `Protect Priority`
- `Move Flexible Work`
- `Save Week`

### Week Needs Protection

Copy:

```text
This week needs protection to hold.
```

Actions:

- `Protect Priority`
- `Move Flexible Work`
- `Make Lighter`

Rules:

- This is the normal UI label for internal `fragile`.
- Do not overuse alarm language.

### Week No Longer Holds

Copy:

```text
This week no longer holds without a change.
```

Actions:

- `Save the Week`
- `Make Lighter`
- `Move Work`

Rules:

- This is the normal UI label for internal `broken`.
- Serious but not punitive.
- Always offer a recovery path.

## You / Trust / Memory States

### Trust Center Top State

Copy:

```text
You are in control.
```

Supporting rows:

- Memory
- Receipts
- Privacy
- Calendar access
- Sync / Export
- Accessibility verification

Rules:

- Do not use a numerical Trust Score at launch.
- Use qualitative status sections.

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

- Section is `What Ambitions Knows`.
- Object/type is `Memory`.
- Do not claim memory exists before it does.
- Do not imply cloud memory unless implemented.

### Memory Suggestion Needs Confirmation

Copy:

```text
Ambitions noticed something that may help future plans.
```

Actions:

- `Confirm`
- `Not Now`
- `What This Uses`

Rules:

- Use for sensitive/high-impact memory suggestions.
- Required for health, relationship/family, financial, location, calendar-derived, and sensitive Life Area details.
- Explain what was noticed and how it would be used.

### Memory Learning Paused

Copy:

```text
Memory learning is paused.
```

Actions:

- `Resume`
- `Review Existing Memory`

Rules:

- Pausing memory learning does not delete existing memory.
- Support global and category-level states where implemented.

### Memory Needs Review

Copy:

```text
This may be based on older context.
```

Actions:

- `Update This`
- `Keep`
- `Delete`

Rules:

- `Delete` requires confirmation.

### Delete All Memory

Copy:

```text
This removes what Ambitions remembers about you. Your goals, tasks, and plans stay unless you delete them separately.
```

Actions:

- `Export First` where export exists
- `Delete Memory`
- `Cancel`

Rules:

- Requires confirmation.
- Offer export/reminder first where export exists.
- If export is unavailable, say so plainly.

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

### Completed Goal In Archive

Copy:

```text
This was completed. The proof and final review are preserved here.
```

Rules:

- Completed goals remain visibly emphasized for 30 days by default before archive emphasis changes.
- Major goals may remain emphasized longer.

### Ended / No Longer Relevant Goal

Copy:

```text
This ended. The reason is preserved so future plans get smarter.
```

Actions:

- `Review`
- `Restore`
- `Open Decision Trail`

Rules:

- Use `Archive` in normal UI.
- Use `Completion Archive` in product/design docs when describing the full system.

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

If export is unavailable before delete-all-memory:

```text
Export is not available yet. You can still delete memory after confirmation.
```

Actions:

- `Delete Memory`
- `Cancel`

## Confirmation vs Receipt Rules

Receipt + undo first:

- Mark Done.
- Move task.
- Park task.
- Attach task to goal.
- Rename Life Area.
- Change display density.

Confirmation required:

- Delete memory.
- Delete all memory.
- Calendar write.
- Major deadline changes.
- Destructive actions.
- External writes.
- Sensitive/high-impact memory creation.

Undo duration policy:

- Quick UI actions: 5-10 seconds.
- Route changes / attach / move: until screen exit or review tray dismissal.
- Rename/display changes: 30 seconds.
- Destructive/external writes: confirmation first, undo only if platform-safe.

## QA Acceptance Criteria

Every screen-level state must satisfy:

- no blank dead ends
- no shame language
- one clear next action
- safe fallback when data/permission fails
- preserved user input where relevant
- correction or route change where relevant
- receipt after meaningful change
- receipt appears inside destination for first-run object creation
- no onboarding permission prompts
- skipped onboarding lands in Today with Capture action
- confirmation for destructive/external/major deadline changes
- confirmation for sensitive/high-impact memory creation
- receipt + undo for reversible local changes where safe
- action-appropriate undo duration
- sensitive Life Area details hidden/collapsed in launch surfaces
- no numerical Trust Score at launch
- Dynamic Type support
- VoiceOver labels/values/hints
- no color-only meaning
- no hidden required gestures
- no unverified claims

## Resolved Wave 2 Questions

- Internal `Dropped` renders as `No Longer Relevant` in normal UI.
- Cancelled and Dropped remain internally separate; launch UI may simplify.
- Intentional goal ending action is `End Goal`, followed by a reason.
- Intentional pause action is `Park Goal`; state is Parked.
- Goal Weather is corrected through inputs, not direct manual override.
- UI Plan labels should use `Needs Protection` and `No Longer Holds` instead of exposing `Fragile`/`Broken` by default.
- Destructive actions, external writes, and major deadline changes require confirmation.
- Mark Done, Move task, Park task, Attach task to goal, Rename Life Area, and Change display density prefer receipt + undo.
- Completed goals stay visibly emphasized for 30 days by default; major goals may remain emphasized longer.
- Product/design language is Completion Archive; normal UI language is Archive.

## Resolved Wave 3 Questions

- Low-risk memories can be auto-created with visibility; sensitive/high-impact memories are suggested for confirmation first.
- Health, relationship/family, financial, location, calendar-derived, and sensitive Life Area memories require confirmation.
- Display/density preferences, recovery preferences, and repeated task routing can auto-create with receipt/visibility.
- Work/career memory is contextual.
- Users can pause memory learning globally and by category.
- User can mark any Life Area sensitive.
- Sensitive launch behavior: hide details in notifications/widgets, collapse details on Today, generic `Private item` labels.
- Advanced sensitive behavior later: Face ID, export exclusion, local-only enforcement, screenshot hiding.
- Undo duration depends on action type.
- No numerical Trust Score at launch; use qualitative status sections.
- Trust Center top status is `You are in control`.
- User-facing memory section is `What Ambitions Knows`; object/type name is `Memory`.
- Users can delete all memory from Trust Center with confirmation and export/reminder first.

## Resolved Wave 4 Questions

- Static premium product preview at launch; animation later.
- First prompt: `What do you want to organize?`
- First object creation shows receipt inside destination.
- Display density is not asked during onboarding; default is Balanced + Comfortable.
- Life Area is inferred when possible and asked only when uncertain.
- Notifications are requested only after reminder/protected-block value.
- Calendar access is requested only from Plan after calendar-aware planning action.
- Default examples cover Career, Creative, Finance, Health, Home, and Relationships / Family.
- Baby/family examples can appear later when contextually relevant.
- Skipping onboarding lands in Today with strong empty state and Capture action.
- First-run success metric is any useful object created.

## Open Questions For Future Waves

- Should Capture low-confidence choices be Task / Goal / Idea, or Task / Goal / Later?
- Which errors deserve inline treatment versus full-screen state?
- Should archived ended/no-longer-relevant goals be recoverable by default?
- Should memory suggestions appear as receipts, review cards, or Trust Center prompts?
- Should the static onboarding preview show Today, Goal Detail, or Plan?
