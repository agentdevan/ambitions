# Command log

Primary command families executed:

- `git fetch --prune origin`, branch/worktree/status and history inspection
- canon query/build/check and focused compiler tests
- direct Xcode bridge window, issue, and selected-test discovery
- `swift build` and `swift test` for `AmbitionsPresentation`
- `xcodebuild build-for-testing` and focused `test-without-building`
- `xcrun simctl` boot/install/launch/screenshot/status-bar automation
- package preview hot-reload launcher for 16 source-changing runs
- SwiftLint, boundary/direct-write/weak-implementation scans, Gitleaks
- screenshot/reference/comparison manifest validation
- `git diff --check`, changed-path and authority audits

Simulator automation recorded two environmental failures: an iPhone Air
launchd/data-migration boot failure and late-suite Accessibility service timeouts
on one iPhone 17 Pro. The same focused tests passed on iPhone 17 Pro Max.

