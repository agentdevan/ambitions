---
name: phase-executor
description: Convert an Ambitions roadmap phase, backlog item, or implementation request into an exact repo-grounded execution plan. Use when asked to implement a numbered phase, turn roadmap text into code work, or break a native SwiftUI feature into concrete file-level tasks across `Native/Ambitions/`, `project.yml`, docs, and tests; do not use for generic brainstorming that is not anchored to the current repo.
---

# Phase Executor

## Purpose

Turn a roadmap phase or implementation request into a concrete execution plan that matches the current Ambitions repository, not a generic iOS playbook.

## When To Use

- A user asks for `implement phase 9`, `turn this roadmap step into code work`, or `break this feature into exact repo tasks`.
- The request references backlog or roadmap documents and needs file-level execution steps.
- The task spans app, services, persistence, routing, targets, docs, and tests and needs ordering.

## When Not To Use

- The user only wants high-level product brainstorming with no repo grounding.
- The user already named a narrower skill such as `capture-flow-implementer` or `xcodegen-target-writer` and the request is already tightly scoped to that workflow.
- The task is a small direct edit that does not need a phase plan.

## Required Inputs

- The user request or roadmap phase text.
- Current repo files relevant to the request.
- Current backlog or audit docs when the request references roadmap work.

## Execution Steps

1. Inspect the repo before planning. Read the current source files, `project.yml`, and the roadmap/backlog docs that actually govern the requested work.
2. Identify the current truth first. Confirm whether the requested behavior, target, service, model, route, or extension already exists. Refuse to pretend missing infrastructure exists.
3. Define the implementation surface. List the exact files and directories likely to change, grouped by role:
   - app/navigation
   - feature screens/view models
   - services
   - domain
   - persistence
   - project configuration
   - docs/tests/manual validation
4. State hard constraints up front. Include architecture boundaries, target constraints, extension safety, persistence rules, and any roadmap gating dependencies.
5. Sequence the work into minimal steps. Order the plan so foundation work lands before dependent UI or extension work.
6. Add acceptance criteria that can be checked in the repo, simulator, or CI flow.
7. Add validation steps using actual Ambitions commands and manual checks, not invented ones.
8. Produce a commit plan that groups changes into reviewable chunks.

## Output Format Expectations

Return a plan with these sections in order:

1. `Repo Grounding`
2. `Files To Touch`
3. `Constraints`
4. `Execution Steps`
5. `Acceptance Criteria`
6. `Validation`
7. `Commit Plan`
8. `Open Questions` only if something is truly missing or ambiguous in the repo

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
- Preserve the repo’s existing phased reality: captures, external routing, snapshot exports, extension work, planner safety, and repo-truth cleanup are distinct jobs.

## Trigger Phrases

- `implement phase 9`
- `turn this roadmap step into code work`
- `break this feature into exact repo tasks`
- `plan the native execution for this backlog item`
