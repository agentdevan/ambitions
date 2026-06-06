# AOR-011 Primitive Integration Audit

Status: Green for read-only audit scope
Issue: AMB-529 / AOR-011
Date: 2026-06-06

This report audits active-surface primitive integration. It does not approve visual quality, accessibility, performance, release readiness, or any new material system.

## Scope Boundary

- Repo branch during audit: `main`
- Starting HEAD: `0bcf2b73b9e700747dc2227f41fa6b1be047f40b`
- UI/product source edited: no
- New primitive proposed: no
- App tests/builds run: no, not required for this read-only audit

## Inspected Sources

- `DesignTokens/*.tokens.json`
- `Sources/Theme/AmbitionTheme.swift`
- `Sources/Components/AmbitionsPremiumMaterials.swift`
- `Sources/Components/AmbitionsFlagshipTactilePrimitives.swift`
- `Sources/Components/AccessibilityAdaptiveInterfacePrimitives.swift`
- `docs/codex/ambitions-ui-primitives-inventory.md`
- `artifacts/ambitions-ui-reconstruction/reports/AOR-001-report.md`
- `artifacts/ambitions-ui-reconstruction/reports/AOR-010-report.md`
- Active roots under `Native/Ambitions/App` and `Native/Ambitions/Features`

## Commands Run

```bash
rg -n "QuietGlass|CelestialField|GraphiteRecess|LuminousTraceModifier|AmbitionTheme|ContextCrownHeader|AtmosphereComposerCanvas|AccessibilityAdaptive" Native Sources --glob "*.swift"
rg -n "\\.background\\(\\.black\\)|Color\\.|LinearGradient|RadialGradient|ultraThinMaterial|thinMaterial|cornerRadius|shadow" Native Sources --glob "*.swift"
```

## Existing Primitive System

The primitive inventory is Green. Existing source already provides:

- `AmbitionTheme`: colors, semantic states, radius, spacing, typography, shell materials, elevation/depth, gradients.
- `QuietGlass`: frosted/refractive container with high-contrast and Reduce Transparency fallback.
- `CelestialField`: particle/canvas background with Reduce Motion, Increase Contrast, and Reduce Transparency fallback.
- `GraphiteRecess`: recessed material using theme tokens and contrast-aware stroke.
- `LuminousTraceModifier`: trace/relationship modifier with Reduce Motion static-origin fallback.
- `ContextCrownHeader`: capture/surface crown using theme shell material and Reduce Motion handling.
- `AtmosphereComposerCanvas`: flagship Capture composer built on `QuietGlass`.
- `AccessibilityAdaptiveInterfacePrimitives`: static requirements catalog for Dynamic Type, VoiceOver, Reduce Motion, non-color meaning, tap target, privacy-safe exposure, and cognitive load.

No missing material/glass/particle capability was proven by this audit.

## Active Primitive Usage By Surface

| Surface | Canonical primitive usage | Local overrides / bypasses | Classification | Recommendation |
| --- | --- | --- | --- | --- |
| Global Chrome | Uses `AmbitionTheme`, shell material tokens, shell divider/depth tokens | `AppShellHeaderRail` builds custom header/ribbon with local `.background(headerMaterial)` and `.shadow(...)` | uses canonical tokens; local styling override | Keep theme tokens, but consolidate header/ribbon shape into an existing shell primitive or documented shell header primitive before changing visuals |
| Today | Uses `AmbitionTheme`; loaded root uses `RealityMeridianView`; current-time fusion uses theme radius/spacing | `TodayBackgroundView` has raw `LinearGradient`, `RadialGradient`, `Color.black`; `TodayRealityMeridianCurrentTimeFusionModifier` has raw hard-coded `LinearGradient`, `Color.white`, `Color.black`, and shadow | local styling override; bypasses theme in specific background/fusion areas | Replace raw gradients/shadows with theme materials or a tokenized Reality Meridian background variant; do not create a new particle/background system |
| Goals | Uses `LivingSurfaceBackground`, `TopLevelSurfaceCompositionBar`, `AppCard`, `StateDrivenMaterialPanel`, `TagPill`, `ProofPulse`, state styles | Many nested `RoundedRectangle(...).fill(theme.colors.surfaceOverlay)` and local shadows across `GoalComponents` and `GoalMissionControlLanePrimitives` | uses canonical primitives; local styling override | Replace repeated inner rounded overlays with existing `AppCard`, `StateDrivenMaterialPanel`, `AmbitionRichPanel`, `GraphiteRecess`, or small reusable row primitive if needed |
| Time | Uses `LivingSurfaceBackground`, `TopLevelSurfaceCompositionBar`, `StateDrivenMaterialPanel`, `HeroCard`, `AmbitionChip`, `TagPill`, `EvidenceLabel` | Contour buttons, day cards, decision/reflow rows use local `RoundedRectangle`, fill/stroke, and selected shadow logic | uses canonical primitives; local styling override | Keep LifeShape-specific geometry, but move repeated local panels into existing panel primitives or theme-tokenized helper rows; no new material system |
| Motion | Uses `QuietGlass` and `luminousTrace` directly in `MotionCurrentNodeCard`; uses `AmbitionTheme` and Reduce Motion | Node card shape is canonical; list/card composition is a product integration issue from AOR-010, not a primitive capability gap | uses canonical primitive | Keep primitives; later Motion issue should change composition/ownership, not invent material |
| You | Root uses `LivingSurfaceBackground`, `PersonalSystemCenterRootView`, grouped navigation primitives, `AmbitionTheme`; detail sheets use `AppCard`, `TagPill`, theme tokens | `YouScreen` contains many detail-section local rounded overlays and preview swatches; root is more integrated than detail stack | uses canonical primitives; local styling override | Preserve grouped navigation; migrate repeated detail rows/swatches to existing grouped/list/panel primitives as scoped cleanup |
| Capture | Active `CaptureScreen` uses `AtmosphereComposerCanvas` and `ContextCrownHeader`; route cards use `StateDrivenMaterialPanel`, `AppCard`, `TagPill` | `CaptureDraftRoutePreviewCard` repeats rounded row overlays; `CaptureAtmosphereComposer.swift` has `.background(.ultraThinMaterial)` but is not mounted by active `CaptureScreen` | active root uses canonical primitive; stale/support composer has duplicate material | Keep `AtmosphereComposerCanvas` as canonical. Treat `CaptureAtmosphereComposer` as stale/support unless remounted; do not fork composer materials |

