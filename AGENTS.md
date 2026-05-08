# Ambitions Codex Guidance

Ambitions 3.0 remains the completed implementation baseline, but the Ambitions Design System and AmbitionsCanon pack are now the highest source truth for future Ambitions product, visual, shell, chrome, IA, Signature Object, trust, accessibility, QA, token/material, and implementation-planning work. Ambitions 2.0, v2, Waves, Batch 61+, D/M/R, Ambitions 3.0/4.0, PXOS, SI, handoff, audit, and Codex train material are preserved as implementation history, supporting context, or stricter proof gates where compatible.

## Required Read Order

0. `docs/AmbitionsCanon/README.md` for future product/design/source-truth precedence, then the AmbitionsCanon docs it names when the task touches product, visual, shell, chrome, IA, Signature Objects, trust, accessibility, QA, tokens/materials, or implementation planning.
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
11. `docs/codex/RESUME_GLOBAL_BATCH_TRAIN.md` when the user says `resume global batch train`.
12. `docs/codex/FLAGSHIP_IMPLEMENTATION_UPGRADE_OVERLAY.md` for flagship maturity, terminal-device, pre-device closure, and no-hosted-workflow validation rules.
13. `docs/codex/CODEX_OS_INDEX.md` for Codex OS route, ACX, gate, evidence, batch-state, and skills routing when the task is developer-tooling, governance, or long-run execution.

Older docs may remain useful, but they do not override Ambitions 3.0 source docs. If old docs conflict with Ambitions 3.0, resolve in favor of Ambitions 3.0 and document the conflict when it affects implementation.

## Repo Behavior

- Work on `main` only unless the user explicitly requests branch-based work.
- Do not create or switch branches for normal Ambitions execution.
- Preserve completed implementation history exactly as history.
- Preserve XcodeGen. Edit `project.yml` and regenerate the project; do not rely on a checked-in `.xcodeproj` as source truth.
- Preserve the native SwiftUI architecture.
- Do not create new top-level Ambitions destinations. The canonical destinations remain `Today / Goals / Capture / Plan / You`.
- Do not implement product features in docs/tooling passes unless the tooling itself requires a narrow test or compatibility fix.
- Use repo-local Codex operating docs, skills, validation packs, context packs, playbooks, and templates under `.codex/` and `docs/codex/`.
- During Codex OS / developer-tooling / governance passes, do not implement app features, refactor SwiftUI source, modify product IA, or add runtime app dependencies.

## Architecture Boundaries

- `Native/Ambitions/App` owns app entry, dependency container, environment injection, shell, and routing.
- `Native/Ambitions/Domain` owns domain models, contracts, state machines, receipts, proof, recommendation, and planning logic.
- `Native/Ambitions/Services` owns service protocols and implementations.
- `Native/Ambitions/Persistence` owns SwiftData persistence.
- `Native/Ambitions/Features` owns feature UI for Today, Goals, Capture, Plan, You, and owned secondary surfaces.
- `Native/Ambitions/UI`, `Sources/`, and `AppUI/Sources/` own shared UI and package surfaces.
- `project.yml` is the XcodeGen source of truth for targets, schemes, app extensions, and build wiring.

## Execution Rules

- Start non-trivial work by checking repo status, current docs, and the target code paths.
- For non-trivial work, pick one route from `.codex/routes/README.md` before broad search. Add a second route only for real cross-boundary work.
- Use the smallest safe touch budget. Name primary files before edits.
- Prefer deterministic, additive, compatibility-safe changes.
- Do not silently rewrite product strategy, IA, naming, release posture, or roadmap structure.
- Do not invent seams or claim implementation without repo evidence.
- Do not add runtime app dependencies unless the dependency policy permits it and the user explicitly accepts the tradeoff.
- Prefer focused validation first, then broaden based on risk.
- After meaningful changes, run `xcodegen generate` and the relevant build/test/scan pack when local tooling supports it.
- Validation summaries must separate verified, failed, not verified, and human/device follow-up.
- Keep release claims conservative. Do not claim device verification, accessibility verification, TestFlight readiness, App Store readiness, or release readiness without matching evidence.
- Use `scripts/ai/acx.py` only as a non-executing extractor for bounded reads, saved-log summaries, changed-file grouping, advisory scans, and gate reports.
- Use `scripts/ai/acx_local.py` only for allowlisted local command profiles. It must not accept arbitrary shell strings, use `shell=True`, run destructive commands, stage, commit, push, reset, clean, delete, switch branches, run `sudo`, or run `bash -c` / `sh -c`.
- Preserve raw command logs under `.codex/logs/` when using ACX Local. Summaries do not replace raw logs.
- If ACX is unavailable, fall back to direct `rg`, `git status`, documented validation commands, and manual raw-log capture; report the fallback.

