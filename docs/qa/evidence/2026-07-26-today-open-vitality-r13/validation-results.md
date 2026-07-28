# Validation results

Validation date: 2026-07-28 EDT

## Green checks

- `swift build --package-path Packages/AmbitionsPresentation --target AmbitionsNativeVisualFoundry`: passed in 15.85 seconds.
- `swift test --package-path Packages/AmbitionsPresentation`: 124 tests passed, 0 failed.
- Direct fixture-host `xcodebuild build-for-testing`: `TEST BUILD SUCCEEDED` on iPhone 17 Pro Max, iOS 26.5.
- R13 focused native UI batch: 13 of 14 passed on the first batch. The saving still test exposed a synthetic-timing race, was narrowed to the dedicated static saving fixture, and then passed in isolation. The complete five-test screenshot-capture group subsequently passed, 5 of 5.
- Complete fixture-host UI suite: 90 tests executed; 88 passed and two assertion-precision checks failed in the one-shot batch. The first queried a stale commit accessibility node during saving instead of verifying that duplicate commitment was unavailable. The second required root and global adaptive-navigation controls to coexist in one Accessibility Dynamic Type viewport instead of following the natural scroll transformation.
- Final focused repair verification: the corrected successful-journey test passed 1 of 1, and the corrected Accessibility Dynamic Type passage test passed 1 of 1. The evidence therefore reports the original 88/90 batch plus the two fresh focused passes; it does not misrepresent the original batch as all-green.
- SwiftLint: 54 changed Swift files, 0 violations.
- Canon build: 66 documents, 466 requirements, 47 UX screens, 39 visual contracts, 16 local links, and 45 JSON files.
- Focused canon/compiler suite: 44 tests passed.
- Canon check: passed.
- Local-first boundary scan: green.
- Runtime direct-write audit: green; no unsafe or unknown production direct-write rows.
- Weak-implementation scan: green after replacing a legitimate SwiftUI enabled-state modifier that the broad scanner classified as an inactive-test pattern.
- Gitleaks current-material and introduced-history scan: green; no leaks in approximately 173.56 MB or 65 introduced commits.
- Gitleaks B02-to-R13 range scan: green; no leaks in 30 commits.
- Evidence validator: 37 screenshots, four contact sheets, and eight owner references validated.
- `git diff --check`: passed.
- Final specification review: `PASS` after its original scope and evidence blockers were repaired.
- Final combined visual-quality/accessibility review: `PASS`; 20-category average 4.50/5 with no category below 4.

## Final evidence repair

- Replaced A01-A04 with distinct native captures proving Accessibility Dynamic Type root/review recomposition, actual Simulator Increased Contrast, and non-color state distinction.
- Replaced D01, D04, D05, D08, and D09 with the named Goal, History, Filters, Undo, and complete failed-settlement states.
- Corrected F13 device metadata to iPhone 17 Pro Max and regenerated C01/C04.
- Confirmed no duplicate screenshot hashes, blank panels, mislabeled panels, or obscured required review actions remain.

## Native tooling qualification

The package-backed native preview loop remained the default visual loop. Sixteen source-changing warm reloads completed without a clean build or host relaunch; 15 were under 15 seconds and one took 23 seconds.

The direct Xcode bridge was preferred for the final build request. Xcode did not return a bounded completion result, so the waiting call was stopped. Direct `xcodebuild` was then used only for the permitted Simulator build and selected UI automation. The fixture-host build succeeded. This bridge availability result is not classified as a repository or direct-Xcode integration failure, and the earlier XcodeBuildMCP `Transport closed` event is not used as R13 failure evidence.

## Authority and changed-path audit

- Local `main` and `origin/main`: `5670f24fb82adefd27cffee5ddf8fb70676ed049`.
- Source calibration SHA: `ac7ed07d090d65bdc469a9a2309f6899dc6135e6`.
- VC-01 through VC-14 remain `CLOSED`.
- `APPROVED FOR SWIFTUI` remains `false`.
- Broad frontend reconstruction and runtime integration remain unauthorized.
- No canon or generated-canon file changed.
- No production app entry, runtime adapter, legacy frontend, dependency resolution, Figma artifact, Code Connect artifact, or production screenshot baseline changed or was added.
- The R13 evidence directory contains no recording file, recording metadata, or recording validation.
- The R13 evidence is English-only by owner direction.

## Proof ceiling

Simulator builds, tests, screenshots, and contact sheets establish evaluation evidence only. They do not complete direct-device proof, production visual approval, runtime persistence proof, or `APPROVED FOR SWIFTUI`.
