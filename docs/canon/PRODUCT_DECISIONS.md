# Ambitions Product Decisions

Status: Active canon decision log for product-definition waves.

Purpose: Preserve explicit product decisions made after canon consolidation. This document records decisions that should later be reflected in focused canon docs, batch prompts, and implementation acceptance criteria.

## Decision Authority

This document records resolved product decisions. It does not replace:

- `MASTER_PRODUCT_SPEC.md` for product truth
- `docs/canon/design/Ambitions_Design_Constitution.md` for design/IA/UX authority
- `docs/canon/Ambitions_2_0_Product_Architecture.md` for surface ownership
- `docs/canon/DOMAIN_MODEL.md` for object model detail
- `docs/canon/GOAL_PLAN_TASK_LIFECYCLE.md` for lifecycle detail

When these decisions clarify an ambiguity, future docs and batch prompts should follow them unless a later explicit canon decision supersedes them.

---

# Wave 1 — Product Identity And Life Areas

Adoption date: 2026-04-27

## 1. Highest-Level Product Category

Resolved direction:

```text
Ambitions is a personal life operating system, personal execution system, life organization system, and external brain for goals, plans, tasks, memory, and recovery.
```

User-facing emphasis:

```text
Life organization system.
```

Internal ambition:

```text
Personal life operating system / external brain.
```

Implementation implication:

- Marketing and onboarding may use simpler language such as `life organization system`.
- Internal architecture, roadmap, and long-range product strategy may use `personal life operating system` and `external brain`.
- Do not reduce Ambitions to a goal app, task app, planner, habit tracker, or calendar wrapper.

## 2. Opening Feeling

Resolved direction:

Primary feeling:

```text
My life feels organized.
```

Immediate proof:

```text
I know what matters now.
I know the next concrete step.
```

Supporting feelings:

```text
My goals feel achievable.
I trust the system.
I feel calm.
```

Implementation implication:

- The first screenful should prioritize organization, current relevance, and next action.
- Calm is important, but calm supports organization; it is not the whole product promise.
- A beautiful screen that does not make life feel more organized fails the product standard.

## 3. Life Area Requirement

Resolved decision:

```text
Ambitions can infer Life Area, but the user can correct it.
```

Implementation implication:

- Life Area should be recommended/inferred, not mandatory friction.
- Items may temporarily exist without a confirmed Life Area.
- Smart Attachment, receipts, and correction UI should make Life Area assignment editable.

## 4. Default Life Areas

Resolved default set:

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

Implementation implication:

- These are the default Life Areas that should ship.
- Future onboarding, Capture routing, Goal creation, and You personalization should use this default set unless later superseded.

## 5. Renameable Life Areas

Resolved decision:

```text
Users can rename default Life Areas, but each renamed area should keep an internal canonical type underneath.
```

Implementation implication:

- User-facing name can change.
- Internal type should preserve routing, intelligence, icon defaults, examples, and future domain behavior.
- Example: user renames `Creative` to `Music`; internal canonical type may remain `creative`.

## 6. North Star Language

Resolved decision:

```text
Use North Star in deeper views only.
```

Implementation implication:

- Top-level/new-user copy may use clearer language such as `long-term ambition`.
- Deeper Goals/Life Areas views can introduce `North Star` as premium product language.
- Do not overexpose North Star during onboarding or simple goal creation.

## 7. Goal Meaning

Resolved decision:

```text
A Goal is a meaningful outcome that may need a plan.
```

Implementation implication:

- A goal is not any task with a deadline.
- A goal is not merely a project board.
- A goal should be important enough to justify direction, plan, proof, lifecycle, and review.

## 8. Standalone Task Language

Resolved decision:

```text
User-facing term: Task.
Internal/design canon term: One-Step Goal.
```

Implementation implication:

- Normal UI can say `Task`.
- Design/system docs can continue using `One-Step Goal` to preserve the distinction from contained `Step`.
- Avoid `To-Do` as the primary Ambitions object name.

## 9. Tasks Without Goals

Resolved decision:

```text
A task can exist without a goal, but Ambitions should suggest attaching or promoting it when useful.
```

Implementation implication:

- Do not force every item into a Goal.
- Do not create a top-level Tasks tab.
- A standalone Task can later attach to a Goal, promote into a Goal, convert to a Ritual, or remain standalone.

## 10. Non-Negotiable Product Rules

Resolved rule stack:

System rule:

```text
Every item has a place.
```

Execution rules:

```text
Every goal has a next step.
Every plan must be believable.
```

Emotional rule:

```text
The user never feels punished for drifting.
```

Product-shape rule:

```text
The app stays deep, not wide.
```

Implementation implication:

