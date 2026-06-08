# AMB-594 You Polish

Verdict: Green

## Scope

AMB-594 polished the You root first viewport so the Personal Runtime / User System Profile starts from a compact governance control group before the broader grouped navigation list. Trust & Automation, Personal Runtime, and Receipts & History are now visible as the first inspectable controls, with line-based status treatment instead of capsule status chrome.

This is scoped source, focused test, and local simulator screenshot evidence for the You root polish only. It is not release proof, device proof, human visual approval, performance proof, privacy/legal approval, TestFlight readiness, App Store readiness, CI proof, or full accessibility approval.

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

- Added a first-viewport `Runtime Governance` control group for Trust & Automation, Personal Runtime, and Receipts & History.
- Kept the full semantic grouped navigation below the priority governance controls.
- Replaced You root status capsule chrome with line-based status emphasis.
- Extended the focused Personal System Center design-system coverage to assert the priority governance group and the no-capsule status treatment.
- Added the narrow AMB-594 allowance to the You personal-runtime concept lock after the post guard flagged the source touch as blocked without an explicit allowed batch.

## First Viewport Proof

- Screenshot: `artifacts/ambitions-ui-reconstruction/screenshots/amb-594-you-polish.png`
- Pixel dimensions: 1170 x 2532
- Capture commands:
  - `xcrun simctl install 81485ACD-AF10-4B92-8C03-9BB8805A4A23 .codex/DerivedData/Ambitions/Build/Products/Debug-iphonesimulator/Ambitions.app`
  - `SIMCTL_CHILD_AMBITIONS_BOOTSTRAP_MODE=demo xcrun simctl launch --terminate-running-process 81485ACD-AF10-4B92-8C03-9BB8805A4A23 com.ambitions.ios --args -AmbitionsInitialSurface you -AmbitionsScreenshotMode YES`
  - `scripts/sim/simctl_screenshot.sh artifacts/ambitions-ui-reconstruction/screenshots/amb-594-you-polish.png --simulator 81485ACD-AF10-4B92-8C03-9BB8805A4A23 --retries 3`
  - `sips -g pixelWidth -g pixelHeight artifacts/ambitions-ui-reconstruction/screenshots/amb-594-you-polish.png`
- Visual inspection result: the first viewport presents Personal Runtime / User System Profile, then the Runtime Governance group with Trust & Automation, Personal Runtime, and Receipts & History before the broader Planning Setup controls. It does not present a detached profile hero, admin/status wall, or generic settings-wall output.

## Focused Tests

- `make xcode-focused-test BATCH=AMB-594 TEST=AmbitionsTests/PersonalSystemCenterDesignSystemTests` - passed after one visual polish repair cycle.
- Final focused log: `.codex/xcode-logs/AMB-594/20260608T202012Z-AmbitionsTests-PersonalSystemCenterDesignSystemTests-65742-11401/focused-test.log`
- Output: `Executed 5 tests, with 0 failures (0 unexpected)`.
- Repair note: the first screenshot showed a visible truncation in the Trust & Automation priority row subtitle. The row subtitle limit was increased from two lines to three lines, then the same focused command passed and the screenshot was recaptured.

## Changed Files

- `Native/Ambitions/Features/You/YouRootSurface.swift`
- `Native/AmbitionsTests/App/PersonalSystemCenterDesignSystemTests.swift`
- `docs/codex/concept-lock-registry.yml`
- `prompts/batches/AMB-594.md`
- `artifacts/ambitions-ui-reconstruction/polish/AMB-594-you-polish.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-594-you-polish.png`

## Validation

- `python3 scripts/ambitions-champion-coverage-check.py` - passed before source edits; generated build reports were restored and not committed.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-594 --prompt prompts/batches/AMB-594.md` - passed before source edits.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-594 --prompt prompts/batches/AMB-594.md --changed-from d627819c571b29862d67e768e2c29f4b15159589` - failed once because AMB-594 was not yet allowed for the locked You personal-runtime concept; repaired by adding the narrow AMB-594 concept-lock allowance.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-594 --prompt prompts/batches/AMB-594.md --changed-from d627819c571b29862d67e768e2c29f4b15159589` - passed after the concept-lock allowance repair; report `build/reports/parallel-implementation-guard/AMB-594-post.md`.
- `make xcode-focused-test BATCH=AMB-594 TEST=AmbitionsTests/PersonalSystemCenterDesignSystemTests` - passed; final output `Executed 5 tests, with 0 failures (0 unexpected)`.
- `xcrun simctl install ... Ambitions.app` plus `scripts/sim/simctl_screenshot.sh ... amb-594-you-polish.png` - captured 1170 x 2532 simulator screenshot.
- `python3 scripts/ambitions-unsupported-claim-scan.py --changed-from d627819c571b29862d67e768e2c29f4b15159589` - passed.
- `bash scripts/codex-forbidden-claim-scan.sh Native/Ambitions/Features/You/YouRootSurface.swift Native/AmbitionsTests/App/PersonalSystemCenterDesignSystemTests.swift docs/codex/concept-lock-registry.yml prompts/batches/AMB-594.md artifacts/ambitions-ui-reconstruction/polish/AMB-594-you-polish.md` - no blocking hits.
- `python3 scripts/ambitions-champion-coverage-check.py` - passed after source edits; generated build reports were restored and not committed.
- `bash scripts/release-claim-safety-scan.sh` - passed.
- `git diff --check` - passed.

## Rollback Notes

- Revert the AMB-594 commit to remove the Runtime Governance first-viewport group, restore the prior You root status capsule treatment, and remove the AMB-594 focused assertions and proof artifacts.
- If only proof artifacts need rollback, remove:
  - `artifacts/ambitions-ui-reconstruction/polish/AMB-594-you-polish.md`
  - `artifacts/ambitions-ui-reconstruction/screenshots/amb-594-you-polish.png`

## Remaining Yellow Debt

- None.

## Required Completion Footer

Verdict: Green
Artifact paths:
- artifacts/ambitions-ui-reconstruction/polish/AMB-594-you-polish.md
- artifacts/ambitions-ui-reconstruction/screenshots/amb-594-you-polish.png
Focused tests:
- make xcode-focused-test BATCH=AMB-594 TEST=AmbitionsTests/PersonalSystemCenterDesignSystemTests - passed; Executed 5 tests, with 0 failures (0 unexpected)
Changed files:
- Native/Ambitions/Features/You/YouRootSurface.swift
- Native/AmbitionsTests/App/PersonalSystemCenterDesignSystemTests.swift
- docs/codex/concept-lock-registry.yml
- prompts/batches/AMB-594.md
- artifacts/ambitions-ui-reconstruction/polish/AMB-594-you-polish.md
- artifacts/ambitions-ui-reconstruction/screenshots/amb-594-you-polish.png
Rollback notes:
- Revert the AMB-594 commit to remove the Runtime Governance first-viewport group, restore prior You root status capsule treatment, remove the narrow AMB-594 concept-lock allowance, and remove AMB-594 focused assertions and proof artifacts.
Remaining Yellow debt:
- None
