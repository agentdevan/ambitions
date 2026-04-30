# Ambitions 3.0 Developer Tooling Adoption Report

Status: Completed tooling adoption batch

## Executive Result

The Ambitions 3.0 Codex Performance Operating System now has an adopted local developer tooling layer for faster validation, cleaner Xcode logs, deterministic JSON parsing, and advisory documentation QA. No Ambitions product features or app runtime dependencies were added.

## Tools Adopted

- `gh`: local GitHub inspection when authenticated.
- `jq`: deterministic JSON parsing.
- `xcbeautify`: readable local `xcodebuild` output while preserving exit status.
- `markdownlint-cli2`: advisory Markdown lint.
- `lychee`: advisory link checking.

## Optional Later

- SwiftLint: staged only in `Brewfile.optional-later`.
- SwiftFormat: staged only in `Brewfile.optional-later`.
- Fastlane: staged only in `Brewfile.optional-later`; not active until signing/TestFlight/App Store automation becomes near-term.

## Files Added

- `Brewfile`
- `Brewfile.optional-later`
- `scripts/validate-dev-tools.sh`
- `scripts/run-doc-qa.sh`
- `scripts/build-local.sh`
- `scripts/test-local.sh`
- `.codex/skills/markdown-doc-qa-runner.md`
- `.codex/validation/doc-qa-pack.md`
- `docs/audits/ambitions-3-0-dev-tooling-adoption-report.md`

## Files Updated

- `.gitignore`
- `.codex/skills/dependency-auditor.md`
- `.codex/skills/mac-toolchain-bootstrapper.md`
- `.codex/skills/ci-parity-reviewer.md`
- `.codex/skills/build-test-pack-runner.md`
- `.codex/skills/dependency-addition-gatekeeper.md`
- `.codex/skills/dependency-security-reviewer.md`
- `.codex/skills/license-risk-reviewer.md`
- `.codex/operations/dependency-change-protocol.md`
- `.codex/operations/local-validation-protocol.md`
- `.codex/operations/branch-and-sync-protocol.md`
- `.codex/operations/closeout-and-evidence-protocol.md`
- `.codex/validation/dependency-drift-pack.md`
- `.codex/validation/local-ci-parity-pack.md`
- `.codex/validation/repo-hygiene-pack.md`
- `.codex/validation/active-canon-pack.md`
- `.codex/validation/README.md`
- `docs/canon/Ambitions_3_0_Dependency_Management_Policy.md`
- `docs/canon/Ambitions_3_0_Build_Skills_And_Dependency_Management.md`
- `docs/canon/Ambitions_3_0_Codex_Performance_Operating_System.md`
- `docs/canon/Ambitions_3_0_Codex_Value_Maximization_System.md`
- `docs/codex/MAC_CODEX_5_5_TOOLCHAIN_SETUP.md`
- `docs/codex/AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING.md`
- `docs/codex/AMBITIONS_3_0_SKILL_SYSTEM_INDEX.md`
- `docs/codex/MASTER_AMBITIONS_3_0_CODEX_PROMPT.md`
- `docs/audits/dependency-management-audit.md`

## CI Status

CI was not changed. A workflow-dispatch docs QA workflow was considered, but the push was rejected because the current GitHub OAuth token does not have `workflow` scope. The safer result is local docs QA plus documented future CI promotion.

## Commands Run For Evidence

```bash
brew bundle check || true
scripts/validate-dev-tools.sh || true
scripts/run-doc-qa.sh || true
scripts/build-local.sh
scripts/test-local.sh || true
rg -n --hidden --glob '!/.git/**' 'Brewfile|validate-dev-tools|run-doc-qa|build-local|test-local|markdownlint-cli2|lychee|xcbeautify|jq|gh' README.md docs AGENTS.md .codex scripts .github || true
```

## Validation Result

- `brew bundle check || true`: initially reported missing dependencies, then passed after `brew bundle install`.
- `scripts/validate-dev-tools.sh || true`: PASS after install. Found Xcode 26.3, XcodeGen 2.45.4, ripgrep 15.1.0, gh 2.92.0, jq 1.8.1, xcbeautify 3.2.1, markdownlint-cli2 0.22.1, and lychee 0.24.1.
- `scripts/run-doc-qa.sh || true`: PASS in advisory mode. Stale-guidance hits are historical/supporting; deprecated-language and Markdown lint debt remain; lychee found 5 broken local links in older canon docs and stayed advisory.
- `scripts/build-local.sh`: PASS on `platform=iOS Simulator,name=iPhone 17`.
- `scripts/test-local.sh || true`: PARTIAL. `AmbitionsTests` passed 744 tests. `AmbitionsUITests` failed 9 tests, consistent with the known FAANG handoff UI-smoke debt class. This does not indicate an app build break from the tooling batch.
- Discoverability scan: PASS; new tools/scripts are referenced across docs, `.codex`, scripts, and workflow files.

## Expected Failure Handling

- Missing adopted tools should be fixed with `brew bundle` on developer Macs, but should not be misclassified as app runtime failures.
- Docs QA link failures are advisory unless `DOC_QA_STRICT=1`.
- Full `scripts/test-local.sh` may fail because prior FAANG handoff UI smoke failures remain known repo debt.

## Should This Be Required For Future Codex Runs?

Use `scripts/validate-dev-tools.sh` before major local work, `scripts/run-doc-qa.sh` for docs-heavy work, and `scripts/build-local.sh` for build proof. Do not require strict docs QA or full local tests for every small docs-only task.
