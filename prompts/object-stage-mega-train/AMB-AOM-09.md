<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-AOM-09 — Goals Reconstruction

Work directly on `main`.

Objective: reconstruct Goals as Constellation Atlas.

Scope:

- Life Areas are clear and actionable.
- Goal Threads can open and connect to Today.
- Root Goals is not a KPI dashboard or generic goals list.
- Inspection details remain available without dominating the first viewport.
- Preserve accessibility and Dynamic Type.

Allowed owners:

```text
Native/Ambitions/Features/Goals/
Native/Ambitions/App/
Native/Ambitions/Stage/
Native/Ambitions/Projection/
Sources/
Native/AmbitionsTests/Goals/
Native/AmbitionsUITests/
artifacts/object-stage-mega-train/
```

Validation:

```bash
git diff --check
python3 scripts/ambitions_validate_authority_drift.py
```

Build or record not-run reason. Capture screenshots if practical.

Final report: Status, files changed, Goals behavior, accessibility notes, validation, risks, rollback.
