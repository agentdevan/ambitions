<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-AOM-01A — Root Surface Contract and AppTab Cleanup

Work directly on `main`.

Objective: make the root surface contract exactly `Today / Goals / Time / You`.

Scope:

- Update root surface enum/model ownership.
- Remove Motion and Capture from root surface collections.
- Keep legacy route compatibility compile-safe if references exist.
- Do not rewrite shell UI visuals here.
- Do not edit broad UI tests here except narrow compile/test contract updates.

Allowed owners are defined by the Train V3 manifest.

Validation:

```bash
git diff --check
python3 scripts/ambitions_validate_authority_drift.py
python3 scripts/codex/amb-master-canon-ia-validate.py
```

Build if enabled by the runner.

Final report: Status, files changed, root surface count, Motion root status, Capture root status, validation, risks, rollback.
