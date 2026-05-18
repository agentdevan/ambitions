<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# UI Studio Prompt 07: Trust Continuity UX

## Batch ID

`UI-STUDIO-07-TRUST-CONTINUITY-UX`

## Purpose

Keep the You surface and adjacent trust flows settings-like, calm, and explicit about continuity, privacy, and redaction.

## Active Source Truth To Inspect

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `frontend/visual-encyclopedia/UI_STUDIO_OPERATING_SYSTEM.md`
- `frontend/visual-encyclopedia/FRONTEND_AUTHORITY_INDEX.md`
- `Native/Ambitions/Features/Profile/` if source work is in scope

## Install Scope

- Preserve trust controls as first-class, inspectable surfaces.
- Make privacy and continuity state visible.
- Keep the result native and not like a generic settings dump.

## Hard Rules

- No fake sync indicators.
- No ambiguous privacy claims.
- No generic profile residue.
- No forced onboarding permission requests outside current truth.

## Validation Expectations

- `make prompt-audit`
- `git diff --check`

## Final Response Format

- Summarize the trust and continuity boundaries.
- End with `STATUS: GREEN|YELLOW|RED`.
