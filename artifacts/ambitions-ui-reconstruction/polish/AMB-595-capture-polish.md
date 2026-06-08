# AMB-595 Capture Polish

Verdict: Green

## Scope

AMB-595 polished the activated global Capture seam so the first viewport starts with Capture activation and input, then shows a compact Atmosphere Composer status strip for typing readiness, low-confidence route basis, and Reduce Motion-safe route meaning before deeper route review.

This is scoped source, focused test, and local simulator screenshot evidence for activated Capture polish only. It is not release proof, device proof, human visual approval, performance proof, privacy/legal approval, TestFlight readiness, App Store readiness, CI proof, or full accessibility approval.

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

- Moved activated Capture input ahead of route reveal/review so the seam reads as a composer-first global action.
- Added a compact Atmosphere Composer strip with typing readiness, deterministic review-needed route basis, and Reduce Motion-safe static labeling.
- Kept route review, correction, source trust, receipt, and no-silent-placement behavior on the existing Capture Routing primitive family.
- Added focused source-structure assertions for the new activation strip, compact state rows, and input-before-route order.
- Added the narrow AMB-595 allowance to the Capture routing concept lock before source edits.

## Activated View Proof

- Screenshot: `artifacts/ambitions-ui-reconstruction/screenshots/amb-595-capture-polish.png`
- Pixel dimensions: 1170 x 2532
- Capture commands:
  - `xcrun simctl install 81485ACD-AF10-4B92-8C03-9BB8805A4A23 .codex/DerivedData/Ambitions/Build/Products/Debug-iphonesimulator/Ambitions.app`
  - `SIMCTL_CHILD_AMBITIONS_BOOTSTRAP_MODE=demo SIMCTL_CHILD_AMBITIONS_LAUNCH_URL='ambitions://captures/inbox?origin=widget' xcrun simctl launch --terminate-running-process 81485ACD-AF10-4B92-8C03-9BB8805A4A23 com.ambitions.ios --args -AmbitionsInitialSurface today -AmbitionsScreenshotMode YES`
  - `scripts/sim/simctl_screenshot.sh artifacts/ambitions-ui-reconstruction/screenshots/amb-595-capture-polish.png --simulator 81485ACD-AF10-4B92-8C03-9BB8805A4A23 --retries 3`
  - `sips -g pixelWidth -g pixelHeight artifacts/ambitions-ui-reconstruction/screenshots/amb-595-capture-polish.png`
- Visual inspection result: the screenshot shows Today with the activated global Capture seam. The seam presents `Capture Anything`, entry source, input field, save/goal/dictation controls, and an Atmosphere Composer strip with `Ready for typing`, `Needs review before placement`, and `Reduce Motion ready`. Capture remains a global action and does not present a generic intake list, conversation surface, persistent floating action, or category picker.

## Focused Tests

- `make xcode-focused-test BATCH=AMB-595 TEST=AmbitionsTests/CaptureRoutingPrimitiveFamilyTests` - passed after visual polish repair cycles.
- Final focused log: `.codex/xcode-logs/AMB-595/20260608T210403Z-AmbitionsTests-CaptureRoutingPrimitiveFamilyTests-75745-16707/focused-test.log`
- Output: `Executed 4 tests, with 0 failures (0 unexpected)`.
- Repair notes:
  - First preflight failed because AMB-595 was not yet allowed on the locked Capture routing concept and the prompt lacked the required You / What Ambitions Knows inspection boundary. Added the narrow concept-lock allowance and repaired the prompt, then preflight passed.
  - First screenshot after input-first polish crowded the header because the new status strip was outside the seam scroll area. Moved the status strip into the scroll area and reran the focused test.
  - A later screenshot captured Today before the app-native Capture URL opened the seam. Recaptured with a longer wait and accepted the activated Capture screenshot.

## Changed Files

- `Native/Ambitions/App/AppShellView.swift`
- `Native/AmbitionsTests/App/CaptureRoutingPrimitiveFamilyTests.swift`
- `docs/codex/concept-lock-registry.yml`
- `prompts/batches/AMB-595.md`
- `artifacts/ambitions-ui-reconstruction/polish/AMB-595-capture-polish.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-595-capture-polish.png`

## Validation

- `python3 scripts/ambitions-champion-coverage-check.py` - passed before source edits; generated build reports were restored and not committed.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-595 --prompt prompts/batches/AMB-595.md` - failed once on missing Capture lock allowance and missing You inspection boundary, then passed after repairs.
- `make xcode-focused-test BATCH=AMB-595 TEST=AmbitionsTests/CaptureRoutingPrimitiveFamilyTests` - passed; final output `Executed 4 tests, with 0 failures (0 unexpected)`.
- `xcrun simctl install ... Ambitions.app` plus `scripts/sim/simctl_screenshot.sh ... amb-595-capture-polish.png` - captured 1170 x 2532 simulator screenshot.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-595 --prompt prompts/batches/AMB-595.md --changed-from f8161a8b06dc77007d1843f06dd11e6abe4948c9` - passed; report `build/reports/parallel-implementation-guard/AMB-595-post.md`.
- `python3 scripts/ambitions-unsupported-claim-scan.py --changed-from f8161a8b06dc77007d1843f06dd11e6abe4948c9` - passed.
- `bash scripts/codex-forbidden-claim-scan.sh Native/Ambitions/App/AppShellView.swift Native/AmbitionsTests/App/CaptureRoutingPrimitiveFamilyTests.swift docs/codex/concept-lock-registry.yml prompts/batches/AMB-595.md artifacts/ambitions-ui-reconstruction/polish/AMB-595-capture-polish.md` - no blocking hits.
- `python3 scripts/ambitions-champion-coverage-check.py` - passed after source edits; generated build reports were restored and not committed.
- `bash scripts/release-claim-safety-scan.sh` - passed.
- `git diff --check` - passed.

## Rollback Notes

- Revert the AMB-595 commit to restore the prior activated Capture ordering, remove the compact Atmosphere Composer activation strip, remove the AMB-595 focused assertions, remove the narrow AMB-595 Capture lock allowance, and remove AMB-595 proof artifacts.
- If only proof artifacts need rollback, remove:
  - `artifacts/ambitions-ui-reconstruction/polish/AMB-595-capture-polish.md`
  - `artifacts/ambitions-ui-reconstruction/screenshots/amb-595-capture-polish.png`

## Remaining Yellow Debt

- None.

## Required Completion Footer

Verdict: Green
Artifact paths:
- artifacts/ambitions-ui-reconstruction/polish/AMB-595-capture-polish.md
- artifacts/ambitions-ui-reconstruction/screenshots/amb-595-capture-polish.png
Focused tests:
- make xcode-focused-test BATCH=AMB-595 TEST=AmbitionsTests/CaptureRoutingPrimitiveFamilyTests - passed; Executed 4 tests, with 0 failures (0 unexpected)
Changed files:
- Native/Ambitions/App/AppShellView.swift
- Native/AmbitionsTests/App/CaptureRoutingPrimitiveFamilyTests.swift
- docs/codex/concept-lock-registry.yml
- prompts/batches/AMB-595.md
- artifacts/ambitions-ui-reconstruction/polish/AMB-595-capture-polish.md
- artifacts/ambitions-ui-reconstruction/screenshots/amb-595-capture-polish.png
Rollback notes:
- Revert the AMB-595 commit to restore prior activated Capture ordering, remove the compact Atmosphere Composer activation strip, remove AMB-595 focused assertions, remove the narrow AMB-595 Capture lock allowance, and remove AMB-595 proof artifacts.
Remaining Yellow debt:
- None
