# AOR-CAPTURE-00 / AMB-555 Capture Path Audit

Status: Green for audit-only scope

AMB-555 proves the current active shell treats Capture as a global action / compatibility route, not as a rendered top-level tab. This audit did not modify UI source and does not claim Capture reconstruction, visual readiness, accessibility compliance, device proof, privacy/legal approval, TestFlight readiness, App Store readiness, CI proof, performance proof, or release readiness.

## Active Truth Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`

Truth anchors:

- `docs/truth/PRODUCT_DESIGN_TRUTH.md:88` locks top-level IA to `Today / Goals / Time / Motion / You` and states Capture is global input, not a destination.
- `docs/truth/PRODUCT_DESIGN_TRUTH.md:705-714` states Capture is always available but not a tab, with contextual entries first, quiet toolbar fallback second, bottom composer seam after activation, and no persistent floating Capture button.
- `docs/truth/IMPLEMENTATION_TRUTH.md:195-213` repeats the active IA and Capture global-action posture.
- `docs/truth/IMPLEMENTATION_TRUTH.md:607-611` marks prior top-level Capture/feed/FAB patterns as stale source seams and migration targets.
- `AGENTS.md:41-58` repeats the repo-front-door contract: `Capture` is global Atmosphere Composer/action layer, not a tab.

## Current Active Shell Evidence

### Capture Is Not Rendered As A Top-Level Tab

- `Native/Ambitions/App/AppTab.swift:13-15` defines `AppTab.allCases` as `[.today, .goals, .time, .motion, .you]`; `.capture` is excluded.
- `Native/Ambitions/App/AmbitionsRootView.swift:91-112` renders exactly five `Tab` values: Today, Goals, Time, Motion, and You. There is no `Tab(... .capture ...)`.
- `Native/Ambitions/App/AppTab.swift:60-67` maps `.capture` through `canonicalTopLevelTab` to `.today`, preventing Capture from remaining selected as a canonical top-level tab.
- `Native/Ambitions/App/AppNavigation.swift:71-73` initializes selected tabs through `canonicalTopLevelTab`.
- `Native/Ambitions/App/AppNavigation.swift:101-104` also canonicalizes selected tabs when a tab is selected.

### Legacy / Compatibility Capture Routes Are Demoted

- `Native/Ambitions/App/AppTab.swift:19-29` still decodes raw `"capture"` to `.capture`, but this is compatibility source and is not in `allCases`.
- `Native/Ambitions/App/AppTab.swift:192-213` preserves legacy raw Capture/Captures routes and seeds them back to Today.
- `Native/Ambitions/App/AppTab.swift:231-240` maps external `"capture"` / `"captures"` route input to `.openTimeRoute(.captureInbox)`, not a top-level tab.
- `Native/Ambitions/App/ShellCommandRouter.swift:102-108` routes `.tab(.capture)` to `presentCaptureCompatibilityRoute(source:)` instead of selecting a Capture tab.
- `Native/Ambitions/App/AppNavigation.swift:241-249` ensures a selected `.capture` compatibility state is moved back to Today before presenting the quick Capture command sheet.

### Quiet Toolbar Fallback Exists

- `Native/Ambitions/App/ShellCommandModels.swift:228-255` defines `AppShellCaptureAccessModel` with toolbar title/accessibility text and per-tab accessibility identifiers.
- `Native/Ambitions/App/AmbitionsRootView.swift:285-297` installs the shell utility Capture button as the top-bar trailing fallback for shell surfaces.
- `Native/Ambitions/App/AmbitionsRootView.swift:418-423` presents that toolbar Capture as a `.quickCapture` command sheet with source from the current canonical top-level tab.

### Contextual Entry Points Exist

- `Native/Ambitions/Features/Today/TodayScreen.swift:229-234` routes Today `.quickLog` into `.quickCapture` with source `.todayQuickCapture`.
- `Native/Ambitions/Features/Today/TodayScreen.swift:48-57` has a Today toolbar Capture action that routes to the Capture compatibility route.
- `Native/Ambitions/Features/Time/TimeScreen.swift:50-63` provides a Time empty-state secondary action that opens `.captureInbox`.
- `Native/Ambitions/Features/Time/TimeScreen.swift:1805-1808` labels Time route actions to `.captureInbox` as `Open Capture`.
- `Native/Ambitions/App/ShellCommandRouter.swift:150-181` executes `.quickCapture` by saving local Capture text, opening the Capture compatibility route, and recording a receipt.
- `Native/Ambitions/App/ShellCommandRouter.swift:236-247` executes `.openCapture` through Time-route Capture compatibility, not a top-level tab.

### Bottom Composer Seam Appears Only After Activation

