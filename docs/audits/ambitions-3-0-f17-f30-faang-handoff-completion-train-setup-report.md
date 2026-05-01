# Ambitions 3.0 F17-F30 FAANG Handoff Completion Train Setup Report

Date: 2026-05-01
Status: Green after local setup validation; commit and push pending

## Train Purpose

The F17-F30 FAANG Handoff Completion Train carries Ambitions 3.0 from Shell/Meridian planning through final FAANG handoff gate rerun, repair if needed, handoff packaging, and Beyond 3.0 continuation planning.

## Starting Truth

- F01-F16.5 are complete by current registry and report evidence.
- Build passes on `iPhone 17`.
- Focused tests across Plan, Goals, You/Profile, routing/App Intent, Today, and the F16 UI contract lane are Green by prior reports.
- Full tests remain PARTIAL/advisory because `scripts/test-local.sh` reached the known full UI smoke class with 29 UI tests run and 7 failures in the latest F12-F16.5 report.
- Doc QA remains advisory/PARTIAL from known markdown, deprecated-language, and link backlog.
- Architecture scan remains advisory/PARTIAL with pre-existing large-file warnings.
- FAANG handoff remains PARTIAL.
- F17 implementation is not approved by setup alone; F18 remains blocked until F17 planning is Green.

## Batch List

F17, F18, F18.5, F19, F20, F21, F21.5, F22, F22.5, F23, F24, F24.5, F25, F26, F27, F28, F29, and F30.

## Gates

The train is Green-only auto-continuation. Yellow stops unless the current batch is the remediation batch for that Yellow condition. Red stops immediately.

F17 must prove shell ownership, route parity, fallback navigation, feature flag, rollback, accessibility fallback, external implications, F18/F19 tests, and no unresolved shell ambiguity before F18 may run.

F27 is the only batch that may move FAANG handoff from PARTIAL to PASS, and only if the handoff gate rerun passes.

## Stop Conditions

New touched-scope doc QA failures, UI smoke failures, architecture warnings, copy/privacy/accessibility ambiguity, routing ambiguity, App Store claim ambiguity, unsupported readiness claims, device-proof ambiguity, build failure, focused-test failure, workflow touch, runtime dependency addition, privacy leakage, hidden personalization, broken destination access, fallback removal, weakened tests, commit failure, push failure, or untrustworthy validation stop the train.

## Implementation Approval Rules

F17 is planning-only. F18 is authorized only if F17 returns Green. F29 is blocked until F27 PASS. F30 is blocked until F29 Green.

## F17 Starting Conditions

Current entry point: F17 Shell / Meridian Planning & Readiness Audit.

Next exact batch prompt:

`docs/codex/batches/F17_Shell_Meridian_Planning_And_Readiness_Audit_Prompt.md`

## Risks

- Shell/Meridian changes are critical routing/accessibility work.
- Full UI smoke failures remain known until F21.
- Doc QA backlog remains known until F22/F22.5.
- Pre-existing architecture warnings must not be worsened.
- Physical device, App Store, TestFlight, and public accessibility claims remain unavailable without matching evidence.

## Setup Artifacts

- `docs/codex/batch-trains/F17_F30_FAANG_HANDOFF_COMPLETION_TRAIN.md`
- `docs/codex/BATCH_TRAIN_F17_F30_FAANG_HANDOFF_PROMPT.md`
- F17-F30 batch prompts under `docs/codex/batches/`
- updated Codex/canon indexes and run-state files

## Validation

- `git status --short`: expected setup diff only.
- `scripts/validate-dev-tools.sh || true`: PASS.
- `scripts/batch-train-preflight.sh || true`: PASS with expected setup diff.
- `scripts/batch-train-gate-check.sh || true`: YELLOW while setup files are
  unstaged; this is expected before the setup commit.
- `scripts/run-doc-qa.sh || true`: PARTIAL/advisory from known stale-guidance,
  deprecated-language, markdownlint, and lychee backlog. The setup does not
  claim doc QA Green.
- `scripts/swiftui-architecture-scan.sh || true`: PARTIAL/advisory from known
  large-file and extraction warnings. No app code changed in setup.
- `scripts/build-local.sh`: PASS on `iPhone 17`.
- `git diff --check`: PASS.

No `.github/workflows/` files were touched. No runtime dependency file was
touched. No app implementation file was touched.

## Gate Classification

Green for Part 1 setup, subject to successful commit and push.

Part 2 may start only after the setup commit is pushed. The next exact batch is
F17 Shell / Meridian Planning & Readiness Audit.
