# Exact command log

Commands were executed from the R14 worktree unless noted.

- `git fetch --prune origin`
- `/usr/bin/git rev-parse HEAD main origin/main`
- `swift test --package-path Packages/AmbitionsPresentation`
- `swift test --package-path Packages/AmbitionsPresentation --filter TodayVitalityRootTests`
- `/usr/bin/xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost -destination 'platform=iOS Simulator,id=396F4B4A-2DAD-4345-B26E-ABD2EF69BF5E' -derivedDataPath /tmp/ambitions-r14-build-working/r14-derived build-for-testing`
- focused `test-without-building` invocations for journey, settlement, Full Day, supporting depth, recovery, resilience, accessibility, and screenshot capture.
- `xcrun simctl boot`, `bootstatus`, `install`, `launch`, and `io screenshot` on the recorded iPhone 17e, iPhone 17 Pro, and iPhone 17 Pro Max devices.
- `xcrun xcresulttool export attachments` for the final natural-scroll frame.
- ImageMagick identify/montage commands for blank-frame inspection, dimensions, and contact sheets.
- Final validation commands and exact results are recorded in `validation-results.md`.

The direct Xcode bridge remained preferred. A single XcodeBuildMCP fallback probe returned the previously known `Transport closed`; it was not treated as a repository or direct-Xcode integration failure. Direct `xcodebuild`/`simctl` was used only for permitted Simulator automation and evidence capture.