## Local Raw Styling Inventory

| File / lines | Hit | Active classification | Replace / keep |
| --- | --- | --- | --- |
| `Native/Ambitions/App/AppShellView.swift:161` through `Native/Ambitions/App/AppShellView.swift:162` | Header rail `.background(headerMaterial)` and `.shadow(...)` | local styling override using canonical shell tokens | Keep short term; consolidate under shell/header primitive in AOR-CHROME-00 |
| `Native/Ambitions/Features/Today/TodayBackground.swift:15` through `Native/Ambitions/Features/Today/TodayBackground.swift:43` | Raw `LinearGradient`, `RadialGradient`, and `Color.black` overlay | bypasses theme in active Today background | Replace with `theme.materials`, `CelestialField`, or Reality Meridian object tokens |
| `Native/Ambitions/Features/Today/TodayDayRailCurrentTimeFusion.swift:35` through `Native/Ambitions/Features/Today/TodayDayRailCurrentTimeFusion.swift:57` | Raw hard-coded dark `LinearGradient`, `Color.white` stroke, `Color.black` shadow | bypasses theme in active Today fusion wrapper | Replace with theme canon materials or an existing `QuietGlass`/`GraphiteRecess` variant |
| `Native/Ambitions/Features/Goals/GoalComponents.swift:328`, `:363`, `:389` through `:390`, `:423` through `:424`, `:547` through `:548`, `:605` | Repeated local `RoundedRectangle` fill/stroke with theme tokens | local styling override | Replace repeated row containers with existing panel/list primitive or small theme-token helper |
| `Native/Ambitions/Features/Goals/GoalMissionControlLanePrimitives.swift:233` through `:240`, `:422` through `:428` | Local lane-card shape fill/stroke/shadow | local styling override using theme tokens | Keep lane-specific interaction short term; consolidate shape/shadow into existing panel primitive |
| `Native/Ambitions/Features/Time/TimeLifeShapeField.swift:223` through `:266` | `StateDrivenMaterialPanel` around primary field | uses canonical primitive | Keep |
| `Native/Ambitions/Features/Time/TimeLifeShapeField.swift:365` through `:372`, `:525` through `:528` | Local contour button and selected-band rounded fills | local styling override using theme tokens | Keep shape semantics, but extract to existing panel/list primitive before larger UI rebuild |
| `Native/Ambitions/Features/Time/TimeScreen.swift:1156`, `:1184` through `:1185` | `HeroCard` and `TagPill` in Time hero | uses canonical primitive | Keep; product issue is root composition, not primitive gap |
| `Native/Ambitions/Features/Time/TimeScreen.swift:1399` through `:1407` | Local day-card fill/stroke/selected shadow | local styling override | Replace with theme elevation helper or `AppCard`/panel row primitive if design keeps day cards |
| `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:64`, `:118` through `:125` | `QuietGlass` and `luminousTrace` | uses canonical primitive | Keep |
| `Native/Ambitions/Features/You/YouRootSurface.swift:65` through `:103` | `PersonalSystemCenterRootView` root composition with grouped navigation | uses canonical primitive family | Keep; improve integration through root composition work |
| `Native/Ambitions/Features/You/YouScreen.swift:433`, `:485`, `:533` and many later detail cards | `AppCard` plus repeated detail-row rounded overlays | uses canonical primitive with local row overrides | Keep detail behavior; consolidate repeated rows in later You issue |
| `Native/Ambitions/Features/Capture/CaptureScreen.swift:44`, `:93` through `:96` | `AtmosphereComposerCanvas`, `ContextCrownHeader` | uses canonical primitive | Keep |
| `Native/Ambitions/Features/Capture/CaptureDraftRoutePreviewCard.swift:15`, `:81` through `:85`, `:115` through `:130`, `:177` through `:181`, `:226` through `:230` | `StateDrivenMaterialPanel` plus repeated rounded row overlays | uses canonical panel; local row overrides | Keep panel; consolidate row styling if route shelf remains |
| `Native/Ambitions/Features/Capture/CaptureAtmosphereComposer.swift:174` | `.background(.ultraThinMaterial)` | dead/stale/support-only; `CaptureScreen` does not mount this composer | Do not use as active source truth. If remounted, replace with `AtmosphereComposerCanvas` or `QuietGlass` |

