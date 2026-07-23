# VC-14 Native Visual Foundry bootstrap evidence

Date: 2026-07-23

Status: Ready for owner visual review; not owner-approved

Authority: `VC14-NATIVE-S01 — Matched Native Flagship Proof`

Fixture: `today-bootstrap/preparing-for-baby/typical/v1`

All fixture copy is synthetic evaluation content, not canon. The screenshots in
this packet are evaluation references, not final production screenshot
baselines.

## Preserve exactly

- Native SwiftUI and the running native application remain the primary visual
  proving environments.
- Today remains the primary path, with a compact semantic crown, one dominant
  Start Here identity, matte primary content, natural vertical scrolling, and a
  Crowned Edge Dock in ordinary Peek posture.
- System typography, native button behavior, safe-area behavior, semantic
  accessibility, and an opaque Reduce Transparency dock equivalent remain
  native defaults or explicit requirements.
- Figma is optional comparison material only. Legacy frontend views are not
  visual authority.

## Changed

- Installed the final VC-14 human/machine authority and compiler projection.
- Added one fixture-driven, production-intended Today composition in the
  existing `AmbitionsPresentation` Swift package.
- Added a fixture-only Simulator host, three preview variants, one local
  orchestration skill, and this evaluation packet.

## Removed

Nothing was removed from the live application, legacy frontend, runtime, or
dependency graph. Benchmark-only copy, spacing, typography, tonal, and
conditional-state mutations were restored before capture.

## Added

- `AmbitionsNativeVisualFoundry` package product and target
- `AmbitionsNativeFoundryHost` fixture-only iOS target and scheme
- `ambitions-native-visual-foundry` repository-local skill
- Typical Light, Typical Dark, and Accessibility Dynamic Type Dark frames
- Warm-loop benchmark and machine-readable screenshot metadata

## Unresolved

- Owner visual acceptance is pending for all three frames.
- Direct-device proof is required by VC-14 and remains incomplete.
- Navigation, expanded dock behavior, Search, Capture, keyboard, restoration,
  sheets, runtime adapters, and consequential review remain outside this proof.
- XcodeBuildMCP could not establish a session because its transport closed; the
  non-invasive incremental Xcode/Simulator path was measured through
  `xcodebuild` and `simctl` instead.

## Architecture-sensitive assumptions

- Immutable `TodayBootstrapContent` values are the adapter seam: a later
  runtime adapter may construct the same snapshot without changing the view's
  semantic contract.
- The sibling package target is intentionally isolated from
  `AmbitionsFlagshipUI`, the live app entry, and legacy frontend code.
- Empty host closures demonstrate native control rendering only; they do not
  claim navigation or runtime capability.
- The dedicated host is QA infrastructure. It is not an alternate product
  entry point and is not a dependency of the live `Ambitions` target.

## Validation

Final command outcomes are recorded in `validation.md`. The scoped package
build/tests, fixture-only host build, canon build/check, compiler tests,
render verification, diff hygiene, and changed-path audit are the applicable
proof lanes.

## Evidence

| Variant | Appearance | Dynamic Type | Screenshot |
| --- | --- | --- | --- |
| Today Bootstrap — Typical Light | Light | Large | `screens/today-bootstrap-typical-light.png` |
| Today Bootstrap — Typical Dark | Dark | Large | `screens/today-bootstrap-typical-dark.png` |
| Today Bootstrap — Accessibility Dynamic Type Dark | Dark | Accessibility 1 | `screens/today-bootstrap-accessibility-dynamic-type-dark.png` |

Device: iPhone 17 Pro Max Simulator

UDID: `DD9B9C84-7188-48FA-AA2A-AB5C1D0EE2B6`

Runtime: iOS 26.5 (`23F77`)

Toolchain: Xcode 26.6 (`17F113`), Swift 6.3.3

Accessibility settings: appearance and Dynamic Type are explicitly overridden
per variant. Reduce Motion and Grayscale are off in the Simulator. Increased
Contrast, Reduce Transparency, and VoiceOver were not explicitly enabled.

See `screenshot-metadata.json` for dimensions, byte sizes, and SHA-256 digests,
and `benchmark-report.md` for exact paths and latency observations.

### Changed-file groups

- Authority and plan: VC-14 human/machine records, Visual System, input
  contract, canon manifests/readmes, UX Blueprint projections, and the bounded
  execution plan.
- Compiler and tests: `tools/ambitions_canon/compiler.py`, focused compiler
  tests, and generated canon projections.
- Skill: `.agents/skills/ambitions-native-visual-foundry/SKILL.md` and its
  validation record.
- Foundry boundary: the `AmbitionsNativeVisualFoundry` product/target, immutable
  content, fixture, focused tests, and boundary ADR.
- Preview proof: Today view/previews, fixture-only host, `project.yml`, this
  manifest, benchmark/validation records, screenshot metadata, and three PNGs.

The final changed-path audit in `validation.md` is authoritative for the exact
base-to-branch file list.

## Proof ceiling

This packet proves that one fixture-driven, production-intended Today slice can
build and render as three real native Simulator frames and can iterate through
two warm native loops. It does not prove owner closure, direct-device behavior,
live data, runtime integration, navigation, full-app accessibility, final
tokens/components, production screenshot baselines, the eight-frame matrix, or
the complete Today calibration journey.

Stop here for owner visual review.
