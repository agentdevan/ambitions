# AOR-MOTION-01 Motion Current Structural Reconstruction Report

Issue: AMB-543
Date: 2026-06-06
Status: Yellow

## Scope

Replaced the old segmented-control-led Motion root with a living Motion Current field. The patch stays inside the active Motion owner plus narrow companion tests required by compile proof.

## Files changed

- `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift`
- `Native/AmbitionsTests/Motion/MotionCurrentScreenTests.swift`
- `prompts/batches/AMB-543.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/motion-current-after.png`
- `artifacts/ambitions-ui-reconstruction/reports/AOR-MOTION-01-report.md`

## Product behavior

- `MotionCurrentScreen` now renders these root children:
  - compact Context Crown
  - Motion Current field
  - Proof lane
  - Recovery lane
  - Re-entry lane
  - compact source/proof/receipt affordance
  - Continuity Dock
- Removed the old root `Picker` / segmented control model.
- Removed the old selected-strand node card stack.
- Removed the old `No Motion Yet` and `Source Unavailable` fixture states from live Motion source.
- Preserved source/proof/receipt/control visibility as first-viewport Motion Current semantics.
- Kept empty Motion state structured without reverting to an empty dashboard, report, activity feed, progress chart, score, streak, XP, or productivity-report frame.

## Active Truth Files Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`

## Runner And Guard Evidence

- Runner prompt saved with Ambitions runner header: `prompts/batches/AMB-543.md`
- Runner self-healed prompt wording only.
- Champion coverage passed in runner.
- Parallel implementation guard preflight passed: `build/reports/parallel-implementation-guard/AMB-543-pre.md`
- Nested runner phase stopped before patching because the external model/OAuth path was unavailable.
- Local bounded patch proceeded only after runner-local champion and pre-guard Green.

## Validation

Passed:

- `make xcode-build-for-testing BATCH=AMB-543`
  - final passing summary: `.codex/xcode-summaries/AMB-543/20260607T015339Z-bft-32811-13408/build-for-testing-summary.json`
- `make xcode-focused-test BATCH=AMB-543 TEST=AmbitionsTests/MotionCurrentScreenTests`
  - final passing summary: `.codex/xcode-summaries/AMB-543/20260607T015926Z-AmbitionsTests-MotionCurrentScreenTests-36167-8153/focused-test-summary.json`
  - executed tests: 5
- `make xcode-focused-test BATCH=AMB-543 TEST=AmbitionsUITests/AmbitionsUITests/testPreviewBootstrapExposesCanonicalFiveTabShellAndSecondarySurfaces`
  - final passing summary: `.codex/xcode-summaries/AMB-543/20260607T020317Z-AmbitionsUITests-AmbitionsUITests-testPreviewBootstrapExposesCanonicalFiveTabShe-38160-2722/focused-test-summary.json`
  - executed tests: 1
- Forbidden Motion structure scan:
  - `rg -n "Picker|segmented|No Motion Yet|Source Unavailable|analytics|dashboard|progress chart|activity feed|score|streak|XP|productivity|blocked|waiting|needs review" Native/Ambitions/Features/Motion/MotionCurrentScreen.swift Native/AmbitionsTests/Motion/MotionCurrentScreenTests.swift`
  - result: no matches

Repair cycles:

- First build failed because existing Motion tests referenced the deleted node/segment model.
- Second build failed because the updated test used invalid Swift key-path syntax for `lowercased()`.
- Third build passed after the narrow test repair.

## Screenshot Proof

Captured:

- `artifacts/ambitions-ui-reconstruction/screenshots/motion-current-after.png`

Observed change:

- First viewport no longer shows the segmented Proof / Recovery / Re-entry control.
- First viewport no longer shows the old `No Motion Yet` card.
- First viewport shows the new Motion crown, field, runtime inspection rows, and the beginning of the Proof lane.

## Accessibility Boundary

Implemented:

- Root screen accessibility identifier remains `motion.current.screen`.
- Motion field exposes combined accessibility label/value for title, summary, source, proof, receipt, and control.
- Lanes expose combined accessibility labels with title, status, and summary.
- Decorative glyphs are hidden from accessibility.
- Existing canonical shell UI test still opens Motion through the top-level tab shell.

Not verified:

- Manual VoiceOver traversal.
- Full Dynamic Type screenshot sweep.
- Reduce Motion screenshot.
- Increase Contrast screenshot.
- Real-device proof.
- Performance measurement.

## Claim Boundary

This is source, local simulator build/test, focused UI test, and screenshot proof for AMB-543 only. It is not release proof, public accessibility proof, performance proof, privacy/legal approval, physical-device proof, TestFlight readiness, or App Store readiness.

## Rollback

Revert the AMB-543 commit to restore the prior Motion root, stale Motion tests, prompt, screenshot, and report state.
