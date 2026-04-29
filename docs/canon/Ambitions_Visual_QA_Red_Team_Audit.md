# Ambitions Visual QA Red-Team Audit

## Date

2026-04-29

## Commit Assessed

`b10bfc5ca6c2546be05a955f5aed23cd3bedc55a` (`Prepare simulator release review handoff`)

## Release Posture

Current posture remains `Candidate prepared; human approval required`.

This audit downgrades visual/product readiness. The current UI is unacceptable for investor demo, TestFlight, App Store screenshots, public release claims, visual approval, accessibility approval, or final RC lock. It may be usable only for internal engineering inspection and limited personal manual testing where the tester already knows the current defects.

## Executive Finding

The current simulator build is visually unacceptable. The product has strong underlying architecture and many source-backed feature contracts, but the visible app fails basic premium iPhone expectations: safe-area confidence, readable typography, stable tab-bar visibility, dark/light visual feedback, first-screen information hierarchy, Settings-style You navigation, and screenshot readiness.

Acceptability:

| Use | Current UI status |
| --- | --- |
| Personal manual testing | Unacceptable for broad product feel; acceptable only for source/debug inspection with known defects |
| Investor demo | Blocked |
| TestFlight | Blocked |
| App Store screenshots | Blocked |

## Evidence Used

- Human screenshot observations supplied in the audit prompt are the primary visual evidence. They report missing/buried tab bar, unsafe/transparent header behavior, text clipping such as `Integra- tions`, `Personal- ization`, and `Accessibili- ty`, low-contrast blue/accent copy, dark mode not visibly changing, and You reading as a long card stack rather than a Settings-style grouped list.
- Simulator/device used for build: `iPhone 17` iOS Simulator, iOS 26.2 SDK via Xcode command-line build.
- Launch attempted: yes. The built app was installed and launched once on the booted `iPhone 17` simulator with `xcrun simctl launch booted com.ambitions.ios`.
- Screenshot capture: intentionally skipped. The prompt explicitly warned not to run a screenshot-capture loop or block on screenshot automation; human screenshots were treated as primary evidence.
- Screens reviewed through source inspection: global shell/tab bar, global header/top chrome, Today, Goals, Goal Detail, Capture, Plan, You/Profile, Trust Center, What Ambitions Knows, Reviews, onboarding, GroupedNavigationList, RichPanel/card primitives, density/panel size/theme primitives, appearance preference plumbing, UI tests, and design-system tests.
- Limitations: no new simulator screenshots, no pixel/contrast measurement, no Dynamic Type simulator pass, no VoiceOver traversal, no physical-device proof, and no rendered external-surface review.

## Top Critical Defects

1. You is not a Settings-style grouped navigation root. Source still renders a full card-stack root before and after the grouped list: hero, system center card, control room, trust card, constitution, memory, correction, automation, receipts, reviews, Appearance Studio, defaults, permissions, context vault, integrations, and account sections in sequence (`Native/Ambitions/Features/Profile/ProfileScreen.swift`). This directly conflicts with the requested compact grouped-navigation model.
2. Shell/tab-bar confidence is broken by overlay geometry. The root shell uses a `ZStack(alignment: .bottomTrailing)` containing `TabView`, a continuity receipt, and a floating global entry button padded into the bottom/tab region. Source does not reserve a bottom safe-area inset for the floating button or prove it cannot bury the tab bar.
3. Header/top chrome is visually unsafe. `AppShellScaffold` inserts the header with `safeAreaInset(edge: .top)`, while the header uses translucent overlay gradients rather than a clearly opaque/elevated surface. Human evidence reports content scrolling under or blending through the header and overlap near status/Dynamic Island/top controls.
4. GroupedNavigationList rows are not compression-safe. Row title/subtitle use unrestricted wrapping and `fixedSize`, while trailing badges are fixed one-line pills. This makes long labels/statuses likely to hyphenate, clip, crowd, or explode row height on narrow widths and Dynamic Type.
5. Theme changes are not visibly immediate enough. Appearance choices live deep inside You and only apply to the root after explicit save/sync. The current test coverage verifies preference enum mapping, not a visible root theme transition or dark/light screenshot difference.
6. Tests passed because they mainly assert existence and route reachability. The UI suite checks that tabs/elements exist and can be scrolled to, but it does not assert frames, non-overlap, contrast, first-screen reachability, tab-bar visibility after overlays, clipped text, Dynamic Type resilience, or screenshot equivalence.

