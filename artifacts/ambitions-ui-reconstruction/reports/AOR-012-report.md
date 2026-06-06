# AOR-012 Root Chrome Consolidation Audit

Issue: AMB-530
Date: 2026-06-06
Scope: Read-only audit of active shell chrome ownership and duplicated surface chrome.
Status: Green for audit completion. No source cleanup was performed or claimed.

## Truth Boundary

Active IA remains `Today / Goals / Time / Motion / You` with global `Capture`.
This audit did not change tab IA, Capture routing, runtime behavior, screenshots, accessibility proof, or release posture.

## Commands Run

```bash
rg -n "ContextCrownHeader|ContinuityDock|TabView|selectedTab|activeTab|Capture|Toolbar|toolbar|search|magnifyingglass|plus|ribbon|banner|header|Receipt|Trust|Why this" Native Sources --glob "*.swift"
rg -n "ContinuityDock|TopLevelSurfaceCompositionBar|ContextCrownHeader|ToolbarItem|\\.toolbar|Label\\(\"Capture\"|magnifyingglass|AmbitionActionClosureTray|EvidenceLabel|Receipt|Trust|Why this" Native/Ambitions/Features Sources/Components --glob "*.swift"
rg -n "TopLevelSurfaceCompositionBar\\(" Native/Ambitions/Features Sources/Components --glob "*.swift"
rg -n "ContextCrownHeader\\(" Native Sources --glob "*.swift"
rg -n "AppShellScaffold\\(|AppShellHeaderRail|shellUtilityButtons|shellActivatedCaptureComposerSeam|shellContinuityReceipt|TabView\\(" Native/Ambitions/App --glob "*.swift"
```

## Chrome Owner Map

| Chrome element | Current owner | Evidence | AOR owner assignment |
| --- | --- | --- | --- |
| Root composition | `AmbitionsRootView` | `Native/Ambitions/App/AmbitionsRootView.swift:35-39` mounts `shellTabView`, activated Capture seam, and continuity receipt in one root `ZStack`. | AOR-CHROME-00 |
| Dock/tab bar | `AmbitionsRootView.shellTabView(theme:)` plus UIKit tab appearance | `Native/Ambitions/App/AmbitionsRootView.swift:91-117` defines only Today, Goals, Time, Motion, You tabs and tab-bar toolbar styling; `:475-496` configures `UITabBarAppearance`. No `ContinuityDock` symbol was found. | AOR-CHROME-00 |
| Top shell header | `AppShellScaffold` / `AppShellHeaderRail` | `Native/Ambitions/App/AppShellView.swift:127-140` inserts `AppShellHeaderRail` as a top safe-area inset and hides the navigation bar; `:143-166` builds the rail. | AOR-CHROME-00 |
| Header title/subtitle and posture | `AmbitionsRootView` per-route scaffold configuration | `Native/Ambitions/App/AmbitionsRootView.swift:143-263` wraps Today, Goals, Time, Motion, and You roots in `AppShellScaffold` with per-surface title/subtitle/posture. | AOR-CHROME-00 |
| Utility icons | `AmbitionsRootView.shellUtilityButtons(for:)` | `Native/Ambitions/App/AmbitionsRootView.swift:293-312` supplies the Capture and memory-lens buttons for every tab scaffold. | AOR-CHROME-00 |
| Search / memory-lens button | `AmbitionsRootView.shellUtilityButtons(for:)` | `Native/Ambitions/App/AmbitionsRootView.swift:305-310` uses `systemImage: "magnifyingglass"` and `shell.<tab>.memory-lens-button`. | AOR-CHROME-00 |
| Capture button | `AmbitionsRootView.shellUtilityButtons(for:)` and activated seam | `Native/Ambitions/App/AmbitionsRootView.swift:295-304` invokes `presentSurfaceCapture(for:)`; `:444-449` presents `.quickCapture`; `:316-330` hosts `AppShellActivatedCaptureSeam`. | AOR-CHROME-00 |
| Status / continuity ribbon | `AppShellHeaderPosture` and `AppShellHeaderRail` | `Native/Ambitions/App/AppShellView.swift:51-64` defines continuity messages; `:154-160` renders `headerRow`, `continuityRibbon`, and divider. | AOR-CHROME-00 |
| Context Crown | Primitive defined in design system, active only in Capture route | `Sources/Components/AmbitionsFlagshipTactilePrimitives.swift:9-135` defines `ContextCrownHeader`; `Native/Ambitions/Features/Capture/CaptureScreen.swift:93-96` is the only active call site found. | AOR-CAPTURE-00 now; AOR-CHROME-00 if future work makes it global |
| Global continuity receipt | `AmbitionsRootView.shellContinuityReceipt` | `Native/Ambitions/App/AmbitionsRootView.swift:335-349` hosts `AmbitionActionClosureTray` for `navigation.continuityReceipt`. | AOR-CHROME-00 |
| Trust Seam / receipt primitives | Shared design-system primitives and feature-owned receipts | `Sources/Components/AmbitionsFlagshipTactilePrimitives.swift:417-602` defines `TrustSeamExplainer`; `Sources/Components/TrustReceiptLayerPrimitives.swift:596-944` defines drawers, inline receipts, and toasts. | Shared primitive owner, with feature-surface hosting owners |

## Duplicate Chrome Map

