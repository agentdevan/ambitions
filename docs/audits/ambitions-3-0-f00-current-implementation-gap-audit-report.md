# Ambitions 3.0 F00 Current Implementation Gap Audit Report

Date: 2026-04-30

## Executive Verdict

F00 completed as an audit-only traceability pass. Ambitions 3.0 has a passing local build and passing unit-test suite, but the implementation remains PARTIAL against the 3.0 front-end/product primitive map because Reality Rail, Step Detail, Step Session, Action Closure, receipt/review surfacing, Capture placement, Plan Life Suite, Goal Mission Control, You trust controls, external surfaces, accessibility proof, and UI test modernization all still have documented gaps.

FAANG handoff readiness remains PARTIAL. Do not claim FAANG handoff readiness, TestFlight readiness, App Store readiness, public accessibility verification, final RC lock, or real-device proof from this batch.

## Task Width Classification

- Task size: L
- Type: audit/docs-only
- Implementation: prohibited
- App code changes: prohibited
- Workflow changes: prohibited
- Runtime dependency changes: prohibited
- Branch: `main`
- Starting HEAD: `5282b23bd6ad62ad3b4870fe0694f492d5285250`

## Role Passes Used

- FAANG Team Operating Model
- Task Width Gate
- Current Run State Protocol
- Source Truth Reconciliation Protocol
- Repo Truth Enforcer
- FAANG Handoff Auditor
- Legacy Language Sweeper
- Release Readiness Gate Runner
- Active Canon Pack
- UI Test Contract Pack
- Repo Hygiene Pack
- Copy Guard Pack
- Local CI Parity Pack for evidence only

## Scans Run

Legacy language scan:

```bash
rg -n --hidden --glob '!/.git/**' 'Start Focus|Focus Session|best next move|next best move|AI confidence|productivity score|profile tab|insights tab|habits tab|overdue|failed|missed' . || true
```

Internal identifier scan:

```bash
rg -n --hidden --glob '!/.git/**' 'startFocus|TodayFocus|activeFocus|bestNextMove|capturesInbox|Insights|Profile|Habits' Native Sources AppUI docs .github project.yml || true
```

## Build/Test Baseline

| Command | Status | Evidence |
| --- | --- | --- |
| `scripts/validate-dev-tools.sh \|\| true` | PASS | Xcode 26.3, XcodeGen 2.45.4, ripgrep 15.1.0, git 2.53.0, gh 2.92.0, jq 1.8.1, xcbeautify 3.2.1, markdownlint-cli2 0.22.1, lychee 0.24.1. |
| `scripts/run-doc-qa.sh \|\| true` | PARTIAL/advisory | Broad pre-existing markdownlint backlog: 8,980 markdownlint errors and 5 older local-link failures. Latest logs under `docs/audits/doc-qa/20260430-164517-*`. |
| `scripts/build-local.sh \|\| true` | PASS | `Ambitions.xcodeproj` generated; `iPhone 17` simulator build succeeded. |
| `scripts/test-local.sh \|\| true` | PARTIAL | `AmbitionsTests` passed 744 tests; `AmbitionsUITests` ran 29 tests with 9 failures. |

UI xcresult:

`/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.04.30_16-06-21--0400.xcresult`

## UI Test Failure Summary

Failing UI tests:

- `testDemoPlanPressureScrubberUpdatesSelectedDayAndActionLane`
- `testForcedOnboardingCaptureFirstPathOpensQuickCapture`
- `testGoalDetailTrustAndMemoryDisclosureStayBelowStrategicLayer`
- `testPreviewBootstrapCanCreateGoalFromEmptyState`
- `testQuickRecoveryAndQuickFocusReturnToTodayWithExplicitReentry`
- `testShellOwnedCreateGoalFlowWorksFromCommandSheet`
- `testTodayCanHandOffToGoalDetail`
- `testTodayCanHandOffToPlan`
- `testTodayStartFocusCanOpenBoundedFocusScreenlet`

Affected surfaces: Today, Plan, Capture/onboarding, Goals create flow, Goal Detail, shell command sheet, focus/recovery re-entry.

