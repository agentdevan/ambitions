<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-AOM-11 — You Reconstruction

Work directly on `main`.

Objective: reconstruct You as User System Profile with native settings quality.

Scope:

- You starts from the user and system profile, not an internal runtime console.
- Settings groups are clear, native, and concise.
- Account, privacy, appearance, notifications, learning, receipts/history, export, and support controls are organized cleanly.
- Avoid social profile, admin panel, AI settings wall, or verbose documentation UI.
- Preserve accessibility and Dynamic Type.

Allowed owners:

```text
Native/Ambitions/Features/You/
Native/Ambitions/App/
Native/Ambitions/Stage/
Native/Ambitions/Projection/
Sources/
Native/AmbitionsTests/You/
Native/AmbitionsUITests/
artifacts/object-stage-mega-train/
```

Validation:

```bash
git diff --check
python3 scripts/ambitions_validate_authority_drift.py
```

Build or record not-run reason. Capture screenshots if practical.

Final report: Status, files changed, You behavior, accessibility notes, validation, risks, rollback.
