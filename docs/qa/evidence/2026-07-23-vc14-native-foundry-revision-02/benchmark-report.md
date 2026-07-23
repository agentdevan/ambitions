# Native Visual Foundry revision 02 warm-loop measurement

Date: 2026-07-23

View: `TodayBootstrapView`

Fixture: `today-bootstrap/preparing-for-baby/typical/v1`

Device: iPhone 17 Pro Simulator, iOS 26.5 (`23F77`),
`EDE1E954-C663-47FB-855B-95F96AE2DBDD`

Toolchain: Xcode 26.6 (`17F113`), Swift 6.3.3

The existing package-backed Simulator preview launcher was warmed before both
measurements. No `clean` was used. The package, target, device, filter, and
hot-reload workflow were unchanged.

```sh
node /Users/devan/.codex/plugins/cache/openai-curated-remote/build-ios-apps/0.1.2/skills/ios-simulator-browser/scripts/swiftui-preview-browser.mjs \
  /Users/devan/Documents/GitHub/ambitions/.worktrees/vc14-native-foundry-bootstrap/Packages/AmbitionsPresentation/Package.swift \
  --package-target AmbitionsNativeVisualFoundry \
  --device EDE1E954-C663-47FB-855B-95F96AE2DBDD \
  --preview-filter 'Today Bootstrap — Typical Light'
```

The warm host reported ready at 09:20:29 EDT. Latency uses launcher change
detection through the `hot reloaded package preview` event and a visibly
updated native frame.

| Kept revision | Detected | Visible | Latency | Assessment | Result |
| --- | --- | --- | ---: | --- | --- |
| Smaller native action control/font | 09:21:20 | 09:21:30 | 10 s | Excellent | Rendered |
| Restrained final action tonal treatment | 09:22:41 | 09:22:51 | 10 s | Excellent | Rendered |

Reliability: 2/2 kept warm refinements built and rendered. Both repeat below 15
seconds, so the package-backed Simulator preview remains the provisional
Foundry inner loop. The existing incremental Xcode fixture-host build remains
the final capture/verification path.

No dependency, architecture change, runtime connection, or product integration
was introduced for this measurement.