- Capture, routing, and Smart Attachment must prevent orphaned life objects.
- Active goals should expose one Next Visible Step unless blocked/waiting.
- Plan should tell the truth when a day/week/goal does not hold.
- Recovery language must remain non-shaming.
- New capability should prefer drill-downs and contextual intelligence over new top-level tabs.

## Wave 1 Follow-Up Targets

These decisions should be reflected in:

- `DOMAIN_MODEL.md`
- `GOAL_PLAN_TASK_LIFECYCLE.md`
- `ONBOARDING_SPEC.md`
- `TRUST_PRIVACY_MEMORY.md`
- `EMPTY_ERROR_RECOVERY_STATES.md`
- future batch prompts involving Life Areas, Capture routing, onboarding, Goals, Plan, or You.

---

# Wave 2 — Lifecycle And State Language

Adoption date: 2026-04-27

## 1. Dropped State Language

Resolved decision:

```text
Internal state: Dropped.
User-facing label: No Longer Relevant.
```

Implementation implication:

- System/domain docs may keep `dropped` as an internal lifecycle state.
- Normal UI should avoid making the user feel judged; use `No Longer Relevant` when the goal ended through drift, non-continuation, or relevance loss.

## 2. Cancelled vs Dropped At Launch

Resolved decision:

```text
Cancelled and Dropped remain internally separate, but the UI can simplify at launch.
```

Implementation implication:

- Internal state should preserve useful distinction for learning and future reviews.
- Launch UI can present simpler end-state choices and hide unnecessary taxonomy.
- Archive can reveal richer distinction in deeper views.

## 3. Intentional Goal Ending Action

Resolved decision:

```text
Primary action: End Goal.
Then ask the reason.
```

Implementation implication:

- Avoid making `Cancel Goal` the primary general action.
- `End Goal` should open a reason/route choice rather than immediately destroying state.
- Ended goals preserve proof, decision trail, and learning.

## 4. Goal Pause Action

Resolved decision:

```text
Primary action: Park Goal.
State: Parked.
```

Implementation implication:

- Use `Park Goal` for intentional pause.
- Parked means intentionally paused and preserved.
- Parked goals can resume later and should not feel like failure.

## 5. Goal Weather Correction

Resolved decision:

```text
Goal Weather is not manually overridden directly. The user can correct inputs that affect weather.
```

Implementation implication:

- Do not add a simple `Set Weather` control as the main UI.
- Provide correction routes for deadline, proof, blocker, next step, scope, waiting state, and assumptions.
- Weather remains explainable through `Why This` / `Why Changed`.

## 6. Plan State Language

Resolved decision:

```text
Internal states can be strong.
UI labels should be softer.
```

Internal states:

```text
Believable
Tight
Fragile
Broken
```

User-facing labels:

```text
Believable
Tight
Needs Protection
No Longer Holds
```

Implementation implication:

- Preserve strong internal meaning for logic and QA.
- Avoid unnecessarily harsh UI language.
- `Broken` should generally render as `No Longer Holds` in normal UI.
- `Fragile` should generally render as `Needs Protection` in normal UI.

## 7. Confirmation Requirements

Resolved decision:

```text
Require confirmation for destructive actions, external writes, and major deadline changes.
```

Implementation implication:

- Destructive memory/privacy changes require confirmation.
- Calendar writes require confirmation.
- Major deadline changes require confirmation or an explicit reviewed change flow.
- Ordinary local reversible changes should prefer receipt + undo.

## 8. Receipt + Undo vs Confirmation

Resolved decision:

Receipt + undo first:

```text
Mark Done
Move task
Park task
Attach task to goal
Rename Life Area
Change display density
```

Confirmation required:

```text
Delete memory
Calendar write
```

Implementation implication:

- Do not over-confirm reversible actions.
- Meaningful reversible changes should close with a receipt.
- Destructive/privacy/external actions require confirmation.

## 9. Completed Goal Visibility

Resolved decision:

```text
Default: completed goals stay visibly emphasized for 30 days.
Major goals may remain emphasized longer depending on importance.
```

Implementation implication:

- Completion should feel meaningful, not instantly hidden.
- After the emphasis window, completed goals move toward Archive/Completion Archive treatment.
- Major goals can stay visible longer or receive richer completion summaries.

## 10. Archive Naming

Resolved decision:

```text
Product/design docs: Completion Archive.
Normal UI: Archive.
```

Implementation implication:

- Use `Completion Archive` in canon when describing the full system.
- Use simpler `Archive` in everyday navigation/copy unless extra clarity is needed.
- Archive preserves learning; it is not trash.

## Wave 2 Follow-Up Targets

These decisions should be reflected in:

