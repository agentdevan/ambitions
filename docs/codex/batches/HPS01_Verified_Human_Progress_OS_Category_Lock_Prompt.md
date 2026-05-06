# HPS01 Verified Human Progress OS Category Lock Prompt
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
