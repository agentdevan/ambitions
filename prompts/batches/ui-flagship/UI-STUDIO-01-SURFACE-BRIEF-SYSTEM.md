<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# UI Studio Prompt 01: Surface Brief System

## Batch ID

`UI-STUDIO-01-SURFACE-BRIEF-SYSTEM`

## Purpose

Install the surface brief system that every future flagship UI batch must use before implementation. The goal is to make the brief explicit enough that a fresh Codex session cannot confuse surface topology, state coverage, or proof requirements.

## Active Source Truth To Inspect

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `frontend/visual-encyclopedia/FRONTEND_AUTHORITY_INDEX.md`
- `frontend/visual-encyclopedia/UI_STUDIO_OPERATING_SYSTEM.md`
- `frontend/visual-encyclopedia/trace/UI_STUDIO_SCREEN_STATE_MATRIX.md`

## Install Scope

- Keep the brief structure inside the UI Studio docs and prompt family.
- Preserve the active top-level IA: `Today / Goals / Capture / Time / You`.
- Keep `Plan` compatibility-only.
- Do not widen into app-source implementation.

## Required Output

Install a reusable surface brief contract that always includes:

- `Surface`
- `Primary object`
- `User intent`
- `Backend projection`
- `Empty state`
- `Normal state`
- `Dense state`
- `Recovery state`
- `Accessibility risks`
- `Performance risks`
- `What must not be built`

## Hard Rules

- No dashboard default.
- No chatbot-first framing.
- No card-stack fallback.
- No fake proof claims.
- No color-only meaning.

## Validation Expectations

- `make prompt-audit`
- `git diff --check`

## Final Response Format

- Summarize the installed brief contract.
- List the files changed.
- State the validation run.
- End with `STATUS: GREEN|YELLOW|RED`.
