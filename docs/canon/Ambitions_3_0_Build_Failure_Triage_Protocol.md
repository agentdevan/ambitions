# Ambitions 3.0 Build Failure Triage Protocol

Status: Historical supporting canon; subordinate to `docs/truth/*`

## Purpose

Build failures must be triaged quickly and honestly so Codex does not repair the wrong layer or hide environment gaps.

## Failure Classes

- Repo compile failure.
- Project generation failure.
- Package resolution failure.
- Toolchain missing or wrong version.
- Simulator/runtime unavailable.
- Code signing or entitlement issue.
- Generated artifact or stale cache issue.
- Wrapper/script issue.

## Triage Order

1. Run `scripts/validate-dev-tools.sh || true`.
2. Run `xcodegen generate`.
3. If wrapper failed, compare with direct `xcodebuild`.
4. Check simulator availability with `xcrun simctl list devices available`.
5. Classify first failing layer.
6. Fix repo failures narrowly; document environment failures.
7. Do not change product code for a toolchain failure.

## Evidence

Capture exact command, selected destination, first meaningful error, classification, fix attempt, and next action. Use `.codex/templates/test-failure-report-template.md` for build/test reports.
