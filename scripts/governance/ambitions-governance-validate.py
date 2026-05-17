#!/usr/bin/env python3
"""Validate generated governance reconciliation state."""
from __future__ import annotations

import json
import sys
from pathlib import Path

REQUIRED_FILES = [
    "train_lineage_graph.json",
    "proof_linkage_graph.json",
    "train_to_implementation_map.json",
    "registry_projection.md",
    "orphan_prompt_audit.md",
    "stale_overlay_audit.md",
    "governance_reconciliation_summary.json",
]


def fail(msg: str) -> int:
    print(f"GOVERNANCE VALIDATION FAILED: {msg}", file=sys.stderr)
    return 1


def main() -> int:
    root = Path("docs/governance/generated")
    if not root.exists():
        return fail("generated governance directory missing")

    for name in REQUIRED_FILES:
        p = root / name
        if not p.exists():
            return fail(f"missing generated artifact: {name}")
        if p.stat().st_size == 0:
            return fail(f"empty generated artifact: {name}")

    summary = json.loads((root / "governance_reconciliation_summary.json").read_text())

    unresolved = summary.get("needs_reconciliation_count", 0)
    stale = summary.get("stale_overlay_count", 0)

    print("Ambitions governance validation")
    print(f"Unresolved reconciliation count: {unresolved}")
    print(f"Stale overlay count: {stale}")

    if unresolved > 0:
        return fail("unresolved reconciliation states remain")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
