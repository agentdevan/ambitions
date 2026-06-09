# AMB-558 Screenshot Board

## Verdict

Yellow.

This artifact assembles the AMB-558 screenshot board after simulator recovery for AMB-604. It reflects the required eleven-path set regenerated on 2026-06-08 and tracks against commit `efdb5550c`.

## Required Screenshot Board

| Required path | Status | Metadata |
|---|---|---|
| `artifacts/ambitions-ui-reconstruction/screenshots/today-default-after-final.png` | Present | size `269246`, mtime `2026-06-08T23:48:53-0400` |
| `artifacts/ambitions-ui-reconstruction/screenshots/goals-default-after-final.png` | Present | size `269090`, mtime `2026-06-08T23:49:20-0400` |
| `artifacts/ambitions-ui-reconstruction/screenshots/time-default-after-final.png` | Present | size `269091`, mtime `2026-06-08T23:49:56-0400` |
| `artifacts/ambitions-ui-reconstruction/screenshots/motion-default-after-final.png` | Present | size `269248`, mtime `2026-06-08T23:50:20-0400` |
| `artifacts/ambitions-ui-reconstruction/screenshots/you-default-after-final.png` | Present | size `269440`, mtime `2026-06-08T23:50:54-0400` |
| `artifacts/ambitions-ui-reconstruction/screenshots/capture-activated-after-final.png` | Present | size `268188`, mtime `2026-06-08T23:51:12-0400` |
| `artifacts/ambitions-ui-reconstruction/screenshots/today-large-dynamic-type-after-final.png` | Present | size `309683`, mtime `2026-06-08T23:51:38-0400` |
| `artifacts/ambitions-ui-reconstruction/screenshots/time-reduce-motion-after-final.png` | Present | size `367913`, mtime `2026-06-08T23:52:03-0400` |
| `artifacts/ambitions-ui-reconstruction/screenshots/motion-empty-after-final.png` | Present | size `359868`, mtime `2026-06-08T23:52:22-0400` |
| `artifacts/ambitions-ui-reconstruction/screenshots/you-increase-contrast-after-final.png` | Present | size `579908`, mtime `2026-06-08T23:52:46-0400` |
| `artifacts/ambitions-ui-reconstruction/screenshots/capture-keyboard-after-final.png` | Present | size `360365`, mtime `2026-06-08T23:53:04-0400` |

## Screenshot Runtime Metadata

- Recorded source commit: `efdb5550c`
- Required path inventory command:
  - `for p in artifacts/ambitions-ui-reconstruction/screenshots/today-default-after-final.png artifacts/ambitions-ui-reconstruction/screenshots/goals-default-after-final.png artifacts/ambitions-ui-reconstruction/screenshots/time-default-after-final.png artifacts/ambitions-ui-reconstruction/screenshots/motion-default-after-final.png artifacts/ambitions-ui-reconstruction/screenshots/you-default-after-final.png artifacts/ambitions-ui-reconstruction/screenshots/capture-activated-after-final.png artifacts/ambitions-ui-reconstruction/screenshots/today-large-dynamic-type-after-final.png artifacts/ambitions-ui-reconstruction/screenshots/time-reduce-motion-after-final.png artifacts/ambitions-ui-reconstruction/screenshots/motion-empty-after-final.png artifacts/ambitions-ui-reconstruction/screenshots/you-increase-contrast-after-final.png artifacts/ambitions-ui-reconstruction/screenshots/capture-keyboard-after-final.png; do if [ -s \"$p\" ]; then stat -f 'PRESENT %N size=%z mtime=%Sm' -t '%Y-%m-%dT%H:%M:%S%z' \"$p\"; else echo \"MISSING $p\"; fi; done`
- Capture loop command used (simulator UUID `8ACCD665-4807-4102-B526-5A1AE20686A8`, bootstrap mode `demo`):
  - `SIMCTL_CHILD_AMBITIONS_BOOTSTRAP_MODE=demo xcrun simctl launch --terminate-running-process ... com.ambitions.ios --args ...`
  - `scripts/sim/simctl_screenshot.sh <output-path> --simulator 8ACCD665-4807-4102-B526-5A1AE20686A8 --retries 3`
