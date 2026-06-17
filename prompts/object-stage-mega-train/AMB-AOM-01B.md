<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-AOM-01B — Root Shell Routing and Compatibility Fallbacks

Work directly on `main`.

Objective: make root shell routing use the four root surfaces while preserving safe compatibility for old Motion/Capture entry points.

Scope:

- Update root shell routing and selection logic.
- Route legacy Motion root requests to a safe Today/You/trust fallback, not a root tab.
- Route legacy Capture root requests to the global composer path when available or a safe fallback.
- Update AppIntent/deep-link routing only where necessary.
- Do not rebuild visual shell design in this batch.

Allowed owners are defined by the Train V3 manifest.

Validation:

```bash
git diff --check
python3 scripts/ambitions_validate_authority_drift.py
python3 scripts/codex/amb-master-canon-ia-validate.py
```

Build if enabled by the runner.

Final report: Status, files changed, root routing behavior, compatibility fallbacks, validation, risks, rollback.
