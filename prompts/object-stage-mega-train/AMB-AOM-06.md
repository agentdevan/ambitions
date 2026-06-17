<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-AOM-06 — SwiftData Schema Review

Work directly on `main`.

Objective: review whether the object-stage migration needs SwiftData schema changes. Apply only the minimum migration-safe expansion if required for compile or real runtime ownership.

Scope:

- Inspect SwiftData models, repositories, migration helpers, and tests.
- Prefer adapting existing models over new schema.
- Add schema only if required by Stage/Capture/Motion/trust runtime behavior.
- Add migration defaults and tests when schema changes.

Allowed owners:

```text
Native/Ambitions/Persistence/
Native/Ambitions/Domain/
Native/AmbitionsTests/Persistence/
Native/AmbitionsTests/Domain/
artifacts/object-stage-mega-train/
```

Validation:

```bash
git diff --check
python3 scripts/ambitions-local-first-boundary-scan.py
```

Build or record not-run reason. Run persistence tests if touched.

Final report: Status, schema changed yes/no, migration safety, tests, validation, risks, rollback.
