# Ambitions Canon To Implementation Boundary Map

Status: Yellow
Date: 2026-05-08

This boundary map continues `Repo Phase 0 — Orientation Audit And Canon Pointer Cleanup`. It is a docs-only planning artifact. It does not rename app code, change Swift behavior, modify Xcode settings, alter assets, change tests, start screenshots, or claim implementation completion.

Yellow is the correct result because AmbitionsCanon is installed and mappable, but the current repo still preserves compatibility names and older Product Experience / Signature Interface terminology that must be mapped before implementation edits.

## Source Truth Read

- `docs/AmbitionsCanon/Ambitions_Design_System.md`
- `docs/AmbitionsCanon/00_Canon_Index_10_10_Maturity_Gate.md`
- `docs/AmbitionsCanon/01_Product_Canon.md`
- `docs/AmbitionsCanon/02_Continuity_Layer_Chrome.md`
- `docs/AmbitionsCanon/03_Signature_Object_Specs.md`
- `docs/AmbitionsCanon/04_Trust_Privacy_Automation.md`
- `docs/AmbitionsCanon/05_Accessibility_Motion_Performance.md`
- `docs/AmbitionsCanon/06_QA_Preview_Visual_Drift.md`
- `docs/AmbitionsCanon/07_Native_Shell_Tokens_Materials.md`
- `docs/AmbitionsCanon/08_Implementation_Codex_Repo_Integration.md`
- `docs/audits/ambitions-canon-pack-repo-phase-0-orientation-audit.md`
- `README.md`
- `AGENTS.md`
- `docs/README.md`
- `docs/canon/README.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/handoff/Ambitions_Product_Experience_Pack_Repo_Traceability_Map.md`
- `docs/handoff/Ambitions_Product_Experience_Pack_File_Boundary_Map.md`

## Files Inspected

- `Native/Ambitions/App/AppTab.swift`
- `Native/Ambitions/App/AmbitionsRootView.swift`
- `Native/Ambitions/App/AppMeridianShell.swift`
- `Native/Ambitions/App/AppShellView.swift`
- `Native/Ambitions/Features/Today/`
- `Native/Ambitions/Features/Goals/`
- `Native/Ambitions/Features/Captures/`
- `Native/Ambitions/Features/Plan/`
- `Native/Ambitions/Features/Profile/`
- `Native/Ambitions/Features/Habits/`
- `Native/Ambitions/Features/Insights/`
- `Native/Ambitions/Features/Shared/`
- `Native/Ambitions/UI/`
- `Native/Ambitions/PreviewSupport/`
- `Sources/Theme/AmbitionTheme.swift`
- `Sources/Components/`
- `Sources/Previews/`
- `AppUI/Sources/`
- `Native/AmbitionsTests/`
- `Native/AmbitionsUITests/`

## Files Added

- `docs/handoff/Ambitions_Canon_To_Implementation_Boundary_Map.md`

## Files Modified

- `docs/handoff/Ambitions_Canon_To_Implementation_Boundary_Map.md`

## Forbidden Files Not Modified

- `Native/**`
- `Sources/**`
- `AppUI/**`
- `*.swift`
- `project.yml`
- `Package.swift`
- `.github/**`
- `Native/AmbitionsTests/**`
- `Native/AmbitionsUITests/**`
- assets
- generated screenshots
- persistence/model migration files

## Canon Object Mapping

