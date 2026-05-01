# Current Run State

- current task: F03.5 Today Execution State Contract Hardening
- task size: M/L
- active mode: Quality Train / Architecture Hygiene
- active primitive: Reality Rail / Step Execution contract foundation
- active surface: Today
- active context pack: Ambitions 3.0 source stack plus Today Reality Rail context
- active skill: phase-executor plus repo-truth-enforcer
- active operations: swiftui-state-contract-hardening-protocol; feature-file-responsibility-review-protocol
- active validation packs: swiftui-state-contract-pack; feature-file-responsibility-pack; architecture-hygiene-pack; base-build-test-pack; copy-guard-pack; accessibility-pack; privacy-trust-pack
- docs read: README.md; docs/README.md; AGENTS.md; Ambitions 3.0 source stack; Batch Train Orchestrator; F03.5 runner/prompt/manifest; SwiftUI state and feature file architecture docs; BATCH_REGISTRY; CONTEXT_INDEX; F02/F03/orchestrator reports
- files allowed: Native/Ambitions/Features/Today; Native/Ambitions/PreviewSupport/PreviewTodayScenarios.swift; Native/AmbitionsTests/Today; docs/codex; docs/canon status evidence if needed; docs/audits; .codex/reports/current-run-state.md; .codex/reports/current-batch-train-state.md
- files forbidden: F04/F05/F06 behavior; Step Session behavior; Action Closure behavior; Proof/Receipt Ledger behavior; global identifier migration; unrelated surfaces; .github/workflows/**; runtime dependency manifests; release-readiness claims
- accepted Yellow reason: doc QA remains advisory/PARTIAL from known markdown/link/deprecated-language backlog; architecture scan confirmed TodayExecutionViewState.swift at 1,980 lines
- remediation batch: F03.5
- F04 status: blocked until F03.5 is Green
- preflight git: clean on main at e1cd209357a1319fd4249e3f325990408858515e / e1cd2093 Index Ambitions batch train orchestrator
- preflight validation: scripts/batch-train-preflight.sh PASS; scripts/swiftui-architecture-scan.sh advisory with TodayExecutionViewState.swift 1,980 lines; scripts/build-local.sh PASS on iPhone 17

## Extraction Plan

- current responsibilities in TodayExecutionViewState.swift: Today execution root value state; Day Rail state families; Step Detail state helpers; deterministic TodayExecutionProjector; Day Rail projection helpers; privacy redaction helpers; compatibility construction from legacy Today state; screen contract snapshot; command mapping helpers; shared Today string helpers.
- proposed extracted files: DayRailViewState.swift for rail enums/value-state; DayRailStepDetailState.swift for Step Detail state and visible-copy helpers; DayRailProjection.swift for Day Rail compatibility/projection/privacy/duration/target/row helpers; TodayExecutionProjector.swift for TodayExecutionProjectionInput, TodayExecutionProjector, and projector-private helpers; TodayExecutionCompatibility.swift for TodayExecutionViewState.compatibility, replacingDayRail, command mapping, and compatibility comments; TodayScreenContractSnapshot.swift for screenContractSnapshot and contract copy samples.
- behavior preservation strategy: move declarations and extensions without changing values, strings, access modifiers, identifiers, projections, or actions; keep Today-owned types under Native/Ambitions/Features/Today; preserve Start here / Start now copy, private rail redaction, Step Detail redaction, and existing accessibility identifiers.
- tests to run: scripts/build-local.sh; focused TodayViewModelTests; TodayFreshGoalVisibilityTests; TodayShellIntegrationTests; scripts/swiftui-architecture-scan.sh || true; scripts/run-doc-qa.sh || true; git diff --check.
- stop conditions: build failure; focused Today test failure that cannot be repaired inside F03.5; forbidden file/dependency/workflow touch; privacy/copy/accessibility regression; extraction expanding into F04 Step Session, F05 Action Closure, F06 Proof/Receipt, shell/routing, or global identifier migration.

- files changed: Today execution state extraction files; BATCH_REGISTRY; CONTEXT_INDEX; Current Implementation Gap Audit; F03.5 audit report; current run/train state
- tests run: scripts/build-local.sh PASS; TodayViewModelTests PASS 29 tests; TodayFreshGoalVisibilityTests PASS 5 tests; TodayShellIntegrationTests PASS 1 test; scripts/swiftui-architecture-scan.sh advisory with TODAY_EXECUTION_VIEW_STATE_LINES 181; scripts/run-doc-qa.sh advisory; git diff --check PASS; touched-path copy guard reviewed
- failures: initial parallel focused-test attempt produced Xcode build database lock failures; rerun sequentially passed; doc QA remains pre-existing PARTIAL/advisory
- open risks: TodayExecutionProjector.swift is 928 lines; TodayPanels.swift and TodayFeatureService.swift remain large pre-existing files; full UI smoke remains known out of scope; manual accessibility/device/release proof not claimed
- gate result: F03.5 Green
- F04 readiness verdict: Green with guardrails; F04 may proceed only as Step Session rename/migration and routing
- next phase: commit and push F03.5
- last checkpoint: validation complete and tracking docs updated
