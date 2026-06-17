<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-AOM-03 — Motion Demotion to Behavior

Work directly on `main`.

Objective: make Motion a behavior layer instead of root navigation.

Scope:

- Root shell has no Motion destination.
- Motion-related source becomes Stage/Motion behavior or trust inspection support.
- Tests validate Motion is not a root surface.
- Old Motion routes fall back safely.

Allowed owners:

```text
Native/Ambitions/App/
Native/Ambitions/Features/Motion/
Native/Ambitions/Stage/
Native/Ambitions/Projection/
Sources/
Native/AmbitionsTests/
artifacts/object-stage-mega-train/
```

Validation:

```bash
git diff --check
python3 scripts/ambitions_validate_authority_drift.py
python3 scripts/codex/amb-master-canon-ia-validate.py
```

Build or record not-run reason.

Final report: Status, Motion root status, behavior owners, compatibility routes, validation, risks, rollback.