- `GOAL_PLAN_TASK_LIFECYCLE.md`
- `DOMAIN_MODEL.md`
- `EMPTY_ERROR_RECOVERY_STATES.md`
- `TRUST_PRIVACY_MEMORY.md`
- `IMPLEMENTATION_ACCEPTANCE_GATES.md`
- future batch prompts involving Goal Detail, Plan, Archive, Recovery, Receipts, or Trust Center.

---

# Wave 3 — Trust, Memory, And Receipts

Adoption date: 2026-04-27

## 1. Memory Creation

Resolved decision:

```text
Low-risk memories may be auto-created with visibility. Sensitive or high-impact memories should be suggested for user confirmation first.
```

Implementation implication:

- Ambitions should not silently build a large hidden profile.
- Low-risk preference/pattern memory can be created if surfaced in `What Ambitions Knows` and receipt/review paths.
- Sensitive or consequential memory must ask the user first.

## 2. Memories Requiring Explicit Confirmation

Resolved decision:

Require confirmation:

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

Implementation implication:

- Work/career memory can be auto-created only when low-risk and obvious, but should request confirmation when it affects priority, planning, identity, or sensitive context.
- Calendar-derived patterns require confirmation before becoming memory.
- Display and density changes should be visible and reversible.

## 3. Pause Memory Learning

Resolved decision:

```text
Users can pause memory learning globally and by category.
```

Implementation implication:

- Trust Center should include global memory-learning control.
- `What Ambitions Knows` should eventually support per-category memory controls.
- Pausing memory learning should not delete existing memory unless the user chooses deletion.

## 4. Sensitive / Private Life Areas

Resolved decision:

```text
User can mark any Life Area sensitive.
```

Implementation implication:

- Sensitivity is not limited to default categories.
- Sensitive treatment should apply to renamed/custom Life Areas as well.
- Sensitive mode should affect external surfaces and compact summaries.

## 5. Sensitive Mode Behavior

Resolved launch behavior:

```text
Hide details in notifications/widgets.
Collapse details on Today.
Use generic labels like Private item.
```

Later/advanced behavior:

```text
Require Face ID to open.
Exclude from export by default.
Keep local-only.
Hide from screenshots/previews.
```

Implementation implication:

- Launch sensitive mode should be useful without overpromising platform-level privacy.
- Do not claim Face ID, export exclusion, local-only enforcement, or screenshot hiding until implemented and verified.

## 6. Undo Duration

Resolved decision:

```text
Undo duration depends on action type.
```

Suggested default:

```text
Quick UI actions: 5–10 seconds.
Route changes / attach / move: until screen exit or review tray dismissal.
Rename/display changes: 30 seconds.
Destructive/external writes: confirmation first, undo only if platform-safe.
```

Implementation implication:

- Undo availability must be truthful.
- Destructive and external actions should not rely on undo as the primary safety control.
- Receipts should disclose whether undo is available.

## 7. Trust Center Score

Resolved decision:

```text
No numerical Trust Score at launch. Use qualitative status sections.
```

Implementation implication:

- Avoid fake precision in trust.
- Trust Center should show reviewable status sections rather than a gamified score.
- Qualitative status may be used if useful.

## 8. Trust Center Top Status

Resolved decision:

```text
Top status: You are in control.
```

Implementation implication:

- Supporting rows can show memory status, receipts, privacy, sync/export truth, calendar access, and accessibility verification state.
- Avoid overclaiming `system healthy` if platform or sync capabilities are not verified.

## 9. Memory Naming

Resolved decision:

```text
Section name: What Ambitions Knows.
Object/type name: Memory.
```

Implementation implication:

- Use `What Ambitions Knows` for the user-facing section under You/Trust.
- Use `Memory` for object models, detail pages, receipts, and internal language.
- Avoid `Knowledge` as the primary user-facing term.

## 10. Delete All Memory

Resolved decision:

```text
Users can delete all memory from Trust Center, with confirmation and export/reminder first.
```

Implementation implication:

- Deleting all memory is destructive and requires confirmation.
- Offer export/reminder first where export exists.
- If export is not implemented, say so plainly and provide the safest available confirmation path.
- Delete all memory should not delete goals/tasks/plans unless explicitly included in a separate destructive action.

## Wave 3 Follow-Up Targets

These decisions should be reflected in:

- `TRUST_PRIVACY_MEMORY.md`
- `DOMAIN_MODEL.md`
- `EMPTY_ERROR_RECOVERY_STATES.md`
- `IMPLEMENTATION_ACCEPTANCE_GATES.md`
- future batch prompts involving Trust Center, What Ambitions Knows, receipts, sensitive Life Areas, notifications/widgets, export/import, or privacy controls.
