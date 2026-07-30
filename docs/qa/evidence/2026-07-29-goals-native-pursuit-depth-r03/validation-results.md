# Validation results

Executable capture SHA: `0c744ec28aef3164cb7905f2c5c1f6deedfd8e62`

## Build and tests

- AmbitionsPresentation build: passed.
- AmbitionsPresentation complete suite: 177 tests passed, zero failures.
- Fixture-host Simulator build-for-testing: passed in isolated `.codex/DerivedData-R03-UI2`.
- Final combined Goals UI batch: 19 tests passed, zero failures, one run.
  - protected R02 regression suite: 8 passed;
  - R03 functional, accessibility, and reduced-effects suite: 9 passed;
  - R03 journey recording drivers: 2 passed.
- The final clean batch result is `/tmp/GoalsNativeR03-final-clean-1.xcresult`.

The preceding candidate batch exposed two test-harness defects: an unreliable XCUI edge-swipe synthesis and a returned relationship action below the viewport. The regression now uses the visible framework Back control to prove native return/restoration, and the journey scrolls truthfully to the returned relationship entry. Focused repairs passed before the clean 19-test batch. Interactive edge-swipe behavior remains direct-device proof rather than a Simulator claim.

## Static, canon, and authority checks

- SwiftLint strict: 23 changed Swift files, zero violations.
- Canon check: 66 documents, 466 requirements, 47 UX screens, 39 visual contracts, 16 local links, and 59 JSON files passed.
- Focused canon/compiler suite: 44 tests passed.
- Local-first boundary scan: green.
- Flagship boundary audit: green.
- Runtime direct-write audit: green; no unsafe or unknown production direct-write rows.
- Weak-implementation scan: green after replacing a documentation phrase that triggered the conservative scanner; no executable weakness was found.
- Gitleaks over `d3c99c8b287d0aa98fc83c17e4d4f8b77d3c8b9d...HEAD`: green, no leaks.
- Screenshot metadata: 14/14 files and SHA-256 values validated.
- Contact-sheet metadata: 3/3 files and SHA-256 values validated.
- Recording metadata: 2/2 files, SHA-256 values, inventory, and differing semantic frames validated.
- Protected R02 comparison: no material content regression; absolute-error ratios were 1.17% for root and 1.19% for Home/focused Goal, attributable to settled framework chrome capture.

## Evidence inventory

- Primary screenshots: 8.
- Accessibility and reduced-effects screenshots: 4.
- Return and protected-comparison screenshots: 2.
- Contact sheets: 3.
- Recordings: 2 deterministic semantic-state H.264 clips driven by passing XCUI journeys.
- Every artifact has `production_baseline = false`.

## Diagnostic note

Xcode emitted `DebuggerLLDB.DebuggerVersionStore.StoreError` during some Simulator launches. Passing builds and the clean 19-test batch establish that this local debugger-version diagnostic did not affect repository state, fixture-host execution, or results.
