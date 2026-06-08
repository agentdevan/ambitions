# AMB-589 Cross-Surface Chrome / Dock / Crown Polish

Verdict: Green

AMB-589 polished the active shared shell crown so all five canonical root tabs use the same lightweight context-crown treatment: a small status dot, uppercase destination title, compact posture/lens text, and the existing quiet Capture fallback. Drill-down/back routes keep the stronger title/back header material. The native five-tab dock remains unchanged and consistent.

Runtime behavior changed only in shared shell presentation. No runtime data, persistence, Capture routing, top-level IA, backend, telemetry, or intelligence path changed.

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
- `artifacts/ambitions-ui-reconstruction/reports/AOR-CHROME-00-report.md`
- `artifacts/ambitions-ui-reconstruction/reports/AOR-CHROME-01-report.md`
- `artifacts/ambitions-ui-reconstruction/reports/AOR-CHROME-02-report.md`

## Changed Files

- `Native/Ambitions/App/AppShellView.swift`
  - Adds a top-level `shell.header.context-crown` mark for root shell tabs.
  - Uses the existing shell posture/status model and shell theme colors.
  - Makes top-level root tabs share the same visible crown structure.
  - Keeps stronger title/back material only for drill-down routes.
- `Native/AmbitionsUITests/AmbitionsUITests.swift`
  - Extends the canonical five-tab shell UI test to assert the context crown exists.
