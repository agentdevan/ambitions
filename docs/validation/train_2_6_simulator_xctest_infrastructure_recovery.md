# Train 2.6 Simulator + Focused XCTest Infrastructure Recovery

Status: Green
Branch: main
Baseline commit: 8dc324107cd476d5b6598626c09f18920ea3763f
Validation timestamp: 2026-06-18T14:28:44Z
Scope: Simulator and focused XCTest infrastructure recovery only. No Train 3 work, product UI rebuild, shell/navigation change, Motion/Capture migration, screenshot proof, accessibility certification, privacy proof, account/R2 proof, device proof, TestFlight proof, App Store proof, or release readiness is claimed.

## Branch / Worktree Status

- Work remained on `main`.
- Baseline `HEAD`: `8dc324107cd476d5b6598626c09f18920ea3763f`.
- Baseline `origin/main`: `8dc324107cd476d5b6598626c09f18920ea3763f`.
- Safety branch created: No.
- Branch switched: No.
- Force push: No.

## Simulator Health Findings

- Available iOS runtimes: iOS 26.3 and iOS 26.5.
- `iPhone 17` exists under both iOS 26.3 and iOS 26.5.
- Stable selected fallback: `iPhone 17` on iOS 26.5.
- Local selected UDID for this machine: `169566BC-88D9-416F-9F93-0013CBA519EB`.
- The previous Train 2 focused destination `81485ACD-AF10-4B92-8C03-9BB8805A4A23` is `iPhone 17e` on iOS 26.3, not the intended `iPhone 17` destination.
- `scripts/ambitions-xcode-sim-health.sh` previously matched simulator names by substring, so `iPhone 17` could select `iPhone 17e`.
- No destructive simulator erase was performed.
- CoreSimulator restart, Xcode restart, and VM restart were not required after selector repair.

## Destination Stabilization

- Source-controlled wrapper fix: exact simulator name matching in `scripts/ambitions-xcode-sim-health.sh`.
- The selector now keeps the last exact matching simulator, which selects the newer available runtime when duplicate simulator names exist.
- Recommended source-controlled destination contract: set `AMBITIONS_SIM_NAME='iPhone 17'` when an explicit destination is needed.
- Do not source-control local simulator UDIDs. The local UDID above is validation evidence only.

## Files Changed

- `scripts/ambitions-xcode-sim-health.sh`
- `docs/validation/train_2_6_simulator_xctest_infrastructure_recovery.md`

No production source, product UI, tests, shell visuals, root navigation, architecture, `.swiftpm` user data, or generated Xcode project source files were changed.

## Product Behavior Changed

No.

## Validation Commands / Results

- `git status --short --branch`: clean baseline on `main`, synchronized with `origin/main`.
- `git diff --check`: passed.
- `bash -n scripts/ambitions-xcode-sim-health.sh`: passed.
- `AMBITIONS_SIM_NAME='iPhone 17' scripts/ambitions-xcode-sim-health.sh --json`: selected `169566BC-88D9-416F-9F93-0013CBA519EB`.
- `scripts/ambitions-xcode-sim-health.sh --json --repair`: booted selected simulator.
- `python3 scripts/ambitions-design-truth-refraction-audit.py --check`: initially reported stale audit artifacts after this validation doc was added; `--write && --check` regenerated and settled them.
- `python3 scripts/ambitions-legacy-ia-route-lint.py`: passed.
- `python3 scripts/ambitions-surface-contract-lint.py`: passed.
- `python3 scripts/ambitions-copy-contract-lint.py --include-components`: passed.
- `python3 scripts/ambitions-visible-copy-drift-scan.py --strict`: passed; 154 files scanned, 0 findings.
- `python3 scripts/ambitions-vocabulary-drift-scan.py`: passed.
- `python3 scripts/ambitions-moat-drift-scan.py`: passed.
- `python3 scripts/ambitions-repo-authority-validate.py`: passed.
- `scripts/ambitions-xcode-build-for-testing.sh --batch DESIGN-TRUTH-REFRACTION-TRAIN-2-6`: passed.
- `scripts/ambitions-xcode-validate.sh --batch DESIGN-TRUTH-REFRACTION-TRAIN-2-6 --lane focused-test --test AmbitionsTests/ScreenContractRegistryTests --json`: passed; 12 executed tests.
- `scripts/ambitions-xcode-validate.sh --batch DESIGN-TRUTH-REFRACTION-TRAIN-2-6 --lane focused-test --test AmbitionsTests/RepoTruthAuditLedgerTests --json`: passed; 3 executed tests.
- `scripts/ambitions-xcode-validate.sh --batch DESIGN-TRUTH-REFRACTION-TRAIN-2-6 --lane focused-test --test AmbitionsTests/StageMotionRoutingTests --json`: passed; 4 executed tests.

