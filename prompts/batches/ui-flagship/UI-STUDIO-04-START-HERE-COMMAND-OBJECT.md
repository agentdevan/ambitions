<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# UI Studio Prompt 04: Start Here Command Object

## Batch ID

`UI-STUDIO-04-START-HERE-COMMAND-OBJECT`

## Purpose

Define the Start Here command object so the flagship daily surface uses resolver truth, not vague recommendation language.

## Active Source Truth To Inspect

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `frontend/visual-encyclopedia/START_HERE_REALITY_RECOGNITION_DOCTRINE.md`
- `frontend/visual-encyclopedia/UI_STUDIO_OPERATING_SYSTEM.md`
- `frontend/visual-encyclopedia/recipes/today/today_start_here_region.md`

## Install Scope

- Keep `Recommended step`, `Active step`, `In progress`, `Up next`, `Needs closure`, `Recovery`, `Protected time`, `Away mode`, `Current commitment`, and `Schedule conflict` exact.
- Require the command object to expose authority and action without shaming language.

## Hard Rules

- No `best next step`.
- No `next best move`.
- No `optimal move`.
- No generic recommendation card.

## Validation Expectations

- `make prompt-audit`
- `git diff --check`

## Final Response Format

- Summarize the command-object labels and boundaries.
- End with `STATUS: GREEN|YELLOW|RED`.
