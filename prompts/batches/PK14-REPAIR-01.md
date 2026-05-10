<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

`PK14-REPAIR-01`

# Objective

Repair PK14 conductor/runner boundaries after bounded PK14 attempt failure so the
parent cannot re-enter recursive retry loops.

# Scope

- Do not run `PK14`.
- Do not run the global train.
- Do not touch app source.
- Do not mark PK14 complete.
- Update only governance/prompts/state surfaces required to enforce:
  - one child attempt per parent pass,
  - explicit repair handoff over uncontrolled reruns,
  - no self-rerun commands inside batch prompts.

# Required Read Order

1. `prompts/batches/RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION.md`
2. `prompts/batches/PK14.md`
3. `.codex/state/global-train-attempt-ledger.md`
4. `docs/truth/README.md`
5. `docs/truth/CODEX_PROCESS_TRUTH.md`
6. `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json`

# Required Outcome

- Parent/child retry policy is single-attempt by default.
- PK14 retry prompt cannot trigger global train or recursive `make batch`.
- Failed PK14 must lead to this bounded repair prompt only.

# Hard-Red Stops

- Any need to touch app source.
- Any need to run the global train.
- Any requirement to mark PK14 as Green or complete.
- Any unsupported release/build/device/accessibility/performance/privacy claims.

# Rollback

- Do not apply broad rollback across unrelated files.
- If required, restore only files touched by this repair attempt.

STATUS: UNKNOWN
