# AMB-591 Time Polish

Verdict: Green

## Scope

AMB-591 polished the Time first viewport after the Time object-stage and Horizon / Capacity primitive installs. The patch keeps Time as the LifeShape Field owner, uses the installed Time primitives, and does not create a parallel Time, calendar, capacity, planning, or runtime implementation.

This is source, focused-test, local simulator screenshot, and guard evidence for the scoped Time first viewport only. It is not release proof, device proof, human visual approval, performance proof, privacy/legal approval, TestFlight readiness, App Store readiness, CI proof, or full accessibility approval.

## Active Truth Inspected

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

## What Changed

- Moved the LifeShape object canvas above the Horizon control so Time opens on the capacity texture, not a control block.
- Changed the default LifeShape texture from a two-column grid into a single-column line texture.
- Limited the regular first-viewport texture to the primary visible marks so the LifeShape reading stays legible above the shell mask.
- Softened and edge-masked the Time pressure Canvas backdrop so it reads as ambient field texture, not a rectangular panel.
- Moved the object-stage content to top-leading alignment so texture, title, and summary stay together.
- Updated the focused Time source assertion to lock the new no-grid texture.
- Added `AMB-591` to the existing `time_plan_lifeshape` concept-lock allowlist after the post guard correctly blocked the scoped Time source touch.

## First Viewport Proof

- Screenshot: `artifacts/ambitions-ui-reconstruction/screenshots/amb-591-time-polish.png`
- Pixel dimensions: 1170 x 2532
- Capture commands:
  - `xcrun simctl install 81485ACD-AF10-4B92-8C03-9BB8805A4A23 .codex/DerivedData/Ambitions/Build/Products/Debug-iphonesimulator/Ambitions.app`
  - `SIMCTL_CHILD_AMBITIONS_BOOTSTRAP_MODE=demo xcrun simctl launch --terminate-running-process 81485ACD-AF10-4B92-8C03-9BB8805A4A23 com.ambitions.ios --args -AmbitionsInitialSurface time -AmbitionsScreenshotMode YES -AmbitionsTimeRenderState default`
  - `scripts/sim/simctl_screenshot.sh artifacts/ambitions-ui-reconstruction/screenshots/amb-591-time-polish.png --simulator 81485ACD-AF10-4B92-8C03-9BB8805A4A23 --diagnostic artifacts/ambitions-ui-reconstruction/screenshots/amb-591-time-polish.diagnostic.md --retries 3`
  - `sips -g pixelWidth -g pixelHeight artifacts/ambitions-ui-reconstruction/screenshots/amb-591-time-polish.png`
- Visual inspection result: Time presents one first-viewport LifeShape Field object stage. The Horizon primitive control block is below the visible first viewport, the prior two-column texture grid is gone, and no calendar grid, metric-tile wall, or card output is visible in the scoped viewport.

## Focused Tests

- `make xcode-focused-test BATCH=AMB-591 TEST=AmbitionsTests/TimeFeatureServiceTests` - passed
  - Final focused log: `.codex/xcode-logs/AMB-591/20260608T182823Z-AmbitionsTests-TimeFeatureServiceTests-33854-23803/focused-test.log`
  - Output: `Executed 48 tests, with 0 failures (0 unexpected)`
- `make xcode-focused-test BATCH=AMB-591 TEST=AmbitionsTests/HorizonCapacityPrimitiveFamilyTests` - passed
  - Final focused log: `.codex/xcode-logs/AMB-591/20260608T183204Z-AmbitionsTests-HorizonCapacityPrimitiveFamilyTests-35078-8531/focused-test.log`
  - Output: `Executed 4 tests, with 0 failures (0 unexpected)`

## Guard Evidence

- Champion coverage: Green
- Champion coverage report: `build/reports/intelligence-consolidation/champion-coverage-check.md`
- Parallel guard pre: Green after prompt wording repair
- Parallel guard pre report: `build/reports/parallel-implementation-guard/AMB-591-pre.md`
- Parallel guard post: Green after bounded metadata repair
- Parallel guard post report: `build/reports/parallel-implementation-guard/AMB-591-post.md`
- Canonical owner extended: `Native/Ambitions/Features/Time/TimeLifeShapeField.swift`
- New implementation owners: none
- Canonical owner map changed: no
- Supersession ledger updated: no
- Best-code rescue checked: no source fork or duplicate implementation was created
- Runtime wiring gate: no new runtime wiring
- Yellow accepted reason: none
- Red blockers:
  - Initial pre guard Red for prompt-only old-term wording; repaired before source edits.
  - Initial post guard Red for `time_plan_lifeshape` lock; repaired by adding explicit `AMB-591` allowlist entry to the existing lock registry pattern.

