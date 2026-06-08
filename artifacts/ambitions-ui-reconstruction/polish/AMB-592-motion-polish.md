# AMB-592 Motion Polish

Verdict: Green for AMB-592 scoped Motion first-viewport polish.

## Scope

AMB-592 polished the Motion Current first viewport so proof, recovery, re-entry, source, proof, and receipt read as one Motion Current object field. This is a source, focused XCTest, and local simulator screenshot proof packet for the scoped Motion presentation change only.

This is not release proof, real-device proof, TestFlight proof, App Store proof, CI proof, performance proof, privacy/legal approval, public accessibility approval, or human visual approval.

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

- Replaced the detached Motion field glyph with an inline proof / recovery / re-entry rhythm spine inside the Motion Current field.
- Kept source, proof, and receipt affordances in the same first-viewport object field using the installed proof / relationship / trace primitive lines.
- Softened the Motion proof-thread Canvas texture so the field reads less like a rectangular block and more like a current object stage.
- Removed the visible negative proof-state copy about a feed and replaced it with source, receipt, and return-point copy.
- Tightened first-viewport vertical spacing and crown trace layout so the final screenshot keeps labels readable without clipping.
- Extended focused Motion tests to assert the rhythm spine, accessibility identifier, and removal of the detached glyph view.

## Repair Cycle

- Initial AMB-592 screenshot showed the field falling back into a vertical layout: proof / recovery / re-entry were visible, but source / proof / receipt affordances were pushed under the bottom veil.
- Repaired `MotionCurrentField` to keep the rhythm spine and field facts in a compact horizontal object-stage layout.
- Initial repair screenshot exposed clipped crown trace text on `Receipt-aware`.
- Repaired the crown trace layout and recaptured the final screenshot.

## First Viewport Proof

- Screenshot: `artifacts/ambitions-ui-reconstruction/screenshots/amb-592-motion-polish.png`
- Pixel dimensions: 1170 x 2532
- Capture commands:
  - `xcrun simctl install 81485ACD-AF10-4B92-8C03-9BB8805A4A23 .codex/DerivedData/Ambitions/Build/Products/Debug-iphonesimulator/Ambitions.app`
  - `SIMCTL_CHILD_AMBITIONS_BOOTSTRAP_MODE=demo xcrun simctl launch --terminate-running-process 81485ACD-AF10-4B92-8C03-9BB8805A4A23 com.ambitions.ios --args -AmbitionsInitialSurface motion -AmbitionsScreenshotMode YES -AmbitionsMotionRenderState proof`
  - `scripts/sim/simctl_screenshot.sh artifacts/ambitions-ui-reconstruction/screenshots/amb-592-motion-polish.png --simulator 81485ACD-AF10-4B92-8C03-9BB8805A4A23 --retries 3`
  - `sips -g pixelWidth -g pixelHeight artifacts/ambitions-ui-reconstruction/screenshots/amb-592-motion-polish.png`
- Visual inspection result: Motion first viewport shows Motion Current, local/source/receipt traces, inline proof / recovery / re-entry rhythm, and source / proof / receipt affordances above the bottom veil. No metric wall, activity stream, ranked summary, or generic container output is introduced in the scoped first viewport.

## Focused Tests

- `make xcode-focused-test BATCH=AMB-592 TEST=AmbitionsTests/MotionCurrentScreenTests` - passed.
- Final focused log: `.codex/xcode-logs/AMB-592/20260608T190744Z-AmbitionsTests-MotionCurrentScreenTests-47238-17048/focused-test.log`
- Output: `Executed 11 tests, with 0 failures (0 unexpected)`.

## Guard And Scan Validation

- `python3 scripts/ambitions-champion-coverage-check.py` - Green before source edits; generated report outputs were restored before commit.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-592 --prompt prompts/batches/AMB-592.md --batch-type source-changing` - Green before source edits.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-592 --prompt prompts/batches/AMB-592.md --changed-from 7174f396f2e704c407a415bead9dea00e48f344a --batch-type source-changing` - Green.
- `python3 scripts/ambitions-unsupported-claim-scan.py artifacts/ambitions-ui-reconstruction/polish/AMB-592-motion-polish.md prompts/batches/AMB-592.md` - Green.
- `bash scripts/codex-forbidden-claim-scan.sh artifacts/ambitions-ui-reconstruction/polish/AMB-592-motion-polish.md prompts/batches/AMB-592.md` - no blocking hits.
- `git diff --check` - clean.

## Changed Files

- `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift`
- `Native/AmbitionsTests/Motion/MotionCurrentScreenTests.swift`
- `prompts/batches/AMB-592.md`
- `artifacts/ambitions-ui-reconstruction/polish/AMB-592-motion-polish.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-592-motion-polish.png`

## Proof Boundaries

- Local simulator screenshot evidence proves only the scoped AMB-592 first-viewport Motion polish.
- Focused XCTest evidence proves the Motion source contract and fixture-level copy/structure checks.
- Manual VoiceOver traversal, Dynamic Type screenshot bands, Reduce Motion walkthrough, Increase Contrast review, performance measurement, physical-device behavior, privacy/legal review, signed archive validation, TestFlight readiness, App Store readiness, CI proof, and release readiness are not claimed.

## Rollback Notes

- Revert the AMB-592 commit to restore the prior Motion field glyph, crown trace layout, proof-state copy, tests, prompt, report, and screenshot artifact.
- If only proof artifacts need rollback, remove:
  - `artifacts/ambitions-ui-reconstruction/polish/AMB-592-motion-polish.md`
  - `artifacts/ambitions-ui-reconstruction/screenshots/amb-592-motion-polish.png`

## Remaining Yellow Debt

- None for the AMB-592 scoped first-viewport Motion polish.

## Required Completion Footer

Verdict: Green
Artifact paths:
- `artifacts/ambitions-ui-reconstruction/polish/AMB-592-motion-polish.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-592-motion-polish.png`
Focused tests:
- `make xcode-focused-test BATCH=AMB-592 TEST=AmbitionsTests/MotionCurrentScreenTests` - passed; `Executed 11 tests, with 0 failures (0 unexpected)`
Changed files:
- `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift`
- `Native/AmbitionsTests/Motion/MotionCurrentScreenTests.swift`
- `prompts/batches/AMB-592.md`
- `artifacts/ambitions-ui-reconstruction/polish/AMB-592-motion-polish.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-592-motion-polish.png`
Rollback notes:
- Revert the AMB-592 commit to restore the prior Motion field glyph, crown trace layout, proof-state copy, tests, prompt, report, and screenshot artifact.
Remaining Yellow debt:
- None
