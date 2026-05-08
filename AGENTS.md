# Ambitions Codex Guidance

Ambitions 3.0 is the active source of truth. Ambitions 2.0, v2, Waves, Batch 61+, D/M/R, and earlier batch material are preserved as implementation history or supporting context only where Ambitions 3.0 explicitly keeps them binding.

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
11. `docs/codex/RESUME_GLOBAL_BATCH_TRAIN.md` when the user says `resume global batch train`.
12. `docs/codex/FLAGSHIP_IMPLEMENTATION_UPGRADE_OVERLAY.md` for flagship maturity, terminal-device, pre-device closure, and no-hosted-workflow validation rules.
13. `docs/codex/CODEX_OS_INDEX.md` for Codex OS routing, usage efficiency, evidence, route, and state-map entry points.

Older docs may remain useful, but they do not override Ambitions 3.0 source docs. If old docs conflict with Ambitions 3.0, resolve in favor of Ambitions 3.0 and document the conflict when it affects implementation.

## Repo Behavior

- Work on `main` only unless the user explicitly requests branch-based work.
- Do not create or switch branches for normal Ambitions execution.
- Preserve completed implementation history exactly as history.
- Preserve XcodeGen. Edit `project.yml` and regenerate the project; do not rely on a checked-in `.xcodeproj` as source truth.
- Preserve the native SwiftUI architecture.
- Do not create new top-level Ambitions destinations. The canonical destinations remain `Today / Goals / Capture / Plan / You`.
- Do not implement product features in docs/tooling passes unless the tooling itself requires a narrow test or compatibility fix.
- Use repo-local Codex operating docs, skills, validation packs, context packs, playbooks, templates, routes, state mirrors, evidence protocols, and extractors under `.codex/`, `docs/codex/`, and `scripts/ai/`.

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
- Use the smallest safe touch budget. Name primary files before edits.
- Prefer deterministic, additive, compatibility-safe changes.
- Do not silently rewrite product strategy, IA, naming, release posture, or roadmap structure.
- Do not invent seams or claim implementation without repo evidence.
- Do not add runtime app dependencies unless the dependency policy permits it and the user explicitly accepts the tradeoff.
- Prefer focused validation first, then broaden based on risk.
- After meaningful changes, run `xcodegen generate` and the relevant build/test/scan pack when local tooling supports it.
- Validation summaries must separate verified, failed, not verified, and human/device follow-up.
- Keep release claims conservative. Do not claim device verification, accessibility verification, TestFlight readiness, App Store readiness, or release readiness without matching evidence.

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
- `docs/codex/CODEX_USAGE_EFFICIENCY.md`
- `docs/codex/CODEX_AGENT_PROTOCOL.md`
- `docs/codex/CODEX_EVIDENCE_STANDARD.md`
- `docs/codex/CODEX_BATCH_TRAIN_PROTOCOL.md`
- `docs/codex/CODEX_ROUTE_CONTEXT_PROTOCOL.md`
- `docs/codex/CODEX_GATE_ENGINE.md`
- `docs/codex/CODEX_SKILLS_KIT.md`
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

## Codex OS Efficiency Overlay

Use ACX and route files for usage-heavy sessions:

```bash
python3 scripts/ai/acx.py read AGENTS.md --lines 140
python3 scripts/ai/acx.py read docs/codex/CODEX_OS_INDEX.md --lines 160
python3 scripts/ai/acx.py summarize-log output/logs/latest-build.log
python3 scripts/ai/acx.py changed-files-from output/logs/git-status-short.txt
python3 scripts/ai/acx.py gate all
python3 scripts/ai/acx.py gate-report
```

- ACX is non-executing. It reads bounded files, summarizes saved logs, groups changed-file text from saved status output, and runs advisory scans.
- Use `.codex/routes/README.md` before broad repo search.
- Use `.codex/state/ambitions-known-facts.md` and `.codex/state/active-batch.yml` only as compact mirrors; authoritative truth remains in the owner docs they reference.
- Use ACX summaries for navigation and routine review only.
- Inspect raw logs for failed builds, failed tests, failed gates, hard Reds, release/device/accessibility claims, and proof-sensitive decisions.
- If ACX is unavailable, fall back to normal file reads and bounded shell output; do not fail a task only because ACX is missing.

## Batch Train Rule

For multi-batch Ambitions execution, use `docs/codex/AMBITIONS_3_0_BATCH_TRAIN_ORCHESTRATOR.md`, `docs/codex/CODEX_BATCH_TRAIN_PROTOCOL.md`, `.codex/reports/current-batch-train-state.md`, and the selected manifest under `docs/codex/batch-trains/`. Codex may continue automatically through Green and accepted Yellow only when the owner, safety reason, and no-claim boundary are recorded. Red/hard Red stops and produces a repair or decision prompt. F17 Shell/Meridian implementation requires explicit approval.

## Resume Global Batch Train Alias

When the user says `resume global batch train`, immediately read `docs/codex/RESUME_GLOBAL_BATCH_TRAIN.md`. Resume from repo evidence, first close any parked FIO01 / PFC05A / DPTG00 Yellow if safe, then continue the next eligible global batch until all eligible batches are complete or an unrecoverable Red stops the train.
