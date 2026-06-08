# AMB-578 Closure / Recovery Primitive Family

Verdict: Green

## Scope

AMB-578 promoted `closure-recovery-family` into a shared action-state primitive family for Closure and Recovery. The patch adds a design-system contract plus line-stage and line-row primitives, then routes active Closure / Recovery containers through that family in Today, shared recovery panel usage, the recovery tide strip, the closure check-in panel, the closure receipt tray, and the Habits recovery summary wrapper.

This is source, focused unit-test, and local simulator screenshot evidence for the scoped Closure / Recovery primitive family only. It is not release proof, device proof, human visual approval, performance proof, privacy/legal approval, TestFlight readiness, App Store readiness, CI proof, or full accessibility approval.

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

- Added `ClosureRecoveryPrimitiveFamilyContract.current` with primitive ID `closure-recovery-family`.
- Added `ClosureRecoveryPrimitiveRole` for closure, recovery, receipt, and no-silent-change action-state roles.
- Added `ClosureRecoveryPrimitiveStage` for shared action-state stage bands.
- Added `ClosureRecoveryPrimitiveLine` for shared closure, recovery, and receipt rows.
- Replaced the shared `ClosureCheckInPanel` AppCard wrapper with the closure stage primitive.
- Replaced `RecoveryTideStrip` rounded strip chrome with the recovery line primitive.
- Replaced `RecoveryPanel` generic rich-panel wrapping with the recovery stage primitive while preserving visual/content slots and optional actions.
- Replaced `AmbitionActionClosureTray` rounded receipt chrome with the receipt line primitive.
- Replaced Today action-closure sheet generic outcome-map, recovery-prompt, outcome-row, and receipt-preview containers with closure/recovery/receipt primitives.
- Replaced Today recovery bloom outer and option-row containers with recovery stage and line primitives.
- Replaced the Habits recovery summary outer AppCard wrapper with a recovery stage primitive while leaving the existing ritual summary content unchanged.
- Promoted `closure-recovery-family` in the primitive registry and allowed AMB-578 through the Today Start Here and design primitive concept locks.
- Classified the new primitive source and focused test in champion coverage metadata.
- Added focused AMB-578 source-structure coverage in `ClosureRecoveryPrimitiveFamilyTests`.

## Screenshot Proof

- Screenshot: `artifacts/ambitions-ui-reconstruction/screenshots/closure-recovery-family-amb-578.png`
- Pixel dimensions: 1206 x 2622
- Capture commands:
  - `xcrun simctl install 8ACCD665-4807-4102-B526-5A1AE20686A8 .codex/DerivedData/Ambitions/Build/Products/Debug-iphonesimulator/Ambitions.app`
  - `SIMCTL_CHILD_AMBITIONS_BOOTSTRAP_MODE=demo SIMCTL_CHILD_AMBITIONS_LAUNCH_URL='ambitions://tab/today?context=recovery' xcrun simctl launch --terminate-running-process 8ACCD665-4807-4102-B526-5A1AE20686A8 com.ambitions.ios --args -AmbitionsInitialSurface today -AmbitionsScreenshotMode YES`
  - `scripts/sim/simctl_screenshot.sh artifacts/ambitions-ui-reconstruction/screenshots/closure-recovery-family-amb-578.png --simulator 8ACCD665-4807-4102-B526-5A1AE20686A8 --retries 3`
  - `sips -g pixelWidth -g pixelHeight artifacts/ambitions-ui-reconstruction/screenshots/closure-recovery-family-amb-578.png`
- Visual inspection result: the screenshot shows Today in recovery context with the converted receipt/closure line-stage tray visible over the recovery route. It does not present that closure receipt as a generic rounded card.
- Proof boundary: the screenshot proves the routed recovery context and converted line-stage tray render locally. It does not prove full lower-scroll recovery bloom, every action-state row, manual VoiceOver traversal, real-device rendering, or release readiness.

## Focused Tests

- `make xcode-focused-test BATCH=AMB-578 TEST=AmbitionsTests/ClosureRecoveryPrimitiveFamilyTests` - passed after repair cycles.
- Final focused log: `.codex/xcode-logs/AMB-578/20260608T121717Z-AmbitionsTests-ClosureRecoveryPrimitiveFamilyTests-97380-25187/focused-test.log`
- Output: `Executed 3 tests, with 0 failures (0 unexpected)`
- Repair notes:
  - Repaired invalid `AmbitionVisualState.recovery` usage to the existing warning visual state while preserving semantic recovery state.
  - Reworked the Habits recovery summary patch to change only the outer wrapper and avoid broad ritual-source cleanup.

## Changed Files

- `Native/Ambitions/Features/Habits/HabitComponents.swift`
- `Native/Ambitions/Features/Today/TodayActionClosureSheet.swift`
- `Native/Ambitions/Features/Today/TodayPanels.swift`
- `Native/AmbitionsTests/App/ClosureRecoveryPrimitiveFamilyTests.swift`
- `Sources/Components/AmbitionsExtendedTactileKit.swift`
- `Sources/Components/AmbitionsV2CanonicalComponents.swift`
- `Sources/Components/ClosureRecoveryPrimitiveFamily.swift`
- `Sources/Components/RichPanelPrimitives.swift`
- `Sources/Components/ShellChromePrimitives.swift`
- `artifacts/ambitions-ui-reconstruction/action-state/AMB-578-closure-recovery-family.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/closure-recovery-family-amb-578.png`
- `docs/codex/ambitions_primitive_invention_registry.md`
- `docs/codex/concept-lock-registry.yml`
- `docs/codex/existing-code-champion-coverage.yml`

