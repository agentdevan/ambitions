# Ambitions 3.0 Codex System Audit

Status: Completed for Codex Performance Operating System pass

## Executive Summary

The existing Codex system had useful operational history, but several active entry points still pointed Codex toward Ambitions 2.0/v2-era guidance before Ambitions 3.0. This pass reclassifies older material as historical/supporting, preserves implementation evidence, and creates a 3.0-first operating system.

## Audit Table

| File or area | Classification | Action |
|---|---|---|
| `AGENTS.md` | active but needed 3.0 update | Rewritten to 3.0-first guidance. |
| `README.md` | active | Added Codex Performance Operating System links. |
| `docs/README.md` | active | Added Codex Performance Operating System links. |
| `docs/canon/README.md` | active | Added Codex Performance Operating System links. |
| `docs/codex/README.md` | active but needed 3.0 update | Rewritten to 3.0-first Codex entry point. |
| `docs/codex/CONTEXT_INDEX.md` | active but needs ongoing migration | 3.0 top section already present; remaining historical sections are support/history. |
| `docs/codex/MASTER_CODEX_SYSTEM.md` | active but needed 3.0 update | Rewritten to 3.0-first behavior and current handoff risks. |
| `docs/codex/FREE_WORKFLOW_OPERATING_SYSTEM.md` | active but needed 3.0 update | Rewritten to 3.0 local workflow. |
| `docs/codex/BATCH_REGISTRY.md` | implementation evidence/status | Preserved as status truth only. |
| `docs/codex/FAANG_HANDOFF_REPO_CLEANUP_PROMPT.md` | implementation-control evidence | Preserved as cleanup prompt. |
| `docs/codex/batches/` | implementation evidence only | Preserved; not active 3.0 prompts. |
| `.codex/skills/ambitions-*v2*` | stale but useful | Preserved as historical skills; new flat 3.0 skills added. |
| `.codex/operations/` | active but older transformation-specific | Preserved; new 3.0 protocols added. |
| `.codex/templates/` | active but older generic | Preserved; new Ambitions 3.0 templates added. |

## Remaining Risks

- Some historical docs still contain 2.0/v2 references. They are allowed only as history/supporting context.
- F00 must still audit implementation gaps and the 10 failing UI smoke tests from the handoff report.
