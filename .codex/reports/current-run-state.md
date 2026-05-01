# Current Run State

- current task: F04 Step Session rename/migration and routing
- task size: M/L
- active mode: Product Train / F04-F06 Step Closure Proof Train
- active primitive: Step Execution System
- active surface: Today
- active context pack: Ambitions 3.0 source stack plus F04-F06 train manifest
- active skill: phase-executor plus repo-truth-enforcer
- active operations: batch-train-gate-protocol; Today Step Session routing; focused Today validation
- active validation packs: base-build-test-pack; copy-guard-pack; privacy-trust-pack; accessibility-pack; architecture-scan-pack
- docs read: README.md; docs/README.md; docs/canon/README.md; AGENTS.md; Ambitions 3.0 source stack; Batch Train Orchestrator; F04-F06 train prompt/manifest; F07-F16 train manifests/prompts for ordering; F13.5/F16.5 conditional prompts; BATCH_REGISTRY; current gap audit; F03.5 report; batch-train orchestrator report
- files allowed: Native/Ambitions/Features/Today; Native/Ambitions/PreviewSupport/PreviewTodayScenarios.swift; Native/AmbitionsTests/Today; Native/AmbitionsUITests/AmbitionsUITests.swift focused identifier update; Today route/presentation compatibility files; docs/codex; docs/audits; .codex/reports/current-run-state.md; .codex/reports/current-batch-train-state.md
- files forbidden: F05 Action Closure behavior; F06 Proof/Receipt Ledger behavior; Plan/Capture/Goals/You broad work; Shell/Meridian implementation; global legacy identifier migration; .github/workflows/**; runtime dependency manifests; release-readiness claims
- accepted Yellow reason: doc QA advisory backlog unchanged; known full UI smoke readiness failures unchanged; large-file architecture warnings unchanged in substance; legacy focus command/deep-link compatibility remains intentionally deferred to F15
- preflight git: clean on main at 93aabb771fb79e21be243b6b693b2a576ccfc5b0 / 93aabb77 Complete F03.5 Today state contract hardening
- preflight validation: scripts/validate-dev-tools.sh PASS; scripts/batch-train-preflight.sh PASS; scripts/batch-train-gate-check.sh PASS; scripts/swiftui-architecture-scan.sh advisory; scripts/build-local.sh PASS on iPhone 17

## F04 Implementation

- Today action naming migrated from `.startFocus` to `.startStepSession` for the scoped Today action seam.
- `TodayEntryContext.stepSession` now drives `Start now`; legacy `.focus` remains a compatibility alias for existing shell/external routes until F15.
- Existing bounded execution screenlet is now exposed as `TodayStepSessionState`, `TodayStepSessionCard`, and `today.support.step-session`.
- Step Session copy is step-first and explicitly not timer-first.
- F05/F06 behavior remains reserved: Action Closure, Still Counts, Proof, and Receipt Ledger were not implemented.

## Validation

- build: `scripts/build-local.sh` PASS on iPhone 17 after preview fixture label update.
- focused tests: `TodayViewModelTests` PASS 29 tests; `TodayFreshGoalVisibilityTests` PASS 5 tests; `TodayShellIntegrationTests` PASS 1 test.
- focused Step Session proof: `testStepSessionEntryContextSurfacesBoundedStepSession` PASS.
- UI smoke: `testTodayStartNowCanOpenBoundedStepSession` FAILS before Step Session assertion because `waitForTodayScreenReady` cannot establish `today.screen` / hero readiness; classified as accepted background UI smoke issue, not Step Session assertion failure.
- copy guard: touched-path scan found only test guard strings plus existing no-silent-reschedule copy; no user-facing `Focus screenlet`, `Focus Session`, fake AI, or timer-first language introduced.
- privacy/accessibility: no persistence, account, sync, calendar mutation, or sensitive data surface added; Step Session uses existing accessible button/hint patterns and a stable `today.support.step-session` identifier.
- architecture scan: advisory only; `TodayExecutionProjector.swift` remains 928 lines; `TodayPanels.swift` remains 2423 lines; `TodayFeatureService.swift` changed from 2705 to 2707 lines, not a significant current-batch worsening.
- diff whitespace: `git diff --check` PASS.

## Gate

- F04 gate result: Green with accepted background Yellow recorded.
- stop condition: none introduced by current batch.
- next phase: commit F04, then continue to F05 Action Closure / Still Counts.
- last checkpoint: validation complete and tracking docs updating.
