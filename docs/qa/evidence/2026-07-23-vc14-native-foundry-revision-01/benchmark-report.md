# Native Visual Foundry revision warm-loop measurement

Date: 2026-07-23

View: `TodayBootstrapView`

Fixture: `today-bootstrap/preparing-for-baby/typical/v1`

Device: iPhone 17 Pro Simulator, iOS 26.5 (`23F77`),
`EDE1E954-C663-47FB-855B-95F96AE2DBDD`

Toolchain: Xcode 26.6 (`17F113`), Swift 6.3.3

The existing Path A package-backed Simulator preview launcher was warmed before
measurement. No `clean` was used. The module boundary, preview filter, and
hot-reload workflow were unchanged.

Command:

```sh
node /Users/devan/.codex/plugins/cache/openai-curated-remote/build-ios-apps/0.1.2/skills/ios-simulator-browser/scripts/swiftui-preview-browser.mjs \
  Packages/AmbitionsPresentation/Package.swift \
  --package-target AmbitionsNativeVisualFoundry \
  --device EDE1E954-C663-47FB-855B-95F96AE2DBDD \
  --preview-filter 'Today Bootstrap — Typical Light'
```

The warm host was ready at 08:31:14 EDT. Measurements use launcher source-change
detection through the `hot-reloaded` event and a visibly updated native frame.

| Kept refinement | Detected | Visible | Latency | Assessment | Result |
| --- | --- | --- | ---: | --- | --- |
| Timeline semantic spacing 20 → 22 | 08:32:14 | 08:32:28 | 14 s | Excellent | Rendered |
| Confirming spacing 22 → 24 | 08:33:00 | 08:33:11 | 11 s | Excellent | Rendered |

Reliability: 2/2 warm revision reloads built and rendered. The 24-point value
from the confirming reload is the intended final state. The apparently fastest
path therefore repeated below 15 seconds, preserving the original benchmark's
selection of package-backed Simulator preview hot reload as the provisional
Foundry inner loop.

The normal incremental Xcode host build remained the capture/verification path
and completed successfully after the revision. This measurement adds no new
dependency, architecture change, runtime connection, or product integration.
