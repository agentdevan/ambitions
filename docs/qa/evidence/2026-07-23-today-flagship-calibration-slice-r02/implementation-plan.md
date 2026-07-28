# R02 implementation plan

The executed internal plan is preserved at
`docs/superpowers/plans/2026-07-23-today-flagship-calibration-slice-r02.md`.

## Changed boundary

- Existing `AmbitionsNativeVisualFoundry` source and immutable snapshots
- Existing fixture-host variants and semantic walkthroughs
- Existing package tests and fixture-host UI tests
- R01 owner-decision record and new R02 evidence package

## Reused primitives

`NavigationStack`, full-screen review presentation, native recovery sheet,
`DisclosureGroup`, semantic typography/colors, local matte seams, existing dock,
existing Adaptive Navigation Passage, and existing accessibility focus anchors.

## State and flow

No state-machine branch changed. R02 added only history-disclosure UI state. The
successful and interrupted R01 sequences remain intact, and the returned Today
projection now omits the promoted object from the visible timeline.

## Evidence outputs

Sixteen 1206×2622 PNGs, three H.264 Simulator MOVs, R01/R02 comparison hashes,
warm-loop timings, metadata, and validation results.

## Non-goals

No new direction, outcome journey, shell/root design, runtime adapter, product
entry, legacy code, dependency, localization infrastructure, snapshot testing,
or production baseline.
