# RHC05 Validation Script Noise And Allowlist Hardening Prompt
<!-- markdownlint-disable MD013 -->

## Batch Identity

- Batch ID: RHC05
- Title: Validation Script Noise And Allowlist Hardening
- Train: RHC01-RHC06 Repo Hygiene Closeout Train
- Default global placement: after RHC04 and only after active LDI/AOS/FCP/PFC tails are complete or accepted Yellow
- Type: scripts/docs; implementation only for non-mutating validation helpers

## Status

Queued. Do not run until RHC01-RHC04 prove validation noise is slowing or confusing later review.

## Purpose

Reduce known advisory noise in architecture, prompt-smell, product-drift, doc QA, and release-claim scans without weakening the validators that protect Ambitions from generic app drift, release-claim drift, unsafe cleanup, or prompt-built residue.

## Source Truth Files To Read First

- README.md
- AGENTS.md
- .codex/reports/current-run-state.md
- docs/codex/batch-trains/RHC01_RHC06_REPO_HYGIENE_CLOSEOUT_TRAIN.md
- docs/audits/rhc01-repo-hygiene-triage-owner-map-report.md
- docs/audits/rhc04-stale-copy-docs-generated-artifact-hygiene-report.md if present
- docs/audits/pfc01-repo-build-system-inventory-report.md
- docs/audits/pfc02-architecture-boundary-module-map-report.md
- docs/audits/pfc03-dead-code-prompt-artifact-naming-smell-audit-report.md
- docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md
- docs/codex/CODEX_QUALITY_SYSTEM_GATE_MATRIX.md
- docs/codex/BATCH_REGISTRY.md
- docs/codex/CONTEXT_INDEX.md

## Required Preflight Checks

- `git status --short`
- `git branch --show-current`
- `scripts/global-train-next-batch.sh || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/cqs-architecture-boundary-scan.sh Native/Ambitions Sources AppUI/Sources Native/AmbitionsTests || true`
- `scripts/cqs-prompt-built-smell-scan.sh Native || true`
- `scripts/cqs-prompt-built-smell-scan.sh Sources || true`
- `scripts/cqs-product-drift-scan.sh Native || true`
- `scripts/release-claim-safety-scan.sh || true`

## Allowed Files

- scripts/cqs-*.sh
- scripts/*claim*scan*.sh
- scripts/run-doc-qa.sh only if needed and safe
- docs/codex/**
- docs/audits/**

## Forbidden Scope

- No production Swift changes.
- No test deletion.
- No broad regex removal.
- No allowlist that hides user-facing drift, release claims, unsupported compliance claims, or architecture breaks.
- No conversion of blocking Reds into warnings.
- No hosted workflow files.

## Required Work

1. Confirm active batch pointer still permits RHC.
2. Reproduce current advisory noise with existing scripts.
3. Classify each noisy hit as legitimate allowlist, real finding, historical-only, or owner-blocked.
4. Add narrow allowlists only for legitimate, named, stable false positives.
5. Add comments near allowlists explaining why the exception is safe.
6. Re-run the same scans and prove they still catch real forbidden patterns where feasible.

## Green Criteria

RHC05 closes Green when script noise is reduced or proven not worth changing, validators remain strict, scans still detect real drift, and every allowlist has a named source-truth justification.

## Yellow Criteria

A script remains noisy because a later owner must decide whether the underlying source is legitimate; owner and recheck condition are recorded.

## Red Criteria

A validator is weakened, a release/privacy/legal/public-accessibility claim can pass without proof, product-drift detection is hidden, or active batch selection is interrupted.

## Required Evidence Outputs

- `docs/audits/rhc05-validation-script-noise-allowlist-hardening-report.md`

## Commit Message Recommendation

`Run RHC05 Validation Script Noise And Allowlist Hardening`

## Next Safe Prompt / Next Gate

After Green or accepted Yellow, ask global train for next eligible batch. Expected next RHC gate when safe: RHC06.
