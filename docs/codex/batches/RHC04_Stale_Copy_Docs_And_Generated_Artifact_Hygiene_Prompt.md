# RHC04 Stale Copy Docs And Generated Artifact Hygiene Prompt
<!-- markdownlint-disable MD013 -->

## Batch Identity

- Batch ID: RHC04
- Title: Stale Copy Docs And Generated Artifact Hygiene
- Train: RHC01-RHC06 Repo Hygiene Closeout Train
- Default global placement: after RHC03 and only after active LDI/AOS/FCP/PFC tails are complete or accepted Yellow
- Type: docs/copy/source hygiene; source only when owner proof exists

## Status

Queued. Do not run until RHC01-RHC03 prove this cleanup is still needed and safe.

## Purpose

Remove stale active guidance, obsolete future-batch visible copy, deprecated wording, markdownlint/doc QA backlog, and generated/local artifact confusion without changing app behavior or interrupting the active global train.

## Source Truth Files To Read First

- README.md
- AGENTS.md
- docs/native-build-and-release.md
- .codex/reports/current-run-state.md
- docs/codex/RESUME_GLOBAL_BATCH_TRAIN.md
- docs/codex/batch-trains/RHC01_RHC06_REPO_HYGIENE_CLOSEOUT_TRAIN.md
- docs/audits/rhc01-repo-hygiene-triage-owner-map-report.md
- docs/audits/rhc03-placeholder-stub-compatibility-seam-cleanup-report.md if present
- docs/audits/pfc01-repo-build-system-inventory-report.md
- docs/audits/pfc03-dead-code-prompt-artifact-naming-smell-audit-report.md
- docs/codex/BATCH_REGISTRY.md
- docs/codex/CONTEXT_INDEX.md

## Required Preflight Checks

- `git status --short`
- `git branch --show-current`
- `scripts/global-train-next-batch.sh || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/cqs-product-drift-scan.sh Native || true` when user-facing copy is touched

## Candidate Targets

- Stale F-series visible copy in Today projection surfaces.
- Temporary overlay wording in shared primitives/previews.
- Active docs that still imply stale hosted workflow, old CI, old batch-count, or obsolete validation posture.
- Markdownlint backlog where the fix is mechanical and low-risk.
- Generated/local artifact guidance around `Ambitions.xcodeproj/`, `.swiftpm/`, `output/`, and `.DS_Store`.

## Forbidden Scope

- No behavior changes without owner proof.
- No production Swift copy edit unless current user-facing exposure is proven and focused tests/scans run.
- No deletion of generated/local artifacts from user machines; only repo guidance may change.
- No release, App Store, TestFlight, physical-device, legal/privacy, or public accessibility claim.
- No validator weakening.

## Required Work

1. Confirm active batch pointer still permits RHC.
2. Separate active policy from historical evidence in docs.
3. Fix stale guidance only where current repo evidence proves the newer truth.
4. Replace obsolete visible copy only with current Ambitions/PXOS language.
5. Preserve historical audit records unless they are explicitly active guidance.
6. Run doc QA and copy/drift scans where relevant.

## Green Criteria

RHC04 closes Green when stale active guidance and proven visible-copy issues are corrected, historical evidence remains intact, generated/local artifact policy is clear, and validation passes or advisories are owned.

## Yellow Criteria

A stale item may be historical or preview-only and requires later owner proof; owner and recheck condition are recorded.

## Red Criteria

Historical evidence is rewritten as if it never happened, current active policy is made ambiguous, validators are weakened, app behavior changes without owner proof, or active batch selection is interrupted.

## Required Evidence Outputs

- `docs/audits/rhc04-stale-copy-docs-generated-artifact-hygiene-report.md`

## Commit Message Recommendation

`Run RHC04 Stale Copy Docs And Generated Artifact Hygiene`

## Next Safe Prompt / Next Gate

After Green or accepted Yellow, ask global train for next eligible batch. Expected next RHC gate when safe: RHC05.
