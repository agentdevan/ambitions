# AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-authority, merge-or-sequence-file-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: supporting install report
Supporting note: This report supports current Ambitions UI Studio work but does not override `docs/truth/*`.

## Summary

Installed a bounded UI Studio control-plane layer under `frontend/visual-encyclopedia/`, added a screen-state matrix, updated the frontend portal references, created a review board, and generated the flagship prompt family under `prompts/batches/ui-flagship/`.

## Installed artifacts

- `frontend/visual-encyclopedia/UI_STUDIO_OPERATING_SYSTEM.md`
- `frontend/visual-encyclopedia/trace/UI_STUDIO_SCREEN_STATE_MATRIX.md`
- `frontend/visual-encyclopedia/FRONTEND_AUTHORITY_INDEX.md`
- `frontend/README.md`
- `docs/codex/review-boards/AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01.md`
- `prompts/batches/ui-flagship/UI-STUDIO-01-SURFACE-BRIEF-SYSTEM.md`
- `prompts/batches/ui-flagship/UI-STUDIO-02-TOKENS-AND-MATERIALS-REVIEW.md`
- `prompts/batches/ui-flagship/UI-STUDIO-03-REALITY-MERIDIAN-ART-DIRECTION.md`
- `prompts/batches/ui-flagship/UI-STUDIO-04-START-HERE-COMMAND-OBJECT.md`
- `prompts/batches/ui-flagship/UI-STUDIO-05-FIVE-SURFACE-COMPOSITION.md`
- `prompts/batches/ui-flagship/UI-STUDIO-06-CLOSURE-RECOVERY-INTERACTIONS.md`
- `prompts/batches/ui-flagship/UI-STUDIO-07-TRUST-CONTINUITY-UX.md`
- `prompts/batches/ui-flagship/UI-STUDIO-08-ONBOARDING-CATEGORY-UX.md`
- `prompts/batches/ui-flagship/UI-STUDIO-09-PREVIEW-SCREENSHOT-MATRIX.md`
- `prompts/batches/ui-flagship/UI-STUDIO-10-FAANG-LEVEL-UI-RED-TEAM.md`

## Validation status

Validation results for this turn:

- `python3 scripts/ambitions-runner-access-guard.py` -> GREEN
- `make batch-self-check` -> GREEN
- `make prompt-audit` -> YELLOW, because prompt-like support/template/historical files are present but no active runnable prompt is missing runner metadata
- `python3 scripts/ambitions-frontend-source-bindings.py` -> GREEN
- `python3 scripts/ambitions-frontend-proof-contract-check.py` -> GREEN
- `python3 scripts/ambitions-visual-100-anti-generic-check.py` -> PASS
- `python3 scripts/ambitions-visual-100-accessibility-adhd-check.py` -> PASS
- `python3 scripts/ambitions-visual-100-gate-check.py` -> PASS
- `git diff --check` -> GREEN after the install edits
- `python3 scripts/ambitions-frontend-drift-check.py` -> RED, due pre-existing generated prompt / signature-instrument gaps outside this bounded installer scope

## Remaining risks

- The frontend drift checker still reports repository-wide red state unrelated to the installed UI Studio docs.
- The generated prompt family under `prompts/generated/frontend/` still lacks the signature-instrument requirements that the drift checker expects.

## Non-claims

This report does not claim implementation, device proof, accessibility proof, or release readiness.

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
