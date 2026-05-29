# ChatGPT Handoff OS

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-authority

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: supporting install layer

This subtree is a subordinate ChatGPT-to-Codex handoff layer for Ambitions.
It supports repo work. It does not override `docs/truth/*`, `docs/codex/os/`,
or `.codex/`.

## Purpose

This layer gives future ChatGPT conversations a bounded way to produce
runner-compatible Ambitions prompts, decision logs, and review templates.

## Authority

Active truth still starts in `docs/truth/README.md`. If anything here conflicts
with active truth, the truth files win.

## Installed files

- `AMB-CHATGPT-HANDOFF-OS.md`
- `AMB-CHATGPT-TO-CODEX-PROMPT-STANDARD.md`
- `AMB-CHATGPT-REPO-QUESTION-PATTERNS.md`
- `AMB-CHATGPT-DECISION-LOG-STANDARD.md`
- `AMB-CHATGPT-LAUNCH-SCOPE-DECISIONS.md`
- `AMB-CHATGPT-FLAGSHIP-BAR.md`
- `AMB-CHATGPT-CODEX-HANDOFF-TEMPLATE.md`
- `AMB-CHATGPT-REVIEW-PROMPT-TEMPLATE.md`
- `AMB-CHATGPT-UI-PROMPT-TEMPLATE.md`
- `AMB-CHATGPT-BACKEND-PROMPT-TEMPLATE.md`
- `AMB-CHATGPT-APPLE-CONTINUITY-PROMPT-TEMPLATE.md`
- `AMB-CHATGPT-APP-STORE-HONESTY-PROMPT-TEMPLATE.md`
- `AMB-CHATGPT-REVIEW-BOARD-STANDARD.md`

## Operating rule

Use these docs to shape future handoffs and questions, not to replace active
repo truth or the existing Codex runner.

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
