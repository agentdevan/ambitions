<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-AOM-05 — Trust Inspection Route Cleanup

Work directly on `main`.

Objective: make Proof, Source, Privacy, History, and Receipts inspectable trust details instead of root or first-viewport clutter.

Scope:

- Move trust details behind contextual inspection paths.
- Keep Why this, proof, source, receipt, privacy, and history available where useful.
- Reduce internal language on root surfaces.
- Preserve accessibility labels and semantic meaning.

Allowed owners:

```text
Native/Ambitions/App/
Native/Ambitions/Features/Today/
Native/Ambitions/Features/Goals/
Native/Ambitions/Features/Time/
Native/Ambitions/Features/You/
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

Final report: Status, trust routes, root language changes, accessibility notes, validation, risks, rollback.
