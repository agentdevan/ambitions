# Run Ambitions Implementation Reconciliation

## Purpose

Runs the autonomous local governance reconciliation scanner.

This scanner performs real repo traversal against:
- prompts
- registry state
- commit history
- implementation files
- proof artifacts
- audits/reports/tests
- stale overlays
- generated operational projections

---

# Run

From repo root:

```bash
python3 scripts/governance/ambitions-governance-reconcile.py --write
```

Strict mode:

```bash
python3 scripts/governance/ambitions-governance-reconcile.py --write --strict
```

---

# Generated Outputs

Generated under:

```text
/docs/governance/generated/
```

Outputs include:

- train_lineage_graph.json
- proof_linkage_graph.json
- train_to_implementation_map.json
- registry_projection.md
- orphan_prompt_audit.md
- stale_overlay_audit.md
- governance_reconciliation_summary.json

---

# Current Capabilities

The reconciler currently:

- traverses repo text files
- extracts train IDs
- scans prompt lineage
- scans registry references
- scans git history
- maps commit lineage
- maps implementation ownership
- maps proof artifacts
- detects stale overlays
- generates normalized governance projections

---

# Strict Mode

Strict mode fails when unresolved governance states remain.

Examples:
- conflicting registry posture
- completion without proof linkage
- unresolved reconciliation states

---

# Governance Goal

The reconciler is the transition point from:
- append-only operational governance

to:
- deterministic governance control plane.
