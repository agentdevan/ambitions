# FL04 Searchable Life Recall Contract Prompt

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Completed Green on 2026-05-05.
Train: FL01-FL06 Found Life Layer.
Type: Docs/domain/trust contract.

## Purpose

Run FL04 to define the Searchable Life Recall contract: what recall can answer, what proof/source/privacy/freshness must be shown, and what must never be claimed or exposed.

FL04 is docs-only. It does not implement search, memory runtime, AI runtime, sync, persistence, production Swift, schema, or user-facing recall behavior.

## Locked FL04 Decisions

- Recall never presents unsupported inference as fact.
- Every recall answer needs source, freshness, privacy class, review state, and correction/deletion path.
- Sensitive content is private by default and external-surface blocked unless explicitly implemented and reviewed later.
- Recall uses review/source/proof states, not AI confidence or AI verification.
- Recall cannot mutate commitments, goals, plans, receipts, or memory silently.

## Allowed Files

- `docs/canon/Ambitions_Found_Life_Layer.md`
- `docs/codex/batch-trains/FL01_FL06_FOUND_LIFE_LAYER_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_DEPENDENCY_GRAPH.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `docs/codex/batches/FL04_Searchable_Life_Recall_Contract_Prompt.md`
- `docs/audits/fl04-searchable-life-recall-contract-report.md`

## Forbidden Files

- Production Swift files.
- Route/raw-value files.
- Persistence/schema files.
- Sync/cloud files.
- Monetization files.
- Legal/release claim files.
- Workflow/signing/CI files.
- Generated project files.

## Acceptance

- Recall answer states and source/freshness/privacy/review requirements are defined.
- Unsupported inference as fact is forbidden.
- Sensitive external exposure is forbidden by default.
- No runtime recall, durable memory, AI, sync, legal/privacy, or release claim is introduced.

## Next Batch

FL05 Option Value / Pivot Preservation Model.

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