## Full Defect Inventory

| ID | Severity | Surface | Issue | Evidence | Likely Root Cause | Files/Components | Required Correction |
|---|---|---|---|---|---|---|---|
| VQA-001 | Critical | Global shell / tab bar | Tab bar can be hidden, clipped, or visually buried. | Human screenshots report missing/buried tab bar. Source overlays global controls over `TabView`. | Root `ZStack` overlays floating button/receipt on the bottom trailing region without a tab-safe layout contract. | `Native/Ambitions/App/AmbitionsRootView.swift`; `shellGlobalEntryButton`; `shellContinuityReceipt`; SwiftUI `TabView` | Rebuild shell chrome with explicit bottom safe-area reservation, tab-bar visibility assertions, and non-overlap rules for global controls. |
| VQA-002 | Critical | Header / safe area | Header appears transparent/unsafe and content scrolls underneath or blends into it. | Human screenshots report transparent header and scroll-under-header behavior. Source uses translucent header material opacity. | `safeAreaInset` header lacks a solid/elevated background contract and visual separation strong enough for moving content. | `Native/Ambitions/App/AppShellView.swift`; `AppShellScaffold`; `AppShellHeaderRail`; theme shell tokens | Make header opaque/elevated, status-bar-safe, and tested for non-overlap/scroll-under behavior. |
| VQA-003 | Critical | You | You root is a long card stack instead of a Settings-style grouped navigation list. | Human screenshots and source order show card stack dominates root. | `ProfileScreen` renders many `AppCard` sections directly; grouped navigation is only embedded inside `ProfileSystemCenterCard`. | `Native/Ambitions/Features/Profile/ProfileScreen.swift`; `ProfileSystemCenterCard`; `ProfileFeatureService` | Rewrite You root around title + short subheader + compact optional profile/system card + grouped rounded list sections. |
| VQA-004 | Critical | You information architecture | Appearance, Trust, What Ambitions Knows, Memory, Privacy, Export, Notifications, and Accessibility are not first-screen navigational rows. | Human screenshots report Appearance Studio buried far down; source places Appearance Studio after reviews and many cards. | The active You hierarchy prioritizes explanatory cards before navigational rows. | `ProfileScreen`; `ProfileFeatureService.makeSystemCenter` | Put Appearance in Section 1 and Trust/What Ambitions Knows/Privacy/Export/Notifications/Accessibility into logical grouped list sections near the top. |
| VQA-005 | Critical | Text clipping / hyphenation | Labels such as `Integrations`, `Personalization`, and `Accessibility` wrap or hyphenate badly. | Human screenshots show awkward word breaks. | Row content competes with icons/status badges; long labels/subtitles are allowed to wrap while trailing pills consume width. | `Sources/Components/GroupedNavigationList.swift`; `GroupedNavigationRowBody`; `GroupedNavigationBadgeView` | Design compression-safe rows: fixed icon lane, flexible text lane, constrained trailing lane, one-line title by default, subtitle max one line on root, Dynamic Type fallback stacking. |
| VQA-006 | High | Contrast / color legibility | Accent/blue text and secondary copy are hard to read. | Human screenshots report unreadable blue/accent and low-contrast copy. Theme uses muted accent/secondary colors and many tertiary captions. | Visual hierarchy overuses caption/micro text, translucent fills, accent-primary foregrounds, and low-opacity surfaces. | `Sources/Theme/AmbitionTheme.swift`; `Sources/Components/*`; screen cards | Add measured contrast gates and strengthen token roles for dark/light text, badges, and accent copy. |
| VQA-007 | High | Dark mode | Dark mode selection does not visibly change the app. | Human screenshots report no visible change. Source applies root theme from container preference and only syncs after save. | Picker state is local until save; tests cover enum mapping only, not visible root transition. Preview/stub paths can return unchanged dashboard state. | `ProfileAppearanceStudioCard`; `ProfileViewModel`; `AmbitionsRootView`; `AppearancePreferenceTests` | Make selection preview/root feedback obvious or clearly staged, then add UI/snapshot assertions proving dark and light differ visibly. |
| VQA-008 | High | Light mode | Light mode visual quality is unproven and may blend with low-contrast warm surfaces. | Source has light tokens, but no visual test proves readable screenshots. | Existing tests check preference values, not rendered light-mode hierarchy/contrast. | `AmbitionTheme`; `AppearancePreferenceTests`; UI tests | Add light-mode screenshot/contrast checks and visual acceptance criteria. |
| VQA-009 | High | Dynamic Type | Dynamic Type resilience is unproven and likely fragile in rows/chips/header. | Human screenshots show clipped/wrapped text even before larger text stress. | Header controls, badges, segmented controls, and grouped rows have crowding-prone layouts and few adaptive breakpoints. | `AppShellHeaderRail`; `GroupedNavigationList`; `ProfileAppearanceStudioCard`; cards across surfaces | Add accessibility-size layout strategy, row stacking rules, and tests with larger content sizes. |
| VQA-010 | High | Global floating controls | Floating add/search controls can obscure tab/content real estate. | Human screenshots mention tab buried and controls crowded. Source always overlays floating add button and header search button. | Floating button uses bottom padding rather than a reserved chrome lane; every tab receives header search. | `AmbitionsRootView.shellGlobalEntryButton`; `shellUtilityButtons`; `AppShellHeaderRail` | Reposition or integrate global action/search with explicit safe-area and tab-bar constraints. |
| VQA-011 | High | Header controls | Mode chip/header controls crowd available width. | Human screenshots report top-control/status overlap and blending. Source puts app mark, title, mode pill, subtitle, status orb, and trailing button in one compact HStack. | Header anatomy is too dense for narrow devices and accessibility sizes. | `AppShellHeaderRail`; `AmbitionModeLensPill`; `AmbitionAmbientStatusOrb` | Simplify top chrome, collapse mode/status affordances, and test no overlap with Dynamic Island/status bar. |
| VQA-012 | High | Card density / real estate | Major surfaces read as stacks of verbose panels rather than digestible native screens. | Human screenshots describe half-baked, verbose, hard-to-digest UI. Source uses repeated `AppCard`/`HeroCard` stacks across Today, Goals, Plan, You, Capture, and details. | Feature implementation accumulated panels without a visual compression pass. | `TodayScreen`; `GoalsScreen`; `GoalDetailScreen`; `PlanScreen`; `CapturesScreen`; `ProfileScreen`; `FeatureScaffoldView` | Run a surface-by-surface compression pass after shell/theme/You fixes. |
| VQA-013 | High | Excessive verbose copy | Basic navigation rows and panels contain too much explanatory text. | Human screenshots report verbose text where concise rows are needed. Source subtitles often explain system posture/future ownership. | Product-truth copy was placed directly into root UI rather than shorter navigation language. | `ProfileFeatureService.makeSystemCenter`; `ProfileScreen`; `FeatureScaffoldView`; card sections | Reduce root copy to short labels and one-line subtitles; move details into drill-downs. |
| VQA-014 | High | Settings-style mimic quality | You does not mimic iPhone Settings closely enough. | Human direction explicitly asks for Settings-style grouped lists; source uses premium cards and embedded list. | GroupedNavigationList component exists but is not the root layout model. | `ProfileScreen`; `GroupedNavigationList` | Make You root visually list-first: large title, sections, rows, separators, chevrons/statuses/toggles, concise section spacing. |
| VQA-015 | High | Premium visual quality | Current visual quality does not match the premium mockup direction. | Human evidence says app looks half-baked after D/M/R. Source confirms feature-complete surfaces but not final visual composition. | Tests and batches validated source contracts more than rendered craft. | Whole native app | Establish visual acceptance gates with screenshots, contrast, safe-area, and manual signoff. |
| VQA-016 | Major | Today | Today likely inherits header/tab/FAB issues and dense panel stack. | Source: background + ScrollView + hero/support/deep-dive panels under global chrome. | No first-screen real-estate budget or header/tab overlap tests. | `TodayScreen`; `TodayPanels`; `AppShellScaffold` | Audit first viewport and compress after global chrome fix. |
| VQA-017 | Major | Goals | Goals has many top-level cards before active goal content. | Source order includes hero, week pressure, maturity, lifecycle, chips, Life Areas, North Stars, One-Step Goals, bands, ladder, atlas, archive. | Surface grew by additive maturity batches without visual cutdown. | `GoalsScreen`; `GoalComponents` | Re-rank first screen around direction and active goals; defer secondary maturity cards. |
| VQA-018 | Major | Goal Detail | Goal Detail risks excessive scroll and tactical overload. | Source renders hero, mission control, breadcrumb, timeline, filmstrip, next movement, trajectory, explainability, assumptions, proof, decisions, risks, archive, receipts, path builder, actions, memory, tactics. | Many canonical lanes are present but not visually pruned for first-screen comprehension. | `GoalDetailScreen` | Compress lane hierarchy and ensure object identity/next action stay visible. |
| VQA-019 | Major | Capture | Capture has a strong intake panel but uses `FeatureScaffoldView` hero/card structure that may duplicate header/title hierarchy. | Source nests a hero scaffold inside global shell header. | Global header plus per-feature hero consumes vertical space. | `CapturesScreen`; `FeatureScaffoldView` | Keep one dominant intake area and reduce redundant hero copy. |
| VQA-020 | Major | Plan | Plan likely inherits dense panel/card and timeline width constraints. | Source search shows fixed-width timeline elements and many card rows. | Timeline/ribbon components have fixed widths and no visual overlap tests. | `PlanScreen` | Audit timeline compression and first-screen plan fit after chrome fix. |
| VQA-021 | Major | Trust Center | Trust content is reachable but embedded inside You card stack instead of a clear Settings row/detail flow. | Source renders `ProfileTrustCenterCard` above deeper trust/memory sections, with many explanatory cards. | Trust became an inline root panel rather than drill-down-first navigation. | `ProfileTrustCenterCard`; `ProfileFeatureService` | Make Trust Center a grouped navigation destination from You root. |
| VQA-022 | Major | What Ambitions Knows | Memory content is discoverable only after scrolling through multiple cards, and its own section is verbose. | Source places `ProfileMemoryControlsCard` after trust/constitution and includes group rows, narrative memory, patterns, recovery summary, footer. | Memory center is inline and explanatory, not compactly navigable. | `ProfileMemoryControlsCard`; `ProfileFeatureService.makeMemoryControls` | Surface as a row under Memory and Trust, then present compact grouped memory controls in detail. |
| VQA-023 | Major | Reviews | Reviews are inline in You and add substantial vertical weight. | Source places `ProfileReviewsCard` before Appearance Studio. | Reviews maturity content is not behind a row/detail boundary. | `ProfileReviewsCard` | Move Reviews to grouped navigation row and keep root summary minimal. |
| VQA-024 | Major | Onboarding / first-run | Onboarding uses its own `TabView` and hero-style cards; visual readiness is unproven under safe-area/Dynamic Type stress. | Source inspected; UI tests assert route outcomes only. | No visual snapshot or large-text first-run coverage. | `ProgressiveIntelligenceOnboarding.swift`; UI tests | Add first-run visual, safe-area, Dynamic Type, and no-permission checks later. |
| VQA-025 | Major | Screenshot readiness | App is not screenshot-ready. | Human screenshots are unacceptable; source confirms unresolved layout risks. | No screenshot/snapshot test suite and no visual acceptance checklist gate. | Test suite; docs/release posture | Block screenshots until correction pass and snapshot QA are complete. |
| VQA-026 | Critical | Release posture | Visual failures invalidate demo/TestFlight/App Store/public readiness claims. | Current report plus human screenshots. | R01-R05 are evidence ledgers, not visual approval; existing docs already keep readiness unclaimed. | `docs/codex/BATCH_REGISTRY.md`; `docs/codex/Human_Release_Review_Handoff.md`; release reports | Keep release blocked; do not mark visually approved until manual/snapshot gates pass. |

