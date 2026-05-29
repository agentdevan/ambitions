# Post-PK Batch Bundles

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-38335713, AMB28-stale_or_unknown_active_status-83340150

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-file-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: active bundle map after PK41  
Authority: execution accelerator only; canonical queue still controls order

## Purpose

Bundles preserve serial batch IDs while reducing repeated planning overhead. They do not merge batches or weaken proof boundaries.

## Bundles

| Bundle | Batch IDs | Intent |
| --- | --- | --- |
| `pk-tail` | PK34-PK41 | Finish remaining Platform Kernel if explicitly allowed |
| `source-atlas-core` | SA07-SA10C | Claim/requirement/proof/freshness/capability core |
| `source-atlas-runtime` | SA11-SA16 | Store/query/source-needed/offline/container runtime |
| `source-atlas-importers` | SA17-SA24 | URL/text/PDF/OCR/image/classifier/extractor import lane |
| `source-atlas-review-pack` | SA25-SA32 | Review sheet, packs, diff/hash/freshness/adapters/UI handoff |
| `ldi-tail` | LDI17-LDI22 | Living Dream tail, dependency gated |
| `aos-tail` | AOS24-AOS30 | AmbitionsOS tail, dependency gated |
| `fcp-closeout` | FCP27-FCP30 | Flagship completion closeout |
| `pfc-closeout` | PFC31-PFC40 | Platform/framework/compliance closeout |
| `repo-hygiene` | RHC01-RHC06 | Repo hygiene closeout |

## Command

```bash
python3 scripts/ambitions-bundle-next-batches.py --next
python3 scripts/ambitions-bundle-next-batches.py --bundle source-atlas-core
```

## Rule

Bundles are planning context. The train still installs, reviews, commits, advances, and pushes each batch ID independently.

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
