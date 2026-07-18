#!/usr/bin/env python3
"""Compatibility entry point for canonical source-ownership validation.

The retired architecture-tree prose was not a machine-readable source inventory.
Active ownership is now checked by the canonical audit; this wrapper retains the
established JSON contract for callers while failing closed on that audit.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CANON_AUDIT = ROOT / "scripts" / "ambitions-canon.py"


def build_inventory(root: Path) -> dict[str, object]:
    completed = subprocess.run(
        [sys.executable, str(CANON_AUDIT), "audit"],
        cwd=root,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    detail = (completed.stderr or completed.stdout).strip()
    entries = [] if completed.returncode == 0 else [{
        "required_path": "docs/canon",
        "status": "canonical-audit-failed",
        "owner": "canon-governance",
        "current_file": "",
        "migration_action": "repair the active canonical audit failure",
        "risk": "high",
        "test_coverage": "scripts/ambitions-canon.py audit",
        "proof_status": detail,
        "build_included": True,
    }]
    return {
        "summary": {
            "canonical_required_files": 0,
            "entries": len(entries),
            "blocking_entries": len(entries),
            "counts": {"canonical-audit-failed": len(entries)} if entries else {"implemented": 0},
            "green": completed.returncode == 0,
        },
        "entries": entries,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Emit canonical architecture ownership validation.")
    parser.add_argument("--json", action="store_true", help="Emit JSON validation result.")
    parser.add_argument("--root", type=Path, default=ROOT, help="Repository root.")
    args = parser.parse_args()
    inventory = build_inventory(args.root.resolve())
    if args.json:
        print(json.dumps(inventory, sort_keys=True))
    else:
        summary = inventory["summary"]
        print("GREEN canonical source-ownership audit" if summary["green"] else "RED canonical source-ownership audit")
    return 0 if inventory["summary"]["green"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