- `Native/Ambitions/App/ShellCommandModels.swift:306-308` defines an activated Capture composer only when the overlay is a quiet command sheet with quick Capture intent/context.
- `Native/Ambitions/App/AmbitionsRootView.swift:129-140` keeps activated Capture composer overlays out of the regular sheet binding.
- `Native/Ambitions/App/AmbitionsRootView.swift:300-316` renders `AppShellActivatedCaptureSeam` only when `navigation.activeOverlay?.isActivatedCaptureComposer` is true.
- `Native/Ambitions/App/AppShellView.swift:602-647` defines the activated bottom seam and its accessibility identity `shell.activated-capture-seam`.
- `Native/Ambitions/App/AppShellView.swift:689-736` keeps the activated seam composer input/action controls inside that activated overlay path.

### Atmosphere Composer Source Exists

- `Native/Ambitions/Features/Capture/CaptureAtmosphereComposer.swift:107-192` defines `CaptureAtmosphereComposer`, with local route reveal, evidence labels, input alternatives, and accessibility value.
- `Native/Ambitions/Features/Capture/CaptureAtmosphereComposer.swift:225-304` defines the composer input and submit controls.
- `Native/Ambitions/Features/Capture/CaptureAtmosphereComposer.swift:320-369` defines route reveal proof and inspection summary.
- `Sources/Components/AmbitionsFlagshipTactilePrimitives.swift:138-255` defines `AtmosphereComposerCanvas`, which is Capture visual source, not a persistent floating app-level FAB.

## Stale Or Follow-Up Capture Seams

These are source-present seams that must not be promoted as current product truth:

- `Native/Ambitions/App/AppTab.swift:11` still has a `.capture` enum case for raw/legacy compatibility even though `allCases` excludes it.
- `Native/Ambitions/Features/Capture/CaptureScreen.swift:4-7` still defines `CaptureScreenShellMode.topLevelCapture`.
- `Native/Ambitions/Features/Capture/CaptureScreen.swift:175-183` contains top-level Capture copy for that mode.
- `Native/Ambitions/Features/Capture/CaptureScreen.swift:264-266` conditionally shows `CaptureFirstRunGuide()` for `topLevelCapture`.
- `Native/Ambitions/Features/Capture/CaptureScreen.swift:744-765` labels `topLevelCapture` as `Top-level intake`.

Follow-up classification: later Capture reconstruction/demotion issues should remove or further quarantine the `topLevelCapture` preview/source mode and any remaining compatibility copy that implies Capture is a destination. AMB-555 did not modify these UI sources because its Green gate requires no UI source modification.

## Persistent FAB / Feed / Chatbot Check

- `rg -n "floating action|FloatingAction|FAB|floating Capture|persistent.*Capture|Capture.*Button|floating.*button|floating" Native/Ambitions Sources -g '*.swift'` found no persistent Capture FAB implementation. The only `floating` source hits were descriptive visual text for particle/thought-cloud primitives and unrelated copy.
- Active truth rejects notes feed, inbox, chatbot, and category grid as product truth. Source still has `TimeRouteTarget.captureInbox` compatibility naming, but current routing treats it as a Time support route/compatibility path rather than a top-level destination.

## Runner / Guard Notes

- AMB-555 prompt installed at `prompts/batches/AMB-555.md`.
- First runner invocation omitted explicit `BATCH_TYPE=docs-install`, so the runner defaulted to `source-changing` and correctly Red-stopped on locked inspection concepts. No UI source patch occurred.
- Second runner invocation used `BATCH_TYPE=docs-install`; nested Codex Phase 01 failed on usage limit before planning or patching. Run dir: `.codex/runs/AMB-555/20260608T021941Z`.
- Manual continuation stayed audit-only under the docs-install guard.

## Validation

Verified:

- `python3 scripts/ambitions-champion-coverage-check.py` -> Green.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-555 --prompt prompts/batches/AMB-555.md --batch-type docs-install` -> Green.
- `bash scripts/release-claim-safety-scan.sh` -> Green.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-555 --prompt prompts/batches/AMB-555.md --changed-from 142b75995c17aeb63be2ff015c0b7dd77f41d6ae --batch-type docs-install` -> Green.
- `git diff --check` -> clean.

Not run:

- Xcode build/tests, screenshots, UI tests, device tests, accessibility traversal, and performance tests. Reason: AMB-555 is an audit-only docs/proof packet and made no UI source change.

## Proof Boundaries

This audit proves route/source posture only. It does not prove:

- final Capture reconstruction
- screenshot or visual approval
- formal accessibility compliance
- physical-device behavior
- privacy/legal approval
- performance
- CI
- TestFlight/App Store/release readiness

## Rollback

```bash
rm -f prompts/batches/AMB-555.md
rm -f artifacts/ambitions-ui-reconstruction/reports/AOR-CAPTURE-00-report.md
```

## Next

Next eligible issue: `AMB-556`.
