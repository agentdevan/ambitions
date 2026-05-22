# IOS26-T00-B02 Validation Baseline Commands

- Batch: `IOS26-T00-B02`
- Run directory: `.codex/runs/IOS26-T00-B02/20260522T103515Z`
- Branch: `main`
- Starting commit: `58a5cf00b238263df9a916f2a8e77f0adb50aeb0`
- Status: `GREEN`

| # | Command | UTC start | Exit | Summary | Log / artifact |
| --- | --- | --- | --- | --- | --- |
| 1 | `git status --short` | `2026-05-22T10:37:51Z` | `0` | Clean worktree before validation. | Inline output only. |
| 2 | `xcodebuild -version` | `2026-05-22T10:37:54Z` | `0` | `Xcode 26.3` / build `17C529`. | Inline output only. |
| 3 | `xcodebuild -showsdks` | `2026-05-22T10:37:57Z` | `0` | iOS 26.2 SDK and Simulator 26.2 SDK are installed. | Inline output only. |
| 4 | `xcrun simctl list runtimes` | `2026-05-22T10:38:02Z` | `0` | iOS 26.3 runtime is available. | Inline output only. |
| 5 | `xcrun simctl list devices available` | `2026-05-22T10:38:05Z` | `0` | `iPhone 17` is available and booted. | Inline output only. |
| 6 | `xcodegen --version` | `2026-05-22T10:38:07Z` | `0` | `xcodegen` version `2.45.4`. | Inline output only. |
| 7 | `swift --version` | `2026-05-22T10:38:09Z` | `0` | Swift driver `1.127.15`, Apple Swift `6.2.4`. | Inline output only. |
| 8 | `swift package dump-package` | `2026-05-22T10:38:12Z` | `0` | Package resolved as `AmbitionsDesignSystem`; dump completed successfully. | Inline output only. |
| 9 | `xcodegen generate` | `2026-05-22T10:38:18Z` | `0` | Regenerated `Ambitions.xcodeproj` successfully. | `Ambitions.xcodeproj` |
| 10 | `scripts/build-local.sh` | `2026-05-22T10:38:21Z` | `0` | Native build succeeded through `xcbeautify`; warnings were limited to redundant `public` modifiers in `Sources/Components/*.swift`. | `output/logs/build-local-20260522-063821.log` |

Notes:

- `scripts/build-local.sh` also regenerated `Ambitions.xcodeproj` as part of the build lane.
- `git status --short` was clean before the ladder and clean after the ladder.
- No command was skipped or blocked.