- `prompts/batches/AMB-589.md`
  - Installs the AMB-589 runner prompt with required runner metadata.
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-589-shell-today.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-589-shell-goals.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-589-shell-time.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-589-shell-motion.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-589-shell-you.png`
- `artifacts/ambitions-ui-reconstruction/polish/AMB-589-cross-surface-chrome-dock-crown-polish.md`

## Source Patch Summary

Before AMB-589:

- Today root suppressed the shared shell title block.
- Goals, Time, Motion, and You roots showed title/subtitle text in the same rail.
- The root crown therefore had different visible structures across the five canonical tabs.

After AMB-589:

- Every top-level tab shows the same compact context-crown mark.
- The mark is text/line-based and does not introduce a rounded card, panel, tile, or boxed first-viewport shell.
- The Capture fallback remains the only shared root utility button.
- The native dock remains the existing five-tab SwiftUI `TabView` with no Capture tab, sixth tab, badge count, score, streak, or urgency treatment.
- SourceRecord, Receipt, ReplayTrace, and You / What Ambitions knows inspection boundaries remain untouched.

## Screenshot Artifact Paths

Current AMB-589 screenshot artifacts were exported from:

- `.codex/xcode-results/AMB-589/20260608T170119Z-AmbitionsUITests-AmbitionsUITests-testAFRI005ShellScreenshotBaselineCapturesCano-7163-24455/focused-test.xcresult`

Export command:

```bash
xcrun xcresulttool export attachments --path .codex/xcode-results/AMB-589/20260608T170119Z-AmbitionsUITests-AmbitionsUITests-testAFRI005ShellScreenshotBaselineCapturesCano-7163-24455/focused-test.xcresult --output-path .codex/tmp/amb589-xcresult-attachments
```

Final artifact paths:

- `artifacts/ambitions-ui-reconstruction/screenshots/amb-589-shell-today.png` - 1170x2532
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-589-shell-goals.png` - 1170x2532
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-589-shell-time.png` - 1170x2532
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-589-shell-motion.png` - 1170x2532
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-589-shell-you.png` - 1170x2532

Visual inspection boundary:

- Codex spot-checked the exported artifacts for obvious crown/capture overlap and generic shell-card regression.
- This is not human visual approval, release screenshot approval, accessibility certification, or device proof.

## Focused Tests

| Command | Status | Executed tests | Summary |
|---|---:|---:|---|
| `make xcode-focused-test BATCH=AMB-589 TEST=AmbitionsTests/AppShellChromeTests` | passed | 11 | `.codex/xcode-summaries/AMB-589/20260608T164931Z-AmbitionsTests-AppShellChromeTests-4374-24994/focused-test-summary.json` |
| `make xcode-focused-test BATCH=AMB-589 TEST=AmbitionsUITests/AmbitionsUITests/testPreviewBootstrapExposesCanonicalFiveTabShellAndSecondarySurfaces` | passed | 1 | `.codex/xcode-summaries/AMB-589/20260608T165305Z-AmbitionsUITests-AmbitionsUITests-testPreviewBootstrapExposesCanonicalFiveTabShe-5318-26793/focused-test-summary.json` |
| `make xcode-focused-test BATCH=AMB-589 TEST=AmbitionsUITests/AmbitionsUITests/testAFRI005ShellScreenshotBaselineCapturesCanonicalTabs` | passed | 1 | `.codex/xcode-summaries/AMB-589/20260608T170119Z-AmbitionsUITests-AmbitionsUITests-testAFRI005ShellScreenshotBaselineCapturesCano-7163-24455/focused-test-summary.json` |

Focused-test log paths:

- `.codex/xcode-logs/AMB-589/20260608T164931Z-AmbitionsTests-AppShellChromeTests-4374-24994/focused-test.log`
- `.codex/xcode-logs/AMB-589/20260608T165305Z-AmbitionsUITests-AmbitionsUITests-testPreviewBootstrapExposesCanonicalFiveTabShe-5318-26793/focused-test.log`
- `.codex/xcode-logs/AMB-589/20260608T170119Z-AmbitionsUITests-AmbitionsUITests-testAFRI005ShellScreenshotBaselineCapturesCano-7163-24455/focused-test.log`

The wrapper ran build-for-testing before focused tests because Swift source/test files changed.

## Guard And Validation

- `git pull --ff-only` - already up to date before AMB-589 source edits.
- `python3 scripts/ambitions-champion-coverage-check.py --batch AMB-589` - Green; report `build/reports/intelligence-consolidation/champion-coverage-check.md`.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-589 --prompt prompts/batches/AMB-589.md --batch-type source-changing` - Green; report `build/reports/parallel-implementation-guard/AMB-589-pre.md`.
- `git diff --check` - passed before focused Xcode validation.
- `make xcode-focused-test BATCH=AMB-589 TEST=AmbitionsTests/AppShellChromeTests` - passed; 11 executed tests after one compile repair cycle.
- `make xcode-focused-test BATCH=AMB-589 TEST=AmbitionsUITests/AmbitionsUITests/testPreviewBootstrapExposesCanonicalFiveTabShellAndSecondarySurfaces` - passed; 1 executed test.
- `make xcode-focused-test BATCH=AMB-589 TEST=AmbitionsUITests/AmbitionsUITests/testAFRI005ShellScreenshotBaselineCapturesCanonicalTabs` - passed; 1 executed test.
- `xcrun xcresulttool export attachments --path .codex/xcode-results/AMB-589/20260608T170119Z-AmbitionsUITests-AmbitionsUITests-testAFRI005ShellScreenshotBaselineCapturesCano-7163-24455/focused-test.xcresult --output-path .codex/tmp/amb589-xcresult-attachments` - exported five screenshot attachments.
- `sips -g pixelWidth -g pixelHeight artifacts/ambitions-ui-reconstruction/screenshots/amb-589-shell-*.png` - all five artifacts are 1170x2532.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-589 --prompt prompts/batches/AMB-589.md --changed-from 2c6c48bdfcbde13ae4288ed7d159293f407dd96b --batch-type source-changing` - Green; report `build/reports/parallel-implementation-guard/AMB-589-post.md`.
- `python3 scripts/ambitions-unsupported-claim-scan.py artifacts/ambitions-ui-reconstruction/polish/AMB-589-cross-surface-chrome-dock-crown-polish.md prompts/batches/AMB-589.md` - Green.
- `bash scripts/codex-forbidden-claim-scan.sh artifacts/ambitions-ui-reconstruction/polish/AMB-589-cross-surface-chrome-dock-crown-polish.md prompts/batches/AMB-589.md` - no blocking hits; context-only backend-denial hits.
- `git diff --check` - passed after source/report/screenshot changes.
- `bash scripts/release-claim-safety-scan.sh` - Green after staging the AMB-589 source/test/prompt/report/screenshot files.

## Proof Boundaries

- This proves the scoped shell crown source patch, focused shell tests, current simulator screenshot attachment extraction, and stable screenshot artifact paths for the five root tabs.
- It does not claim broad no-card completion across all app source, AMB-607 completion, full suite success, release build success, human visual approval, public accessibility conformance, manual VoiceOver traversal, Dynamic Type screenshot review, Reduce Motion walkthrough, Increase Contrast measured review, performance readiness, real-device behavior, privacy/legal approval, TestFlight readiness, App Store readiness, CI proof, or release readiness.

## Rollback

- Revert the AMB-589 commit to restore the prior top-level shell crown behavior and remove the AMB-589 prompt/report/screenshots.
- Or remove the `rootContextCrown` changes in `Native/Ambitions/App/AppShellView.swift`, remove the `shell.header.context-crown` UI-test assertion, and delete:
  - `prompts/batches/AMB-589.md`
  - `artifacts/ambitions-ui-reconstruction/screenshots/amb-589-shell-today.png`
  - `artifacts/ambitions-ui-reconstruction/screenshots/amb-589-shell-goals.png`
  - `artifacts/ambitions-ui-reconstruction/screenshots/amb-589-shell-time.png`
  - `artifacts/ambitions-ui-reconstruction/screenshots/amb-589-shell-motion.png`
  - `artifacts/ambitions-ui-reconstruction/screenshots/amb-589-shell-you.png`
  - `artifacts/ambitions-ui-reconstruction/polish/AMB-589-cross-surface-chrome-dock-crown-polish.md`

## Required Completion Footer

Verdict: Green
Artifact paths:
- artifacts/ambitions-ui-reconstruction/polish/AMB-589-cross-surface-chrome-dock-crown-polish.md
- artifacts/ambitions-ui-reconstruction/screenshots/amb-589-shell-today.png
- artifacts/ambitions-ui-reconstruction/screenshots/amb-589-shell-goals.png
- artifacts/ambitions-ui-reconstruction/screenshots/amb-589-shell-time.png
- artifacts/ambitions-ui-reconstruction/screenshots/amb-589-shell-motion.png
- artifacts/ambitions-ui-reconstruction/screenshots/amb-589-shell-you.png
Focused tests:
- `make xcode-focused-test BATCH=AMB-589 TEST=AmbitionsTests/AppShellChromeTests` - passed; 11 executed tests.
- `make xcode-focused-test BATCH=AMB-589 TEST=AmbitionsUITests/AmbitionsUITests/testPreviewBootstrapExposesCanonicalFiveTabShellAndSecondarySurfaces` - passed; 1 executed test.
- `make xcode-focused-test BATCH=AMB-589 TEST=AmbitionsUITests/AmbitionsUITests/testAFRI005ShellScreenshotBaselineCapturesCanonicalTabs` - passed; 1 executed test.
Changed files:
- Native/Ambitions/App/AppShellView.swift
- Native/AmbitionsUITests/AmbitionsUITests.swift
- prompts/batches/AMB-589.md
- artifacts/ambitions-ui-reconstruction/screenshots/amb-589-shell-today.png
- artifacts/ambitions-ui-reconstruction/screenshots/amb-589-shell-goals.png
- artifacts/ambitions-ui-reconstruction/screenshots/amb-589-shell-time.png
- artifacts/ambitions-ui-reconstruction/screenshots/amb-589-shell-motion.png
- artifacts/ambitions-ui-reconstruction/screenshots/amb-589-shell-you.png
- artifacts/ambitions-ui-reconstruction/polish/AMB-589-cross-surface-chrome-dock-crown-polish.md
Rollback notes:
- Revert the AMB-589 commit, or remove the listed source/test/prompt/report/screenshot files and rebuild from the pre-AMB-589 base.
Remaining Yellow debt:
- None for the AMB-589 cross-surface chrome/dock/crown scope.