## Ambitions Product Truth

- Ambitions is a premium native iOS life execution system.
- Core loop: `Capture -> Place -> Plan -> Do Today -> Close / Recover -> Save Proof`.
- Ambitions is not a generic task app, calendar clone, habit tracker, productivity score app, chatbot, or AI wrapper.
- User-facing language should prefer Ambitions 3.0 terms such as `Start here`, `What needs a place?`, `Does this hold together?`, `Close the loop`, `Still Counts`, `Proof saved`, and `You are in control`.
- Avoid fake precision, fake certainty, AI theater, shame language, and silent automation.

## Repo-Local Codex System

Use these entry points for Codex performance and execution:

- `.codex/README.md`
- `docs/codex/CODEX_OS_INDEX.md`
- `docs/codex/CODEX_ROUTE_CONTEXT_PROTOCOL.md`
- `docs/codex/CODEX_ACX_LOCAL_EXECUTOR.md`
- `docs/codex/CODEX_EVIDENCE_STANDARD.md`
- `docs/codex/CODEX_GATE_ENGINE.md`
- `docs/codex/CODEX_BATCH_TRAIN_PROTOCOL.md`
- `docs/codex/CODEX_SKILLS_KIT.md`
- `docs/codex/CODEX_REPO_HYGIENE_PROTOCOL.md`
- `docs/canon/Ambitions_3_0_Codex_Performance_Operating_System.md`
- `docs/canon/Ambitions_3_0_FAANG_Team_Operating_Model.md`
- `docs/canon/Ambitions_3_0_Task_Width_And_Batch_Combining_Gate.md`
- `docs/canon/Ambitions_3_0_UI_Test_Contract.md`
- `docs/canon/Ambitions_3_0_Definition_Of_Ready_And_Done.md`
- `docs/codex/MASTER_AMBITIONS_3_0_CODEX_PROMPT.md`
- `docs/codex/AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING.md`
- `docs/codex/AMBITIONS_3_0_SKILL_SYSTEM_INDEX.md`
- `docs/codex/AMBITIONS_3_0_RUN_STATE_PROTOCOL.md`
- `docs/canon/Ambitions_3_0_Dependency_Management_Policy.md`
- `docs/codex/MAC_CODEX_5_5_TOOLCHAIN_SETUP.md`
- `docs/codex/RESUME_GLOBAL_BATCH_TRAIN.md`
- `docs/codex/FLAGSHIP_IMPLEMENTATION_UPGRADE_OVERLAY.md`

## Batch Train Rule

For multi-batch Ambitions 3.0 execution, use `docs/codex/AMBITIONS_3_0_BATCH_TRAIN_ORCHESTRATOR.md`, `docs/codex/CODEX_BATCH_TRAIN_PROTOCOL.md`, `.codex/reports/current-batch-train-state.md`, and the selected manifest under `docs/codex/batch-trains/`. Codex may continue automatically through Green and accepted Yellow only when owner, safety reason, and no-claim boundary are recorded. Hard Red stops. F17 Shell/Meridian implementation requires explicit approval.

## Resume Global Batch Train Alias

When the user says `resume global batch train`, immediately read `docs/codex/RESUME_GLOBAL_BATCH_TRAIN.md`. Resume from repo evidence, first close any parked FIO01 / PFC05A / DPTG00 Yellow if safe, then continue the next eligible global batch until all eligible batches are complete or an unrecoverable Red stops the train.
