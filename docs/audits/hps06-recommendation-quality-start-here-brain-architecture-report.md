# HPS06 Recommendation Quality Start Here Brain Architecture Report
<!-- markdownlint-disable MD013 -->

Result: Accepted Yellow
Date: 2026-05-06
Train: HPS01-HPS12 Human Progress Systems Upgrade Train
Batch: HPS06 Recommendation Quality + Start Here Brain Architecture
Owner: Recommendation Kernel / Today

## Summary

HPS06 adds Recommendation Quality and Start Here Brain architecture as
docs-domain source truth. It defines candidate families, candidate evidence
fields, eligibility gates, rejection gates, explanation contract, recovery
behavior, regression oracle scenarios, Start Here projection rules, and API
contract families for candidate generation, rejection, explanation, and
evaluation.

No recommendation runtime, candidate ranking, model logic, personalization,
persistence, schema, sync, cloud, AI runtime, UI, external-surface behavior, or
evaluation automation was implemented.

## Files Read

- `docs/canon/Ambitions_Human_Progress_Systems_Upgrade.md`
- `docs/canon/Ambitions_Human_Progress_Graph_API_Architecture.md`
- `docs/canon/Ambitions_Verified_Proof_Ledger_Portability_Architecture.md`
- `docs/canon/Ambitions_Source_Truth_Requirement_Graph_Architecture.md`
- `docs/canon/Ambitions_Commitment_Memory_Searchable_Life_Recall_Architecture.md`
- `docs/canon/AmbitionsOS_Recommendation_Kernel.md`
- `docs/codex/batch-trains/HPS01_HPS12_HUMAN_PROGRESS_SYSTEMS_UPGRADE_TRAIN.md`
- `docs/codex/HPS_GATE_MATRIX.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Files Changed

- `docs/canon/Ambitions_Recommendation_Quality_Start_Here_Brain_Architecture.md`
- `docs/codex/batches/HPS06_Recommendation_Quality_Start_Here_Brain_Architecture_Prompt.md`
- `docs/audits/hps06-recommendation-quality-start-here-brain-architecture-report.md`
- HPS train manifest status
- global-order, registry, context, dependency, and run-state docs

## HPS Primitives Touched

- Recommendation Quality
- Start Here Brain
- candidate generation/rejection
- explanation contract
- recovery recommendation behavior
- regression oracle

## HPS Gates Invoked

- Recommendation Quality Gate
- Today / Start Here Gate
- Source Truth Gate
- Verified Proof Ledger Gate
- Commitment Memory / Recall Gate
- Privacy / Memory Permission Gate
- Hidden Mutation Gate
- Sensitive Surface Gate
- No-Implementation-Claim Gate

## No-Sprawl Proof

HPS06 adds an internal recommendation quality architecture document only. It
creates no recommendation runtime, Start Here UI, many-suggestion surface,
chat-first surface, sixth tab, model behavior, personalization engine, external
recommendation behavior, professional advice product, or release/platform
claim.

## Five-Tab Coherence Proof

The Start Here projection rule preserves Today as one primary recommendation
object. Goals, Capture, Plan, and You receive recommendation evidence and
review context only through their owning surfaces. External surfaces receive
redacted summaries only.

## Validation Run

- `git status --short`
- `git diff --check`
- HPS/recommendation architecture scan
- targeted CQS scans
- HPS advisory scripts checked for presence
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Validation Result

- `git diff --check` passed.
- HPS/recommendation architecture scan confirmed candidate families, evidence
  fields, eligibility/rejection gates, explanation/recovery/regression oracle,
  candidate generation/rejection/explanation/evaluation API contract families,
  Start Here one-primary-object projection, and no-claim boundaries.
- Targeted CQS product drift scans returned `CQS_PRODUCT_DRIFT_HITS=0` after
  scanner-friendly wording repair.
- Targeted CQS privacy/security claim scans returned
  `CQS_PRIVACY_SECURITY_CLAIM_HITS=0`.
- HPS advisory scripts were checked and are not yet present:
  `scripts/hps-no-sprawl-scan.sh`, `scripts/hps-moat-coverage-scan.sh`, and
  `scripts/hps-claim-boundary-scan.sh`.
- `scripts/run-doc-qa.sh || true` completed with existing advisory backlog:
  stale-guidance/deprecated-language hits, markdownlint backlog, and lychee
  with 0 errors / 1 redirect. Logs were written under
  `docs/audits/doc-qa/20260506-132100-*`.
- `scripts/batch-train-gate-check.sh || true` completed with the expected
  dirty-tree Yellow hint for the in-progress HPS06 diff.

## Yellow Items

- Result is Accepted Yellow because physical HPS advisory scripts/skills are
  still specified but not executable.
- HPS06 is architecture only; AOS14, AOS18, FCP/FVQ visible Start Here work, and
  future evaluation batches must implement typed recommendation behavior and
  regression proof later after HPS gates are satisfied.

## Hard Red Status

No Hard Red known. No production behavior, schema, persistence, recommendation
runtime, model logic, personalization, sync, AI runtime, UI, external-surface
behavior, professional advice, release, platform, legal, accessibility, or
acquisition claim changed.

## Rollback Path

Revert the HPS06 commit to remove the recommendation architecture document,
prompt, report, and state-doc updates. No source-code or generated rollback is
needed.

## Next Eligible Batch

HPS07 Option Value + Pivot Preservation Architecture.
