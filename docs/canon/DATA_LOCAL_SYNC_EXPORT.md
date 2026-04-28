# Ambitions Data, Local-First, Sync, And Export

Status: Active canon consolidation layer.

Purpose: Consolidate local-first behavior, account posture, sync timing, export/import boundaries, delete-all-memory scope, data controls, failure states, and data trust language into one implementation-readable reference. This document reflects Wave 15 product decisions.

## Core Data Doctrine

Default data posture:

```text
Local-first.
```

Data trust north star:

```text
User understands what is stored, remembered, exported, and deleted.
```

Rules:

- Local-first is a product trust posture, not merely an implementation detail.
- First-run value must not depend on account, backend, cloud, or sync.
- Data behavior should be explicit, reviewable, and recoverable where possible.
- Do not make privacy/trust claims before implementation evidence exists.

## Launch Account Requirement

Launch account requirement:

```text
No account required at launch.
```

Rules:

- Onboarding must not require account creation.
- First useful object creation must not require sync or account setup.
- Account/sync paths may be introduced later only with clear trust, export, and recovery behavior.

## Sync Posture

Sync posture:

```text
No launch sync.
Sync later only after trust/export is strong.
```

Rules:

- Sync should not ship before export, failure states, trust explanations, and user comprehension are strong.
- Do not imply cloud sync exists before it does.
- Sync must not silently change local-first expectations.
- Sync errors must explain what remains safe and what did not happen.

## Export Before Cloud Sync

Export posture:

```text
Export should exist before cloud sync.
```

Rules:

- Export supports trust and user control.
- Export should be clear enough for non-technical users.
- Export/import surfaces should appear as available only when implemented.
- If export is unavailable, say so plainly.

## Export Scope

Export should include:

```text
User-selectable categories.
```

Potential categories:

- Goals
- Tasks
- Plans
- Captures
- Proof
- Reviews
- Memory
- Receipts
- Settings / preferences

Rules:

- Do not default to a raw local database dump as the user-facing export experience.
- Let users understand what category is included.
- Sensitive categories should be clear before export.
- Export should create a receipt when implemented.

## Delete-All-Memory Scope

Delete-all-memory affects:

```text
Memory only.
```

Rules:

- Delete-all-memory must not delete goals, tasks, plans, captures, proof, reviews, or settings unless the user separately chooses a broader destructive action.
- Delete-all-memory requires confirmation.
- Confirmation copy should explain scope plainly.
- Offer export/reminder first where export exists.

Recommended confirmation copy:

```text
This removes what Ambitions remembers about you. Your goals, tasks, and plans stay unless you delete them separately.
```

## Data Controls Location

Data controls live under:

```text
You -> Trust Center / Data controls.
```

Rules:

- Do not create a separate Data tab.
- Do not hide important data controls in obscure developer menus.
- Use Grouped Navigation List patterns where appropriate.
- Data controls should connect to Trust Center, Memory, Export/Import, and receipts.

## Sync / Export Claims

Sync/export claims before implementation:

```text
Do not show sync/export claims before implemented.
```

Rules:

- Roadmap docs may describe future work when clearly labeled as planned.
- Product UI must not claim shipped sync/export before implementation.
- Marketing copy must not imply availability before verification.
- Completion summaries should distinguish shipped behavior from planned canon.

## Export Failure State

Export failure should:

```text
Explain data remains safe.
Offer retry.
Offer review export option.
```

Copy pattern:

```text
Export did not complete. Your Ambitions data is still local.
```

Actions:

```text
Try Again
Review Export
```

Rules:

- Do not imply data was lost unless it was.
- Do not fake successful export.
- Preserve the user's selections where possible.
- Show what did and did not happen.

## Local-First Failure States

When a local write succeeds but an external/sync/export action fails:

```text
Saved locally. External action did not complete.
```

Rules:

- Explain local state separately from external state.
- Do not roll back local value unless required and explained.
- Do not make the user believe cloud/export/sync succeeded when it did not.

## Privacy And Memory Boundary

Rules:

- Memory is separate from goals, tasks, plans, and captures.
- What Ambitions Knows is the user-facing memory inspection surface.
- Sensitive/high-impact memories require confirmation before use.
- Users can pause memory learning globally and by category where implemented.
- Delete-all-memory affects memory only.

## QA Acceptance Criteria

Data/local-first work is acceptable when:

- Default data posture is local-first.
- Launch does not require an account.
- Sync is not part of launch unless a later explicit canon change says otherwise.
- Export exists before cloud sync.
- Export supports user-selectable categories when implemented.
- Delete-all-memory affects memory only.
- Data controls live under You -> Trust Center / Data controls.
- UI does not show sync/export claims before implementation.
- Export failure explains data remains safe, offers retry, and offers review export.
- User can understand what is stored, remembered, exported, and deleted.

## Open Questions For Future Waves

- Which export categories should ship first?
- What format should export use for ordinary users versus advanced users?
- Should import exist at the same time as export or after export is stable?
- What sync provider/path should be evaluated later?
- Should local backup reminders exist before sync?
