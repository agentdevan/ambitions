# Ambitions 3.0 F17 Shell / Meridian Readiness Report

Date: 2026-05-01
Gate: Yellow
Batch: F17 Shell / Meridian Planning & Readiness Audit

## Executive Verdict

F17 is Yellow.

The current native shell preserves top-level destination access, deep links,
App Intents, widgets, and native fallback navigation well enough to plan F18.
It is not clean enough to authorize F18 implementation automatically because
Meridian ownership and feature-flag placement are still ambiguous across
`AmbitionsRootView`, `AppShellView`, and shared shell primitives.

Do not run F18 yet.

## Current Shell / Navigation Architecture

- `Native/Ambitions/App/AppTab.swift` owns canonical destination identity.
- `Native/Ambitions/App/AppNavigation.swift` owns selected tab, route stacks,
  overlays, reentry context, and compatibility normalization.
- `Native/Ambitions/App/AmbitionsRootView.swift` owns the concrete `TabView`,
  per-destination `NavigationStack`s, floating global action lane, onboarding,
  and root overlay presentation.
- `Native/Ambitions/App/AppShellView.swift` owns shell scaffold chrome,
  command sheet, memory lens, shell header, continuity ribbon, and placeholders.
- `Sources/Components/ShellChromePrimitives.swift` owns shared shell visual
  primitives used by the current shell.
- `Native/Ambitions/App/AppExternalRouting.swift` owns deep link, widget,
  notification, Live Activity, and external route translation.
- `Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift` owns
  App Intent shortcut entry points.

## Current Top-Level Destination Access

`AppTab.allCases` is exactly:

- Today
- Goals
- Capture
- Plan
- You

Legacy route values remain compatibility-only:

- `habits` normalizes to Plan with `.habits`.
- `insights` normalizes to You with `.history`.

Current UI tests protect the five visible destinations and absence of old
top-level labels in `Native/AmbitionsUITests/AmbitionsUITests.swift`.

## Route Ownership Map

| Route | Owner | Current behavior |
|---|---|---|
| Today | `AppNavigationModel.selectToday` | Selects `.today`; supports entry context. |
| Goals | `selectedTab = .goals`; `goalsPath` | Goal detail routes push into Goals. |
| Capture | `selectedTab = .captures` | Capture is now a top-level destination. |
| Plan | `selectedTab = .plan`; `planPath` | Plan owns habits and weekly review. |
| You | `selectedTab = .profile`; `insightsPath` | You owns history/monthly review. |
| Command sheet | `ShellOverlayState.commandSheet` | Shell overlay, not a destination. |
| Memory lens | `ShellOverlayState.memoryLens` | Shell overlay, not a destination. |

## Deep Link Map

- `ambitions://tab/today`
- `ambitions://tab/goals`
- `ambitions://tab/captures`
- `ambitions://tab/plan`
- `ambitions://tab/profile`
- `ambitions://captures/inbox`
- `ambitions://plan/habits`
- `ambitions://plan/weekly-review`
- `ambitions://insights/history`
- `ambitions://insights/monthly-review`
- `ambitions://goal/<goalID>`
- `ambitions://overlay/<overlay-kind>`

Unknown routes become generic external entries rather than crashing.

## App Intent Handoff Map

`OpenAmbitionsDestinationIntent` queues URLs through
`AppIntentLaunchRouter.shared`, then the app consumes the pending URL and routes
through the same external router.

Current shortcut destinations include Today, Plan, Capture, command, memory
lens, Start here, Close the loop, recovery, quick focus, and plan patch.

F18 must not change route URLs without updating:

