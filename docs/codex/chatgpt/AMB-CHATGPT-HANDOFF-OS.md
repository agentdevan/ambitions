# AMB-CHATGPT-HANDOFF-OS

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: supporting operating guide

This document defines the subordinate ChatGPT handoff layer for Ambitions.
It exists to turn a ChatGPT conversation into a bounded, executable Codex
prompt without creating a second authority root.

## What this layer does

- Converts user intent into a runner-compatible batch prompt.
- Forces active truth inspection before any patching or claim writing.
- Keeps scope narrow enough for a single bounded Codex pass.
- Preserves the active Ambitions canon and top-level IA.

## What this layer does not do

- It does not change product canon.
- It does not override `docs/truth/*`.
- It does not replace `scripts/ambitions-codex-train.sh`.
- It does not authorize app behavior, release claims, or implementation claims.

## Required flow

1. Identify the task type.
2. Inspect active truth first.
3. Identify the smallest safe file set.
4. Choose the correct prompt template.
5. Add the runner header.
6. State exact allowed and forbidden scope.
7. State validation and proof requirements.
8. State rollback expectations.

## Canon preserved by default

- Today / Goals / Capture / Time / You
- Time is active top-level IA.
- Plan is only an internal compatibility seam where active truth allows it.
- Local-first and proof-first behavior stays mandatory.

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
