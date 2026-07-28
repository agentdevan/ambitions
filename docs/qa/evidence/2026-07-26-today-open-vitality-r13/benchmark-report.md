# Warm-loop benchmark

Environment: package target `AmbitionsNativeVisualFoundry`, iPhone 17 Pro Max
Simulator, iOS 26.5, package-preview browser hot swap, no clean build.

Initial package-preview launch: 69 seconds (cold host generation and launch).

Warm source-changing results, measured from watcher detection to successful hot
reload:

| Area | Runs (seconds) | Result |
| --- | --- | --- |
| Today root spacing | 14, 11, 10, 10 | 4/4 successful |
| Review composition | 12, 13, 13, 12 | 4/4 successful |
| Settlement composition | 11, 12, 11, 12 | 4/4 successful |
| Material treatment | 11, 14, 12, 23 | 4/4 successful |

All 16 changes appeared through hot reload in the same host PID (`26483`), with
no host relaunch and no clean build. The apparently fastest path repeated below
15 seconds in 15 of 16 warm runs. One material run took 23 seconds and remained
successful. The provisional default inner loop remains the package-backed
preview hot reload: excellent to strong and repeatable.

A cached fixture-host `build-for-testing` also succeeded without cleaning. The
direct Xcode bridge remained available for repository diagnostics. XcodeBuildMCP
`Transport closed` was isolated to that fallback and is not classified as a
repository or direct-Xcode failure.

