#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

LIMITS = {
    "unresolved_reconciliation": 0,
    "orphan_prompts": 0,
}


def main() -> int:
    summary_path = Path("docs/governance/generated/governance_reconciliation_summary.json")
    lineage_path = Path("docs/governance/generated/train_lineage_graph.json")

    if not summary_path.exists() or not lineage_path.exists():
        print("missing generated governance artifacts")
        return 1

    summary = json.loads(summary_path.read_text())
    lineage = json.loads(lineage_path.read_text())

    unresolved = summary.get("needs_reconciliation_count", 0)
    records = lineage.get("records", {})
    orphan_prompts = sum(1 for r in records.values() if r.get("prompt_files") and not r.get("commits"))

    failures = []

    if unresolved > LIMITS["unresolved_reconciliation"]:
        failures.append(f"unresolved reconciliation count exceeded: {unresolved}")

    if orphan_prompts > LIMITS["orphan_prompts"]:
        failures.append(f"orphan prompt count exceeded: {orphan_prompts}")

    if failures:
        print("Sprawl budget failures:")
        for f in failures:
            print(f"- {f}")
        return 1

    print("Sprawl budget passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
