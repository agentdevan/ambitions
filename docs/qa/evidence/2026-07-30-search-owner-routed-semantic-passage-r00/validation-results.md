<!-- markdownlint-disable MD013 -->

# Search R00 Validation Results

Status: `PASS`

Native proving ID: `AVF-SEARCH-D07-R01-NATIVE-R00`

Captured source: `5366214d4b1d1c1a8dd7fbec9889cffbc250843b`

## Native package and fixture host

- `swift build --package-path Packages/AmbitionsPresentation`: pass.
- `swift test --package-path Packages/AmbitionsPresentation --filter SearchNativeCalibration`: pass, 11 tests and 0 failures.
- `AmbitionsNativeFoundryHost` Simulator build: pass, `BUILD SUCCEEDED`.
- Focused `SearchNativeCalibrationR00HostUITests`: pass, 6 tests and 0 failures.

Xcode emitted its existing non-fatal `DebuggerLLDB.DebuggerVersionStore.StoreError` launch-snapshot diagnostic; tests continued. One earlier bounded wrapper reached its teardown timeout after XCTest had reported all six tests green. The final focused execution completed with an ordinary successful command exit; the teardown diagnostic is not used to inflate the proof claim.

## Interaction and semantic assertions

- Full-screen Search hides the fixture origin chrome and retains the neutral Today/Search origin tuple.
- Initial query focus presents the software keyboard; query and Cancel remain hittable.
- Cancel from entry, results, Inspect/Understand, owner handoff, no results, and privacy suppression returns to the exact fixture origin and exposes the Search trigger as `Returned from Search`.
- Representative results retain Event-before-movement order and identity → owner → current truth → match reason when material → action semantics.
- Framework Back returns from Inspect/Understand to the selected Event result and restores result focus.
- Owner-handoff preparation preserves `Tomorrow · 9:30 AM`, records zero canonical mutations, and cancellation restores the action-query Search context.
- No results preserves `ceramics invoice` and is distinct from privacy suppression.
- Privacy suppression preserves a valid visible result and exposes none of the protected identity probe.
- Accessibility 2 increases result geometry above ordinary Large, preserves result order and semantic order, and keeps query, Cancel, keyboard, and essential actions reachable.
- All fixture states and mutations are deterministic in focused package tests.

These automated checks are not manual VoiceOver, Switch Control, Voice Control, Full Keyboard Access, RTL, long-localization, or physical-device proof.

## Captures and metadata

- Exactly six required standalone PNGs exist; every image is 1206 × 2622 pixels.
- Each capture was visually inspected at original resolution.
- Accessibility output has a distinct hash from the ordinary result frame after Dynamic Type was explicitly propagated across the full-screen presentation boundary.
- Metadata parses as JSON and records device, OS, appearance, Dynamic Type, fixture identity, exact source commit, hashes, and proof ceiling.

## Bounded repository checks

- SwiftLint 0.63.2 on changed Swift files: pass, 0 violations.
- Local Markdown links in changed records: pass.
- Changed-path audit: pass; changes remain within Foundry Search source/tests/host, the bounded Search evidence package, and the existing global-journey gate record.
- `git diff --check`: pass.
- Introduced-range Gitleaks: pass.
- Primary-worktree Xcode user-scheme hashes: unchanged.
- Final worktree inspection: pass; branch clean after the evidence commit.

No Capture work, canon compilation, broad repository audit, external-link check, production Search suite, unrelated Foundry suite, cross-root synthesis, or Crowned Edge Dock proof ran.
