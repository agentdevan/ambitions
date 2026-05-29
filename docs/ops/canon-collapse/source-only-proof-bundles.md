# Source-Only / Missing-Proof Bundle Analysis

Status: GREEN
Generated UTC: 2026-05-29T00:43:43Z
Owner: CANON-COLLAPSE-002
Linear issue: AMB-288

## Purpose

This report accounts for all active source-only / missing-proof candidates and groups them into bounded action bundles.

It does not modify source code, product truth, prompts, or trains.

## Required read order

- docs/truth/README.md
- docs/truth/PRODUCT_DESIGN_TRUTH.md
- docs/truth/PRODUCT_MOAT_TRUTH.md
- docs/truth/IMPLEMENTATION_TRUTH.md
- docs/truth/RELEASE_TRUTH.md
- docs/truth/CODEX_PROCESS_TRUTH.md
- docs/truth/HISTORICAL_POLICY.md
- docs/ops/batch-ledger/batch-ledger.json
- docs/ops/batch-ledger/conflict-report.json
- docs/ops/batch-ledger/conflict-action-workflow.md
- docs/ops/canon-collapse/active-canon-collapse-candidates.md
- docs/ops/canon-collapse/active-canon-collapse-candidates.json
- docs/ops/change-protocol/change-request-template.md
- docs/ops/change-protocol/change-impact-check.md
- docs/ops/change-protocol/implementation-prompt-template.md
- docs/ops/change-protocol/post-implementation-proof-reconciliation.md

## Summary

- Total source-only / missing-proof candidates: 321
- Bundle count: 4
- Maximum bundle limit: 7

### Candidates by bundle

- finish-real-source-proof: 8
- manual-triage-remainder: 3
- merge-overlap-before-proof: 225
- rewrite-authority-before-proof: 85

### Candidates by path kind

- codex_batch_doc: 89
- codex_doc: 172
- other: 15
- prompt_batch: 45

### Candidates by proof state

- audit: 155
- source-only: 166

## Next bounded action bundle

- Bundle ID: finish-real-source-proof
- Title: Finish proof for source-bound implementation candidates
- Recommended disposition: Finish proof
- Candidate count: 8
- Reason: Create one proof-finish implementation issue only for candidates that can be proven with current local commands.

## Bundle files

- docs/ops/canon-collapse/bundles/finish-real-source-proof.md
- docs/ops/canon-collapse/bundles/merge-overlap-before-proof.md
- docs/ops/canon-collapse/bundles/rewrite-authority-before-proof.md
- docs/ops/canon-collapse/bundles/manual-triage-remainder.md

## Bundles

### Finish proof for source-bound implementation candidates

- Bundle ID: finish-real-source-proof
- Recommended disposition: Finish proof
- Candidate count: 8
- Proof requirement: Run or document the narrowest applicable build/test/proof command for items that reference source, test, scripts, or validation commands.
- Next action: Create one proof-finish implementation issue only for candidates that can be proven with current local commands.

### Merge or sequence overlapping candidates before proof

- Bundle ID: merge-overlap-before-proof
- Recommended disposition: Merge
- Candidate count: 225
- Proof requirement: Resolve overlapping batch/source/surface ownership before proof can be trusted.
- Next action: Create one merge/sequencing issue for duplicate or overlapping active work.

### Rewrite authority references before proof

- Bundle ID: rewrite-authority-before-proof
- Recommended disposition: Rewrite
- Candidate count: 85
- Proof requirement: Add exact source-of-truth references or remove stale authority before implementation proof is meaningful.
- Next action: Create one rewrite issue for active prompts/batches missing source-of-truth authority.

### Manual triage remainder

- Bundle ID: manual-triage-remainder
- Recommended disposition: Expedite
- Candidate count: 3
- Proof requirement: Owner decision required because evidence is ambiguous.
- Next action: Create one manual triage issue only if this bucket remains non-empty after the other bundles.


## Non-claims

- This analysis does not modify source code.
- This analysis does not modify product truth.
- This analysis does not modify prompts or trains.
- This analysis does not mark source-only work complete.
- This analysis does not create one issue per candidate.
- This analysis does not prove implementation, build, tests, accessibility, performance, device, privacy, legal, TestFlight, App Store, or release readiness.
- Linear status is not repo truth.