## Surface Grades

| Surface | Grade | Reason |
| --- | --- | --- |
| Global shell / tab bar | Critical issue | Tab-bar visibility and bottom safe-area confidence fail. |
| Global header / top chrome | Critical issue | Header opacity, top safe-area, and control crowding fail. |
| Today | Major issue | Inherits global chrome defects and dense panel real estate. |
| Goals | Major issue | Too many top-level panels before digestible direction/action. |
| Goal Detail | Major issue | Dense scroll and lane overload risk. |
| Capture | Major issue | Strong core intake, but redundant hero/header structure and global chrome defects. |
| Plan | Major issue | Dense planning/timeline surface with fixed-width/crowding risks. |
| You | Critical issue | Wrong root model: card stack instead of Settings-style grouped navigation. |
| You grouped navigation | Critical issue | Component exists but is embedded inside a card and not compliant as root IA. |
| Appearance Studio | High issue | Buried too far down; visual theme feedback unproven. |
| Trust Center | Major issue | Discoverable but too card-heavy and not row/detail-first. |
| What Ambitions Knows | Major issue | Valuable controls buried inside long memory card stack. |
| Reviews | Major issue | Inline card stack adds heavy vertical weight. |
| Onboarding / first-run | Major issue | Source exists but visual/safe-area/accessibility proof is insufficient. |
| External surface previews | Minor issue for source, Major unverified | Contracts compile, but rendered platform proof remains intentionally unclaimed. |

