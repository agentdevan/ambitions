# Mac Codex 5.5 Toolchain Setup

Status: Active local setup guide

## Codex Mode Usage

- Suggest: planning, audit, risk review, dependency proposal.
- Auto Edit: scoped docs/code/test changes with known files.
- Full Auto: bounded cleanup, generated-project checks, or validation where commands are deterministic.

## Sync Protocol

```bash
git status --short
git branch --show-current
git fetch origin --prune
git checkout main
git pull --ff-only origin main
```

If local work exists, preserve it with a stash or backup before destructive sync. Work on `main` unless the user explicitly says otherwise.

## Brew Bundle Setup

The active local developer tool set is in `Brewfile`:

```bash
brew bundle
brew bundle check || true
```

`Brewfile.optional-later` contains SwiftLint, SwiftFormat, and Fastlane. Do not run it as required setup until the dependency policy promotes those tools.

Use `docs/canon/Ambitions_3_0_Local_Toolchain_Readiness_Matrix.md` and `docs/canon/Ambitions_3_0_Dependency_Promotion_Ladder.md` to decide whether a missing tool is blocking, adopted/advisory, optional-later, docs-only, or avoided.

## Tool Validation

```bash
scripts/validate-dev-tools.sh
```

This checks Xcode, `xcode-select`, XcodeGen, `rg`, `git`, `gh`, `jq`, `xcbeautify`, `markdownlint-cli2`, and `lychee`. SwiftLint, SwiftFormat, and Fastlane are reported only as optional staged tools.

## GitHub And JSON Helpers

- `gh` is useful only when authenticated; use `gh auth status` before relying on it.
- `jq` is preferred for parsing JSON from `xcrun simctl`, `gh`, or CI artifacts instead of brittle text slicing.

## Simulator Discovery

```bash
xcrun simctl list devices available | grep -E 'iPhone' | head -20
```

The local wrappers prefer iPhone 17, then iPhone 16, then the first available iPhone simulator.

## Local Build/Test Wrappers

```bash
scripts/build-local.sh
scripts/test-local.sh
```

Both wrappers run `xcodegen generate`, select an available simulator, write generated logs under ignored `output/logs/`, and use `xcbeautify` when installed while preserving the underlying `xcodebuild` exit status.

The full UI lane currently has known failures from the FAANG handoff report. Do not claim FAANG handoff readiness or release readiness from a partial or failing full test run.

## Direct Build/Test Commands

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' build CODE_SIGNING_ALLOWED=NO
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO
```

Use direct commands when debugging wrapper behavior.

## Documentation QA

```bash
scripts/run-doc-qa.sh
DOC_QA_STRICT=1 scripts/run-doc-qa.sh
```

The default mode runs stale-guidance, deprecated-language, Markdown lint, and link checks with logs under ignored `docs/audits/doc-qa/`. `lychee` is advisory by default because external links and local network conditions can be flaky. Use strict mode only when preparing docs for a blocking gate or after the backlog is clean enough to make the signal meaningful.

## Copy Guard

```bash
rg -n --hidden --glob '!/.git/**' 'Start Focus|Focus Session|best next move|next best move|AI confidence|productivity score|profile tab|insights tab|habits tab|overdue|failed|missed' . || true
```

## Repo Hygiene

```bash
git ls-files | grep -E '(^tmp/|^output/|.ndjson$|.log$|.tmp$|.xcresult$|DerivedData)' || true
git diff --check
git diff --cached --check
```

## Dependency Audit

```bash
sed -n '1,220p' project.yml
sed -n '1,160p' Package.swift
sed -n '1,220p' .github/workflows/ios-validate.yml
sed -n '1,220p' Brewfile
```

## Network-Disabled Strategy

Use installed Xcode, XcodeGen, local packages, checked-in scripts, and docs. If an optional tool is missing, document the fallback and do not add runtime dependencies or paid services.

## Preserve Local Work

```bash
git status --short
git diff > ../ambitions-local-backup/pre-change.diff || true
git stash push -u -m "pre-risky-codex-change" || true
```

## Recover From Bad Changes

Do not use destructive reset unless explicitly approved. Use `git diff`, path-limited reverse patches, or restore only files you changed.

## Stop For Human/Device Proof

Stop and ask when the next claim requires physical device testing, manual accessibility traversal, signing credentials, App Store Connect, TestFlight, paid services, private accounts, or product decisions not in repo docs.
