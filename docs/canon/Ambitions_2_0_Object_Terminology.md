# Ambitions 2.0 Object Terminology

> Historical note: This file is retained for traceability only.
> It is not active authority. Current authority starts in `docs/truth/README.md`.
> Reconcile terminology against current truth/status files before use.

Status: Historical/supporting Ambitions 2.0 terminology reference.
Date: 2026-04-27.

This document records shared object language for D02 and later Design Constitution delta batches. It clarifies product, docs, tests, previews, and user-facing copy without claiming that every object has a first-class model or surface today.

## Locked Rules

```text
Task = standalone One-Step Goal.
Step = action inside a Goal, Path, or Plan.
```

- Do not use Task and Step interchangeably.
- Do not use Task for contained goal/path/plan actions.
- Do not use Step for standalone one-off tasks.
- Do not introduce a top-level Tasks tab.
- Do not present Habits as a standalone top-level product area.
- Do not use AI-wrapper terminology for intelligent routing, suggestions, or explanations.

## Object Definitions

| Term | Definition | Current posture |
| --- | --- | --- |
| Life Area | Visible organization lens for life domains such as Health, Career, Home, Relationships, or Money. It is not a sixth tab. | Historical/supporting reference; verify against current truth/status before use. |
| Ambition | Meaningful direction the user may want to pursue. Ambitions can be active, dormant, identity-level, or refined into Goals. | Historical/supporting reference; verify against current truth/status before use. |
| North Star | Long-range dormant or identity-level Ambition that can live under a Life Area without active goals or plans. | Historical/supporting reference; verify against current truth/status before use. |
| Goal | Concrete outcome with enough structure to carry a path, plan, milestones, steps, proof, decisions, and archive learning. | Historical/supporting reference; verify against current truth/status before use. |
| Path | Believable route through a Goal or Ambition, including assumptions, stages, prerequisites, risks, and alternatives. | Historical/supporting reference; verify against current truth/status before use. |
| Plan | Current agreement with time, capacity, constraints, rituals, recovery, and protected work. | Historical/supporting reference; current active top-level destination is Time, not Plan. |
| Milestone | Meaningful checkpoint on the way to a Goal, larger than a Step and more concrete than broad direction. | Historical/supporting reference; verify against current truth/status before use. |
| Step | Contained action inside a Goal, Path, or Plan. A Step belongs to a larger structure. | Historical/supporting reference; verify against current truth/status before use. |
| Task / One-Step Goal | Standalone one-off outcome that can exist without a parent Goal, Path, Plan, or Life Area. | Historical/supporting reference; verify against current truth/status before use. |
| Proof | Evidence that progress, completion, a decision, or a result happened. | Historical/supporting reference; verify against current truth/status before use. |
| Receipt | User-facing result/trust record that says what happened, what changed, why, and what can be corrected or undone. | Historical/supporting reference; verify against current truth/status before use. |
| Review | Reflection, recovery, history, and carry-forward surface. It is not the same as analytics. | Historical/supporting reference; verify against current truth/status before use. |
| Archive | Saved history for learning and retrieval. Archive is not deletion or trash. | Historical/supporting reference; verify against current truth/status before use. |
| Ritual | Recurring execution structure that supports Goals, Plan, Today, and You. Ritual replaces user-facing standalone Habits posture. | Historical/supporting reference; verify against current truth/status before use. |
| Waiting / Waiting Room | Place for commitments, dependencies, follow-ups, and paused items waiting on something real. | Historical/supporting reference; verify against current truth/status before use. |
| Decision | Human-readable reason a Goal, Path, Plan, Step, Task, or Receipt changed. | Historical/supporting reference; verify against current truth/status before use. |
| Memory / What Ambitions Knows | User-visible memory/control concept for what Ambitions stores, uses, can correct, and can forget. | Historical/supporting reference; verify against current truth/status before use. |

## Required Examples

- Task: Pick up medication from CVS after work. Standalone, may be categorized Health / Wellness, does not require a parent goal.
- Step: Find NASA contacts on LinkedIn later. Contained under Become an Astronaut if attached to that Ambition/Goal path.
- North Star: Become an Astronaut. Can exist as a long-range Career direction without active goals or plans.
- Goal: Build the baby's crib before birth. Concrete outcome with a path/plan/steps.
- Ritual: Weekly planning review. Recurring execution support, not a standalone Habits tab.

## Compatibility Notes

- `Profile` internal names may remain while the user-facing surface is `You`.
- `Habits` internal names may remain while the user-facing surface is `Rituals` or Plan-owned recurring execution.
- `Insights` internal names may remain while user-facing placement is contextual intelligence, Reviews, history, or explanation, not a top-level tab.
- Persistence enum cases, external identifiers, widget families, route names, and historical docs may retain old names when renaming would risk saved data, external compatibility, or out-of-scope platform work.
