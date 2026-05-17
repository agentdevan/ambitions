#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path
from datetime import datetime, timezone

OUT = Path("docs/governance/generated/implementation_expectation_map.json")
ROOTS = [Path("docs/canon"), Path("docs/governance")]
KEYS = [
    "Today", "Goals", "Capture", "Time", "You",
    "Reality Meridian", "Constellation Atlas", "Atmosphere Composer", "LifeShape Field",
    "Start Here"
]


def main() -> int:
    expectations = {}

    for root in ROOTS:
        if not root.exists():
            continue
        for path in root.rglob("*.md"):
            text = path.read_text(encoding="utf-8", errors="replace")
            hits = [k for k in KEYS if k in text]
            if hits:
                expectations[path.as_posix()] = hits

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps({
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "expectations": expectations
    }, indent=2, sort_keys=True) + "\n")
    print(f"wrote {OUT}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
