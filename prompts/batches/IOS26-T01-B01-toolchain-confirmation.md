<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T01-B01 — Toolchain confirmation

## Batch type
Toolchain validation

## Objective
Confirm local Xcode 26/iOS 26/SwiftPM/XcodeGen toolchain before target bump.

## Why this exists
Deployment target changes are unsafe without toolchain proof.

## Dependencies
Train 0 Green or accepted Yellow.

## Truth files to read
- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `project.yml`
- `Package.swift`

## Exact source areas to inspect
project.yml
Package.swift
scripts/
docs/codex/ios26-toolchain-matrix.md
build/reports/ios26-baseline/

## Exact changes allowed
docs/codex/ios26-toolchain-matrix.md
build/reports/ios26-migration/toolchain.md

## Exact changes forbidden
No target bump yet. No project/package/source edits.

## Implementation steps
1. Record Xcode, SDKs, Swift, XcodeGen, simulator runtimes, and simulator devices.
2. Determine exact SwiftPM syntax for iOS 26 platform support.
3. Determine an available iOS 26 simulator destination.
4. Record blockers and do not mutate target settings.

## Tests to add/update
None.

## Commands to run
```bash
git status --short
xcodebuild -version
xcodebuild -showsdks
xcrun simctl list runtimes
xcrun simctl list devices available
xcodegen --version
swift --version
swift package dump-package
```

## Required proof artifacts
docs/codex/ios26-toolchain-matrix.md and build/reports/ios26-migration/toolchain.md

## Accessibility requirements
Do not claim accessibility proof. Preserve accessibility behavior if scripts or source are touched.

## Privacy/local-first requirements
No cloud AI/LLM, hosted backend, analytics/tracking SDK, or privacy manifest weakening.

## iOS 26 API verification requirements
Green only if Xcode 26/iOS 26 SDK/runtime are available and SwiftPM syntax is confirmed. Yellow for partial toolchain with exact blocker. Red if target bump is attempted without proof.

## Green / Yellow / Red closeout rules
Green: scoped work complete with evidence and no forbidden changes.
Yellow: blocker or proof gap explicit with owner, no-claim boundary, and post-batch gate.
Red: forbidden change, missing runner metadata, unverified API adoption, privacy/local-first breach, or false release/readiness claim.

## Rollback strategy
Revert only files touched by this batch. Do not reset unrelated work.

## Final report format
```text
Status: Green / Yellow / Red
Batch:
Train:
Scope:
Branch:
Commit:
Files changed:
Truth files inspected:
Source areas inspected:
Commands run:
Commands not run:
Environment:
Evidence:
Passes:
Failures:
Skipped:
Unproven:
Accessibility status:
Privacy/local-first status:
iOS 26 API verification status:
Claims allowed:
Claims forbidden:
Release blockers:
Post-batch gates:
Rollback:
Next eligible batch:
```
