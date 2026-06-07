# AOR-YOU-01 You Runtime Reconstruction

## Status

Green for AMB-552 source reconstruction and focused local validation.

Formal accessibility conformance, physical-device behavior, performance, privacy/legal approval, TestFlight readiness, App Store readiness, and release readiness are not claimed.

## Issue

Ambitions issue: AMB-552

## Scope

Reconstruct `You` toward a settings-oriented User System Profile structure and extend the locked `you_profile_personal_runtime` owner-review path without creating a parallel implementation.

Canonical root sections:

- Planning Setup
- Account & Preferences
- History & Trust
- Support / System

Additional AMB-552 repair completed in this run:

- Kept Local Context Controls reachable from the You root.
- Ordered the Local Context Controls sheet so Life Context and Source Atlas proof surfaces are discoverable.
- Replaced the Life Context disclosure/action layout that was masking fact action controls in the accessibility tree.
- Stabilized You UI test navigation so offscreen root rows are tapped only after they are actually hittable.

## Files Changed

- `Native/Ambitions/Features/You/YouRootSurface.swift`
- `Native/Ambitions/Features/You/YouScreen.swift`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`
- `docs/audits/intelligence-consolidation/CHAMPION_MERGE_QUEUE.md`
- `docs/codex/concept-lock-registry.yml`
- `artifacts/ambitions-ui-reconstruction/reports/AOR-YOU-01-report.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/you-root-reconstructed-after-final.png`
- `prompts/batches/AMB-552.md`

## Active Truth Files Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`

## Validation

Build/test proof:

- `make xcode-focused-test BATCH=AMB-552 TEST=AmbitionsUITests/AmbitionsUITests/testYouLifeContextHeroCTAsExpandCatchUpAndReviewRoutes`
  - Result: passed, 1 test executed
  - Summary: `.codex/xcode-summaries/AMB-552/20260607T185512Z-AmbitionsUITests-AmbitionsUITests-testYouLifeContextHeroCTAsExpandCatchUpAndRevi-66245-7718/focused-test-summary.json`
- `make xcode-focused-test BATCH=AMB-552 TEST=AmbitionsUITests/AmbitionsUITests/testYouLifeContextLedgerInspectionShowsRuntimeFactorsAndReplayReceipts`
  - Result: passed, 1 test executed
  - Summary: `.codex/xcode-summaries/AMB-552/20260607T185906Z-AmbitionsUITests-AmbitionsUITests-testYouLifeContextLedgerInspectionShowsRuntime-67477-18371/focused-test-summary.json`
- `make xcode-focused-test BATCH=AMB-552 TEST=AmbitionsUITests/AmbitionsUITests/testYouSourceAtlasGoalKnowledgeSurfaceShowsSourceReviewAndReplayReceipts`
  - Result: passed, 1 test executed
  - Summary: `.codex/xcode-summaries/AMB-552/20260607T190233Z-AmbitionsUITests-AmbitionsUITests-testYouSourceAtlasGoalKnowledgeSurfaceShowsSou-68576-21871/focused-test-summary.json`
- `make xcode-focused-test BATCH=AMB-552 TEST=AmbitionsUITests/AmbitionsUITests/testPreviewBootstrapExposesCanonicalFiveTabShellAndSecondarySurfaces`
  - Result: passed, 1 test executed
  - Summary: `.codex/xcode-summaries/AMB-552/20260607T190706Z-AmbitionsUITests-AmbitionsUITests-testPreviewBootstrapExposesCanonicalFiveTabShe-69617-29006/focused-test-summary.json`
- `make xcode-focused-test BATCH=AMB-552 TEST=AmbitionsUITests/AmbitionsUITests/testYouTrustSurfaceShowsConservativeExternalStatusLabels`
  - Result: passed, 1 test executed
  - Summary: `.codex/xcode-summaries/AMB-552/20260607T191049Z-AmbitionsUITests-AmbitionsUITests-testYouTrustSurfaceShowsConservativeExternalSt-70473-11298/focused-test-summary.json`
- `make xcode-focused-test BATCH=AMB-552 TEST=AmbitionsUITests/AmbitionsUITests/testYouPersonalDefaultsRemainVisibleBeneathAppearanceStudio`
  - Result: passed, 1 test executed
  - Summary: `.codex/xcode-summaries/AMB-552/20260607T191412Z-AmbitionsUITests-AmbitionsUITests-testYouPersonalDefaultsRemainVisibleBeneathApp-71304-22299/focused-test-summary.json`

