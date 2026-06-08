# AOR-YOU-03 / AMB-554 Final You QA

Status: Green for scoped AMB-554 execution

AMB-554 performed final QA for the You root and required drill-down proof states. The packet adds current screenshot artifacts, focused launch-state UI coverage, You-local Dynamic Type layout repair, and accessibility/visual contract scaffolding needed for the local proof gates. This is not formal accessibility compliance, release readiness, device proof, privacy/legal approval, TestFlight proof, App Store proof, CI proof, or performance proof.

## Active Truth Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`

## What Changed

- Installed the runner prompt at `prompts/batches/AMB-554.md` and repaired its prompt-only guard clarity with `SourceRecord`, `Receipt`, `ReplayTrace`, and `You / What Ambitions knows` terms.
- Added You screenshot-mode detail routing for the required final-QA sheets.
- Added a focused UI test covering screenshot-mode launch states for Trust & Automation, Personal Runtime, and Receipts & History.
- Repaired You row layout where status pills squeezed detail text and where accessibility Dynamic Type compressed root rows.
- Added generated frontend accessibility/visual contract scaffolding under `frontend/visual-encyclopedia/` so local accessibility contract gates have active, explicit non-claim source.
- Added `docs/accessibility/AMB_ACCESSIBILITY_MOAT_MATRIX.md` as a proof/gap matrix with explicit non-claims.
- Corrected stale ADR IA wording from old Capture-tab canon to current `Today / Goals / Time / Motion / You` plus global `Capture`.

## Screenshot Evidence

All screenshots were recaptured from the rebuilt simulator app at `1170x2532`.

| Screenshot | Purpose |
|---|---|
| `artifacts/ambitions-ui-reconstruction/screenshots/you-root-default-after-final.png` | You root default state |
| `artifacts/ambitions-ui-reconstruction/screenshots/you-trust-automation-after-final.png` | Trust & Automation sheet |
| `artifacts/ambitions-ui-reconstruction/screenshots/you-personal-runtime-after-final.png` | Personal Runtime sheet |
| `artifacts/ambitions-ui-reconstruction/screenshots/you-receipts-history-after-final.png` | Receipts & History sheet |
| `artifacts/ambitions-ui-reconstruction/screenshots/you-large-dynamic-type-after-final.png` | Accessibility Dynamic Type root state |
| `artifacts/ambitions-ui-reconstruction/screenshots/you-reduce-motion-after-final.png` | Reduce Motion root state |
| `artifacts/ambitions-ui-reconstruction/screenshots/you-increase-contrast-after-final.png` | Increase Contrast root state |

Simulator settings were reset after capture:

- content size: `medium`
- increase contrast: `disabled`
- Reduce Motion: `0`

## Validation

Verified:

- `python3 scripts/ambitions-champion-coverage-check.py` -> Green; report `build/reports/intelligence-consolidation/champion-coverage-check.md`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-554 --prompt prompts/batches/AMB-554.md --batch-type source-changing` -> Green; report `build/reports/parallel-implementation-guard/AMB-554-pre.md`
- `make xcode-build-for-testing BATCH=AMB-554` -> passed; summary `.codex/xcode-summaries/AMB-554/20260608T015622Z-bft-67292-19762/build-for-testing-summary.json`
- Direct focused UI suite with five selected tests -> passed, 5 tests, 0 failures; log `.codex/xcode-logs/AMB-554/direct-final-qa/focused-tests.log`; result bundle `.codex/xcode-results/AMB-554/direct-final-qa/test.xcresult`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-554 --prompt prompts/batches/AMB-554.md --changed-from 68a7a600dd671e33fd61b276a197be405199228a --batch-type source-changing` -> Green; report `build/reports/parallel-implementation-guard/AMB-554-post.md`
- `sips -g pixelWidth -g pixelHeight <seven screenshots>` -> all `1170x2532`
- `python3 tools/openai/visual_critique/critique_visual_packet.py --rubric tools/openai/visual_critique/rubrics/ambitions_visual_canon.json --dry-run <seven screenshots>` -> Green local packet structure, screenshot count 7
- `python3 scripts/ambitions_validate_accessibility_gates.py` -> Green
- `python3 scripts/ambitions-accessibility-contract-check.py` -> Green
- `bash scripts/release-claim-safety-scan.sh` -> Green
- `git diff --check` -> clean