| Canon object | Canon role | Current repo path or paths | Current repo term or terms | Mapping status | Risk | Future owner |
| --- | --- | --- | --- | --- | --- | --- |
| AmbitionsShell | Root native shell, safe areas, global composition | `Native/Ambitions/App/AmbitionsRootView.swift`, `AppShellView.swift`, `AppMeridianShell.swift`, `Sources/Components/ShellChromePrimitives.swift` | App shell, Ambition Meridian Shell, AppShellScaffold | Partial | Shell edits are high-risk because they can affect every tab. | Shell / Continuity batch |
| Context Crown | Safe-area-aware orientation layer | `Native/Ambitions/App/AmbitionsRootView.swift`, `AppShellView.swift`, `Sources/Components/ShellChromePrimitives.swift` | AppShellScaffold header, shell header | Partial | Can become dashboard header or utility strip if overfilled. | Shell / Continuity batch |
| Meridian Edge | Edge orientation/state expression | `Native/Ambitions/App/AppMeridianShell.swift`, `Native/Ambitions/Features/Today/TodayDayRailSignaturePrimitives.swift`, `Sources/Components/ShellChromePrimitives.swift` | Meridian shell, Reality Rail, trace/rail | Partial | Visual-only meaning or misplaced continuity signals. | Shell / Today batch |
| Continuity Dock | Canon bottom tab system / calm markers | `Native/Ambitions/App/AmbitionsRootView.swift`, `Native/Ambitions/App/AppTab.swift`, `AppMeridianShell.swift` | TabView, AppMeridianDestinationRail | Partial | Plus icon, red badges, or extra tab would be Hard Red. | Shell / Continuity batch |
| Trust Seam | Explanation/receipt/source seam | `Sources/Components/TrustReceiptLayerPrimitives.swift`, `Native/Ambitions/App/AmbitionsRootView.swift`, `Native/Ambitions/Features/Profile/`, `Native/Ambitions/Features/Today/` | Trust Receipt Layer, continuity receipt, proof review | Partial | Can drift into feed/chat drawer/unsupported privacy claim. | Trust / You / Today batches |
| Quiet Reflow | Preview-before-meaningful-change adaptation | `Native/Ambitions/Features/Plan/PlanReflowDecisionCard.swift`, `PlanReflowDecisionState.swift`, `TodayActionClosureSheet.swift` | Reflow decision, adjustment sheet | Partial | Silent scheduling mutation is Hard Red. | Plan / Trust batch |
| Receipt Surface | Consequence/proof/undo surface | `Native/Ambitions/Domain/ActionClosureReceiptModels.swift`, `Sources/Components/TrustReceiptLayerPrimitives.swift`, `Native/Ambitions/Features/Profile/ProfileTrustHistoryCenterCard.swift` | Trust Receipt Layer, proof receipt, closure receipt | Partial | Notification-feed posture or unsupported reversibility. | Trust / You / Today batches |
| Cross-Object Threads | Source/destination relationship between objects | `Native/Ambitions/Features/Goals/`, `Native/Ambitions/Domain/LifeGraphModels.swift`, `Native/Ambitions/Features/Today/TodayExecutionProjector.swift` | Goal threads, LifePath threads, proof/resource graph | Partial | Decorative relationship lines without source meaning. | Goals / Today / Trust batches |
| Reality Meridian | Today primary object | `Native/Ambitions/Features/Today/TodayDayRailSignaturePrimitives.swift`, `TodayDayRailPanels.swift`, `DayRailViewState.swift`, `TodayScreen.swift` | Reality Rail, Day Rail, Now/Next/Later | Compatibility name | Generic task list or calendar timeline drift. | Today batch |
| Start Here Surface | Today related action object | `Native/Ambitions/Features/Today/TodayHeroStepSignaturePrimitives.swift`, `TodayPanels.swift`, `TodayScreen.swift` | Hero Step Panel, Start here, recommended step | Compatibility name | Detached card stack or AI prompt posture. | Today batch |
| Constellation Atlas | Goals primary life-area object | `Native/Ambitions/Features/Goals/GoalsScreen.swift`, `GoalLifePathSignaturePrimitives.swift`, `GoalsFeatureModels.swift` | LifePath View, Goals overview | Compatibility name | KPI dashboard, ranked life score, astrology map. | Goals batch |
| Orbital Lens | Goals selected-area focus object | `Native/Ambitions/Features/Goals/GoalDetailScreen.swift`, `GoalLifePathSignaturePrimitives.swift`, `GoalsFeatureModels.swift` | LifePath Thread, selected goal/area focus | Partial | Isolated goal dashboard or system-ranked priorities. | Goals batch |
| Atmosphere Composer | Capture primary object | `Native/Ambitions/Features/Captures/CaptureAtmosphereComposer.swift`, `CapturesScreen.swift`, `CaptureDraftRoutePreviewCard.swift` | Capture Atmosphere Composer, Captures | Aligned with compatibility folder name | Feed/inbox/chat/category-board drift. | Capture batch |
| LifeShape Field | Plan primary capacity object | `Native/Ambitions/Features/Plan/PlanLifeShapeTimeCapacityMap.swift`, `PlanLifeSuiteState.swift`, `PlanScreen.swift` | LifeShape Map, LifeShape Time Capacity Map | Compatibility name | Calendar clone, analytics dashboard, silent rearrangement. | Plan batch |
| User System Profile | You primary control object | `Native/Ambitions/Features/Profile/ProfileScreen.swift`, `ProfileRootSurface.swift`, `Sources/Components/PersonalSystemCenterPrimitives.swift` | Profile, Personal System Center | Compatibility name | Social/admin/settings-wall drift or hidden trust controls. | You batch |
| Automation & Trust | Launch automation control and proof posture | `Native/Ambitions/Features/Profile/`, `Sources/Components/TrustReceiptLayerPrimitives.swift`, `Native/Ambitions/Domain/SafeAutomationPolicyModels.swift` | Trust Center, planning defaults, receipt history | Partial | Automation above Preview Reflow or no receipt/control. | You / Trust batch |
| Preview fixtures | Canon state proof inputs | `Native/Ambitions/PreviewSupport/`, `Sources/Previews/`, `Sources/Previews/SignatureInterfaceVisualQAFixtures.swift` | Preview fixtures, SI16 fixture catalog | Partial | Happy-path-only previews or stale object names. | Preview / QA batch |
| Visual QA / screenshots | Rendered evidence and drift scoring | `Sources/Previews/SignatureInterfaceVisualQAPreviews.swift`, `docs/audits/visual-evidence/` | SI16 visual QA | Unknown | No fresh screenshots in this pass. | QA batch |
| Design tokens | Semantic visual language | `Sources/Theme/AmbitionTheme.swift` | AmbitionTheme colors, semantic colors, shell tokens | Partial | Raw feature colors or unvalidated final values. | Token / material batch |
| Materials | Celestial Field, Graphite Recess, Luminous Trace, Quiet Glass | `Sources/Theme/AmbitionTheme.swift`, `Sources/Components/SurfacePrimitives.swift`, `Sources/Components/RichPanelPrimitives.swift` | gradients, surfaces, panels, glass-like controls | Partial | Generic glassmorphism or decorative glow. | Token / material batch |
| Motion / haptics | Meaningful restrained motion and equivalents | `Sources/Components/MotionPrimitives.swift`, `Sources/Previews/InteractionMotionHapticsPreviews.swift` | interaction motion and haptics primitives | Partial | Motion-only meaning or spectacle animation. | Accessibility / motion batch |
| Accessibility | Nonvisual object meaning | `Sources/Accessibility/`, `Native/AmbitionsTests/App/*Accessibility*`, object feature files | accessibility nutrition, adaptive interface primitives | Partial | Visual-only meaning or unreachable trust/receipt path. | Accessibility / QA batch |

