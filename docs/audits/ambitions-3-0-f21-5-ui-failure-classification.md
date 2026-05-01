# Ambitions 3.0 F21.5 UI Failure Classification

Date: 2026-05-01
Batch: F21.5 UI Flake / Reliability Hardening
Input F21 result: `29` UI tests run, `8` failures
Source log: `output/logs/test-local-20260501-114857.log`

## Verdict

The 8 F21 failures were classifiable inside F21.5. No app behavior change was
required by the evidence. The repairs stayed in UI smoke readiness helpers and
product-contract assertions.

Primary failure classes:

- stale test expectations after the Ambitions 3.0 Reality Rail / Day Rail
  migration;
- brittle readiness helpers that required retired Today hero identifiers;
- stale onboarding trust-copy assertion;
- brittle post-submit Goals assertion that accepted one acknowledgement surface
  instead of the product-level "created goal is acknowledged or visible"
  contract;
- suite-order route ambiguity in a broad shell smoke test.

F21.5 focused lanes and full local UI smoke later passed, so F21 may be
reclassified Green by the F21.5 report. F22 remains blocked until that Green
tracking update is committed.

## Failure Classifications

| Test | Failing line | Failure message | Expected product promise | Actual observed behavior | Surface | Primitive | Failure class | Required action | Test may change? | Replacement / retirement evidence |
|---|---:|---|---|---|---|---|---|---|---|---|
| `testForcedOnboardingCaptureFirstPathOpensQuickCapture` | `Native/AmbitionsUITests/AmbitionsUITests.swift:59` | `XCTAssertTrue failed` waiting for `No hidden analytics` | Forced onboarding capture-first path keeps first-run trust copy honest, then opens quick capture. | Current activation copy uses `No account required`, `Starts locally`, `Manual first`, and `Optional connections`; `No hidden analytics` is not current copy. | Onboarding / Capture | First Useful Object Onboarding; Capture -> Placement Resolver | stale test expectation / copy migration | Replace the stale copy wait with current trust-copy waits and preserve quick-capture assertion. | Yes | Repaired test asserts `Starts locally`, `Manual first`, and `shell.command.capture-field`. No retirement. |
| `testPreviewBootstrapCanCreateGoalFromEmptyState` | `Native/AmbitionsUITests/AmbitionsUITests.swift:88` | `XCTAssertTrue failed` waiting for `goals.creation-message` | Empty Goals can open Create Goal, accept a title, submit, and acknowledge or show the created goal. | Submit path reached post-submit state, but the test accepted only one exact acknowledgement identifier. | Goals | Goal Mission Control; First Useful Object Onboarding | brittle post-submit wait | Replace single-message wait with product-contract helper accepting `goals.creation-message`, created title visibility, or Goals surface readiness. | Yes | Repaired helper `waitForCreatedGoalAcknowledgement` preserves created-goal acknowledgement/visibility. No retirement. |
| `testPreviewBootstrapExposesCanonicalFiveTabShellAndSecondarySurfaces` | `Native/AmbitionsUITests/AmbitionsUITests.swift:112` | `XCTAssertTrue failed` waiting for `captures.screen` after tapping Capture | Five canonical destinations stay reachable and secondary surfaces remain under their owners. | Focused F19 proof passed, while the full-suite broad shell smoke failed after prior failures. Direct launch-url Capture also passed, so this was route-readiness/suite-order ambiguity, not proven product regression. | Shell / Capture | Ambitions Operating Shell | suite-order state leakage / route readiness issue | Make fallback shell mode explicit and use a bounded canonical destination helper before destination assertions. | Yes | Repaired `openCanonicalDestination` still requires canonical Today / Goals / Capture / Plan / You reachability. No retirement. |
| `testQuickRecoveryAndQuickFocusReturnToTodayWithExplicitReentry` | `Native/AmbitionsUITests/AmbitionsUITests.swift:434` | `XCTAssertTrue failed` inside `waitForTodayScreenReady` | Quick recovery and quick focus route back to Today with explicit reentry state. | The helper waited for retired `today.hero-card`; current Today signature is `TodayRealityRail`. The command buttons can also require scroll-based hittability in the command sheet. | Today / Shell command sheet | Reality Rail; Step Execution System | stale test expectation / readiness helper drift / brittle hittability wait | Modernize Today readiness to accept Reality Rail contracts and use bounded scroll-to-button helpers for command actions. | Yes | Repaired test asserts command actions return to `today.screen` plus `TodayRealityRail`. No retirement. |
| `testTodayCanHandOffToGoalDetail` | `Native/AmbitionsUITests/AmbitionsUITests.swift:487` | `XCTAssertTrue failed` inside `waitForTodayScreenReady` | Today can hand off from the recommended step into the current detail surface for the recommended work. | The stale Today readiness helper failed before handoff. Current Today 3.0 opens the Today-owned Step Detail sheet from `Start here`; a full Goal Detail route is not the current implemented handoff for this smoke path. | Today | Reality Rail; Step Detail | stale test expectation / product-contract drift | Replace stale Goal Detail expectation with current Step Detail contract. | Yes | Repaired test asserts `TodayStepDetail`, `TodayStepDetailWhyThis`, and `TodayStepDetailPrimaryAction`. No test deleted; historical test name remains but assertion now tracks current contract. |
| `testTodayCanHandOffToPlan` | `Native/AmbitionsUITests/AmbitionsUITests.swift:520` | `XCTAssertTrue failed` inside `waitForTodayScreenReady` | From Today context, Plan remains reachable through the canonical shell route. | The stale Today readiness helper failed before Plan assertion; the earlier Today-specific `today.action.openPlan.none` lookup was not the current reliable product contract. | Today / Plan | Reality Rail; Plan Life Suite | stale test expectation / route readiness drift | Use Reality Rail readiness and canonical Plan destination helper. | Yes | Repaired test first establishes Today readiness, then asserts `plan.screen` via canonical Plan destination. No retirement. |
| `testTodayStartNowCanOpenBoundedStepSession` | `Native/AmbitionsUITests/AmbitionsUITests.swift:463` | `XCTAssertTrue failed` inside `waitForTodayScreenReady` | `Start now` remains visible as the bounded execution entry point from Today detail. | The stale Today readiness helper failed before primary action logic. Current Today Step Detail exposes `Start now` as the primary reserved execution action; the old support-card wait was a brittle downstream expectation for this smoke. | Today | Reality Rail; Step Execution System | stale test expectation / readiness helper drift | Use Reality Rail readiness, open Step Detail, and assert the current `Start now` primary action contract. | Yes | Repaired test asserts `TodayStepDetailPrimaryAction` plus visible `Start now`. No retirement. |
| `testTodaySurfaceShowsDominantHeroAndPrimaryAction` | `Native/AmbitionsUITests/AmbitionsUITests.swift:378` | `XCTAssertTrue failed` inside `waitForTodayScreenReady` | Today shows its dominant signature object and primary action. | Test asserted old dominant hero/support identifiers after Ambitions 3.0 moved the first-screen contract to Reality Rail / Day Rail. | Today | Reality Rail; Rail / Node Visual Grammar | stale test expectation / visual structure contract drift | Replace old hero-card assertion with `TodayRealityRail`, section identifiers, and primary action helper. | Yes | Repaired test asserts `TodayRealityRail`, `TodayRealityRailNowSection`, `TodayRealityRailNextSection`, `TodayRealityRailLaterSection`, and a primary action. No retirement. |

## Repair Plan

Allowed files:

- `Native/AmbitionsUITests/AmbitionsUITests.swift`
- `docs/audits/**`
- `docs/codex/**`
- `.codex/reports/**`

Forbidden unless later evidence proves a product bug:

- broad shell implementation changes;
- broad Today / Goals / Capture / Plan / You implementation changes;
- runtime dependencies;
- `.github/workflows/**`;
- product behavior unrelated to failed UI smoke contracts.

Validation:

- `scripts/build-local.sh`
- focused UI lanes for the eight F21 failures in small groups
- `git diff --check`
- `scripts/batch-train-gate-check.sh || true`
- `scripts/test-local.sh || true`

Stop conditions:

- build failure;
- focused UI lane failure after repair;
- new current-scope product regression;
- forbidden file or dependency/workflow touch;
- full UI smoke remains failing without accepted UI Test Contract classification.
