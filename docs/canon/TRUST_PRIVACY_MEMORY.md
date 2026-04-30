# Ambitions Trust, Privacy, And Memory

Status: Active canon consolidation layer.

Purpose: Make trust, privacy, memory, receipts, explanation, correction, and user control explicit enough for implementation and QA. This document extracts existing doctrine from the Design Constitution, Product Architecture, Systems Architecture, Intelligence Standards, UX Writing Matrix, and product decision Waves 1-3.

## Trust Thesis

Trust is not a settings page. Trust is a product behavior.

```text
Trust = privacy + explanation + correction + receipts + user control.
```

Ambitions is intended to organize a person's life. That requires a higher trust bar than a generic productivity app.

## Wave 2 Trust Decisions

Confirmation required:

```text
Destructive actions
External writes
Major deadline changes
Delete memory
Calendar write
```

Receipt + undo first:

```text
Mark Done
Move task
Park task
Attach task to goal
Rename Life Area
Change display density
```

Goal and archive language:

```text
End Goal = intentional ending action, followed by reason.
Park Goal = intentional pause action.
Dropped internal state = No Longer Relevant in normal UI.
Completion Archive = product/design language.
Archive = normal UI language.
```

## Wave 3 Trust Decisions

Memory creation:

```text
Low-risk memories may be auto-created with visibility.
Sensitive or high-impact memories should be suggested for user confirmation first.
```

Memory confirmation required:

```text
Health-related preferences
Relationship/family details
Financial goals or constraints
Location patterns
Calendar-derived patterns
Sensitive Life Area details
```

Can auto-create with receipt/visibility:

```text
Display/density preferences
Recovery preferences
Repeated task routing
```

Contextual:

```text
Work/career goals
```

Memory controls:

```text
Users can pause memory learning globally and by category.
Users can delete all memory from Trust Center with confirmation and export/reminder first.
```

Sensitive Life Areas:

```text
User can mark any Life Area sensitive.
Launch behavior: hide details in notifications/widgets, collapse details on Today, and use generic labels like Private item.
Later/advanced behavior: Face ID, export exclusion, local-only enforcement, screenshot hiding.
```

Trust Center:

```text
No numerical Trust Score at launch.
Use qualitative status sections.
Top status: You are in control.
User-facing memory section: What Ambitions Knows.
Object/type name: Memory.
```

Undo:

```text
Undo duration depends on action type.
Quick UI actions: 5-10 seconds.
Route changes / attach / move: until screen exit or review tray dismissal.
Rename/display changes: 30 seconds.
Destructive/external writes: confirmation first, undo only if platform-safe.
```

## Trust Principles

1. The user can see what Ambitions knows.
2. The user can correct what Ambitions got wrong.
3. The user can delete or hide sensitive memory where supported.
4. The user can pause memory learning globally and by category.
5. Meaningful changes close with receipts.
6. Recommendations explain evidence and assumptions.
7. External writes require explicit confirmation.
8. Destructive actions and major deadline changes require confirmation.
9. Reversible local changes prefer receipt + undo.
10. Permissions are requested only when a user action makes the value clear.
11. Planned intelligence is never described as shipped behavior.
12. Ambitions is an intelligent product, not a chat-first AI product.
13. Trust-critical states degrade safely.
14. No numerical Trust Score at launch; trust uses qualitative status sections.

## Primary Trust Surfaces

| Surface | Trust role |
| --- | --- |
| Contextual panels | Explain why an action, route, or recommendation appears. |
| Receipt / Action Closure Tray | Shows what happened, what changed, why, undo/correction, and source. |
| You -> Trust Center | Main control center for explanation, privacy, receipts, sync/export status, safe automation, and platform surface truth. Top status: `You are in control.` |
| You -> What Ambitions Knows | Main user-facing memory surface. |
| You -> Reviews | Shows what changed, what was learned, and what should be corrected or carried forward. |
| Capture receipts | Shows where items went and how to change route. |
| Plan permission panels | Explain calendar access and no-permission fallback. |
| Archive / Completion Archive | Preserves learning from completed, ended, no-longer-relevant, merged, replaced, or parked work. |

