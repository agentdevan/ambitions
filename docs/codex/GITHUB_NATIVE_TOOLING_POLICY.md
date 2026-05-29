# GitHub Native Tooling Policy

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-13212827, AMB28-stale_or_unknown_active_status-71473900

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, status-expedite
> Dispositions: clarify-status-before-use, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Policy first.
Scope: GitHub MCP, Dependabot, CodeQL, Actions, and self-hosted runner governance.

## 1. GitHub Official MCP

- Use read-only first.
- Use a fine-grained token scoped to the minimum required repo(s).
- Store no secrets in the repo.
- Prefer dynamic toolsets when available.
- Do not enable write tools until a separate approval batch records scope, token permissions, rollback, and audit proof.

## 2. Dependabot

- Enable Dependabot alerts in GitHub settings if available.
- Add `/.github/dependabot.yml` only when useful and after policy review.
- Do not enable auto-merge.
- Route all dependency PRs through EFC applicability and release-claim scanning.
- Start with tooling/actions ecosystems only unless the app dependency policy is clear.

This run did not create `.github/dependabot.yml` because `.github/` was absent and hosted workflow policy remains explicit-approval only.

## 3. CodeQL

- Swift is supported by CodeQL, but policy comes first.
- Do not enable expensive hosted macOS workflows without a cost, runner, trigger, artifact, and security decision.
- Prefer manual/local or self-hosted policy-gated setup first.

## 4. GitHub Actions

Do not add hosted CI without explicit cost approval.

Do not add:

- release/signing/App Store workflows
- workflows that use secrets without a secrets policy
- public fork PR execution with privileged tokens
- hosted proof that is presented as release proof without matching evidence

Allowed future workflow families after approval:

- docs-and-claims
- mcp-self-test
- xcodegen-check
- focused-build
- visual-proof
- accessibility-proof
- release-truth

Workflow templates may live under `docs/codex/workflow-templates/`. They must not be copied into `.github/workflows/` without approval.

## 5. Self-Hosted Runner

A self-hosted runner must be:

- manual/on-demand
- blocked for public fork PRs
- no secrets by default
- no signing
- path-filtered
- short artifact retention
- not release proof unless explicitly proven

## Non-Claims

This policy does not enable GitHub Actions, Dependabot, CodeQL, GitHub MCP, self-hosted runners, release automation, signing automation, hosted CI, release readiness, App Store readiness, TestFlight readiness, device proof, public accessibility proof, or legal/privacy signoff.

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