## Registry Entries

- `docs/codex/ambitions_primitive_invention_registry.md` now promotes `closure-recovery-family` for AMB-578 and records AMB-578 proof artifacts.
- `docs/codex/concept-lock-registry.yml` now allows AMB-578 for `today_start_here` and `design_primitives`.
- `docs/codex/existing-code-champion-coverage.yml` now classifies the AMB-578 primitive source and focused test.

## Validation

- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-578 --prompt docs/codex/ambitions_primitive_invention_registry.md` - passed before source edits.
- `python3 scripts/ambitions-champion-coverage-check.py` - passed before source edits; generated build reports were restored and not committed.
- `make xcode-focused-test BATCH=AMB-578 TEST=AmbitionsTests/ClosureRecoveryPrimitiveFamilyTests` - passed after repair cycles; final output `Executed 3 tests, with 0 failures (0 unexpected)`.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-578 --prompt docs/codex/ambitions_primitive_invention_registry.md --changed-from d93e14425a568fcc8a71eaa53a845c410b4547c7` - passed; report path `build/reports/parallel-implementation-guard/AMB-578-post.md`.
- `python3 scripts/ambitions-unsupported-claim-scan.py --changed-from d93e14425a568fcc8a71eaa53a845c410b4547c7` - passed.
- `bash scripts/release-claim-safety-scan.sh` - passed.
- `bash scripts/codex-forbidden-claim-scan.sh Native/Ambitions/Features/Habits/HabitComponents.swift Native/Ambitions/Features/Today/TodayActionClosureSheet.swift Native/Ambitions/Features/Today/TodayPanels.swift Native/AmbitionsTests/App/ClosureRecoveryPrimitiveFamilyTests.swift Sources/Components/AmbitionsExtendedTactileKit.swift Sources/Components/AmbitionsV2CanonicalComponents.swift Sources/Components/ClosureRecoveryPrimitiveFamily.swift Sources/Components/RichPanelPrimitives.swift Sources/Components/ShellChromePrimitives.swift docs/codex/ambitions_primitive_invention_registry.md docs/codex/concept-lock-registry.yml docs/codex/existing-code-champion-coverage.yml artifacts/ambitions-ui-reconstruction/action-state/AMB-578-closure-recovery-family.md` - passed.
- `python3 scripts/ambitions-champion-coverage-check.py` - passed; generated build reports were restored and not committed.
- `git diff --check` - passed.

## Rollback Notes

- Revert the AMB-578 commit to restore prior generic closure panels, recovery panels, rounded recovery cards, closure outcome cards, receipt preview cards, closure tray chrome, registry state, concept-lock prefix, and focused test coverage.
- If only proof artifacts need rollback, remove:
  - `artifacts/ambitions-ui-reconstruction/action-state/AMB-578-closure-recovery-family.md`
  - `artifacts/ambitions-ui-reconstruction/screenshots/closure-recovery-family-amb-578.png`

## Remaining Yellow Debt

- None for the AMB-578 Closure / Recovery primitive family scope.
- Not claimed: full lower-scroll recovery bloom screenshot, every action-state row screenshot, manual accessibility traversal, real-device rendering, performance proof, privacy/legal approval, release proof, TestFlight/App Store readiness, or CI proof.

## Required Completion Footer

Verdict: Green.
Artifact paths:
- artifacts/ambitions-ui-reconstruction/action-state/AMB-578-closure-recovery-family.md
- artifacts/ambitions-ui-reconstruction/screenshots/closure-recovery-family-amb-578.png
Focused tests:
- make xcode-focused-test BATCH=AMB-578 TEST=AmbitionsTests/ClosureRecoveryPrimitiveFamilyTests - passed; Executed 3 tests, with 0 failures (0 unexpected)
Changed files:
- Native/Ambitions/Features/Habits/HabitComponents.swift
- Native/Ambitions/Features/Today/TodayActionClosureSheet.swift
- Native/Ambitions/Features/Today/TodayPanels.swift
- Native/AmbitionsTests/App/ClosureRecoveryPrimitiveFamilyTests.swift
- Sources/Components/AmbitionsExtendedTactileKit.swift
- Sources/Components/AmbitionsV2CanonicalComponents.swift
- Sources/Components/ClosureRecoveryPrimitiveFamily.swift
- Sources/Components/RichPanelPrimitives.swift
- Sources/Components/ShellChromePrimitives.swift
- artifacts/ambitions-ui-reconstruction/action-state/AMB-578-closure-recovery-family.md
- artifacts/ambitions-ui-reconstruction/screenshots/closure-recovery-family-amb-578.png
- docs/codex/ambitions_primitive_invention_registry.md
- docs/codex/concept-lock-registry.yml
- docs/codex/existing-code-champion-coverage.yml
Rollback notes:
- Revert the AMB-578 commit to restore prior generic closure panels, recovery panels, rounded recovery cards, closure outcome cards, receipt preview cards, closure tray chrome, registry state, concept-lock prefix, and focused test coverage.
Remaining Yellow debt:
- None for the AMB-578 Closure / Recovery primitive family scope.
