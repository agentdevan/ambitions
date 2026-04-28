# Ambitions Product Decisions

Status: Active canon decision log for product-definition waves.

Purpose: Preserve explicit product decisions made after canon consolidation. This document records decisions that clarify ambiguity across product, design, onboarding, lifecycle, memory, trust, and implementation acceptance.

## Decision Authority

This document records resolved product decisions. It does not replace:

- `MASTER_PRODUCT_SPEC.md` for product truth
- `docs/canon/design/Ambitions_Design_Constitution.md` for design/IA/UX authority
- `docs/canon/Ambitions_2_0_Product_Architecture.md` for surface ownership
- `docs/canon/DOMAIN_MODEL.md` for object model detail
- `docs/canon/GOAL_PLAN_TASK_LIFECYCLE.md` for lifecycle detail
- `docs/canon/TRUST_PRIVACY_MEMORY.md` for trust/memory/privacy detail
- `docs/canon/ONBOARDING_SPEC.md` for first-run flow detail

When these decisions clarify an ambiguity, future docs and batch prompts should follow them unless a later explicit canon decision supersedes them.

---

# Wave 1 — Product Identity And Life Areas

Adoption date: 2026-04-27

## Resolved Decisions

- Ambitions is user-facing as a **life organization system**.
- Internally, Ambitions is a **personal life operating system / external brain** for goals, plans, tasks, memory, and recovery.
- The primary opening feeling is: `My life feels organized`.
- The immediate proof is: `I know what matters now` and `I know the next concrete step`.
- Life Areas are inferred/recommended and correctable, not mandatory friction.
- Default Life Areas:

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

- Users can rename default Life Areas while preserving an internal canonical type.
- `North Star` is deeper-view language; top-level/new-user copy may use `long-term ambition`.
- A Goal is a meaningful outcome that may need a plan.
- User-facing standalone action language is `Task`.
- Internal/design term for a standalone task is `One-Step Goal`.
- A Task can exist without a Goal, but Ambitions should suggest attaching or promoting when useful.

## Non-Negotiable Rules

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

---

# Wave 2 — Lifecycle And State Language

Adoption date: 2026-04-27

## Resolved Decisions

- Internal state: `Dropped`.
- User-facing label for dropped goals: `No Longer Relevant`.
- `Cancelled` and `Dropped` remain internally separate, but the UI can simplify at launch.
- Intentional goal ending action: `End Goal`, then ask the reason.
- Goal pause action: `Park Goal`.
- Pause state: `Parked`.
- Goal Weather is not directly manually overridden. The user corrects inputs that affect weather.
- Internal Plan states may use stronger language:

```text
Believable
Tight
Fragile
Broken
```

- User-facing Plan labels should be softer:

```text
Believable
Tight
Needs Protection
No Longer Holds
```

- Confirmation is required for destructive actions, external writes, and major deadline changes.
- Receipt + undo should be used for reversible local actions:

```text
Mark Done
Move task
Park task
Attach task to goal
Rename Life Area
Change display density
```

- Confirmation is required for:

```text
Delete memory
Calendar write
```

- Completed goals stay visibly emphasized for 30 days by default.
- Major completed goals may remain emphasized longer depending on importance.
- Product/design language: `Completion Archive`.
- Normal UI language: `Archive`.

---

# Wave 3 — Trust, Memory, And Receipts

Adoption date: 2026-04-27

## Resolved Decisions

- Low-risk memories may be auto-created with visibility.
- Sensitive or high-impact memories should be suggested for user confirmation first.

Confirmation required:

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

- Users can pause memory learning globally and by category.
- User can mark any Life Area sensitive.

Sensitive launch behavior:

```text
Hide details in notifications/widgets
Collapse details on Today
Use generic labels like Private item
```

Later/advanced sensitive behavior:

```text
Require Face ID to open
Exclude from export by default
Keep local-only
Hide from screenshots/previews
```

Undo duration depends on action type:

```text
Quick UI actions: 5-10 seconds
Route changes / attach / move: until screen exit or review tray dismissal
Rename/display changes: 30 seconds
Destructive/external writes: confirmation first, undo only if platform-safe
```

Trust Center:

- No numerical Trust Score at launch.
- Use qualitative status sections.
- Top status: `You are in control`.

Memory naming:

- User-facing section: `What Ambitions Knows`.
- Object/type name: `Memory`.

Delete all memory:

- Allowed from Trust Center.
- Requires confirmation.
- Offer export/reminder first where export exists.
- If export is not implemented, say so plainly.
- Does not delete goals/tasks/plans unless explicitly included separately.

---

# Wave 4 — Onboarding And First-Run Flow

Adoption date: 2026-04-27

## Resolved Decisions

- Onboarding should show a static premium product preview at launch.
- Animation can come later.
- The first onboarding prompt is:

```text
What do you want to organize?
```

- First object creation should show the receipt inside the destination.

Example receipt:

```text
Saved as Goal · Creative
Next: Shape the first milestone
Change
```

- Onboarding should not ask for display density up front.
- Default display setting: `Balanced + Comfortable`.
- Display density and panel size can be adjusted later in `You`.
- Life Area should be inferred when possible.
- Life Area should be asked only when Ambitions is uncertain.
- Life Area assignment must remain correctable from the receipt.
- Notifications should not be requested during onboarding.
- Notification permission should only be requested after the user sets a reminder or protected block.
- Calendar access should not be requested during onboarding.
- Calendar access should only be requested from Plan after the user asks for calendar-aware planning.

Default onboarding examples should cover:

```text
Career
Creative
Finance
Health
Home
Relationships / Family
```

- Baby/family examples can appear later when contextually relevant.
- If the user skips onboarding, land in Today with a strong empty state and a Capture action.
- First-run success metric:

```text
User creates any useful object.
```

## Implementation Implications

- Do not optimize onboarding around finishing every setup screen.
- Do not make first-run success depend on calendar, notifications, a full plan, or a full goal hierarchy.
- First value comes from one useful object, one visible destination, one clear receipt, and one next action.
- Onboarding must prove organization before asking for permissions or preferences.

---

# Active Follow-Up Targets

These decisions should be reflected in:

- `DOMAIN_MODEL.md`
- `GOAL_PLAN_TASK_LIFECYCLE.md`
- `ONBOARDING_SPEC.md`
- `TRUST_PRIVACY_MEMORY.md`
- `EMPTY_ERROR_RECOVERY_STATES.md`
- `IMPLEMENTATION_ACCEPTANCE_GATES.md`
- future batch prompts involving onboarding, Life Areas, Capture routing, Today empty states, Goals, Plan, You, Trust Center, receipts, sensitive Life Areas, notifications/widgets, export/import, or privacy controls.
