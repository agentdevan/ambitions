# AMB-1151 through AMB-1154 Maturity Closeout

Date: 2026-06-21
Base SHA before implementation: `f09eca8b7a0dcec79968a895efe529a77e97d295`
Working policy: direct `main`, scoped source and validation changes only

## Scope

- AMB-1152: Today reconstruction proof refreshed against current source.
- AMB-1153: Closure outcome proof repaired so `Waiting` is a first-class visible closure option.
- AMB-1154: Goals Yellow debt re-audited with bounded layout repair and current screenshot proof.
- AMB-1151: Final maturity ledger for this proof group.

## Source Changes

- `Native/Ambitions/Core/Domain/ClosureOutcome.swift`
  - Moved `Waiting` from advanced-only closure options into default closure outcomes.
- `Native/Ambitions/DesignSystem/ProductObjects/TodayDayRailPanels+02-AmbitionsDayRailView+04-upNextRow.swift`
  - Replaced stale `Manual planning still works` copy with `Manual shaping still works`.
- `Native/Ambitions/DesignSystem/ProductObjects/TodayDayRailPanels+02-AmbitionsDayRailView+03-mappedRowNode.swift`
  - Replaced no-step empty action copy `Close the loop` with `Record outcome`.
- `Native/Ambitions/DesignSystem/ProductObjects/ConstellationAtlasView*.swift`
  - Added Dynamic Type awareness to the Goals Constellation Atlas object.
  - Stacked the atlas object at larger content sizes.
  - Switched large-text life-area and relationship grids to two columns.
  - Added content inset away from decorative rails in trust lanes and expanded Orbital Lens.
  - Removed secondary trace labels from the large-text relationship grid to prevent clipping.
- Tests updated for default closure outcome order, split Goals source fixtures, AMB-962 runtime allowance, and Goals layout contract coverage.

## Validation Evidence

### AMB-1152 Today

- Command: `scripts/ambitions-run-ui-screenshot-matrix.sh --batch TRAIN_05_TODAY_A11Y_PROOF --destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' --timeout 20m --kill-after 60s`
  - Status: passed
  - Result bundle: `.codex/xcode-results/TRAIN_05_TODAY_A11Y_PROOF/20260621T144447Z-AMB962.xcresult`
  - Summary: `.codex/xcode-summaries/TRAIN_05_TODAY_A11Y_PROOF/20260621T144447Z-AMB962/extract/summary.json`
  - Screenshots visually reviewed:
    - `amb-962-default`
    - `amb-962-source-unavailable`
    - `amb-962-active-recommended-step`
    - `amb-962-large-dynamic-type`
    - `amb-962-receipt-visible`
    - `amb-962-reduce-motion-static-equivalent`
    - `amb-962-no-step-paths`
  - Visual conclusion: Today proof is acceptable for the covered screenshot matrix. Large Dynamic Type and Reduce Motion matrix states were exercised by the automated UI test. Manual VoiceOver, Increase Contrast, and Reduce Transparency were not manually claimed.

### AMB-1153 Closure

- Command: `scripts/ambitions-xcode-test-focused.sh --batch AMB_1153_CLOSURE_OUTCOME_UNIT --test AmbitionsTests/CoreDomainCanonicalOwnershipTests/testClosureOutcomeOwnsDefaultAndAdvancedOptions --timeout 15m --kill-after 60s`
  - Status: passed
  - Result bundle: `.codex/xcode-results/AMB_1153_CLOSURE_OUTCOME_UNIT/20260621T142137Z-AmbitionsTests-CoreDomainCanonicalOwnershipTests-testClosureOutcomeOwnsDefaultAn-91374-11217/focused-test.xcresult`
- Command: `scripts/ambitions-xcode-test-focused.sh --batch AMB_1153_CLOSURE_SHEET_UNIT --test AmbitionsTests/TodayViewModelTests/testF05ActionClosureSheetSupportsStillCountsWithReceiptPreview --timeout 15m --kill-after 60s`
  - Status: passed
  - Result bundle: `.codex/xcode-results/AMB_1153_CLOSURE_SHEET_UNIT/20260621T142410Z-AmbitionsTests-TodayViewModelTests-testF05ActionClosureSheetSupportsStillCountsW-92251-20401/focused-test.xcresult`
  - Screenshot corroboration: AMB-962 `receipt-visible` state shows `Done`, `Still counts`, `Move it`, `Waiting`, `Blocked`, and `Not needed` in the default closure grid.

### AMB-1154 Goals

- Command: `scripts/ambitions-xcode-test-focused.sh --batch TRAIN_08_GOALS_LAYOUT_REPAIR_UNIT --test AmbitionsTests/GoalsObjectStagePrimitiveTests/testAMB596GoalsFirstViewportTrustDepthUsesVisibleNonTruncatingSummary --timeout 15m --kill-after 60s`
  - Status: passed
  - Result bundle: `.codex/xcode-results/TRAIN_08_GOALS_LAYOUT_REPAIR_UNIT/20260621T152104Z-AmbitionsTests-GoalsObjectStagePrimitiveTests-testAMB596GoalsFirstViewportTrustD-11544-16612/focused-test.xcresult`
