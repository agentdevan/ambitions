# Ambitions Codex Context
<!-- markdownlint-disable MD013 -->

This folder contains operating context for Ambitions Codex runs.

Ambitions 3.0 is the active source of truth. Older Codex prompts and batch files are implementation history or support material unless Ambitions 3.0 explicitly keeps them binding.

Ambitions 4.0 is the active post-3.0 execution program, not a shipped product version. Use [../canon/Ambitions_4_0_Execution_Program.md](../canon/Ambitions_4_0_Execution_Program.md) for queued/blocked status semantics across the 113-batch global order after SI insertion.

EFC is the active peak-proof overlay for unfinished work. Use [EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md](EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md), [BATCH_REGISTRY_EFC_OVERLAY.md](BATCH_REGISTRY_EFC_OVERLAY.md), [GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md](GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md), and [batch-trains/EFC00_EFC18_FLAGSHIP_PROOF_CLOSURE_OVERLAY.md](batch-trains/EFC00_EFC18_FLAGSHIP_PROOF_CLOSURE_OVERLAY.md) after checking active batch state. EFC is not a parallel feature train; it wires proof obligations into existing unfinished owners and adds missing owner batches only where no existing train can produce the proof.

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
11. `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md` and `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md` for peak proof obligations on unfinished work.

## Primary Codex Entry Points

- [MASTER_AMBITIONS_3_0_CODEX_PROMPT.md](MASTER_AMBITIONS_3_0_CODEX_PROMPT.md) — concise canonical prompt for future Codex 5.5 sessions.
- [AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING.md](AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING.md) — how to choose context packs, skills, operations, and validation.
- [AMBITIONS_3_0_SKILL_SYSTEM_INDEX.md](AMBITIONS_3_0_SKILL_SYSTEM_INDEX.md) — repo-local skill catalog.
- [MAC_CODEX_5_5_TOOLCHAIN_SETUP.md](MAC_CODEX_5_5_TOOLCHAIN_SETUP.md) — local Mac/Codex setup and validation commands.
- [MCP_LOCAL_PRODUCTION_OS_PLAN.md](MCP_LOCAL_PRODUCTION_OS_PLAN.md) — local MCP production acceleration plan.
- [MCP_CODEX_SETUP.md](MCP_CODEX_SETUP.md) — Mac VM / Codex setup for Ambitions MCP servers.
- [MCP_EXTERNAL_SERVER_SETUP.md](MCP_EXTERNAL_SERVER_SETUP.md) — external MCP setup and local registration evidence.
- [MCP02_CONTROLLED_PROOF_MCP.md](MCP02_CONTROLLED_PROOF_MCP.md) — allowlisted local proof MCP.
- [MCP03_VISUAL_PROOF_MCP_PLAN.md](MCP03_VISUAL_PROOF_MCP_PLAN.md) — visual proof MCP plan and folder shape.
- [MCP04_ACCESSIBILITY_SHADOW_MCP_PLAN.md](MCP04_ACCESSIBILITY_SHADOW_MCP_PLAN.md) — EFC09 accessibility shadow MCP plan.
- [MCP05_AMBITIONS_TWIN_FIXTURE_MCP_PLAN.md](MCP05_AMBITIONS_TWIN_FIXTURE_MCP_PLAN.md) — Ambitions Twin fixture MCP plan.
- [MCP06_SOURCE_ATLAS_PACK_MCP_PLAN.md](MCP06_SOURCE_ATLAS_PACK_MCP_PLAN.md) — Source Atlas pack MCP plan.
- [MCP07_RELEASE_TRUTH_MCP_PLAN.md](MCP07_RELEASE_TRUTH_MCP_PLAN.md) — release truth MCP plan.
- [GITHUB_NATIVE_TOOLING_POLICY.md](GITHUB_NATIVE_TOOLING_POLICY.md) — GitHub MCP, Dependabot, CodeQL, Actions, and runner policy.
- [AMBITIONS_3_0_RUN_STATE_PROTOCOL.md](AMBITIONS_3_0_RUN_STATE_PROTOCOL.md) — checkpointable state model for long Codex runs.
- [AMBITIONS_3_0_LARGE_BATCH_AND_COMPACT_RECOVERY_PROTOCOL.md](AMBITIONS_3_0_LARGE_BATCH_AND_COMPACT_RECOVERY_PROTOCOL.md) — XL batch checkpoint and compaction recovery rules.
- [AMBITIONS_3_0_PROMPT_QUALITY_RUBRIC.md](AMBITIONS_3_0_PROMPT_QUALITY_RUBRIC.md) — prompt quality scoring for future implementation asks.
- [AMBITIONS_3_0_PARALLEL_CODEX_WORKTREE_PROTOCOL.md](AMBITIONS_3_0_PARALLEL_CODEX_WORKTREE_PROTOCOL.md) — parallel worktree guardrails.
- [CONTEXT_INDEX.md](CONTEXT_INDEX.md) — source precedence and implementation-history navigation.
- [BATCH_REGISTRY.md](BATCH_REGISTRY.md) — implementation status truth only.
- [BATCH_REGISTRY_EFC_OVERLAY.md](BATCH_REGISTRY_EFC_OVERLAY.md) — EFC proof-owner overlay for the active registry.
- [GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md](GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md) — peak optimized global sequencing overlay.
- [EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md](EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md) — 100/100 planned-architecture proof operating layer.
- [../canon/Ambitions_4_0_Execution_Program.md](../canon/Ambitions_4_0_Execution_Program.md) — active post-3.0 execution-program status semantics.
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

