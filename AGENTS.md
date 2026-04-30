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
- `docs/canon/Ambitions_3_0_Codex_Performance_Operating_System.md`
- `docs/codex/MASTER_AMBITIONS_3_0_CODEX_PROMPT.md`
- `docs/codex/AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING.md`
- `docs/codex/AMBITIONS_3_0_SKILL_SYSTEM_INDEX.md`
- `docs/canon/Ambitions_3_0_Dependency_Management_Policy.md`
- `docs/codex/MAC_CODEX_5_5_TOOLCHAIN_SETUP.md`
