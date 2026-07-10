# Article 29 — Frontend architecture

## FRONTEND-001 — View responsibility

SwiftUI Views render projection/presentation state and emit intents. They do not own canonical persistence, networking, planning algorithms, recurrence expansion, event replay, or external writes.

## FRONTEND-002 — Presentation-state ownership

Use:

- `@State` for view-local ephemeral state,
- environment values for stable dependencies,
- scoped observable models for presentation coordination,
- immutable projection models for canonical rendered state.

Duplicated mutable canonical state inside Views is forbidden.

## FRONTEND-003 — Exhaustive state representation

Flagship surfaces, details, sheets, rows, grids, and overlays use exhaustive state models rather than unrelated Boolean combinations that permit impossible UI.

## FRONTEND-004 — Component contracts

Every shared component documents semantic purpose, input model, supported states, accessibility contract, layout behavior, Dynamic Type behavior, motion, tap targets, forbidden uses, and screenshot baseline.

## FRONTEND-005 — Layout law

Owning specifications define supported devices, orientation posture, safe areas, keyboard behavior, scroll ownership, nested-scroll restrictions, sheet behavior, minimum readable widths, and large-content behavior.

## FRONTEND-006 — Navigation identity

Every route defines stable identity, deep-link form, restoration, focus return, missing-object behavior, deleted-object behavior, and conflict/degraded fallback.

## FRONTEND-007 — Body purity

Expensive sorting, recurrence expansion, graph planning, file access, hashing, database queries, and network work are forbidden in SwiftUI `body`.

## FRONTEND-008 — Abstraction threshold

Shared abstraction follows shared semantics, state, accessibility, and lifecycle—not visual similarity alone.

## FRONTEND-009 — Preview matrix

Every flagship surface and stable shared component includes representative previews for empty, populated, dense, extreme text, long localization, light/dark, increased contrast, Reduce Transparency, accessibility text sizes, error/recovery, denied permission, offline/stale, and supported device classes.

## FRONTEND-010 — Asset governance

Prefer SF Symbols where semantically correct. Custom icons and images require ownership, scaling, color-space, accessibility, caching, and dark/OLED review. Rasterized text is forbidden.

---
