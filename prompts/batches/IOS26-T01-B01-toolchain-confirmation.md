<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T01-B01 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T01-B01`

## Train ID and title
`TRAIN_01` - iOS 26 minimum migration foundation

## Batch role in train
Batch 1 of 3 in TRAIN_01

## Upstream dependencies
- `TRAIN_00`

## Downstream dependencies
- `TRAIN_02`
- `TRAIN_03`
- `TRAIN_11`

## Objective
Confirm local Xcode 26/iOS 26/SwiftPM/XcodeGen toolchain before target bump.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, status board, chatbot, AI wrapper, SaaS admin panel, or ranking-based productivity framing.

## Local-first/privacy constraints
No cloud AI/LLM, hosted backend, analytics/tracking SDK, or privacy manifest weakening.

## Accessibility constraints
Do not claim accessibility proof. Preserve accessibility behavior if scripts or source are touched.

## Performance constraints when relevant
Do not regress launch, scrolling, persistence, or runtime responsiveness. Do not claim performance validation without measured proof.

## Champion Merge source boundary
- Champion Merge final status is accepted Yellow, not Red; IOS26 work may proceed only inside the no-claim boundaries below.
- Before source edits, inspect `docs/codex/canonical-owner-map.yml`, `docs/codex/concept-lock-registry.yml`, and `build/reports/intelligence-consolidation/TRAIN_04L_CLOSEOUT.md`.
- Extend the canonical owner for any touched concept. Do not create a new parallel owner or revive retired duplicate object names as active source/UI terms.
- Keep unresolved Yellow concepts locked against ordinary feature claims until their follow-up gate is Green or owner-accepted.

## Allowed files/directories
docs/codex/ios26-toolchain-matrix.md
build/reports/ios26-migration/toolchain.md

## Forbidden files/directories
No target bump yet. No project/package/source edits.

## Exact implementation steps
1. Record Xcode, SDKs, Swift, XcodeGen, simulator runtimes, and simulator devices.
2. Determine exact SwiftPM syntax for iOS 26 platform support.
3. Determine an available iOS 26 simulator destination.
4. Record blockers and do not mutate target settings.

## Validation commands
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

## Proof artifacts to write
docs/codex/ios26-toolchain-matrix.md and build/reports/ios26-migration/toolchain.md
- `build/reports/ios26-baseline/`
- `build/reports/ios26-migration/`
- `build/reports/ios26-shell/`
- `build/reports/private-life-runtime/`
- `build/reports/goal-intent-compiler/`
- `build/reports/life-context/`
- `build/reports/step-optionality/`
- `build/reports/source-atlas-runtime-bridge/`
- `build/reports/capture-runtime-bridge/`
- `build/reports/core-replacement-contracts/`
- `build/reports/core-life-object-store/`
- `build/reports/time-operations/`
- `build/reports/reminder-operations/`
- `build/reports/project-step-operations/`
- `build/reports/life-knowledge-operations/`
- `build/reports/life-command-search/`
- `build/reports/private-life-runtime-integration/`
- `build/reports/reality-meridian/`
- `build/reports/lifeshape-field/`
- `build/reports/constellation-atlas/`
- `build/reports/atmosphere-composer/`
- `build/reports/user-system-profile/`
- `build/reports/proof-receipts-replay/`
- `build/reports/data-safety/`
- `build/reports/external-surfaces/`
- `build/reports/accessibility-nutrition/`
- `build/reports/performance/`
- `build/reports/repo-hygiene/`
- `build/reports/release-candidate/`

## Green / Yellow / Red gates
Green: scoped work complete with evidence and no forbidden changes.
Yellow: blocker or proof gap explicit with owner, no-claim boundary, and post-batch gate.
Red: forbidden change, missing runner metadata, unverified API adoption, privacy/local-first breach, or false release/readiness claim.

## Rollback behavior
Revert only files touched by this batch. Do not reset unrelated work.

## Claims allowed
- This batch may claim only source, test, and proof outcomes directly demonstrated by current logs and artifacts.
- Docs-only or tooling-only changes must be described as docs-only or tooling-only.

## Claims forbidden
- No release readiness, TestFlight readiness, App Store readiness, CI proof, device proof, accessibility verification, performance validation, privacy/legal approval, or Private Life Runtime moat completion without matching current proof.

## Final report required fields
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

## STATUS placeholder
STATUS: <GREEN|YELLOW|RED>

## Original prompt intent retained
The original prompt text is retained below for intent preservation. The sealed sections above are the execution boundary.

----- BEGIN ORIGINAL PROMPT -----
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
----- END ORIGINAL PROMPT -----
