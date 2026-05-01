# F03.5 Today Execution State Contract Hardening Prompt

Path: docs/codex/batches/F03_5_Today_Execution_State_Contract_Hardening_Prompt.md
Status: Copy/paste ready batch prompt


Run immediately after F03 and before F04.

Docs to read: README.md, docs/README.md, AGENTS.md, Ambitions 3.0 source stack, Batch Train Orchestrator, SwiftUI State Contract Standard, Feature Boundary Constitution, State Projection Extraction Rules, F01-F03 audit reports, BATCH_REGISTRY, CONTEXT_INDEX.

Task width: M/L Quality Train architecture hygiene. Allowed files: Today state/projection/panel/screen/test/preview files, F03.5 audit report, run-state docs, batch registry/index. Forbidden files: Plan, Capture, Goals, You/Profile, shell/routing outside Today, `.github/workflows/**`, dependency manifests, Step Session behavior, Action Closure, Proof/Receipt, global identifier migration.

Inspect exactly: `Native/Ambitions/Features/Today/TodayExecutionViewState.swift`, `TodayPanels.swift`, `TodayScreen.swift`, `Native/AmbitionsTests/Today/TodayViewModelTests.swift`.

Extraction candidates: `DayRailViewState.swift`, `DayRailProjection.swift`, `DayRailStepDetailState.swift`, `TodayStepDetailPanel.swift`, `TodayExecutionProjector.swift`, `TodayExecutionCompatibility.swift`, `TodayScreenContractSnapshot.swift`.

Rules: Do not implement F04. Do not add Step Session behavior. Do not add new user-facing Today behavior. Do not migrate global identifiers. Refactor only if it reduces responsibility creep and preserves tests. If no extraction is needed, document why and pass with no app-code change.

Tests: `scripts/build-local.sh`, focused `TodayViewModelTests`, `TodayFreshGoalVisibilityTests`, `TodayShellIntegrationTests`, `git diff --check`, `scripts/swiftui-architecture-scan.sh`.

Stop on Yellow/Red gates, forbidden scope pressure, failed build/focused tests, privacy/copy regression, or extraction becoming a broad rewrite.

Closeout: report Result, files changed, extraction decision, validation, gate result, commit, remaining risks, next prompt.