## Top-Level Surface Boundary Map

| Surface | Canon composition | Current paths | Boundary decision |
| --- | --- | --- | --- |
| Today | `AmbitionsShell + RealityMeridian + StartHereSurface` | `Native/Ambitions/Features/Today/` | Future edits must stay inside Today object wrappers/projections unless shell ownership is explicitly in scope. |
| Goals | `AmbitionsShell + ConstellationAtlas + OrbitalLens` | `Native/Ambitions/Features/Goals/` | Future edits must keep Mission Control inside Goal Detail and avoid top-level Mission Control. |
| Capture | `AmbitionsShell + AtmosphereComposer` | `Native/Ambitions/Features/Captures/` | Internal plural folder remains compatibility; visible copy must remain singular Capture. |
| Plan | `AmbitionsShell + LifeShapeField` | `Native/Ambitions/Features/Plan/` | Week/capacity/life-shape planning is in scope; calendar-grid primary UI is out of scope. |
| You | `AmbitionsShell + UserSystemProfile` | `Native/Ambitions/Features/Profile/` | Internal Profile remains compatibility; user-facing You and trust controls must stay visible. |

## Shell / Chrome Boundary Map

| Canon chrome | Current implementation evidence | Implementation boundary |
| --- | --- | --- |
| Context Crown | `AppShellScaffold` title/subtitle/trailing button pattern | Header copy and one-context rule can be adjusted only in shell batches. |
| Continuity Dock | `TabView` plus optional `AppMeridianDestinationRail` | Must preserve five visible tabs, no red counts, no Capture plus tab. |
| Meridian Edge | Meridian shell and Today rail concepts | Must repeat meaning in labels/VoiceOver, not visual edge only. |
| Trust Seam | Continuity receipt and trust receipt primitives | Must stay source/control/receipt-oriented, not chat/feed. |