## Memory Model

Memory is user-visible remembered context that can shape future recommendations only when evidence-backed and correctable.

Section name:

```text
What Ambitions Knows
```

Object/type name:

```text
Memory
```

Memory types:

- explicit user preference
- recurring pattern
- domain/life-area preference
- schedule/capacity signal
- recovery preference
- route correction
- ignored suggestion pattern
- completed review learning
- trust/safety preference
- display/density/accessibility preference
- sensitive Life Area flag
- memory learning control

Memory required fields:

- `id`
- `memoryType`
- `summary`
- `source`
- `freshnessState`
- `confidenceState`
- `createdAt`
- `updatedAt`

Recommended fields:

- `evidenceIds`
- `relatedObjectIds`
- `correctionHistoryIds`
- `privacyLevel`
- `requiresConfirmation`
- `isConfirmed`
- `categoryLearningPaused`
- `reviewedAt?`
- `expiresAt?`

## Memory Creation Policy

Low-risk memories may be auto-created when they remain visible and correctable.

Auto-create with receipt/visibility:

- display/density preferences
- recovery preferences
- repeated task routing

Require explicit confirmation before memory use:

- health-related preferences
- relationship/family details
- financial goals or constraints
- location patterns
- calendar-derived patterns
- sensitive Life Area details

Contextual memory:

- work/career goals can be auto-created only when low-risk and obvious
- request confirmation when work/career memory affects priority, planning, identity, or sensitive context

Rules:

- Ambitions should not silently build a large hidden profile.
- Sensitive or high-impact memory should be suggested for confirmation first.
- Calendar-derived patterns require confirmation before becoming memory.
- Memory suggestions should explain what was noticed and how it would be used.

## Memory Freshness

User-facing freshness labels:

- `Current`
- `May Need Review`
- `Based on Older Context`

Rules:

- Older context should not appear equally trusted to current confirmed context.
- Important memories should have a review path.
- Memory correction should generate a receipt.
- Memory deletion requires confirmation.

## Memory Confidence

Recommended internal states:

- `confirmed`
- `inferred`
- `uncertain`
- `stale`
- `corrected`
- `deleted`

User-facing copy should not say `model confidence`. Use plain explanation:

- `You told Ambitions this.`
- `Based on recent choices.`
- `This may need review.`
- `Updated from your correction.`

## Memory Learning Controls

Users can pause memory learning globally and by category.

Rules:

- Pausing memory learning should not delete existing memory.
- Global pause belongs in Trust Center.
- Per-category controls belong in What Ambitions Knows or a Memory Settings route.
- Existing memory should remain inspectable, correctable, and deletable while learning is paused.
- Resuming learning should be explicit.

## What Ambitions Knows

`You -> What Ambitions Knows` should show memory categories with freshness and correction controls.

Required categories:

- Preferences
- Goals and Life Areas
- Planning patterns
- Recovery preferences
- Repeated routes / corrections
- Display and focus preferences
- Trust and privacy choices
- Sensitive areas
- Memory learning controls

Each memory category should support:

- inspect
- correct
- delete where safe
- review source/evidence where useful
- pause/resume learning for that category where implemented

Rules:

- Correcting memory should create a receipt.
- Deleting memory requires confirmation.
- Deleting all memory requires confirmation and export/reminder first.
- If export is not implemented, say so plainly and provide the safest available confirmation path.
- Delete all memory should not delete goals/tasks/plans unless explicitly included in a separate destructive action.
- Display/density preference changes should prefer receipt + undo.

## Receipts

Receipts are trust objects, not disposable toast messages.

Receipt anatomy:

- What happened.
- What changed.
- Why it changed.
- Undo if safe.
- Correction if relevant.
- Timestamp/source when useful.

Receipt result states:

- created
- changed
- scheduled
- moved
- attached
- exported
- drafted / prepared
- completed
- failed safely
- needs confirmation
- undo available

