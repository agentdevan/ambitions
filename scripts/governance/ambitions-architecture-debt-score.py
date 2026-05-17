#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

OUT = Path("docs/governance/generated/architecture_debt_score.json")


def count(patterns: list[str], roots: list[Path]) -> int:
    total = 0
    for root in roots:
        if not root.exists():
            continue
        for path in root.rglob("*.md"):
            text = path.read_text(encoding="utf-8", errors="replace")
            for p in patterns:
                total += text.count(p)
    return total


def main() -> int:
    debt = {
        "plan_language_residue": count(["Plan"], [Path("docs"), Path("prompts")]),
        "historical_markers": count(["historical", "superseded"], [Path("docs"), Path("prompts")]),
        "governance_scripts": len(list(Path("scripts/governance").glob("*.py"))) if Path("scripts/governance").exists() else 0,
    }

    score = max(0, 100 - debt["plan_language_residue"] - debt["historical_markers"])

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps({"score": score, "debt": debt}, indent=2) + "\n")
    print(f"wrote {OUT}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
