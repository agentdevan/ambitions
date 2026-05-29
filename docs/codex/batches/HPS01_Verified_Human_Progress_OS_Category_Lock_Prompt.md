# HPS01 Verified Human Progress OS Category Lock Prompt

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Complete / Accepted Yellow as local category-lock reconciliation.
Date: 2026-05-06
Train: HPS01-HPS12 Human Progress Systems Upgrade Train
Owner: Product Strategy / Founder Vision

## Purpose

Close the first Human Progress Systems gate before AOS starts. HPS01 locks
Ambitions as the private operating system for verified human progress, preserves
the consumer wedge "Start here every day", and makes HPS a no-sprawl internal
architecture/governance layer rather than a new visible product surface.

## Source Truth

Read before execution:

- `docs/canon/Ambitions_Human_Progress_Systems_Upgrade.md`
- `docs/codex/batch-trains/HPS01_HPS12_HUMAN_PROGRESS_SYSTEMS_UPGRADE_TRAIN.md`
- `docs/codex/HPS_GATE_MATRIX.md`
- `docs/codex/HPS_CROSS_TRAIN_INTEGRATION_MAP.md`
- `docs/codex/HPS_CODEX_OS_UPGRADE_MAP.md`
- `docs/codex/HPS_MOAT_AND_ACQUISITION_READINESS_MAP.md`
- `docs/codex/GLOBAL_HPS_COMPLETION_ORDER_OVERLAY.md`
- `docs/audits/hps-source-truth-and-global-order-integration-report.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- run-state, registry, and context docs

## Allowed Files

- HPS01 prompt/report docs
- HPS train manifest status
- global-order, registry, context, dependency, and run-state docs

## Forbidden Files

- Production Swift
- Top-level navigation or new tab
- Broad all-at-once control surface, metric board,
  school/career/workforce/family/coaching product,
  marketplace, public credential network, hosted AI backend, user-data server,
  API platform, legal/release/App Store/TestFlight/acquisition readiness claim,
  dependency, project, signing, workflow, persistence, or entitlement changes

## Required Acceptance

- Category lock is explicit: Ambitions is the private operating system for
  verified human progress.
- HPS remains internal substrate/governance, not a visible destination.
- Five-tab coherence remains Today / Goals / Capture / Plan / You.
- Vertical expansion, acquisition readiness, and moat language stay strategy
  only and make no commercial or buyer-interest claim.
- AOS and LDI remain blocked until HPS01-HPS12 close Green or accepted Yellow
  with owners.

## Required Validation

Run:

- `git status --short`
- `git diff --check`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`
- HPS advisory scripts if present, or document absence
- relevant CQS scripts

## Closeout

Close Accepted Yellow if local validation is recorded, no forbidden files are
touched, the global order is reconciled to select HPS02 next, and missing HPS
physical scripts/skills are explicitly owner-gated for later HPS Codex OS work.

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
