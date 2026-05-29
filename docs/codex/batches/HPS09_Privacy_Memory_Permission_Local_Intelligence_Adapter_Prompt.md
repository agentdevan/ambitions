# HPS09 Privacy Memory Permission Local Intelligence Adapter Prompt

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-22647572, AMB28-same_source_file_targeted_by_multiple_active_batches-65376188, AMB28-same_surface_multiple_active_batches-66075429

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Complete / Accepted Yellow on 2026-05-06.
Train: HPS01-HPS12 Human Progress Systems Upgrade.
Type: Docs/privacy/intelligence architecture.

## Purpose

Run HPS09 to define the Privacy / Memory Permission and Local Intelligence
Adapter contract before future AOS/LDI local intelligence work. The contract
covers memory permission ledger, sensitive area classes, external-surface
redaction, deterministic fallback, local/on-device adapter strategy,
structured extraction boundaries, tool-calling approval boundaries, hidden
mutation blocks, model dependency blocks, and performance/battery boundaries.

HPS09 is docs-only. It does not implement memory permission runtime, local
model runtime, extraction, classification, tool calling, persistence, schema,
sync, cloud, UI, external-surface behavior, model invocation, legal/privacy
certification, or release claims.

## Locked HPS09 Decisions

- Deterministic fallback is required before any model-dependent behavior.
- Core correctness must not require model availability.
- Inferred memories are not facts until reviewed where risk requires it.
- Sensitive areas are private by default.
- External surfaces receive redacted summaries only.
- Tool calling cannot mutate state without user-reviewed proposal and receipt.
- No hosted AI, cloud, user-data server, or model-runtime claim is introduced.
- Performance and battery boundaries are required before future adapters.

## Allowed Files

- `docs/canon/Ambitions_Privacy_Memory_Permission_Local_Intelligence_Adapter_Architecture.md`
- `docs/codex/batches/HPS09_Privacy_Memory_Permission_Local_Intelligence_Adapter_Prompt.md`
- `docs/audits/hps09-privacy-memory-permission-local-intelligence-adapter-report.md`
- `docs/codex/batch-trains/HPS01_HPS12_HUMAN_PROGRESS_SYSTEMS_UPGRADE_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_HPS_COMPLETION_ORDER_OVERLAY.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_DEPENDENCY_GRAPH.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Forbidden Files

- Production Swift files.
- Route/raw-value files.
- Persistence/schema/migration files.
- Sync/cloud/account/backend files.
- Model runtime, adapter, extraction, classification, or tool-calling files.
- Recommendation runtime or personalization files.
- Widget, notification, Live Activity, App Intent, or external-surface
  behavior files.
- Workflow, signing, entitlement, or generated project files.
- Legal/release/App Store/TestFlight claim files.

## Acceptance

- Memory permission object families, required privacy fields, permission
  states, sensitive area classes, external-surface redaction, deterministic
  fallback tier ladder, structured extraction boundary, tool approval states,
  performance/battery boundaries, surface projection rules, API contract
  families, and regression oracle scenarios are defined.
- Privacy, memory, local intelligence, and tool behavior remain review-bound,
  redacted, deterministic-first, and no-hidden-mutation.
- No runtime, model invocation, schema, sync, UI, external behavior,
  professional advice, legal/privacy certification, or release claim is
  introduced.

## Validation

- `git status --short`
- `git diff --check`
- HPS privacy/local intelligence architecture scan
- relevant CQS scans
- HPS advisory scripts checked for presence
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Next Batch

HPS10 AI Governance + Evaluation Assurance Lab.

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
