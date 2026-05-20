<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# Private Life Runtime Source Proof Alignment

## Batch ID
AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T13-PRIVATE-LIFE-RUNTIME

## Runner command
`scripts/ambitions-codex-train.sh AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T13-PRIVATE-LIFE-RUNTIME prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T13-PRIVATE-LIFE-RUNTIME.md`

## Objective
Align source, tests, and docs around the Private Life Runtime proof target without claiming completion.

## Active source truth to inspect
Truth files, `docs/runtime/PRIVATE_LIFE_RUNTIME_PROOF_SPEC.md`, Domain/Services/Persistence runtime files, tests, receipts/proof docs.

## Allowed scope
Runtime proof maps, focused deterministic/local source or tests when tightly scoped, docs/status proof boundaries, reset reports.

## Forbidden scope
No cloud/LLM/backend shortcut, no hidden recommendation engine, no completion claim without scenario tests, no frontend-doc truth relocation.

## Implementation requirements
Map or test the proof target: same intent plus different local context yields different inspectable daily execution sequence, relaunch replay, closure/recovery adaptation, and proof/receipt continuity.

## Visual proof expectations
None unless UI proof seams are touched.

## Accessibility expectations
No accessibility proof claims unless tested.

## Privacy / trust expectations
Runtime remains deterministic, local, inspectable, receipt-backed, and user-controllable.

## Continuity expectations
Preserve existing persistence and recommendation contracts; avoid migrations unless tested.

## Validation expectations
Run focused runtime tests if present/added, build when feasible, prompt validators, Codex OS validator, JSON parse, `git diff --check`, and `git status --short`.

## Hard Red stop conditions
Cloud/core LLM/backend introduced, proof target claimed complete without tests, persistence break, or build failure.

## Rollback expectations
Restore touched runtime/test/docs files from this train only.

## Expected final report format
Proof target map, tests added/run, gaps, validation, non-claims.