- Accessibility variants were captured via `simctl ui` / `defaults` commands toggling:
  - `xcrun simctl ui 8ACCD665-4807-4102-B526-5A1AE20686A8 content_size accessibility-extra-extra-extra-large`
  - `xcrun simctl spawn 8ACCD665-4807-4102-B526-5A1AE20686A8 defaults write com.apple.Accessibility ReduceMotionEnabled -bool YES/NO`
  - `xcrun simctl ui 8ACCD665-4807-4102-B526-5A1AE20686A8 increase_contrast enabled/disabled`

## Focused Tests

Not available - no focused test target exists for the exact AMB-558 eleven-path final screenshot board. Existing screenshot-related UI coverage, including `testAFRI005ShellScreenshotBaselineCapturesCanonicalTabs`, does not cover the required final/accessibility/Capture screenshot set.

## Validation

- `python3 scripts/ambitions-unsupported-claim-scan.py prompts/batches/AMB-558.md artifacts/ambitions-ui-reconstruction/final-gate/AMB-558-screenshot-board.md` - Green.
- `bash scripts/codex-forbidden-claim-scan.sh prompts/batches/AMB-558.md artifacts/ambitions-ui-reconstruction/final-gate/AMB-558-screenshot-board.md` - no blocking hits.
- `bash scripts/release-claim-safety-scan.sh` - Green.
- `bash -lc 'required_paths=(\"artifacts/ambitions-ui-reconstruction/screenshots/today-default-after-final.png\" \"artifacts/ambitions-ui-reconstruction/screenshots/goals-default-after-final.png\" \"artifacts/ambitions-ui-reconstruction/screenshots/time-default-after-final.png\" \"artifacts/ambitions-ui-reconstruction/screenshots/motion-default-after-final.png\" \"artifacts/ambitions-ui-reconstruction/screenshots/you-default-after-final.png\" \"artifacts/ambitions-ui-reconstruction/screenshots/capture-activated-after-final.png\" \"artifacts/ambitions-ui-reconstruction/screenshots/today-large-dynamic-type-after-final.png\" \"artifacts/ambitions-ui-reconstruction/screenshots/time-reduce-motion-after-final.png\" \"artifacts/ambitions-ui-reconstruction/screenshots/motion-empty-after-final.png\" \"artifacts/ambitions-ui-reconstruction/screenshots/you-increase-contrast-after-final.png\" \"artifacts/ambitions-ui-reconstruction/screenshots/capture-keyboard-after-final.png\" ); for p in \"${required_paths[@]}\"; do [[ -s \"$p\" ]] || { echo \"FAIL $p\"; exit 1; }; done; echo PASS'` - passed.
- `git diff --check` - passed.

## Changed Files

- `artifacts/ambitions-ui-reconstruction/final-gate/AMB-558-screenshot-board.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/today-default-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/goals-default-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/time-default-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/motion-default-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/you-default-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/capture-activated-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/today-large-dynamic-type-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/time-reduce-motion-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/motion-empty-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/you-increase-contrast-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/capture-keyboard-after-final.png`

## Proof Boundaries

This report claims only screenshot-board inventory and capture execution evidence for AMB-604. It does not claim visual quality approval, accessibility certification, release readiness, device proof, CI proof, TestFlight readiness, App Store readiness, or product completeness.

## Required Completion Footer

Verdict: Yellow
Artifact paths:
- `artifacts/ambitions-ui-reconstruction/final-gate/AMB-558-screenshot-board.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/today-default-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/goals-default-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/time-default-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/motion-default-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/you-default-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/capture-activated-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/today-large-dynamic-type-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/time-reduce-motion-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/motion-empty-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/you-increase-contrast-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/capture-keyboard-after-final.png`
Focused tests:
- `not available` - no matching focused test target exists for the exact AMB-558 screenshot board.
Changed files:
- `artifacts/ambitions-ui-reconstruction/final-gate/AMB-558-screenshot-board.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/today-default-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/goals-default-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/time-default-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/motion-default-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/you-default-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/capture-activated-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/today-large-dynamic-type-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/time-reduce-motion-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/motion-empty-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/you-increase-contrast-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/capture-keyboard-after-final.png`
Remaining Yellow debt:
- AMB-605