## You Page Findings

The You page does not meet the requested Settings-style grouped-navigation-list direction.

Source currently renders You as a long vertical sequence of rich cards: hero, grouped-system card, control room, trust center, constitution, memory controls, correction, automation boundaries, receipts, reviews, Appearance Studio, defaults, notification degraded state, context vault, integrations, and account. This makes the screen feel like a dashboard/settings wall, not a compact Settings-style root.

The intended structure should be:

- title `You`
- one short subheader
- optional compact profile/system card that does not dominate
- grouped list Section 1 `Me`: Profile, Personalization, Appearance
- grouped list Section 2 `Memory and Trust`: What Ambitions Knows, Trust Center, Receipts & History, Corrections
- grouped list Section 3 `Reviews and Progress`: Reviews, Proof, Archive / Completed
- grouped list Section 4 `System Edges`: Notifications, Integrations, Widgets / Live Activities / Shortcuts, Export / Import
- grouped list Section 5 `Accessibility and Support`: Accessibility, Help / Support, About

Current source partially contains these concepts in `ProfileFeatureService.makeSystemCenter`, but it uses different grouping, includes extra Analytics/Settings rows, combines `Memory / What Ambitions Knows`, places Appearance Studio as a full card far below the top, and keeps Trust/Memory content inline instead of as compact navigable rows.