Focused UI tests in the direct suite:

- `AmbitionsUITests/AmbitionsUITests/testPreviewBootstrapExposesCanonicalFiveTabShellAndSecondarySurfaces`
- `AmbitionsUITests/AmbitionsUITests/testYouTrustSurfaceShowsConservativeExternalStatusLabels`
- `AmbitionsUITests/AmbitionsUITests/testYouLifeContextLedgerInspectionShowsRuntimeFactorsAndReplayReceipts`
- `AmbitionsUITests/AmbitionsUITests/testYouPersonalRuntimeAndLocalDataControlsShowHonestStatusLabels`
- `AmbitionsUITests/AmbitionsUITests/testYouScreenshotProofLaunchStatesOpenRequiredDetailSheets`

Accepted Yellow / advisory:

- `bash scripts/accessibility-ui-batch-readiness-scan.sh` -> advisory Yellow scan complete.
- `bash scripts/sig-accessibility-evidence-check.sh` -> advisory Yellow until SIG15 records final accessibility/motion closeout.

Runner note:

- The Ambitions runner was invoked for AMB-554 after prompt install and pre-guard repair, but the nested Codex runner phase stopped with a usage-limit/tooling Red before a source patch or validation. Manual continuation stayed within the repaired Green pre-guard and AMB-554 prompt scope, with the usage-limit fallback recorded in Linear.

Wrapper substitution note:

- A prior focused-test wrapper invocation produced stale-selector evidence for one new screenshot-state test. Final proof uses a direct `xcodebuild -only-testing:` suite that executed all five selected tests and passed.

## Proof Boundaries

Not verified:

- Manual VoiceOver traversal
- Physical-device accessibility proof
- Tap-target measurement across all You paths
- Full accessibility-size screenshot sweep
- Performance or Instruments proof
- Privacy/legal approval
- Release, TestFlight, App Store, hosted CI, or public accessibility compliance readiness

The native tab bar remains translucent by shell policy. AMB-554 did not change global tab-bar opacity or shell-wide underlap behavior.

## Rollback

Path-limited rollback:

```bash
git restore -- Native/Ambitions/Features/You/YouRootSurface.swift Native/Ambitions/Features/You/YouScreen.swift Native/AmbitionsUITests/AmbitionsUITests.swift docs/architecture/decisions/ADR-004-product-object-architecture.md
rm -f prompts/batches/AMB-554.md
rm -f docs/accessibility/AMB_ACCESSIBILITY_MOAT_MATRIX.md
rm -rf frontend/visual-encyclopedia
rm -f artifacts/ambitions-ui-reconstruction/screenshots/you-root-default-after-final.png
rm -f artifacts/ambitions-ui-reconstruction/screenshots/you-trust-automation-after-final.png
rm -f artifacts/ambitions-ui-reconstruction/screenshots/you-personal-runtime-after-final.png
rm -f artifacts/ambitions-ui-reconstruction/screenshots/you-receipts-history-after-final.png
rm -f artifacts/ambitions-ui-reconstruction/screenshots/you-large-dynamic-type-after-final.png
rm -f artifacts/ambitions-ui-reconstruction/screenshots/you-reduce-motion-after-final.png
rm -f artifacts/ambitions-ui-reconstruction/screenshots/you-increase-contrast-after-final.png
rm -f artifacts/ambitions-ui-reconstruction/reports/AOR-YOU-03-report.md
```

## Next

Next eligible issue: `AMB-555`.
