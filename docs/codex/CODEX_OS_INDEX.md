# Ambitions Codex OS Index

Status: Active Codex OS index and usage-efficiency overlay.  
Date: 2026-05-07  
Scope: Developer tooling, execution governance, evidence discipline, and batch-train efficiency. This file is not product implementation evidence.

## Purpose

This index prevents future Codex sessions from rediscovering the repo from scratch. It points agents to the smallest operating layer that can safely answer the current task.

## Source-Truth Precedence

1. Current user directive.
2. `AGENTS.md`.
3. `docs/codex/CODEX_OS_PEAK_OPERATING_PROTOCOL.md`.
4. `.codex/README.md`.
5. `docs/codex/CONTEXT_INDEX.md`.
6. `docs/canon/Ambitions_3_0_Codex_Performance_Operating_System.md`.
7. `docs/codex/CODEX_QUALITY_SYSTEM_GATE_MATRIX.md`.
8. `docs/codex/CODEX_QUALITY_SYSTEM_REPAIR_PROTOCOL.md`.
9. `.codex/reports/current-batch-train-state.md`.
10. This index and the route/state/evidence files named below.

When files disagree, preserve the older historical record and add a reconciliation note instead of overwriting history.

## Codex OS Subsystems

| Subsystem | Path | Use |
| --- | --- | --- |
| Operating protocol | `docs/codex/CODEX_OS_PEAK_OPERATING_PROTOCOL.md` | Red/Yellow/Green rules, no-overwrite, no-double-work, stop/repair conditions. |
| Run state | `docs/codex/AMBITIONS_3_0_RUN_STATE_PROTOCOL.md` | How to persist and resume long sessions. |
| Batch state | `.codex/reports/current-batch-train-state.md` | Current train truth and next eligible batch. |
| CQS gates | `docs/codex/CODEX_QUALITY_SYSTEM_GATE_MATRIX.md` | Source truth, scope, architecture, visual quality, accessibility, privacy, validation, report gates. |
| CQS scripts | `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` | Advisory scan entry points. |
| ACX extractor | `scripts/ai/acx.py` and `scripts/ai/acx` | Bounded reads, saved-log summaries, changed-file grouping from saved status text, advisory gates, and gate reports. |
| Route context | `.codex/routes/*.route.md` | Small read lists and proof rules by task. |
| State snapshots | `.codex/state/*.md` and `.codex/state/*.yml` | Efficiency snapshots that point back to authoritative run/batch state. |
| Evidence standard | `docs/codex/CODEX_EVIDENCE_STANDARD.md` | Required proof before claims. |
| Usage efficiency | `docs/codex/CODEX_USAGE_EFFICIENCY.md` | Context budget, ACX, route-first execution, proof policy. |
| Agent protocol | `docs/codex/CODEX_AGENT_PROTOCOL.md` | How Codex should start, inspect, edit, validate, and report. |
| Batch protocol | `docs/codex/CODEX_BATCH_TRAIN_PROTOCOL.md` | Continue-until-hard-Red behavior and restart discipline. |

## Default Session Boot

Use this sequence unless the user scopes a smaller task:

```bash
python3 scripts/ai/acx.py read AGENTS.md --lines 140
python3 scripts/ai/acx.py read docs/codex/CODEX_OS_PEAK_OPERATING_PROTOCOL.md --lines 120
python3 scripts/ai/acx.py read .codex/reports/current-batch-train-state.md --lines 180
```

Then select exactly one route file from `.codex/routes/`.

## Efficiency Rule

Read summaries first, owner docs second, full source third. Use broad repo search only after route context and existing state fail to answer the question.

## Claim Boundary

This operating layer can prove that Codex OS docs/tooling were added or changed. It cannot prove app behavior, build success, device success, public accessibility conformance, privacy/legal compliance, App Store readiness, TestFlight readiness, release readiness, or production readiness without matching command and human/operator evidence.
