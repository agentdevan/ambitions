# FCP08 Ambition Meridian Shell Report
<!-- markdownlint-disable MD013 -->

Date: 2026-05-05
Train: FCP Flagship Completion
Batch: FCP08 Ambition Meridian Shell
Result: Green with accepted background Yellow

## Result

FCP08 is Green. It promotes the already-implemented feature-flagged Meridian
shell to the default presentation, preserves native rollback with
`--ambitions-shell=native`, and adds a typed shell-chrome contract for the
destination rail, receipt overlay zone, global action, safe-area posture, and
rollback truth.

## Files Read

- `docs/canon/Ambitions_3_0_Ambition_Meridian_Shell_SwiftUI_Build_Spec.md`
- `docs/codex/FLAGSHIP_COMPLETION_OBJECT_SCORECARD.md`
- `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `Native/Ambitions/App/AmbitionsRootView.swift`
- `Native/Ambitions/App/AppShellPresentationMode.swift`
- `Native/Ambitions/App/AppMeridianShell.swift`
- `Native/Ambitions/App/AppTab.swift`
- `Native/AmbitionsTests/App/AppShellNavigationTests.swift`
- `Native/AmbitionsTests/App/AppShellChromeTests.swift`

## Files Changed

- `Native/Ambitions/App/AppShellPresentationMode.swift`
- `Native/Ambitions/App/AppMeridianShell.swift`
- `Native/AmbitionsTests/App/AppShellNavigationTests.swift`
- `docs/codex/batches/FCP08_Ambition_Meridian_Shell_Prompt.md`
- `docs/audits/fcp08-ambition-meridian-shell-report.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_DEPENDENCY_GRAPH.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/batch-trains/FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN.md`

## What Changed

- `AppShellPresentationMode.resolved()` now defaults to `.meridian`.
- Native fallback remains available through `--ambitions-shell=native`,
  `--ambitions-shell=nativeFallback`, or non-Meridian environment values.
- Added `AppMeridianShellChromeState` as a typed launch shell contract.
- The Meridian rail now exposes the Ambition Meridian label and selected
  destination as visible shell context.
- The Meridian rail accessibility value summarizes destination rail, receipt
  overlay zone, global action, and safe-area posture.
- Added focused shell tests proving the new default, rollback path, five
  canonical destinations, receipt zone contract, and no dashboard / AI
  confidence / sixth-tab drift.

## Tests Run

- `xcodegen generate`: PASS.
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/AppShellNavigationTests -only-testing:AmbitionsTests/AppShellChromeTests`: PASS, 35 tests, 0 failures. Expected `NOT_CODESIGNED` app-group simulator logs appeared because signing was disabled.
- `scripts/build-local.sh`: PASS, Build Succeeded.
- `scripts/cqs-product-drift-scan.sh ... || true`: advisory existing
  Capture Inbox compatibility hits in app routing files.
- `scripts/cqs-prompt-built-smell-scan.sh ... || true`: advisory existing
  coordinator/placeholder hits outside the new shell contract.
- `scripts/cqs-accessibility-motion-scan.sh ... || true`: advisory scan hits;
  the Meridian rail exposes explicit label/value, selected/not-selected
  destination values, and native fallback rollback.
- `scripts/cqs-privacy-security-claim-scan.sh ... || true`: PASS, 0 hits.
- `build_run_sim` through XcodeBuildMCP: PASS on iPhone 17 simulator.
- Simulator screenshot captured:
  `/var/folders/y1/sl7_d6_j11gb24rysqdj8c1r0000gn/T/screenshot_optimized_43acedd9-ca99-4723-9d87-676037fd9416.jpg`.

## Accepted Background Yellow

- FCP08 does not claim public accessibility conformance, physical-device proof,
  TestFlight/App Store readiness, release readiness, or legal/privacy
  compliance.
- Historical F18/F19 reports still describe the earlier feature-flagged state
  where native fallback was default; they remain history, while this report is
  the current FCP08 implementation truth.
- Doc QA and CQS scan advisory backlog may remain outside this touched scope.

## Rollback Path

Pass `--ambitions-shell=native` or revert this batch commit. No route/raw value,
external URL, persistence, schema, widget, App Intent, or Live Activity contract
changed.

## Next Eligible Batch

FCP09 Motion / Haptics / Reduced Motion Proof, if global order and validation
gates allow continuation.
