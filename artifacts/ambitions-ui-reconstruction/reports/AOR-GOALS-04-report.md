# AOR-GOALS-04 Goals Motion, Accessibility, Proof Screenshots Report

## Status

Yellow/Green: scoped Goals screenshot proof is complete and current validation is Green. Manual VoiceOver traversal, device testing, performance, privacy/legal, TestFlight, App Store, CI, and release readiness are not claimed.

## Files Changed

- `prompts/batches/AMB-550.md`
- `Native/Ambitions/Features/Goals/GoalsFeatureModels.swift`
- `Native/Ambitions/Features/Goals/GoalsScreen.swift`
- `Native/Ambitions/Features/Goals/GoalComponents.swift`
- `Native/AmbitionsTests/Goals/GoalsOverviewBoardTests.swift`
- `artifacts/ambitions-ui-reconstruction/screenshots/goals-default-atlas-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/goals-selected-life-area-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/goals-orbital-lens-expanded-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/goals-proof-available-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/goals-large-dynamic-type-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/goals-reduce-motion-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/goals-increase-contrast-after-final.png`
- `artifacts/ambitions-ui-reconstruction/reports/AOR-GOALS-04-report.md`

## Why The Change Was Needed

AMB-550 required current proof that the Goals Direction Atlas and Orbital Lens remain object-owned and meaningful across default, selected Life Area, proof, Dynamic Type, Reduce Motion, and Increase Contrast variants. AMB-549 added the Orbital Lens, but deterministic screenshot launch states were still missing.

This patch adds a launch-only `GoalsScreenshotProofState` for screenshot proof. Default runtime remains unchanged. The proof state can expand or prioritize the Orbital Lens, bring the selected Life Area chip into view, and highlight proof while keeping the Lens attached to existing Atlas state.

## Active Truth Files Inspected

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

## Behavior Verified

- Direction Atlas remains the primary Goals object in default and variant screenshots.
- Orbital Lens remains sourced from `GoalsOverview.orbitalLens` and does not become a separate Goals root.
- Selected Life Area screenshot mode reorders the selected chip to the front only for deterministic proof.
- Orbital Lens expanded mode renders the Lens before the Atlas object only for deterministic screenshot proof.
- Reduce Motion toggles the Lens without animation and keeps the static selected area, active thread, recommended step, Today feed, proof, source, and why rows visible.
- Increase Contrast strengthens Atlas and Lens boundaries through `colorSchemeContrast`.
- Nonvisual source support includes composed accessibility labels/values for the Atlas, Life Area chips, and Orbital Lens rows.

## Screenshot Evidence

All screenshots were captured from booted simulator `iPhone 17e` (`81485ACD-AF10-4B92-8C03-9BB8805A4A23`) after installing `.codex/DerivedData/Ambitions/Build/Products/Debug-iphonesimulator/Ambitions.app`.

| Screenshot | Launch / setting | Result |
|---|---|---|
| `goals-default-atlas-after-final.png` | Demo bootstrap, `-AmbitionsInitialSurface goals`, `-AmbitionsGoalsRenderState default` | Direction Atlas is primary; equal-weight areas, Source, and Proof are visible. |
| `goals-selected-life-area-after-final.png` | Demo bootstrap, `-AmbitionsGoalsRenderState selected-life-area` | Selected `Career` Life Area is first and visibly attached to the Atlas state. |
| `goals-orbital-lens-expanded-after-final.png` | Demo bootstrap, `-AmbitionsGoalsRenderState orbital-lens-expanded` | Expanded Lens shows selected area, active thread, recommended step, Today feed, proof, source, and why rows. |
| `goals-proof-available-after-final.png` | Demo bootstrap, `-AmbitionsGoalsRenderState proof-available` | Atlas proof lane shows proof available and remains attached to the Atlas object. |
| `goals-large-dynamic-type-after-final.png` | Demo bootstrap, `-AmbitionsGoalsRenderState selected-life-area`, simulator `content_size accessibility-large`, `UICTContentSizeCategoryAccessibilityL` | Equal-weight areas remain visible and same-sized under large Dynamic Type. |
| `goals-reduce-motion-after-final.png` | Demo bootstrap, simulator `com.apple.Accessibility ReduceMotionEnabled = YES`, expanded Lens state | Meaning is static and does not depend on animation. |
| `goals-increase-contrast-after-final.png` | Demo bootstrap, `xcrun simctl ui ... increase_contrast enabled` | Atlas and chip boundaries are stronger under increased contrast. |

## Validation Performed / Not Performed

Performed:

- `AUTO_BRANCH=0 ALLOW_DIRTY=1 scripts/ambitions-codex-train.sh AMB-550 prompts/batches/AMB-550.md`
  - Runner reached Green pre-guard, then nested Codex planning stopped on an external usage limit before source edits.
- `make xcode-focused-test BATCH=AMB-550 TEST=AmbitionsTests/GoalsOverviewAtlasTests`
  - Green after repair: `.codex/xcode-summaries/AMB-550/20260607T053520Z-AmbitionsTests-GoalsOverviewAtlasTests-54377-10380/focused-test-summary.json`
- `make xcode-build-for-testing BATCH=AMB-550`
  - Green after repair: `.codex/xcode-summaries/AMB-550/20260607T053909Z-bft-55888-14441/build-for-testing-summary.json`
- `make xcode-focused-test BATCH=AMB-550 TEST=AmbitionsUITests/AmbitionsUITests/testDemoGoalsAtlasLoadsCoreModules`
  - Green after repair: `.codex/xcode-summaries/AMB-550/20260607T054137Z-AmbitionsUITests-AmbitionsUITests-testDemoGoalsAtlasLoadsCoreModules-56972-17090/focused-test-summary.json`
- `python3 tools/openai/visual_critique/critique_visual_packet.py --rubric tools/openai/visual_critique/rubrics/ambitions_visual_canon.json --dry-run <7 screenshots>`
  - Green: 7 screenshots present, no missing screenshots.
- `git diff --check`
  - Green.

Not performed:

- Manual VoiceOver traversal.
- Real-device testing.
- Performance measurement.
- Privacy/legal review.
- Signed archive, TestFlight, App Store, CI, or release readiness validation.

## EFC Flagship Proof Overlay

EFC applicability: invoked as screenshot/accessibility proof for a user-facing Goals surface. The current proof is screenshot, source, unit, and UI-test evidence only. It is not a release, device, performance, privacy/legal, or full accessibility approval packet.

## Non-Claims

- No new top-level destination, tab, backend, telemetry, runtime dependency, cloud AI, hosted service, or release path was introduced.
- No screenshot baseline was silently bulk-updated.
- No app behavior completion beyond AMB-550 scoped Goals proof is claimed.
- Source-level accessibility labels and screenshots are not a claim of full accessibility compliance.

## Risks / Yellow Items

- Manual VoiceOver traversal remains Yellow and owned by a later accessibility QA pass.
- Dynamic Type proof uses `accessibility-large`; more extreme accessibility sizes may require a separate layout pass if they need first-viewport parity.
- The proof-available screenshot proves the Atlas proof lane in the first viewport; the deeper highlighted Lens proof row is source-backed and visible when the Lens is expanded.

## Rollback Path

- Revert the AMB-550 commit to remove launch-only Goals screenshot proof state, selected-chip screenshot reordering, contrast/reduce-motion refinements, screenshots, and this report.
- If only artifacts need rollback, remove the seven `goals-*-after-final.png` screenshots and this report without changing runtime source.

## Next Eligible Batch

Next eligible issue in the requested sequence: AMB-551.
