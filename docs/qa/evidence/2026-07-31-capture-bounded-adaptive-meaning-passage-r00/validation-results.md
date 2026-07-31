<!-- markdownlint-disable MD013 -->

# Capture R00 Validation Results

Status: `PASS`

Package review status: `READY_FOR_OWNER_CAPTURE_NATIVE_REVIEW`

Native proving ID: `AVF-CAPTURE-S07-R01-NATIVE-R00`

Captured source: `8fd34693d81938975ac26692719375f6a675589b`

## Native package and fixture host

- `swift build --package-path Packages/AmbitionsPresentation`: pass.
- `swift test --package-path Packages/AmbitionsPresentation --filter CaptureNativeCalibration`: pass, 16 tests and 0 failures.
- `AmbitionsNativeFoundryHost` Simulator build: pass, `BUILD SUCCEEDED`.
- Focused `CaptureNativeCalibrationR00HostUITests`: pass, 7 tests and 0 failures in 291.535 seconds.
- Focused final accessibility capture test: pass, 1 test and 0 failures in 34.887 seconds.

The established VC14 Simulator initially had stale host content and then an unavailable XCTest accessibility service. The installed host mismatch was corrected, the product UI and software keyboard were manually observable, and no source defect was inferred from the service failure. After confirming no Xcode or XCTest work was active, the user-level CoreSimulator service was restarted without erasing device data. Final automated evidence ran on a fresh isolated iPhone 17 Pro Simulator with the same OS and 1206 × 2622 profile: `VC14 Capture Proof iPhone 17 Pro`, UDID `8A217324-6158-45E4-907D-ECBA5198DDCB`, iOS 26.5 (23F77).

Xcode emitted its non-fatal `DebuggerLLDB.DebuggerVersionStore.StoreError` diagnostic during UI launch. Every final focused test passed and the recorded `.xcresult` is authoritative for the bounded automated run.

## Interaction and semantic assertions

- Capture enters as a temporary full-screen global non-root, hides neutral-origin chrome, focuses the editor, shows the native keyboard, and retains the Today/Capture return tuple.
- Empty Cancel dismisses directly. Non-empty Cancel presents only `Keep Editing` and `Discard and Close`.
- `Keep Editing` preserves the expression and editor focus; `Discard and Close` performs no mutation and restores exact origin trigger focus.
- Primary expression remains visible through bounded meaning, review, Change, and recovery.
- The ambiguous fixture alone receives one targeted clarification; no second clarification is produced.
- Framework Back preserves the preceding Capture state; `Change` restores retained text and focus.
- Consequential review retains original words, proposed Goals meaning, related Time context, unchanged current state, and the pre-change boundary.
- `Continue to Goals` records a fixture-only handoff flag and keeps the canonical mutation count at zero.
- Recovery retains original expression, clarified response when present, proposed meaning, and related context in-session.
- Prohibited rendered terms for chatbot, schema, dictation, attachment, persistence, Receipt, Undo, settlement, routing internals, fixture, proof, implementation, and mutation are absent.
- Accessibility 2 preserves the full semantic inventory in order, uses native vertical scrolling, keeps the navigation actions reachable, and makes the primary and secondary actions fully hittable without clipping or collision.
- The final Accessibility 2 screenshot is a native XCTest attachment captured immediately after the tested ScrollView gesture and hitability assertions; no screenshot-only layout branch exists.

These automated checks are not manual VoiceOver, Switch Control, Voice Control, Full Keyboard Access, RTL, long-localization, or physical-device proof.

## Captures and metadata

- Exactly six required standalone PNGs exist; every image is 1206 × 2622 pixels.
- Each capture was visually inspected at original resolution.
- Metadata parses as JSON and records the Simulator, OS, appearance, Dynamic Type, fixture identity, exact source commit, hashes, and proof ceiling.
- The first five captures use Dynamic Type Large. The sixth uses Accessibility 2 and demonstrates the scrolled action region while automated order assertions retain the complete review inventory.

## Bounded repository checks

- SwiftLint 0.63.2 on changed Swift files: pass, 0 violations.
- Local Markdown links in changed records: pass.
- Changed-path audit: pass; changes remain within Capture-specific Foundry source/tests/host, this bounded Capture evidence package, and the existing global-journey gate record.
- `git diff --check`: pass.
- Introduced-range Gitleaks: pass.
- Primary-worktree Xcode user-scheme hashes: unchanged.
- Final worktree inspection: pass; branch clean after the evidence commit.

Accepted Search files and behavior remained untouched. No canon compilation, external-link validation, production Capture suite, Search suite, broad repository audit, cross-root synthesis, or dock proof ran.
