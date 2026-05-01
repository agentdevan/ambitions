# Master Ambitions 3.0 Codex Prompt

Copy this into a fresh Codex 5.5 session from the repo root.

```markdown
You are Codex 5.5 working in `/Users/devan/Documents/GitHub/ambitions` on the native SwiftUI Ambitions repo.

Ambitions 3.0 is the active source of truth. Do not use Ambitions 2.0/v2, Waves, Batch 61+, or older roadmap docs as active direction unless a 3.0 doc explicitly keeps that domain binding.

First read:
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

Then choose:
- one context pack from `.codex/context-packs/`,
- one primary skill from `.codex/skills/`,
- one operation protocol from `.codex/operations/`, and
- one validation pack from `.codex/validation/`.

Before implementation, classify task width using `docs/canon/Ambitions_3_0_Task_Width_And_Batch_Combining_Gate.md`. For M/L/XL work, run the relevant FAANG role review from `docs/canon/Ambitions_3_0_FAANG_Team_Operating_Model.md`. For long or XL work, maintain `docs/codex/AMBITIONS_3_0_RUN_STATE_PROTOCOL.md` and `docs/codex/AMBITIONS_3_0_LARGE_BATCH_AND_COMPACT_RECOVERY_PROTOCOL.md` checkpoints. Use `docs/canon/Ambitions_3_0_Definition_Of_Ready_And_Done.md` for readiness and completion gates.

Preserve XcodeGen and native SwiftUI architecture. Work on `main` unless explicitly told otherwise. Do not create new top-level destinations. Do not add runtime dependencies without the dependency policy. Do not claim implementation, test, device, accessibility, TestFlight, App Store, or release readiness without evidence.

Before edits, inspect repo status and name the touch budget. When tooling matters, run `scripts/validate-dev-tools.sh`. For docs-heavy changes, run `scripts/run-doc-qa.sh`. For native build proof, prefer `scripts/build-local.sh`; for full test proof, use `scripts/test-local.sh` and report known UI smoke failures honestly. After edits, run the focused validation pack, then build/test only as risk requires. Close out with files changed, commands run, PASS/PARTIAL/FAIL, remaining risks, and the next exact prompt.
```

## Batch Train Orchestrator

When a prompt spans multiple Ambitions 3.0 batches, load `docs/codex/AMBITIONS_3_0_BATCH_TRAIN_ORCHESTRATOR.md`, select exactly one manifest under `docs/codex/batch-trains/`, initialize `.codex/reports/current-batch-train-state.md`, and continue only on Green. Yellow/Red stops with repair/resume material. FAANG handoff remains PARTIAL unless its gate is re-run and passes.

For the current handoff completion lane, use `docs/codex/batch-trains/F17_F30_FAANG_HANDOFF_COMPLETION_TRAIN.md` and `.codex/reports/current-batch-train-state.md`. F17 repair, F18, F19, F20, F21/F21.5, F22, and F22.5 are Green by current train evidence. F22.7 Human-Made Active Repo Hygiene / 3.0-As-Baseline Gate is mandatory before F23. FAANG handoff remains PARTIAL unless F27 explicitly passes.
