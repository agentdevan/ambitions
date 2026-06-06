# AOR-010 Surface Composition Audit

Status: Green for read-only audit scope
Issue: AMB-528 / AOR-010
Date: 2026-06-06

This report maps the described Red baseline failures to live source. It is not visual approval, screenshot approval, accessibility proof, release proof, or implementation completeness proof.

## Scope Boundary

- Repo branch during audit: `main`
- Starting HEAD: `827a5389bd30599ef1710cb6bc1fc3f5380e3336`
- UI/product source edited: no
- App tests/builds run: no, not required for this read-only audit
- Baseline screenshot attachment: not available in the Linear issue payload returned to Codex; this report maps the issue-described screenshot failures and screenshot-visible strings to live source.

## Commands Run

```bash
rg -n "Card|HeroCard|SurfaceCard|ModuleCard|Tile|Panel|Banner|Pill|Chip|RoundedRectangle|cornerRadius|shadow|ultraThinMaterial|thinMaterial|LinearGradient|RadialGradient|background\\(|opacity\\(" Native Sources --glob "*.swift"
rg -n "Today keeps one important step|Reality Meridian continuity|Start Here emerges|Goals keeps direction|Time shapes the week|No Motion Yet|Source Unavailable|User System Profile|Your System" Native Sources --glob "*.swift"
rg -n "Dashboard|Assistant|AI recommends|best next move|next best move|overdue|failed|streak|score|optimize|smart capture|Plan tab|Profile tab|Pulse|Capture tab|DayTimelineRail|Hero Step Panel|Hero Step Module|Calendar tab|Inbox tab" Native Sources docs --glob "*.swift" --glob "*.md"
```

The broad styling command intentionally returns many design-system, preview, test, and generated hits. Active runtime classification below is based on the AMB-525 runtime path plus direct source reads.

## Active Runtime Path

Active launch path remains:

`AmbitionsApp -> LaunchGateView -> AmbitionsRootView -> shellTabView(theme:) -> SwiftUI TabView`

Evidence:

- `Native/Ambitions/App/AmbitionsRootView.swift:29` defines the root `body`.
- `Native/Ambitions/App/AmbitionsRootView.swift:35` mounts `shellTabView(theme:)`.
- `Native/Ambitions/App/AmbitionsRootView.swift:91` defines the active `TabView`.
- `Native/Ambitions/App/AmbitionsRootView.swift:93` through `Native/Ambitions/App/AmbitionsRootView.swift:110` mount only `Today`, `Goals`, `Time`, `Motion`, and `You`.
- `Native/Ambitions/App/AmbitionsRootView.swift:199` through `Native/Ambitions/App/AmbitionsRootView.swift:208` mount `CaptureScreen()` only as a Time-owned support route.
- `Native/Ambitions/App/AmbitionsRootView.swift:293` through `Native/Ambitions/App/AmbitionsRootView.swift:303` mount Capture as toolbar action, not as a tab.

## Required Surface Table

