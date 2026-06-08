# AMB-579 Quiet Reflow Primitive Family

Verdict: Green

## Scope

AMB-579 promoted `quiet-reflow-family` into a shared action-state primitive family for preview-before-commit reflow decisions and receipt previews. The patch adds a design-system contract plus line-stage, line-row, and before/after preview primitives, then routes active Time and Today replacement/reflow containers through that family.

This is source, focused unit-test, and local simulator screenshot evidence for the scoped Quiet Reflow primitive family only. It is not release proof, device proof, human visual approval, performance proof, privacy/legal approval, TestFlight readiness, App Store readiness, CI proof, or full accessibility approval.

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

- Added `QuietReflowPrimitiveFamilyContract.current` with primitive ID `quiet-reflow-family`.
- Added `QuietReflowPrimitiveRole` for preview, option, impact, receipt, source, no-silent-change, and manual-fallback action-state roles.
- Added `QuietReflowPrimitiveStage` for shared reflow line-stage surfaces.
- Added `QuietReflowPrimitiveLine` for source, control, impact, manual fallback, and receipt rows.
- Added `QuietReflowBeforeAfterPrimitive` for preview-before-commit current/proposed-state comparisons.
- Replaced `TimeReflowDecisionCard` generic `AppCard` and rounded option/preview containers with Quiet Reflow primitives.
- Replaced the Time root `reflowTrustSeam` local preview treatment with Quiet Reflow primitives while preserving before/after, source, manual fallback, reason, control, receipt, and action controls.
- Replaced Today step replacement original recommendation, alternatives, impact, and receipt preview rounded containers with Quiet Reflow primitives.
- Added a screenshot-only `-AmbitionsTimeFocus quiet-reflow` hook that moves the existing Time reflow trust seam into first-viewport proof position for this screenshot route only.
- Promoted `quiet-reflow-family` in the primitive registry.
- Allowed AMB-579 through the Today Start Here, Time LifeShape, and design primitive concept locks.
- Classified the new primitive source and focused test in champion coverage metadata.
- Added focused AMB-579 source-structure coverage in `QuietReflowPrimitiveFamilyTests`.

## Screenshot Proof

- Screenshot: `artifacts/ambitions-ui-reconstruction/screenshots/quiet-reflow-family-amb-579.png`
- Pixel dimensions: 1206 x 2622
- Capture commands:
  - `mcp__xcodebuildmcp.install_app_sim` with app path `.codex/DerivedData/Ambitions/Build/Products/Debug-iphonesimulator/Ambitions.app`
  - `mcp__xcodebuildmcp.launch_app_sim` with `AMBITIONS_BOOTSTRAP_MODE=demo` and launch args `-AmbitionsInitialSurface time -AmbitionsScreenshotMode YES -AmbitionsTimeRenderState reflow -AmbitionsTimeReflowAction receipt -AmbitionsTimeFocus quiet-reflow`
  - `scripts/sim/simctl_screenshot.sh artifacts/ambitions-ui-reconstruction/screenshots/quiet-reflow-family-amb-579.png --simulator 8ACCD665-4807-4102-B526-5A1AE20686A8 --retries 3`
  - `sips -g pixelWidth -g pixelHeight artifacts/ambitions-ui-reconstruction/screenshots/quiet-reflow-family-amb-579.png`
- Visual inspection result: the screenshot shows Time with the Quiet Reflow line-stage in first-viewport proof position, including Reflow preview, before/after labels, shape-change copy, and receipt-preview copy.
- Proof boundary: the screenshot proves the focused local simulator Time reflow route renders the Quiet Reflow stage. It does not prove every Today replacement row screenshot, manual VoiceOver traversal, real-device rendering, or release readiness.

## Focused Tests

- `make xcode-focused-test BATCH=AMB-579 TEST=AmbitionsTests/QuietReflowPrimitiveFamilyTests` - passed after repair cycles.
- Final focused log: `.codex/xcode-logs/AMB-579/20260608T125711Z-AmbitionsTests-QuietReflowPrimitiveFamilyTests-12726-9466/focused-test.log`
- Output: `Executed 4 tests, with 0 failures (0 unexpected)`
- Repair notes:
  - Repaired the Today replacement option symbol by adding a view-local `replacementOptionSystemImage(for:)` mapper instead of broadening the domain model.
  - Repaired screenshot proof after the first simulator capture was blocked by an iOS open-confirmation prompt.
  - Added the screenshot-only `-AmbitionsTimeFocus quiet-reflow` hook after the unfocused Time first viewport only showed the top of the reflow stage.

## Changed Files

- `Native/Ambitions/Features/Time/TimeLifeShapeField.swift`
- `Native/Ambitions/Features/Time/TimeReflowDecisionCard.swift`
- `Native/Ambitions/Features/Today/TodayStepReplacementSheet.swift`
- `Native/AmbitionsTests/App/QuietReflowPrimitiveFamilyTests.swift`
- `Sources/Components/QuietReflowPrimitiveFamily.swift`
- `artifacts/ambitions-ui-reconstruction/action-state/AMB-579-quiet-reflow-family.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/quiet-reflow-family-amb-579.png`
- `docs/codex/ambitions_primitive_invention_registry.md`
- `docs/codex/concept-lock-registry.yml`
- `docs/codex/existing-code-champion-coverage.yml`

