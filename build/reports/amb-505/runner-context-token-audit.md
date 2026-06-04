# AMB-505 Runner Context Compaction and Token-Budget Audit

Date: 2026-06-04
Branch: codex/amb-505-runner-context-audit
Baseline SHA: 087c48803826fab56f6f6cdc1ca1c6c0dc599a08
Status: Green

## Scope

AMB-505 was executed as process/tooling hardening only.

No app source, app UI, app navigation, app data model, tests, project file, package manifest, privacy manifest, entitlement, screenshot, signing, release, hosted service, network tooling, dependency, or external-service path was changed.

Product truth was not changed. Validation/proof gates were not weakened. No source migration, app behavior, release readiness, accessibility readiness, privacy/legal readiness, TestFlight readiness, App Store readiness, or device proof is claimed.

## Active Truth Files Inspected

- docs/truth/README.md
- docs/truth/PRODUCT_DESIGN_TRUTH.md
- docs/truth/PRODUCT_MOAT_TRUTH.md
- docs/truth/IMPLEMENTATION_TRUTH.md
- docs/truth/RELEASE_TRUTH.md
- docs/truth/CODEX_PROCESS_TRUTH.md
- docs/truth/HISTORICAL_POLICY.md
- AGENTS.md
- README.md
- docs/README.md
- project.yml
- Package.swift

## Files Inspected

