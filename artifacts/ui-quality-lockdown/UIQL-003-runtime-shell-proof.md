# AMB-958 / UIQL-003 Runtime Shell Proof Refresh

Status: Candidate Green for read-only runtime shell ownership proof
Program: UIQL - Ambitions Flagship UI Quality Lockdown
Actual Linear issue: AMB-958
UIQL label: UIQL-003
Date: 2026-06-11
Branch: `main`
Start HEAD: `783fe8566f70c269edd2dd53646a4350c1ef425c`

## Scope

This report refreshes the current runtime shell ownership map from live source. It does not repair UI, change app behavior, run a visual approval pass, or certify accessibility.

The purpose is to prevent later UIQL issues from assuming the wrong root shell, treating preview/support shell code as the live runtime, or using stale AOR/synthetic UIQL artifacts as current shell proof.

## Evidence Inspected

- `Native/Ambitions/App/AmbitionsApp.swift`
- `Native/Ambitions/UI/LaunchGateView.swift`
- `Native/Ambitions/App/AmbitionsRootView.swift`
- `Native/Ambitions/App/AppTab.swift`
- `Native/Ambitions/App/AppNavigation.swift`
- `Native/Ambitions/App/ShellCommandRouter.swift`
- `Native/Ambitions/App/AppShellView.swift`
- `Native/Ambitions/App/AppMeridianShell.swift`
- `Native/Ambitions/App/AppShellPresentationMode.swift`
- Active surface roots under `Native/Ambitions/Features/Today`, `Goals`, `Time`, `Motion`, `You`, and `Capture`

## Commands And Logs

| Command | Exit | Artifact |
| --- | ---: | --- |
| `git status --short --branch; git rev-parse HEAD` | 0 | `artifacts/ui-quality-lockdown/script-output/AMB-958-runtime-shell-repo-state.log` |
| `rg -n "@main|struct .*App: App|LaunchGateView|AmbitionsRootView|AppMeridianShell|TabView|NavigationStack|WindowGroup" Native Sources --glob "*.swift"` | 0 | `artifacts/ui-quality-lockdown/script-output/AMB-958-runtime-shell-root-scan.log` |
| `rg -n "case today|case goals|case time|case motion|case you|case capture|selectedTab|activeTab|TabView" Native Sources --glob "*.swift"` | 0 | `artifacts/ui-quality-lockdown/script-output/AMB-958-runtime-shell-tab-scan.log` |
| `rg -n "safeAreaInset|ignoresSafeArea|toolbarBackground|toolbar\\(|overlay\\(|zIndex|fullScreenCover|sheet\\(" Native/Ambitions/App Sources --glob "*.swift"` | 0 | `artifacts/ui-quality-lockdown/script-output/AMB-958-runtime-shell-overlay-scan.log` |
| `python3` source contract check for root tab values and Capture canonicalization | 0 | `artifacts/ui-quality-lockdown/script-output/AMB-958-runtime-shell-contract-check.log` |

## Runtime Path

The live app entry path is:

`AmbitionsApp` -> `LaunchGateView` -> `AmbitionsRootView` -> native `TabView` -> active surface root.

Source proof:

- `AmbitionsApp` is the `@main` SwiftUI app and creates `LaunchGateView` inside `WindowGroup`.
- `LaunchGateView` routes `.ready(container)` to `AmbitionsRootView(container: container)`.
- `AmbitionsRootView` owns the root `ZStack`, root `TabView`, shell Capture seam, continuity receipt, sheet overlays, onboarding full-screen cover, theme injection, and tab-bar appearance.

## Ownership Map

| Runtime concern | Current owner | Evidence |
| --- | --- | --- |
| App entry | `Native/Ambitions/App/AmbitionsApp.swift` | `@main` app, `WindowGroup`, `LaunchGateView(bootstrapper:)` |
| Launch gate | `Native/Ambitions/UI/LaunchGateView.swift` | `.ready(container)` routes to `AmbitionsRootView`; loading/failure are launch-gate scaffolds only |
| Root runtime shell | `Native/Ambitions/App/AmbitionsRootView.swift` | `ZStack` with `shellTabView`, activated Capture seam, continuity receipt |
| Actual top-level tab owner | `AmbitionsRootView.shellTabView(theme:)` | Native `TabView(selection: $navigation.selectedTab)` |
| Active top-level tabs | `AppTab.allCases` plus explicit root `Tab` declarations | `Today / Goals / Time / Motion / You`; no top-level Capture tab |
| Header owner | `AppShellScaffold` and `AppShellHeaderRail` in `AppShellView.swift` | Active roots wrap content in `AppShellScaffold`; header uses `safeAreaInset(edge: .top)` |
| Dock/tab-bar owner | `AmbitionsRootView.shellTabView(theme:)` and `configureTabBarAppearance(with:)` | Native `.tabBar` toolbar background/color visibility plus UIKit tab bar appearance |
| Capture header entry | `AmbitionsRootView.shellUtilityButtons(for:)` | Each active root gets a toolbar Capture button wired to `presentSurfaceCapture(for:)` |
| Activated Capture overlay | `AmbitionsRootView.shellActivatedCaptureComposerSeam(theme:)` and `AppShellActivatedCaptureSeam` | Rendered only when `navigation.activeOverlay?.isActivatedCaptureComposer` |
| Sheet overlay owner | `AmbitionsRootView.activeSheetOverlayBinding` and `AppShellOverlayView` | Non-activated overlays render through SwiftUI `.sheet` |
| Receipt overlay owner | `AmbitionsRootView.shellContinuityReceipt(theme:)` | Renders `AmbitionActionClosureTray` for `navigation.continuityReceipt` |
| Navigation state | `AppNavigationModel` | Owns `selectedTab`, paths, overlay, receipt, and canonicalizes tab selection |
| Capture compatibility routing | `AppNavigationModel`, `ShellCommandRouter` | Capture tab requests route to Capture overlay/Time support, not a sixth root tab |