## Global Shell / Tab Bar Findings

The shell uses SwiftUI `TabView`, which is appropriate for the canonical five-tab IA, but the surrounding custom chrome is not safe enough. `AmbitionsRootView` overlays `shellContinuityReceipt` and a floating global entry button on top of the `TabView`. The add button uses manual bottom padding rather than a formal safe-area/tab-bar reservation. This is a likely root cause for human-observed missing, clipped, or buried tab bar behavior.

The tab-bar test only asserts `app.tabBars.buttons[...]` existence and selection. It does not prove the tab bar is visible, unobscured, high contrast, or tappable after the floating button/receipt/header states render.

## Header / Safe Area Findings

The global header is inserted with `safeAreaInset(edge: .top)` and hides the standard navigation bar. The header rail includes app mark/back button, title, mode lens pill, subtitle/status orb, trailing search/action buttons, continuity ribbon, and divider. That is too much top chrome for narrow iPhone real estate.

The header background is `theme.shell.headerMaterial.opacity(theme.surfaces.backgroundBlurOpacity)`, where dark mode uses an overlay gradient with partial opacity. This can read as transparent and let scrolled content visually bleed underneath. Human screenshots specifically report unsafe header and status/Dynamic Island overlap; source does not include an assertion or layout guard proving otherwise.

## Typography / Readability Findings

Typography/readability is failing in practice. The strongest source risks are:

- long row labels competing with fixed icon width, trailing badges, chevrons, and status values
- `GroupedNavigationRowBody` allowing unrestricted title/subtitle wrapping with `fixedSize`
- badges using one-line text with scale-down, forcing label columns to shrink
- many captions/micro labels in dense panels
- large card stacks with repeated explanatory copy

