# AMB-FE-BE Implementation Train

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-authority

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Installed docs/prompts package; not execution proof
Purpose: Runner-compatible train installer for the Ambitions Frontend + Backend Implementation train
Authority: Subordinate to `docs/truth/*`, current source evidence, and active batch state

This directory installs the train scaffolding only. It does not implement the frontend, backend, or release proof.

## Installed assets

- [Manifest](./AMB-FE-BE-IMPLEMENTATION-MANIFEST.md)
- [Status](./AMB-FE-BE-IMPLEMENTATION-STATUS.md)
- [Risks](./AMB-FE-BE-IMPLEMENTATION-RISKS.md)
- [Execution Order](./AMB-FE-BE-EXECUTION-ORDER.md)
- [Contracts](./AMB-FE-BE-CONTRACTS.md)

## Prompt set

Runner prompts live in `prompts/batches/amb-fe-be/` and follow the active runner header convention.

## Non-claims

- This package does not prove implementation, validation, accessibility, device behavior, privacy approval, or release readiness.
- This package does not change app source, project wiring, signing, or workflows.
- This package does not override the active queue truth in `docs/codex/BATCH_REGISTRY.md` or `docs/codex/CONTEXT_INDEX.md`.

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
