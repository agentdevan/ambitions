# AMB-596 Final Cross-Surface Polish Pass

Verdict: Green for AMB-596 scoped final first-viewport polish.

## Scope

AMB-596 reviewed the first viewport rhythm, density, continuity, primitive consistency, screenshot posture, and no-card-law posture across Today, Goals, Time, Motion, You, and global Capture.

One source repair was needed: the Goals Direction Atlas Source / Proof trust-depth lanes used first-viewport text that still ellipsized in the compact object stage. The repair keeps the existing Goals object-stage primitive and full accessibility summaries, but gives the visible first-viewport trust lanes and relationship contour compact display labels.

This is source, focused XCTest, and local simulator screenshot evidence for the scoped first-viewport polish only. It is not release proof, real-device proof, TestFlight proof, App Store proof, CI proof, performance proof, privacy/legal approval, public accessibility approval, or human visual approval.

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

- Added a Goals first-viewport trust summary for the selected Direction Atlas header.
- Added compact visible Source and Proof lane details so Source / Proof depth no longer ellipsizes in the first viewport.
- Kept the full SourceRecord, Receipt, ReplayTrace, Today link, and You inspection summaries in existing model/accessibility paths.
- Replaced only the compact relationship-contour display labels with fitting visible labels; the underlying life-area values remain unchanged.
- Updated the focused Goals object-stage primitive tests to guard the AMB-596 non-truncating first-viewport trust-depth path.

## First Viewport Proof

- Today screenshot: `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-today-first-viewport.png`
- Goals screenshot: `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-goals-first-viewport.png`
- Time screenshot: `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-time-first-viewport.png`
- Motion screenshot: `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-motion-first-viewport.png`
- You screenshot: `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-you-first-viewport.png`
- Capture screenshot: `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-capture-first-viewport.png`
- Pixel dimensions for all six screenshots: 1170 x 2532.

Visual inspection result:

- Today: Green. Start Here remains the primary first-viewport object, with proof/source context and subordinate Up Next rhythm.
- Goals: Green after repair. Direction Atlas, equal-weight life areas, Source / Proof trust depth, and compact relationship contour fit without visible ellipses in the first viewport.
- Time: Green. LifeShape Field remains a single first-viewport object stage rather than a free/busy or calendar-density layout.
- Motion: Green. Motion Current keeps proof/progress/recovery/re-entry inspection without becoming an activity feed or metric wall.
- You: Green. Runtime governance and What Ambitions Knows inspection remain first-viewport visible without turning into generic settings copy.
- Capture: Green. Capture remains a contextual global action/composer route, not a tab or inbox surface.

Goals recapture commands after the repair:

- `xcrun simctl install 81485ACD-AF10-4B92-8C03-9BB8805A4A23 .codex/DerivedData/Ambitions/Build/Products/Debug-iphonesimulator/Ambitions.app`
- `SIMCTL_CHILD_AMBITIONS_BOOTSTRAP_MODE=demo xcrun simctl launch --terminate-running-process 81485ACD-AF10-4B92-8C03-9BB8805A4A23 com.ambitions.ios --args -AmbitionsInitialSurface goals -AmbitionsScreenshotMode YES -AmbitionsGoalsRenderState proof-available`
- `scripts/sim/simctl_screenshot.sh artifacts/ambitions-ui-reconstruction/screenshots/amb-596-goals-first-viewport.png --simulator 81485ACD-AF10-4B92-8C03-9BB8805A4A23 --retries 3`
- `sips -g pixelWidth -g pixelHeight artifacts/ambitions-ui-reconstruction/screenshots/amb-596-goals-first-viewport.png`

## Focused Tests

- `make xcode-focused-test BATCH=AMB-596 TEST=AmbitionsTests/GoalsObjectStagePrimitiveTests` - passed.
- Final focused log: `.codex/xcode-logs/AMB-596/20260608T214419Z-AmbitionsTests-GoalsObjectStagePrimitiveTests-85678-7224/focused-test.log`
- Output: `Executed 4 tests, with 0 failures (0 unexpected)`.

## Guard And Scan Validation

