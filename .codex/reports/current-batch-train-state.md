# Current Batch Train State

Path: `.codex/reports/current-batch-train-state.md`
Status: F20 Green pending commit; F21 next if pushed

- train name: F17-F30 FAANG Handoff Completion Train
- train type: Release / Architecture / Product Quality Train
- active batch: F20 External Surfaces Privacy-Safe Projection
- current entry point: F20, then F21
- completed batches: F01, F02, F03, F03.5, F04, F05, F06, F07, F08, F09, F10, F11, F12, F13, F13.5, F14, F15, F16, F16.5 by current registry/report evidence
- gate status: F17 repair Green, F18 Green, F19 Green, F20 Green pending commit; FAANG handoff PARTIAL
- auto-continuation rule: Green only
- F18 status: Green committed and pushed; F18.5 not triggered
- F19 status: Green committed and pushed
- F20 status: Green pending commit/push
- F27 status: final FAANG handoff gate rerun
- F28 status: conditional repair only if F27 PARTIAL/FAIL
- F29/F30 status: final packaging/continuation only, not feature implementation
- accepted background Yellow: doc QA advisory backlog unchanged; known full UI smoke failures before F21; pre-existing architecture extraction warnings unchanged; documented compatibility seams unchanged; legacy historical docs marked non-active
- current primitive: Ambitions Operating Shell for F17 planning
- current surface: external-surface privacy-safe projection and canonical route handoff
- context pack: Ambitions 3.0 source stack plus release/readiness/handoff/privacy/accessibility/shell docs
- skill: repo-truth-enforcer; phase-executor
- operation: F20 gate, then gated train resume if Green
- validation pack: dev tools, batch preflight, batch gate check, doc QA advisory, architecture scan advisory, build, diff check
- files touched: `Native/AmbitionsTests/App/ExternalSurfaceSnapshotTests.swift`, `docs/audits/ambitions-3-0-f20-external-surfaces-privacy-projection-report.md`, docs/codex tracking files, .codex/reports
- commands run before setup edits: `git status --short`, `git branch --show-current`, `git rev-parse HEAD`, `git log -1 --oneline`, `scripts/validate-dev-tools.sh || true`, `scripts/batch-train-preflight.sh || true`, `scripts/batch-train-gate-check.sh || true`, `scripts/swiftui-architecture-scan.sh || true`, `scripts/build-local.sh`
- tests run: local build PASS on iPhone 17 during setup; F17 validation pending after report
- architecture warnings: advisory/PARTIAL, pre-existing large-file warnings unchanged before setup edits
- checkpoint history: Part 1 setup committed and pushed; F17 planning inspected shell/routing/external surfaces
- stop condition: none in F20 pending commit; accepted background Yellow remains unchanged
- next batch: F21 Full UI Smoke Stabilization after F20 commit/push
- resume instructions: re-read this file, `docs/codex/batch-trains/F17_F30_FAANG_HANDOFF_COMPLETION_TRAIN.md`, `docs/codex/BATCH_TRAIN_F17_F30_FAANG_HANDOFF_PROMPT.md`, `docs/codex/batches/F17_Shell_Meridian_Planning_And_Readiness_Audit_Prompt.md`, current git status, and setup report before continuing
