# Ambitions 3.0 F03 Step Detail Recommendation Explanation Report

Date: 2026-04-30
Status: implemented as a Today-local detail surface

## Task Width

- Size: M
- Type: Today UI/detail implementation
- Primitive: Reality Rail plus Recommendation Ledger foundation
- Surface: Today
- App code changes: limited to Today UI/model/test/preview seams
- Workflow changes: none
- Dependency changes: none
- Release readiness claims: none

## Files Changed

- `Native/Ambitions/Features/Today/TodayExecutionViewState.swift`
- `Native/Ambitions/Features/Today/TodayPanels.swift`
- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Native/Ambitions/PreviewSupport/PreviewTodayScenarios.swift`
- `Native/AmbitionsTests/Today/TodayViewModelTests.swift`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `docs/canon/Ambitions_3_0_Current_Implementation_Gap_Audit.md`
- `docs/audits/ambitions-3-0-f03-step-detail-recommendation-explanation-report.md`
- `.codex/reports/current-run-state.md`

## Step Detail Behavior

F03 adds `DayRailStepDetailState` and `TodayStepDetailSheet` as a Today-owned
surface. Tapping the Reality Rail `Start here` card or a Now/Next/Later row opens
the sheet without creating global routing.

The sheet shows:

- privacy-safe step title
- timing bucket: `Start here`, `Now`, `Next`, or `Later`
- duration label and duration source
- source label
- context label
- `Recommended because` explanation bullets
- private-state message when the rail projection is sensitive
- visible reserved `Start now`
- disabled reserved `Adjust plan` and `Review later`

`Start now` remains reserved for F04 and does not start a Step Session in F03.
Action Closure remains F05, and Proof/Receipt remains F06.

## Recommendation Explanation Behavior

The explanation is deterministic and derived from existing Reality Rail state:

- source facts from `DayRailSourceLabelState`
- duration source from `DayRailDurationSource`
- context fit from the rail context summary
- goal/path support from the hero or row text when safe

F03 does not expose model confidence, hidden reasoning, raw private data, or fake
personalization claims.

## Privacy Projection Behavior

Sensitive/private rail items project as:

- title: `Private step`
- privacy state: `Details hidden here`
- source: privacy-safe source summary
- why-this bullets: redacted, plan-grounded, user-control language

Focused tests prove sensitive fixture text does not appear in Step Detail visible
copy.

## Accessibility Identifiers

Added stable identifiers:

- `TodayStepDetail`
- `TodayStepDetailTitle`
- `TodayStepDetailWhyThis`
- `TodayStepDetailSourceLabel`
- `TodayStepDetailDurationLabel`
- `TodayStepDetailContextLabel`
- `TodayStepDetailPrimaryAction`
- `TodayStepDetailPrivateState`
- `TodayStepDetailDismiss`

The sheet has a clear title, dismiss control, readable explanation section, and
private accessibility labels that do not include sensitive fixture text. F03 does
not claim manual VoiceOver, Dynamic Type, contrast, or real-device proof.

## Tests Added Or Updated

`TodayViewModelTests` now cover:

- Reality Rail hero and row detail state production
- Ambitions 3.0-compliant Step Detail copy
- deterministic source/context/duration labels
- private/sensitive title and explanation redaction
- forbidden-copy absence in Step Detail visible copy
- `Start now` presence without Step Session implementation
- reserved Action Closure and Proof/Receipt slots
- missing-duration fallback behavior

Focused UI smoke was not expanded in F03 because the full UI suite remains a
known F16 modernization lane, and F03 already adds stable identifiers for that
future coverage.

## Copy Guard Result

Touched-path scan found no new active user-facing Step Detail use of forbidden
phrases. Allowed hits are test guard strings and existing engineering/historical
references such as failure-state code or docs that explicitly record known debt.

## Validation Result

- `xcodegen generate`: PASS
- `scripts/validate-dev-tools.sh || true`: PASS
- `scripts/run-doc-qa.sh || true`: PARTIAL/advisory; pre-existing markdown,
  deprecated-language, and link backlog remains logged
- `scripts/build-local.sh`: PASS on `iPhone 17`
- `TodayViewModelTests`: PASS, 29 tests
- `TodayFreshGoalVisibilityTests`: PASS, 5 tests after rerunning a simulator
  bootstrap glitch
- `TodayShellIntegrationTests`: PASS, 1 test
- `git diff --check`: PASS

## Remaining Today Gaps

- F04 must replace focus-first execution naming/routing with Step Session.
- F05 must implement Action Closure / Still Counts.
- F06 must implement the Proof/Receipt Ledger surface.
- Full UI smoke remains known failing and belongs to F16 modernization unless a
  narrower failing Today assertion becomes safe to address earlier.
- FAANG handoff remains PARTIAL.

## Next F04 Prompt Recommendation

Run F04: Step Session rename/migration and routing. Limit scope to Today
execution action naming, Step Session presentation/routing, compatibility-safe
tests, and copy guard. Do not implement Action Closure, Proof/Receipt Ledger,
Plan Life Suite, shell architecture changes, workflow changes, dependencies, or
global Profile/Insights/Habits identifier migration.
