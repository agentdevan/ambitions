<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-AOM-07 — Shell and Visual Foundation

Work directly on `main`.

Objective: rebuild the shared shell and visual foundation for the four-surface app.

Scope:

- Root shell supports Today, Goals, Time, and You.
- Bottom navigation has one coherent native treatment.
- Capture remains global/contextual.
- Materials, spacing, type, haptics, and motion policy use shared tokens.
- Reduce Motion and accessibility equivalents remain available.

Allowed owners:

```text
Native/Ambitions/App/
Native/Ambitions/UI/
Sources/
AppUI/
Native/AmbitionsTests/App/
Native/AmbitionsUITests/
artifacts/object-stage-mega-train/
```

Validation:

```bash
git diff --check
python3 scripts/ambitions_validate_authority_drift.py
```

Build or record not-run reason. Capture screenshots if practical.

Final report: Status, shell changes, nav state, Capture access, accessibility notes, validation, risks, rollback.
