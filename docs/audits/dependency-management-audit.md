# Dependency Management Audit

Status: Completed for Codex Performance Operating System pass

## Audited Inputs

- `project.yml`
- `Package.swift`
- `.github/workflows/ios-validate.yml`
- `.codex/`
- `scripts/`
- current local build/test conventions

## Classification

| Tool/dependency | Classification | Rationale |
|---|---|---|
| Xcode | required | Native iOS build/test/archive toolchain. |
| XcodeGen | required | `project.yml` is the project source of truth. |
| Swift Package Manager | required | Local packages in `Package.swift`. |
| ripgrep | required | Fast deterministic source/docs scans. |
| git | required | Repo sync, diff, commit, push. |
| gh CLI | optional recommended | Useful for GitHub checks when authenticated. |
| jq | optional recommended | Useful for JSON simulator/CI output. |
| xcbeautify | optional recommended | Log readability only; not required. |
| markdownlint-cli2 | optional recommended | Docs hygiene. |
| markdown link checker | optional recommended | Periodic docs audits. |
| SwiftLint | optional later | Needs agreed rules and CI impact review. |
| SwiftFormat | optional later | Needs agreed style policy. |
| Fastlane | optional later | Only if signing/TestFlight automation becomes near-term. |
| Tuist | avoid | Do not replace XcodeGen. |
| SwiftGen | avoid | Not justified by current repo. |
| Sourcery | avoid | Not justified by current repo. |
| Danger | avoid | Adds CI/process complexity. |
| analytics SDKs | avoid | Privacy/product policy not defined for SDK instrumentation. |
| backend SDKs | avoid | Local-first; sync/backend boundary not active. |
| AI SDKs | avoid | Ambitions is intelligent, not an AI-wrapper app. |
| paid QA services | avoid | Use local deterministic validation first. |

## Dependencies Added

None.

## Recommendation

Keep dependency surface minimal through F00/F01. Revisit optional docs and log tools only after core 3.0 UI/test loops are stable.
