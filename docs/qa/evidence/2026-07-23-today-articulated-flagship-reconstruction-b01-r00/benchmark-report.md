# Native Foundry warm-loop benchmark

Device: VC14 iPhone 17 Pro Simulator, iOS 26.5 (`23F77`)

Path: package-backed `AmbitionsNativeVisualFoundry` preview through the existing
`ios-simulator-browser` workflow. No injection dependency and no clean build
were used.

| Phase | Run | Save-to-visible result | Result |
| --- | ---: | ---: | --- |
| Root composition | initial | 22 s | PASS |
| Root composition | warm 1 | 13 s | PASS |
| Root composition | warm 2 | 19 s | PASS |
| Root composition | warm 3 | 19 s | PASS |
| Root composition | warm 4 | 14 s | PASS |
| Deeper journey | warm 1 | 11 s | PASS |
| Deeper journey | warm 2 | 7 s | PASS |
| Deeper journey | warm 3 | 7 s | PASS |
| Deeper journey | warm 4 | 8 s | PASS |

All eight source-changing warm runs rendered the intended native change. The
host did not require a clean rebuild. The final cached fixture-host build took
6 seconds. Package preview remains the selected default inner loop; the warm
deeper median is 7.5 seconds and therefore excellent under the locked latency
assessment.

One pair of root observations overlapped while the preview browser settled;
they are retained as observed rather than normalized away. There were no three
consecutive regressions above the R02 steady-state range.
