# RHC02 Large File Extraction And Module Boundary Prompt
<!-- markdownlint-disable MD013 -->

## Batch Identity

- Batch ID: RHC02
- Title: Large File Extraction And Module Boundary
- Train: RHC01-RHC06 Repo Hygiene Closeout Train
- Default global placement: after RHC01 and only after the active full-stack LDI/AOS/FCP/PFC tails are complete or accepted Yellow
- Type: implementation/tests when still needed

## Status

Queued. Do not run until RHC01 proves this cleanup is still needed and safe.

## Purpose

Reduce known oversized-file and mixed-boundary risk without changing product behavior, routes, persistence, sync, release posture, or user-facing canon.

## Source Truth Files To Read First

- README.md
- AGENTS.md
- .codex/reports/current-run-state.md
- docs/codex/batch-trains/RHC01_RHC06_REPO_HYGIENE_CLOSEOUT_TRAIN.md
- docs/audits/rhc01-repo-hygiene-triage-owner-map-report.md
- docs/audits/pfc02-architecture-boundary-module-map-report.md
- docs/audits/pfc03-dead-code-prompt-artifact-naming-smell-audit-report.md
- docs/codex/BATCH_REGISTRY.md
- docs/codex/CONTEXT_INDEX.md

## Required Preflight Checks

- `git status --short`
- `git branch --show-current`
- `scripts/global-train-next-batch.sh || true`
- `scripts/cqs-architecture-boundary-scan.sh Native/Ambitions Sources AppUI/Sources Native/AmbitionsTests || true`

## Candidate Owner Files

RHC02 may inspect and, only when still oversized or mixed-boundary, extract from:

- `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`
- `Native/Ambitions/Features/Today/TodayFeatureService.swift`
- `Native/Ambitions/Features/Profile/ProfileScreen.swift`
- `Native/Ambitions/Features/Plan/PlanFeatureService.swift`
- `Native/Ambitions/Features/Profile/ProfileFeatureService.swift`
- `Native/Ambitions/Features/Plan/PlanScreen.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureModels.swift`
- `Native/Ambitions/Features/Today/TodayPanels.swift`
- Large domain/shared files named by RHC01 only when focused tests exist.

## Forbidden Scope

- No behavior rewrite.
- No new top-level destinations.
- No route/raw-value changes.
- No persistence/schema changes.
- No sync/cloud/backend/hosted AI changes.
- No release, legal/privacy, public accessibility, App Store, TestFlight, or physical-device claims.
- No extraction that makes tests weaker or hides coverage gaps.

## Required Work

1. Confirm RHC01 owner map and current line-count/boundary evidence.
2. Choose the smallest extraction slice with the highest cleanup value.
3. Move pure helpers/projectors/models into owner-specific files without behavior change.
4. Add or run focused tests for the extracted owner behavior.
5. Re-run architecture and product drift scans.
6. Record any remaining oversized owners as Yellow with owner and recheck condition.

## Green Criteria

RHC02 closes Green when at least one high-priority owner is safely extracted or all candidates are proven already resolved, focused tests pass or no-op proof is documented, and no active full-stack batch was interrupted.

## Yellow Criteria

A candidate remains oversized but cannot be safely split without a later feature owner, device proof, or larger test harness; owner and recheck condition are recorded.

## Red Criteria

Behavior changes without proof, route/raw/persistence break, weakened tests, expanded oversized files without justification, or active batch interruption.

## Required Evidence Outputs

- `docs/audits/rhc02-large-file-extraction-module-boundary-report.md`

## Commit Message Recommendation

`Run RHC02 Large File Extraction And Module Boundary`

## Next Safe Prompt / Next Gate

After Green or accepted Yellow, ask global train for next eligible batch. Expected next RHC gate when safe: RHC03.
