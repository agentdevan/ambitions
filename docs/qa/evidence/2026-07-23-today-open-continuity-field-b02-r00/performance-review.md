# B02 SwiftUI performance review

Status: `PROPOSED`

- Scope: fixture-driven `AmbitionsNativeVisualFoundry` journey only
- Baseline: `f38e943b993166ab94ae5ebf71e4e75fbc0cbbd6`
- Toolchain: Xcode 26.6, Swift 6.3.3, iOS 26.5 Simulator

## Audit disposition

| Area | Finding | Disposition |
| --- | --- | --- |
| Observation scope | Journey state is one small value binding; immutable fixture snapshots remain outside live runtime. | Retain. No broad observation architecture added. |
| Stable identity | Step, Goal, Receipt, History, return anchor, timeline rows, and Full Day rows preserve deterministic fixture IDs. | Retain. Tests continue to assert identity continuity and uniqueness. |
| Scroll containers | Root, focus, review, settlement, recovery, and Full Day use native scrolling. Full Day remains the only larger chronology. | Restore native indicators; do not add custom scrolling or snapping. |
| Dense rows | Largest synthetic stress fixture has 10 rows. No stall or hitch was observed. | Keep current row composition; lazy conversion is not justified by evidence. |
| Crown observation | Task 09 clamps crown progress before callback, avoiding repeated saturated updates. | Retain. |
| Timeline evaluation | Task 09 snapshots selected timeline objects once per body evaluation. | Retain. |
| Materials | Primary content is opaque. Functional dock chrome alone uses native glass, with an opaque accessibility branch. | Retain; no custom blur or expensive content material. |
| Animation invalidation | Journey-local motion policy is short, state-bound, and disabled under Reduce Motion. No ambient animation exists. | Retain. |
| Accessibility recomposition | Accessibility 5 increases layout work only through native vertical composition and scrolling. | Accept. No geometry reader or fixed-coordinate workaround added. |
| Tall-device rhythm | The root uses the available viewport as a minimum height and lets its three existing overview rows share remaining semantic-plane space. | Accept. It adds no fixture truth, preserves natural overflow and scrolling, and avoids fixed screenshot coordinates. |
| Compiler performance | Adding announcement and accessibility modifiers to the already-large calibration body caused a demonstrated type-check timeout. | Refactored into `presentedJourney`, `navigationRoot`, `destination(for:)`, and `reconcileNativeBack` without semantic change. Package target then built in 13.28 seconds. |

## Rendering observations

- The package-backed host and fixture host rendered Accessibility 5,
  long-English LTR, Increased Contrast, Differentiate Without Color, Reduce
  Transparency, compact iPhone, standard Pro, and Pro Max without visible
  scrolling stalls or delayed material resolution.
- Changing Simulator content size and contrast required no clean build.
- Compact and Pro Max reused the same built host artifact; no device-specific
  source path or fixed screenshot coordinate was introduced.
- Restoring native scroll indicators adds no custom animation or layout loop.

## Targeted profiling decision

- ETTrace was not run. The Simulator and package-preview passes showed no hitch,
  scrolling stall, unexpected invalidation, or animation symptom that would make
  a trace actionable.
- Memgraph was not run. The fixture journey uses bounded immutable values and
  showed no suspicious growth, retention, or repeated-host symptom.
- Both tools remain available if a later complete recording or direct-device run
  exhibits a reproducible symptom. Skipping them is not a claim of production
  performance closure.

## Validation

- `swift build --package-path Packages/AmbitionsPresentation --target AmbitionsNativeVisualFoundry`: PASS after the bounded compiler refactor, 13.28 seconds.
- `testB02AccessibilityAndAdaptivityMatrix`: PASS, 1 test, 365.934 seconds on
  the final fresh rerun (439.099 seconds including build/test orchestration).
- `swift test --package-path Packages/AmbitionsPresentation`: PASS, 49 tests.
- Foundry host Simulator build: PASS, `** BUILD SUCCEEDED **`; fresh log:
  `/tmp/b02-task10-final-host-build-20260725.log`.
- Strict SwiftLint across all 16 changed Swift files: PASS, 0 violations;
  fresh log: `/tmp/b02-task10-final-swiftlint-scope-20260725.log`.
- `git diff --check`: PASS.

## Proof ceiling

This audit supports the bounded fixture-host composition only. It does not prove
physical-device frame pacing, thermal behavior, memory lifetime under runtime
data, production persistence, or broad frontend performance. No ETTrace or
memgraph claim is made, and `APPROVED FOR SWIFTUI` remains false.

## Owner evidence override

The earlier Arabic/RTL diagnostic run remains historical implementation evidence
only. It is excluded from the final English-only B02 matrix and no RTL or
localization proof claim is made. Long-English LTR is the final content-expansion
stress; RTL and localization remain open.
