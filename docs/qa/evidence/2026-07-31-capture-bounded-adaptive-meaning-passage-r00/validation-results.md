<!-- markdownlint-disable MD013 -->

# Capture R01 Validation Results

Status: `PASS`

Package review status: `READY_FOR_OWNER_CAPTURE_NATIVE_R01_REVIEW`

Native proving ID: `AVF-CAPTURE-S07-R01-NATIVE-R01`

Captured source: `8e645c4c67534096b27ef5979b6db71796ee0350`

## Native package and fixture host

- `swift build --package-path Packages/AmbitionsPresentation`: pass.
- `swift test --package-path Packages/AmbitionsPresentation --filter CaptureNativeCalibration`: pass, 17 tests and 0 failures.
- `AmbitionsNativeFoundryHost` Simulator build: pass, `BUILD SUCCEEDED`.
- Focused `CaptureNativeCalibrationR00HostUITests`: pass, 7 tests and 0 failures in 268.560 seconds.
- SwiftLint 0.63.2 on the six changed Swift files: pass, 0 violations.

Final native validation ran on `VC14 Capture R01 iPhone 17 Pro`, UDID `5F93135F-DB04-41C9-81FD-F8272224994B`, iOS 26.5 (23F77), at 1206 × 2622 pixels. Xcode emitted its non-fatal `DebuggerLLDB.DebuggerVersionStore.StoreError` launch diagnostic. Earlier focused attempts encountered a transient Simulator service-hub failure; no competing Xcode or XCTest process was active, the user-level CoreSimulator service was restarted without erasing device data, and the final complete focused run passed.

## Interaction and semantic assertions

- Capture enters as a temporary full-screen global non-root, hides neutral-origin chrome, focuses the editor, shows the native keyboard, and retains the Today/Capture return tuple.
- Empty entry exposes no primary action. Non-empty expression uses one transient `Continue` action.
- Empty Cancel dismisses directly. Non-empty Cancel presents only `Keep Editing` and `Discard and Close`.
- `Keep Editing` preserves the expression and editor focus; `Discard and Close` performs no mutation and restores exact origin trigger focus.
- Original expression precedes proposed meaning and remains visible through meaning, clarification, review, Edit, and recovery.
- The ambiguous fixture alone receives one targeted clarification in framework depth; no second clarification is produced.
- Bounded meaning contains no detached `Destination`, `Proposed, not added`, or `What this could mean` anatomy.
- Review preserves proposal, original words, related Time context, unchanged state, consequence, and one primary/one secondary action hierarchy.
- `Continue to Goals` records a fixture-only handoff flag and keeps the canonical mutation count at zero.
- Recovery retains expression, clarified response when present, proposed meaning, and related context in-session.
- Prohibited rendered terms for chatbot, schema, dictation, attachment, persistence, Receipt, Undo, settlement, routing internals, fixture, proof, implementation, and mutation are absent.
- Framework Back preserves Capture context; global Cancel and discard restore the exact origin and Capture-trigger focus.

## Accessibility proof

- Accessibility 2 begins with proposal identity and original words in deterministic order, preserves the related Time context, and continues through the truth/consequence fold by native scrolling.
- Top and lower states have no label, action, or content overlap.
- The fixed bottom action treatment does not obscure the scrollable consequence after the tested scroll.
- `Continue to Goals` and `Edit proposal` are fully inside the app viewport, at least 44 points high, non-overlapping, and hittable.
- Back and Cancel remain semantically available; no text is scaled down to fit.
- The two accessibility PNGs separately record top orientation and the lower scrolled action state.

This is automated Simulator geometry, identifier, order, scrolling, and hitability proof. It is not manual VoiceOver, Switch Control, Voice Control, Full Keyboard Access, RTL, long-localization, or physical-device proof.

## Captures and metadata

- Exactly seven required standalone PNGs exist; every image is 1206 × 2622 pixels.
- Each capture was visually inspected at original resolution.
- Metadata parses as JSON and records the Simulator, OS, appearance, Dynamic Type, fixture identity, exact source commit, hashes, and proof ceiling.
- The first five captures use Dynamic Type Large. Frames 06 and 07 use Accessibility 2.

## Bounded repository checks

- Local Markdown links in changed Capture records: pass.
- Strict changed-path audit: pass; the R01 delta remains within Capture-specific Foundry source/tests/host and the existing Capture evidence package.
- `git diff --check`: pass.
- Introduced-range Gitleaks: pass.
- Primary-worktree Xcode user-scheme hashes: unchanged.
- Current `main` remains `0c1451d74ca73e87a0a95008b3d0adde5c001f1a`; this branch was not rebased.
- Final worktree inspection: pass; branch clean after the evidence commit.

Accepted Search source, screenshots, behavior, and evidence remained untouched. No production Capture, routing, canon, accepted root evidence, final component, final token, operating-plan document, or production app entry changed. No canon compilation, external-link validation, production Capture suite, Search suite, broad audit, FR-2 work, cross-root rendering, or production reconstruction ran.