## Local MCP Production OS

The Ambitions local production MCP stack starts with:

- `tools/mcp/ambitions_repo_mcp/`
- `tools/mcp/ambitions_proof_mcp/`

Use `ambitions_repo_mcp` as a local, read-only Codex acceleration layer for active-batch state, EFC applicability, source-truth stack, changed-file impact, forbidden claim scanning, closeout shape validation, and repo posture summaries.

Use `ambitions_proof_mcp` for allowlisted local validation names only. It is not a generic shell.

Scaffold-only MCP plans live under:

- `tools/mcp/ambitions_visual_mcp/`
- `tools/mcp/ambitions_accessibility_mcp/`
- `tools/mcp/ambitions_fixture_mcp/`
- `tools/mcp/ambitions_source_atlas_mcp/`
- `tools/mcp/ambitions_release_truth_mcp/`

Setup docs:

- [MCP Local Production OS Plan](MCP_LOCAL_PRODUCTION_OS_PLAN.md)
- [MCP Codex Setup](MCP_CODEX_SETUP.md)
- [MCP External Server Setup](MCP_EXTERNAL_SERVER_SETUP.md)
- [GitHub Native Tooling Policy](GITHUB_NATIVE_TOOLING_POLICY.md)

MCP is local developer tooling only. It is not an Ambitions app runtime dependency, does not authorize hosted AI, does not add telemetry, and does not prove release/device/accessibility/legal/privacy readiness by itself.

## FAANG Team Operating Protocols

The FAANG-team operating upgrade is indexed from:

- [../canon/Ambitions_3_0_FAANG_Team_Operating_Model.md](../canon/Ambitions_3_0_FAANG_Team_Operating_Model.md)
- [../canon/Ambitions_3_0_Task_Width_And_Batch_Combining_Gate.md](../canon/Ambitions_3_0_Task_Width_And_Batch_Combining_Gate.md)
- [../canon/Ambitions_3_0_UI_Test_Contract.md](../canon/Ambitions_3_0_UI_Test_Contract.md)
- [../canon/Ambitions_3_0_Local_Toolchain_Readiness_Matrix.md](../canon/Ambitions_3_0_Local_Toolchain_Readiness_Matrix.md)
- [../canon/Ambitions_3_0_Definition_Of_Ready_And_Done.md](../canon/Ambitions_3_0_Definition_Of_Ready_And_Done.md)
- [../canon/Ambitions_3_0_Decision_Record_Protocol.md](../canon/Ambitions_3_0_Decision_Record_Protocol.md)
- [../canon/Ambitions_3_0_Architecture_Review_Board_Protocol.md](../canon/Ambitions_3_0_Architecture_Review_Board_Protocol.md)
- [../canon/Ambitions_3_0_Release_Claim_Truth_Protocol.md](../canon/Ambitions_3_0_Release_Claim_Truth_Protocol.md)
- [../canon/Ambitions_Beyond_3_0_Continuity_Rules.md](../canon/Ambitions_Beyond_3_0_Continuity_Rules.md)

## Historical Material

- [Ambitions_2_0_Codex_Execution_Guide.md](Ambitions_2_0_Codex_Execution_Guide.md) is historical/supporting unless a 3.0 doc explicitly references it.
- [batches/](batches/) preserves implementation evidence and older prompts. Do not run old batch prompts as active Ambitions 3.0 work without reconciling them against the 3.0 source docs.
- [FAANG_HANDOFF_REPO_CLEANUP_PROMPT.md](FAANG_HANDOFF_REPO_CLEANUP_PROMPT.md) remains the cleanup prompt used to produce the current handoff audit outputs.

## Batch Train Orchestrator

Use `docs/codex/AMBITIONS_3_0_BATCH_TRAIN_ORCHESTRATOR.md` plus the artifacts in this directory for gated Ambitions 3.0 batch trains. F03.5, F13.5, and F16.5 are architecture checkpoint prompts; do not skip them when their triggers fire.