| Surface | Active root | Screenshot strings found | Root card/panel count | Local styling overrides | Banned/stale terms | Failure class | Owner issue |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Today | `AmbitionsRootView.todayNavigation()` -> `TodayScreen(showsNavigationChrome: false)` -> `RealityMeridianView` | `Today keeps one important step in view.` from shell posture; `Reality Meridian continuity` and `Start Here emerges...` from Day Rail projection | 1 primary object (`RealityMeridianView`) plus fallback state; no root `AppCard` stack in `TodayScreen` loaded path | `TodayBackgroundView`, `fusedCurrentTimeCursor`, shell safe-area header | `failed` appears only as async enum branch/source state, not active product copy | Active runtime; comparatively closest to one-primary-object but still under global shell rail | AOR-TODAY-00 |
| Time | `AmbitionsRootView.timeNavigation()` -> `TimeScreen(showsNavigationChrome: false)` | `Time shapes the week only with confirmation.` from shell posture; `LifeShape Field depth`, `Shape Time`, Day/Week/Month chips | 5 immediate loaded modules before the depth disclosure: composition bar, `TimeLifeShapeField`, `TimeHeroCard`, `TimeScopeChipStrip`, `TimeCapacityEnvelopeCard`; depth disclosure contains 17+ additional card/panel modules | `LivingSurfaceBackground(context: .plan)`, `HeroCard`, `StateDrivenMaterialPanel`, `AppCard`, `TagPill`, rounded overlays | `.plan` is internal compatibility context; `TimeDashboard` is type naming; `score` is internal sorting math, not visible active copy in inspected root | Active runtime root card/panel stack and chip strip; LifeShape object does not fully own first screen | AOR-TIME-00 |
| Motion | `AmbitionsRootView.motionNavigation()` -> `MotionCurrentScreen()` | `No Motion Yet`, `Source Unavailable`, `Motion Current` | One segmented strand picker plus a `ForEach` of `MotionCurrentNodeCard` cards from static fixture projection | `QuietGlass`, source/proof/receipt row grid, `luminousTrace` | `ProofPulse`/`pulse` hits exist in reusable primitives, not current tab truth; `No Motion Yet` and `Source Unavailable` are active placeholder strings | Active runtime placeholder/card-list pattern; proof/inspection source is fixture-like and not yet a richer current object | AOR-MOTION-00 |
| Goals | `AmbitionsRootView.goalsNavigation()` -> `GoalsScreen(showsNavigationChrome: false)` | `Goals keeps direction connected to the next step.` from shell posture; Goals loaded path uses atlas/life-area/north-star/depth labels | 5+ immediate root modules: composition bar, `GoalMissionControlLanes`, optional creation `AppCard`, optional `GoalAtlasPreviewCard`, `GoalsLifeAreasPanel`, `GoalsNorthStarsRailCard`, empty/depth state; depth disclosure adds 10+ card/panel modules | `LivingSurfaceBackground`, `AppCard`, `GoalAtlasPreviewCard`, `Goals*Card`, `StateDrivenMaterialPanel`, `.ambitionPanel` transitions | `Task` appears in `This can become a goal later... standalone Task`; should be reviewed for task-manager drift | Active runtime card/panel stack; Constellation/Direction object competes with multiple modules | AOR-GOALS-00 |
| You | `AmbitionsRootView.youNavigation()` -> `YouScreen(showsNavigationChrome: false)` -> `PersonalSystemCenterRootView` | `Your System`, `User System Profile`, `Trust & Automation`, `Privacy`, `Receipts & History`, `Defaults` | Root has composition bar plus one `PersonalSystemCenterRootView`; the detail sheet has many `You*Card` sections | `LivingSurfaceBackground(context: .you)`, grouped navigation primitives, setup completeness, detail sheet cards | `profileProjection` is internal model naming; `User System Profile` is allowed active copy | Active runtime settings-style surface with extra composition band; detail cards are drill-down, not root | AOR-YOU-00 |
| Capture | No top-level tab. Active paths are global toolbar Capture, activated composer seam, and Time support route to `CaptureScreen()` | `Capture`, `Capture Anything`, `What needs a place?`, `Needs a Place`, `Ready to Place`, `Grow into Goal` | Global seam: one activated composer panel; Time support route: composition bar, `AtmosphereComposerCanvas`, optional depth disclosure and capture cards | `TopLevelSurfaceCompositionBar(surface: .capture)`, `AtmosphereComposerCanvas`, `StateDrivenMaterialPanel`, `AppCard`, `ContextCrownHeader` | `CaptureScreenShellMode.topLevelCapture` and `AmbitionsTopLevelSurfaceComposition.case capture` are active-support stale residue because Capture is not an active top-level tab | Active support route/global action; support code still preserves top-level Capture wording and component enum | AOR-CAPTURE-00 |
| Global Chrome | `AmbitionsRootView.shellTabView(theme:)` plus `AppShellScaffold` | Shell header/ribbon shows title/subtitle/posture continuity copy; toolbar has Capture and memory-lens actions | One safe-area header rail on every tab plus two trailing shell utility buttons | `safeAreaInset(edge: .top)`, tab bar material/tint, header rail posture icons, toolbar buttons | Top-level TabView is correct; Capture is toolbar action, not tab | Active runtime shell header/ribbon and detached utility chrome visible across surfaces | AOR-CHROME-00 |

## Source Excerpts And Classifications

### Active Runtime

- `Native/Ambitions/App/AmbitionsRootView.swift:91` -> `TabView(selection: $navigation.selectedTab)`.
- `Native/Ambitions/App/AmbitionsRootView.swift:93` -> Today tab mounts `todayNavigation()`.
- `Native/Ambitions/App/AmbitionsRootView.swift:97` -> Goals tab mounts `goalsNavigation()`.
- `Native/Ambitions/App/AmbitionsRootView.swift:101` -> Time tab mounts `timeNavigation()`.
- `Native/Ambitions/App/AmbitionsRootView.swift:105` -> Motion tab mounts `motionNavigation()`.
- `Native/Ambitions/App/AmbitionsRootView.swift:109` -> You tab mounts `youNavigation()`.
- `Native/Ambitions/App/AppShellView.swift:127` through `Native/Ambitions/App/AppShellView.swift:138` -> `AppShellScaffold` injects top shell header rail.
- `Native/Ambitions/App/AmbitionsRootView.swift:293` through `Native/Ambitions/App/AmbitionsRootView.swift:303` -> global toolbar Capture and memory-lens buttons.

### Active Runtime Surface Roots

