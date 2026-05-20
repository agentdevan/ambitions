<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T01-B02 — Deployment target bump

## Batch type
Project/package migration

## Objective
Move all iOS deployment targets from 17.0 to 26.0 after toolchain confirmation.

## Why this exists
The app modernization target is iOS 26 minimum.

## Dependencies
IOS26-T01-B01 Green or owner-accepted Yellow with explicit SDK syntax proof.

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
scripts/build-local.sh
scripts/setup_macos_ios_dev.sh
Native/AmbitionsWidgetExtension/AmbitionsWidgetBundle.swift

## Exact changes allowed
project.yml
Package.swift
scripts/build-local.sh
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/codex/ios26-migration-foundation-plan.md
build/reports/ios26-migration/deployment-target-bump.md

## Exact changes forbidden
No feature/runtime behavior changes. No UI redesign. No unverified SDK syntax.

## Implementation steps
1. Update IPHONEOS_DEPLOYMENT_TARGET to 26.0.
2. Update every deploymentTarget: "17.0" to "26.0".
3. Update Package.swift iOS platform to confirmed iOS 26 syntax.
4. Update build script destination preference for an available iOS 26 iPhone simulator without hardcoding nonexistent devices.
5. Regenerate project, build, and record logs.

## Tests to add/update
Focused unit tests if build succeeds and simulator is available.

## Commands to run
```bash
git diff -- project.yml Package.swift scripts/build-local.sh
xcodegen generate
swift package dump-package
scripts/build-local.sh
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=<available iOS 26 iPhone simulator>" -only-testing:AmbitionsTests test
```

## Required proof artifacts
build/reports/ios26-migration/deployment-target-bump.md

## Accessibility requirements
Do not claim accessibility proof. Preserve accessibility behavior if scripts or source are touched.

## Privacy/local-first requirements
No cloud AI/LLM, hosted backend, analytics/tracking SDK, or privacy manifest weakening.

## iOS 26 API verification requirements
Green only with generated project and build proof. Yellow if scoped but environment blocks validation. Red for unknown build failure plus unrelated repair.

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
