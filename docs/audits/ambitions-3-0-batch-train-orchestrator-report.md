# Ambitions 3.0 Batch Train Orchestrator Report

Path: docs/audits/ambitions-3-0-batch-train-orchestrator-report.md
Date: 2026-04-30
Status: setup validation pending

## Executive Verdict
The Batch Train Orchestrator has been created as docs/tooling/run-state infrastructure. It does not implement app behavior. It establishes Green/Yellow/Red gates, batch manifests, operations, validation packs, templates, playbooks, checklists, runner prompts, architecture standards, and advisory scripts.

## Current Truth
F01, F02, and F03 are complete by registry and audit evidence. F03.5 is next and should run before F04 because `TodayExecutionViewState.swift` exceeds the 1000-line extraction-required threshold. FAANG handoff remains PARTIAL. Full UI smoke still has known failures. F17 Shell/Meridian must not auto-run.

## Added
- Orchestrator canon: `docs/codex/AMBITIONS_3_0_BATCH_TRAIN_ORCHESTRATOR.md`
- Architecture canon: SwiftUI state contract, feature boundary/file size, state projection extraction rules
- Train manifests under `docs/codex/batch-trains/`
- Runner prompts under `docs/codex/`
- Batch prompts for F03.5, F13.5, and F16.5
- Operations, validation packs, templates, playbooks, and checklists under `.codex/`
- Advisory scripts under `scripts/`

## Safe Trains
F03.5 can run as a single-batch Quality/Architecture Hygiene train after setup is committed and pushed Green. F04-F06 can run only after F03.5 is Green or explicitly not triggered, which is unlikely given current line counts.

## Unsafe Trains
F17 implementation is unsafe without explicit approval. Release trains are unsafe without evidence gates. Broad migration/test/shell combinations are forbidden.

## Remaining Risks
Doc QA may remain advisory because of pre-existing markdown/link backlog. Full UI smoke is known PARTIAL. The train system is new and should be used conservatively.

## Next Exact Prompt
Run `docs/codex/BATCH_F03_5_TODAY_ARCHITECTURE_HARDENING_PROMPT.md` only after orchestrator setup validates, commits, and pushes Green.


## Validation Evidence

- `scripts/validate-dev-tools.sh || true`: PASS.
- `scripts/run-doc-qa.sh || true`: PARTIAL/advisory. Stale-guidance hits are historical/supporting. Markdown and lychee backlog remains broad and pre-existing, with new generated-doc formatting also advisory. No active read-order hit tells Codex to start with 2.0/v2 before 3.0.
- stale active-guidance scan: allowed historical/supporting references only.
- orphan check: initially found older unlinked F00 report; fixed by adding it to `docs/codex/CONTEXT_INDEX.md`.
- `scripts/batch-train-preflight.sh || true`: PASS for required docs/scripts; reported expected setup diff.
- `scripts/batch-train-gate-check.sh || true`: PASS with Yellow hint because setup changes were present.
- `scripts/swiftui-architecture-scan.sh || true`: PASS/advisory; confirms `TodayExecutionViewState.swift` is 1,980 lines and F03.5 is required.
- `scripts/build-local.sh || true`: PASS on iPhone 17 simulator destination.
- `git diff --check`: PASS after whitespace cleanup.

## Gate Classification

Result: PARTIAL / Yellow for automatic continuation.

Reason: the orchestrator setup is coherent and build-valid, but the train must not auto-start because doc QA remains advisory and architecture scan emits file-responsibility warnings, including the required F03.5 trigger. Under the orchestrator rules, Yellow stops and creates a repair/decision prompt rather than continuing automatically.

## Repair / Resume Prompt

Use `docs/codex/BATCH_F03_5_TODAY_ARCHITECTURE_HARDENING_PROMPT.md` after human confirmation that the Yellow advisory state is acceptable for starting F03.5. Do not start F04. Do not skip F03.5. Preserve behavior and run the F03.5 validation pack.
