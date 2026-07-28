# Validation results

Date: 2026-07-23

Rendered source SHA: `64d1a63954cb1f63c1750f4dd203155989b1b8a1`

Device: VC14 iPhone 17 Pro Simulator, iOS 26.5 (`23F77`),
`EDE1E954-C663-47FB-855B-95F96AE2DBDD`

Toolchain: Xcode 26.6 (`17F113`), Swift 6.3.3

## Native build and test lanes

| Command / lane | Exact fresh outcome |
| --- | --- |
| Foundry target build | PASS — `AmbitionsNativeVisualFoundry` built in 0.33 seconds. |
| Full presentation package tests | PASS — 30 tests, 0 failures: 5 contracts, 4 bootstrap fixtures, 11 calibration fixtures, and 10 journey-state tests. |
| Fixture-host Simulator build | PASS — `BUILD SUCCEEDED` on the named iPhone 17 Pro Simulator. The cached incremental benchmark build was 8.93 seconds. |
| Fixture-host UI suite | PASS — 9 tests, 0 failures in 164.639 seconds; `TEST SUCCEEDED`. |
| SwiftLint changed Swift scope | PASS — 12 files, 0 violations, 0 serious. |
| Package preview | PASS — 4/4 real native hot reloads at approximately 12 seconds; final intended copy visibly restored. |

The UI lane covers standard and accessibility review actions, non-mutating
cancel, history open/return, returned-object uniqueness and focus continuity,
genuine Arabic RTL, low-velocity native scroll evidence, minimum targets,
Adaptive Navigation Passage grouping, and both recovery choices. Xcode emitted
a non-failing local debugger-version snapshot warning; all automation sessions
and assertions completed.

## Canon and repository-quality lanes

| Command / lane | Exact fresh outcome |
| --- | --- |
| Canon build | PASS — 66 documents, 466 requirements, 47 UX screens, 39 visual contracts, 16 local links, 31 JSON files. |
| Canon check | PASS — identical counts and no generated drift. |
| Focused canon/compiler suite | PASS — 44 tests in 11.368 seconds. |
| Local-first boundary scan | PASS — active authority boundary checks green. |
| Runtime direct-write audit | PASS — no unsafe/unknown production rows; 55 classified markers (`preview-only`: 2, `projection-only`: 3, `unproven`: 50). |
| Weak-implementation scan | PASS — no newly introduced weak patterns. |
| Full current-material Gitleaks | PASS — no leaks in 243.98 MB; base-to-branch history also clean. |
| R01→R02 Gitleaks range | PASS — no leaks in the exact range from the R01 HEAD through the final R02 documentation commit. |
| `git diff --check` | PASS — no whitespace errors before evidence commit; repeated on the final staged and committed tree. |

## Media integrity

- Sixteen 1206×2622 Simulator PNGs and three H.264 MOVs exist.
- J01/J02/J03 native AVFoundation durations are 30.255, 21.962, and 27.738
  seconds.
- Complete screenshot and recording contact-sheet review found no obscured
  required text/action or persistent broken transition.
- Production-baseline and direct-device-complete fields are `false`.
- Machine validation matches every PNG/MOV path, byte size, SHA-256, dimension,
  and AVFoundation duration; the comparison manifest contains all 10 required
  R01/R02 pairs.
- Copy inventory validation confirms its six-column contract and 20 mapped
  visible-string rows.

## Authority and changed-path audit

- PASS — active AVF direction IDs are byte-equivalent to R01 and VC-01 through
  VC-14 remain `CLOSED`.
- PASS — `APPROVED FOR SWIFTUI`, broad frontend reconstruction, broad
  production implementation, global implementation, Figma, and legacy cutover
  remain `false`; direct-device proof remains incomplete.
- PASS — no canon/generated authority, production app entry, runtime adapter,
  legacy frontend, dependency resolution, Figma/Code Connect artifact, or
  production screenshot baseline changed.
- PASS — every changed path is inside the existing Foundry source/host/tests,
  R02 plan/evidence, or the R01 owner-decision record.
- PASS — all 16 R01 screenshots and 3 R01 recordings still match their
  historical byte sizes and hashes; only R01 `owner-review.md` changed.

Broad production UI, persistence, migration, privacy, performance, memory, and
full-application suites were not run because R02 did not change those scopes.
Their absence is not presented as proof.
