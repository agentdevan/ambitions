# Train 2.5 Checkpoint Hygiene + Focused Test Proof Recovery

Status: Yellow
Branch: main
Base checkpoint: 8d095586156ba72bd4e960ed69c14db511af4aa9
Remote checkpoint: 8d095586156ba72bd4e960ed69c14db511af4aa9
Validation timestamp: 2026-06-18T13:44:14Z
Scope: Train 2.5 checkpoint hygiene and focused test proof recovery only. No Train 3 work, product UI rebuild, root shell rebuild, Motion/Capture migration, screenshot proof, accessibility certification, privacy proof, account/R2 proof, device proof, TestFlight proof, App Store proof, or release readiness is claimed.

## Branch / Worktree Status

- Began on `main`.
- `git status --short --branch`: `## main...origin/main`.
- Local `HEAD`: `8d095586156ba72bd4e960ed69c14db511af4aa9`.
- `origin/main`: `8d095586156ba72bd4e960ed69c14db511af4aa9`.
- Safety branch created: No. The checkout was clean and already synchronized with `origin/main`.

## Files Changed

- `docs/validation/train_2_5_checkpoint_hygiene_test_proof.md`: new checkpoint note.
- `docs/validation/train_2_enforcement_gates.md`: clarified Train 2 production change classification.
- `docs/audits/design_truth_readback.md`: regenerated commit pointer.
- `docs/audits/design_truth_refraction_audit.md`: regenerated file counts and commit pointer.
- `docs/audits/file_by_file_truth_ledger.md`: regenerated validation-doc ledger row.

No production source, tests, scripts, `.swiftpm` user data, or Xcode project source files were changed in Train 2.5.

## Hygiene Checks

- Accidental Xcode user-data status: clean at Train 2.5 baseline; no `.swiftpm/xcode/xcuserdata/devan.xcuserdatad/xcschemes/xcschememanagement.plist` change was staged or required.
- Git process cleanup: prior stuck PIDs `25002` and `25443` were absent; Git remained responsive.
- Intended Train 2.5 files: validation docs plus required regenerated audit artifacts.

## Train 2 Classification Repair

- Production runtime behavior changed: No.
- Production UI architecture changed: No.
- Production accessibility copy changed: Yes. Train 2 changed one stale Time accessibility hint in `Native/Ambitions/Features/Time/TimeScreen.swift` to `Review Time recovery boundaries before confirming any broad change.`

## Focused Test Recovery Attempts

- Existing Train 2 build-for-testing artifact used: `.codex/DerivedData/Ambitions/Build/Products/Ambitions_iphonesimulator26.5-x86_64.xctestrun`.
- Direct `test-without-building` with Train 2 simulator UDID failed before XCTest execution because simulator `81485ACD-AF10-4B92-8C03-9BB8805A4A23` was no longer available.
- `xcrun simctl list devices available` stalled and was interrupted.
- Direct `test-without-building` with named destination `platform=iOS Simulator,name=iPhone 17` repeatedly emitted destination warnings and was interrupted before XCTest execution.

## Focused Test Artifacts

- Direct UDID attempt log: `.codex/xcode-logs/DESIGN-TRUTH-REFRACTION-TRAIN-2-5/20260618T134013Z-ScreenContractRegistryTests-direct/focused-test.log`
- Direct UDID attempt result bundle: `.codex/xcode-results/DESIGN-TRUTH-REFRACTION-TRAIN-2-5/20260618T134013Z-ScreenContractRegistryTests-direct/ScreenContractRegistryTests.xcresult`
- Named-destination attempt log: `.codex/xcode-logs/DESIGN-TRUTH-REFRACTION-TRAIN-2-5/20260618T134212Z-ScreenContractRegistryTests-name-iPhone17/focused-test.log`
- Named-destination attempt result bundle: `.codex/xcode-results/DESIGN-TRUTH-REFRACTION-TRAIN-2-5/20260618T134212Z-ScreenContractRegistryTests-name-iPhone17/ScreenContractRegistryTests.xcresult`

## Focused Tests Actually Executed

None proven in Train 2.5. No focused XCTest Green is claimed.

## Focused Tests Not Run

- `AppShellNavigationTests`
- `AppShellChromeTests`
- `ScreenContractRegistryTests`
- `ShellPreviewMatrixTests`
- `StageMotionRoutingTests`
- `ShellCommandRouterTests`

The recovery attempts stopped before executed-test counts were produced.

## Validation Passed

- `python3 -m py_compile scripts/ambitions-surface-contract-lint.py scripts/ambitions-visible-copy-drift-scan.py scripts/ambitions-design-truth-refraction-audit.py`
- `git diff --check`
- `python3 scripts/ambitions-design-truth-refraction-audit.py --write`
- `python3 scripts/ambitions-design-truth-refraction-audit.py --check`
- `python3 scripts/ambitions-legacy-ia-route-lint.py`
- `python3 scripts/ambitions-surface-contract-lint.py`
- `python3 scripts/ambitions-copy-contract-lint.py --include-components`
- `python3 scripts/ambitions-visible-copy-drift-scan.py --strict`
- `python3 scripts/ambitions-vocabulary-drift-scan.py`
- `python3 scripts/ambitions-moat-drift-scan.py`
- `python3 scripts/ambitions-repo-authority-validate.py`

## Validation Failed / Yellow

- Initial `python3 scripts/ambitions-design-truth-refraction-audit.py --check` reported stale audit artifacts after the validation doc edits; `--write && --check` regenerated and settled them.
- Focused XCTest proof recovery remained Yellow. No executed-test counts were produced.
- Xcode build-for-testing was not rerun in Train 2.5 because Train 2.5 changed docs/audit artifacts only; the Train 2 build-for-testing proof remains `.codex/xcode-summaries/DESIGN-TRUTH-REFRACTION-TRAIN-2/20260618T130620Z-bft-17650-14716/build-for-testing-summary.json`.

## Checkpoint Decision

- Train 2 source commit status: already committed and pushed as `8d095586156ba72bd4e960ed69c14db511af4aa9`.
- Train 2.5 commit recommendation: Commit the validation-doc checkpoint and regenerated audit artifacts; do not claim focused XCTest Green.
- Train 3 readiness: Not ready for Green. Train 3 should remain blocked or Yellow until focused XCTest execution produces real executed-test counts, or the simulator/test-launch blocker is explicitly accepted as a Yellow exception.
