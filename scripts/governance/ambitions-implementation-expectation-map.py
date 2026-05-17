#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path
import subprocess

OUT = Path("docs/governance/generated/implementation_expectation_map.json")
ROOTS = [Path("docs/canon"), Path("docs/governance")]
KEYS = [
    "Today", "Goals", "Capture", "Time", "You",
    "Reality Meridian", "Constellation Atlas", "Atmosphere Composer", "LifeShape Field",
    "Start Here"
]


def git_commit_iso() -> str:
    proc = subprocess.run(
        ["git", "show", "-s", "--format=%cI", "HEAD"],
        cwd=Path(__file__).resolve().parents[2],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    return proc.stdout.strip() or "unknown"


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
        "generated_at": git_commit_iso(),
        "expectations": expectations
    }, indent=2, sort_keys=True) + "\n")
    print(f"wrote {OUT}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
