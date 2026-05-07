# RHC03 Placeholder Stub And Compatibility Seam Cleanup Prompt
<!-- markdownlint-disable MD013 -->

## Batch Identity

- Batch ID: RHC03
- Title: Placeholder Stub And Compatibility Seam Cleanup
- Train: RHC01-RHC06 Repo Hygiene Closeout Train
- Default global placement: after RHC02 and only after active LDI/AOS/FCP/PFC tails are complete or accepted Yellow
- Type: implementation/tests when owner proof exists

## Status

Queued. Do not run until RHC01/RHC02 confirm this batch is still needed and safe.

## Purpose

Resolve Yellow-owned placeholder, stub, and compatibility seams without breaking routes, raw values, deep links, App Intents, widgets, notifications, external snapshots, persistence, tests, or preview behavior.

## Source Truth Files To Read First

- README.md
- AGENTS.md
- .codex/reports/current-run-state.md
- docs/codex/batch-trains/RHC01_RHC06_REPO_HYGIENE_CLOSEOUT_TRAIN.md
- docs/audits/rhc01-repo-hygiene-triage-owner-map-report.md
- docs/audits/rhc02-large-file-extraction-module-boundary-report.md if present
- docs/audits/pfc03-dead-code-prompt-artifact-naming-smell-audit-report.md
- docs/codex/BATCH_REGISTRY.md
- docs/codex/CONTEXT_INDEX.md

## Candidate Targets

RHC03 may inspect and clean only when owner proof exists:

- `Native/Ambitions/Support/FutureIntegrationPlaceholders.swift`
- `AppShellPlaceholderRouteView`
- `shell.placeholder`
- Preview/test/dev-only stub service naming
- Compatibility vocabulary around Profile/You, Insights, Habits/Ritual, ActiveFocus/TodayFocus, and failed taxonomy seams

## Required Preflight Checks

- `git status --short`
- `git branch --show-current`
- `scripts/global-train-next-batch.sh || true`
- `scripts/cqs-prompt-built-smell-scan.sh Native || true`
- `scripts/cqs-product-drift-scan.sh Native || true`

## Forbidden Scope

- No deletion based on name smell alone.
- No route/raw-value/deep-link/App Intent/widget/notification compatibility break.
- No migration or persistence/schema changes.
- No broad copy rewrite.
- No release, legal/privacy, App Store, TestFlight, physical-device, or public accessibility claims.
- No validator weakening.

## Required Work

1. Confirm active batch pointer still permits RHC.
2. For each candidate, prove whether it is production-facing, preview/test-only, compatibility-protective, or dead.
3. Rename, retire, or preserve seams only with owner-specific proof.
4. Run focused tests for any touched source owner.
5. Record every preserved seam as Green legitimate or Yellow owned.

## Green Criteria

RHC03 closes Green when targeted seams are safely resolved or explicitly preserved with proof, focused tests pass for touched source, and no compatibility behavior breaks.

## Yellow Criteria

A seam remains because it protects compatibility or needs a later owner; the reason, owner, and recheck condition are recorded.

## Red Criteria

Unsafe deletion, hidden compatibility break, route/raw/persistence change, validator weakening, unsupported release/platform claim, or active batch interruption.

## Required Evidence Outputs

- `docs/audits/rhc03-placeholder-stub-compatibility-seam-cleanup-report.md`

## Commit Message Recommendation

`Run RHC03 Placeholder Stub And Compatibility Seam Cleanup`

## Next Safe Prompt / Next Gate

After Green or accepted Yellow, ask global train for next eligible batch. Expected next RHC gate when safe: RHC04.
