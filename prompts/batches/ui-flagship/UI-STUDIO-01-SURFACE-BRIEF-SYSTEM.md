<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
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

The contract must also preserve:

- the active top-level IA: `Today / Goals / Capture / Time / You`
- `Plan` as compatibility-only
- one-primary-object discipline
- local-first / on-device-first posture
- non-claims around implementation, screenshot proof, accessibility proof, performance proof, and release proof

## Hard Rules

- No surface default.
- No chatbot-first framing.
- No card-stack fallback.
- No fake proof claims.
- No color-only meaning.
- `What must not be built` must explicitly reject surface, chatbot, card-stack, calendar-clone, fake-proof, and color-only-meaning defaults.

## Validation Expectations

- `make prompt-audit`
- `git diff --check`

## Final Response Format

- Summarize the installed brief contract.
- List the files changed.
- State the validation run.
- End with `STATUS: GREEN|YELLOW|RED`.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
