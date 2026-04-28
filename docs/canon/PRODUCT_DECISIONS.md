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
