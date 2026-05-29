# Post-PK Proof-Light Policy

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite
> Dispositions: rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: active speed policy after PK41  
Authority: subordinate to truth files and terminal proof gates

## Principle

Post-PK execution should favor fast installation plus honest proof boundaries.

`Green` requires focused proof for the touched owner. If focused proof is deferred, use `installed_unverified` or Accepted Yellow with an explicit owner and next proof path.

## Lane Matrix

| Lane | Proof during install | Heavy proof timing |
| --- | --- | --- |
| docs_only | `git diff --check`, prompt/claim scan on changed files | final bundle gate |
| prompt_only | prompt audit, queue consistency | final bundle gate |
| state_only | state-advance validation | immediate |
| model_only | focused model tests if Swift touched | bundle stabilization |
| service_only | focused service tests if available | bundle stabilization |
| source_atlas | focused SA model/query/importer tests | SA bundle gate |
| ui_preview | view-model/previews/screenshots only when claimed | visual QA gate |
| repo_hygiene | path/diff/generation checks | RHC terminal gate |
| release_terminal | batch-defined full proof | immediate |

## Accepted Yellow

Allowed for:

- simulator/environment failures,
- broad build blockers outside touched owner seam,
- missing optional visual proof when no visual completion is claimed,
- unavailable physical device proof outside terminal gates.

Not allowed for:

- compile failure in touched owner,
- invalid JSON/state files,
- completed-batch reactivation,
- missing prompt,
- false release/readiness/accessibility/device/performance/privacy/legal claims,
- unknown root cause.

## Proof-Lite Closeout Language

Use `installed_unverified` only when implementation is intentionally installed without focused owner proof. Do not use `Green` unless proof exists.

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
