Status: Yellow
Batch: IOS26-T02-B00
Train: IOS26
Scope: Flagship pre-shell geometry invariant
Branch: main
Commit: 120aba7af7be858e769a7e2a257cbc82ca98a7c2 -> working tree updated, no commit created in this phase

Files changed:
- `Native/Ambitions/App/AmbitionsRootView.swift`
- `Native/Ambitions/Features/Capture/CaptureScreen.swift`
- `build/reports/ios26-shell/safe-area-root-invariant.md`
- `docs/codex/POST_BATCH_GATE_REGISTRY.md`

Truth files inspected:
- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`

Source areas inspected:
- `Native/Ambitions/App/AmbitionsRootView.swift:34-75`
- `Native/Ambitions/App/AppShellView.swift:101-113`
- `Native/Ambitions/App/AppMeridianShell.swift:1-82`
- `Native/Ambitions/Features/Capture/CaptureScreen.swift:28-107`
- `Native/Ambitions/App/AppNavigation.swift:51-125`
- `Native/AmbitionsTests/App/AppShellChromeTests.swift:1-120`
- `Native/AmbitionsTests/App/AppShellNavigationTests.swift:1-220`

Before/after grep audit:

```text
Before:
Native/Ambitions/App/AmbitionsRootView.swift:59:.overlay(alignment: .bottom) {
Native/Ambitions/App/AmbitionsRootView.swift:70:.overlay(alignment: .bottom) {
Native/Ambitions/App/AmbitionsRootView.swift:72:    .padding(.bottom, resolvedTheme.spacing.xxxl + resolvedTheme.spacing.xl)
Native/Ambitions/Features/Capture/CaptureScreen.swift:96:            .ignoresSafeArea(edges: .top)

After:
Native/Ambitions/App/AmbitionsRootView.swift:59:.safeAreaInset(edge: .bottom, spacing: 0) {
Native/Ambitions/App/AmbitionsRootView.swift:60:    VStack(spacing: resolvedTheme.spacing.sm) {
Native/Ambitions/App/AmbitionsRootView.swift:70:                shellFloatingControlLane(theme: resolvedTheme)
Native/Ambitions/Features/Capture/CaptureScreen.swift:92:            ContextCrownHeader(
Native/Ambitions/Features/Capture/CaptureScreen.swift:95:            )
```

Commands run:
- `rg -n "ignoresSafeArea|edgesIgnoringSafeArea|safeAreaInset|safeAreaPadding|GeometryReader|UIScreen.main|safeAreaInsets|overlay|zIndex|keyboard" Native Sources`
- `xcodegen generate`
- `scripts/build-local.sh`
- `make xcode-focused-test BATCH=IOS26-T02-B00 TEST=AmbitionsTests/AppShellChromeTests`
- `git diff --check`

Validation logs:
- `output/logs/build-local-20260522-084006.log`
- `output/logs/build-local-20260522-085154.log`
- `.codex/xcode-logs/IOS26-T02-B00/20260522T124158Z/focused-test.log`
- `.codex/xcode-logs/IOS26-T02-B00/20260522T125329Z/focused-test.log`
- `.codex/xcode-summaries/IOS26-T02-B00/20260522T124157Z/validate-summary.json`
- `.codex/xcode-summaries/IOS26-T02-B00/20260522T124158Z/focused-test-summary.json`
- `.codex/xcode-summaries/IOS26-T02-B00/20260522T125328Z/validate-summary.json`
- `.codex/xcode-summaries/IOS26-T02-B00/20260522T125329Z/focused-test-summary.json`
- `.codex/xcode-results/IOS26-T02-B00/20260522T124158Z/focused-test.xcresult`
- `.codex/xcode-results/IOS26-T02-B00/20260522T125329Z/focused-test.xcresult`

Evidence:
- Root shell chrome now reserves the bottom safe area through `safeAreaInset(edge: .bottom, spacing: 0)` instead of fixed bottom overlay padding.
- Meridian destination rail and floating command lane are now root-owned safe-area chrome, stacked inside the bottom inset.
- Capture no longer applies a foreground top safe-area ignore to `ContextCrownHeader`.
- Background-only `.ignoresSafeArea()` remains in place for canvas/background treatment.
- `xcodegen generate` succeeded and regenerated `Ambitions.xcodeproj`.
- Repair-pass `xcodegen generate` succeeded and regenerated `Ambitions.xcodeproj`.
- Repair-pass `scripts/build-local.sh` succeeded with `** BUILD SUCCEEDED **`, log `output/logs/build-local-20260522-085154.log`.
- Repair-pass focused test lane passed: `AmbitionsTests/AppShellChromeTests` executed 10 tests with 0 failures, summary `.codex/xcode-summaries/IOS26-T02-B00/20260522T125329Z/focused-test-summary.json`.
- Required accepted-Yellow follow-up gate is recorded in `docs/codex/POST_BATCH_GATE_REGISTRY.md`.

Passes:
- Root safe-area chrome ownership moved into the root-owned bottom safe-area inset.
- Foreground top safe-area bypass removed from Capture.
- Local build passed.
- Focused unit test lane passed.
- `git diff --check` passed.

Failures:
- No build or test failures in the executed lanes.

Skipped:
- UI screenshot lane was not run.
- Device-verified collision proof was not run.
- Accessibility screenshot/manual proof was not run.
- Keyboard-specific visual proof was not run.

Unproven:
- On-device screenshot proof for status bar, Dynamic Island, home indicator, keyboard, and tab chrome collisions.
- Manual accessibility proof for the touched surface.

Safe-area root owner:
- `Native/Ambitions/App/AmbitionsRootView.swift:34-75` now owns the bottom chrome reservation.

Top inset behavior:
- Top shell inset ownership remains in `AppShellView.safeAreaInset(edge: .top)` for shell-scaffolded screens.
- Capture no longer opts its foreground crown header out of the top safe area.

Bottom inset behavior:
- Bottom meridian rail and global add lane are reserved by the root as safe-area inset content.
- The previous fixed bottom padding collision hack was removed.

Keyboard avoidance behavior:
- No custom keyboard offset was added.
- The bottom safe-area inset is the only geometry change, so keyboard avoidance now relies on SwiftUI safe-area mechanics rather than manual collision padding.

Tab bar avoidance behavior:
- The TabView tab bar remains the canonical bottom navigation when shell presentation is not meridian.
- The new root bottom inset sits above tab chrome instead of overlapping it with fixed offsets.

Floating command behavior:
- The global add button remains root-owned and now lives inside the bottom safe-area inset rather than an overlay with magic bottom padding.

Screenshot proof status:
- Not run in this phase.

Accessibility status:
- No new accessibility proof was added.
- Existing test coverage for shell chrome copy and semantics still passed.

Privacy/local-first status:
- Unchanged.
- No cloud, backend, analytics, or AI dependency was introduced.

iOS 26 API verification status:
- No new iOS 26 API adoption in this patch.
- `safeAreaInset` usage is existing SwiftUI API behavior, not a new platform claim.

Claims allowed:
- Root-owned bottom safe-area reservation was implemented in source.
- Capture foreground top safe-area bypass was removed.
- Local build and focused unit test validation passed.

Claims forbidden:
- No claim of screenshot proof.
- No claim of device validation.
- No claim of accessibility validation.
- No claim of release readiness.

Release blockers:
- Missing screenshot/device proof for the touched geometry.
- Missing manual accessibility proof for the touched surface.

Post-batch gates:
- Accepted Yellow gate recorded in `docs/codex/POST_BATCH_GATE_REGISTRY.md` as `IOS26-T02-B00 Safe-Area Screenshot/Device Gate`.
- Gate must run before Train 05 or before any later screenshot-dependent IOS26 shell/visual batch claims Green from this geometry invariant.
- Gate owner: Codex operator / next IOS26 train continuation owner.
- Gate requirement: collect simulator screenshot or device proof for status bar, Dynamic Island, home indicator, keyboard, tab chrome, and touched Capture top inset behavior; include accessibility/visual proof status; preserve the no-claim boundary until proof exists.

Rollback:
- Revert only `Native/Ambitions/App/AmbitionsRootView.swift` and `Native/Ambitions/Features/Capture/CaptureScreen.swift`.
- Remove this report and the `IOS26-T02-B00 Safe-Area Screenshot/Device Gate` registry entry if the batch is rolled back.

Next eligible batch:
- Continue the IOS26 train after screenshot/device proof is collected or after the next gated UI validation lane is selected.