This explains the human-observed `Integra- tions`, `Personal- ization`, and `Accessibili- ty` breaks.

## Theme / Dark Mode Findings

The theme system has dark and light token sets, and `AmbitionsRootView` resolves the root theme from `container.appearancePreference`. However, the visible Appearance Studio experience is too buried and does not prove an immediate global visual change. Existing tests only prove:

- `.system` does not force a preferred color scheme
- `.light` maps to `.light`
- `.dark` maps to `.dark`

They do not assert that selecting Dark visibly changes the current screen, that Save updates root chrome, that light/dark contrast passes, or that screenshots differ meaningfully.

## Visual Quality vs Mockup Direction

Blunt finding: the current UI is not visually close enough to the premium mockup direction. It reads as an additive feature-contract build with many cards, chips, captions, and explanatory panels, not as a composed iPhone-native premium product. The architecture is serious; the rendered hierarchy is not yet screenshot-worthy.

The most visible mismatch is You. It should feel like an Ambitions-flavored iPhone Settings root. Instead it feels like an internal trust/status dashboard with a grouped-list component placed inside one card.

## Testing Gaps

Why current tests passed while the UI is visually broken:

- UI smoke checks assert existence and navigation reachability, not visual correctness.
- Tests scroll until elements exist, which hides first-screen reachability failures.
- Tests do not inspect frames for overlap between header, content, floating button, tab bar, and safe areas.
- Tests do not run screenshot or snapshot comparisons.
- Tests do not measure contrast or color-token legibility.
- Tests do not prove dark/light visual difference.
- Tests do not stress Dynamic Type or larger accessibility sizes.
- Tests do not check text clipping, hyphenation, or awkward wrapping.
- Tests do not assert that Appearance is visible in the first screenful of You.
- Tests do not assert that You is structurally a root `GroupedNavigationList` rather than a card stack.

Tests that only assert existence instead of visual quality:

- `testPreviewBootstrapExposesCanonicalFiveTabShellAndSecondarySurfaces` checks tab buttons and many screen/card identifiers but not frames or visibility.
- `testProfileAppearanceStudioControlsAreAccessibleFromKeyboardAndTouch` scrolls to `Appearance Studio` rather than requiring first-screen discoverability.
- `testProfileTrustSurfaceShowsConservativeExternalStatusLabels` scrolls to trust/memory labels rather than asserting Settings-style placement.
- `GroupedNavigationListDesignSystemTests` compile sample rows and token minima but do not render/measure row compression.
- `AppearancePreferenceTests` verify enum mapping only.

Tests to add:

- tab-bar visible/unobscured frame assertion after launch, tab switches, overlay presentation/dismissal, and receipt presentation
- header safe-area and non-overlap assertion for status/Dynamic Island-safe top chrome
- scroll-under-header regression check using a known first row/card frame
- You root structure test requiring grouped sections and row order
- first-screenful reachability assertion for Appearance, What Ambitions Knows, Trust Center, Privacy/Export, Notifications, and Accessibility
- text clipping/hyphenation guard for `Integrations`, `Personalization`, `Accessibility`, and long status pills
- dark-mode visual assertion and light-mode visual assertion
- Dynamic Type stress tests for root shell and You grouped list
- contrast token tests for accent, secondary, tertiary, badge, and tab/header colors
- screenshot/snapshot comparisons later for Today, Goals, Goal Detail, Capture, Plan, You, Trust Center, What Ambitions Knows, onboarding, and empty states
- accessibility assertions for row labels/values/hints, tap targets, no color-only state, and focus not obscured

## Recommended Correction Strategy

Do not implement in this audit pass. The next correction pass should proceed in this order:

1. Global shell/chrome/safe-area/tab-bar fix.
2. Theme and color token fix.
3. You page rewrite to Settings-style grouped navigation.
4. Typography/readability/Dynamic Type fix.
5. Surface-by-surface layout compression pass.
6. Screenshot/snapshot QA test additions.
7. Visual acceptance checklist.

## Release Posture Impact

Current UI should block:

- investor demo
- TestFlight
- App Store screenshots
- public release claims
- visual approval
- accessibility approval
- final RC lock

