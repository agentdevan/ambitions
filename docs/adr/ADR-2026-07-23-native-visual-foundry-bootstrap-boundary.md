# ADR-2026-07-23: Native Visual Foundry bootstrap boundary

Status: Accepted for the bounded VC-14 bootstrap

Date: 2026-07-23

## Decision

Add `AmbitionsNativeVisualFoundry` as a library target and product inside the
existing `Packages/AmbitionsPresentation` package. Production-intended SwiftUI
views consume immutable `TodayBootstrapContent` values. Synthetic fixtures
construct those values without importing runtime or legacy app modules.

A later runtime adapter may construct the same value snapshot. That adapter is
not part of this bootstrap, and the value snapshot does not claim live runtime
capability.

## Why this boundary

`AmbitionsPresentation` is already an importable Swift package for presentation
contracts, foundation, and UI. A narrow sibling target isolates the Foundry
without forcing the preview slice into the existing tab-based flagship shell or
the live application dependency graph. It supports package-backed preview
hosting and lightweight Swift tests while leaving the app entry unchanged.

## Rejected alternatives

- Modify the live `Ambitions` application target or app entry: rejected because
  runtime integration and app-entry cutover are unauthorized.
- Reuse or copy legacy frontend views: rejected because legacy source is not
  visual authority and would couple the slice to the cutover path.
- Put the slice in `AmbitionsFlagshipUI`: rejected because its current shell
  includes bottom-tab anatomy that this bootstrap must not inherit.
- Create another Swift package: rejected because the existing presentation
  package already supplies a clean package-backed boundary.
- Create a custom CLI, MCP, hot-injection layer, or snapshot dependency:
  rejected as unnecessary and explicitly outside VC-14 authorization.

## Proof ceiling

Package builds, fixture tests, preview frames, and the fixture-only host can
prove this isolated boundary. They do not prove live data, navigation, dock
expansion, restoration, runtime integration, device accessibility, production
baselines, or owner visual closure.
