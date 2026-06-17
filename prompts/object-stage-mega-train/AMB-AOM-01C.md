<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-AOM-01C — Root IA Tests and Stale Motion Assertions

Work directly on `main`.

Objective: update tests and validators so they enforce the four root surfaces and no longer require Motion or Capture as root destinations.

Scope:

- Update root IA tests and UI tests that assert Motion/Capture root tab behavior.
- Preserve useful Motion test material by marking it for Stage/Motion behavior migration or trust inspection tests later.
- Update scripts only when they still validate stale root IA.
- Do not perform full Motion source demotion here; that belongs to AOM-03.

Allowed owners are defined by the Train V3 manifest.

Validation:

```bash
git diff --check
python3 scripts/ambitions_validate_authority_drift.py
python3 scripts/codex/amb-master-canon-ia-validate.py
```

Build if enabled by the runner.

Final report: Status, files changed, migrated tests, stale test debt, validation, risks, rollback.
