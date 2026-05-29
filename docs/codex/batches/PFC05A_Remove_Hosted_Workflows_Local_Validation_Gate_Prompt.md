# PFC05A Remove Hosted Workflows Local Validation Gate Prompt

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-authority-check**
> AMB-291 note: This batch/prompt is not standalone authority and must read the listed source-of-truth files before use.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, status-expedite
> Dispositions: clarify-status-before-use, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

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

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
