# Experience Kernel Validation Command Map

Status: Active repo-level validation entry points for `Packages/AmbitionsExperienceKernel`
Owner: AMB-366 / AFRI-014
Scope: Developer validation command map, not product behavior proof or release readiness proof

## Repo Entry Points

Run these commands from the repository root.

| Check | Command | Package-owned script | Proof output |
| --- | --- | --- | --- |
| Kernel lint | `make experience-kernel-lint` | `Packages/AmbitionsExperienceKernel/Scripts/ambitions_kernel_lint.py` | stdout summary |
| Repo truth audit | `make experience-kernel-repo-truth` | `Packages/AmbitionsExperienceKernel/Scripts/repo_truth_audit.py` | `Packages/AmbitionsExperienceKernel/ambitions_experience_kernel_repo_truth_report.json` |
| Performance budget scan | `make experience-kernel-performance` | `Packages/AmbitionsExperienceKernel/Scripts/performance_budget_scan.py` | `Packages/AmbitionsExperienceKernel/ambitions_experience_kernel_performance_report.json` |
| Visual QA checklist | `make experience-kernel-visual-qa` | `Packages/AmbitionsExperienceKernel/Scripts/generate_snapshot_matrix.py` | `Packages/AmbitionsExperienceKernel/snapshot_matrix_checklist.md` |
| Release report generation | `make experience-kernel-release-report` | `Packages/AmbitionsExperienceKernel/Scripts/generate_release_report.py` | `Packages/AmbitionsExperienceKernel/release_readiness_report.json` |
| Combined local release-flow check | `make experience-kernel-release-check` | all package scripts above | all proof outputs above |

## Release Claim Boundary

These entry points promote package validation into the repo workflow. They do not prove physical-device behavior, signed archive/export validation, TestFlight validation, App Store submission validation, public accessibility conformance, legal/privacy approval, CI proof, or product-completeness claims.

Use current command logs and this command map together. Generated JSON or markdown outputs are supporting artifacts only unless the matching command was run for the current commit.

## Rollback

Remove the `experience-kernel-*` targets from `Makefile` and return to running package-local scripts directly from `Packages/AmbitionsExperienceKernel`.
