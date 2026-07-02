# Architecture Remediation Owner Map

Status: AMB-1657 evidence baseline

Snapshot date: 2026-07-02

Repo state: `0055a18a1fab4d2c62d6dc73bf7597e630d07b8e` on `main`

This owner map is a static source map. It does not move ownership, prove
runtime authority, or close architecture debt. It exists so later remediation
can follow law over lore, deep runtime with boring UI, and delete before naming.

## Canonical Owner Counts

`docs/truth/PRODUCT_DESIGN_TRUTH.md` defines the final architecture tree. The
current `Native/Ambitions` top-level source roots are aligned to those canonical
owner names. Pressure remains inside those roots.

| Canonical owner | Tracked files | Swift files | Swift LOC |
| --- | ---: | ---: | ---: |
| `App` | 40 | 39 | 4893 |
| `Stage` | 57 | 57 | 6238 |
| `Core` | 724 | 722 | 151098 |
| `Projection` | 174 | 174 | 34094 |
| `Language` | 10 | 10 | 589 |
| `Trust` | 15 | 15 | 1591 |
| `Interaction` | 8 | 8 | 729 |
| `Rendering` | 10 | 10 | 697 |
| `DesignSystem` | 98 | 98 | 12556 |
| `Surfaces` | 72 | 72 | 12182 |
| `Composer` | 16 | 16 | 2669 |
| `Scenarios` | 38 | 38 | 3407 |
| `Diagnostics` | 6 | 6 | 369 |
| `Quality` | 42 | 42 | 2554 |

Observed noncanonical `Native/Ambitions` top-level implementation directories:
none, excluding `Resources`, `Support`, and `PreviewSupport`.

## Core Internal Ownership Pressure

`Core/LocalRuntimeOS` is the canonical backend/runtime authority owner for new
runtime work. `Core/Runtime` and `Core/Persistence` are implementation
scaffolding and migration debt when touched by future source trains.

| `Native/Ambitions/Core` child | Tracked files | Swift files | Swift LOC | Baseline note |
| --- | ---: | ---: | ---: | --- |
| `Domain` | 225 | 223 | 50987 | High model/concept density; inspect before naming new laws. |
| `LocalRuntimeOS` | 329 | 329 | 64459 | Canonical runtime authority home; future work must preserve Command -> Event -> Projection -> Receipt -> Replay. |
| `Permissions` | 13 | 13 | 2211 | Platform boundary; later work needs platform proof. |
| `Persistence` | 34 | 34 | 7485 | Migration debt when touched; contains SwiftData repository candidates. |
| `Runtime` | 115 | 115 | 25514 | Migration debt when touched; contains broad service/projector/engine vocabulary. |
| `Time` | 8 | 8 | 442 | Low-count support area. |

## Projection Internal Ownership Pressure

Projection is canonical, but future migrations need to prevent projection,
external snapshot, and mutation concerns from becoming competing runtime
authority.

| `Native/Ambitions/Projection` child | Tracked files | Swift files | Swift LOC | Baseline note |
| --- | ---: | ---: | ---: | --- |
| `ExternalSnapshots` | 11 | 11 | 2828 | Shared with widget/share targets; inspect mutation and receipt boundaries before changes. |
| `Mutations` | 15 | 15 | 1792 | Needs later authority review against runtime mutation law. |
| `OverlayLenses` | 4 | 4 | 161 | Low-count projection support. |
| `OverlayScenes` | 4 | 4 | 158 | Low-count projection support. |
| `StageMotionProjection.swift` | 1 | 1 | 26 | Single-file projection bridge. |
| `StageScenes` | 4 | 4 | 228 | Low-count projection support. |
| `SurfaceLenses` | 135 | 135 | 28901 | Large projection concentration; later source migrations should avoid adding more broad lens authority without deletion/collapse. |

## Product Surface Ownership

The top-level product surface contract remains Today / Goals / Time / You, with
global Capture and Motion as behavior. This map does not change user-facing
surface canon.

| Owner area | Files | Swift files | Swift LOC | Baseline note |
| --- | ---: | ---: | ---: | --- |
| `Native/Ambitions/Surfaces/Today` | 9 | 9 | 1090 | Persistent surface owner. |
| `Native/Ambitions/Surfaces/Goals` | 17 | 17 | 3730 | Persistent surface owner. |
| `Native/Ambitions/Surfaces/Time` | 12 | 12 | 1567 | Persistent surface owner. |
| `Native/Ambitions/Surfaces/You` | 25 | 25 | 5140 | Persistent surface owner. |
| `Native/Ambitions/Composer/Capture` | 16 | 16 | 2669 | Global Capture owner. |
| `Native/Ambitions/Stage/Motion` | 9 | 9 | 751 | Motion behavior owner. |

## Extension And Package Ownership

These roots are outside the `Native/Ambitions` final tree, but they participate
in build or external-surface behavior and must stay visible in later source
migration planning.

| Root | Swift files | Swift LOC | Baseline note |
| --- | ---: | ---: | --- |
| `Native/AmbitionsWidgetExtension` | 3 | 503 | Widget target; shares selected `Projection/ExternalSnapshots` files through XcodeGen. |
| `Native/AmbitionsShareExtension` | 2 | 277 | Share extension target; shares selected `Projection/ExternalSnapshots` files through XcodeGen. |
| `Sources` | 111 | 25091 | Root package product `AmbitionsDesignSystem`; package owner still needs governance clarity before any movement. |
| `AppUI/Sources` | 7 | 1651 | Root package product `AmbitionsWidgetUI`; depends on `AmbitionsDesignSystem`. |
| `Packages/AmbitionsExperienceKernel/Sources` | 15 | 1446 | Separate local package used by app target. |

## Owner Map Closeout Boundary

- Final Architecture Tree inspected: yes, through `PRODUCT_DESIGN_TRUTH.md` and `scripts/ambitions-architecture-inventory.py --json`.
- Canonical owners touched: docs only; no Swift owner was modified.
- Files moved or created in source: none.
- Old/noncanonical source paths removed: none.
- Compatibility shims left behind: none added by this slice.
- Yellow architecture debt remains in `Core/Runtime`, `Core/Persistence`, direct-write candidates, split-file pressure, and external-snapshot mutation candidates.
- Next repair train: AMB-1658 governance rules, followed by runtime authority map work before source migration parents.
- No equivalent folder/path interpretation was used.
