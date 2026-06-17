<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-AOM-10 — Time Reconstruction

Work directly on `main`.

Objective: reconstruct Time as LifeShape Field.

Scope:

- Time shows capacity, pressure, protected windows, fixed points, and horizons as a coherent field.
- Time is not a calendar clone, agenda clone, free/busy grid, or productivity score surface.
- Reflow and shaping controls preserve confirmation and user control.
- Inspection details remain available without dominating the first viewport.
- Preserve accessibility and Dynamic Type.

Allowed owners:

```text
Native/Ambitions/Features/Time/
Native/Ambitions/App/
Native/Ambitions/Stage/
Native/Ambitions/Projection/
Sources/
Native/AmbitionsTests/Time/
Native/AmbitionsUITests/
artifacts/object-stage-mega-train/
```

Validation:

```bash
git diff --check
python3 scripts/ambitions_validate_authority_drift.py
```

Build or record not-run reason. Capture screenshots if practical.

Final report: Status, files changed, Time behavior, accessibility notes, validation, risks, rollback.
