# Ambitions Codex Context

This folder contains operating context for Ambitions Codex runs.

Ambitions 3.0 is the active source of truth. Older Codex prompts and batch files are implementation history or support material unless Ambitions 3.0 explicitly keeps them binding.

## Required Read Order

1. `README.md`
2. `docs/README.md`
3. `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
4. `docs/canon/Ambitions_3_0_Front_End_Redesign_Index.md`
5. `docs/canon/Ambitions_3_0_Rebuild_Operating_Model.md`
6. `docs/canon/Ambitions_3_0_Documentation_System_Index.md`
7. `docs/canon/Ambitions_3_0_Primitive_Architecture.md`
8. `docs/canon/Ambitions_3_0_Product_Language_System.md`
9. The target Ambitions 3.0 primitive, surface, state-machine, privacy, accessibility, QA, release, or dependency doc.
10. `docs/codex/BATCH_REGISTRY.md` for implementation status truth only.

## Primary Codex Entry Points

- [MASTER_AMBITIONS_3_0_CODEX_PROMPT.md](MASTER_AMBITIONS_3_0_CODEX_PROMPT.md) — concise canonical prompt for future Codex 5.5 sessions.
- [AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING.md](AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING.md) — how to choose context packs, skills, operations, and validation.
- [AMBITIONS_3_0_SKILL_SYSTEM_INDEX.md](AMBITIONS_3_0_SKILL_SYSTEM_INDEX.md) — repo-local skill catalog.
- [MAC_CODEX_5_5_TOOLCHAIN_SETUP.md](MAC_CODEX_5_5_TOOLCHAIN_SETUP.md) — local Mac/Codex setup and validation commands.
- [CONTEXT_INDEX.md](CONTEXT_INDEX.md) — source precedence and implementation-history navigation.
- [BATCH_REGISTRY.md](BATCH_REGISTRY.md) — implementation status truth only.
- [MASTER_CODEX_SYSTEM.md](MASTER_CODEX_SYSTEM.md) — standing Codex behavior, now subordinate to Ambitions 3.0.
- [FREE_WORKFLOW_OPERATING_SYSTEM.md](FREE_WORKFLOW_OPERATING_SYSTEM.md) — free local validation and handoff workflow.

## Repo-Local Operating System

The reusable system lives under `.codex/`:

- `.codex/skills/` for task-specific execution guidance.
- `.codex/operations/` for protocols.
- `.codex/templates/` for copy/paste prompts and reports.
- `.codex/validation/` for validation packs.
- `.codex/playbooks/` for failure recovery.
- `.codex/context-packs/` for minimal context sets.
- `.codex/checklists/` for preflight, commit, release, privacy, accessibility, and handoff checks.

## Historical Material

- [Ambitions_2_0_Codex_Execution_Guide.md](Ambitions_2_0_Codex_Execution_Guide.md) is historical/supporting unless a 3.0 doc explicitly references it.
- [batches/](batches/) preserves implementation evidence and older prompts. Do not run old batch prompts as active Ambitions 3.0 work without reconciling them against the 3.0 source docs.
- [FAANG_HANDOFF_REPO_CLEANUP_PROMPT.md](FAANG_HANDOFF_REPO_CLEANUP_PROMPT.md) remains the cleanup prompt used to produce the current handoff audit outputs.
