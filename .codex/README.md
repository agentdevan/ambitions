# Ambitions 3.0 Repo-Local Codex System

This directory is the reusable operating layer for Codex work in Ambitions.

Use it after reading the Ambitions 3.0 source hierarchy. It is not product canon; it is the execution system that keeps Codex fast, scoped, and honest.

## Folders

- `skills/` — task-specific execution skills.
- `operations/` — repeatable protocols for work types.
- `templates/` — copy/paste-ready prompts and reports.
- `validation/` — focused and full validation packs.
- `playbooks/` — failure recovery guidance.
- `context-packs/` — minimal source docs/files by workstream.
- `routes/` — route-first context files that shrink read scope by task.
- `state/` — compact efficiency mirrors for known facts, active batch, Yellow, and hard Red ledgers.
- `manifests/` — machine-readable Codex OS maps and ownership manifests.
- `checklists/` — preflight, implementation, commit, privacy, accessibility, release, and handoff checks.
- `reports/` — optional local generated reports; commit only intentional handoff evidence.
- `logs/` — local generated ACX/raw command logs; ignored by git.

## FAANG Team Operating Layer

The Ambitions 3.0 FAANG-team upgrade adds task width gates, role review, run-state recovery, UI test contracts, toolchain readiness, Definition of Ready/Done, ADR/architecture review, QA specialty protocols, test ownership, flake triage, dependency promotion, release-claim truth, traceability, risk/postmortem loops, prompt quality, human escalation, and parallel worktree rules.

Start with:

- `docs/codex/CODEX_OS_INDEX.md`
- `docs/codex/CODEX_USAGE_EFFICIENCY.md`
- `docs/codex/CODEX_AGENT_PROTOCOL.md`
- `docs/codex/CODEX_EVIDENCE_STANDARD.md`
- `docs/codex/CODEX_BATCH_TRAIN_PROTOCOL.md`
- `docs/codex/CODEX_ROUTE_CONTEXT_PROTOCOL.md`
- `docs/canon/Ambitions_3_0_FAANG_Team_Operating_Model.md`
- `docs/canon/Ambitions_3_0_Task_Width_And_Batch_Combining_Gate.md`
- `docs/canon/Ambitions_3_0_UI_Test_Contract.md`
- `docs/canon/Ambitions_3_0_Local_Toolchain_Readiness_Matrix.md`
- `docs/codex/AMBITIONS_3_0_RUN_STATE_PROTOCOL.md`
- `docs/codex/AMBITIONS_3_0_LARGE_BATCH_AND_COMPACT_RECOVERY_PROTOCOL.md`
- `docs/codex/AMBITIONS_3_0_PROMPT_QUALITY_RUBRIC.md`
- `docs/codex/AMBITIONS_3_0_PARALLEL_CODEX_WORKTREE_PROTOCOL.md`

## How To Use

1. Read `AGENTS.md`.
2. Read `docs/codex/CODEX_OS_INDEX.md`.
3. Use `python3 scripts/ai/acx.py read ...` for bounded file reads when helpful.
4. Choose one route from `.codex/routes/README.md`.
5. Choose one primary skill.
6. Choose one operation protocol.
7. Choose one validation pack.
8. Close out with evidence, raw logs where required, and next prompt.

## ACX Usage

ACX is repo-local efficiency tooling, not product runtime. It does not execute build, test, git, Xcode, or shell commands. Use it to summarize saved logs and scan docs:

```bash
python3 scripts/ai/acx.py read AGENTS.md --lines 140
python3 scripts/ai/acx.py summarize-log output/logs/latest-build.log
python3 scripts/ai/acx.py changed-files-from output/logs/git-status-short.txt
python3 scripts/ai/acx.py gate all
python3 scripts/ai/acx.py gate-report
```

The shell wrapper is available at `scripts/ai/acx`. If it is not executable after checkout, run `chmod +x scripts/ai/acx`.

## Batch Train Orchestrator

Use `docs/codex/AMBITIONS_3_0_BATCH_TRAIN_ORCHESTRATOR.md`, `docs/codex/CODEX_BATCH_TRAIN_PROTOCOL.md`, plus the artifacts in this directory for gated Ambitions 3.0 batch trains. F03.5, F13.5, and F16.5 are architecture checkpoint prompts; do not skip them when their triggers fire.
