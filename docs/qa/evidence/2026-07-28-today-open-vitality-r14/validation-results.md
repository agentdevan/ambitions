# R14 validation results

Validation scope: `AVF-TODAY-S10-B04-D09-R14 — Native Fidelity Restoration`

Source validation SHA: `d39dd340c` (`repair R14 final UI assertions`)

## Build and tests

- Foundry target build: passed with `swift build --package-path Packages/AmbitionsPresentation --target AmbitionsNativeVisualFoundry`.
- Full presentation package tests: passed, 136 tests, 0 failures.
- Fixture-host Simulator build-for-testing: passed on iPhone 17 Pro, iOS 26.5, UDID `396F4B4A-2DAD-4345-B26E-ABD2EF69BF5E`.
- Focused repair batch: passed after the final returned-Today time-posture assertion repair.
- Final complete fixture-host UI suite: passed in one run, 90 tests, 0 failures, 0 unexpected failures, 2511.238 seconds. Result bundle: `/tmp/R14FinalCompleteUI-Green.xcresult`.
- SwiftLint: passed in strict mode for every changed Swift file.

## Repair history

The first complete batch executed 90 tests with 9 failures. Each failure was a stale assertion against an intentional R14 contract change: conditional `Scroll to Now`, the scrolling-aware Peek label construction, exact launch-brief fixture copy, human-facing history accessibility composition, focused-Step consequence copy, or the restored returned-Today action/time anatomy. No failing assertion was weakened to conceal behavior. The affected tests were updated to assert the approved R14 truth, rebuilt, run as a focused batch, and then rerun as the complete suite above.

## Canon and boundary validation

- `python3 scripts/ambitions-canon.py build`: passed; 66 documents, 466 requirements, 47 UX records, 39 visual records, 16 links, and 48 JSON projections.
- `python3 scripts/ambitions-canon.py check`: passed with the same counts.
- `python3 -m unittest tools.tests.test_ambitions_canon_compiler`: passed, 44 tests.
- Local-first boundary scan: passed.
- Runtime direct-write audit: passed; 55 markers reviewed, with no unsafe or unknown direct write.
- Weak-implementation scan: passed after replacing an ambiguous evidence-only phrase; no product source was changed for that repair.
- Gitleaks over `4e18499c0015acb1d64de7ccef1bb835fe2281a9..HEAD`: passed, no leaks.
- Changed-path audit: passed; changes remain in the Foundry package, fixture host/UI tests, and the R14 evidence package.
- Authority audit: passed; no canon authority, generated canon, app entry, runtime adapter, legacy frontend, dependency resolution, Figma, Code Connect, or production screenshot baseline changed.
- `git diff --check`: passed after normalizing evidence Markdown EOF whitespace.

## Evidence validation

- Screenshot metadata: 29 native Simulator frames validated for SHA-256, dimensions, fixture identity, device/OS, accessibility settings, and `production_baseline = false`.
- Contact-sheet metadata: three sheets validated against their recorded files and dimensions.
- `R14-A05` is intentionally pixel-equal to `R14-F07`: the standard review already uses structural node, label, and seam distinctions that do not depend on color.
- `R14-DK01` is intentionally pixel-equal to `R14-F09`: Simulator screenshots cannot encode physical display luminance. Physical low-brightness inspection remains open.
- No journey recordings were created or validated, per owner direction.

## Tooling note

The direct Xcode bridge remained preferred for implementation and diagnostics. One XcodeBuildMCP fallback probe returned the known `Transport closed` response; it was not treated as a direct-Xcode or repository failure. Direct `xcodebuild` and `simctl` were used for permitted Simulator automation and evidence capture.

## Final independent review

The single final authority/validation reviewer returned `PASS` with no blockers. It independently confirmed the fixture-only route boundary, unchanged R13 evidence tree, exact coverage of all 33 non-evidence changed paths, 29 screenshot and three contact-sheet hashes, `production_baseline = false`, the 90-test zero-failure result, undecided owner status, and the unmerged/unpushed branch state.

## Proof ceiling

The owner-authorized fixture route from returned Today to `step.send-launch-brief` is implemented and non-mutating. No production route, runtime adapter, app-entry integration, or launch-brief mutation journey was added. Direct-device proof remains incomplete. Runtime integration and broad reconstruction remain unauthorized. `APPROVED FOR SWIFTUI` remains `false`.
