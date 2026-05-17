#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

GENERATED = Path("docs/governance/generated")
OUT = GENERATED / "lineage_confidence_scores.json"


def score(record: dict) -> int:
    value = 0
    if record.get("prompt_files"):
        value += 20
    if record.get("commits"):
        value += 25
    if record.get("implementation_files"):
        value += 25
    if record.get("proof_files"):
        value += 15
    if record.get("audit_files"):
        value += 5
    if record.get("test_files"):
        value += 10
    return min(value, 100)


def main() -> int:
    lineage_path = GENERATED / "train_lineage_graph.json"
    if not lineage_path.exists():
        print("missing train lineage graph")
        return 1

    lineage = json.loads(lineage_path.read_text())
    records = lineage.get("records", {})

    out = {}
    for train_id, record in records.items():
        out[train_id] = {
            "score": score(record),
            "state": record.get("state"),
            "confidence": record.get("confidence"),
        }

    OUT.write_text(json.dumps(out, indent=2, sort_keys=True) + "\n")
    print(f"wrote {OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
