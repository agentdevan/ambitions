# AMB-559 Banned-Term And Stale-IA Scan

## Verdict

Red.

The required scan completed and the output is preserved. Active top-level IA remains compatible with the current canon, but the scan found active/runtime UI-adjacent banned-term hits that cannot honestly be classified as only dead code or historical context. AMB-605 was filed as the remediation issue.

## Exact Scan Command

```bash
rg -n "Dashboard|Assistant|AI recommends|AI decided|best next move|next best move|overdue|failed|streak|score|optimize|smart capture|Plan tab|Profile tab|Pulse|Capture tab|DayTimelineRail|Hero Step Panel|Hero Step Module|Calendar tab|Inbox tab" Native Sources --glob "*.swift"
```

## Exact Scan Output

Full output file:

`artifacts/ambitions-ui-reconstruction/final-gate/AMB-559-banned-term-scan-output.txt`

Output summary:

- Total hits: `1066`
- `Dashboard`: `311`
- `Assistant`: `2`
- `AI decided`: `2`
- `best next move`: `4`
- `next best move`: `3`
- `overdue`: `43`
- `failed`: `254`
- `streak`: `63`
- `score`: `347`
- `optimize`: `4`
- `Plan tab`: `1`
- `Pulse`: `44`
- `Calendar tab`: `1`

## Classification

Top-level IA check:

- `Native/Ambitions/App/AppTab.swift` keeps `AppTab.allCases` as `.today`, `.goals`, `.time`, `.motion`, `.you`.
- `.capture` remains a compatibility/global-routing case and canonicalizes to `.today` for top-level selection.
- No evidence from this audit shows `Pulse`, `Capture`, `Plan`, `Profile`, `Calendar`, or `Inbox` as active top-level IA.

Representative active/runtime risk:

- `Native/Ambitions/Services/GoalExplainabilityProjector.swift` emits `Understanding score` and `Path score` into `GoalConfidenceState.detailLabels`.
- `Native/Ambitions/Features/Goals/GoalDetailScreen.swift` renders `state.confidence.detailLabels`.
- `Native/Ambitions/Features/Habits/HabitsFeatureService.swift` includes `Current dashboard range` and `streak` model/copy paths.

Representative compatibility/internal/historical classes:

- Tests asserting absence of stale IA, such as `XCTAssertFalse(app.tabBars.buttons["Pulse"].exists)`, are expected compatibility-proof hits.
- `ProofPulse` component/type names are not the old `Pulse` tab, but still need owner classification in the remediation pass.
- Enum/state names such as `.failed`, `.failedSafely`, and `AsyncViewState.failed` are internal state names unless rendered directly as user-facing copy.
- `Dashboard` model/type names such as `TimeDashboard`, `YouDashboard`, `HabitsDashboard`, and `InsightsDashboard` are internal/source-compatibility naming risks, not proof of current top-level IA by themselves.

## Focused Tests

Not available - no focused test target is directly relevant to a read-only banned-term/stale-IA scan. The required `rg` command is the relevant proof mechanism for AMB-559.

## Validation

- Required `rg` scan command - completed with `1066` hits; full output saved at `artifacts/ambitions-ui-reconstruction/final-gate/AMB-559-banned-term-scan-output.txt`.
- `python3 scripts/ambitions-unsupported-claim-scan.py artifacts/ambitions-ui-reconstruction/final-gate/AMB-559-banned-term-and-stale-ia-scan.md artifacts/ambitions-ui-reconstruction/final-gate/AMB-559-banned-term-scan-output.txt` - Green.
- `bash scripts/codex-forbidden-claim-scan.sh artifacts/ambitions-ui-reconstruction/final-gate/AMB-559-banned-term-and-stale-ia-scan.md artifacts/ambitions-ui-reconstruction/final-gate/AMB-559-banned-term-scan-output.txt` - not applicable as a blocking closeout gate for this audit artifact; it flags the preserved raw evidence required by AMB-559.
- `bash scripts/release-claim-safety-scan.sh` - not applicable as a blocking closeout gate for this audit artifact; it flags preserved raw scan output from an existing test fixture, not a new release claim in this report.
- `git diff --check` - passed.

## Changed Files

Active Swift/runtime files changed:

- none

Audit artifacts added:

- `artifacts/ambitions-ui-reconstruction/final-gate/AMB-559-banned-term-and-stale-ia-scan.md`
- `artifacts/ambitions-ui-reconstruction/final-gate/AMB-559-banned-term-scan-output.txt`

## Follow-Up

- AMB-605 - remove active banned-term runtime UI hits and rerun the AMB-559 scan.

## Proof Boundaries

This report is audit proof only. It does not claim source remediation, visual approval, accessibility approval, release readiness, device proof, CI proof, TestFlight readiness, App Store readiness, or product completion.

## Required Completion Footer

Verdict: Red
Artifact paths:
- `artifacts/ambitions-ui-reconstruction/final-gate/AMB-559-banned-term-and-stale-ia-scan.md`
- `artifacts/ambitions-ui-reconstruction/final-gate/AMB-559-banned-term-scan-output.txt`
Focused tests:
- `not available` - no focused test target is directly relevant to a read-only banned-term/stale-IA scan; the required `rg` command is the relevant proof mechanism.
Changed files:
- none
Remaining Yellow debt:
- AMB-605
