# GitHub Native Tooling Policy

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
