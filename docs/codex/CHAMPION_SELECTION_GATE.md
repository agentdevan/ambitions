# Champion Selection Gate

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite
> Dispositions: rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Active Codex gate.

Future batches are not allowed to create new implementation owners unless:

1. no existing owner exists, or
2. the batch explicitly supersedes an owner, or
3. the batch creates a scoped helper under a canonical owner.

Existing code champion coverage is mandatory. Future implementation work may not proceed until every existing Swift file/type is classified and every product/runtime concept has a canonical owner or explicit owner-review boundary.

Any replacement must:

- update `docs/audits/intelligence-consolidation/SUPERSESSION_LEDGER.md`
- update `docs/audits/intelligence-consolidation/BEST_CODE_RESCUE_LEDGER.md` if useful old behavior exists
- update `docs/audits/intelligence-consolidation/CANONICAL_OWNER_MAP.md`
- update `docs/codex/canonical-owner-map.yml`
- preserve tests/proof or add replacements
- avoid broad implementation claims until proof passes

No batch may create a new canonical owner just to bypass the parallel implementation guard.

Concepts listed in `docs/codex/concept-lock-registry.yml` are blocked for ordinary feature/runtime/product trains until their Champion Merge queue item is closed Green or accepted Yellow with owner boundary. Source-changing work on locked concepts must be a Champion Merge or owner-review resolution batch.

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