## Focused Tests Executed

- `ScreenContractRegistryTests`: 12 executed, 0 failures.
- `RepoTruthAuditLedgerTests`: 3 executed, 0 failures.
- `StageMotionRoutingTests`: 4 executed, 0 failures.

Total focused XCTest proof recovered: 19 executed tests, 0 failures.

## Focused Tests Not Executed

None required for Train 2.6.

## Xcode Artifacts

- Build summary: `.codex/xcode-summaries/DESIGN-TRUTH-REFRACTION-TRAIN-2-6/20260618T142120Z-bft-4149-5121/build-for-testing-summary.json`
- Build log: `.codex/xcode-logs/DESIGN-TRUTH-REFRACTION-TRAIN-2-6/20260618T142120Z-bft-4149-5121/build-for-testing.log`
- Build result bundle: `.codex/xcode-results/DESIGN-TRUTH-REFRACTION-TRAIN-2-6/20260618T142120Z-bft-4149-5121/build-for-testing.xcresult`
- `ScreenContractRegistryTests` log: `.codex/xcode-logs/DESIGN-TRUTH-REFRACTION-TRAIN-2-6/20260618T142522Z-AmbitionsTests-ScreenContractRegistryTests-5465-24802/focused-test.log`
- `ScreenContractRegistryTests` result bundle: `.codex/xcode-results/DESIGN-TRUTH-REFRACTION-TRAIN-2-6/20260618T142522Z-AmbitionsTests-ScreenContractRegistryTests-5465-24802/focused-test.xcresult`
- `RepoTruthAuditLedgerTests` log: `.codex/xcode-logs/DESIGN-TRUTH-REFRACTION-TRAIN-2-6/20260618T142714Z-AmbitionsTests-RepoTruthAuditLedgerTests-6219-25015/focused-test.log`
- `RepoTruthAuditLedgerTests` result bundle: `.codex/xcode-results/DESIGN-TRUTH-REFRACTION-TRAIN-2-6/20260618T142714Z-AmbitionsTests-RepoTruthAuditLedgerTests-6219-25015/focused-test.xcresult`
- `StageMotionRoutingTests` log: `.codex/xcode-logs/DESIGN-TRUTH-REFRACTION-TRAIN-2-6/20260618T142802Z-AmbitionsTests-StageMotionRoutingTests-6601-23759/focused-test.log`
- `StageMotionRoutingTests` result bundle: `.codex/xcode-results/DESIGN-TRUTH-REFRACTION-TRAIN-2-6/20260618T142802Z-AmbitionsTests-StageMotionRoutingTests-6601-23759/focused-test.xcresult`

## Temporary Fallback Contract

Not needed for Train 2.6 because focused XCTest execution recovered with executed-test counts.

If XCTest regresses again, no train may close Green without executed XCTest counts or an explicitly approved replacement validation path. A Yellow fallback would require, at minimum, build-for-testing, Python compile for changed scripts, `git diff --check`, design-truth audit `--check`, legacy IA lint, surface contract lint, copy contract lint, bounded visible-copy drift scan, vocabulary drift scan, moat drift scan, repo authority validation, and screenshot/accessibility/mutation proof once UI changes begin.

## Remaining Blockers

- None for the Train 2.6 infrastructure scope.
- Product, screenshot, accessibility, privacy, account/R2, device, TestFlight, App Store, and release readiness remain unclaimed.

## Train 3 Readiness

Ready for the focused XCTest infrastructure prerequisite. Train 3 was not started in this pass.
