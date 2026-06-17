<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-AOM-00 — Source Map

Work directly on `main`.

Read `docs/truth/PRODUCT_DESIGN_TRUTH.md`, `AGENTS.md`, and `docs/truth/IMPLEMENTATION_TRUTH.md`.

Create these artifacts:

- `artifacts/object-stage-mega-train/AOM-00-source-map.md`
- `artifacts/object-stage-mega-train/AOM-00-risk-register.md`
- `artifacts/object-stage-mega-train/AOM-00-validation-plan.md`

Map root IA, Capture, Motion, trust inspection, surface UI, tests, validators, and SwiftData touchpoints before source edits.

Validation:

```bash
git diff --check
python3 scripts/ambitions_validate_authority_drift.py
python3 scripts/codex/amb-master-canon-ia-validate.py
python3 scripts/ambitions-local-first-boundary-scan.py
```

Final report: Status, files changed, artifacts, validation run, validation not run, risks, rollback.