Completed historical train: [batch-trains/F17_F30_FAANG_HANDOFF_COMPLETION_TRAIN.md](batch-trains/F17_F30_FAANG_HANDOFF_COMPLETION_TRAIN.md). F17 through F30 are Green by current train evidence. F27 remains PASS after the F28 repair/rebaseline, F27.5 completed with no critical maintainability blocker, F29 created the final engineer handoff package, and F30 created the Beyond 3.0 continuation plan and final closeout. Beyond 3.0 is now represented operationally by the Ambitions 4.0 Execution Program. Release Evidence Closure is complete through REC06; PX01-PX20 are complete as future canon/roadmap evidence, and PXOS, ME, CS, Signature Interface, Product Depth, and AOS remain future/queued until selected and proven by evidence.

## EFC Peak Proof Controls

- [EFC Flagship Proof Operating Layer](EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md)
- [Batch Registry EFC Overlay](BATCH_REGISTRY_EFC_OVERLAY.md)
- [Global Full-Stack Completion Order — EFC Peak Overlay](GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md)
- [EFC00-EFC18 Flagship Proof Closure Overlay](batch-trains/EFC00_EFC18_FLAGSHIP_PROOF_CLOSURE_OVERLAY.md)

EFC defines the peak optimized proof sequence for unfinished work. It does not authorize production Swift, release claims, hosted AI, telemetry, sync, signing, entitlements, hosted CI, App Store readiness, TestFlight readiness, physical-device proof, public accessibility proof, or legal/privacy compliance by itself.

## Ambitions 4.0 Global Batch Controls

- [Global Future Batch Execution Order](GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md)
- [Global Future Batch Dependency Graph](GLOBAL_FUTURE_BATCH_DEPENDENCY_GRAPH.md)
- [Global Future Batch Gate Matrix](GLOBAL_FUTURE_BATCH_GATE_MATRIX.md)
- [Global Batch Execution Orchestrator](GLOBAL_BATCH_EXECUTION_ORCHESTRATOR.md)
- [Global Batch Automated Gate Protocol](GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md)
- [Global Batch Repair Loop Protocol](GLOBAL_BATCH_REPAIR_LOOP_PROTOCOL.md)
- [Global Batch Continuation Protocol](GLOBAL_BATCH_CONTINUATION_PROTOCOL.md)
- [Global Batch FAANG Quality Bar](GLOBAL_BATCH_FAANG_QUALITY_BAR.md)

These controls define the Ambitions 4.0 global execution order, automated gates, repair behavior, validation strength, and continuation rules. They are not approval to start REC02, PXOS, ME, CS, SI, AOS, Product Depth, or any implementation train.

## AmbitionsOS Future Trains

- [AOS Train Control System](AMBITIONSOS_AOS_TRAIN_CONTROL_SYSTEM.md)
- [AOS01-AOS30 Train](batch-trains/AOS01_AOS30_AMBITIONSOS_LOCAL_INTELLIGENCE_TRAIN.md)
- [ME01-ME12 Train](batch-trains/ME01_ME12_MAINTAINABILITY_EXTRACTION_TRAIN.md)
- [CS01-CS10 Train](batch-trains/CS01_CS10_COMPATIBILITY_SEAM_RETIREMENT_TRAIN.md)
- [SI01-SI18 Train](batch-trains/SI01_SI18_SIGNATURE_INTERFACE_IMPLEMENTATION_TRAIN.md)

These trains are queued/blocked in Ambitions 4.0 and must not run automatically after canon authoring.

## Active Post-3.0 Train

- [REC01-REC06 Release Evidence Closure Train](batch-trains/REC01_REC06_RELEASE_EVIDENCE_CLOSURE_TRAIN.md) is complete as evidence/status work after the 2026-05-02 pre-train hardening pass. It did not implement app behavior or claim release/platform proof.

## PXOS Future Controls

- [PXOS Train Control System](PXOS_TRAIN_CONTROL_SYSTEM.md)
- [PXOS Gate Matrix](PXOS_GATE_MATRIX.md)
- [PXOS Product Decision Ledger](PXOS_PRODUCT_DECISION_LEDGER.md)
- [PXOS Batch Prompt Standard](PXOS_BATCH_PROMPT_STANDARD.md)
- [PX01-PX20 Train](batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md)

PXOS is future user-facing product experience canon. PX01-PX20 are complete as future canon/roadmap evidence; PXOS implementation is not started. Later implementation work starts only through global dry-run and valid approval gates.

- [EB External Brain Dependency Graph](EB_EXTERNAL_BRAIN_DEPENDENCY_GRAPH.md) - active planned 4.0 EB train dependencies.
