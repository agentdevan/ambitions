# AFRI-014 Experience Kernel Release Flow Proof

Issue: AMB-366 / AFRI-014
Date: 2026-05-31
Scope: Promote `AmbitionsExperienceKernel` validation into repo-level developer entry points.

## Summary

Repo-root Makefile targets now wrap the package-owned validation scripts for kernel lint, repo truth audit, performance budget scan, visual QA checklist generation, release report generation, and the combined local release-flow check.

The package scripts remain owned by `Packages/AmbitionsExperienceKernel/Scripts`. No app source, product runtime behavior, UI route, dependency graph beyond the existing package wiring, signing setting, hosted workflow, CI path, network path, or release posture was changed.

## Command Map

Canonical command map:

- `docs/codex/EXPERIENCE_KERNEL_VALIDATION_COMMAND_MAP.md`

Repo-root commands:

- `make experience-kernel-lint`
- `make experience-kernel-repo-truth`
- `make experience-kernel-performance`
- `make experience-kernel-visual-qa`
- `make experience-kernel-release-report`
- `make experience-kernel-release-check`

Proof outputs:

- `Packages/AmbitionsExperienceKernel/ambitions_experience_kernel_repo_truth_report.json`
- `Packages/AmbitionsExperienceKernel/ambitions_experience_kernel_performance_report.json`
- `Packages/AmbitionsExperienceKernel/snapshot_matrix_checklist.md`
- `Packages/AmbitionsExperienceKernel/release_readiness_report.json`

## Validation

Verified:

- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-366 --batch-type guard-repair --prompt /tmp/AMB-366-AFRI-014-guard-prompt.md`
  - Green
  - Report: `build/reports/parallel-implementation-guard/AMB-366-pre.md`
- `make experience-kernel-lint`
  - Green
  - `colorAssets=90 inventions=32 batches=16`
- `make experience-kernel-repo-truth`
  - Initial run was Red when the target scanned the full repository and wrote a root-level report. Repair: the Makefile target now runs the package-owned audit from `Packages/AmbitionsExperienceKernel`, matching the package scope validated in AFRI-012.
  - Re-run Green
  - Findings: `0`
  - Report: `Packages/AmbitionsExperienceKernel/ambitions_experience_kernel_repo_truth_report.json`
- `make experience-kernel-performance`
  - Green
  - Findings: `0`
  - Report: `Packages/AmbitionsExperienceKernel/ambitions_experience_kernel_performance_report.json`
- `make experience-kernel-visual-qa`
  - Green
  - Report: `Packages/AmbitionsExperienceKernel/snapshot_matrix_checklist.md`
- `make experience-kernel-release-report`
  - Green
  - Report: `Packages/AmbitionsExperienceKernel/release_readiness_report.json`
- `make experience-kernel-release-check`
  - Green
  - Runs lint, package-scoped repo truth audit, performance budget scan, visual QA checklist generation, and release report generation
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-366 --batch-type guard-repair --prompt /tmp/AMB-366-AFRI-014-guard-prompt.md --changed-from HEAD`
  - Green
  - Report: `build/reports/parallel-implementation-guard/AMB-366-post.md`
- `git diff --check`
  - Green
- Targeted provider/off-device scan across changed AMB-366 files
  - Green
- Targeted sensitive-key and unsupported-claim scan across changed AMB-366 files
  - Green
- Targeted old-product-term scan
  - Green for docs/proof files
  - Whole-file Makefile scan hit pre-existing target names outside the AMB-366 diff. Changed-line Makefile review showed no old-product terms introduced by AMB-366.

## Claim Boundary

This packet proves repo-level command availability and current local command outcomes only after the validation section is filled with current results. It does not claim physical-device behavior, signed archive/export validation, TestFlight validation, App Store submission validation, public accessibility conformance, legal/privacy approval, CI proof, or product completeness.
