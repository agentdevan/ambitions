# Mac Codex 5.5 Toolchain Setup

Status: Active local setup guide

## Codex Mode Usage

- Suggest: planning, audit, risk review, dependency proposal.
- Auto Edit: scoped docs/code/test changes with known files.
- Full Auto: only for bounded, low-risk cleanup or validation where commands are deterministic.

## Sync Protocol

```bash
git status --short
git branch --show-current
git fetch origin --prune
git checkout main
git pull --ff-only origin main
```

If local work exists, preserve it with a branch/stash before destructive sync.

## Tool Checks

```bash
xcodebuild -version
xcode-select -p
xcodegen --version
swift --version
rg --version
git --version
```

## Simulator Discovery

```bash
xcrun simctl list devices available | grep -E 'iPhone' | head -20
```

Use `iPhone 17` if `iPhone 16` is unavailable locally and record the exact destination.

## Build Commands

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' build CODE_SIGNING_ALLOWED=NO
```

## Test Commands

```bash
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests test CODE_SIGNING_ALLOWED=NO
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO
```

The full UI lane currently has known failures from the FAANG handoff report; prefer focused tests for touched paths and record existing failures honestly.

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
```

## Network-Disabled Strategy

Avoid relying on new network downloads. Use installed Xcode, XcodeGen, local packages, and checked-in docs/scripts. If a tool is missing, document the fallback and do not add a dependency silently.

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
