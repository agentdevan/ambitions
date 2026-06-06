# AOR-CHROME-02 Report - Dock and Tab State Audit

Status: Green
Issue: AMB-537
Date: 2026-06-06
Base commit: `c3b5fccbdd0e750814132a6d38f2e83bd1eaba3a`

## Truth Files Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `artifacts/ambitions-ui-reconstruction/reports/AOR-001-report.md`
- `artifacts/ambitions-ui-reconstruction/reports/AOR-CHROME-00-report.md`
- `artifacts/ambitions-ui-reconstruction/reports/AOR-CHROME-01-report.md`

## Scope

AMB-537 is a dock/tab-state audit. No app source behavior was changed. The active top-level IA remains locked to `Today / Goals / Time / Motion / You`; Capture remains global/contextual and compatibility-routed, not a tab.

## Runner / Guard Posture

- `ALLOW_DIRTY=1 scripts/ambitions-codex-train.sh AMB-537 prompts/batches/AMB-537.md`
  - Champion coverage Green.
  - Runner-classified source-changing pre-guard stopped Red because the required scan prompt references `Sources`, which touched the locked `design_primitives` concept in prompt text only.
  - No app source patch was produced by the runner.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-537 --prompt prompts/batches/AMB-537.md --batch-type audit-only`
  - Green.
  - This is the applicable guard mode for the report-only audit.

## Required Scan

```bash
rg -n "TabView|case today|case goals|case time|case motion|case you|case capture|Plan tab|Profile tab|Pulse|Capture tab|Calendar tab|Inbox tab" Native Sources --glob "*.swift"
```

### Scan Classification

- Active root tab owner:
  - `Native/Ambitions/App/AmbitionsRootView.swift:92-111` contains exactly five `Tab(...)` entries: Today, Goals, Time, Motion, You.
- Active canonical tab list:
  - `Native/Ambitions/App/AppTab.swift:6-10` declares Today, Goals, Time, Motion, You.
  - `Native/Ambitions/App/AppTab.swift:13-15` makes `allCases` exactly `[.today, .goals, .time, .motion, .you]`.
- Capture compatibility:
  - `Native/Ambitions/App/AppTab.swift:11` retains `.capture` as a compatibility/raw route case.
  - `Native/Ambitions/App/AppTab.swift:55-61` maps `.capture` to `.today` for canonical top-level behavior.
  - `Native/Ambitions/App/AppNavigation.swift:242-243` guards capture compatibility by returning selected tab to Today before opening Capture.
- Legacy IA compatibility:
  - `LegacyIARouteCompatibility` maps `pulse` to Motion, `plan` to Time, and `profile` to You as compatibility routing only.
  - These strings do not appear as active top-level tab entries.
- Pulse scan hits:
  - Hits in `Sources/Previews`, proof/motion visual primitives, and tests are visual/proof pulse terminology or tests asserting Pulse is not an active tab.
  - No active root `Tab("Pulse")` or `AppTab.allCases` Pulse entry exists.
- Plan/Profile/Calendar/Inbox scan:
  - Plan/Profile compatibility exists only as legacy route mapping or support route language.
  - Calendar/Inbox strings appear in feature/support contexts, not active top-level `Tab(...)` entries.

## Active Routing Proof

| Proof point | Evidence |
|---|---|
| Active shell owner | `AmbitionsRootView.shellTabView(theme:)` owns the native `TabView`. |
| Five visible tabs | `Tab(AppTab.today.title...)`, `Tab(AppTab.goals.title...)`, `Tab(AppTab.time.title...)`, `Tab(AppTab.motion.title...)`, `Tab(AppTab.you.title...)`. |
| Capture not visible as tab | No `Tab(AppTab.capture...)` exists in `shellTabView`; `AppTab.allCases` excludes `.capture`. |
| Capture compatibility | Raw `.capture` canonicalizes to Today and opens contextual Capture, not a tab. |
| Pulse compatibility | Legacy `pulse` maps to Motion and tests assert `AppTab.allCases` does not contain `Pulse`. |
| Plan/Profile compatibility | Legacy `plan` maps to Time and `profile` maps to You; neither becomes active top-level IA. |

## Dock Restraint / Badge Scan

`rg -n "\.badge\(|Tab\(" Native/Ambitions/App/AmbitionsRootView.swift Native/Ambitions/App/AppTab.swift Native/Ambitions/App/AppNavigation.swift`

- No `.badge(...)` call exists in active shell tab ownership.
- No XP, streak, urgency, gamification, or notification-count behavior is attached to the root dock.
- The dock remains native SwiftUI `TabView` plus tab-bar material styling.

## Validation

- `ALLOW_DIRTY=1 scripts/ambitions-codex-train.sh AMB-537 prompts/batches/AMB-537.md`
  - Champion coverage Green.
  - Source-changing pre-guard Red due prompt-only `design_primitives` false positive; no source patch.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-537 --prompt prompts/batches/AMB-537.md --batch-type audit-only`
  - Green.
- Required stale-IA scan above.
  - Passed with no active IA Red.
- `rg -n "\.badge\(|Tab\(" Native/Ambitions/App/AmbitionsRootView.swift Native/Ambitions/App/AppTab.swift Native/Ambitions/App/AppNavigation.swift`
  - Passed with no active shell tab badges.
- `git diff --check`
  - Passed.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-537 --prompt prompts/batches/AMB-537.md --changed-from c3b5fccbdd0e750814132a6d38f2e83bd1eaba3a --batch-type audit-only`
  - Green.

## Proof Boundaries

- This proves the source scan and current report-only tab/dock audit.
- This does not prove app behavior changes, screenshots, accessibility, performance, real-device behavior, privacy/legal approval, CI proof, TestFlight readiness, App Store readiness, or release readiness.

## Rollback

Remove this report and `prompts/batches/AMB-537.md` to return to `c3b5fccbdd0e750814132a6d38f2e83bd1eaba3a`.