Receipt + undo first:

- Mark Done.
- Move task.
- Park task.
- Attach task to goal.
- Rename Life Area.
- Change display density.

Confirmation required instead:

- Delete memory.
- Delete all memory.
- Calendar write.
- Major deadline changes.
- Destructive actions.
- External writes.

Undo duration by action type:

- Quick UI actions: 5-10 seconds.
- Route changes / attach / move: until screen exit or review tray dismissal.
- Rename/display changes: 30 seconds.
- Destructive/external writes: confirmation first, undo only if platform-safe.

Receipt rules:

- Meaningful commands should produce a receipt.
- Sensitive receipts hide details by default.
- Receipts should be searchable later.
- Unsuccessful actions should say what remains safe.
- Undo availability must be truthful.
- Correction is not the same as undo.
- Do not over-confirm ordinary reversible local actions.

## Explanation Model

User-facing labels:

- `Why This`
- `Why Now`
- `Why Changed`
- `What This Uses`
- `Needs Confirmation`
- `Update This`

Avoid:

- `AI Explanation`
- `AI Confidence`
- `Model Reasoning`
- `Fix AI`

Every explanation should distinguish:

- evidence from user input
- evidence from actions/reviews
- calendar-derived context when permission exists
- assumptions
- defaults
- uncertainty
- correction path

Goal Weather rule:

- Users should correct inputs that affect Goal Weather rather than manually setting weather directly.
- Inputs include deadline, proof, blocker, next step, scope, waiting state, and assumptions.

Memory suggestion rule:

- Sensitive or high-impact memory suggestions must explain what Ambitions noticed, how it would be used, and how to decline.

## Privacy Levels

Recommended privacy states:

- `standard`
- `sensitive summary`
- `hidden details`
- `private object`
- `external-source derived`
- `exportable`
- `excluded from export`

Rules:

- Sensitive details should not appear in notifications/widgets by default.
- Calendar-derived data should be summarized for planning decisions, not copied broadly.
- External data labels must distinguish `From your calendar`, `Created in Ambitions`, and `Based on your plan`.
- Sync/export status must be truthful.
- User-facing privacy claims require implementation evidence.

## Sensitive Life Areas

User can mark any Life Area sensitive.

Launch behavior:

- hide details in notifications/widgets
- collapse details on Today
- use generic labels such as `Private item`

Later/advanced behavior:

- require Face ID to open
- exclude from export by default
- keep local-only
- hide from screenshots/previews

Rules:

- Sensitivity applies to default, renamed, and custom Life Areas.
- Do not claim Face ID, export exclusion, local-only enforcement, or screenshot hiding until implemented and verified.
- Sensitive mode should affect external surfaces and compact summaries.

## Permission Trust

### Calendar

- Plan owns calendar permission.
- Calendar read permission is requested only after explicit Plan action.
- Calendar write requires explicit confirmation.
- Calendar-derived patterns require confirmation before becoming memory.
- Plan works without calendar access.
- Denied permission should degrade gracefully.

Allowed triggers:

- `Make Plan calendar-aware`
- `Find real open windows`

### Notifications

- Sparse by default.
- Privacy-safe by default.
- Operational, calm, and specific.
- Request only after user chooses reminder/notification value.
- Sensitive Life Area details should be hidden by default.

### Sync / Export

- Local-first behavior must remain clear.
- Export/import receipts should explain what changed.
- Sync unavailable or unverified states must be explicit.
- Delete all memory should offer export/reminder first where export exists.

## Safe Automation Boundary

Ambitions may:

- suggest
- prepare
- explain
- ask for confirmation
- execute confirmed safe local actions

Ambitions must not silently:

- change important deadlines
- move calendar blocks externally
- delete memory
- rewrite goals/plans
- send/share/export personal information
- claim learning without evidence
- hide uncertainty
- create sensitive/high-impact memory without confirmation

Automation levels:

- Level 0: deterministic rules
- Level 1: local pattern summaries
- Level 2: user-confirmed learning
- Level 3: optional AI-assisted drafting/explanation
- Level 4: external knowledge/provider-backed suggestions
- Level 5: automation with explicit confirmation only

## Trust Center Structure

Top status:

```text
You are in control.
```

Trust status style:

```text
No numerical Trust Score at launch. Use qualitative status sections.
```

Recommended Grouped Navigation List sections:

### Understanding

- Why This / Explanations
- Receipts
- Decision Trail
- What Changed

### Memory

- What Ambitions Knows
- Memory Review
- Corrections
- Freshness
- Pause Memory Learning
- Delete All Memory

### Privacy

- Sensitive Details
- Sensitive Life Areas
- Calendar Data
- Notifications Privacy
- Export Data

### Control

- Safe Automation Boundary
- Confirmations
- Undo / Recovery
- Delete / Reset

### Platform Status

- Sync / Export
- Widgets
- Live Activities
- App Intents
- Calendar Access
- Accessibility Verification

## Goal Ending And Archive Trust

User-facing actions:

```text
End Goal
Park Goal
Archive
```

Rules:

- `End Goal` should ask the reason before finalizing when practical.
- Ended goals preserve proof, decision trail, and learning.
- Internal `dropped` should render as `No Longer Relevant` in normal UI.
- Completed goals remain visibly emphasized for 30 days by default; major goals may stay emphasized longer.
- Product/design docs may say `Completion Archive`; normal UI should usually say `Archive`.
- Archive is not trash.

## Failure And Degraded Trust States

If something fails, the app should say:

1. what happened
2. what remains safe
3. what the user can do next

Examples:

```text
Calendar access is unavailable. Plan still works manually.
```

```text
This was saved locally, but export did not complete.
```

```text
Ambitions is not sure where this belongs. It is saved to Needs a Place.
```

```text
Export is not available yet. You can still delete memory after confirmation.
```

## QA Acceptance Criteria

Trust implementation is acceptable when:

- User can inspect and correct memory.
- Low-risk memories are visible and correctable.
- Sensitive/high-impact memories require confirmation before use.
- User can pause memory learning globally and by category where implemented.
- User can mark any Life Area sensitive.
- Sensitive Life Area details hide in notifications/widgets and collapse on Today at launch.
- Trust Center uses `You are in control` and qualitative status sections, not a numerical Trust Score.
- Meaningful actions create receipts.
- Reversible local actions prefer receipt + undo.
- Undo duration is action-appropriate and truthfully represented.
- Destructive actions, external writes, and major deadline changes require confirmation.
- Explanations distinguish evidence from assumptions.
- Sensitive details are hidden by default in external surfaces.
- Permission requests are user-action triggered.
- Calendar write requires confirmation.
- Calendar-derived memory requires confirmation.
- Sync/export/accessibility claims are truthful.
- Unsuccessful actions state what remains safe.
- Memory deletion and delete-all-memory require confirmation.
- No AI/model terminology appears in normal UI.

## Resolved Wave 2 Questions

- Internal `Dropped` renders as `No Longer Relevant` in normal UI.
- Cancelled and Dropped remain internally separate; launch UI may simplify.
- Intentional goal ending action is `End Goal`, followed by a reason.
- Intentional pause action is `Park Goal`; state is Parked.
- Goal Weather is corrected through inputs, not direct manual override.
- Destructive actions, external writes, and major deadline changes require confirmation.
- Mark Done, Move task, Park task, Attach task to goal, Rename Life Area, and Change display density prefer receipt + undo.
- Delete memory and calendar write require confirmation.
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
- User-facing section is `What Ambitions Knows`; object/type name is `Memory`.
- Users can delete all memory from Trust Center with confirmation and export/reminder first.

## Open Questions For Future Waves

- What exact data belongs in export/import v1?
- Should sensitive Life Areas have per-surface toggles?
- Should memory suggestions appear as receipts, review cards, or Trust Center prompts?
- Should Trust Center qualitative status have named states such as Clear, Needs Review, Limited, or Attention?
