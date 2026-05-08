# Ambitions 3.0 Repo-Local Codex System

This directory is the reusable operating layer for Codex work in Ambitions.

Use it after reading the Ambitions source hierarchy. It is not product canon; it is the execution system that keeps Codex fast, scoped, repairable, and honest.

## Folders

- `skills/` — task-specific execution skills.
- `operations/` — repeatable protocols for work types.
- `templates/` — copy/paste-ready prompts and reports.
- `validation/` — focused and full validation packs.
- `playbooks/` — failure recovery guidance.
- `context-packs/` — minimal source docs/files by workstream.
- `checklists/` — preflight, implementation, commit, privacy, accessibility, release, and handoff checks.
- `reports/` — optional local generated reports; commit only intentional handoff evidence.
- `routes/` — route-first context maps for focused read lists and forbidden edits.
- `state/` — compact mirrors for current facts, active batch, recent validation, repair state, proof cache, and ledgers; owner docs and raw logs win.
- `manifests/` — machine-readable Codex OS maps for efficiency, bundles, impact, repair, ACX profiles, gates, proof, skills, ownership, source truth, and no-double-work.

## FAANG Team Operating Layer

The Ambitions Codex OS upgrade adds task width gates, role review, run-state recovery, UI test contracts, toolchain readiness, Definition of Ready/Done, ADR/architecture review, QA specialty protocols, test ownership, flake triage, dependency promotion, release-claim truth, traceability, risk/postmortem loops, prompt quality, human escalation, parallel worktree rules, speed bundles, changed-file impact routing, repair diagnosis, proof cache, sanitized evidence, build triage, visual QA packets, and accessibility packets.

Start with:

- `docs/codex/CODEX_OS_INDEX.md`
- `docs/codex/CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08.md`
- `.codex/routes/README.md`
- `docs/codex/CODEX_ROUTE_CONTEXT_PROTOCOL.md`
- `docs/codex/CODEX_ACX_LOCAL_EXECUTOR.md`
- `docs/codex/CODEX_SPEED_ENGINE.md`
- `docs/codex/CODEX_REPAIR_ENGINE.md`
- `docs/codex/CODEX_PROOF_CACHE_PROTOCOL.md`
- `docs/codex/CODEX_BUILD_SHERIFF_PROTOCOL.md`
- `docs/codex/CODEX_VISUAL_QA_PROTOCOL.md`
- `docs/codex/CODEX_ACCESSIBILITY_PROOF_PROTOCOL.md`
- `docs/codex/CODEX_PRIVACY_SECURITY_SCAN_PROTOCOL.md`
- `docs/codex/CODEX_EVIDENCE_STANDARD.md`
- `docs/codex/CODEX_GATE_ENGINE.md`
- `docs/codex/CODEX_BATCH_TRAIN_PROTOCOL.md`
- `docs/codex/CODEX_SKILLS_KIT.md`
- `docs/codex/CODEX_REPO_HYGIENE_PROTOCOL.md`
- `docs/canon/Ambitions_3_0_FAANG_Team_Operating_Model.md`
- `docs/canon/Ambitions_3_0_Task_Width_And_Batch_Combining_Gate.md`
- `docs/canon/Ambitions_3_0_UI_Test_Contract.md`
- `docs/canon/Ambitions_3_0_Local_Toolchain_Readiness_Matrix.md`
- `docs/codex/AMBITIONS_3_0_RUN_STATE_PROTOCOL.md`
- `docs/codex/AMBITIONS_3_0_LARGE_BATCH_AND_COMPACT_RECOVERY_PROTOCOL.md`
- `docs/codex/AMBITIONS_3_0_PROMPT_QUALITY_RUBRIC.md`
- `docs/codex/AMBITIONS_3_0_PARALLEL_CODEX_WORKTREE_PROTOCOL.md`

## How To Use

1. Read `AGENTS.md` and `docs/codex/CODEX_OS_INDEX.md`.
2. Choose one route from `.codex/routes/README.md` before broad search.
3. Run `python3 scripts/ai/acx_local.py bundle quick` when local tooling is available.
4. Use `python3 scripts/ai/acx_impact.py <changed files>` to map changed paths to route/bundle/gate needs.
5. Choose one context pack, primary skill, operation protocol, and validation pack.
6. Use `scripts/ai/acx.py` for non-executing extraction and `scripts/ai/acx_local.py` only for allowlisted local profiles/bundles.
7. Use `scripts/ai/acx_repair.py diagnose` after failed gates, Red/hard Red, failed profiles, or repeated Yellow churn.
8. Use `scripts/ai/acx_closeout.py` and `scripts/ai/acx_sanitized_evidence.py` when a proof packet or handoff packet is needed.
9. Close out with raw-log evidence, exit codes, Green/Yellow/Red, claims not made, and next prompt.

## Batch Train Orchestrator

Use `docs/codex/AMBITIONS_3_0_BATCH_TRAIN_ORCHESTRATOR.md`, `docs/codex/CODEX_BATCH_TRAIN_PROTOCOL.md`, plus the artifacts in this directory for gated Ambitions batch trains. F03.5, F13.5, and F16.5 are architecture checkpoint prompts; do not skip them when their triggers fire.
