# RHC06 Repo Hygiene Closeout And Handoff Prompt
<!-- markdownlint-disable MD013 -->

## Batch Identity

- Batch ID: RHC06
- Title: Repo Hygiene Closeout And Handoff
- Train: RHC01-RHC06 Repo Hygiene Closeout Train
- Default global placement: after RHC05 and only after active LDI/AOS/FCP/PFC tails are complete or accepted Yellow
- Type: audit/handoff

## Status

Queued. Do not run until RHC01-RHC05 are Green or accepted Yellow.

## Purpose

Close the repo hygiene train with a final evidence-bound scorecard, remaining Yellow register, and handoff state that does not claim release, App Store, TestFlight, legal/privacy, public accessibility, or physical-device readiness.

## Source Truth Files To Read First

- README.md
- AGENTS.md
- .codex/reports/current-run-state.md
- .codex/reports/current-batch-train-state.md
- docs/codex/RESUME_GLOBAL_BATCH_TRAIN.md
- docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md
- docs/codex/batch-trains/RHC01_RHC06_REPO_HYGIENE_CLOSEOUT_TRAIN.md
- docs/audits/rhc01-repo-hygiene-triage-owner-map-report.md
- docs/audits/rhc02-large-file-extraction-module-boundary-report.md if present
- docs/audits/rhc03-placeholder-stub-compatibility-seam-cleanup-report.md if present
- docs/audits/rhc04-stale-copy-docs-generated-artifact-hygiene-report.md if present
- docs/audits/rhc05-validation-script-noise-allowlist-hardening-report.md if present
- docs/audits/pfc01-repo-build-system-inventory-report.md
- docs/audits/pfc02-architecture-boundary-module-map-report.md
- docs/audits/pfc03-dead-code-prompt-artifact-naming-smell-audit-report.md
- docs/codex/BATCH_REGISTRY.md
- docs/codex/CONTEXT_INDEX.md

## Required Preflight Checks

- `git status --short`
- `git branch --show-current`
- `scripts/global-train-next-batch.sh || true`
- `scripts/global-train-status-summary.sh || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Allowed Files

- docs/audits/**
- docs/codex/**
- .codex/reports/** only for evidence-bound status updates
- scripts/global-train-next-batch.sh and scripts/global-train-status-summary.sh only if queue ordering needs a final safe pointer update

## Forbidden Scope

- No production Swift changes.
- No route/raw-value, persistence/schema, sync/cloud, signing, entitlement, hosted workflow, release, App Store, TestFlight, physical-device, legal/privacy, or public accessibility claim.
- No deleting historical audit evidence.
- No marking Yellow items Green without proof.

## Required Work

1. Confirm the active batch pointer permits RHC06.
2. Read RHC01-RHC05 reports and collect remaining Yellows.
3. Produce a scorecard for architecture/file size, placeholder/stub seams, compatibility vocabulary, stale copy/docs, generated/local artifacts, and validation-script noise.
4. Mark each remaining item as Green resolved, Yellow owned, or Red blocking.
5. Update registry/context/run-state only if safe and evidence-bound.
6. Confirm no RHC work claims final release or device readiness.

## Green Criteria

RHC06 closes Green when repo hygiene debt is either resolved or explicitly Yellow-owned with no unowned blocking hygiene Red, and Codex can safely continue global completion.

## Yellow Criteria

Remaining cleanup exists but has a named owner, proof requirement, and recheck condition.

## Red Criteria

Unowned blocking hygiene debt remains, source truth conflicts, active batch selection is interrupted, or the report claims readiness beyond evidence.

## Required Evidence Outputs

- `docs/audits/rhc06-repo-hygiene-closeout-handoff-report.md`

## Commit Message Recommendation

`Run RHC06 Repo Hygiene Closeout And Handoff`

## Next Safe Prompt / Next Gate

After Green or accepted Yellow, ask global train for the next eligible batch from repo evidence.
