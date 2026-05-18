<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# UI Studio Prompt 02: Tokens and Materials Review

## Batch ID

`UI-STUDIO-02-TOKENS-AND-MATERIALS-REVIEW`

## Purpose

Review the active token and materials layer before any flagship UI implementation. The goal is to keep visual language consistent, reusable, and native instead of creating one-off styling.

## Active Source Truth To Inspect

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `frontend/visual-encyclopedia/FRONTEND_AUTHORITY_INDEX.md`
- `frontend/visual-encyclopedia/UI_STUDIO_OPERATING_SYSTEM.md`
- current token, primitive, and material docs in `frontend/visual-encyclopedia/`

## Install Scope

- Reuse existing tokens and materials where possible.
- Extend only when current truth shows a real gap.
- Keep the result compatible with native iPhone polish and the active IA.

## Required Review Questions

- Which tokens are actually source-backed?
- Which materials are only decorative and should be removed?
- Which values are shared across surfaces instead of bespoke to one screen?
- Which visual choices would make the app feel generic or web-like?

## Hard Rules

- Do not introduce a duplicate design system.
- Do not create an ornamental gradient or glass layer without semantic value.
- Do not allow token drift to override active truth.

## Validation Expectations

- `make prompt-audit`
- `git diff --check`

## Final Response Format

- Summarize the token/material findings.
- List any token gaps that remain unresolved.
- End with `STATUS: GREEN|YELLOW|RED`.
