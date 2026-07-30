<!-- markdownlint-disable MD013 -->

# Validation Results

Status: `PASS`

Captured source: `99a81c4063b1928b3cf5ec53783594f8d41e5e95`

## Native package and fixture host

- `swift build --package-path Packages/AmbitionsPresentation`: pass.
- `swift test --package-path Packages/AmbitionsPresentation --filter YouNativeCalibration`: pass, 6 tests and 0 failures.
- `AmbitionsNativeFoundryHost` Simulator `build-for-testing`: pass, `TEST BUILD SUCCEEDED`.
- Focused `YouNativeCalibrationD07HostUITests`: pass, 3 tests and 0 failures.

Xcode emitted a non-fatal `DebuggerLLDB.DebuggerVersionStore.StoreError` diagnostic while creating the UI-test launch snapshot. The focused tests continued and passed.

## Interaction and accessibility assertions

- Root to Appearance uses `NavigationStack` and a typed route.
- The framework Back button is present and hittable.
- Back returns to the root at the originating scroll position and exposes Appearance as the return target.
- Ordinary root order and summaries are asserted through Notifications & Attention.
- The next domain begins below the ordinary first viewport rather than being compressed into it.
- Accessibility Dynamic Type preserves all nine domains, all summaries, canonical semantic order, and natural scroll reachability.
- Every asserted row has at least a 44-point interaction envelope.

These automated semantic checks are not manual VoiceOver, Switch Control, Voice Control, Full Keyboard Access, long-localization, RTL, or physical-device proof.

## Captures and metadata

- Exactly three required PNG files exist.
- Each PNG is 1206 × 2622 pixels.
- Metadata parses as JSON and records device, OS, appearance, Dynamic Type, fixture identity, exact captured-source commit, SHA-256, `production_baseline = false`, `direct_device_proof = false`, and `approved_for_swiftui = false`.
- All three images were inspected at original resolution against the bounded native rejection conditions.

## Bounded repository checks

- SwiftLint 0.63.2 on the nine changed Swift files: pass, 0 violations.
- Local Markdown links in changed records: pass.
- Changed-path audit: pass; only Native Foundry host/test paths, the Foundry package/test paths, existing You packet records, and this evidence directory changed.
- `git diff --check`: pass.
- Introduced-range Gitleaks: pass.
- Final worktree inspection: pass; branch clean after evidence commit.

No canon compilation, broad repository audit, external-link check, unrelated test suite, production-app reconstruction check, manual Xcode session, or physical-device lane ran.
