# CS05B ActiveFocus/TodayFocus Compatibility Proof Report

<!-- markdownlint-disable MD013 -->

Date: 2026-05-03

Status: PASS WITH YELLOW

Formal batch: 044 — CS05 ActiveFocus TodayFocus Retirement

Internal stage: CS05B — ActiveFocus Compatibility Preservation Proof

## Summary

CS05B added focused compatibility tests only. It did not edit production Swift, route/raw values, default-tab behavior, persistence behavior, accessibility identifiers, widget source files, App Intent source files, or Today feature source files.

The proof preserves the current source-truth contract documented by CS05A:

- `activeFocus` remains a legacy external snapshot schema field.
- `ExternalSurfaceNowState.activeFocus` remains decodable/encodable and has priority over `bestNextStep` in external glance/widget projection.
- `context=focus` remains carried in generated deep links and payloads for Today focus context.
- Notification/widget payload translators currently normalize `tab=today` payloads to the Today tab while retaining the `context=focus` value in the payload itself.
- `quick_focus` remains a shell command raw value that selects Today with `.focus` entry context.
- `FocusNowWidget` projection continues to use the active focus reference as its primary URL target.

No seam was retired. CS05C remains deferred until a later proof shows a narrower internal retirement is safe.

## Files Changed

Focused test files:

- `Native/AmbitionsTests/App/ExternalRoutingTests.swift`
- `Native/AmbitionsTests/App/ExternalSurfaceActionPayloadTests.swift`
- `Native/AmbitionsTests/App/ExternalSurfaceSnapshotTests.swift`
- `Native/AmbitionsTests/App/ExternalWidgetProjectionTests.swift`
- `Native/AmbitionsTests/App/ShellCommandRouterTests.swift`

Docs/status files:

- `docs/audits/cs05-activefocus-todayfocus-compatibility-proof-report.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `docs/codex/batch-trains/CS01_CS10_COMPATIBILITY_SEAM_RETIREMENT_TRAIN.md`

## Proof Matrix

| Seam | Proof | Result |
| --- | --- | --- |
| `activeFocus` snapshot field | `testActiveFocusSnapshotFieldRemainsLegacyCompatible` encodes JSON containing `activeFocus` and decodes focus and best-next-step references. | Green |
| Active focus priority | `testGlanceStatePreservesActiveFocusPriorityOverBestNextStep` proves glance state chooses `activeFocus` over `bestNextStep`. | Green |
| FocusNow widget projection | `testFocusNowWidgetProjectionPreservesActiveFocusPrimaryReference` proves widget projection primary URL uses the active focus goal reference and privacy copy remains hidden-detail. | Green |
| Today focus deep link | `testFocusContextRoutesAndPayloadsRemainCompatibleWithTodayStepPosture` proves `ambitions://tab/today?context=focus` round-trips to `.openToday(.focus)`. | Green |
| Notification/widget focus payloads | The same routing test proves payloads carry `context=focus` while current translators normalize `tab=today` to `.openTab(.today)`. | Accepted Yellow |
| `quick_focus` shell command | `testQuickFocusCommandPreservesFocusContextCompatibility` proves raw value, selected tab, Today focus entry context, route history presentation context, and destination. | Green |
| Default tab / persistence | Not touched by CS05B. No migration behavior changed. | Green |
| Accessibility identifiers | Not touched by CS05B. Existing identifiers remain stable. | Green |

## Validation

Focused test command:

```bash
set -o pipefail
mkdir -p output/logs
LOG="output/logs/cs05b-activefocus-compatibility-tests-$(date +%Y%m%d-%H%M%S).log"
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:AmbitionsTests/ExternalSurfaceSnapshotTests \
  -only-testing:AmbitionsTests/ExternalSurfaceActionPayloadTests \
  -only-testing:AmbitionsTests/ExternalWidgetProjectionTests \
  -only-testing:AmbitionsTests/AppIntentRoutingTests \
  -only-testing:AmbitionsTests/ExternalRoutingTests \
  -only-testing:AmbitionsTests/ShellCommandRouterTests \
  -only-testing:AmbitionsTests/CanonicalNowStateModelsTests \
  test CODE_SIGNING_ALLOWED=NO | tee "$LOG"
```

Result: PASS — 74 selected tests, 0 failures.

Passing log: `output/logs/cs05b-activefocus-compatibility-tests-20260503-120349.log`

Additional validation:

| Command | Result |
| --- | --- |
| `git diff --check` | PASS |
| changed-file boundary scan | PASS; touched files are focused tests plus docs/status files only. |
| release-claim scan | PASS WITH YELLOW; hits are forbidden-claim lists, scan commands, historical logs, and explicit non-claims. |
| `scripts/run-doc-qa.sh || true` | PASS WITH YELLOW; existing stale-guidance, deprecated-language, and markdownlint advisory backlog remains; lychee passed 647 links with 0 errors. |
| `scripts/batch-train-gate-check.sh || true` | PASS WITH YELLOW before commit with expected dirty-tree hint only. |

Earlier failed attempts in the same repair loop were caused by CS05B test-authoring mistakes: missing `ExternalSurfaceSnapshot.nextAction` arguments and an over-specific assertion that notification/widget payload translators should return `.openToday(.focus)` rather than current repo truth `.openTab(.today)` with `context=focus` retained in payload values. These were repaired in tests only.

## Yellow Advisories

| Advisory | Owner | Why Deferral Is Safe |
| --- | --- | --- |
| CS05C narrow internal retirement remains blocked. | CS05C | CS05B proves preservation, not retirement. Keeping `activeFocus`, `TodayFocus*`, `.focus`, and `FocusNowWidget` names avoids compatibility break. |
| Notification/widget payload translators normalize `tab=today` to `.openTab(.today)` even when payload values include `context=focus`. | CS05C or a future external-route adapter batch | CS05B documents and tests current behavior. No compatibility value is removed, and payload context is preserved. |
| Rendered widget/App Shortcut OS proof was not performed. | Human/platform proof backlog | Unit/simulator tests prove model and routing contracts. CS05B makes no rendered widget, physical-device, App Store, or TestFlight claim. |
| Existing docs QA backlog remains. | Existing repo-wide docs QA backlog | The backlog predates CS05B and does not weaken ActiveFocus/TodayFocus compatibility proof. |

## Red Issues

None remaining.

## Claims

CS05B may claim focused simulator/unit compatibility proof for current `activeFocus`, Today focus route payload, FocusNow widget projection, and quick focus shell command behavior.

## Non-Claims

CS05B does not claim the ActiveFocus/TodayFocus seam is retired. It does not claim production readiness, TestFlight readiness, App Store readiness, physical-device proof, rendered widget proof, public accessibility conformance, release readiness, or AmbitionsOS/Signature Interface/Product Depth implementation.

## Next Safe Path

Defer CS05C as accepted Yellow unless a future dry-run proves a tiny internal retirement is safe. Resume the global order at CS06 dry-run.
