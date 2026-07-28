# B02 validation results

Status: `PASS — FINAL FRESH VERIFICATION`

This record separates already observed phase results from the required final
branch-closeout run. A phase pass is not substituted for fresh final evidence.

## Most recent observed changed-scope results

| Check | Observed result | Scope / qualification |
| --- | --- | --- |
| Foundry package tests | PASS, 49 tests | Fresh Task 10 suite before final regression/evidence changes |
| Accessibility/adaptivity UI matrix | PASS, 1 test, 365.934 s test time; 439.099 s orchestration | VC14 iPhone 17 Pro, iOS 26.5 |
| Fixture-host Simulator build | PASS, `** BUILD SUCCEEDED **` | Task 10 final host build |
| SwiftLint | PASS, 0 violations | All 16 Swift paths changed through Task 10 |
| `git diff --check` | PASS | Task 10 final state |
| Package-preview hot reload | PASS | Root, focus, and motion/material warm-loop sets; no clean build |
| Compact / Pro / Pro Max native render | PASS | Same Foundry contract on iOS 26.5 |
| Accessibility 5 / long-English LTR / contrast / no-color / opaque chrome | PASS in Simulator evidence | Does not close physical accessibility proof |
| Task 11 package guards | PASS, 50 tests | Commit `133c040e5` |
| Task 11 recording drivers | PASS, 5 English-only drivers | Five continuous Simulator recordings captured and validated |
| Task 11 recovery target guards | PASS, 2 focused tests | Rendered controls retain at least 44 points |

## Final required run

| Check | Final result |
| --- | --- |
| Foundry target build | PASS, `Build of target: AmbitionsNativeVisualFoundry complete` |
| Full package tests and fixture tests | PASS, 50 tests, 0 failures |
| Fixture-host Simulator build | PASS, `** BUILD SUCCEEDED **` on B02 Recording iPhone 17 Pro |
| English-only fixture-host UI suite and B02-specific tests | PASS, 33 tests, 0 failures, 823.675 s |
| SwiftLint across final changed Swift paths | PASS, 0 violations across 24 files |
| Canon build/check and focused canon/compiler tests | PASS, build/check plus 44 tests |
| Boundary scan | PASS, GREEN local-first boundary |
| Direct-write audit | PASS, GREEN; no unsafe or unknown production rows |
| Weak-implementation scan | PASS after removing one unfinished evidence-wording hit; no implementation finding |
| Full current-material Gitleaks scan | PASS, 264.28 MB scanned, no leaks |
| B01-to-B02 range Gitleaks scan | PASS, 13 commits scanned, no leaks |
| Screenshot metadata validation | PASS, 25/25 paths, hashes, sizes, dimensions |
| Recording metadata validation | PASS, 5/5 paths, hashes, sizes |
| Comparison metadata validation | PASS, 4/4 paths, hashes, sizes, dimensions |
| Reference-hash validation | PASS, owner reference and B01 matrix hashes unchanged |
| Changed-path and authority audits | PASS, Foundry/evidence scope only; authority state unchanged |
| `git diff --check` | PASS |
| Final clean working tree | Rechecked after the final commits and reported in the handoff |

Final media validation rejected Arabic/RTL artifacts from the B02 screenshot,
recording, and contact-sheet inventories. Historical diagnostic source and
repository history remain intact but are not referenced as final proof.

## Authority assertions requiring final audit

- Active canon and VC-01 through VC-14 authority unchanged.
- B02 did not modify, merge into, or push `main`. The verified B02 starting
  baseline was `f2781053d1ffcf962f112014b37d916bd677c450`; local `main` and
  `origin/main` later advanced externally to
  `5670f24fb82adefd27cffee5ddf8fb70676ed049` during this execution.
- No generated canon, production app entry, runtime adapter, legacy frontend,
  dependency resolution, Figma, Code Connect, or production screenshot baseline
  changed.
- Broad reconstruction and runtime integration authorizations remain false.
- `APPROVED FOR SWIFTUI` remains false.

## Recording verification

The five XCUI drivers passed independently and again in the 33-test English-only
suite. `simctl recordVideo` captured the native Foundry-host framebuffer on a
fresh iPhone 17 Pro Simulator. AVFoundation passthrough trimming removed only
Simulator pre-roll and post-test Home frames. Five samples from each final movie
were inspected to confirm the intended native states and to reject stale Home
or live-app frames.

Two discarded capture attempts are recorded as reliability evidence: an
unthrottled screenshot sampler starved XCTest, and a reused Simulator developed
an accessibility-daemon timeout. Neither invalid artifact entered the evidence
package. The fresh dedicated recording Simulator and warm UI drivers were
repeatable.

Final independent review also detected a post-test Home transition at the tail
of J03, J04, and J05. The three files were retrimmed without changing journey
content, and durations, hashes, and metadata were regenerated. Fresh samples at
99 percent of each revised duration show the intended Foundry-host state. This
repair changed evaluation media only; it did not change Swift source or the
rendered-source SHA.

## Proof ceiling

Passing builds and tests support the bounded fixture-driven Foundry branch only.
They do not constitute visual acceptance, direct-device proof, production
runtime proof, or authorization to merge, push, reconstruct broadly, or cut over.
