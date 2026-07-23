# Native Visual Foundry warm-loop benchmark

Date: 2026-07-23

View: `TodayBootstrapView`

Fixture: `today-bootstrap/preparing-for-baby/typical/v1`

Device: iPhone 17 Pro Max Simulator, iOS 26.5 (`23F77`),
`DD9B9C84-7188-48FA-AA2A-AB5C1D0EE2B6`

Toolchain: Xcode 26.6 (`17F113`), Swift 6.3.3

No benchmark used `clean`. Every temporary mutation was restored before the
final screenshots and validation.

## Path A — package-backed Simulator preview hot reload

Tool: the installed `ios-simulator-browser` preview launcher

Command:

```sh
node /Users/devan/.codex/plugins/cache/openai-curated-remote/build-ios-apps/0.1.2/skills/ios-simulator-browser/scripts/swiftui-preview-browser.mjs \
  Packages/AmbitionsPresentation/Package.swift \
  --package-target AmbitionsNativeVisualFoundry \
  --device DD9B9C84-7188-48FA-AA2A-AB5C1D0EE2B6 \
  --preview-filter 'Today Bootstrap — Typical Light'
```

The first generated-host build took about 117 seconds and the launcher timed
out before observing render readiness. The native frame appeared about three
seconds later and was independently captured from the Simulator. The warmed
restart built in 11 seconds and reported ready in 20 seconds. The table measures
source-change detection through the launcher's `hot-reloaded` event after that
warm-up.

| Mutation | Observed latency | Assessment | Result |
| --- | ---: | --- | --- |
| Copy | 15 s | Strong | Rendered; copy change independently visible in a Simulator capture |
| Padding | 9 s | Excellent | Rendered |
| Typography | 9 s | Excellent | Rendered |
| Functional dock material/tonal treatment | 9 s | Excellent | Rendered |
| Small conditional-state change | 11 s | Excellent | Rendered |
| Padding confirmation 1 | 12 s | Excellent | Rendered |
| Padding confirmation 2 | 9 s | Excellent | Rendered |

Reliability: 7/7 warm mutations rendered. The cold readiness observation failed
once; this remains a known launcher reliability limitation rather than a hidden
success.

## Path B — incremental Xcode build plus Simulator install/launch

XcodeBuildMCP `session_show_defaults` was attempted first and failed twice with
`Transport closed`, including after the repository's native MCP lifecycle check
completed successfully. The permitted non-invasive fallback used the same host
and Simulator with normal command-line Xcode tooling.

Build command:

```sh
xcodebuild \
  -project Ambitions.xcodeproj \
  -scheme AmbitionsNativeFoundryHost \
  -configuration Debug \
  -destination id=DD9B9C84-7188-48FA-AA2A-AB5C1D0EE2B6 \
  -derivedDataPath /tmp/ambitions-vc14-native-foundry-derived-data \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Each measurement includes the incremental build, `simctl install`,
`simctl launch --terminate-running-process`, a six-second render allowance, and
a successful native PNG capture.

| Mutation | Observed latency | Assessment | Result |
| --- | ---: | --- | --- |
| Repaired warm baseline | 21.76 s | Strong | Rendered |
| Copy | 19.86 s | Strong | Rendered |
| Padding | 17.31 s | Strong | Rendered |
| Typography | 17.67 s | Strong | Rendered |
| Functional dock material/tonal treatment | 18.38 s | Strong | Rendered |
| Small conditional-state change | 17.37 s | Strong | Rendered |
| Padding confirmation 1 | 18.24 s | Strong | Rendered |
| Padding confirmation 2 | 17.73 s | Strong | Rendered |

Reliability: 8/8 warmed measurements built, launched, and captured. The first
host render exposed letterboxing because the fixture host lacked launch-screen
metadata; adding generated launch-screen metadata repaired it before these
measurements and before final evidence capture.

## Provisional default inner loop

Select Path A, package-backed Simulator preview hot reload, as the provisional
Foundry inner loop. Its repeatable warm range was 9–15 seconds versus Path B's
17.31–21.76 seconds. Path B remains the reliable render-and-capture verification
path, especially while Path A's cold readiness timeout is unresolved.

This benchmark authorizes no broader architecture change, dependency, runtime
integration, or production screenshot baseline.
