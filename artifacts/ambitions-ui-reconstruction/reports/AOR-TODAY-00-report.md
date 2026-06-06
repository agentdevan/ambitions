# AOR-TODAY-00 Today Runtime Path and Red Baseline

Issue: AMB-531
Date: 2026-06-06
Scope: Evidence-first Today runtime audit and before screenshot capture. No UI reconstruction.
Status: Green for audit completion. Visual/product quality remains Red baseline for future Today reconstruction.

## Truth Boundary

Active IA remains `Today / Goals / Time / Motion / You` with global `Capture`.
This issue did not change UI source, tab IA, Capture routing, runtime behavior, screenshot baselines beyond refreshing the required before artifact, accessibility behavior, performance, or release posture.

## Commands Run

```bash
rg -n "Today keeps one important step|Reality Meridian continuity|Start Here emerges from the active Meridian node|Manual fallback stays available|Freshness stays visible|On device" Native Sources --glob "*.swift"
rg -n "Reality Meridian|RealityMeridian|Start Here|Start here|Now|Next|Later|Source|Freshness|Manual fallback|On device|timeline|Timeline|Today title|toolbar|ToolbarItem|showsNavigationChrome" Native/Ambitions/Features/Today Sources --glob "*.swift"
rg -n "On-device|On device|on-device" Native Sources --glob "*.swift"
xcrun simctl list devices booted
xcrun simctl install booted .codex/DerivedData/Ambitions/Build/Products/Debug-iphonesimulator/Ambitions.app
xcrun simctl launch booted com.ambitions.ios --args -AmbitionsInitialSurface today -AmbitionsScreenshotMode YES
xcrun simctl io booted screenshot artifacts/ambitions-ui-reconstruction/screenshots/today-default-before.png
sips -g pixelWidth -g pixelHeight artifacts/ambitions-ui-reconstruction/screenshots/today-default-before.png
```

## Required Screenshot

Captured current before screenshot:

- `artifacts/ambitions-ui-reconstruction/screenshots/today-default-before.png`
- Simulator: booted `iPhone 17e` from `xcrun simctl list devices booted`
- Size: 1170 x 2532
- Launch args: `-AmbitionsInitialSurface today -AmbitionsScreenshotMode YES`

Visual proof boundary: screenshot is evidence of the current Red baseline, not approval.

## Active Runtime Path

| Runtime layer | Evidence | Classification |
| --- | --- | --- |
| App root shell | `Native/Ambitions/App/AmbitionsRootView.swift:35-39` mounts `shellTabView`, activated Capture seam, and continuity receipt. | Active shell |
| Today tab route | `Native/Ambitions/App/AmbitionsRootView.swift:91-111` defines only Today, Goals, Time, Motion, You in `TabView`; `:143-152` wraps `TodayScreen(showsNavigationChrome: false)` in `AppShellScaffold(title: "Today")`. | Active path, no Capture tab |
| Shell status ribbon | `Native/Ambitions/App/AppShellView.swift:51-64` defines `Today keeps one important step in view.`; `:154-160` renders `headerRow`, `continuityRibbon`, and divider. | Active shell chrome |
| Today root | `Native/Ambitions/Features/Today/TodayScreen.swift:28-33` creates `ZStack`, `TodayBackgroundView`, `ScrollView`, and `LazyVStack`; `:50-71` renders `RealityMeridianView(...).fusedCurrentTimeCursor()`. | Active feature root |
| Today local toolbar compatibility | `Native/Ambitions/Features/Today/TodayScreen.swift:99-111` conditionally defines a local Capture toolbar when `showsNavigationChrome` is true. Active shell passes false at `AmbitionsRootView.swift:151`, so this is not active root chrome. | Inactive shell / compatibility path |
| Reality Meridian view | `Native/Ambitions/Features/Today/TodayDayRailPanels.swift:4-34` maps `RealityMeridianView` to `AmbitionsDayRailView`; `:61-107` builds the main rail surface. | Active primary object |
| Fused time cursor | `Native/Ambitions/Features/Today/TodayDayRailCurrentTimeFusion.swift:4-8` adds `.fusedCurrentTimeCursor()`; `:17-31` stacks `RealityMeridianTimeBand` over the rail and overlays `RealityMeridianCurrentTimeCursor`. | Active local styling override |
| Topology/prose panel | `Native/Ambitions/Features/Today/TodayRealityMeridianTopology.swift:11-21` renders continuity title and summary; `:23-86` renders Start here, Now, Next, Later, Source, Freshness, Closure, Proof, and Pressure badges. | Active card-stack layout |
| Topology source data | `Native/Ambitions/Features/Today/DayRailProjection.swift:356-428` builds `DayRailContinuityState` with title `Reality Meridian continuity` and summary `Start Here emerges...`. | Active runtime content projection |

## Exact String Trace

