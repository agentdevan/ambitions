# Train 2 Enforcement Gates

Status: Yellow
Branch: main
Base checkpoint: 4cf734223e4441d9cb7efceffbed71dbd68e2972
Validation timestamp: 2026-06-18T13:25:00Z
Scope: Train 2 enforcement gates only. No product UI rebuild, Motion/Capture migration, screenshot proof, accessibility certification, privacy proof, account/R2 proof, device proof, TestFlight proof, App Store proof, or release readiness is claimed.

## Changes Validated

- `scripts/ambitions-surface-contract-lint.py` now enforces four root surfaces: Today, Goals, Time, You.
- Capture remains guarded as global composer/overlay compatibility, not a root surface.
- Motion remains guarded as Stage/Motion behavior compatibility, not a root surface.
- `ScreenContractID.capture.canonicalTopLevelTitle` is no longer a top-level title.
- Screen contract and shell matrix tests now align with current primary objects: Reality Meridian, Constellation Atlas, LifeShape Field, User System Profile.
- `scripts/ambitions-visible-copy-drift-scan.py --strict` is bounded by default and reports file counts.
- One visible Time hint was changed from Plan wording to Time wording.
- Train 0/1 generated audit artifacts were regenerated and settled.

## Commands Run

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
- `scripts/ambitions-xcode-build-for-testing.sh --batch DESIGN-TRUTH-REFRACTION-TRAIN-2`
- `scripts/ambitions-xcode-validate.sh --batch DESIGN-TRUTH-REFRACTION-TRAIN-2 --lane focused-test --test AmbitionsTests/AppShellNavigationTests,AmbitionsTests/AppShellChromeTests,AmbitionsTests/ScreenContractRegistryTests,AmbitionsTests/ShellPreviewMatrixTests,AmbitionsTests/StageMotionRoutingTests,AmbitionsTests/ShellCommandRouterTests --json`
- XcodeBuildMCP `test_sim` with the same six `-only-testing` selectors.
- `xcodebuild ... test-without-building -only-testing AmbitionsTests/ScreenContractRegistryTests ...`

## Pass / Fail Results

- Python compile: passed.
- `git diff --check`: passed.
- Audit generator settling cycle: passed after a second `--write && --check` cycle.
- Legacy IA route lint: passed.
- Surface contract lint: passed.
- Copy contract lint: passed.
- Bounded visible-copy drift scan: passed; 154 files scanned, 0 findings.
- Vocabulary drift scan: passed.
- Moat drift scan: passed.
- Repo authority validation: passed.
- Build-for-testing: passed.
- Focused XCTest execution: Yellow. The wrapper reached `test-without-building` for `AmbitionsTests/AppShellNavigationTests` but did not reach test execution before it was stopped; XcodeBuildMCP `test_sim` timed out after 120s; direct single-suite fallback for `AmbitionsTests/ScreenContractRegistryTests` also stalled in package resolution and was stopped.

## Xcode Artifacts

- Build summary: `.codex/xcode-summaries/DESIGN-TRUTH-REFRACTION-TRAIN-2/20260618T130620Z-bft-17650-14716/build-for-testing-summary.json`
- Build log: `.codex/xcode-logs/DESIGN-TRUTH-REFRACTION-TRAIN-2/20260618T130620Z-bft-17650-14716/build-for-testing.log`
- Build result bundle: `.codex/xcode-results/DESIGN-TRUTH-REFRACTION-TRAIN-2/20260618T130620Z-bft-17650-14716/build-for-testing.xcresult`
- Focused wrapper preflight build summary: `.codex/xcode-summaries/DESIGN-TRUTH-REFRACTION-TRAIN-2/20260618T131253Z-bft-21050-17580/build-for-testing-summary.json`
- Focused wrapper preflight build log: `.codex/xcode-logs/DESIGN-TRUTH-REFRACTION-TRAIN-2/20260618T131253Z-bft-21050-17580/build-for-testing.log`
- Focused wrapper preflight build result bundle: `.codex/xcode-results/DESIGN-TRUTH-REFRACTION-TRAIN-2/20260618T131253Z-bft-21050-17580/build-for-testing.xcresult`
- Focused test partial log: `.codex/xcode-logs/DESIGN-TRUTH-REFRACTION-TRAIN-2/20260618T131409Z-AmbitionsTests-AppShellNavigationTests-21816-6890/focused-test.log`
- Focused test partial result bundle path: `.codex/xcode-results/DESIGN-TRUTH-REFRACTION-TRAIN-2/20260618T131409Z-AmbitionsTests-AppShellNavigationTests-21816-6890/focused-test.xcresult`
- Direct fallback partial result bundle path: `.codex/xcode-results/DESIGN-TRUTH-REFRACTION-TRAIN-2/direct-screen-contract-registry.xcresult`

## Focused Tests Actually Executed

None proven in this pass. Do not claim focused XCTest Green for Train 2.

## Focused Tests Not Run

- `AppShellNavigationTests`
- `AppShellChromeTests`
- `ScreenContractRegistryTests`
- `ShellPreviewMatrixTests`
- `StageMotionRoutingTests`
- `ShellCommandRouterTests`

The wrapper and direct fallback both stopped before executed-test counts were produced.

## Product Behavior Changed

Only one user-facing copy string changed: the Time recovery maturity accessibility hint now says `Review Time recovery boundaries before confirming any broad change.`

No root UI rebuild, Motion destination migration, Capture composer rebuild, screenshot matrix, device run, accessibility certification, privacy/account/R2 validation, TestFlight validation, App Store validation, or release validation was performed.

## Known Yellow / Red Risks

- Yellow: focused XCTest execution did not complete due to repeated package-resolution/test startup behavior.
- Yellow: no screenshot, accessibility, device, privacy, account/R2, release, or App Store proof was produced or claimed.
- Yellow: Xcode validation touched `.swiftpm/xcode/xcuserdata/devan.xcuserdatad/xcschemes/xcschememanagement.plist`; this is local Xcode scheme-management user data and is not part of the Train 2 source scope.
- Not Red: script gates and build-for-testing passed, and no source evidence shows Train 2 reintroduced Capture or Motion as root surfaces.

## Next Proof Required

- Re-run the six focused XCTest suites until executed-test counts are produced.
- If `test-without-building` continues to stall after package resolution, investigate simulator/package resolution state before further Train 3 work.
