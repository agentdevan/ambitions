<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# UI Studio Prompt 09: Preview Screenshot Matrix

## Batch ID

`UI-STUDIO-09-PREVIEW-SCREENSHOT-MATRIX`

## Purpose

Require a controlled preview and screenshot matrix for flagship UI work so proof coverage is explicit before any visual claim.

## Active Source Truth To Inspect

- `docs/truth/RELEASE_TRUTH.md`
- `frontend/visual-encyclopedia/UI_STUDIO_OPERATING_SYSTEM.md`
- `frontend/visual-encyclopedia/trace/UI_STUDIO_SCREEN_STATE_MATRIX.md`

## Install Scope

- Require preview fixtures for empty, normal, dense, recovery, error, reduced motion, large Dynamic Type, small iPhone, and large iPhone states when relevant.
- Keep screenshots controlled and truthful.
- Treat preview coverage as a proof requirement, not proof itself.

## Hard Rules

- No fake screenshot claims.
- No release readiness claims from previews alone.
- No omission of non-ideal states when the surface can show them.

## Validation Expectations

- `make prompt-audit`
- `git diff --check`

## Final Response Format

- Summarize the preview matrix requirements.
- End with `STATUS: GREEN|YELLOW|RED`.
