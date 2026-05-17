#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

GENERATED = Path("docs/governance/generated")
OUT = GENERATED / "cleanup_action_plan.md"


def main() -> int:
    lineage_path = GENERATED / "train_lineage_graph.json"
    if not lineage_path.exists():
        print("missing train lineage graph")
        return 1

    lineage = json.loads(lineage_path.read_text())
    records = lineage.get("records", {})

    unresolved = []
    orphan = []

    for rec in records.values():
        state = rec.get("state")
        if state in {"NEEDS_RECONCILIATION", "COMPLETION_CLAIM_UNPROVEN"}:
            unresolved.append(rec)
        if rec.get("prompt_files") and not rec.get("commits"):
            orphan.append(rec)

    lines = [
        "# Governance Cleanup Action Plan",
        "",
        "## Unresolved Reconciliation Actions",
        "",
    ]

    for rec in unresolved[:50]:
        lines.append(f"- `{rec.get('train_id')}`: reconcile registry state, proof linkage, and implementation ownership")

    lines += ["", "## Orphan Prompt Actions", ""]

    for rec in orphan[:50]:
        lines.append(f"- `{rec.get('train_id')}`: determine whether prompt is historical, superseded, or missing lineage")

    OUT.write_text("\n".join(lines) + "\n")
    print(f"wrote {OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
