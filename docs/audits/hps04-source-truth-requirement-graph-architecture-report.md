# HPS04 Source Truth Requirement Graph Architecture Report
<!-- markdownlint-disable MD013 -->

Result: Accepted Yellow
Date: 2026-05-06
Train: HPS01-HPS12 Human Progress Systems Upgrade Train
Batch: HPS04 Source Truth + Requirement Graph Architecture
Owner: Source Truth / Goal Path / LDI

## Summary

HPS04 adds Source Truth and Requirement Graph architecture as docs-domain
source truth. It defines requirement object families, requirement state fields,
claim states, source quality states, freshness and uncertainty states,
requirement edge families, source conflict behavior, recommendation source
boundaries, Source Atlas inheritance, and API contract families for requirement
reads, proposals, conflicts, and projections.

No runtime source truth system, source pack, scraping, OCR, PDF or URL import,
source refresh, claim extraction, requirement database, schema, sync, account,
hosted AI, Source Atlas runtime, official requirement behavior, professional
advice product, or UI was implemented.

## Files Read

- `docs/canon/Ambitions_Human_Progress_Systems_Upgrade.md`
- `docs/canon/Ambitions_Human_Progress_Graph_API_Architecture.md`
- `docs/canon/Ambitions_Verified_Proof_Ledger_Portability_Architecture.md`
- `docs/codex/batch-trains/HPS01_HPS12_HUMAN_PROGRESS_SYSTEMS_UPGRADE_TRAIN.md`
- `docs/codex/HPS_GATE_MATRIX.md`
- `docs/codex/HPS_CROSS_TRAIN_INTEGRATION_MAP.md`
- `docs/codex/GLOBAL_HPS_COMPLETION_ORDER_OVERLAY.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Files Changed

- `docs/canon/Ambitions_Source_Truth_Requirement_Graph_Architecture.md`
- `docs/codex/batches/HPS04_Source_Truth_Requirement_Graph_Architecture_Prompt.md`
- `docs/audits/hps04-source-truth-requirement-graph-architecture-report.md`
- HPS train manifest status
- global-order, registry, context, dependency, and run-state docs

## HPS Primitives Touched

- Source Truth / Requirement Graph
- claim state
- source quality
- freshness and uncertainty
- proof-to-requirement mapping inheritance
- source conflict behavior
- recommendation source boundary
- Source Atlas inheritance

## HPS Gates Invoked

- Source Truth / Requirement Graph Gate
- Verified Proof Ledger Gate
- Human Progress Graph Gate
- Privacy / Memory Permission Gate
- Hidden Mutation Gate
- Sensitive Surface Gate
- Vertical Expansion No-Build Gate
- No-Implementation-Claim Gate
- Five-Tab Cohesion Gate

## No-Sprawl Proof

HPS04 adds an internal source truth and requirement graph architecture document
only. It creates no official requirement database, school/workforce product,
professional advice product, source marketplace, hosted source service, API
product, public recommendation engine, visible requirement control surface, or
eligibility certainty claim.

## Five-Tab Coherence Proof

The projection contract maps requirement facts back into Today source-review
steps, Goals path/proof requirements, Capture placement/source-needed review,
Plan deadline/capacity constraints, and You source/correction/privacy/export
controls. External surfaces receive redacted non-official summaries only.

## Validation Run

- `git status --short`
- `git diff --check`
- HPS/source requirement architecture scan
- targeted CQS scans
- HPS advisory scripts checked for presence
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Validation Result

- `git diff --check` passed.
- HPS/source requirement architecture scan confirmed requirement object
  families, requirement state fields, claim/source-quality/freshness/
  uncertainty states, requirement edge families, read/proposal/conflict/
  projection API contract families, Source Atlas inheritance, no silent
  requirement officialization, and no-claim boundaries.
- Targeted CQS product drift scans returned `CQS_PRODUCT_DRIFT_HITS=0`.
- Targeted CQS privacy/security claim scans returned
  `CQS_PRIVACY_SECURITY_CLAIM_HITS=0`.
- HPS advisory scripts were checked and are not yet present:
  `scripts/hps-no-sprawl-scan.sh`, `scripts/hps-moat-coverage-scan.sh`, and
  `scripts/hps-claim-boundary-scan.sh`.
- `scripts/run-doc-qa.sh || true` completed with the existing advisory
  backlog: stale-guidance/deprecated-language hits, markdownlint backlog, and
  lychee with 0 errors / 1 redirect. Logs were written under
  `docs/audits/doc-qa/20260506-121153-*`.
- `scripts/batch-train-gate-check.sh || true` completed with the expected
  dirty-tree Yellow hint for the in-progress HPS04 diff.

## Yellow Items

- Result is Accepted Yellow because physical HPS advisory scripts/skills are
  still specified but not executable.
- HPS04 is architecture only; Source Atlas, AOS13, AOS06, LDI05, LDI08, and
  recommendation/export/import batches must implement typed source and
  requirement behavior later after HPS gates are satisfied.

## Hard Red Status

No Hard Red known. No production behavior, schema, persistence, source runtime,
source ingestion, sync, AI runtime, professional advice, official requirement
database, UI, release, platform, legal, accessibility, or acquisition claim
changed.

## Rollback Path

Revert the HPS04 commit to remove the source truth architecture document,
prompt, report, and state-doc updates. No source-code or generated rollback is
needed.

## Next Eligible Batch

HPS05 Commitment Memory + Searchable Life Recall Architecture.
