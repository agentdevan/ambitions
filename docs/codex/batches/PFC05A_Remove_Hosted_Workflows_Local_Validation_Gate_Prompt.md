# PFC05A Remove Hosted Workflows Local Validation Gate Prompt

Status: complete after hosted workflows are removed and active validation docs point to local/Codex-operated proof only.
Type: repo-hygiene / validation-governance.
App behavior: none.

## Goal

Remove all GitHub Actions / hosted workflow files from Ambitions and replace active validation guidance with local terminal, local Xcode, checked-in script, proof-artifact, and Codex-operated validation language.

## Scope

In scope:

- Delete `.github/workflows/**`.
- Remove empty workflow directory by deleting all tracked workflow files.
- Update active validation docs so they no longer instruct operators to use hosted CI, workflow jobs, Actions artifacts, or `.github/workflows/ios-validate.yml` as current proof.
- Add audit evidence that workflow files were intentionally removed.
- Preserve local validation commands for project generation, package resolution, simulator build, unit tests, UI tests, unsigned archive sanity, and signed App Store validation handoff.

Out of scope:

- Production Swift.
- Generated projects.
- Dependencies.
- Signing, entitlements, provisioning, App Store, TestFlight, or release configuration.
- Hosted CI replacement services.
- Runtime/platform behavior changes.

## Local Validation Rule

Current Ambitions validation must come from local/Codex-operated evidence:

- checked-in scripts
- local terminal command logs
- local Xcode / xcodebuild commands
- local simulator proof
- explicit proof artifacts
- local archive/signing validation where release gates require it
- terminal gates

## Hosted Workflow Rule

GitHub Actions, hosted CI, workflow runs, workflow artifacts, and `.github/workflows/**` are not valid current proof sources.

Historical audit mentions may remain only when clearly historical and not current operator guidance.

## Repair Loop

If active docs still point to GitHub Actions or workflow files as current validation, repair the active docs before closing this batch.

If workflow deletion is blocked by permissions, stop as Hard Red and do not continue the train.

## Acceptance

PFC05A is Green only when:

- no `.github/workflows` directory remains in the tracked repo
- active docs use local/Codex-operated validation guidance
- deleted workflow files are listed in `docs/audits/hosted-workflow-removal-report.md`
- remaining hosted-CI mentions are classified as historical, removed-policy, or forbidden-current-proof language
- no hosted-CI proof claim is introduced
