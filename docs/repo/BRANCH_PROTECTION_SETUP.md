# Branch Protection Setup

Status: repo-governance instructions only. This document does not prove CI success, release readiness, or GitHub plan capability. The Xcode status check is intended for the repo owner's self-hosted `Ambitions-XCode26` runner, not GitHub-hosted macOS.

## Path A: Branch Protection Or Rulesets Available

Use this path if the current GitHub plan exposes branch protection or repository rulesets for the private repo.

1. Protect `main`.
2. Require pull requests before merge.
3. Require status checks before merge.
4. Require conversation resolution before merge.
5. Disable force pushes.
6. Disable deletions.
7. Prefer squash merge.
8. Require these status check names:
   - `repo-hygiene`
   - `ambitions-law-audit`
   - `remediation-governance-check`
   - `source-atlas-boundary-audit`
   - `swiftlint`
   - `semgrep-local`
   - `shellcheck`
   - `workflow-lint`
   - `docs-lint`
   - `secrets-scan`
   - `python-tests`
   - `xcode-build-for-testing` where applicable on the self-hosted `Ambitions-XCode26` macOS/Xcode runner

## Path B: Private Branch Protection Not Available Without Paying

Do not pay for a new plan or add a paid quality gate for this stack.

Use the workflow check suite as the visible merge gate:

1. Open a PR for each change.
2. Let `.github/workflows/ambitions-pr-review.yml` run.
3. Never merge manually unless required checks pass or the PR closeout records an explicit Yellow/Red reason.
4. Ask ChatGPT to review the PR URL before squash merge.
5. Keep GitHub Actions logs and artifacts as proof for the PR.

## Required Checks

The free PR review stack expects these checks to be visible on PRs:

- `repo-hygiene`
- `ambitions-law-audit`
- `remediation-governance-check`
- `source-atlas-boundary-audit`
- `swiftlint`
- `semgrep-local`
- `shellcheck`
- `workflow-lint`
- `docs-lint`
- `secrets-scan`
- `python-tests`
- `xcode-build-for-testing` where applicable on the self-hosted `Ambitions-XCode26` runner

The Xcode check is intentionally not configured for GitHub-hosted macOS runners. It runs automatically for PRs touching `Native/**`, `Package.swift`, `project.yml`, or checked-in Xcode project paths, and it can be forced with `workflow_dispatch`.