- `Native/Ambitions/Features/Today/TodayScreen.swift:28` through `Native/Ambitions/Features/Today/TodayScreen.swift:69` -> `RealityMeridianView` is the loaded Today object.
- `Native/Ambitions/Features/Goals/GoalsScreen.swift:35` through `Native/Ambitions/Features/Goals/GoalsScreen.swift:116` -> loaded Goals stacks mission-control lanes, atlas preview, life areas, north stars, and depth disclosure.
- `Native/Ambitions/Features/Time/TimeScreen.swift:21` through `Native/Ambitions/Features/Time/TimeScreen.swift:83` -> loaded Time stacks LifeShape Field, hero card, chip strip, capacity envelope, and depth disclosure.
- `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:15` through `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:43` -> Motion renders a segmented picker plus node card list.
- `Native/Ambitions/Features/You/YouScreen.swift:23` through `Native/Ambitions/Features/You/YouScreen.swift:47` -> You renders composition bar plus `PersonalSystemCenterRootView`.
- `Native/Ambitions/Features/Capture/CaptureScreen.swift:32` through `Native/Ambitions/Features/Capture/CaptureScreen.swift:97` -> Capture support route renders composer canvas plus optional depth/cards and crown header.

### Preview-Only

- `Native/Ambitions/Features/Today/TodayScreen.swift:404` through `Native/Ambitions/Features/Today/TodayScreen.swift:421` -> Today previews.
- `Native/Ambitions/Features/Goals/GoalsScreen.swift:292` through `Native/Ambitions/Features/Goals/GoalsScreen.swift:324` -> Goals previews.
- Broad hits under `Sources/Previews/**` are preview-only unless separately mounted through active runtime.

### Debug-Only

- `Native/Ambitions/App/AppBootstrapper.swift` DEBUG screenshot arguments from AMB-526 are screenshot harness only; not a runtime product path.
- SwiftUI `#Preview` blocks guarded by `#if DEBUG` are debug/preview only.

### Dead/Stale Or Support-Only

- `Sources/Components/TopLevelSurfaceCompositionPrimitives.swift:4` through `Sources/Components/TopLevelSurfaceCompositionPrimitives.swift:10` includes `case capture` alongside Today/Goals/Time/You. This is support component residue because active TabView does not include Capture.
- `Native/Ambitions/Features/Capture/CaptureScreen.swift:4` through `Native/Ambitions/Features/Capture/CaptureScreen.swift:7` includes `topLevelCapture`; this is not mounted by active TabView and should stay classified as stale/support unless a scoped route explicitly needs it.
- `Native/Ambitions/App/AppShellPresentationMode.swift:55` through `Native/Ambitions/App/AppShellPresentationMode.swift:102` defines Meridian shell state. AMB-525 classified Meridian shell as support/preview-compatible rather than active root owner.

### Indirect/Generated

- `Sources/Theme/AmbitionsFrontendAuthority.generated.swift` hits are generated authority records and must not be treated as live rendered proof.
- `Sources/Accessibility/AccessibilityNutrition.swift` hits are checklist/proof-contract data, not direct screen rendering.
- Test hits under `Native/AmbitionsTests/**` and `Native/AmbitionsUITests/**` are validation source, not active UI.

### Unknown

- Widget/Live Activity hits under `Native/AmbitionsWidgetExtension/**` are external surfaces and are outside this AOR-010 top-level app shell audit.

## Banned/Stale Term Notes

- No active TabView `Pulse`, `Capture`, `Plan`, `Calendar`, `Inbox`, `Review`, or `Profile` tab was found.
- `Pulse` appears in reusable proof/motion primitive names such as `ProofPulse` and animation flags, not as active current tab truth.
- `failed` appears widely as async/result state naming and test data; the inspected roots do not present it as shame copy in the loaded first-screen paths.
- `Dashboard` appears in model/service/test names such as `TimeDashboard` and `YouDashboard`; this is internal naming residue, not necessarily visible UI copy.
- `TopLevelSurfaceCompositionPrimitives` still models `Capture` as a top-level composition case; this is the clearest active-support stale-canon residue discovered in this audit.

## Owner Assignments

- AOR-TODAY-00: Today should preserve `RealityMeridianView` as the primary object while reducing shell/header interference.
- AOR-GOALS-00: Goals should collapse multi-card root competition into one Direction/Constellation primary object and move depth to drill-down.
- AOR-TIME-00: Time should make LifeShape Field own the first screen and demote chip/card/depth sprawl.
- AOR-MOTION-00: Motion should replace fixture-like card list composition with a richer Motion Current object and proof/progress inspection flow.
- AOR-YOU-00: You should keep settings-style grouping while removing composition-band clutter and ensuring User System Profile owns the screen.
- AOR-CAPTURE-00: Capture should remain global composer/support route only; remove/demote top-level Capture residue in support primitives.
- AOR-CHROME-00: Global chrome should reduce the shell header/ribbon and detached utility chrome that appears above every surface.

## Green Gate Result

- Exact active files/views/line excerpts identified: yes.
- Failure owners assigned: yes.
- Preview/debug/dead/generated/test hits separated: yes.
- UI/product source edited: no.
- Visual success/readiness claimed: no.
