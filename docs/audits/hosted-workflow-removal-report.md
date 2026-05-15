# Hosted Workflow Removal Report

Status: Green for tracked workflow removal and active README/native validation replacement; Yellow for residual historical hosted-CI references that require classification in large registry/context files if local patch tooling is available.
Date: 2026-05-06
Updated: 2026-05-15
Batch: PFC05A Remove Hosted Workflows / Local Validation Gate
Type: docs/governance/repo-hygiene

## Deleted Workflow Files

Previously deleted tracked workflow files:

- `.github/workflows/ios-validate.yml`
- `.github/workflows/cqs-advisory-gates.yml`
- `.github/workflows/swift6-modernization-scan.yml` (removed on
  2026-05-14 after it was found reintroduced as a push-triggered hosted
  workflow)

Additional tracked workflow files deleted on 2026-05-15:

- `.github/workflows/swift6-modernization-scan.yml`
- `.github/workflows/signature-visual-instruments-07.yml`

Reason for the 2026-05-15 addendum:

- `swift6-modernization-scan.yml` reintroduced automatic `push` execution on `main`.
- `signature-visual-instruments-07.yml` reintroduced automatic `push` execution for selected paths and included hosted generated-output commit behavior.
- Both conflicted with the active local-validation/no-hosted-CI-proof posture.

No tracked `.github/workflows/*.yml` file should run on `push` by default. If a workflow is reintroduced later, it must be explicitly approved and manual-only by default via `workflow_dispatch` unless active policy is changed.

## Active Docs Updated

Updated active operator guidance:

- `README.md`
  - removed active hosted workflow validation guidance
  - states hosted workflows are intentionally absent
  - states validation evidence must come from checked-in scripts, local terminal logs, local Xcode / `xcodebuild`, local simulator commands, proof artifacts, and terminal gates
- `docs/native-build-and-release.md`
  - replaced hosted workflow coverage with local validation coverage
  - preserved local generation, build, package resolution, unit test, UI test, unsigned archive, signed App Store validation, and release-operation handoff commands
  - records terminal-only physical-device gate boundaries
- `.github/README.md`
  - records that Ambitions does not use hosted GitHub Actions workflows as automatic validation on every commit
  - forbids `push` / `pull_request` workflow triggers without a specific policy change and matching audit note
  - preserves local validation as the active proof path

## Local Validation Replacement

Current validation proof must come from:

- checked-in scripts
- explicit local command logs
- local Xcode / `xcodebuild` commands
- local simulator proof
- local device proof where required
- proof artifacts
- terminal gates
- release-gate-specific local signing/App Store validation evidence when required

Hosted workflow runs, hosted-CI logs, generated hosted commits, and Actions artifacts are not valid current proof sources.

## Remaining Historical Mentions

Residual mentions of GitHub Actions, hosted CI, Actions artifacts, `.github/workflows/**`, or specific historical workflow filenames may remain only when clearly historical, archival, removed-policy, or forbidden-current-proof language.

Known likely historical/supporting areas to inspect/classify on a local checkout:

- `.codex/skills/github-actions-parity-auditor.md`
- `.codex/skills/markdown-doc-qa-runner.md`
- `.codex/validation/local-ci-parity-pack.md`
- earlier PFC audit reports and prompts that recorded prior hosted-workflow parity work
- historical 2.0 docs or old capability matrices

If any active doc still instructs contributors to use hosted workflows as current validation, repair that doc before this batch can be marked fully Green.

## No Hosted-CI Proof Claim

This report makes no hosted-CI proof claim. It intentionally removes hosted workflow proof as a current validation source and replaces it with local/Codex-operated validation.

## 2026-05-15 Verification Notes

Connector-level verification performed:

- direct fetch of `.github/workflows/swift6-modernization-scan.yml` on `main` returned `Not Found` after deletion
- direct fetch of `.github/workflows/signature-visual-instruments-07.yml` on `main` returned `Not Found` after deletion
- `.github/README.md` was added to record the no-hosted-auto-CI policy

Limitations:

- GitHub code search may temporarily show stale indexed results for deleted workflow paths.
- No local checkout was available through this connector session, so `git status`, `git diff --check`, `test ! -d .github/workflows`, and repo-wide `rg` checks were not executed locally.

## Yellow Parked Item

Owner: next local Codex operator
Reason: connector-safe edits to very large current-state, registry, and context files may require local patch tooling to avoid truncating preserved history.
Follow-up: classify residual hosted-CI mentions after running `rg -n "\.github/workflows|GitHub Actions|hosted CI|Actions artifact|ios-validate\.yml|swift6-modernization-scan\.yml|signature-visual-instruments-07\.yml" README.md docs .codex .github || true` on a local checkout.
Recheck condition: all remaining active-doc hits must either be removed or explicitly classified as historical/forbidden-current-proof language; `find .github/workflows -type f -print 2>/dev/null` must return no workflow files unless active policy explicitly restores manual-only workflow files.