## Replace With Theme Token / Existing Primitive / Keep

- Replace raw `Color.black`, `Color.white`, and explicit RGB gradients in active Today background/fusion with `AmbitionTheme` materials, `CelestialField`, `GraphiteRecess`, or object tokens.
- Replace repeated local rounded row containers in Goals, Time, You, and Capture detail rows with existing `AppCard`, `StateDrivenMaterialPanel`, `AmbitionRichPanel`, `GraphiteRecess`, `GroupedNavigationList`, or a narrow existing-primitive extension.
- Keep `MotionCurrentNodeCard` primitive use for now; Motion needs composition work, not a material replacement.
- Keep `AtmosphereComposerCanvas` as the canonical Capture composer. Do not revive `CaptureAtmosphereComposer` without replacing its `.ultraThinMaterial` path.
- Keep shell token usage, but consolidate the visible header/ribbon into a scoped shell primitive before making AOR-CHROME visual changes.

## Missing Capability Assessment

No missing primitive capability was proven.

Evidence:

- `QuietGlass` already handles Increase Contrast / Reduce Transparency fallback through `colorSchemeContrast` and `accessibilityReduceTransparency`.
- `CelestialField` already disables animated particle behavior for Reduce Motion, Increase Contrast, or Reduce Transparency.
- `LuminousTraceModifier` already provides Reduce Motion static-origin meaning.
- `ContextCrownHeader` handles Increase Contrast and Reduce Motion, though it does not explicitly read Reduce Transparency.
- `AccessibilityAdaptiveInterfacePrimitives` documents manual proof requirements and does not allow public accessibility claims.

Primitive gaps to track without proof claims:

- Active local backgrounds do not uniformly read Reduce Transparency; they may rely on color/opacity layers even when equivalent tokenized fallbacks exist.
- Local row containers often use color and opacity for hierarchy; they need manual High Contrast / non-color meaning review.
- Static code inspection cannot prove Dynamic Type fit, VoiceOver order, Reduce Motion meaning, Increase Contrast, or Reduce Transparency behavior.

## No-New-Primitive Recommendation

Do not create a new material, glass, particle, shader, or card primitive from AMB-529.

The problem is active integration:

- Today bypasses canonical materials with raw background/fusion styling.
- Goals, Time, You, and Capture repeat local rounded row surfaces instead of consistently applying existing panel/list primitives.
- Global chrome uses shell tokens but still owns bespoke header/ribbon behavior.

Next source-changing AOR issues should integrate existing primitives first and only extend an existing primitive when a concrete behavior cannot be expressed by `AmbitionTheme`, `QuietGlass`, `GraphiteRecess`, `StateDrivenMaterialPanel`, `AmbitionRichPanel`, `GroupedNavigationList`, `ContextCrownHeader`, or `AtmosphereComposerCanvas`.

## Classification Summary

- Uses canonical primitive: Global tokens, Motion, active Capture composer, Time hero/field wrapper, Goals/You/Time cards and chips.
- Bypasses theme: active Today background and current-time fusion raw colors/gradients/shadow.
- Local styling override: repeated Goals/Time/You/Capture rounded row fills/strokes and selected shadows.
- Duplicate material: stale/support `CaptureAtmosphereComposer.swift` `.ultraThinMaterial`; not active `CaptureScreen` runtime.
- Preview-only: `Sources/Previews/**` hits and SwiftUI `#Preview` blocks.
- Dead/stale: `CaptureAtmosphereComposer` unless remounted; `AppMeridianShell` as runtime support/preview from AOR-001.
- Unknown/out of scope: widget and share extension styling hits.

## Green Gate Result

- Active surface local styling overrides listed: yes.
- Existing primitive reuse opportunities listed: yes.
- New primitive proposed without proof: no.
- High Contrast / Reduce Transparency / Reduce Motion gaps called out without proof claims: yes.
- UI/product source edited: no.
- Accessibility proof claimed: no.
