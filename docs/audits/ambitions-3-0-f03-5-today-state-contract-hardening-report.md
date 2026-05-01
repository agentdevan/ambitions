# Ambitions 3.0 F03.5 Today State Contract Hardening Report

Date: 2026-04-30
Status: behavior-preserving architecture hardening complete

## Result

PASS for the bounded F03.5 scope.

F03.5 gate: Green.

FAANG handoff remains PARTIAL.

## Task Width

- Size: M/L
- Type: Quality Train / Architecture Hygiene
- Primitive: Reality Rail / Step Execution contract foundation
- Surface: Today
- Product behavior changes: none
- Workflow changes: none
- Dependency changes: none
- Release readiness claims: none

## Accepted Yellow Reason

F03.5 started from an accepted Yellow preflight state only for remediation:

- doc QA remains PARTIAL/advisory from known markdown, deprecated-language, and
  old local-link backlog
- `scripts/swiftui-architecture-scan.sh || true` confirmed
  `TodayExecutionViewState.swift` at `1,980` lines
- F04 remained blocked until F03.5 completed

## Extracted Files

- `Native/Ambitions/Features/Today/DayRailViewState.swift`
- `Native/Ambitions/Features/Today/DayRailStepDetailState.swift`
- `Native/Ambitions/Features/Today/DayRailProjection.swift`
- `Native/Ambitions/Features/Today/TodayExecutionProjector.swift`
- `Native/Ambitions/Features/Today/TodayExecutionCompatibility.swift`
- `Native/Ambitions/Features/Today/TodayScreenContractSnapshot.swift`
- `Native/Ambitions/Features/Today/TodayExecutionStringHelpers.swift`

## Responsibilities Moved

- Day Rail enums and value states moved to `DayRailViewState.swift`.
- Step Detail state, reserved `Start now`, placeholder actions, and visible copy
  helpers moved to `DayRailStepDetailState.swift`.
- Day Rail compatibility, duration placeholders, target helpers, privacy
  visibility/redaction helpers, row-slot titles, and row construction moved to
  `DayRailProjection.swift`.
- `TodayExecutionProjectionInput`, `TodayExecutionProjector`, and projector
  private helper methods moved to `TodayExecutionProjector.swift`.
- `TodayExecutionViewState.compatibility`, `replacingDayRail`, and command
  mapping helpers moved to `TodayExecutionCompatibility.swift`.
- `screenContractSnapshot` moved to `TodayScreenContractSnapshot.swift`.
- Existing short-string helpers moved to `TodayExecutionStringHelpers.swift`.

## TodayExecutionViewState

- Before: `1,980` lines, owning Day Rail state, Step Detail state, projection,
  projector, compatibility, command mapping, screen-contract snapshot, and
  string helpers.
- After: `181` lines, owning Today execution enums and aggregate renderable
  state only.
- Remaining risk: `TodayExecutionProjector.swift` is `928` lines, and
  `TodayPanels.swift` / `TodayFeatureService.swift` remain large pre-existing
  Today files. F04 should avoid broad additions to those files unless it
  performs a similarly bounded extraction.

## Behavior Preservation Evidence

- Reality Rail copy and identifiers are unchanged.
- Step Detail copy and identifiers are unchanged.
- Private Day Rail and Step Detail redaction still use `Private item`,
  `Private step`, `Private source`, and `Details hidden here`.
- `Start here` and `Start now` remain stable.
- `Start now` remains the reserved F04 seam and does not implement Step Session.
- Action Closure and Proof/Receipt Ledger remain unimplemented.

## Validation

Verified:

- `git status --short`: clean before F03.5 preflight
- `git branch --show-current`: `main`
- `git rev-parse HEAD`: `e1cd209357a1319fd4249e3f325990408858515e`
- `git log -1 --oneline`: `e1cd2093 Index Ambitions batch train orchestrator`
- `scripts/batch-train-preflight.sh || true`: PASS
- `scripts/build-local.sh`: PASS on `platform=iOS Simulator,name=iPhone 17`
- `TodayViewModelTests`: PASS, `29` tests
- `TodayFreshGoalVisibilityTests`: PASS, `5` tests
- `TodayShellIntegrationTests`: PASS, `1` test
- `scripts/swiftui-architecture-scan.sh || true`: advisory; reports
  `TODAY_EXECUTION_VIEW_STATE_LINES 181`
- `git diff --check`: PASS
- touched-path copy guard: PASS for new active user-facing Today copy; hits are
  existing test guard strings, failure-state internals, and historical docs

Partial/advisory:

- `scripts/run-doc-qa.sh || true`: PARTIAL/advisory from known stale-guidance,
  deprecated-language, markdownlint, and lychee backlog
- Initial parallel focused-test attempt produced Xcode build database lock
  failures; the affected tests were rerun sequentially and passed

Not verified:

- full UI smoke
- manual VoiceOver / Dynamic Type / Reduce Motion
- physical device behavior
- TestFlight, App Store, or release readiness

## Gate Result

F03.5 gate: Green.

F04 readiness verdict: Green, with guardrails.

F04 may proceed to Step Session rename/migration and routing only. It must not
start F05 Action Closure, F06 Proof/Receipt Ledger, global identifier migration,
dependency changes, workflow changes, shell replacement, or release-readiness
claims.

## Next Exact Prompt

Run `BATCH_TRAIN_F04_F06_PROMPT.md` only if the train runner continues with F04
first and preserves the F04/F05/F06 gates. F04 is the next batch; F05 and F06
remain gated behind F04 Green.
