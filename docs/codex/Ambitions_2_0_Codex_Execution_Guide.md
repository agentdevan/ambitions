# Ambitions 2.0 Codex Execution Guide

This file is the practical execution guide for Codex sessions. It should stay aligned with `CONTEXT_INDEX.md`, `MASTER_CODEX_SYSTEM.md`, `BATCH_REGISTRY.md`, and `FREE_WORKFLOW_OPERATING_SYSTEM.md`.

## Always Read Order

For Ambitions 2.0 tasks, read:

1. `AGENTS.md`
2. `MASTER_PRODUCT_SPEC.md`
3. `docs/codex/CONTEXT_INDEX.md`
4. `docs/codex/FREE_WORKFLOW_OPERATING_SYSTEM.md`
5. `docs/codex/MASTER_CODEX_SYSTEM.md`
6. `docs/codex/BATCH_REGISTRY.md`
7. `docs/canon/Ambitions_2_0_Master_Plan.md`
8. `docs/canon/Ambitions_2_0_Product_Architecture.md`
9. `docs/canon/Ambitions_2_0_Systems_Architecture.md`
10. `docs/canon/Ambitions_2_0_Visual_System.md`
11. `docs/canon/design/Ambitions_Design_Constitution.md` when the task touches design, IA, UX writing, interaction, trust, accessibility, or external surfaces
12. `docs/canon/Ambitions_2_0_Object_Terminology.md` when the task touches shared object naming or copy
13. `docs/canon/Ambitions_2_0_Roadmap.md`
14. `docs/canon/Ambitions_2_0_Batch_Plan.md`
15. `docs/canon/Ambitions_2_0_Intelligence_Standards.md`
16. `docs/canon/Ambitions_2_0_Accessibility_Nutrition.md` when accessibility, UI, release, or trust claims are involved
17. `docs/canon/Ambitions_2_0_Capability_Matrix.md` when verifying status or starting a roadmap reconciliation pass
18. `docs/canon/Ambitions_2_0_Implementation_Gap_Audit.md` when planning Design Constitution alignment or checking implementation gaps
19. `docs/canon/Ambitions_2_0_Roadmap_Merge_Audit.md` before planning any original Batch 89-120 work
20. `docs/review/VISUAL_REVIEW_CHECKLIST.md` when the task changes visible UI, navigation, empty states, or user-facing language
21. `docs/review/FRICTION_LOG.md` when observed product friction needs to be captured without expanding active batch scope

## Execution Rules

- Current execution status: Batches 00-88, D01-D26, M01-M12, and R01-R05 are complete for planning purposes. R05 records `Candidate prepared; human approval required`, not TestFlight readiness, App Store submission readiness, or final RC lock. Original Batches 89-120 remain future planned roadmap work only through the classifications and dependencies in `docs/canon/Ambitions_2_0_Roadmap_Merge_Audit.md` and `docs/canon/POST_D26_MATURITY_ROADMAP.md`.
- Work one batch at a time.
- Work on `main` only.
- Do not create, switch to, or suggest branches unless the user explicitly asks.
- Start with a plan pass before an implementation pass for non-trivial or multi-file work.
- Do not do feature work outside the active batch.
- Do not skip ahead into Batch 89+ implementation unless a direct user request explicitly changes scope and the roadmap merge audit dependencies are satisfied.
- Do not build surfaces before shared systems exist.
- Do not build widgets or Live Activities before Canonical Now State and Command Pipeline are stable.
- Do not do sync work before data model and capability verification.
- Do not add HealthKit, household/shared-life, food/calorie sync, or non-phone hardware work in Ambitions 2.0.
- Do not add paid automation or paid infrastructure unless the user explicitly authorizes it.
- Prefer free local validation, targeted tests, manual visual review, and repo-native Markdown checklists over GitHub Actions, scheduled agents, paid cloud runners, or external QA services.
- Future batches must preserve the Goal -> Plan -> Task -> Proof relationship: goals show direction, plans show the believable path, milestones show meaningful checkpoints, tasks show concrete next action, proof shows real progress, decisions explain change, weather shows readable health, and archive preserves learning.
- Design, IA, UX writing, component naming, interaction, trust, accessibility, and external-surface decisions must preserve `docs/canon/design/Ambitions_Design_Constitution.md`.
- Active shell remains Today / Goals / Capture / Plan / You. Do not restore Insights, Profile, Habits, or Tasks as top-level tabs.
- Batches 83, 84, 85, 93, 97, and 107 inherit the integrated Goal / Plan / Task visual systems from the active canon; do not rename them locally or split overlapping concepts into duplicate engines.
- Preserve old launch/release history as historical docs unless a specific batch supersedes it.
- Report changed files and validation steps every time.

## Required Batch Lifecycle

Use the lifecycle in `FREE_WORKFLOW_OPERATING_SYSTEM.md`:

1. Preflight.
2. Plan.
3. Implement.
4. Validate.
5. Visual / UX review when relevant.
6. Docs sync.
7. Stale-reference audit.
8. Completion summary.
9. Human review.
10. Next prompt.

A batch is not complete until implementation, validation evidence, registry/doc truth, and handoff are aligned.

## Required Completion Summary Format

Return:

1. Current batch and scope
2. Files changed
3. What changed
4. Validation performed
5. Visual / UX review result when relevant
6. Verified
7. Not verified
8. Could not verify here
9. Likely risks
10. Manual follow-up required
11. Registry update recommendation
12. Completion claim: Complete / Not complete / Blocked