- `python3 scripts/ambitions-champion-coverage-check.py` - Green before source edits; generated report outputs are restored before commit.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-596 --prompt prompts/batches/AMB-596.md --batch-type source-changing` - Green before source edits.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-596 --prompt prompts/batches/AMB-596.md --changed-from 9904ab97156e78f7347f85e31aa06bb49dc5ec24 --batch-type source-changing` - Green.
- `python3 scripts/ambitions-unsupported-claim-scan.py --changed-from 9904ab97156e78f7347f85e31aa06bb49dc5ec24` - Green.
- `bash scripts/codex-forbidden-claim-scan.sh Native/Ambitions/Features/Goals/GoalComponents.swift Native/Ambitions/Features/Goals/GoalsFeatureModels.swift Native/AmbitionsTests/Goals/GoalsObjectStagePrimitiveTests.swift prompts/batches/AMB-596.md artifacts/ambitions-ui-reconstruction/polish/AMB-596-final-cross-surface-polish-pass.md` - no blocking hits.
- `bash scripts/release-claim-safety-scan.sh` - Green.
- `python3 scripts/ambitions-champion-coverage-check.py` - Green after source edits; generated report outputs are restored before commit.
- `git diff --check` - clean.

## Changed Files

- `Native/Ambitions/Features/Goals/GoalComponents.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureModels.swift`
- `Native/AmbitionsTests/Goals/GoalsObjectStagePrimitiveTests.swift`
- `prompts/batches/AMB-596.md`
- `artifacts/ambitions-ui-reconstruction/polish/AMB-596-final-cross-surface-polish-pass.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-today-first-viewport.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-goals-first-viewport.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-time-first-viewport.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-motion-first-viewport.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-you-first-viewport.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-capture-first-viewport.png`

## Proof Boundaries

- Local simulator screenshot evidence proves only the scoped AMB-596 first-viewport polish review and the Goals first-viewport repair.
- Focused XCTest evidence proves the Goals object-stage source contract and AMB-596 first-viewport trust-depth source checks.
- Manual VoiceOver traversal, Dynamic Type screenshot bands, Reduce Motion walkthrough, Increase Contrast review, performance measurement, physical-device behavior, privacy/legal review, signed archive validation, TestFlight readiness, App Store readiness, CI proof, and release readiness are not claimed.

## Rollback Notes

- Revert the AMB-596 commit to restore the prior Goals compact trust lane copy, relationship contour labels, AMB-596 prompt, report, and screenshot artifacts.
- If only proof artifacts need rollback, remove:
  - `artifacts/ambitions-ui-reconstruction/polish/AMB-596-final-cross-surface-polish-pass.md`
  - `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-today-first-viewport.png`
  - `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-goals-first-viewport.png`
  - `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-time-first-viewport.png`
  - `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-motion-first-viewport.png`
  - `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-you-first-viewport.png`
  - `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-capture-first-viewport.png`

## Remaining Yellow Debt

- None for the AMB-596 scoped first-viewport final polish pass.

## Required Completion Footer

Verdict: Green
Artifact paths:
- `artifacts/ambitions-ui-reconstruction/polish/AMB-596-final-cross-surface-polish-pass.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-today-first-viewport.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-goals-first-viewport.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-time-first-viewport.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-motion-first-viewport.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-you-first-viewport.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-capture-first-viewport.png`
Focused tests:
- `make xcode-focused-test BATCH=AMB-596 TEST=AmbitionsTests/GoalsObjectStagePrimitiveTests` - passed; `Executed 4 tests, with 0 failures (0 unexpected)`
Changed files:
- `Native/Ambitions/Features/Goals/GoalComponents.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureModels.swift`
- `Native/AmbitionsTests/Goals/GoalsObjectStagePrimitiveTests.swift`
- `prompts/batches/AMB-596.md`
- `artifacts/ambitions-ui-reconstruction/polish/AMB-596-final-cross-surface-polish-pass.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-today-first-viewport.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-goals-first-viewport.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-time-first-viewport.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-motion-first-viewport.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-you-first-viewport.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-596-capture-first-viewport.png`
Rollback notes:
- Revert the AMB-596 commit to restore the prior Goals compact trust lane copy, relationship contour labels, prompt, report, and screenshots.
Remaining Yellow debt:
- None
