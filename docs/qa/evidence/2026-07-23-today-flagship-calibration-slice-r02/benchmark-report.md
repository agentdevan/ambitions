# R02 warm-loop benchmark

Date: 2026-07-23

Preview: `TFCS-F01`

Fixture: `today-flagship/preparing-for-baby/still-counts/v1`

Device: VC14 iPhone 17 Pro Simulator, iOS 26.5 (`23F77`),
`EDE1E954-C663-47FB-855B-95F96AE2DBDD`

Toolchain: Xcode 26.6 (`17F113`), Swift 6.3.3

No clean build, injection dependency, or architecture change was used.

## Package-backed Path A

The existing preview browser built the host, launched F01, and reported ready at
18:20:06 EDT. The temporary visible copy mutation toggled “Home before dinner”
and “Home before family dinner”; the intended copy was restored and visually
verified before shutdown.

| Cycle | Save | Detected | Visible hot reload | Save-to-visible | Result |
| --- | --- | --- | --- | ---: | --- |
| First source-changing run | 18:20:23 | 18:20:27 | 18:20:35 | ~12 s | Rendered |
| Warm run 1 / restore | 18:21:05 | 18:21:10 | 18:21:17 | ~12 s | Rendered |
| Warm run 2 | 18:21:48 | 18:21:54 | 18:22:00 | ~12 s | Rendered |
| Warm run 3 / final restore | 18:22:31 | 18:22:37 | 18:22:43 | ~12 s | Rendered |

Reliability: 4/4 changes built and appeared in preview-host PID `29892` without
a clean build or host restart. Assessment: **excellent** (under 15 seconds).
The R01 steady-state was 9 seconds; the 12-second R02 result is not a material
regression and no three-run stop-loss triggered.

## Cached fixture-host path

A cached incremental Simulator build completed with `BUILD SUCCEEDED` in 8.93
seconds. This path remains the capture/final host verification path.

## Selection

Package-backed hot reload remains the default native visual loop. The normal
fixture-host build remains the deterministic screenshot, recording, and UI-test
path. No dependency was installed.