R01-R05 completion history should not be changed. Those rows remain completed for planning/evidence purposes, but this red-team audit adds a new visual/product blocker that must be corrected before any demo/release posture upgrade.

## Correction Pass 1 Status

Date: 2026-04-29.

Status: implementation correction pass completed in source, with simulator/unit/UI validation still required before any visual approval claim. Release posture remains blocked for investor demo, TestFlight, App Store screenshots, public release claims, accessibility approval, and RC lock.

What was fixed:

- VQA-001: the global add control now lives in an explicit bottom safe-area lane with a stable accessibility identifier instead of being manually padded over the tab-bar region; the tab bar uses opaque UIKit appearance.
- VQA-002 and VQA-011: the app shell header now uses a simplified title/subtitle layout, an opaque/elevated theme material, a stable `shell.header.rail` identifier, and stronger separation from scrolling content.
- VQA-003, VQA-004, VQA-014, and VQA-022: the You root is now list-first. The prior long stack of hero/control/trust/memory/review/appearance/defaults/integration cards was moved behind grouped navigation rows and detail sheets.
- VQA-005 and VQA-009: `GroupedNavigationList` rows now use a fixed icon lane, flexible one-line title/subtitle behavior at normal sizes, constrained trailing status width, and an accessibility-size stacked fallback.
- VQA-006 through VQA-008: dark/light theme tokens were strengthened for text, overlays, strokes, tab labels, and header surfaces. Appearance remains a first-section row and opens Appearance Studio directly.
- VQA-013: root-level You copy was shortened to row labels plus one-line subtitles; verbose explanatory material now lives behind rows.

What remains blocked:

- VQA-012, VQA-015, VQA-016 through VQA-020, VQA-024, and VQA-025 remain partially or fully open. Today, Goals, Goal Detail, Capture, and Plan still need a surface-by-surface visual compression pass and screenshot/manual review.
- Contrast is improved through token changes, but no measured contrast audit was run and no accessibility claim is made.
- Dynamic Type resilience is improved for grouped rows, but no simulator Dynamic Type screenshot pass or VoiceOver traversal was run.
- Screenshot/snapshot automation still does not exist for visual approval and was not introduced in this pass.

Tests added or hardened:

- Shell UI smoke now asserts canonical tab buttons are hittable, verifies `shell.header.rail` and `shell.floating-control-lane`, and checks the global add button frame does not intersect the tab bar.
- You UI smoke now requires the `you.root` grouped navigation root, required top sections, first-screen Appearance, What Ambitions Knows, and Trust Center rows, and row order with Appearance above memory/trust rows.
- Appearance UI smoke now opens Appearance Studio through the top `Appearance` row instead of scrolling through a card stack.
- Profile service tests now enforce the required You grouped sections and row order.
- Appearance/theme tests now verify system/light/dark root theme resolution and opaque chrome token behavior.
- Grouped navigation tests now include the long labels that previously broke visually: `Integrations`, `Personalization`, `Accessibility`, `Widgets / Live Activities / Shortcuts`, and `What Ambitions Knows`.

Visual limitations not proven by automation:

- No new screenshots were captured in this correction pass.
- No pixel snapshot comparison, measured contrast test, real-device safe-area proof, VoiceOver audit, Dynamic Type screenshot pass, or App Store screenshot review was completed.
- The implementation is materially more aligned with the audit direction, but it is not visually approved until a human simulator/device review and screenshot QA pass confirm the rendered result.

Manual review items:

- Verify the tab bar is visible and readable on all five top-level tabs in light and dark mode.
- Verify the header does not overlap the status bar/Dynamic Island and that scroll content does not visually bleed through it.
- Verify the You root reads as an Ambitions-flavored Settings-style grouped list, with no awkward hyphenation in `Integrations`, `Personalization`, or `Accessibility`.
- Verify Appearance, What Ambitions Knows, and Trust Center are immediately discoverable.
- Verify the floating add lane does not obscure content, tab labels, or the home indicator.
- Verify dark mode and light mode visibly differ after saving Appearance settings.
- Run the next pass as either surface-by-surface polish plus screenshot QA, or manual simulator review before further source polishing.
