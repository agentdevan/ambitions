# Validation results

## Build and tests

- Focused `TimeNativeCalibration` package suite: 9 tests passed, zero
  failures after final lint-only source cleanup.
- Native Foundry host Simulator build: passed after final source cleanup.
- Final combined D07 UI batch: 5 tests passed, zero failures in one run.
  - measured Week orientation and proportional geometry;
  - focused Wednesday, compact detail, dismissal, and exact return;
  - proposal inspection, current/proposed separation, and unchanged return;
  - Thursday external-source and proposal distinction;
  - Accessibility 2 ordered chronology in place of the spatial timeline.
- Final UI result:
  `.codex/DerivedData/TimeD07/Logs/Test/`
  `Test-AmbitionsNativeFoundryHost-2026.07.30_12-19-51--0400.xcresult`

The first candidate UI batch exposed one accessibility grouping defect: an
identifier on the review container masked its separately testable descendants.
Removing that redundant identifier preserved the rendered screen and exposed
current, proposed, consequence, and actions independently. A later Simulator
automation stall was resolved by rebooting only the dedicated VC14 device after
confirming no competing build lane. The clean five-test batch then passed.

## Static and evidence checks

- SwiftLint strict: 10 changed Swift files, zero violations.
- Markdown lint: 19 changed Markdown files, zero errors.
- Screenshot metadata JSON: valid.
- Screenshot inventory: exactly five native PNG files, all 1206 × 2622.
- Screenshot hashes: 5/5 matched metadata and all five were distinct.
- Visual inspection: 5/5 final frames contained the intended native screen;
  the discarded blank capture batch is not referenced by metadata.
- Changed-path audit: bounded to Foundry host, Foundry package/tests, Time
  research documents, and D07 evidence.
- `git diff --check`: passed.
- Introduced-range Gitleaks: recorded after the final commit.

## Diagnostic note

Xcode 26.6 emitted `DebuggerLLDB.DebuggerVersionStore.StoreError` during some
Simulator launches. The final signed build, rendered frames, unit suite, and
clean UI batch passed; the local debugger-version diagnostic did not alter the
fixture or repository result.