Classification: mixed outdated test expectation, real implementation gap, accessibility identifier drift, navigation drift, copy migration, and product-canon conflict. F16 owns modernization after F01-F15 reduce the underlying app/copy/identifier drift.

## Legacy Language Summary

- Total scan hits: 858
- Allowed migration/copy-guard/archive references: broad majority, especially active canon/copy-guard docs and historical docs.
- Active user-facing debt: confirmed in widget/external-surface fallback copy and some defensive error strings, including `overdue` and `failed`.
- Test debt: present where tests still encode old Focus/Profile/Insights/Habits assumptions.
- Internal migration debt: tracked with the identifier scan and assigned to F15 after functional F01-F14 work.
- Recommended cleanup batch: F15 Legacy identifier migration, with F16 UI test modernization immediately after.

## Internal Identifier Summary

- Total scan hits: 3,443
- Active code hits: high, including `Profile`, `Insights`, `Habits`, `startFocus`, `bestNextMove`, `capturesInbox`, `activeFocus`, and `TodayFocus`.
- User-facing leaks: limited but confirmed around external-widget/fallback wording and tests.
- Compatibility seams: `AppTab.profile` mapping to `You`, `AppTab.insights` mapping to History, route targets, and legacy test fixtures.
- Persisted/deep-link risk: non-trivial; do not bulk rename before compatibility adapters are designed.
- Recommended migration batch: F15, after F01-F14 establish the 3.0 surface contracts.

## Strongest Implementation Gaps

- Reality Rail / Day Rail is not represented as a canonical first-class view-state object.
- Step Detail is routed but not implemented as the 3.0 signature object contract.
- Step Session is still bounded-focus flavored and needs later migration.
- Action Closure and Still Counts are modeled but not fully surfaced in the 3.0 close/recover loop.
- Proof & Receipt Ledger has strong domain models but incomplete user-facing ledger/review projection.
- Capture has a strong smart-attachment base but needs 3.0 Placement Resolver and Grow into Goal work.
- Goals still needs Goal Mission Control organization, not just existing board/detail behavior.
- You trust/memory work is strong but still internally Profile-named and not the full 3.0 control plane.
- External surfaces compile but still carry legacy focus/overdue/fallback language and lack rendered/device proof.

## Strongest Test Gaps

- UI smoke expectations are not yet aligned to the 3.0 product contract.
- Several UI failures likely mix outdated expectations with real missing states.
- Accessibility identifiers and labels need a modernization pass after surface contracts stabilize.
- Test fixtures still preserve historical Focus/Profile/Insights/Habits vocabulary.

## FAANG Handoff Blockers

- Full UI smoke suite is PARTIAL.
- Legacy language and internal identifier debt remains active.
- Current implementation does not fully satisfy Ambitions 3.0 primitives.
- Public accessibility, real-device, external-surface rendering, Shortcuts/Siri, widget gallery, Live Activity lifecycle, notification delivery, signed archive, TestFlight, and App Store gates remain unverified.
- Doc QA markdown/link backlog remains advisory and unresolved.

## Recommended F01 Starting Scope

F01 should create the Reality Rail / Day Rail foundation before visual rewrite work. It should add deterministic Today rail view-state/projection support for Now / Next / Later, `Start here`, `Start now`, duration/source labels, privacy-safe rows, row-detail placeholders, and future closure/proof slots. F01 should keep Today rendering mostly intact and prove the foundation with focused unit tests and copy guards.

## Risks

- Renaming legacy identifiers too early could break persisted/deep-link compatibility.
- Updating UI tests before the app contracts are implemented could turn real gaps into false green.
- Touching shell/Meridian before F01-F16 risks hiding core-loop gaps behind navigation churn.
- Treating doc QA backlog as launch blocking without prioritization could distract from the known app/test blockers.

## Next Exact Prompt

Use the copy/paste prompt in `docs/canon/Ambitions_3_0_Current_Implementation_Gap_Audit.md` under `Recommended Next Codex Prompt: F01 Reality Rail Foundation`. That prompt is the source-controlled F01 handoff artifact and includes required docs, context pack, skills, protocols, allowed/forbidden files, implementation scope, tests, copy/accessibility/privacy requirements, validation commands, run-state instructions, and closeout format.
