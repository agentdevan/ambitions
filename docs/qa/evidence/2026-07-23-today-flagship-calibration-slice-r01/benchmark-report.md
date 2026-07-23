# Today calibration warm-loop benchmark

Date: 2026-07-23

View: `TodayFlagshipCalibrationView`

Fixture: `today-flagship/preparing-for-baby/still-counts/v1`

Device: VC14 iPhone 17 Pro Simulator, iOS 26.5 (`23F77`),
`EDE1E954-C663-47FB-855B-95F96AE2DBDD`

Toolchain: Xcode 26.6 (`17F113`), Swift 6.3.3

No `clean` was used and no dependency was installed.

## Path A — package-backed preview hot reload

```sh
node /Users/devan/.codex/plugins/cache/openai-curated-remote/build-ios-apps/0.1.2/skills/ios-simulator-browser/scripts/swiftui-preview-browser.mjs \
  /Users/devan/Documents/GitHub/ambitions/.worktrees/today-flagship-calibration-slice/Packages/AmbitionsPresentation/Package.swift \
  --package-target AmbitionsNativeVisualFoundry \
  --device EDE1E954-C663-47FB-855B-95F96AE2DBDD \
  --preview-filter 'TFCS-F01'
```

The host reported ready at 15:58:58 EDT and rendered a real native F01 frame.
The warm mutation changed the visible present relationship from `Home before
dinner` to `Home before family dinner`, then restored the intended copy.

| Cycle | Detected | Hot swapped | Latency | Result |
| --- | --- | --- | ---: | --- |
| First warm mutation | 15:59:19 | 15:59:35 | 16 s | Rendered |
| Restore | 16:00:16 | 16:00:25 | 9 s | Rendered |
| Repeat mutation | 16:01:00 | 16:01:09 | 9 s | Rendered |
| Final restore | 16:01:47 | 16:01:56 | 9 s | Rendered |

Reliability: 4/4 hot swaps built and rendered in the same preview-host PID
`91591`. Steady-state latency is 9 seconds; assessment: **excellent**. The
intended fixture was visibly restored before shutdown.

## Path B — normal incremental host build/install/launch

The same target and Simulator were used. Measured cached incremental builds were
8.19 and 4.89 seconds. The complete normal build/install/launch command returned
a visible-host launch in 10.58 seconds. A source-changing incremental build
during the safe-area repair measured 12.30 seconds; an earlier less-warm source
change measured 17.98 seconds.

Reliability: all measured commands succeeded. Warm build/install/launch is
excellent; source-changing incremental builds ranged from excellent to strong.

## Selection

Path A remains the default Foundry inner loop because it hot-swaps a real package
preview without host relaunch and repeated at 9 seconds. Path B remains the
capture and final fixture-host verification path. Neither path required product
integration or architecture restructuring.
