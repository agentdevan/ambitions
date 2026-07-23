# Validation results

Date: 2026-07-23

Implementation SHA: `1b2e0f5b4e92735aadcf91e4d92d10fd3620f8fe`

Device: VC14 iPhone 17 Pro Simulator, iOS 26.5 (`23F77`),
`EDE1E954-C663-47FB-855B-95F96AE2DBDD`

Toolchain: Xcode 26.6 (`17F113`), Swift 6.3.3

## Native build and test lanes

| Command / lane | Exact outcome |
| --- | --- |
| `swift build --package-path Packages/AmbitionsPresentation --target AmbitionsNativeVisualFoundry` | PASS — final post-repair target build completed in 4.86 seconds. |
| `swift test --package-path Packages/AmbitionsPresentation` | PASS — 25 tests, 0 failures: 5 presentation contracts, 4 bootstrap fixtures, 7 calibration fixtures, 9 journey-state tests. |
| `xcodegen generate` | PASS — project regenerated from `project.yml`; no hand-edited project state. |
| Foundry-host Simulator build | PASS — `** BUILD SUCCEEDED **` on the named iPhone 17 Pro Simulator, including a final post-repair compile. |
| Focused Foundry-host UI suite | PASS — 4 tests, 0 failures in 108.179 seconds; `** TEST SUCCEEDED **`. |
| Package-backed preview render | PASS — a real native `TFCS-F01` frame rendered; four warm mutations rendered in the same preview-host process. |

The UI suite proves adaptive navigation and recovery choices, a real dense
Today scroll with crown/dock continuity, non-mutating cancellation followed by
the complete Still counts settlement/return, semantic order, native Step entry,
and minimum target sizing. Xcode emitted a non-failing local debugger-version
snapshot warning during UI launches; all automation sessions and assertions
completed successfully.

## Canon and repository-quality lanes

| Command / lane | Exact outcome |
| --- | --- |
| `python3 scripts/ambitions-canon.py build` | PASS — 66 documents, 466 requirements, 47 UX screens, 39 visual contracts, 16 local links, 28 JSON files. |
| `python3 scripts/ambitions-canon.py check` | PASS — the same counts; no generated-output drift. |
| Canon compiler unit suite | PASS — 44 tests in 16.105 seconds. |
| SwiftLint strict on all 14 changed Swift files | PASS — 0 violations, 0 serious. |
| Local-first boundary scan | PASS — active authority boundary checks green. |
| Runtime direct-write audit | PASS — no unsafe/unknown production rows; 55 classified markers (`preview-only`: 2, `projection-only`: 3, `unproven`: 50). |
| Weak-implementation scan | PASS after one focused repair — no newly introduced weak patterns. |
| Full Gitleaks scan | PASS — no leaks in 233.13 MB current repository material or the two-commit introduced range from the base. |
| `git diff --check` | PASS — no whitespace errors. |

The first weak-implementation run reported three `.disabled(...)` SwiftUI
interaction guards as disabled-test markers. These were native guards for
object recovery, duplicate recovery presentation, and post-commit
cancellation—not skipped tests. The repository's concrete
`AMBitionsAllowWeakPattern` classification was added at those exact lines. The
focused SwiftLint, weak scan, Foundry build, full package tests, and host build
then passed without changing rendered behavior.

## Media integrity

- Screenshot metadata JSON parses and asserts schema 1, fixture family,
  production-baseline `false`, and direct-device proof `false`.
- All 10 matched frames and all 6 supporting frames exist and match recorded
  byte size, SHA-256, and 1206×2622 dimensions exactly.
- Journey metadata JSON parses and asserts schema 1, the same fixture family,
  three recordings, production-baseline `false`, and direct-device proof
  `false`.
- `TFCS-J01`, `J02`, and `J03` match byte size and SHA-256 exactly. Native
  AVFoundation reports 19.498, 20.572, and 19.590 seconds respectively, matching
  metadata within the 0.02-second tolerance.
- Manual contact-sheet inspection found no text or required control obscured by
  the crown, dock, safe area, or another control. Natural scroll continuation
  is also exercised by screenshot, recording, and UI-test evidence.

## Authority and changed-path audit

- PASS — active AVF baseline and VC-14 direction IDs equal the starting commit.
- PASS — VC-01 through VC-14 remain `CLOSED`; the visual-closure planning
  program remains closed.
- PASS — Figma, SwiftUI, implementation, broad production implementation,
  broad frontend reconstruction, and legacy cutover authorizations remain
  `false`.
- PASS — Today flagship calibration authorization remains narrow and `true`;
  direct-device proof remains required and incomplete.
- PASS — no canon, generated authority, production app entry, runtime adapter,
  legacy frontend, dependency manifest, Figma, Code Connect, or production
  screenshot-baseline path changed.
- PASS — every changed path conforms to the Foundry host/package/test, evidence,
  plan, and `project.yml` allowlist.

Broad UI, production runtime, persistence, migration, privacy, performance,
memory, and full-application suites were not run because those surfaces were
not changed. Their absence is not presented as proof. Final branch cleanliness
and the evidence-commit SHA are verified and reported at handoff.
