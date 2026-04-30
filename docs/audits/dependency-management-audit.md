# Ambitions 3.0 Dependency Management Audit

Status: Updated for developer tooling adoption

## Executive Result

The optional recommended development tools have been adopted as local developer tools only. No Ambitions app runtime dependency was added. SwiftLint, SwiftFormat, and Fastlane remain staged-only and non-blocking.

## Audited Inputs

- `project.yml`
- `Package.swift`
- `.github/workflows/ios-validate.yml`
- `Brewfile`
- `Brewfile.optional-later`
- `scripts/validate-dev-tools.sh`
- `scripts/run-doc-qa.sh`
- `scripts/build-local.sh`
- `scripts/test-local.sh`
- `.codex/validation/dependency-drift-pack.md`
- `.codex/validation/local-ci-parity-pack.md`

## Current Tool Classification

| Tool/dependency | Classification | Current posture | Validation |
| --- | --- | --- | --- |
| Xcode | Required build dependency | Required for native build/test/archive. | `xcodebuild -version` |
| XcodeGen | Required build dependency | Required because `project.yml` is source of truth. | `xcodegen --version` |
| SwiftPM | Required build dependency | Used through Xcode/Package.swift. | `swift --version` |
| git | Required local tool | Required for repo state and commits. | `git --version` |
| zsh/bash | Required local shell | Required for local scripts. | script execution |
| ripgrep | Required local tool | Required for fast scans. | `rg --version` |
| gh | Adopted local developer tool | Useful when authenticated; credentials are user-owned. | `gh --version` |
| jq | Adopted local developer tool | JSON parsing for simulator/GitHub/tool output. | `jq --version` |
| xcbeautify | Adopted local developer tool | Readable local Xcode logs; not required by app runtime. | `xcbeautify --version` |
| markdownlint-cli2 | Adopted documentation QA tool | Advisory by default until docs backlog is clean. | `markdownlint-cli2 --version` |
| lychee | Adopted documentation QA tool | Advisory link checks by default due to network flakiness. | `lychee --version` |
| SwiftLint | Optional staged tool | Not active, not blocking. | `Brewfile.optional-later` only |
| SwiftFormat | Optional staged tool | Not active, not blocking. | `Brewfile.optional-later` only |
| Fastlane | Optional staged tool | Documentation-only until signing/TestFlight/App Store automation is near-term. | `Brewfile.optional-later` only |
| Tuist | Avoid | Do not replace XcodeGen. | N/A |
| SwiftGen | Avoid | Not justified. | N/A |
| Sourcery | Avoid | Not justified. | N/A |
| Danger | Avoid | CI/process complexity not justified. | N/A |
| Analytics SDKs | Forbidden without future policy | Runtime privacy/product risk. | N/A |
| Backend SDKs | Forbidden without future policy | Local-first/sync boundary not ready. | N/A |
| AI SDKs | Forbidden without future policy | Ambitions is intelligent, not an AI-wrapper product. | N/A |
| Paid QA services | Avoid | Cost/process overhead not justified. | N/A |

## Runtime Dependency Result

No app runtime dependencies were added. `Package.swift` and `project.yml` remain the native dependency/configuration boundaries.

## CI Blocking Status

- Existing `.github/workflows/ios-validate.yml` remains unchanged for native iOS validation.
- No docs QA workflow is active. A workflow-dispatch docs QA job was intentionally not kept because the current GitHub OAuth token cannot push workflow changes without `workflow` scope.
- Markdown lint and lychee do not block push/main by default.

## Validation Commands

```bash
brew bundle check || true
scripts/validate-dev-tools.sh || true
scripts/run-doc-qa.sh || true
scripts/build-local.sh
scripts/test-local.sh || true
```

Current evidence: `brew bundle check` passes after installing the adopted tools, `scripts/validate-dev-tools.sh` passes, `scripts/run-doc-qa.sh` passes in advisory mode with known docs backlog findings, `scripts/build-local.sh` passes on iPhone 17, and `scripts/test-local.sh || true` records 744 passing unit tests plus 9 known UI smoke failures.

## Risks

- Optional tools may be missing on a new Mac until `brew bundle` is run.
- `gh` may be installed but unauthenticated; do not rely on it for repo truth.
- `lychee` can fail from network, rate-limit, or external-site behavior.
- Markdown lint currently exposes backlog debt and should remain advisory until intentionally cleaned.
- Full local tests still inherit the prior known UI smoke failures.

## Removal Path

Remove a local tool by deleting it from `Brewfile`, removing references from scripts/docs, and rerunning `scripts/validate-dev-tools.sh || true` plus `scripts/build-local.sh`.
