<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# UI Studio Prompt 03: Reality Meridian Art Direction

## Batch ID

`UI-STUDIO-03-REALITY-MERIDIAN-ART-DIRECTION`

## Purpose

Direct the art treatment for Today's Reality Meridian so the surface feels like a day with a spine, not a dashboard or task list.

## Active Source Truth To Inspect

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `frontend/visual-encyclopedia/FRONTEND_AUTHORITY_INDEX.md`
- `frontend/visual-encyclopedia/UI_STUDIO_OPERATING_SYSTEM.md`
- `frontend/visual-encyclopedia/recipes/today/today_reality_meridian_flagship_surface.md`
- `frontend/visual-encyclopedia/recipes/today/today_start_here_region.md`

## Install Scope

- Keep the Today object dominant.
- Keep the current-time cursor and scheduled node separate.
- Preserve the sparse proof and recovery layer.
- Preserve the locked `Start now →` and `Local · Ambitions` treatments where truth supports them.

## Hard Rules

- No dense dashboard.
- No hero card stack.
- No merged scheduled/current time marker.
- No fake AI badge or generic `On-device` chip.

## Validation Expectations

- `make prompt-audit`
- `git diff --check`

## Final Response Format

- Summarize the Reality Meridian art direction constraints.
- Note any state labels that must remain exact.
- End with `STATUS: GREEN|YELLOW|RED`.