## Active Surface Roots

| Top-level tab | Active root path | Notes |
| --- | --- | --- |
| Today | `TodayScreen(showsNavigationChrome: false)` inside `AppShellScaffold(title: "Today", subtitle: "Execution")` | Root source owner remains `Native/Ambitions/Features/Today/TodayScreen.swift` |
| Goals | `GoalsScreen(... showsNavigationChrome: false, onCreateGoal: ...)` inside `AppShellScaffold(title: "Goals", subtitle: "Direction")` | Goal detail navigation stays under Goals path |
| Time | `TimeScreen(showsNavigationChrome: false)` inside `AppShellScaffold(title: "Time", subtitle: "Shape Time")` | Capture inbox is a Time support route, not a top-level tab |
| Motion | `MotionCurrentScreen()` inside `AppShellScaffold(title: "Motion", subtitle: "Motion Current")` | Root accessibility identifier is `motion.current.screen` |
| You | `YouScreen(showsNavigationChrome: false)` inside `AppShellScaffold(title: "You", subtitle: "Control")` | Monthly review and history stay under You path |

## AppMeridianShell Classification

`Native/Ambitions/App/AppMeridianShell.swift` is not the active runtime root shell for the current app path.

Current evidence:

- `AmbitionsRootView` does not instantiate `AppMeridianDestinationRail`.
- `AppMeridianShell.swift` defines `AppMeridianDestinationRail` and a `#if DEBUG` preview host.
- `rg` finds `AppMeridianDestinationRail` use only in `AppMeridianShell.swift` preview/support code, `AppShellPresentationMode.swift`, and tests.
- `AppShellPresentationMode` still exists as support/compatibility state, but current runtime shell proof must start from `AmbitionsApp` -> `LaunchGateView` -> `AmbitionsRootView`.

Allowed use: source orientation, preview/support compatibility, and tests.

Forbidden use: claiming `AppMeridianShell.swift` is the live runtime shell, dock owner, header owner, receipt owner, or Capture overlay owner without new source proof.

## Preview / Runtime Mismatch

Known mismatch:

- AppMeridian preview/support code can render a custom destination rail, but the current runtime path uses native `TabView` inside `AmbitionsRootView`.
- Legacy/synthetic UIQL artifacts named `UIQL-001` through `UIQL-007` may contain useful partial repo evidence, but they are not AMB-958 closeout proof unless explicitly cited and bounded in this report.
- AOR screenshots remain superseded for UIQL flagship quality proof; they are not runtime shell proof.

## UIQL Firewall Closeout Block

- Actual Linear issue: AMB-958.
- UIQL label: UIQL-003.
- Active root/source dependency: Green. The current runtime root path is proven from `@main` app entry to `AmbitionsRootView`.
- Product object: Not applicable to this report-only gate; no surface product Green is claimed.
- Surface owner: Green. Current top-level owners are Today, Goals, Time, Motion, You under `AmbitionsRootView`.
- Existing primitives: Green for ownership classification only. This report does not add primitives.
- Red conditions checked: Green. The report does not assume a root shell without source proof, does not treat preview-only shell code as live runtime, and does not skip dock/header/receipt/overlay ownership.
- Screenshot paths: Not applicable. No screenshot approval is claimed.
- Accessibility variants: Not applicable. Current source identifies accessibility identifiers/labels where inspected, but this is not accessibility certification.
- Copy/canon scan: Not a source-changing copy gate; current shell contract scan passed.
- No-new-primitive default: Green. No source or primitive edits.
- Candidate Green closeout: Green for read-only runtime ownership proof.

## Red / Yellow / Green

Green:

- Active runtime path proven from source.
- Active root top-level tabs are exactly `Today / Goals / Time / Motion / You`.
- Capture is proven as global/support overlay and Time support route, not a top-level tab.
- Header, dock/tab-bar, receipt overlay, sheet overlay, and activated Capture overlay owners are identified.
- AppMeridian status is classified as preview/support/test-compatible, not active runtime root shell.
- No app source, tests, project files, dependencies, or runtime behavior changed.

Yellow:

- No visual approval, screenshot matrix, Dynamic Type matrix, VoiceOver audit, Reduce Motion audit, Increase Contrast audit, physical-device proof, performance proof, or release proof was run because AMB-958 is read-only shell ownership proof.
- Prior synthetic UIQL source commits remain partial evidence only and still require actual AMB issue closeouts before they can close later Linear issues.

Red:

- None for AMB-958 report-only scope.

## Non-Claims

This report does not claim:

- UI repair or product implementation completion.
- Screenshot approval or visual quality approval.
- Accessibility certification.
- Owner approval.
- Release readiness, TestFlight readiness, App Store readiness, CI proof, physical-device proof, performance proof, or privacy/legal approval.
- Closure of AMB-959 or any later surface reconstruction issue.

## Next Dependency

Next executable issue after AMB-958 push and Linear closeout: AMB-959 / UIQL-004 - Shell Safe-Area + Dock Legibility Repair.

Do not start AMB-959 until this report is committed, pushed to `main`, and AMB-958 is updated by actual AMB issue ID.