## Token / Material Boundary Map

| Canon material/token area | Current implementation evidence | Boundary decision |
| --- | --- | --- |
| Semantic tokens | `AmbitionTheme.Colors`, `SemanticColors`, `ShellTokens` | Add aliases only when compile-safe and non-persistence; do not claim exact values final. |
| Celestial Field | theme canvas gradients/backgrounds | Can map existing canvas tokens; no visual-final claim without screenshots. |
| Graphite Recess | elevated/surface/recess-like panels | Can map existing surface tokens; avoid generic card proliferation. |
| Luminous Trace | semantic accent/status/trace-like colors | Use only for state/proof/continuity relationship; avoid decorative glow. |
| Quiet Glass | shell controls/material backgrounds | Keep native, restrained, tappable, and contrast-aware. |

## Compatibility Name Mapping

| Current repo term | Canon term | User-facing risk | Internal compatibility allowed? | Future treatment |
| --- | --- | --- | --- | --- |
| captures | Capture | Low if visible title remains singular; medium if folder/name leaks to copy. | Yes | Keep internal until a scoped rename plan exists. |
| profile | You / User System Profile | Medium if user sees Profile as top-level label. | Yes | Preserve internal owner; user-facing label remains You. |
| habits | legacy/internal, not top-level | High if restored as top-level tab. | Yes as Plan-owned compatibility/depth only | Do not expose as sixth tab. |
| insights | legacy/internal, not top-level | High if restored as top-level tab. | Yes as You/Profile-owned history/reflection depth only | Do not expose as sixth tab. |
| DayTimelineRail / Reality Rail / Day Rail | Reality Meridian | Medium; old names can overfit rail/list visuals. | Yes temporarily | Alias in docs and gradually migrate copy under Today batch. |
| Hero Step Panel | Start Here Surface | Medium; detached panel/card risk. | Yes temporarily | Future Today batch should bind it to active Meridian node. |
| LifePath View | Constellation Atlas / Orbital Lens | Medium; path metaphor can become linear project tracker. | Yes temporarily | Map overview to Atlas and selected detail to Lens. |
| LifeShape Map | LifeShape Field | Medium; map can become calendar-grid/analytics surface. | Yes temporarily | Preserve capacity field semantics. |
| Personal System Center | User System Profile | Medium; can become dense admin/settings wall. | Yes temporarily | Map to You grouped control center. |
| Ambition Meridian Shell | Continuity Dock / Meridian Edge / shell | Medium; shell-specific invention can overtake native tab contract. | Yes temporarily | Keep five-tab native shell; map Meridian to edge/dock where useful. |
| Trust Receipt Layer | Trust Seam / Receipt Surface | Medium; can become feed or unsupported trust claim. | Yes temporarily | Keep source/control/receipt proof discipline. |

## First Safe Implementation Batch Options

1. Token/material inventory only: map existing `AmbitionTheme` fields to Canon semantic tokens without changing values.
2. Preview fixture inventory only: map existing SI16 fixtures to AmbitionsCanon required fixture names and park missing fixtures.
3. Shell/Continuity Dock audit only: prove five visible tabs and document compatibility cases before source edits.
4. Today terminology bridge: add wrappers or aliases only if compile-safe and no broad Today rewrite is required.
5. Capture composer audit: preserve existing `CaptureAtmosphereComposer` and route reveal after input.

## Hard Red File Boundaries

- Any change that requires promoting Mission Control, Dashboard, Assistant, Calendar, Inbox, or Settings to top-level.
- Any change that adds a sixth primary tab.
- Any broad shell/root navigation rewrite outside a shell batch.
- Any migration/persistence/default change without explicit migration plan.
- Any implementation that requires deleting historical docs or overwriting accepted Yellow/Red history.
- Any code change when validation required for safety cannot be run.

## Future Proof Requirements

- Build/test evidence for any Swift changes.
- Screenshot or rendered preview proof before visual-quality claims.
- VoiceOver/Dynamic Type/Reduce Motion evidence before accessibility claims.
- Device profiling before performance claims.
- Source/control/receipt evidence before automation/trust claims.
- Green/Yellow/Red closeout with files touched and files intentionally not touched.

## Recommended Next Phase

```text
Phase 2 — Master Implementation Batch Plan
```
