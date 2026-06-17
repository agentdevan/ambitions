<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-AOM-12 — Final Validation and Truth Update

Work directly on `main`.

Objective: close the Object-Stage Mega Train with tests, validators, proof artifacts, and implementation truth update.

Scope:

- Update root IA tests and validator scripts.
- Run authority, boundary, build, and focused navigation validation.
- Capture screenshots when practical.
- Update `docs/truth/IMPLEMENTATION_TRUTH.md` only after source proof exists.
- Produce final validation report.

Allowed owners:

```text
Native/AmbitionsTests/
Native/AmbitionsUITests/
scripts/
docs/truth/IMPLEMENTATION_TRUTH.md
artifacts/object-stage-mega-train/
```

Validation:

```bash
git diff --check
python3 scripts/ambitions_validate_authority_drift.py
python3 scripts/codex/amb-master-canon-ia-validate.py
python3 scripts/ambitions-local-first-boundary-scan.py
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -resolvePackageDependencies
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build
```

Required artifact:

```text
artifacts/object-stage-mega-train/AOM-12-final-validation-report.md
```

Final report: Status, baseline SHA, final SHA, files changed, root surfaces, Capture composer, Motion behavior, screenshots, build result, tests result, risks, rollback.
