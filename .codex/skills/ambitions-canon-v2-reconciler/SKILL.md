---
name: ambitions-canon-v2-reconciler
description: Use before broad Ambitions 2.0 product, visual, roadmap, batch-plan, decision-log, terminology, stale-copy, or source-of-truth reconciliation work. Enforces five-tab IA, current language rules, guided automation defaults, schedule/vacation/cognitive-fit/receipt canon, and docs-first truth updates without claiming implementation from docs-only changes.
---

# Ambitions Canon V2 Reconciler

## Purpose

Use this skill before broad Ambitions 2.0 product/design/spec integration, especially when updating canonical docs, roadmap files, batch plans, decision logs, stale copy, terminology, or source-of-truth hierarchy.

## Required Grounding

Read the current task, then inspect the active source-of-truth docs before editing:

1. `AGENTS.md`
2. `docs/codex/CONTEXT_INDEX.md`
3. `docs/codex/BATCH_REGISTRY.md`
4. `docs/codex/Ambitions_2_0_Codex_Execution_Guide.md`
5. Relevant `docs/canon/Ambitions_2_0_*.md` files
6. `docs/canon/design/Ambitions_Design_Constitution.md` when design, IA, copy, trust, accessibility, or external surfaces are touched

Prefer newer Ambitions 2.0 canon over older historical docs when they conflict. Preserve historical context; do not erase completed batch history.

## Canon Rules

- Ambitions has exactly five top-level tabs: `Today`, `Goals`, `Capture`, `Plan`, `You`.
- Deprecated user-facing language: `Your best next move`, `next best move`, `Start Focus`, `Focus session`, `Overdue`, `Failed`, `Missed`, `Behind`.
- Today hero language is `Start here`.
- Action language uses `step`, not `move`, except internal closure/system state where `Moved` may exist.
- `HeroDecisionPanel` may remain as an internal legacy name only if already used; user-facing component/copy should be `HeroStepPanel` / `Start here`.
- Guided automation is the default.
- Schedule & Availability belongs under `You -> Planning Behavior` and may also appear as clickable contextual setup prompts where schedule data would improve recommendations.
- Vacation is not free time by default.
- New vacation setup requires per-vacation availability choice and supports `make this my default`.
- Cognitive fit supports both inferred and user-selected paths.
- Closure receipts must be visible in Today, Trust Center, and Goal Detail.

## Procedure

1. Audit source-of-truth docs before editing.
2. Identify stale or conflicting canon and record which newer source wins.
3. Update canonical docs first.
4. Update roadmap, batch, registry, and decision-log references second.
5. Scan for deprecated terminology and stale state language in touched active docs and visible copy.
6. Preserve historical docs as historical where appropriate, but mark superseded truth clearly.
7. Do not claim implementation if only docs changed.
8. Keep changes narrow and reversible; avoid opportunistic rewrites.
9. Finish with changed files, stale references removed, remaining risks, and validation performed.

## Validation

- Use `rg` for deprecated wording and source-of-truth conflicts.
- Run `git diff --check` after edits.
- For docs-only changes, do not run app tests unless the edit touches code, generated project files, or live user-facing behavior.
- Separate verified, not verified, and could not verify here.

## Common Follow-On Skills

- Use `ambitions-time-context-builder` when reconciliation turns into schedule, availability, duration, vacation, cognitive-fit, or reflow model work.
- Use `ambitions-action-closure-receipts` when reconciliation turns into closure outcome or receipt work.
- Use `ambitions-ios-surface-polisher` when reconciliation turns into visible SwiftUI surface work.
- Use `ambitions-v2-validation-closeout` before declaring a broad v2 integration pass complete.
