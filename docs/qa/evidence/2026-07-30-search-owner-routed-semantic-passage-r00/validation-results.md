<!-- markdownlint-disable MD013 -->

# Search R01 Validation Results

Status: `PASS`

Native proving ID: `AVF-SEARCH-D07-R01-NATIVE-R01`

Captured source: `873aab9cf6258a6dbe19a681d303b5c75e425d30`

## Native package and fixture host

- `swift build --package-path Packages/AmbitionsPresentation`: pass.
- `swift test --package-path Packages/AmbitionsPresentation --filter SearchNativeCalibration`: pass, 11 tests and 0 failures.
- `AmbitionsNativeFoundryHost` Simulator build: pass, `BUILD SUCCEEDED`.
- Focused `SearchNativeCalibrationR00HostUITests`: pass, 6 tests and 0 failures.

The final focused execution completed with an ordinary successful command exit. Xcode emitted its non-fatal `DebuggerLLDB.DebuggerVersionStore.StoreError` diagnostic; the passing `.xcresult` remains the recorded authority. CoreSimulator enumeration was restored without erasing Simulator data before the final build, test, and capture passes.

## Interaction and semantic assertions

- Full-screen Search hides the fixture origin chrome and retains the neutral Today/Search origin tuple.
- Initial query focus presents the software keyboard; query and Cancel remain hittable.
- Cancel from entry, results, contextual Inspect, owner handoff, no results, and privacy suppression returns to the exact fixture origin and exposes the Search trigger as `Returned from Search`.
- Representative results retain Event-before-movement order and identity → product-facing owner → current state → match reason when material → action semantics.
- Details uses product-facing object, timing, match, and bounded explanation language; framework Back returns to the selected Event result and restores result focus.
- Review in Time uses current time, requested time, consequence, and exactly one primary handoff action. It preserves `Tomorrow · 9:30 AM`, records zero canonical mutations, and framework Back restores the action-query Search context.
- No results preserves `ceramics invoice` and is distinct from privacy suppression.
- Privacy suppression preserves a valid visible result and exposes none of the protected identity probe.
- The prohibited rendered-language scanner finds none of the internal architecture, truth-taxonomy, fixture, proof, implementation, or mutation terms in Search product UI.
- Accessibility 2 keeps the complete first result and its Inspect action hittable above the native keyboard, preserves both fixture results in the scrollable semantic inventory, and leaves the second result as natural below-fold continuation.
- All fixture states and mutations are deterministic in focused package tests.

These automated checks are not manual VoiceOver, Switch Control, Voice Control, Full Keyboard Access, RTL, long-localization, or physical-device proof.

## Captures and metadata

- Exactly six required standalone PNGs exist; every image is 1206 × 2622 pixels.
- Each capture was visually inspected at original resolution.
- Every R01 capture has a distinct hash from its R00 predecessor. Details, Review in Time, and Accessibility 2 are intentional changes; entry reflects the required helper-copy change. Ordinary results and privacy suppression retain their R00 structure with deterministic native-capture differences only.
- Metadata parses as JSON and records device, OS, appearance, Dynamic Type, fixture identity, exact source commit, hashes, and proof ceiling.

## Acceptance-only authority reconciliation

- Current authority maps local query and retrieval to Find, Details and `About this result` to contextual Inspect, and Review in Time / Continue to Time to owner-routed Act preparation.
- The contextual-Inspect screenshot was renamed without changing its `ec644db1dcef775a01cff8700fdbf4992bb7589464b5532b4f0a6352c35fe694` SHA-256 hash.
- All six R01 PNG hashes, dimensions, and rendered product copy remain unchanged.
- Retired conversational and generic explanation-mode authority is absent from active Search evidence; bounded explanation remains content within contextual Inspect.
- Changed paths remain limited to Search evidence, the existing proof-gate record, and strictly necessary non-rendered Foundry/test identifiers.
- Local Markdown links resolve; prohibited positive-authorization markers are absent; `git diff --check` passes.
- Staged Gitleaks reports no leaks, and the four primary-worktree user-scheme hashes match acceptance preflight.
- No Xcode, Simulator, screenshot capture, package build, or focused test suite was rerun because only non-rendered identifiers and documentation changed.

## Bounded repository checks

- SwiftLint 0.63.2 on changed Swift files: pass, 0 violations.
- Local Markdown links in changed records: pass.
- Changed-path audit: pass; changes remain within Foundry Search source/tests/host, the bounded Search evidence package, and the existing global-journey gate record.
- `git diff --check`: pass.
- Introduced-range Gitleaks: pass.
- Primary-worktree Xcode user-scheme hashes: unchanged.
- Final worktree inspection: pass; branch clean after the R01 evidence commit.

No Capture work, canon compilation, broad repository audit, external-link check, production Search suite, unrelated Foundry suite, cross-root synthesis, or Crowned Edge Dock proof ran.
