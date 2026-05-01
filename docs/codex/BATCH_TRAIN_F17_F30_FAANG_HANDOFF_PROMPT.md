# Batch Train F17-F30 FAANG Handoff Prompt

Path: `docs/codex/BATCH_TRAIN_F17_F30_FAANG_HANDOFF_PROMPT.md`
Status: Copy/paste ready train prompt
Created: 2026-05-01

You are Codex 5.5 working on `main` in `/Users/devan/Documents/GitHub/ambitions`.

Run the F17-F30 FAANG Handoff Completion Train from `docs/codex/batch-trains/F17_F30_FAANG_HANDOFF_COMPLETION_TRAIN.md`.

Read first:

1. `README.md`
2. `docs/README.md`
3. `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
4. `docs/canon/Ambitions_3_0_Front_End_Redesign_Index.md`
5. `docs/canon/Ambitions_3_0_Rebuild_Operating_Model.md`
6. `docs/canon/Ambitions_3_0_Documentation_System_Index.md`
7. `docs/canon/Ambitions_3_0_Primitive_Architecture.md`
8. `docs/canon/Ambitions_3_0_Product_Language_System.md`
9. `docs/codex/AMBITIONS_3_0_BATCH_TRAIN_ORCHESTRATOR.md`
10. `docs/codex/BATCH_REGISTRY.md`
11. `docs/codex/CONTEXT_INDEX.md`
12. selected batch prompt

Rules:

- Continue automatically only on Green.
- Yellow stops unless the current batch is the remediation batch for the Yellow condition.
- Red stops immediately.
- Do not skip gates.
- Do not skip F22.7.
- Do not skip F27.5.
- Do not run F18 unless F17 is Green.
- Do not remove native fallback navigation.
- Do not break top-level destination access.
- Do not touch `.github/workflows/`.
- Do not add runtime dependencies or paid services.
- Do not weaken tests to pass.
- Do not delete UI tests without replacement or retirement evidence.
- Do not fake App Store, device, privacy, accessibility, TestFlight, or release proof.
- Do not claim FAANG handoff readiness until F27 reruns the gate and passes.
- Treat Ambitions 3.0 as the current baseline. Active docs/code/tests/handoff material should not require old launches, old tabs, old shells, old batch history, or older canon to understand the current app.
- Preserve useful history only when archived, labeled as historical/supporting context, or required for compatibility.

Start with F17:

`docs/codex/batches/F17_Shell_Meridian_Planning_And_Readiness_Audit_Prompt.md`

Current continuation after F21.5 starts at F22 Product Language + Active Repo Baseline Reset, then F22.5 if triggered, mandatory F22.7, F23, F24, F24.5 if triggered, F25, F26, F27, mandatory F27.5, F28 if needed, F29, and F30.

After every Green batch:

1. update `.codex/reports/current-run-state.md`
2. update `.codex/reports/current-batch-train-state.md`
3. write the batch report
4. run required validation
5. commit with path-limited staging
6. push to `origin/main`
7. continue only to the next manifest batch

Final response must classify PASS / PARTIAL / FAIL and include batches attempted, batches completed, stop point, stop reason, commits, validation, architecture, FAANG handoff status, remaining risks, and the next exact prompt.
