# Current Batch Train State

Path: `.codex/reports/current-batch-train-state.md`
Status: F27 PARTIAL; F28 triggered; F27.5/F29/F30 blocked

- train name: F17-F30 FAANG Handoff Completion Train
- train type: Release / Architecture / Product Quality Train
- active batch: F28 FAANG Handoff Repair Train
- current entry point: F28 repair/classification after F27 PARTIAL
- completed batches: F01-F16.5 by registry/report evidence; F17 repair, F18, F19, F20, F21/F21.5, F22, F22.5, F22.7, F23, F24, F25, and F26 by current train evidence
- gate status: F17 repair Green, F18 Green, F19 Green, F20 Green, F21 reclassified Green by F21.5, F21.5 Green, F22 Green, F22.5 Green, F22.7 Green, F23 Green, F24 Green; F24.5 not triggered; F25 Green; F26 Green; F27 PARTIAL; FAANG handoff PARTIAL
- auto-continuation rule: Green only
- mandatory added gates: F22.7 Human-Made Active Repo Hygiene / 3.0-As-Baseline Gate; F27.5 Human-Made Codebase Maintainability Audit
- F22 status: Green; report `docs/audits/ambitions-3-0-f22-product-language-baseline-reset-report.md`
- F22.5 status: Green; report `docs/audits/ambitions-3-0-f22-5-doc-qa-backlog-closure-report.md`
- F22.7 status: Green; report `docs/audits/ambitions-3-0-f22-7-human-made-active-repo-hygiene-report.md`
- F23 status: Green; report `docs/audits/ambitions-3-0-f23-accessibility-adhd-qa-report.md`
- F24 status: Green; report `docs/audits/ambitions-3-0-f24-privacy-trust-qa-report.md`
- F24.5 status: not triggered
- F25 status: Green; report `docs/audits/ambitions-3-0-f25-device-performance-edge-case-qa-report.md`; focused edge/device/performance suite passed 94 selected tests; local simulator build passed; physical-device proof not claimed
- F26 status: Green; report `docs/audits/ambitions-3-0-f26-app-store-demo-truth-report.md`; marketing docs `docs/marketing/Ambitions_3_0_App_Store_Truth_Packet.md` and `docs/marketing/Ambitions_3_0_Demo_Script.md`; focused release-truth suite passed 9 selected tests
- F27 status: PARTIAL; report `docs/audits/ambitions-3-0-final-faang-handoff-readiness-report.md`; full `scripts/test-local.sh` exited 65 with 1 UI smoke failure, isolated rerun passed
- F27.5 status: mandatory maintainability audit after F27 PASS or after F28 repairs make F27 PASS
- F28 status: triggered by F27 PARTIAL
- F29/F30 status: blocked until F27 and F27.5 are Green
- accepted background Yellow: doc QA advisory backlog before F22, pre-existing historical docs clearly marked archive/supporting, pre-existing architecture warnings, documented compatibility seams, physical-device proof unavailable with no physical-device claim
- current primitive: Release / Market Proof System plus active canon/product-language hygiene
- current surface: UI reliability repair/classification, handoff evidence indexing, inventory/traceability cleanup needed for F27 rerun
- context pack: Ambitions 3.0 source stack plus baseline/human-made/archive policies and release/readiness/handoff/privacy/accessibility docs
- skill: repo-truth-enforcer; ios-qa-regression-checker; release-hardening
- operation: F28 repair/classification after F27 PARTIAL
- validation pack: targeted UI/full-suite reliability evidence, handoff evidence indexing, build/doc/architecture gate as needed
- files touched: F27 final handoff report, refreshed handoff scan artifacts, `.codex/reports`
- commands run: `scripts/build-local.sh`; `scripts/test-local.sh`; focused UI rerun; `scripts/run-doc-qa.sh || true`; `scripts/swiftui-architecture-scan.sh || true`; `scripts/batch-train-gate-check.sh || true`; F27 scans
- tests run: `scripts/test-local.sh` passed 779 unit tests and 28/29 UI tests but exited 65; focused rerun of failing UI test passed
- doc QA result: markdownlint `10187` advisory errors, lychee `0` errors, stale/deprecated language mostly historical/guard/internal hits
- stop condition: F27.5/F29/F30 blocked until F28 repairs/classifies and F27 reruns PASS
- next batch: F28 FAANG Handoff Repair Train
- resume instructions: read this file, `docs/audits/ambitions-3-0-f22-product-language-baseline-reset-report.md`, `docs/audits/ambitions-3-0-f22-5-doc-qa-backlog-closure-report.md`, the train manifest, baseline/human-made/archive policies, F22.7 report if present, and current git status before continuing
