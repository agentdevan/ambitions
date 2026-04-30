# F02 Reality Rail Visual States Report

Date: 2026-04-30

## Result

PASS for the bounded F02 scope.

FAANG handoff remains PARTIAL.

## Task Width

- Size: M
- Type: Today UI implementation
- Primitive: Reality Rail
- Surface: Today
- App scope: Today UI, Today state/model tests, and Today preview seams only
- Workflow changes: none
- Dependency changes: none
- Release readiness claims: none

## Files Changed

- `.codex/reports/current-run-state.md`
- `Native/Ambitions/Features/Today/TodayExecutionViewState.swift`
- `Native/Ambitions/Features/Today/TodayPanels.swift`
- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Native/Ambitions/PreviewSupport/PreviewTodayScenarios.swift`
- `Native/AmbitionsTests/Today/TodayViewModelTests.swift`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `docs/audits/ambitions-3-0-f02-reality-rail-visual-states-report.md`

## UI Rendered

F02 adds a focused Today-owned `AmbitionsDayRailView` and renders it as the
first loaded Today surface from `experience.execution.dayRail`.

Rendered:

- `Start here` hero card
- recommended step title
- duration label
- source/context labels
- `Start now` primary action
- Now / Next / Later sections
- privacy-safe private item projection
- empty/unavailable state copy
- subtle reserved closure/proof copy

Not implemented:

- Step Detail
- Step Session
- Action Closure Sheet
- Proof / Receipt Ledger
- Plan, Capture, Goals, You, shell, widget, Live Activity, or App Intent work

## Accessibility

Identifiers added:

- `TodayRealityRail`
- `TodayRealityRailHero`
- `TodayRealityRailStartHereTitle`
- `TodayRealityRailPrimaryAction`
- `TodayRealityRailNowSection`
- `TodayRealityRailNextSection`
- `TodayRealityRailLaterSection`
- `TodayRealityRailRow`
- `TodayRealityRailPrivateItem`

VoiceOver/privacy notes:

- Rail, hero, sections, rows, and reserved slots carry readable labels/values.
- Private projections use `Private item` and `Details stay private on Today.`
- Private row/hero labels do not include the sensitive step title or subtitle.
- Row meaning is exposed through text labels, not only node color or shape.

Dynamic Type notes:

- The rail uses existing SwiftUI text styles and vertical stacks.
- Primary action keeps a stable minimum height.
- No rendered screenshot or manual Dynamic Type pass was claimed in F02.

## Privacy Projection Behavior

F02 renders the F01 privacy projection in the rail:

- standard items show their title and source labels
- private/sensitive items show privacy-safe replacement copy
- private accessibility labels remain redacted
- compact rail UI does not expose private title/details in private preview state

## Tests Added Or Updated

`TodayViewModelTests` now includes F02 coverage for:

- `Start here` and `Start now` visible rail copy
- deterministic Now / Next / Later ordering
- private/sensitive projection redaction
- forbidden rail copy absence
- closure/proof slots remaining reserved without claiming behavior

Existing F01 tests remain in the same file and continue to cover the state
foundation.

## Copy Guard

Touched-path command:

```bash
rg -n \
  'Start Focus|Focus Session|best next move|next best move|AI confidence|productivity score|profile tab|insights tab|habits tab|overdue|failed|missed' \
  Native/Ambitions/Features/Today/TodayExecutionViewState.swift \
  Native/Ambitions/Features/Today/TodayPanels.swift \
  Native/Ambitions/Features/Today/TodayScreen.swift \
  Native/Ambitions/PreviewSupport/PreviewTodayScenarios.swift \
  Native/AmbitionsTests/Today/TodayViewModelTests.swift \
  docs/codex/BATCH_REGISTRY.md \
  docs/codex/CONTEXT_INDEX.md \
  .codex/reports/current-run-state.md || true
```

Result:

- No new active user-facing rail copy uses banned terms.
- Allowed hits are test assertions that banned terms are absent.
- Pre-existing non-rail hits remain in Today failure-state/test language and
  historical tracking docs.

## Validation Result

Verified:

- `scripts/validate-dev-tools.sh || true`: PASS
- `scripts/build-local.sh`: PASS on `iPhone 17`
- `TodayViewModelTests`: PASS, 23 tests
- `TodayFreshGoalVisibilityTests`: PASS, 5 tests
- `TodayShellIntegrationTests`: PASS, 1 test
- touched-path copy guard: PASS for active rail UI copy
- `git diff --check`: PASS

Partial/advisory:

- `scripts/run-doc-qa.sh || true`: PARTIAL/advisory due to pre-existing
  markdownlint, deprecated-language, and old local-link backlog.

Not required for F02:

- full UI smoke suite
- physical-device proof
- manual VoiceOver/Dynamic Type proof
- TestFlight/App Store/release readiness gates

## Remaining Today Gaps

- F03 Step Detail is still not implemented.
- F04 Step Session is still not implemented.
- F05 Action Closure Sheet is still not implemented.
- F06 Proof / Receipt Ledger is still not implemented.
- Full UI smoke remains known failing from pre-existing gaps.
- Legacy language/internal identifier migration remains future-owned.
- FAANG handoff remains PARTIAL.

## Next Exact Prompt Recommendation

Run F03: Step Detail and recommendation explanation.

Scope it to Today row tap / recommendation explanation only:

- keep `Start now` separate for F04 Step Session
- do not implement Action Closure or Proof/Receipt
- preserve Today / Goals / Capture / Plan / You
- add privacy-safe explanation/source facts
- add focused Today tests and avoid full UI smoke repair unless required by the
  F03 route contract
