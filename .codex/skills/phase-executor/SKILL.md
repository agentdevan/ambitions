---
name: phase-executor
description: Convert an Ambitions roadmap phase, backlog item, or risky implementation request into an exact repo-grounded execution plan. Use when asked to implement a numbered phase, turn roadmap text into code work, or start any task that touches domain logic, persistence, XcodeGen, extensions, routing, container wiring, release hardening, or multi-file docs truth; do not use for generic brainstorming that is not anchored to the current repo.
---

# Phase Executor

## Purpose

Turn a roadmap phase or risky implementation request into a concrete execution plan that matches the current Ambitions repository, not a generic iOS playbook.

## When To Use

- A user asks for `implement phase 9`, `turn this roadmap step into code work`, or `break this feature into exact repo tasks`.
- The request references backlog or roadmap documents and needs file-level execution steps.
- The task spans app, services, persistence, routing, targets, docs, or tests.
- A risky change must plan first before edits.

## When Not To Use

- The user only wants high-level product brainstorming with no repo grounding.
- The task is a small direct edit that does not need a plan.
- A narrower skill is already active and the work is low-risk and single-surface.

## Required Inputs

- The user request or roadmap phase text.
- Current repo files relevant to the request.
- Current backlog or audit docs when the request references roadmap work.

## Execution Steps

1. Inspect the repo before planning. Read the current source files, `project.yml`, and the roadmap/backlog docs that actually govern the requested work.
2. Identify the current truth first. Confirm whether the requested behavior, target, service, model, route, or extension already exists. Refuse to pretend missing infrastructure exists.
3. Decide plan size:
   - lightweight plan for a narrow risky edit
   - fuller plan when the task crosses multiple layers or has uncertain seams
4. Define the implementation surface. List the exact files and directories likely to change, grouped by role:
   - app/navigation
   - feature screens/view models
   - services
   - domain
   - persistence
   - project configuration
   - docs/tests/manual validation
5. State hard constraints up front. Include architecture boundaries, target constraints, extension safety, persistence rules, and any roadmap gating dependencies.
6. Sequence the work into minimal steps. Order the plan so foundation work lands before dependent UI or extension work.
7. Bound the first execution slice explicitly. Name the smallest safe starting step instead of planning the whole task as one edit wave.
8. Add self-check points after each planned slice so execution can compare results against the goal before widening the diff.
9. Add acceptance criteria that can be checked in the repo, simulator, or CI flow.
10. Add validation steps using actual Ambitions commands and manual checks, not invented ones.
11. Add retry and stop notes for likely failure modes:
   - environment/tooling block
   - missing repo seam
   - wrong skill selection
   - validation failure after a narrow change
12. Produce a commit plan that groups changes into reviewable chunks.
13. Hand off to the follow-on implementation skill when one clearly fits, instead of keeping execution inside this planning skill.

## Output Format Expectations

Return a plan with these sections in order:

1. `Repo Grounding`
2. `Files To Touch`
3. `Constraints`
4. `Execution Steps`
5. `First Safe Slice`
6. `Acceptance Criteria`
7. `Validation`
8. `Retry Or Stop Notes`
9. `Commit Plan`
10. `Open Questions` only if something is truly missing or ambiguous in the repo

Use the templates in `templates/` when they help keep the output structured:

- `templates/phase-prompt-template.md`
- `templates/acceptance-criteria-template.md`
- `templates/commit-plan-template.md`

## Validation Requirements

- Verify each planned change against current repo files before naming it.
- Align validation with `docs/native-build-and-release.md` and `.github/workflows/ios-validate.yml`.
- If a requested phase depends on missing foundation work, say so explicitly and reorder the plan accordingly.

## Ambitions-Specific Guardrails

- Treat `Native/Ambitions/` as the shipping source of truth.
- Use the feature/service/repository patterns already described in `docs/codex/repo-audit-baseline.md`.
- Prefer `docs/implementation-backlog.md`, `docs/README.md`, `project.yml`, and current native source files over stale historical docs.
- Do not route new shipping work into removed or legacy TypeScript runtime paths.
- Preserve the repo's existing phased reality: captures, external routing, snapshot exports, extension work, planner safety, and repo-truth cleanup are distinct jobs.

## Skill Chaining

- Chain to `capture-flow-implementer` for capture-domain work.
- Chain to `xcodegen-target-writer` for target/config work.
- Chain to `planner-domain-safe-editor` for domain and Today/planner changes.
- Chain to `repo-truth-enforcer` for docs truth reconciliation.
- Expect a follow-on `ios-qa-regression-checker` pass after implementation.

## Failure Recovery

- If the request is lower-risk than it first appeared, downgrade to a lighter plan and say so.
- If the wrong follow-on skill is likely, name the correct one before implementation starts.
- If the requested feature would require inventing a seam the repo does not have, keep the plan truthful and call out the missing seam explicitly.
- If the plan reveals that only a narrow partial implementation is safe, say so and scope the first slice to that partial landing.

## Trigger Phrases

- `implement phase 9`
- `turn this roadmap step into code work`
- `break this feature into exact repo tasks`
- `plan the native execution for this backlog item`
