# AOR-MOTION-02 Proof, Recovery, Re-entry Current Report

Issue: AMB-544
Date: 2026-06-06
Status: Yellow

## Scope

Extended the AMB-543 Motion Current root so proof, recovery, and re-entry lanes carry embodied current states with source/proof/receipt traces.

## Files changed

- `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift`
- `Native/AmbitionsTests/Motion/MotionCurrentScreenTests.swift`
- `prompts/batches/AMB-544.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/motion-current-lanes-after.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/motion-current-lanes-small-after.png`
- `artifacts/ambitions-ui-reconstruction/reports/AOR-MOTION-02-report.md`

## Product behavior

- Proof, Recovery, and Re-entry lanes now include compact current-state rows rather than only lane prose.
- Each state row carries:
  - state title
  - state label
  - source trace
  - proof trace
  - receipt trace
  - accessibility summary
- Required current states are represented:
  - no proof yet
  - proof available
  - proof transferred
  - recovery active
  - recovery complete
  - stalled but returnable
  - re-entry available
  - source unavailable
  - receipt linked
  - life-area development
  - changed object
- Recovery copy uses calm route / Still counts language.
- Re-entry copy uses return point / available language without failure framing.

## Active Truth Files Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`

## Runner And Guard Evidence

- Runner prompt saved with Ambitions runner header: `prompts/batches/AMB-544.md`
- Runner self-healed prompt wording only.
- Champion coverage passed in runner.
- Parallel implementation guard preflight passed: `build/reports/parallel-implementation-guard/AMB-544-pre.md`
- Nested runner phase stopped before patching because the external model/OAuth path was unavailable.
- Local bounded patch proceeded only after runner-local champion and pre-guard Green.

## Validation

Passed:

- `make xcode-build-for-testing BATCH=AMB-544`
  - passing summary: `.codex/xcode-summaries/AMB-544/20260607T021212Z-bft-41905-13841/build-for-testing-summary.json`
- `make xcode-focused-test BATCH=AMB-544 TEST=AmbitionsTests/MotionCurrentScreenTests`
  - passing summary: `.codex/xcode-summaries/AMB-544/20260607T022207Z-AmbitionsTests-MotionCurrentScreenTests-48425-18583/focused-test-summary.json`
  - executed tests: 8
- `make xcode-focused-test BATCH=AMB-544 TEST=AmbitionsUITests/AmbitionsUITests/testPreviewBootstrapExposesCanonicalFiveTabShellAndSecondarySurfaces`
  - passing summary: `.codex/xcode-summaries/AMB-544/20260607T022736Z-AmbitionsUITests-AmbitionsUITests-testPreviewBootstrapExposesCanonicalFiveTabShe-50715-12379/focused-test-summary.json`
  - executed tests: 1
- Forbidden framing scans returned no matches in Motion source/tests for analytics, dashboard, activity feed, score, streak, XP, productivity, failure, shame, overdue, and placeholder-card framing.

Repair cycle:

- First focused Motion test run failed because a stale AMB-543 assertion still banned `source unavailable`; AMB-544 requires that as a current state. The assertion was corrected to allow the required state while still banning the old empty placeholder.
- Second focused Motion test run passed.

## Screenshot Proof

Captured:

- `artifacts/ambitions-ui-reconstruction/screenshots/motion-current-lanes-after.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/motion-current-lanes-small-after.png`

Screenshot boundary:

- Current available simulator tooling captured the top viewport only; no scroll/gesture command was available in `simctl` or the enabled Xcode MCP tools.
- The screenshots show Motion Current root shape, lane entry, and the beginning of the Proof lane.
- The below-fold embodied state rows are proven by source and focused tests, not by a scrolled screenshot in this run.

## Accessibility Boundary

Implemented:

- Each embodied lane state row has a combined accessibility label and value.
- Each row value includes Source, Proof, and Receipt.
- Lane accessibility values include the embodied state summaries.
- Decorative dots remain hidden from accessibility.

Not verified:

- Manual VoiceOver traversal.
- Full Dynamic Type screenshot sweep.
- Reduce Motion screenshot.
- Increase Contrast screenshot.
- Scrolled screenshot of every embodied lane row.
- Real-device proof.
- Performance measurement.

## Claim Boundary

This is source, local simulator build/test, focused UI test, and top-viewport screenshot proof for AMB-544 only. It is not release proof, public accessibility proof, performance proof, privacy/legal approval, physical-device proof, TestFlight readiness, or App Store readiness.

## Rollback

Revert the AMB-544 commit to remove the embodied lane state rows, test assertions, prompt, screenshots, and report.
