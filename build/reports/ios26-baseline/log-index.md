# IOS26-T00-B02 Validation Baseline Log Index

- Batch: `IOS26-T00-B02`
- Run directory: `.codex/runs/IOS26-T00-B02/20260522T103515Z`
- Branch: `main`
- Starting commit: `58a5cf00b238263df9a916f2a8e77f0adb50aeb0`

| # | Command | Exit | Primary log / artifact | Indexed summary |
| --- | --- | --- | --- | --- |
| 1 | `git status --short` | `0` | Inline output only | Worktree clean before validation. |
| 2 | `xcodebuild -version` | `0` | Inline output only | Xcode `26.3` build `17C529`. |
| 3 | `xcodebuild -showsdks` | `0` | Inline output only | iOS `26.2` SDK and Simulator `26.2` SDK present. |
| 4 | `xcrun simctl list runtimes` | `0` | Inline output only | iOS `26.3` runtime present. |
| 5 | `xcrun simctl list devices available` | `0` | Inline output only | `iPhone 17` available and booted. |
| 6 | `xcodegen --version` | `0` | Inline output only | `xcodegen` `2.45.4`. |
| 7 | `swift --version` | `0` | Inline output only | Swift `6.2.4`. |
| 8 | `swift package dump-package` | `0` | Inline output only | Package graph dumped successfully. |
| 9 | `xcodegen generate` | `0` | `Ambitions.xcodeproj` | Project regenerated; no tracked diff remained afterward. |
| 10 | `scripts/build-local.sh` | `0` | `output/logs/build-local-20260522-063821.log` | Full native build log; build succeeded with redundant `public` modifier warnings only. |

Log notes:

- The build log is the canonical detailed proof artifact for the native compile lane.
- The build lane used `xcbeautify` and wrote its log to `output/logs/build-local-20260522-063821.log`.
- No separate log file was produced by the lightweight environment checks; their evidence is the inline command output.