## Changed Files

- `Native/Ambitions/Features/Time/TimeLifeShapeField.swift`
- `Native/AmbitionsTests/Time/TimeFeatureServiceTests.swift`
- `docs/codex/concept-lock-registry.yml`
- `prompts/batches/AMB-591.md`
- `artifacts/ambitions-ui-reconstruction/polish/AMB-591-time-polish.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-591-time-polish.png`

## Validation

- `python3 scripts/ambitions-champion-coverage-check.py --batch AMB-591` - passed; Green
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-591 --prompt prompts/batches/AMB-591.md --batch-type source-changing` - passed after prompt wording repair; Green
- `make xcode-focused-test BATCH=AMB-591 TEST=AmbitionsTests/TimeFeatureServiceTests` - passed; `Executed 48 tests, with 0 failures (0 unexpected)`
- `make xcode-focused-test BATCH=AMB-591 TEST=AmbitionsTests/HorizonCapacityPrimitiveFamilyTests` - passed; `Executed 4 tests, with 0 failures (0 unexpected)`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-591 --prompt prompts/batches/AMB-591.md --changed-from cba3abe4d37398f49b9f84a9eb5d5354632e2380 --batch-type source-changing` - passed after concept-lock allowlist repair; Green
- `sips -g pixelWidth -g pixelHeight artifacts/ambitions-ui-reconstruction/screenshots/amb-591-time-polish.png` - passed; 1170 x 2532
- `python3 scripts/ambitions-unsupported-claim-scan.py artifacts/ambitions-ui-reconstruction/polish/AMB-591-time-polish.md prompts/batches/AMB-591.md` - passed; Green
- `bash scripts/codex-forbidden-claim-scan.sh artifacts/ambitions-ui-reconstruction/polish/AMB-591-time-polish.md prompts/batches/AMB-591.md` - passed; no blocking hits
- `git diff --check` - passed
- `bash scripts/release-claim-safety-scan.sh` - passed; Green after staging the AMB-591 source, test, metadata, prompt, report, and screenshot files

## Not Verified

- Full test suite.
- Manual VoiceOver traversal.
- Dynamic Type screenshot sweep.
- Reduce Motion walkthrough.
- Increase Contrast measured review.
- Physical-device rendering.
- Performance measurement.
- Release, TestFlight, App Store, privacy/legal, or CI readiness.

## Remaining Yellow Debt

None for the scoped AMB-591 first viewport polish.

## Rollback Notes

Revert the AMB-591 commit to restore the prior Time first-viewport order, two-column LifeShape texture, Canvas backdrop opacity/masking, semantic mark visibility count, focused source assertion, prompt, report, screenshot, and concept-lock allowlist state.

If only proof artifacts need rollback, remove:

- `artifacts/ambitions-ui-reconstruction/polish/AMB-591-time-polish.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-591-time-polish.png`

## Required Completion Footer

Verdict: Green
Artifact paths:
- `artifacts/ambitions-ui-reconstruction/polish/AMB-591-time-polish.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-591-time-polish.png`
Focused tests:
- `make xcode-focused-test BATCH=AMB-591 TEST=AmbitionsTests/TimeFeatureServiceTests` - passed; `Executed 48 tests, with 0 failures (0 unexpected)`
- `make xcode-focused-test BATCH=AMB-591 TEST=AmbitionsTests/HorizonCapacityPrimitiveFamilyTests` - passed; `Executed 4 tests, with 0 failures (0 unexpected)`
Changed files:
- `Native/Ambitions/Features/Time/TimeLifeShapeField.swift`
- `Native/AmbitionsTests/Time/TimeFeatureServiceTests.swift`
- `docs/codex/concept-lock-registry.yml`
- `prompts/batches/AMB-591.md`
- `artifacts/ambitions-ui-reconstruction/polish/AMB-591-time-polish.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-591-time-polish.png`
Rollback notes:
- Revert the AMB-591 commit to restore the prior Time first-viewport polish state.
Remaining Yellow debt:
- None
