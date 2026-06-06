# AOR-001 Report - Active Runtime Path

Status: Green for runtime-path proof, with a runner-process Yellow noted below.
Issue: AMB-525
Date: 2026-06-06
Branch: `main`
Commit inspected: `4f841ec4b98b7e42fc51bdc0ea3e6199c9b53676`

## Boundary

This report proves source-level runtime routing only. It does not prove visual quality, screenshot approval, accessibility conformance, performance, device behavior, privacy/legal approval, TestFlight readiness, App Store readiness, production readiness, or release readiness.

No UI/product source files were edited for this proof packet.

## Required Commands Run

```bash
git status --short --branch
git rev-parse --show-toplevel
git rev-parse HEAD
find . -maxdepth 4 \( -name "*.xcodeproj" -o -name "*.xcworkspace" -o -name "Package.swift" \) -print
rg -n "@main|struct .*App: App|LaunchGateView|AmbitionsRootView|AppMeridianShell|TabView|NavigationStack|NavigationSplitView|WindowGroup" . --glob "*.swift"
rg -n "enum .*Tab|enum .*Surface|case today|case goals|case time|case motion|case you|case capture|selectedTab|activeTab|TabView" Native Sources --glob "*.swift"
```

## Command Results

`git status --short --branch`:

```text
## main...origin/main
?? prompts/batches/AMB-525.md
```

`git rev-parse --show-toplevel`:

```text
/Users/devan/Documents/GitHub/ambitions
```

`git rev-parse HEAD`:

```text
4f841ec4b98b7e42fc51bdc0ea3e6199c9b53676
```

`find` result:

```text
./Ambitions.xcodeproj
./Ambitions.xcodeproj/project.xcworkspace
./Packages/AmbitionsExperienceKernel/Package.swift
./Package.swift
```

## Root App Entry

Proven: yes.

`Native/Ambitions/App/AmbitionsApp.swift:3-15` proves the app entry:

```swift
@main
@MainActor
struct AmbitionsApp: App {
    var body: some Scene {
        WindowGroup {
            LaunchGateView(bootstrapper: bootstrapper)
```

Classification: active runtime entry.

## LaunchGateView Active

Active: yes.

`Native/Ambitions/App/AmbitionsApp.swift:14-15` opens `LaunchGateView` in the app `WindowGroup`.

`Native/Ambitions/UI/LaunchGateView.swift:4-13` proves the ready path:

```swift
struct LaunchGateView: View {
    @Bindable var bootstrapper: AppBootstrapper

    var body: some View {
        AppCanvasView {
            switch bootstrapper.phase {
            case .idle, .launching:
                loadingView
            case let .ready(container):
                AmbitionsRootView(container: container)
```

Classification: active launch gate.

## AmbitionsRootView Active

Active: yes.

`Native/Ambitions/UI/LaunchGateView.swift:12-13` opens `AmbitionsRootView(container:)` after bootstrap readiness.

`Native/Ambitions/App/AmbitionsRootView.swift:7-37` proves the root view owns the shell body and calls `shellTabView(theme:)`:

```swift
struct AmbitionsRootView: View {
    private let container: AppContainer
    private let shellPresentationMode: AppShellPresentationMode
    @State private var navigation: AppNavigationModel

    var body: some View {
        ZStack(alignment: .bottom) {
            shellTabView(theme: resolvedTheme)
            shellActivatedCaptureComposerSeam(theme: resolvedTheme)
            shellContinuityReceipt(theme: resolvedTheme)
```

Classification: active runtime root.

## Actual Tab/Dock Owner

Owner: `AmbitionsRootView.shellTabView(theme:)`.

`Native/Ambitions/App/AmbitionsRootView.swift:91-112` proves the actual SwiftUI tab owner:

```swift
private func shellTabView(theme: AmbitionTheme) -> some View {
    TabView(selection: $navigation.selectedTab) {
        Tab(AppTab.today.title, systemImage: AppTab.today.systemImage, value: AppTab.today) {
            todayNavigation()
        }
        Tab(AppTab.goals.title, systemImage: AppTab.goals.systemImage, value: AppTab.goals) {
            goalsNavigation()
        }
        Tab(AppTab.time.title, systemImage: AppTab.time.systemImage, value: AppTab.time) {
            timeNavigation()
        }
        Tab(AppTab.motion.title, systemImage: AppTab.motion.systemImage, value: AppTab.motion) {
            motionNavigation()
        }
        Tab(AppTab.you.title, systemImage: AppTab.you.systemImage, value: AppTab.you) {
            youNavigation()
        }
    }
```

`Native/Ambitions/App/AppTab.swift:6-15` proves active `allCases` are Today / Goals / Time / Motion / You:

```swift
case today
case goals
case time
case motion
case you
case capture

static var allCases: [AppTab] {
    [.today, .goals, .time, .motion, .you]
}
```

Classification: active top-level tabs are five canonical tabs. `case capture` remains as a compatibility route, not a top-level tab because it is excluded from `AppTab.allCases` and absent from `AmbitionsRootView.shellTabView`.

## AppShellView Status

Status: active support.

`Native/Ambitions/App/AppShellView.swift` is not the root shell, but it defines support views used by `AmbitionsRootView`:

- `AppShellScaffold` at `Native/Ambitions/App/AppShellView.swift:100`
- `AppShellOverlayView` at `Native/Ambitions/App/AppShellView.swift:306`
- `AppShellActivatedCaptureSeam` at `Native/Ambitions/App/AppShellView.swift:619`

`rg` confirms `AmbitionsRootView` calls these support types:

```text
Native/Ambitions/App/AmbitionsRootView.swift:57: AppShellOverlayView
Native/Ambitions/App/AmbitionsRootView.swift:145: AppShellScaffold
Native/Ambitions/App/AmbitionsRootView.swift:318: AppShellActivatedCaptureSeam
```

Classification: support, not root owner.

## AppMeridianShell Status

Status: support/preview only.

`Native/Ambitions/App/AppMeridianShell.swift:4-9` defines `AppMeridianDestinationRail`, not an app/root shell:

```swift
struct AppMeridianDestinationRail: View {
    let theme: AmbitionTheme
    let selectedTab: AppTab
    let onSelect: (AppTab) -> Void
```

`Native/Ambitions/App/AppMeridianShell.swift:134-170` wraps it in `#if DEBUG` previews:

```swift
#if DEBUG
private struct AppMeridianDestinationRailPreviewHost: View {
    @State private var selectedTab: AppTab = .today
...
#Preview("App Meridian Shell") {
    AppMeridianDestinationRailPreviewHost()
}
```

`rg "AppMeridianDestinationRail"` finds no runtime caller outside `AppMeridianShell.swift`; references are its declaration and previews only.

Classification: support/preview. It is not the live runtime root and must not be assumed active.

## Surface Roots

### Today Root

Proven: `AmbitionsRootView.todayNavigation()` opens `TodayScreen(showsNavigationChrome: false)`.

Source:

- `Native/Ambitions/App/AmbitionsRootView.swift:143-152`
- `Native/Ambitions/Features/Today/TodayScreen.swift:4-28`

Line excerpt:

```swift
private func todayNavigation() -> some View {
    NavigationStack {
        AppShellScaffold(...) {
            TodayScreen(showsNavigationChrome: false)
        }
    }
}
```

### Goals Root

Proven: `AmbitionsRootView.goalsNavigation()` opens `GoalsScreen(...)`.

Source:

- `Native/Ambitions/App/AmbitionsRootView.swift:156-180`
- `Native/Ambitions/Features/Goals/GoalsScreen.swift:4-35`

Line excerpt:

```swift
private func goalsNavigation() -> some View {
    NavigationStack(path: $navigation.goalsPath) {
        AppShellScaffold(...) {
            GoalsScreen(
                externalCreationMessage: creationMessage,
                externalRefreshID: goalsRefreshID,
                showsNavigationChrome: false,
                onCreateGoal: { presentCreateGoal(from: .goalsCreate) }
            )
        }
    }
}
```

### Time Root

Proven: `AmbitionsRootView.timeNavigation()` opens `TimeScreen(showsNavigationChrome: false)`.

Source:

- `Native/Ambitions/App/AmbitionsRootView.swift:187-196`
- `Native/Ambitions/Features/Time/TimeScreen.swift:4-44`

Line excerpt:

```swift
private func timeNavigation() -> some View {
    NavigationStack(path: $navigation.timePath) {
        AppShellScaffold(...) {
            TimeScreen(showsNavigationChrome: false)
        }
```

### Motion Root

Proven: `AmbitionsRootView.motionNavigation()` opens `MotionCurrentScreen()`.

Source:

- `Native/Ambitions/App/AmbitionsRootView.swift:240-249`
- `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:4-48`

Line excerpt:

```swift
private func motionNavigation() -> some View {
    NavigationStack {
        AppShellScaffold(...) {
            MotionCurrentScreen()
                .accessibilityIdentifier("motion.current.screen")
        }
    }
}
```

### You Root

Proven: `AmbitionsRootView.youNavigation()` opens `YouScreen(showsNavigationChrome: false)`.

Source:

- `Native/Ambitions/App/AmbitionsRootView.swift:254-263`
- `Native/Ambitions/Features/You/YouScreen.swift:7-61`

Line excerpt:

```swift
private func youNavigation() -> some View {
    NavigationStack(path: $navigation.youPath) {
        AppShellScaffold(...) {
            YouScreen(showsNavigationChrome: false)
        }
```

## Capture Route

Active Capture route: global/contextual overlay, not a top-level tab.

Evidence:

- `AppTab.capture` exists as a compatibility route in `Native/Ambitions/App/AppTab.swift:11`, but `AppTab.allCases` excludes it at `Native/Ambitions/App/AppTab.swift:13-15`.
- `AppTab.canonicalTopLevelTab` maps `.capture` to `.today` at `Native/Ambitions/App/AppTab.swift:60-67`.
- `AmbitionsRootView.shellUtilityButtons(for:)` creates a toolbar Capture button per active tab at `Native/Ambitions/App/AmbitionsRootView.swift:293-304`.
- `AmbitionsRootView.presentSurfaceCapture(for:)` presents `.quickCapture` with `.quickCapture` presentation context at `Native/Ambitions/App/AmbitionsRootView.swift:444-449`.
- `ShellOverlayState.isActivatedCaptureComposer` is true for quiet command sheet plus quick-capture intent/context at `Native/Ambitions/App/ShellCommandModels.swift:306-308`.
- `AmbitionsRootView.shellActivatedCaptureComposerSeam(theme:)` renders `AppShellActivatedCaptureSeam` only when the active overlay is the activated capture composer at `Native/Ambitions/App/AmbitionsRootView.swift:316-330`.

Line excerpt:

```swift
private func presentSurfaceCapture(for tab: AppTab) {
    container.commandRouter.presentCommandSheet(
        intent: .quickCapture,
        source: AppShellCaptureAccessModel.source(for: tab),
        presentationContext: .quickCapture
    )
}
```

Compatibility Capture route:

- `TimeRouteTarget.captureInbox` remains at `Native/Ambitions/App/AppNavigation.swift:29-30`.
- `openCapturesInbox()` routes through `openTimeRoute(.captureInbox)` at `Native/Ambitions/App/AppNavigation.swift:178-180`.
- `openTimeRoute(.captureInbox)` uses `presentCaptureCompatibilityRoute(source:)` and clears `timePath` at `Native/Ambitions/App/AppNavigation.swift:153-158`.

`CaptureScreen` still exists as a Time-support/detail route and reusable Capture surface source:

- `Native/Ambitions/Features/Capture/CaptureScreen.swift:4-20`
- `Native/Ambitions/App/AmbitionsRootView.swift:197-209`

Classification: active global overlay plus compatibility/detail route; not an active top-level tab.

## Preview/Runtime Mismatches

1. `AppMeridianShell.swift` has DEBUG previews named "App Meridian Shell", but no runtime caller was found. Treat it as support/preview until a runtime caller is added and proven.
2. `AppShellPresentationMode` can resolve `--ambitions-shell=meridian` or `AMBITIONS_SHELL_PRESENTATION`, but `AmbitionsRootView` only stores `shellPresentationMode` and does not branch on it in inspected source. The live root still calls `shellTabView(theme:)`.
3. `CaptureScreenShellMode.topLevelCapture` exists in `CaptureScreen`, but `AmbitionsRootView.shellTabView` does not include a Capture tab. Treat this as source compatibility/support, not active top-level IA.

## Feature Flags

Found:

- `AppShellPresentationMode.launchArgumentName = "--ambitions-shell"` and `environmentName = "AMBITIONS_SHELL_PRESENTATION"` at `Native/Ambitions/App/AppShellPresentationMode.swift:7-8`.
- `AppShellPresentationMode.resolved(...)` returns `.nativeFallback` by default at `Native/Ambitions/App/AppShellPresentationMode.swift:10-23`.
- No branch on `shellPresentationMode` was found in `AmbitionsRootView` beyond storing it at lines 12 and 21-24.

## Debug Gates

Found:

- `AppMeridianShell.swift` previews are wrapped in `#if DEBUG` at `Native/Ambitions/App/AppMeridianShell.swift:134-170`.
- `AppBootstrapper` contains DEBUG preview/live override handling, but this report did not validate runtime behavior under those debug paths.
- `AppContainerFactory` contains DEBUG seed/preview environment hooks such as `AMBITIONS_UI_SEED_CAPTURES` and `AMBITIONS_PREVIEW_TODAY_SCENARIO`.

## Unknowns

- This report did not run the app in Simulator and therefore does not prove what a rendered screenshot looks like.
- This report did not run unit tests, UI tests, accessibility audits, performance measurements, device checks, archive checks, or release checks.
- This report did not prove that `AppShellPresentationMode` is intentionally retained or obsolete; it only proves it is not currently used to choose the root path in inspected `AmbitionsRootView`.
- This report did not prove the quality or completeness of any feature root. It only proves routing and source ownership.

## Runner Process Note

The Ambitions runner was invoked as:

```bash
BATCH_TYPE=proof-only AUTO_BRANCH=0 ALLOW_MAIN_COMMIT=1 ALLOW_DIRTY=1 AUTO_COMMIT=0 AUTO_PUSH=0 KEEP_GOING_ON_YELLOW=1 MAX_REPAIR_PASSES=1 scripts/ambitions-codex-train.sh AMB-525 prompts/batches/AMB-525.md
```

Runner result: Yellow before patch phase.

Reason:

```text
Locked-path precheck found unauthorized candidate paths:
- design_primitives: Sources
- design_primitives: Native/Ambitions/UI
```

Classification: accepted process Yellow for this proof-only issue. The runner did not create a source patch or the required report. The required read-only commands were run directly after the runner stopped, and this report was created manually from current source evidence.

## Green Gate Review

- Actual `@main` entry is proven: yes.
- Live root path is proven with line excerpts: yes.
- Actual tab/dock owner is proven: yes, `AmbitionsRootView.shellTabView`.
- Active root SwiftUI view for each surface is proven: yes for Today, Goals, Time, Motion, You.
- Active Capture route is proven: yes, contextual/global overlay plus compatibility/detail route, not a top-level tab.
- UI/product source code edited: no.

Final AOR-001 proof status: Green for runtime-path proof, accepted Yellow for runner process precheck.
