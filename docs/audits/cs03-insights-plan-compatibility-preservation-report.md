# CS03B Insights Compatibility Preservation Report

<!-- markdownlint-disable MD013 -->

Status: CS03B complete with commit/push evidence.
Date: 2026-05-02

## Batch

- Formal batch ID: `CS03`
- Internal completed stage: `CS03B`
- Global order number: `042`
- Result: PASS WITH YELLOW.
- Validation strength: Strong focused compatibility validation.

## Scope Completed

CS03B adds focused test proof that legacy `insights` compatibility and visible
`Plan` canon can coexist without route/raw/default/accessibility drift.

Changed test files:

- `Native/AmbitionsTests/App/AppShellNavigationTests.swift`
- `Native/AmbitionsTests/App/ExternalRoutingTests.swift`

CS03B did not edit production Swift. It did not rename, delete, or retire any
`Insights` symbol.

## Proof Added

- Legacy `AppTab.insights` selection still normalizes to `.profile`.
- Legacy `insights` selection opens the history support route.
- Visible top-level tabs remain `Today / Goals / Capture / Plan / You`.
- `Insights` does not appear as a visible top-level tab.
- `AppTab.insights.rawValue` remains `insights`.
- `AppTab.insights.title` remains `History`.
- `ambitions://tab/insights` still parses as `.openTab(.insights)`.
- `ambitions://insights/history` still parses as `.openInsightsRoute(.history)`.
- `ambitions://insights/monthly-review` still parses as
  `.openInsightsRoute(.monthlyReview)`.
- Generated deep links for `InsightsRouteTarget` remain stable.
- Notification/widget payloads with `tab=insights` still parse.
- `openInsightsRoute` payloads still use `tab=profile` for current You/history
  support compatibility.
- Router dispatch of `.openInsightsRoute(.monthlyReview)` still lands in the
  You/Profile support route.

## File-Size And Diff Notes

- `AppShellNavigationTests.swift`: 341 lines after CS03B.
- `ExternalRoutingTests.swift`: 482 lines after CS03B.
- Diff is test-only and reviewable.
- No production owner file size changed.

## Compatibility Boundaries

- Route/raw values changed: no.
- `InsightsRouteTarget` changed: no.
- Accessibility identifiers changed: no.
- Default-tab/persistence behavior changed: no.
- Shell navigation behavior changed: no.
- Product behavior changed: no.

## Yellow Advisories

| Advisory | Classification | Owner | Why deferral is safe |
| --- | --- | --- | --- |
| Current repo behavior maps legacy `insights` to You/Profile history support rather than directly to Plan. | Already Owned by Later Batch | CS10 handoff or future product owner decision | CS03B proves current behavior and visible `Plan` canon are stable; changing destination would be a behavior migration. |
| Internal `Insights` type/file/folder names remain. | Already Owned by Later Batch | CS03C or future PD/AOS owner | They carry contextual-intelligence/history semantics and are not visible top-level IA claims. |
| Accessibility identifiers remain `insights.*`. | Already Owned by Later Batch | CS03C only after alias/deprecation proof | Identifier stability protects UI automation and external route proof. |
| Existing repo-wide docs QA backlog remains. | Existing Repo-Wide Advisory | Docs QA backlog | Not caused by CS03B and not required for focused route/test proof. |

## Validation Commands

| Command | Result | Notes |
| --- | --- | --- |
| `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/AppShellNavigationTests -only-testing:AmbitionsTests/ExternalRoutingTests test CODE_SIGNING_ALLOWED=NO` | PASS | 58 tests, 0 failures. |
| `git diff --check` | PASS | No whitespace errors. |
| Changed-file boundary check | PASS | Dirty files are limited to focused app shell/external routing tests plus `docs/**` and `.codex/**`. |
| Release-claim scan | PASS WITH YELLOW | Hits are guardrails, scan commands, historical logs, and explicit non-claims only. |
| `scripts/run-doc-qa.sh || true` | PASS WITH YELLOW | Existing stale-guidance/deprecated-language/markdownlint backlog remains; lychee passed with 647 OK and 0 errors. |
| `scripts/batch-train-gate-check.sh || true` | PASS WITH YELLOW | Existing dirty-tree hint before commit; no CS03B blocking gate failure. |

## Claims

CS03B may claim legacy `insights` raw/external route compatibility is preserved
by focused tests while visible top-level `Plan` canon remains intact.

## Non-Claims

CS03B does not claim the Insights seam is retired, Plan migration complete,
`InsightsRouteTarget` replaced, accessibility identifiers renamed,
physical-device proof, release readiness, App Store readiness, TestFlight
readiness, public accessibility conformance, PXOS implementation, Signature
Interface implementation, Product Depth implementation, or AmbitionsOS
implementation.

## Rollback

Revert the two focused test files and this report. No production behavior
rollback is required because CS03B does not edit app code.

## Next Safe Path

Formal CS03 may close as PASS WITH YELLOW after CS03B commit evidence. CS03C
remains blocked/deferred. The next global batch is CS04 Habits/Ritual/Plan
Compatibility Retirement only if dry-run selection says `Execution allowed:
YES`.

## Commit SHA

`126e86be` (`Preserve Insights compatibility while supporting Plan surface naming`).