- Command: `scripts/ambitions-xcode-test-focused.sh --batch TRAIN_08_GOALS_REAUDIT_UNIT --test AmbitionsTests/GoalsOverviewAtlasTests --timeout 15m --kill-after 60s`
  - Status: passed, 17 tests
  - Result bundle: `.codex/xcode-results/TRAIN_08_GOALS_REAUDIT_UNIT/20260621T152803Z-AmbitionsTests-GoalsOverviewAtlasTests-13668-8649/focused-test.xcresult`
- Command: `scripts/ambitions-xcode-test-focused.sh --batch TRAIN_08_GOALS_REAUDIT_SCREENSHOTS --test AmbitionsUITests/AmbitionsUITests/testAMB963GoalsReconstructionScreenshotMatrix --timeout 20m --kill-after 60s`
  - Status: passed
  - Result bundle: `.codex/xcode-results/TRAIN_08_GOALS_REAUDIT_SCREENSHOTS/20260621T152310Z-AmbitionsUITests-AmbitionsUITests-testAMB963GoalsReconstructionScreenshotMatrix-12215-1862/focused-test.xcresult`
  - Screenshots visually reviewed:
    - `.codex/xcode-summaries/TRAIN_08_GOALS_REAUDIT_SCREENSHOTS/20260621T152310Z-AmbitionsUITests-AmbitionsUITests-testAMB963GoalsReconstructionScreenshotMatrix-12215-1862/extract/screenshots/amb-963-goals-default_0_6D7E6400-8419-47FC-90D6-13FE2C939A1E.png`
    - `.codex/xcode-summaries/TRAIN_08_GOALS_REAUDIT_SCREENSHOTS/20260621T152310Z-AmbitionsUITests-AmbitionsUITests-testAMB963GoalsReconstructionScreenshotMatrix-12215-1862/extract/screenshots/amb-963-goals-selected-life-area_0_D8013E85-B1E2-45E1-A1FB-121B81A40DF8.png`
    - `.codex/xcode-summaries/TRAIN_08_GOALS_REAUDIT_SCREENSHOTS/20260621T152310Z-AmbitionsUITests-AmbitionsUITests-testAMB963GoalsReconstructionScreenshotMatrix-12215-1862/extract/screenshots/amb-963-goals-proof-source-visible_0_41117BFE-4AEE-4A6B-B2B7-4A2CC43F3FE5.png`
    - `.codex/xcode-summaries/TRAIN_08_GOALS_REAUDIT_SCREENSHOTS/20260621T152310Z-AmbitionsUITests-AmbitionsUITests-testAMB963GoalsReconstructionScreenshotMatrix-12215-1862/extract/screenshots/amb-963-goals-large-dynamic-type_0_1AE54B21-D204-4DD8-8620-F7E38B36147A.png`
  - Visual conclusion: current Goals screenshots are acceptable for the covered matrix. Default and selected states keep the dock readable and trust lanes inset from rails. Proof-source state keeps source/proof/why copy readable. Large Dynamic Type state uses two-column grids and avoids clipped relationship labels.

## Repository Gates

- `git diff --check`
  - Status: passed
- `python3 scripts/ambitions-quality-gate.py --max-per-gate 20`
  - Status: GREEN
  - Output summary: `production_swift_files=1147`, `changed_paths=10`, `GREEN all strict quality gates passed`
- `python3 scripts/ambitions-architecture-inventory.py --json`
  - Status: GREEN
  - Output summary: `green=true`, `blocking_entries=0`, `implemented=224`
- `find Native/Ambitions -path '*Features*' -type f -name '*.swift' | sort`
  - Status: no production Swift files under `Native/Ambitions/**/Features`
- `scripts/release-claim-safety-scan.sh`
  - Status: GREEN, no proof-sensitive release claims found
- `scripts/no-unsupported-ai-claim-scan.sh`
  - Status: YELLOW advisory scan complete
  - Treatment: advisory only. This closeout makes no unsupported hosted-AI, release, App Store, or privacy-completeness claims.

## Architecture Tree Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched:
  - `Core/Domain`
  - `DesignSystem/ProductObjects`
  - `Surfaces/Goals` indirectly through existing UI test coverage only
  - `Projection/SurfaceLenses` tests only, for split source fixture reading
  - `Quality`/UI test harness through `Native/AmbitionsUITests`
- Files moved or created:
  - Created `docs/validation/amb_1151_1154_maturity_closeout.md`.
  - No source files moved.
- Old/non-canonical paths removed:
  - None.
- Compatibility shims left behind:
  - None.
- Yellow architecture debt:
  - Internal `MissionControl*` Goals type names remain as non-user-facing implementation names. AMB-1154 proof confirms top-level Goals first-screen copy does not expose `Mission Control`, `Direction Atlas`, KPI, score, rank, or dashboard language. A broader internal naming migration was not required for this bounded repair and was not claimed complete.
- No equivalent-folder/path interpretation used:
  - Confirmed. No new `Features/` implementation was introduced.

## Final Verdict

Green for this bounded AMB-1151 through AMB-1154 implementation slice, with one explicit non-blocking advisory: the unsupported-AI scan remains Yellow/advisory and no unsupported AI or release-readiness claim is made.