## Registry Entries

- `docs/codex/ambitions_primitive_invention_registry.md` now promotes `quiet-reflow-family` for AMB-579 and records AMB-579 proof artifacts.
- `docs/codex/concept-lock-registry.yml` now allows AMB-579 for `today_start_here`, `time_plan_lifeshape`, and `design_primitives`.
- `docs/codex/existing-code-champion-coverage.yml` now classifies the AMB-579 primitive source and focused test.

## Validation

- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-579 --prompt docs/codex/ambitions_primitive_invention_registry.md` - passed before source edits; report path `build/reports/parallel-implementation-guard/AMB-579-pre.md`.
- `python3 scripts/ambitions-champion-coverage-check.py` - passed before source edits; generated build reports were restored and not committed.
- `make xcode-focused-test BATCH=AMB-579 TEST=AmbitionsTests/QuietReflowPrimitiveFamilyTests` - passed after repair cycles; final output `Executed 4 tests, with 0 failures (0 unexpected)`.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-579 --prompt docs/codex/ambitions_primitive_invention_registry.md --changed-from d591704bf4a310e9d17a349b231c13edaf369697` - passed; report path `build/reports/parallel-implementation-guard/AMB-579-post.md`.
- `python3 scripts/ambitions-unsupported-claim-scan.py --changed-from d591704bf4a310e9d17a349b231c13edaf369697` - passed.
- `bash scripts/release-claim-safety-scan.sh` - passed.
- `bash scripts/codex-forbidden-claim-scan.sh Native/Ambitions/Features/Time/TimeLifeShapeField.swift Native/Ambitions/Features/Time/TimeReflowDecisionCard.swift Native/Ambitions/Features/Today/TodayStepReplacementSheet.swift Native/AmbitionsTests/App/QuietReflowPrimitiveFamilyTests.swift Sources/Components/QuietReflowPrimitiveFamily.swift docs/codex/ambitions_primitive_invention_registry.md docs/codex/concept-lock-registry.yml docs/codex/existing-code-champion-coverage.yml artifacts/ambitions-ui-reconstruction/action-state/AMB-579-quiet-reflow-family.md` - passed.
- `python3 scripts/ambitions-champion-coverage-check.py` - passed; generated build reports were restored and not committed.
- `git diff --check` - passed.

## Rollback Notes

- Revert the AMB-579 commit to restore prior Time reflow decision panel treatment, Time root reflow seam treatment, Today replacement local containers, registry state, concept-lock prefixes, champion coverage metadata, screenshot hook, and focused test coverage.
- If only proof artifacts need rollback, remove:
  - `artifacts/ambitions-ui-reconstruction/action-state/AMB-579-quiet-reflow-family.md`
  - `artifacts/ambitions-ui-reconstruction/screenshots/quiet-reflow-family-amb-579.png`

## Remaining Yellow Debt

- None for the AMB-579 Quiet Reflow primitive family scope.
- Not claimed: every Today replacement row screenshot, manual accessibility traversal, real-device rendering, performance proof, privacy/legal approval, release proof, TestFlight/App Store readiness, App Store readiness, or CI proof.

## Required Completion Footer

Verdict: Green.
Artifact paths:
- artifacts/ambitions-ui-reconstruction/action-state/AMB-579-quiet-reflow-family.md
- artifacts/ambitions-ui-reconstruction/screenshots/quiet-reflow-family-amb-579.png
Focused tests:
- make xcode-focused-test BATCH=AMB-579 TEST=AmbitionsTests/QuietReflowPrimitiveFamilyTests - passed; Executed 4 tests, with 0 failures (0 unexpected)
Changed files:
- Native/Ambitions/Features/Time/TimeLifeShapeField.swift
- Native/Ambitions/Features/Time/TimeReflowDecisionCard.swift
- Native/Ambitions/Features/Today/TodayStepReplacementSheet.swift
- Native/AmbitionsTests/App/QuietReflowPrimitiveFamilyTests.swift
- Sources/Components/QuietReflowPrimitiveFamily.swift
- artifacts/ambitions-ui-reconstruction/action-state/AMB-579-quiet-reflow-family.md
- artifacts/ambitions-ui-reconstruction/screenshots/quiet-reflow-family-amb-579.png
- docs/codex/ambitions_primitive_invention_registry.md
- docs/codex/concept-lock-registry.yml
- docs/codex/existing-code-champion-coverage.yml
Rollback notes:
- Revert the AMB-579 commit to restore prior Time reflow decision panel treatment, Time root reflow seam treatment, Today replacement local containers, registry state, concept-lock prefixes, champion coverage metadata, screenshot hook, and focused test coverage.
Remaining Yellow debt:
- None for the AMB-579 Quiet Reflow primitive family scope.