- `Native/AmbitionsTests/App/AppIntentRoutingTests.swift`
- `Native/AmbitionsTests/App/ExternalRoutingTests.swift`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`

## Widget / External Surface Implications

Widgets and Live Activities use `ExternalSurfaceActionPayload` URLs and
`ExternalWidgetProjection`. They rely on route parity rather than direct shell
knowledge.

F18 must keep `widgetURL` and Live Activity return links landing in the app
through `DefaultAppExternalRouter`.

## Fallback Navigation Plan

Native `TabView` must remain the fallback.

F18 should not delete the existing `TabView`. The safest shape is:

1. keep `TabView(selection: $navigation.selectedTab)` as the accessibility and
   system fallback;
2. add a reversible shell mode value such as `nativeTabBar` vs `meridian`;
3. render Meridian only when the flag is enabled;
4. keep destination selection funneled through `AppNavigationModel`;
5. preserve direct access to Today / Goals / Capture / Plan / You.

## Feature Flag Plan

F17 does not find an existing dedicated shell feature flag owner.

Recommended repair before F18:

- add an app-local shell presentation mode contract;
- default it to native fallback;
- expose it only through compile-time or launch-argument configuration for
  tests;
- do not add remote config, paid services, or runtime dependencies.

## Rollback Plan

Rollback must be one config change:

- set shell presentation mode to native fallback;
- keep all route state in `AppNavigationModel`;
- avoid moving route ownership into Meridian-only views;
- leave all deep links and App Intent URLs unchanged.

## Accessibility Fallback Plan

The native `TabView` fallback must remain accessible.

Meridian may add a custom visual destination rail only if:

- all five destinations have stable labels and identifiers;
- VoiceOver can reach every destination;
- Dynamic Type does not hide any destination;
- reduced-motion users do not lose orientation;
- native fallback stays available.

## UI Tests Needed For F18 / F19

Add or update focused tests for:

- five destination access under native fallback;
- five destination access under Meridian flag;
- global add lane does not overlap fallback navigation;
- deep link to Plan selects Plan;
- deep link to Capture lands on Capture;
- legacy `habits` and `insights` route compatibility;
- App Intent queued URLs route through the same shell path;
- fallback mode can be restored without route loss.

## Files F18 May Touch

- `Native/Ambitions/App/AppTab.swift`
- `Native/Ambitions/App/AppNavigation.swift`
- `Native/Ambitions/App/AmbitionsRootView.swift`
- `Native/Ambitions/App/AppShellView.swift`
- `Sources/Components/ShellChromePrimitives.swift`
- `Native/AmbitionsTests/App/*Shell*Tests.swift`
- `Native/AmbitionsTests/App/*Routing*Tests.swift`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`
- F18 report and run-state files

## Files F18 May Not Touch

- `.github/workflows/**`
- runtime dependency manifests
- App Store / TestFlight release claim docs except truthful reports
- persistence migrations
- unrelated feature screens
- UI tests that are deleted without replacement or retirement evidence

## F18 Implementation Plan

F18 should start with a small repair/design slice, not visual shell code:

1. create a shell presentation mode owner and default to native fallback;
2. add tests proving native fallback remains the default;
3. add tests proving the mode can select Meridian without changing route state;
4. only then add Meridian visual chrome behind the flag;
5. keep destination actions calling `AppNavigationModel.selectTab`;
6. rerun build and focused shell/routing tests.

## F17 Repair Update

F17 originally stopped Yellow. The follow-up F17 repair decision in
`docs/audits/ambitions-3-0-f17-shell-meridian-ownership-decision.md` resolves
the shell ownership ambiguity and is Green.

F18 is authorized only within that ownership contract:

- native fallback remains the default;
- shell presentation mode owns presentation only;
- `AppNavigationModel` and `AppExternalRoute` retain route ownership;
- Meridian must not remove fallback navigation or duplicate route state;
- F18 must prove route parity and fallback safety before continuing.

## Gate Result

Yellow.

Reasons:

- No existing dedicated shell feature flag owner was found.
- Meridian implementation ownership is split between root composition,
  scaffold chrome, and shared primitives.
- `AmbitionsRootView.swift` and `AppShellView.swift` are already in the
  architecture-scan responsibility-review band.
- Proceeding directly to F18 would risk mixing feature-flag ownership,
  route parity, visual shell work, and fallback safety in one batch.

Accepted background Yellow remains unchanged:

- doc QA backlog unchanged;
- known full UI smoke failures before F21;
- pre-existing architecture warnings unchanged;
- compatibility seams unchanged.

## Validation

- `scripts/build-local.sh`: PASS on `iPhone 17`.
- `scripts/batch-train-gate-check.sh || true`: Yellow only because the F17
  report and run-state files were unstaged during validation.
- `scripts/swiftui-architecture-scan.sh || true`: advisory/PARTIAL with the
  existing large-file and responsibility-review list. No app code changed.
- `git diff --check`: PASS.

No `.github/workflows/` files were touched. No runtime dependency file was
touched. No app implementation file was touched.

## Repair / Decision Prompt

```text
Run a narrow F17 repair decision pass before F18.

Goal: create a Green Shell/Meridian architecture and ownership plan without
implementing Meridian UI.

Read:
- docs/audits/ambitions-3-0-f17-shell-meridian-readiness-report.md
- docs/codex/batch-trains/F17_F30_FAANG_HANDOFF_COMPLETION_TRAIN.md
- docs/canon/Ambitions_3_0_Ambitions_Operating_Shell.md
- docs/canon/Ambitions_3_0_Ambition_Meridian_Shell_SwiftUI_Build_Spec.md
- Native/Ambitions/App/AppTab.swift
- Native/Ambitions/App/AppNavigation.swift
- Native/Ambitions/App/AmbitionsRootView.swift
- Native/Ambitions/App/AppShellView.swift

Allowed files:
- docs/audits/ambitions-3-0-f17-shell-meridian-readiness-report.md
- docs/codex/batches/F18_Feature_Flagged_Meridian_Shell_Implementation_Prompt.md
- .codex/reports/current-run-state.md
- .codex/reports/current-batch-train-state.md

Required output:
- exact owner for shell presentation mode
- exact flag/default/rollback contract
- exact F18 write set
- exact focused tests to add first
- Green/Yellow/Red decision

Do not implement F18 until this repair decision is Green.
```
