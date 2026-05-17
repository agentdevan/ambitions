#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import sys

REQUIRED = [
    Path("docs/governance/generated/registry_projection.md"),
    Path("docs/governance/generated/governance_reconciliation_summary.json"),
    Path("docs/governance/generated/orphan_prompt_audit.md"),
    Path("docs/governance/generated/stale_overlay_audit.md"),
]


def main() -> int:
    missing = [p.as_posix() for p in REQUIRED if not p.exists()]
    if missing:
        print("Batch closeout validation failed:")
        for m in missing:
            print(f"- missing {m}")
        return 1

    print("Batch closeout governance validation passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
