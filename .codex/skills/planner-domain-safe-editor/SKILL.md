---
name: planner-domain-safe-editor
description: Safely edit Ambitions planning-domain logic around goal engine behavior, rescheduling, Today decisions, evidence/feedback handling, and action flows. Use when changing planner logic, Today decision rules, rescheduling, or core domain services under `Native/Ambitions/Domain/` and related feature services; these edits must start with a plan and should finish with `ios-qa-regression-checker`; do not use for superficial UI-only work or casual rewrites that ignore planner invariants.
---

# Planner Domain Safe Editor

## Purpose

Protect the planning engine and its downstream feature behavior from casual regressions when core logic changes are required.

## When To Use

- `change rescheduling`
- `update Today logic`
- `modify planning engine`
- change feedback, evidence, or action handling that affects goal plans or Today behavior

## When Not To Use

- The task is purely visual.
- The change is a small wording update in a screen.
- The request is capture-only and does not touch planner or Today invariants.

## Required Inputs

- Relevant domain and feature-service files.
- Current planner tests.
- Any doc notes or contracts relevant to the requested behavior.

## Execution Steps

0. Require a plan before edits. Use `phase-executor`, `feature-plan.md`, or `bugfix-plan.md` depending on scope.
1. Inspect planner/domain models first:
   - `Native/Ambitions/Domain/Planning/`
   - `Native/Ambitions/Domain/GoalEngine/`
   - `Native/Ambitions/Domain/Reschedule/`
   - `Native/Ambitions/Features/Today/`
   - affected feature services
2. Identify invariants before editing:
   - deterministic behavior
   - clarification/blocker handling
   - support/untimed semantics
   - evidence and feedback propagation
   - route/detail expectations downstream
3. Locate all downstream consumers of the changed contract. Planner edits often affect Today, Goals, Goal Detail, previews, and tests.
4. Choose the first deterministic slice and make the smallest change that satisfies the requirement. Avoid broad rewrites of planner structure when a narrower rule change works.
5. Self-check invariants after that slice before touching adjacent planner behavior.
6. Update or add tests that prove the invariant remains intact.
7. Retry only when the next move is narrower than the failed one and directly tied to the observed breakage.
8. If the requested change conflicts with existing contracts or roadmap direction, say so explicitly instead of forcing a brittle patch.
9. Stop if the remaining request would require broad planner rewrites or validation you cannot trust here.
10. Hand off to `ios-qa-regression-checker` after implementation.

Use the checklist in `templates/planner-change-safety-checklist.md`.

## Output Format Expectations

When summarizing, report:

1. invariant or behavior changed
2. files touched
3. downstream areas checked
4. tests added or updated
5. remaining risk if any

## Validation Requirements

- Run targeted planner/domain tests when available.
- Prefer adding tests for deterministic behavior changes, not just manual confidence.
- If full validation is not possible, call out the affected downstream screens/services explicitly.

## Ambitions-Specific Guardrails

- Respect `GoalEngineContracts.swift` and related native planner files as current contract truth.
- Preserve clarification-first, blocker-visible, support-mode, and untimed behavior unless the task explicitly changes them.
- Do not import old TypeScript planner logic back into the shipping native path.
- Be careful with `TodayFeatureService`, `GoalsFeatureService`, and route targets that depend on planner outputs.

## Failure Recovery

- If the request is broader than a safe planner edit, pause and produce a clearer plan before changing code.
- If the issue can be solved outside planner logic, switch to the narrower skill rather than rewriting the planner.
- If full validation cannot run, call out the downstream screens and tests still at risk.
- If a deterministic slice still fails after one or two grounded retries, stop and report the invariant risk instead of widening the rewrite.

## Trigger Phrases

- `change rescheduling`
- `update Today logic`
- `modify planning engine`
- `adjust feedback handling in the goal engine`
