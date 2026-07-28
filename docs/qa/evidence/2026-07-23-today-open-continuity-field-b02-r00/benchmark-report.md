# B02 native visual-loop benchmark

Status: `COMPLETE`

Selected loop: package-backed native PreviewHost on the VC14 iPhone 17 Pro
Simulator, iOS 26.5. No InjectionNext or other injection dependency was added.
No benchmark run used `clean`.

## Root composition

| Run | Elapsed | Result | Relaunch | Clean |
| --- | ---: | --- | --- | --- |
| Initial launch | ~100 s | Native frame rendered | initial host | no |
| Warm source change 1 | 36 s | Change visible | no | no |
| Warm source change 2 | 12 s | Change visible | no | no |
| Warm source change 3 | 13 s | Change visible | no | no |
| Warm source change 4 | 11 s | Intended source restored and visible | no | no |

## Focused-object composition

Five source-changing warm reloads completed in 14, 11, 11, 12, and 11 seconds.
All produced real native PreviewHost frames without host relaunch, clean build,
or injection dependency.

## Motion and material composition

| Run | Elapsed | Result | Relaunch | Clean |
| --- | ---: | --- | --- | --- |
| Initial launch | 76 s | Native frame rendered | initial host | no |
| Warm source change 1 | 16 s | Change visible | no | no |
| Warm source change 2 | 13 s | Change visible | no | no |
| Warm source change 3 | 13 s | Change visible | no | no |
| Warm source change 4 | 17 s | Intended source restored and visible | no | no |

The final restored motion-preview hash matched its pre-mutation baseline:
`8e76cdb5bbf7cad7c18901f11e75a9afcc2d560609f784515515c9cb7ca5bab7`.

## Assessment

- Steady-state 11–17 seconds is generally excellent to strong by the VC-14
  latency rubric.
- One 36-second root pass was temporarily acceptable and did not repeat as the
  steady state.
- Initial 76–100-second launches are not the inner loop; a warm host is required.
- Ordinary copy, spacing, state, and motion revisions did not require a clean
  full-app build.
- The provisional default remains the package-backed native preview loop.

## Proof ceiling

These are observed development-loop timings on one host and Simulator. They are
not product performance measurements, direct-device frame pacing, persistence
latency, or a production runtime guarantee.
