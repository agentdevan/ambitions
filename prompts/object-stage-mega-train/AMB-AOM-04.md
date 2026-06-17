<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-AOM-04 — Capture Global Composer

Work directly on `main`.

Objective: make Capture a global composer overlay instead of a root surface.

Scope:

- Capture opens through global/contextual entry points.
- Root navigation does not include Capture.
- Compatibility routes open the composer safely.
- Composer copy uses user language.
- Keyboard and close behavior remain stable.

Allowed owners:

```text
Native/Ambitions/App/
Native/Ambitions/Features/Capture/
Native/Ambitions/Stage/
Native/Ambitions/Projection/
Native/AmbitionsTests/
Native/AmbitionsUITests/
artifacts/object-stage-mega-train/
```

Validation:

```bash
git diff --check
python3 scripts/ambitions_validate_authority_drift.py
python3 scripts/codex/amb-master-canon-ia-validate.py
```

Build or record not-run reason.

Final report: Status, files changed, composer route, compatibility route, validation, risks, rollback.
