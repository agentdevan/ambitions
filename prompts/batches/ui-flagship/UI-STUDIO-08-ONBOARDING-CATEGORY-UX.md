<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# UI Studio Prompt 08: Onboarding Category UX

## Batch ID

`UI-STUDIO-08-ONBOARDING-CATEGORY-UX`

## Purpose

Install onboarding and category education that explains Ambitions without turning it into a motivational wizard or generic app tour.

## Active Source Truth To Inspect

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `frontend/visual-encyclopedia/UI_STUDIO_OPERATING_SYSTEM.md`
- any active onboarding or setup surface recipes

## Install Scope

- Keep onboarding honest about what is already known and what still needs setup.
- Explain the category through the primary objects, not through slogans.
- Preserve local-first and privacy-first posture.

## Hard Rules

- No forced calendar permission during onboarding.
- No fake personalization claims.
- No pseudo-optimistic copy that overpromises the product.

## Validation Expectations

- `make prompt-audit`
- `git diff --check`

## Final Response Format

- Summarize the onboarding category posture.
- End with `STATUS: GREEN|YELLOW|RED`.
