# Ambitions Trust, Privacy, And Memory

Status: Active canon consolidation layer.

Purpose: Make trust, privacy, memory, receipts, explanation, correction, and user control explicit enough for implementation and QA. This document extracts existing doctrine from the Design Constitution, Product Architecture, Systems Architecture, Intelligence Standards, UX Writing Matrix, and product decision Waves 1-2.

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

## Trust Principles

1. The user can see what Ambitions knows.
2. The user can correct what Ambitions got wrong.
3. The user can delete or hide sensitive memory where supported.
4. Meaningful changes close with receipts.
5. Recommendations explain evidence and assumptions.
6. External writes require explicit confirmation.
7. Destructive actions and major deadline changes require confirmation.
8. Reversible local changes prefer receipt + undo.
9. Permissions are requested only when a user action makes the value clear.
10. Planned intelligence is never described as shipped behavior.
11. Ambitions is an intelligent product, not a chat-first AI product.
12. Trust-critical states degrade safely.

## Primary Trust Surfaces

| Surface | Trust role |
| --- | --- |
| Contextual panels | Explain why an action, route, or recommendation appears. |
| Receipt / Action Closure Tray | Shows what happened, what changed, why, undo/correction, and source. |
| You -> Trust Center | Main control center for explanation, privacy, receipts, sync/export status, safe automation, and platform surface truth. |
| You -> What Ambitions Knows | Main user-facing memory surface. |
| You -> Reviews | Shows what changed, what was learned, and what should be corrected or carried forward. |
| Capture receipts | Shows where items went and how to change route. |
| Plan permission panels | Explain calendar access and no-permission fallback. |
| Archive / Completion Archive | Preserves learning from completed, ended, no-longer-relevant, merged, replaced, or parked work. |

## Memory Model

Memory is user-visible remembered context that can shape future recommendations only when evidence-backed and correctable.

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
- `reviewedAt?`
- `expiresAt?`

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

Each memory category should support:

- inspect
- correct
- delete where safe
- review source/evidence where useful

Rules:

- Correcting memory should create a receipt.
- Deleting memory requires confirmation.
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
- Calendar write.
- Major deadline changes.
- Destructive actions.
- External writes.

Receipt rules:

- Meaningful commands should produce a receipt.
- Sensitive receipts hide details by default.
- Receipts should be searchable later.
- Failed actions should say what remains safe.
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

## Permission Trust

### Calendar

- Plan owns calendar permission.
- Calendar read permission is requested only after explicit Plan action.
- Calendar write requires explicit confirmation.
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

### Sync / Export

- Local-first behavior must remain clear.
- Export/import receipts should explain what changed.
- Sync unavailable or unverified states must be explicit.

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

Automation levels:

- Level 0: deterministic rules
- Level 1: local pattern summaries
- Level 2: user-confirmed learning
- Level 3: optional AI-assisted drafting/explanation
- Level 4: external knowledge/provider-backed suggestions
- Level 5: automation with explicit confirmation only

## Trust Center Structure

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

### Privacy

- Sensitive Details
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

## QA Acceptance Criteria

Trust implementation is acceptable when:

- User can inspect and correct memory.
- Meaningful actions create receipts.
- Reversible local actions prefer receipt + undo.
- Destructive actions, external writes, and major deadline changes require confirmation.
- Explanations distinguish evidence from assumptions.
- Sensitive details are hidden by default in external surfaces.
- Permission requests are user-action triggered.
- Calendar write requires confirmation.
- Sync/export/accessibility claims are truthful.
- Failed actions state what remains safe.
- Memory deletion requires confirmation.
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

## Open Questions For Future Waves

- Which memories should be auto-created versus suggested for confirmation?
- How long should undo remain available for each receipt type?
- Should users be able to pause memory learning globally?
- Should sensitive Life Areas have a privacy mode?
- What exact data belongs in export/import v1?
- Should Trust Center show a single status score or avoid scoring entirely?
