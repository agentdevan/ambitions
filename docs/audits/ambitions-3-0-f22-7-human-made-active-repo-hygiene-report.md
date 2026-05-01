# Ambitions 3.0 F22.7 Human-Made Active Repo Hygiene Report

Date: 2026-05-01
Train: F17-F30 FAANG Handoff Completion Train
Batch: F22.7 Human-Made Active Repo Hygiene / 3.0-As-Baseline Gate
Gate: Green

## Result

F22.7 is Green.

The active repo now reads from Ambitions 3.0 as the current baseline in the
first-hour source path. The active entry docs no longer point a new engineer to
the old F17/F18 start condition as the current train state. They now point to
F22.7 as the mandatory next checkpoint after F22 and F22.5 Green evidence.

This gate does not claim the codebase has no legacy/internal naming debt. It
classifies the remaining compatibility seams, large-file risks, and old naming
risks so they are understandable before F23 and before the later mandatory
F27.5 maintainability audit.

FAANG handoff remains PARTIAL until F27 explicitly passes.

## Source-Truth Check

Primary first-hour path inspected:

- `README.md`
- `AGENTS.md`
- `docs/README.md`
- `docs/canon/README.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/codex/MASTER_AMBITIONS_3_0_CODEX_PROMPT.md`
- `docs/codex/CONTEXT_INDEX.md`

Active narrative fixes:

- `README.md` now says F17 repair, F18, F19, F20, F21/F21.5, F22, and F22.5
  are Green, and that F22.7 is mandatory before F23.
- `docs/README.md` now carries the same current train state.
- `docs/codex/MASTER_AMBITIONS_3_0_CODEX_PROMPT.md` now tells new sessions to
  use the active train manifest and current train-state file, rather than
  restarting the lane at F17.
- `docs/codex/CONTEXT_INDEX.md` now records F22 and F22.5 Green evidence and
  points to F22.7 as the current continuation.

Legacy-current ambiguity scan:

- No remaining hit in the first-hour path says the current next batch is F22,
  says F18 is still blocked by F17, or instructs the user to start the active
  handoff train from the old F17 planning prompt.
- Remaining old-version references in the first-hour path are explicit:
  historical/supporting-only guardrails or banned-term guidance.

## Representative Codebase Check

Sampled active seams:

- Today:
  `Native/Ambitions/Features/Today/TodayViewModel.swift`,
  `Native/Ambitions/Features/Today/TodayFeatureModels.swift`,
  `Native/Ambitions/Features/Today/TodayExecutionViewState.swift`,
  and Today tests.
- Capture:
  `Native/Ambitions/Features/Captures/CapturesViewModel.swift`.
- Plan:
  `Native/Ambitions/Features/Plan/PlanViewModel.swift`.
- Goals:
  `Native/Ambitions/Features/Goals/GoalsViewModels.swift`.
- You/Profile:
  `Native/Ambitions/Features/Profile/ProfileScreen.swift`.
- App shell and routing:
  `Native/Ambitions/App/AppTab.swift`,
  `Native/Ambitions/App/AppMeridianShell.swift`,
  `Native/Ambitions/App/AppExternalRouting.swift`,
  `Native/Ambitions/App/AppIntentLaunchRouter.swift`.
- Domain:
  `Native/Ambitions/Domain/TodayModels.swift`,
  `Native/Ambitions/Domain/ScreenContractModels.swift`,
  `Native/Ambitions/Domain/CanonicalNowStateModels.swift`.
- Persistence:
  `Native/Ambitions/Persistence/SwiftDataModels.swift`.
- Tests:
  `Native/AmbitionsTests/App/AppShellNavigationTests.swift`,
  `Native/AmbitionsTests/Today/TodayViewModelTests.swift`.

### Clear Ownership

- Shell/routing ownership is legible:
  `Native/Ambitions/App` owns tabs, navigation, Meridian/fallback shell, and
  external route translation.
- Feature view models are generally feature-owned and small enough to read
  quickly.
- Today execution has a clearer state/projector/view split than earlier train
  history: `TodayExecutionViewState`, `TodayExecutionProjector`,
  `TodayExecutionCompatibility`, screen-contract snapshot, panels, and tests
  are separated.

### Understandable State Contracts

- `AppTab.allCases` exposes only `Today / Goals / Capture / Plan / You`.
- Legacy raw values for `habits` and `insights` normalize to current canonical
  destinations and are protected by shell tests.
- Today uses `recommendedStep` in current execution state and tests.
- Async failure states remain internal state-machine vocabulary; visible copy
  uses softer language where F22 touched leakage.

### Compatibility Seams

Allowed and still documented:

| Seam | Why retained | User-facing exposure | Current coverage |
|---|---|---|---|
| `AppTab.habits` | legacy route/preference compatibility | title maps to `Rituals`; not a top-level tab | `AppShellNavigationTests` |
| `AppTab.insights` / `InsightsRouteTarget` | legacy route/history compatibility | title maps to `History`; not a top-level tab | shell and routing tests |
| `Profile` type/folder names | user-facing `You` runs through existing feature ownership | navigation title and root copy say `You` | Profile/You tests and screen code |
| `activeFocus` / external snapshot v1 | widget/Live Activity/deep-link schema stability | not visible copy | external snapshot/widget tests |
| `TodayFocus*` / `.focus` semantic states | broad Today execution compatibility and design-system semantic state | current visible copy is Step Session / Reality Rail where product-facing | Today tests and copy guards |
| `.failed` / `.failedSafely` | internal result and receipt taxonomy | visible copy softened to `could not finish` / `Safely blocked` where active | receipt, command, and copy tests |

Needs later maintainability attention:

- `Native/Ambitions/Domain/TodayModels.swift` contains older preview/dashboard
  model names such as `FocusSession`. Current production Today surfaces use the
  newer Today feature models and Reality Rail / recommended-step contracts, so
  this is not a F22.7 blocker, but it should be reviewed during F27.5.
- `Native/Ambitions/Features/Captures` remains plural internally while the
  user-facing tab is singular `Capture`. This is understandable from
  `README.md` and `AppTab.title`, but it should be documented for first-commit
  work and avoided in new visible copy.

### Generated-Looking Code And Prompt-History Comments

- No obvious prompt-history comments were found in the representative active
  sample.
- Some fixture/test metadata still uses old `batch` tokens or `legacyFallback`
  names. These are not visible product language and are best treated as
  compatibility/test-history seams, not release claims.

### Duplicated Model Concepts

- The largest conceptual duplication risk is the coexistence of older
  `TodayDashboard` / `FocusSession` preview models with newer Today experience
  and execution contracts.
- This is documented as maintainability debt for F27.5 rather than rewritten
  during F22.7 because the train forbids opportunistic compatibility breakage.

## Test Contract Check

Representative tests read as product contracts:

- `AppShellNavigationTests` protects canonical top-level tabs and legacy route
  normalization.
- `TodayViewModelTests` protects Reality Rail copy, private projection, banned
  language, and Step Detail behavior.

Allowed test-language hits:

- banned phrases appear in negative assertions;
- `.failed` appears in internal state-machine tests;
- legacy tab raw values appear in compatibility tests.

These tests are not stale layout trivia and were not weakened.

## Large-File And Architecture Risks

`scripts/swiftui-architecture-scan.sh || true` is advisory and reported
pre-existing extraction warnings. Largest active examples include:

- `Native/Ambitions/Features/Goals/GoalsFeatureService.swift` at `5024` lines;
- `Native/Ambitions/Features/Today/TodayFeatureService.swift` at `2718` lines;
- `Native/Ambitions/Features/Today/TodayPanels.swift` at `2423` lines;
- `Native/Ambitions/Features/Plan/PlanFeatureService.swift` at `2394` lines;
- `Native/Ambitions/Features/Profile/ProfileScreen.swift` at `2167` lines;
- `Native/Ambitions/Features/Plan/PlanScreen.swift` at `1978` lines.

These warnings are not new in F22.7 and are not worsened by this batch. They
remain mandatory evidence for F27.5.

## New Engineer First Commit Path

Build:

1. Read `README.md`, `AGENTS.md`, `docs/README.md`,
   `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`, and
   `docs/codex/CONTEXT_INDEX.md`.
2. Run `scripts/validate-dev-tools.sh || true`.
3. Run `scripts/build-local.sh`.

Run tests:

- Use `scripts/test-local.sh` for the broad local pack.
- Use focused `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions`
  commands for touched feature suites.
- Treat UI smoke, device, accessibility, and release claims as evidence-gated.

Where to start:

- Shell/navigation: `Native/Ambitions/App`.
- Today: `Native/Ambitions/Features/Today`.
- Capture: `Native/Ambitions/Features/Captures`, with user-facing label
  `Capture`.
- Goals: `Native/Ambitions/Features/Goals`.
- Plan: `Native/Ambitions/Features/Plan`.
- You: `Native/Ambitions/Features/Profile`, with user-facing label `You`.
- Domain contracts: `Native/Ambitions/Domain`.
- Persistence: `Native/Ambitions/Persistence`.
- Shared UI: `Sources/` and `AppUI/Sources/`.

What not to touch casually:

- `.github/workflows/**`;
- runtime dependency manifests;
- legacy deep-link, App Intent, widget, Live Activity, route, or raw-value
  compatibility seams;
- release/App Store/privacy/accessibility claims without matching evidence.

How to add a feature:

- Start from the target Ambitions 3.0 primitive/surface doc.
- Add or update domain/state/projector/view seams in the owning feature folder.
- Preserve current shell destinations.
- Add tests that protect product contracts, privacy projection, accessibility
  identifiers, and non-shaming language.

How to modernize tests:

- Prefer product contracts over brittle layout trivia.
- Keep legacy raw-value tests where they protect compatibility.
- Do not delete failing assertions just to pass a gate.

Privacy/accessibility/release truth:

- Redact external surfaces by default.
- Keep user-facing trust controls in You.
- Do not claim VoiceOver, Dynamic Type, TestFlight, App Store, or physical
  device readiness without explicit evidence.

## Validation

Commands:

- active source-truth drift scan over first-hour docs: PASS after F22.7 fixes.
- representative code/test scan: PASS with documented compatibility seams and
  maintainability warnings.
- banned-language sample scan over active first-hour docs, Today, shell, and
  sampled tests: PASS for active visible copy; remaining hits are negative
  tests, internal state names, or explicit PARTIAL truth.
- `scripts/swiftui-architecture-scan.sh || true`: advisory warnings only;
  pre-existing large-file/extraction debt recorded above.
- `scripts/batch-train-gate-check.sh || true`: advisory Yellow because the
  intended F22.7 working tree was dirty.
- `git diff --check`: PASS before report creation.
- `scripts/build-local.sh`: PASS.
  Log: `output/logs/build-local-20260501-151626.log`.

Not verified:

- full `scripts/test-local.sh` was not rerun in F22.7;
- full UI smoke was not rerun in F22.7;
- physical-device behavior was not verified;
- external accessibility conformance was not claimed.

## Gate Decision

Green.

The active repo reads from Ambitions 3.0 as baseline in the first-hour path,
known compatibility seams are explained, no user-facing legacy language was
introduced, no active doc presents old canon as current, no generated junk is
staged, and the local build passes.

F23 Accessibility / ADHD / Dynamic Type / VoiceOver QA is unblocked next.
