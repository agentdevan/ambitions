<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-AOM-08 — Today Reconstruction

Work directly on `main`.

Objective: reconstruct Today as Reality Meridian + Start Here, not a static timeline or CTA stack.

Scope:

- Current time must be live and trustworthy.
- Start Here must expose one recommended Step or a clear no-step state.
- Today must visibly mutate after meaningful actions.
- Closure/recovery states must be simple and non-shaming.
- Source/proof/receipt language must move behind inspection where possible.
- Preserve Dynamic Type, VoiceOver, Reduce Motion, and safe-area behavior.

Allowed owners:

```text
Native/Ambitions/Features/Today/
Native/Ambitions/App/
Native/Ambitions/Stage/
Native/Ambitions/Projection/
Sources/
Native/AmbitionsTests/Today/
Native/AmbitionsUITests/
artifacts/object-stage-mega-train/
```

Validation:

```bash
git diff --check
python3 scripts/ambitions_validate_authority_drift.py
```

Build or record not-run reason. Capture screenshots if practical.

Final report: Status, live time behavior, Start Here behavior, mutation behavior, accessibility notes, validation, risks, rollback.
