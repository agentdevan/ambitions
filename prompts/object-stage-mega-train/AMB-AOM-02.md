<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-AOM-02 — Stage Spine and Motion Behavior

Work directly on `main`.

Objective: install or adapt the Stage spine and Motion behavior layer.

Required product shape:

```text
Root surfaces: Today / Goals / Time / You
Global composer: Capture
Motion: behavior layer
Trust: inspection routes
```

Scope:

- Add or adapt Stage state, route, action, context, and overlay ownership.
- Add or adapt Stage/Motion event and reduced-motion behavior.
- Keep Motion out of root navigation.
- Extend existing owners where possible.

Allowed owners:

```text
Native/Ambitions/App/
Native/Ambitions/Stage/
Native/Ambitions/Projection/
Native/Ambitions/Domain/
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

Final report: Status, files changed, Stage owners, Motion behavior, validation, risks, rollback.