- AGENTS.md
- .agents/AGENTS.md
- docs/AGENTS.md
- scripts/AGENTS.md
- .codex/os/AMBITIONS_OPERATING_CONTEXT.md
- .codex/os/ACTIVE_AUTHORITY_MAP.md
- .codex/hooks/session_start_context.py
- .codex/reports/current-run-state.md
- .codex/reports/current-batch-train-state.md
- prompts/_BATCH_TEMPLATE.md
- scripts/ambitions-codex-train.sh
- scripts/ambitions-runner-self-check.sh
- scripts/ambitions-runner-quote-self-check.sh
- scripts/ambitions-advance-batch-state.py
- scripts/afep025_architecture_manifest_validate.py
- scripts/ambitions-batch-prep-scaffold.py
- scripts/ambitions-faang-red-team-review-check.py
- scripts/ambitions-visual-100-proof-dashboard.py
- scripts/ambitions-encyclopedia-to-frontend-os-final-gate.py
- scripts/ambitions_visual_design_lock_repair_05_common.py
- scripts/ambitions_design_system_15_common.py
- scripts/ambitions-visual-100-prompt-authority-check.py
- scripts/codex-os/*

## Files Changed

- prompts/_BATCH_TEMPLATE.md
- prompts/_RUNNER_REQUIRED_HEADER.md
- scripts/afep025_architecture_manifest_validate.py
- scripts/ambitions-advance-batch-state.py
- scripts/ambitions-batch-prep-scaffold.py
- scripts/ambitions-codex-train.sh
- scripts/ambitions-encyclopedia-to-frontend-os-final-gate.py
- scripts/ambitions-faang-red-team-review-check.py
- scripts/ambitions-runner-context-token-audit.py
- scripts/ambitions-runner-quote-self-check.sh
- scripts/ambitions-runner-self-check.sh
- scripts/ambitions-visual-100-prompt-authority-check.py
- scripts/ambitions-visual-100-proof-dashboard.py
- scripts/ambitions_design_system_15_common.py
- scripts/ambitions_visual_design_lock_repair_05_common.py
- build/reports/amb-505/runner-context-token-audit.md

## Token-Budget Findings

New audit command:

```bash
python3 scripts/ambitions-runner-context-token-audit.py
```

Current audit result:

- Status: Green.
- Inspected files: 23.
- Approx total token estimate: 39,527.
- Heuristic: approximate tokens = ceil(character_count / 4).
- Largest active process/context file: scripts/ambitions-codex-train.sh at about 13,271 tokens.
- Default scan excludes Native/, Sources/, AppUI/, Packages/, DerivedData, logs, run transcripts, and repo-intelligence caches.
- Stale language findings: none.
- Model routing findings: none.
- Repeated large-block candidate: .codex/reports/current-run-state.md and .codex/reports/current-batch-train-state.md share an approximately 443-token current-state block.

The repeated current-state mirror is not a Red condition. It is a bounded compaction follow-up because those mirrors are generated/operational state files and should be compacted through the generator/state format, not by one-off manual deletion.

## Runner/Context Fixes

- Added a no-dependency runner/context token audit script using Python standard library only.
- Added the missing reusable runner header file expected by scripts/ambitions-wrap-prompt.sh and scripts/ambitions-runner-self-check.sh.
- Updated runner self-check assertions from stale Capture-tab IA to active Today / Goals / Time / Motion / You plus global Capture context.
- Updated state-advancement generated state text so future mirrors do not inject Today / Goals / Capture / Time / You as active IA.
- Updated process-script model wording so active generated reports no longer name GPT-5.4-mini as the default bounded patch model.
- Updated scripts/ambitions-codex-train.sh default bounded patch model to gpt-5.3-codex-spark to align with AGENTS.md. GPT-5.4-mini remains fallback/historical only where active authority permits it.
- Updated docs/process runner handling so docs-install/audit/proof-only batches do not attempt implementation parallel guard pre/post checks when source guard inputs are absent; source-changing and guard-repair batches still run those guards.
- Updated scripts/ambitions-runner-quote-self-check.sh so its mocked validation path is explicitly historical, docs-install, no-commit, no-push, and self-contained.
- Removed active old-IA/model drift from process report generators that were emitting or enforcing stale active runner text.

## AGENTS Split Strategy

Root and nested AGENTS files were inspected:

- AGENTS.md
- .agents/AGENTS.md
- docs/AGENTS.md
- scripts/AGENTS.md
- Native/Ambitions/App/AGENTS.md
- Native/Ambitions/Domain/AGENTS.md
- Native/Ambitions/Features/AGENTS.md

No AGENTS split was implemented. Root AGENTS.md is the current canonical front-door operating contract and a split would be broad enough to risk changing repo authority semantics. The safe follow-up is to add a dedicated AGENTS split issue with explicit acceptance gates before moving any root guidance.

Proposed follow-up title:

```text
AMB follow-up: Design root/nested AGENTS split without changing truth-file authority
```

Acceptance gates:

- Root AGENTS.md remains canonical operating authority.
- docs/truth/* remains higher authority.
- Nested AGENTS.md files contain only location-specific execution details.
- No product truth, release proof, validation proof, or source behavior claims change.
- Validation includes the token audit, runner self-check, and an AGENTS-path diff review.

## Validation Commands Run

- git status --short --branch: clean baseline on main before changes; later branch-local process diff only.
- git switch -c codex/amb-505-runner-context-audit: succeeded.
- find . -maxdepth 4 -iname "AGENTS.md" -print: found root, .agents, docs, scripts, and Native scoped AGENTS files.
- rg -n "Today / Goals / Capture / Time / You|Pulse is active|Pulse.*approved|Capture.*tab|persistent floating Capture|5\.4-mini|mini" .codex AGENTS.md docs scripts 2>/dev/null || true: remaining hits are truth-file guardrails, stale-source/historical classifications, detector strings, generated logs/summaries, and out-of-scope older architecture docs; active runner/context scan is Green.
- rg -n "Today / Goals / Time / Motion / You|global Atmosphere Composer|Motion is approved|Pulse is prior|local-first" .codex AGENTS.md docs scripts 2>/dev/null || true: active context present in AGENTS.md, truth files, .codex/os, .codex/hooks, .codex/reports, and runner scripts.
- python3 scripts/ambitions-runner-context-token-audit.py: Green.
- python3 scripts/ambitions-runner-context-token-audit.py --help: passed.
- python3 -m py_compile scripts/ambitions-runner-context-token-audit.py scripts/ambitions-advance-batch-state.py scripts/afep025_architecture_manifest_validate.py scripts/ambitions_visual_design_lock_repair_05_common.py scripts/ambitions_design_system_15_common.py scripts/ambitions-faang-red-team-review-check.py scripts/ambitions-visual-100-proof-dashboard.py scripts/ambitions-encyclopedia-to-frontend-os-final-gate.py scripts/ambitions-visual-100-prompt-authority-check.py scripts/ambitions-batch-prep-scaffold.py: passed.
- bash -n scripts/ambitions-codex-train.sh scripts/ambitions-runner-self-check.sh scripts/ambitions-runner-quote-self-check.sh: passed.
- bash scripts/ambitions-runner-self-check.sh: Green.
- bash scripts/ambitions-runner-quote-self-check.sh: Green with mocked Codex phases; no commit; no push.
- git diff --check: passed.

## Remaining Yellow Follow-Ups

1. Compact duplicated .codex current-state mirror prose through scripts/ambitions-advance-batch-state.py or the current-state format owner, preserving proof honesty and no-readiness claims.
2. Create a dedicated AGENTS split issue before moving root guidance into nested AGENTS files.
3. Separately classify older architecture docs and historical visual scripts that still mention Today / Goals / Capture / Time / You, without widening AMB-505 into a product/source migration.

## Acceptance Gate Status

- No app source touched: Pass.
- No tests/project/package/privacy/entitlement files touched: Pass.
- No product truth changed: Pass.
- Truth-file authority preserved: Pass.
- Validation/proof gates preserved or strengthened: Pass.
- Token-budget audit exists: Pass.
- Runner/context replay safely bounded or follow-up recorded: Pass.
- Active runner/context does not inject old IA as active truth: Pass.
- Pulse appears only as prior/historical/stale context in active runner/context: Pass.
- Capture is not represented as an active top-level tab in active runner/context: Pass.
- Motion remains active fifth tab in active runner/context: Pass.
- Local-first deterministic runtime posture preserved: Pass.
- Proof artifact exists: Pass.
- AMB-501 left open: Pass.
- M03 not started: Pass.

## Rollback

Path-limited rollback, if needed:

```bash
git restore -- prompts/_BATCH_TEMPLATE.md scripts/afep025_architecture_manifest_validate.py scripts/ambitions-advance-batch-state.py scripts/ambitions-batch-prep-scaffold.py scripts/ambitions-codex-train.sh scripts/ambitions-encyclopedia-to-frontend-os-final-gate.py scripts/ambitions-faang-red-team-review-check.py scripts/ambitions-runner-quote-self-check.sh scripts/ambitions-runner-self-check.sh scripts/ambitions-visual-100-prompt-authority-check.py scripts/ambitions-visual-100-proof-dashboard.py scripts/ambitions_design_system_15_common.py scripts/ambitions_visual_design_lock_repair_05_common.py
rm -f prompts/_RUNNER_REQUIRED_HEADER.md scripts/ambitions-runner-context-token-audit.py build/reports/amb-505/runner-context-token-audit.md
```
