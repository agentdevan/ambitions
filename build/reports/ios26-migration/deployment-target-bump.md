# IOS26-T01-B02 Deployment Target Bump Report

Status: Green

## Batch metadata

- Batch: `IOS26-T01-B02`
- Train: `IOS26 Train 01, minimum migration foundation`
- Phase: `04 - GPT-5.5 repair pass 1 validation closeout`
- Run directory: `.codex/runs/IOS26-T01-B02/20260522T114712Z`
- Starting commit: `1396071df7f13c3db95fb92f7aac197905424e39`
- Branch: `main`
- Date: `2026-05-22`

## Files changed

- `project.yml`
- `Package.swift`
- `scripts/build-local.sh`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `build/reports/ios26-migration/deployment-target-bump.md`

## Truth files inspected

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

## Source areas inspected

- `project.yml`
- `Package.swift`
- `scripts/build-local.sh`
- `prompts/batches/IOS26-T01-B02-deployment-target-bump.md`
- `build/reports/ios26-migration/toolchain.md`
- current build log at `output/logs/build-local-20260522-080717.log`

## Commands run

- `git diff -- project.yml Package.swift scripts/build-local.sh docs/truth/IMPLEMENTATION_TRUTH.md docs/truth/RELEASE_TRUTH.md docs/codex/ios26-migration-foundation-plan.md build/reports/ios26-migration/deployment-target-bump.md`
- `bash -n scripts/build-local.sh`
- `xcodegen generate`
- `swift package dump-package`
- `scripts/build-local.sh`
- `make xcode-focused-test BATCH=IOS26-T01-B02 TEST=AmbitionsTests/AppReleaseConfigurationTests`
- Phase 03 repair: tightened `scripts/build-local.sh` so it fails honestly when no iOS 26 iPhone simulator is available instead of falling back to a non-iOS 26 runtime.
- Phase 03 validation: `bash -n scripts/build-local.sh`
- Phase 03 validation: `git diff --check -- project.yml Package.swift scripts/build-local.sh docs/truth/IMPLEMENTATION_TRUTH.md docs/truth/RELEASE_TRUTH.md build/reports/ios26-migration/deployment-target-bump.md`
- Phase 03 validation: `xcodegen generate`
- Phase 03 validation: `swift package dump-package`
- Phase 03 validation: `scripts/build-local.sh`
- Phase 03 validation: `make xcode-focused-test BATCH=IOS26-T01-B02 TEST=AmbitionsTests/AppReleaseConfigurationTests`
- Phase 04 validation: `bash -n scripts/build-local.sh`
- Phase 04 validation: `git diff --check -- project.yml Package.swift scripts/build-local.sh docs/truth/IMPLEMENTATION_TRUTH.md docs/truth/RELEASE_TRUTH.md build/reports/ios26-migration/deployment-target-bump.md`
- Phase 04 validation: `xcodegen generate`
- Phase 04 validation: `swift package dump-package`
- Phase 04 validation: `scripts/build-local.sh`
- Phase 04 validation: `make xcode-focused-test BATCH=IOS26-T01-B02 TEST=AmbitionsTests/AppReleaseConfigurationTests`

## Commands not run

- Raw `xcodebuild` commands outside the approved wrapper lanes
- Any source/runtime/UI changes outside the approved migration slice

## Environment

- Branch: `main`
- Generated project: `Ambitions.xcodeproj`
- Local simulator destination used by the build wrapper: `platform=iOS Simulator,name=iPhone 17`
- Local simulator runtime observed in wrapper logs: iOS 26.2 SDK / iOS 26.3 runtime

## Evidence

- `project.yml` now sets `IPHONEOS_DEPLOYMENT_TARGET: 26.0` and every target deployment target to `26.0`.
- `Package.swift` now uses `// swift-tools-version: 6.2` and `.iOS(.v26)`.
- `scripts/build-local.sh` now selects an available iOS 26 iPhone simulator by checking the runtime grouping and fails honestly if no iOS 26 iPhone simulator is available.
- `swift package dump-package` reported iOS platform `26.0` and tools version `6.2.0`.
- `scripts/build-local.sh` completed successfully during Phase 04 and wrote `output/logs/build-local-20260522-080717.log`.
- `make xcode-focused-test BATCH=IOS26-T01-B02 TEST=AmbitionsTests/AppReleaseConfigurationTests` completed successfully during Phase 04 with `xcode validation passed`; summary: `.codex/xcode-summaries/IOS26-T01-B02/20260522T120851Z/focused-test-summary.json`.

## Passes

- Deployment targets were bumped to iOS 26.0 in the project file.
- SwiftPM platform syntax was bumped to `.iOS(.v26)` with PackageDescription 6.2.
- The local build wrapper passed.
- The focused validation lane passed.
- The build wrapper selected an iOS 26 simulator destination rather than assuming an unavailable device, and no longer falls back to a non-iOS 26 simulator runtime.

## Failures

- None in the approved migration slice.

## Skipped

- No app/runtime/source UI files were edited.
- No dependency changes were introduced.
- No raw `xcodebuild` shell proof was collected outside the wrapper lanes.

## Unproven

- Full test suite pass/fail.
- Accessibility proof.
- Privacy/legal approval.
- Release readiness.

## Accessibility status

- Not verified in this batch.

## Privacy/local-first status

- Preserved. No cloud AI/LLM, analytics/tracking SDK, or hosted backend changes were introduced.

## iOS 26 API verification status

- Confirmed for this migration slice: the manifest and project targets now resolve at iOS 26.0, and the focused validation lane passed on an iOS 26 simulator destination.

## Claims allowed

- The repo now targets iOS 26.0 in `project.yml`.
- The package manifest now declares `.iOS(.v26)`.
- The local build wrapper and focused test lane both passed for this migration slice.

## Claims forbidden

- Do not claim full release readiness.
- Do not claim full-suite validation.
- Do not claim accessibility, privacy, or device-readiness proof.

## Release blockers

- None for the approved migration slice.
- Broader release readiness remains unproven.

## Post-batch gates

- Continue with the next IOS26 batch only through the runner and only after preserving proof honesty.

## Rollback

- Revert only the files listed in `Files changed` if this migration slice needs to be undone.

## Next eligible batch

- `IOS26-T01-B03` if the owner accepts the current proof boundaries.
