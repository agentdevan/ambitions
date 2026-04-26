# Ambitions 2.0 Codex Execution Guide

## Always Read Order

For Ambitions 2.0 tasks, read:

1. `AGENTS.md`
2. `MASTER_PRODUCT_SPEC.md`
3. `docs/codex/CONTEXT_INDEX.md`
4. `docs/codex/MASTER_CODEX_SYSTEM.md`
5. `docs/codex/BATCH_REGISTRY.md`
6. `docs/canon/Ambitions_2_0_Master_Plan.md`
7. `docs/canon/Ambitions_2_0_Product_Architecture.md`
8. `docs/canon/Ambitions_2_0_Systems_Architecture.md`
9. `docs/canon/Ambitions_2_0_Visual_System.md`
10. `docs/canon/Ambitions_2_0_Roadmap.md`
11. `docs/canon/Ambitions_2_0_Batch_Plan.md`
12. `docs/canon/Ambitions_2_0_Accessibility_Nutrition.md` when accessibility, UI, release, or trust claims are involved
13. `docs/canon/Ambitions_2_0_Capability_Matrix.md` when verifying status or starting Batch 61

## Execution Rules

- Current execution status: Batch 00-82 are complete for planning, Batch 83 is the next queued / next uncompleted batch, and Batch 84+ are future planned roadmap work.
- Work one batch at a time.
- Work on `main` only.
- Do not create, switch to, or suggest branches unless the user explicitly asks.
- Start with a plan pass before an implementation pass for non-trivial or multi-file work.
- Do not do feature work outside the active batch.
- Do not skip ahead into Batch 84+ implementation unless a direct user request explicitly changes scope.
- Do not build surfaces before shared systems exist.
- Do not build widgets or Live Activities before Canonical Now State and Command Pipeline are stable.
- Do not do sync work before data model and capability verification.
- Do not add HealthKit, household/shared-life, food/calorie sync, or non-phone hardware work in Ambitions 2.0.
- Future batches must preserve the Goal -> Plan -> Task -> Proof relationship: goals show direction, plans show the believable path, milestones show meaningful checkpoints, tasks show concrete next action, proof shows real progress, decisions explain change, weather shows readable health, and archive preserves learning.
- Batches 83, 84, 85, 93, 97, and 107 inherit the newly integrated Goal / Plan / Task visual systems from the active canon; do not implement them early, rename them locally, or split overlapping concepts into duplicate engines.
- Preserve old launch/release history as historical docs unless a specific batch supersedes it.
- Report changed files and validation steps every time.

## Required Completion Summary Format

Return:

1. Current batch and scope
2. Files changed
3. What changed
4. Validation performed
5. Verified
6. Not verified
7. Could not verify here
8. Likely risks
9. Manual follow-up required
10. Registry update recommendation
