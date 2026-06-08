# AMB-590 Today Polish

Verdict: Green

## Scope

AMB-590 polished the Today first viewport after the AMB-572 object-stage primitive install. The patch stays inside the active Today / Reality Meridian owner plus the explicit concept-lock allowlist metadata needed for this Today polish batch.

This is source, focused unit-test, local simulator screenshot, and guard evidence for the scoped Today first viewport only. It is not release proof, device proof, human visual approval, performance proof, privacy/legal approval, TestFlight readiness, App Store readiness, CI proof, or full accessibility approval.

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

- Replaced the decorative Today star-dot field with a subdued meridian orientation sweep so the first viewport reads as a product object field, not decorative celestial wallpaper.
- Removed the decorative sparkle next to the Start Here recommendation title.
- Removed the misplaced active connector overlay that crossed the hero explanation text in the AMB-572 screenshot.
- Tightened the first-viewport `Up next` treatment into a lightweight relationship thread with smaller typography and line marks instead of a heavy schedule-like block.
- Added `AMB-590` to the existing `today_start_here` concept-lock allowlist after the post guard correctly blocked the scoped Today source touch.

## First Viewport Proof

- Screenshot: `artifacts/ambitions-ui-reconstruction/screenshots/amb-590-today-polish.png`
- Pixel dimensions: 1170 x 2532
- Capture commands:
  - `xcrun simctl install 81485ACD-AF10-4B92-8C03-9BB8805A4A23 .codex/DerivedData/Ambitions/Build/Products/Debug-iphonesimulator/Ambitions.app`
  - `SIMCTL_CHILD_AMBITIONS_BOOTSTRAP_MODE=preview SIMCTL_CHILD_AMBITIONS_PREVIEW_TODAY_SCENARIO=stable xcrun simctl launch --terminate-running-process 81485ACD-AF10-4B92-8C03-9BB8805A4A23 com.ambitions.ios --args -AmbitionsInitialSurface today -AmbitionsScreenshotMode YES`
  - `scripts/sim/simctl_screenshot.sh artifacts/ambitions-ui-reconstruction/screenshots/amb-590-today-polish.png --simulator 81485ACD-AF10-4B92-8C03-9BB8805A4A23 --diagnostic artifacts/ambitions-ui-reconstruction/screenshots/amb-590-today-polish.diagnostic.md --retries 3`
  - `sips -g pixelWidth -g pixelHeight artifacts/ambitions-ui-reconstruction/screenshots/amb-590-today-polish.png`
- Visual inspection result: the first viewport presents one full-bleed Reality Meridian / Start Here object stage. The previous explanation-line overlap is gone, the decorative star dots are not visible, and the `Up next` area reads as a subordinate line thread rather than a generic card/module stack.

## Focused Tests

- `make xcode-focused-test BATCH=AMB-590 TEST=AmbitionsTests/TodayRealityMeridianExperienceElevationTests` - passed
- Final focused log: `.codex/xcode-logs/AMB-590/20260608T173410Z-AmbitionsTests-TodayRealityMeridianExperienceElevationTests-15041-26087/focused-test.log`
- Output: `Executed 6 tests, with 0 failures (0 unexpected)`

## Guard Evidence

- Champion coverage: Green
- Champion coverage report: `build/reports/intelligence-consolidation/champion-coverage-check.md`
- Parallel guard pre: Green
- Parallel guard pre report: `build/reports/parallel-implementation-guard/AMB-590-pre.md`
- Parallel guard post: Green after bounded metadata repair
- Parallel guard post report: `build/reports/parallel-implementation-guard/AMB-590-post.md`
- Canonical owner extended: `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- New implementation owners: none
- Canonical owner map changed: no
- Supersession ledger updated: no
- Best-code rescue checked: no source fork or duplicate implementation was created
- Runtime wiring gate: no new runtime wiring
- Yellow accepted reason: none
- Red blockers: initial post guard Red for `today_start_here` lock; repaired by adding explicit `AMB-590` allowlist entry to the existing lock registry pattern

## Changed Files

- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `docs/codex/concept-lock-registry.yml`
- `prompts/batches/AMB-590.md`
- `artifacts/ambitions-ui-reconstruction/polish/AMB-590-today-polish.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-590-today-polish.png`

## Validation

- `python3 scripts/ambitions-champion-coverage-check.py --batch AMB-590` - passed; Green
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-590 --prompt prompts/batches/AMB-590.md --batch-type source-changing` - passed; Green
- `make xcode-focused-test BATCH=AMB-590 TEST=AmbitionsTests/TodayRealityMeridianExperienceElevationTests` - passed; `Executed 6 tests, with 0 failures (0 unexpected)`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-590 --prompt prompts/batches/AMB-590.md --changed-from a913c5a6969addbf7c13e601c8dfba4e16420a7b --batch-type source-changing` - passed after concept-lock allowlist repair; Green
- `sips -g pixelWidth -g pixelHeight artifacts/ambitions-ui-reconstruction/screenshots/amb-590-today-polish.png` - passed; 1170 x 2532
- `python3 scripts/ambitions-unsupported-claim-scan.py artifacts/ambitions-ui-reconstruction/polish/AMB-590-today-polish.md prompts/batches/AMB-590.md` - passed; Green
- `bash scripts/codex-forbidden-claim-scan.sh artifacts/ambitions-ui-reconstruction/polish/AMB-590-today-polish.md prompts/batches/AMB-590.md` - passed; no blocking hits
- `git diff --check` - passed
- `bash scripts/release-claim-safety-scan.sh` - passed; Green after staging the AMB-590 source, metadata, prompt, report, and screenshot files

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

None for the scoped AMB-590 first viewport polish.

## Rollback Notes

Revert the AMB-590 commit to restore the prior Today first-viewport atmosphere, title decoration, connector overlay, `Up next` row treatment, and concept-lock allowlist state.

If only proof artifacts need rollback, remove:

- `artifacts/ambitions-ui-reconstruction/polish/AMB-590-today-polish.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-590-today-polish.png`

## Required Completion Footer

Verdict: Green
Artifact paths:
- `artifacts/ambitions-ui-reconstruction/polish/AMB-590-today-polish.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-590-today-polish.png`
Focused tests:
- `make xcode-focused-test BATCH=AMB-590 TEST=AmbitionsTests/TodayRealityMeridianExperienceElevationTests` - passed; `Executed 6 tests, with 0 failures (0 unexpected)`
Changed files:
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `docs/codex/concept-lock-registry.yml`
- `prompts/batches/AMB-590.md`
- `artifacts/ambitions-ui-reconstruction/polish/AMB-590-today-polish.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-590-today-polish.png`
Rollback notes:
- Revert the AMB-590 commit to restore the prior Today first-viewport polish state.
Remaining Yellow debt:
- None
