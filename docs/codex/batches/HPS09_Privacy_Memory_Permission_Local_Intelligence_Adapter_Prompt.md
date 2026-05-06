# HPS09 Privacy Memory Permission Local Intelligence Adapter Prompt
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
