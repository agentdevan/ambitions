<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# UI Studio Prompt 06: Closure Recovery Interactions

## Batch ID

`UI-STUDIO-06-CLOSURE-RECOVERY-INTERACTIONS`

## Purpose

Review and install the closure and recovery interaction grammar so the product can handle interruption, error, and repair without shame.

## Active Source Truth To Inspect

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `frontend/visual-encyclopedia/UI_STUDIO_OPERATING_SYSTEM.md`
- the Today closure and recovery recipes in `frontend/visual-encyclopedia/recipes/today/`

## Install Scope

- Keep closure language calm and inspectable.
- Preserve undo, retry, and recovery affordances when they are source-backed.
- Distinguish interrupted, blocked, stale, and recoverable states.

## Hard Rules

- No shaming overdue language.
- No fake urgency.
- No hidden recovery controls.
- No red-only failure messaging.

## Validation Expectations

- `make prompt-audit`
- `git diff --check`

## Final Response Format

- Summarize the closure/recovery interaction rules.
- End with `STATUS: GREEN|YELLOW|RED`.
