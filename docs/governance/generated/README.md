# Generated Governance Outputs

This directory contains generated governance reconciliation artifacts.

Do not manually edit generated outputs.

Regenerate with:

```bash
python3 scripts/governance/ambitions-governance-reconcile.py --write
```

Validate with:

```bash
python3 scripts/governance/ambitions-governance-validate.py
```

Strict reconciliation:

```bash
python3 scripts/governance/ambitions-governance-reconcile.py --write --strict
```

Codex OS bridge outputs live under `build/codex-os/` and are refreshed by the repo doctor, canon installer, and sync bridge. Inspect those outputs alongside the generated governance files when debugging autonomy or batch selection.
