<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-AOM-01 — Root IA Refactor and AppTab Cleanup

Work directly on `main`.

Objective: make the root app model match the current four-surface law.

Active root surfaces:

```text
Today / Goals / Time / You
```

Scope:

- Refactor `AppTab` / root surface model to four persistent surfaces.
- Remove Motion as a root destination.
- Remove Capture as a root destination.
- Preserve safe compatibility mapping for older Motion/Capture external routes.
- Update shell routing, root dock, app intent copy, and root IA tests.

Allowed owners:

```text
Native/Ambitions/App/
Native/Ambitions/AppIntents/
Native/Ambitions/Domain/ScreenContractModels.swift
Native/AmbitionsTests/App/
Native/AmbitionsUITests/
scripts/*ia* scripts/*authority* scripts/*boundary*
artifacts/object-stage-mega-train/
```

Validation:

```bash
git diff --check
python3 scripts/ambitions_validate_authority_drift.py
python3 scripts/codex/amb-master-canon-ia-validate.py
python3 scripts/ambitions-local-first-boundary-scan.py
```

Build or record not-run reason.

Final report: Status, root surfaces, compatibility routes, validation, tests, risks, rollback.
