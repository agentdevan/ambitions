<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# UI Studio Prompt 10: FAANG-Level UI Red Team

## Batch ID

`UI-STUDIO-10-FAANG-LEVEL-UI-RED-TEAM`

## Purpose

Run the red-team lens that rejects generic, fake, inaccessible, or under-polished UI before it can be treated as flagship work.

## Active Source Truth To Inspect

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `frontend/visual-encyclopedia/UI_STUDIO_OPERATING_SYSTEM.md`
- `frontend/visual-encyclopedia/FRONTEND_AUTHORITY_INDEX.md`

## Install Scope

- Call out generic dashboard, calendar-clone, chatbot-first, and card-stack regressions.
- Call out Plan residue wherever it appears.
- Call out inaccessible tap targets, color-only states, and over-animation.

## Hard Rules

- No greenwashed review.
- No cosmetic approval without proof.
- No generic praise language without specific evidence.

## Validation Expectations

- `make prompt-audit`
- `git diff --check`

## Final Response Format

- Summarize the red-team failure modes.
- End with `STATUS: GREEN|YELLOW|RED`.