| Duplicate or overlap | Evidence | Classification | Owner assignment |
| --- | --- | --- | --- |
| Goals shell header plus surface composition band | Shell wraps Goals at `Native/Ambitions/App/AmbitionsRootView.swift:156-180`; `GoalsScreen` adds `TopLevelSurfaceCompositionBar(surface: .goals)` at `Native/Ambitions/Features/Goals/GoalsScreen.swift:35-39`. | Large duplicated header/status identity layer. | AOR-CHROME-00 decides shell header/ribbon; AOR-GOALS-00 decides whether the composition bar remains as surface object framing. |
| Time shell header plus surface composition band | Shell wraps Time at `Native/Ambitions/App/AmbitionsRootView.swift:187-196`; `TimeScreen` adds `TopLevelSurfaceCompositionBar(surface: .time)` at `Native/Ambitions/Features/Time/TimeScreen.swift:21-29`. | Large duplicated header/status identity layer. | AOR-CHROME-00 plus AOR-TIME-00. |
| You shell header plus surface composition band | Shell wraps You at `Native/Ambitions/App/AmbitionsRootView.swift:254-263`; `YouScreen` adds `TopLevelSurfaceCompositionBar(surface: .you)` at `Native/Ambitions/Features/You/YouScreen.swift:23-27`. | Large duplicated header/status identity layer. | AOR-CHROME-00 plus AOR-YOU-00. |
| Capture support route triple chrome | Time support route wraps Capture in `AppShellScaffold(title: "Capture")` at `Native/Ambitions/App/AmbitionsRootView.swift:199-209`; `CaptureScreen` adds `TopLevelSurfaceCompositionBar(surface: .capture)` at `Native/Ambitions/Features/Capture/CaptureScreen.swift:37-43` and `ContextCrownHeader` at `:93-96`. | Highest-risk duplicated chrome and active Capture support-route clutter. Capture is still not a tab. | AOR-CHROME-00 plus AOR-CAPTURE-00. |
| Feature-local toolbar compatibility | Active root passes `showsNavigationChrome: false` to Goals, Time, and You at `Native/Ambitions/App/AmbitionsRootView.swift:172-176`, `:195`, and `:262`; feature files still define conditional toolbar items at `GoalsScreen.swift:130-147` and `TimeScreen.swift:91-103`. | Compatibility chrome, not active root chrome in the current shell path. | Surface owners may keep for previews/legacy entry until scoped cleanup. |
| AppMeridian destination rail | `Native/Ambitions/App/AppMeridianShell.swift:4-21` defines `AppMeridianDestinationRail`; no active root call site found in `AmbitionsRootView`. | Support/preview shell artifact, not active dock owner. | AOR-CHROME-00 cleanup candidate if future chrome consolidation removes unused shell experiments. |

## Capture Action Placement Map

Capture is placed as a global contextual action, not a top-level tab:

- `Native/Ambitions/App/AmbitionsRootView.swift:91-111` defines Today, Goals, Time, Motion, and You tabs only.
- `Native/Ambitions/App/AmbitionsRootView.swift:295-304` provides the shared toolbar Capture button for each tab.
- `Native/Ambitions/App/AmbitionsRootView.swift:316-330` renders the activated bottom composer seam only after Capture is invoked.
- `Native/Ambitions/App/AmbitionsRootView.swift:199-209` routes Time's support destination to `CaptureScreen()` without adding a Capture tab.
- `Native/Ambitions/Features/Capture/CaptureScreen.swift:4-7` still has `.topLevelCapture` shell mode in the type system, but the active root path uses it as a Time support route.

## Trust / Receipt Hosting Map

| Trust or receipt surface | Evidence | Owner assignment |
| --- | --- | --- |
| Global transient continuity receipt | `AmbitionsRootView.shellContinuityReceipt` at `Native/Ambitions/App/AmbitionsRootView.swift:335-349`. | AOR-CHROME-00 |
| Today Start Here receipt preview | `Native/Ambitions/Features/Today/TodayStartHereSurface.swift:203-215` uses `EvidenceLabel("Why this?")` and `InlineTrustReceipt`. | AOR-TODAY-00 |
| Today closure receipt sheets | `Native/Ambitions/Features/Today/TodayActionClosureSheet.swift:52-53` toolbar close and `:284-296` receipt preview boundary; `TodayStepReplacementSheet.swift:630-631` also owns sheet toolbar chrome. | AOR-TODAY-00 |
| Motion proof/receipt rows | `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:87-92` renders source/proof/receipt/control rows. | AOR-MOTION-00 |
| Capture receipt and trust seam | `Native/Ambitions/Features/Capture/CaptureScreen.swift:271-292` renders a Capture receipt preview; `:441-460` renders the Capture route trust seam. | AOR-CAPTURE-00 |
| Goals trust and receipts | `Native/Ambitions/Features/Goals/GoalDetailScreen.swift:77-107` hosts trust and receipts cards; `:741-749` defines `GoalDetailReceiptsCard`. | AOR-GOALS-00 |
| You trust/receipts center | `Native/Ambitions/Features/You/YouRootSurface.swift:36-44` lists Trust Center, Receipts & History, and Trust & Automation; `YouScreen.swift:43-47` hosts the root view. | AOR-YOU-00 |

## Green Gate Assessment

- Shared chrome source identified: `AmbitionsRootView`, `AppShellScaffold`, and `AppShellHeaderRail`.
- Duplicated large headers/status ribbons assigned: Goals, Time, You, and Capture composition bands are assigned to AOR-CHROME-00 plus their surface owners.
- Context Crown status known: active only in `CaptureScreen`; not global shell chrome.
- Continuity Dock/tab status known: SwiftUI `TabView` plus UIKit tab bar appearance is active; no `ContinuityDock` symbol was found.
- Capture action placement known: shared shell toolbar action plus activated seam; Capture support route exists under Time; Capture is not a tab.

## Proof / Claim Boundaries

This is a read-only audit. It does not prove visual quality, accessibility behavior, screenshot baselines, performance, release readiness, or any chrome cleanup. Future consolidation must include source edits, screenshots, and accessibility review under the relevant AOR issue.
