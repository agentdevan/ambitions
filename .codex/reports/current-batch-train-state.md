# Current Batch Train State

Path: `.codex/reports/current-batch-train-state.md`
Status: F22 Green; F22.5 triggered; F23 blocked until F22.5 and mandatory F22.7 Green

- train name: F17-F30 FAANG Handoff Completion Train
- train type: Release / Architecture / Product Quality Train
- active batch: F22.5 Doc QA Backlog Closure
- current entry point: F22.5 after F22 commit/push
- completed batches: F01-F16.5 by registry/report evidence; F17 repair, F18, F19, F20, F21/F21.5, and F22 by current train evidence
- gate status: F17 repair Green, F18 Green, F19 Green, F20 Green, F21 reclassified Green by F21.5, F21.5 Green, F22 Green with F22.5 triggered; FAANG handoff PARTIAL
- auto-continuation rule: Green only
- mandatory added gates: F22.7 Human-Made Active Repo Hygiene / 3.0-As-Baseline Gate; F27.5 Human-Made Codebase Maintainability Audit
- F22 status: Green; report `docs/audits/ambitions-3-0-f22-product-language-baseline-reset-report.md`
- F22.5 status: triggered by markdownlint backlog and broken links
- F22.7 status: mandatory next gate after F22.5 Green
- F23 status: blocked until F22, F22.5 if triggered, and F22.7 are Green
- F27 status: final FAANG handoff gate rerun; FAANG handoff remains PARTIAL until F27 passes
- F27.5 status: mandatory maintainability audit after F27 PASS or after F28 repairs make F27 PASS
- F28 status: conditional repair only if F27 or F27.5 PARTIAL/FAIL
- F29/F30 status: blocked until F27 and F27.5 are Green
- accepted background Yellow: doc QA advisory backlog before F22, pre-existing historical docs clearly marked archive/supporting, pre-existing architecture warnings, documented compatibility seams, physical-device proof unavailable with no physical-device claim
- current primitive: Release / Market Proof System plus active canon/product-language hygiene
- current surface: active docs, active copy, compatibility seams, train state
- context pack: Ambitions 3.0 source stack plus baseline/human-made/archive policies and release/readiness/handoff/privacy/accessibility docs
- skill: repo-truth-enforcer; ios-qa-regression-checker; release-hardening
- operation: F22 baseline reset complete; commit/push required before F22.5
- validation pack: dev tools, batch preflight, batch gate check, build, focused touched-scope tests, docs QA, diff check
- files touched: active policy/index/tracking docs, F22 report, focused visible copy/state-contract files, `.codex/reports`
- commands run: `git status --short`, `git branch --show-current`, `git rev-parse HEAD`, `git log -1 --oneline`, `scripts/validate-dev-tools.sh || true`, `scripts/batch-train-preflight.sh || true`, `scripts/batch-train-gate-check.sh || true`, `scripts/build-local.sh`, mandated copy/baseline scans, focused xcodebuild tests, `scripts/run-doc-qa.sh || true`, `git diff --check`
- tests run: build PASS; focused touched-scope tests PASS (`32` tests); docs QA advisory PARTIAL
- doc QA result: markdownlint `10087` errors, lychee `5` broken links in `3` docs, stale/deprecated language mostly historical/guard/internal hits
- stop condition: none for F22 after commit/push; F22.5 must run before F22.7
- next batch: F22.5 Doc QA Backlog Closure
- resume instructions: read this file, `docs/audits/ambitions-3-0-f22-product-language-baseline-reset-report.md`, the train manifest, baseline/human-made/archive policies, and current git status before continuing