| String | Source |
| --- | --- |
| `Today keeps one important step in view.` | `Native/Ambitions/App/AppShellView.swift:54` |
| `Reality Meridian continuity` | `Native/Ambitions/Features/Today/DayRailProjection.swift:423`; tests also assert this copy. |
| `Start Here emerges from the active Meridian node...` | `Native/Ambitions/Features/Today/DayRailProjection.swift:424`; rendered by `TodayRealityMeridianTopology.swift:17`. |
| `Manual fallback stays available.` | `Native/Ambitions/Features/Today/DayRailProjection.swift:371` and `TodayRealityMeridianTopology.swift:32`; screenshot shows it in Start here topology badge. |
| `Freshness stays visible` | `Native/Ambitions/Features/Today/TodayRealityMeridianTopology.swift:65` and `:123`; screenshot shows Freshness badge clipped low in first viewport. |
| `On-device` | The exact required search found preview-only `Sources/Previews/TrustReceiptLayerPreviews.swift:84`; the broader trace found the visible Today badge in `Native/Ambitions/Features/Today/TodayDayRailPanels.swift:230` with accessibility label at `:239`. |

## Red Baseline Classification

| Visible Today failure | Screenshot evidence | Source trace | Required classification |
| --- | --- | --- | --- |
| Detached toolbar icons float above status ribbon | Two circular buttons appear at the upper right before the ribbon. | Shared shell utility buttons at `AmbitionsRootView.swift:293-312`; header rendering at `AppShellView.swift:237-260`. | Detached toolbar icons; active shell |
| Large shell status ribbon consumes first viewport | Ribbon reads `Today keeps one important step in view.` above the primary object. | `AppShellView.swift:51-64` and `:154-160`. | Active shell status ribbon |
| Timeline/time-band card appears as first large object | Screenshot begins the content with a 6 AM to 9 PM band and current-time marker. | `TodayDayRailCurrentTimeFusion.swift:17-31`; `Sources/Components/RealityMeridianTimeBand.swift:27-31` defines Start here / Now / Next / Later zones. | Local styling override; timeline card |
| Today title block overlaps/competes with the time-band surface | Screenshot shows large `Today` text intruding below the time band. | `TodayDayRailPanels.swift:69-72` renders `header` and topology after the fused time band; source line for `header` is in this file, active inside `AmbitionsDayRailView`. | Card-stack layout / local composition issue |
| Reality Meridian prose panel dominates first viewport | Panel shows `Reality Meridian continuity` and long explanatory prose. | `TodayRealityMeridianTopology.swift:11-21`; copy from `DayRailProjection.swift:423-424`. | Card-stack layout; fixture/demo-like explanatory content in active projection |
| Start Here / Now / Next / Later appear as tiles | Screenshot shows a grid of topology cards rather than one primary decision object. | `TodayRealityMeridianTopology.swift:23-86`. | Card-stack layout |
| Source/Freshness cards are low and clipped by first viewport | Screenshot shows Source and Freshness cards dark/clipped at the bottom. | `TodayRealityMeridianTopology.swift:57-67` renders Source/Freshness badges; `TodayDayRailPanels.swift:368-389` also renders source freshness near the current moment when a hero step exists. | Card-stack layout; source/freshness card duplication risk |
| Runtime/preview mismatch risk remains | Required exact search found `On device` in a preview fixture, while screenshot shows `On-device` visible in runtime. | `Sources/Previews/TrustReceiptLayerPreviews.swift:84` matched exact search; broader trace found active Today copy at `TodayDayRailPanels.swift:230` and `:239`. | Preview/runtime mismatch risk |
| Tab/dock mismatch not visible in first screenshot | The screenshot top viewport does not show the bottom tab bar. | Active root `TabView` evidence remains `AmbitionsRootView.swift:91-117`; AOR-012 found no `ContinuityDock`. | Marked not in first-viewport screenshot; active dock path already proven |

## Required Trace Checklist

- Timeline card: traced to `TodayDayRailCurrentTimeFusion.swift` and `RealityMeridianTimeBand.swift`.
- Status ribbon: traced to `AppShellView.swift`.
- Today title block: traced to active `AmbitionsDayRailView.header` call site in `TodayDayRailPanels.swift`.
- Reality Meridian prose panel: traced to `TodayRealityMeridianTopology.swift` plus `DayRailProjection.swift`.
- Start Here/Now/Next/Later tiles: traced to `TodayRealityMeridianTopology.swift`.
- Source/Freshness cards: traced to `TodayRealityMeridianTopology.swift` and `TodayDayRailPanels.swift`.
- Detached toolbar icons: traced to `AmbitionsRootView.shellUtilityButtons(for:)` and shell header button rendering.
- Tab/dock mismatch: not visible in first screenshot; active root path remains SwiftUI `TabView` with canonical five tabs.

## Green Gate Assessment

- Active Today rendering files are proven with source line excerpts.
- Before screenshot was captured from a booted simulator with deterministic Today launch args.
- Required visible structures were traced or marked not visible in the first screenshot.
- No UI source code was modified.

## Proof / Claim Boundaries

This report does not claim visual approval, accessibility approval, performance proof, release readiness, or UI reconstruction. It records a Red baseline and source ownership for future Today cleanup.