Build-for-testing proof:

- Focused test wrappers triggered build-for-testing preflights because Swift source/test files were dirty.
- Latest recorded build-for-testing summary: `.codex/xcode-summaries/AMB-552/20260607T191305Z-bft-71052-24831/build-for-testing-summary.json`

Guard/proof commands:

- `python3 scripts/ambitions-champion-coverage-check.py`
  - Result: GREEN
  - Report: `build/reports/intelligence-consolidation/champion-coverage-check.md`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-552 --prompt prompts/batches/AMB-552.md --batch-type source-changing`
  - Result: GREEN
  - Report: `build/reports/parallel-implementation-guard/AMB-552-pre.md`
- `git diff --check`
  - Result: passed, no whitespace errors
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-552 --prompt prompts/batches/AMB-552.md --changed-from fd3acc95bc25933306e937052311c38f0dc767e8 --batch-type source-changing`
  - Result: GREEN
  - Report: `build/reports/parallel-implementation-guard/AMB-552-post.md`
  - Locked concept touched: `you_profile_personal_runtime`
  - Allowed merge batch: true

Screenshot and visual packet:

- Refreshed screenshot:
  - `SIMCTL_CHILD_AMBITIONS_BOOTSTRAP_MODE=demo xcrun simctl launch --terminate-running-process 81485ACD-AF10-4B92-8C03-9BB8805A4A23 com.ambitions.ios --args -AmbitionsInitialSurface you -AmbitionsScreenshotMode YES`
  - `xcrun simctl io 81485ACD-AF10-4B92-8C03-9BB8805A4A23 screenshot artifacts/ambitions-ui-reconstruction/screenshots/you-root-reconstructed-after-final.png`
  - Result: `1170 x 2532` PNG
- `python3 tools/openai/visual_critique/critique_visual_packet.py --rubric tools/openai/visual_critique/rubrics/ambitions_visual_canon.json --dry-run artifacts/ambitions-ui-reconstruction/screenshots/you-root-reconstructed-after-final.png`
  - Result: PASS, status green

## Validation Not Run

- `testDemoCanNavigateAcrossAllTabs` was not rerun; prior selector lookup in this branch did not discover that test. Current coverage uses `testPreviewBootstrapExposesCanonicalFiveTabShellAndSecondarySurfaces` for canonical five-tab shell proof.
- No physical-device run.
- No formal accessibility audit.
- No performance profiling.
- No archive/export/signing/TestFlight/App Store validation.
- No privacy/legal review.

## Proof Boundaries

- Verified: AMB-552 source reconstruction compiles through focused wrapper build-for-testing preflights, the six listed focused UI tests pass locally, the post parallel-implementation guard is green, and the local visual packet structure accepts the refreshed You root screenshot.
- Not verified: formal accessibility conformance, physical device, performance, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, or CI.
- This report does not claim that Private Life Runtime behavior is complete; it verifies the scoped You inspection/settings reconstruction and local UI routes covered by the listed tests.

## Risks / Yellow Items

- Formal accessibility and device proof remain owner/manual follow-up outside this AMB-552 local validation scope.
- Source Atlas is reachable after Life Context in the current sheet order, but the UI test needed repeated scroll attempts because Life Context is large. Future You detail work may choose a more compact local-context hierarchy.

## Rollback

- Revert `Native/Ambitions/Features/You/YouRootSurface.swift`.
- Revert `Native/Ambitions/Features/You/YouScreen.swift`.
- Revert `Native/AmbitionsUITests/AmbitionsUITests.swift`.
- Revert `docs/audits/intelligence-consolidation/CHAMPION_MERGE_QUEUE.md`.
- Revert `docs/codex/concept-lock-registry.yml`.
- Remove `prompts/batches/AMB-552.md`.
- Remove `artifacts/ambitions-ui-reconstruction/reports/AOR-YOU-01-report.md`.
- Remove `artifacts/ambitions-ui-reconstruction/screenshots/you-root-reconstructed-after-final.png`.

## Next Eligible Issue

- `AMB-553` remains the next You owner-review extension point in `AMB-CHAMPION-MERGE-YOU-01`; execution still needs concrete AMB-553 issue/prompt authority before source changes.
