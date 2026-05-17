#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path
import subprocess

OUT_DIR = Path("docs/governance/generated")
OUT = OUT_DIR / "canon_propagation_plan.md"

RULES = [
    ("Plan", "Time"),
    ("Hero Step Panel", "Start Here"),
    ("Mission Control", "Constellation Atlas"),
]

SCAN_ROOTS = [Path("docs"), Path("prompts"), Path("Sources"), Path("Native"), Path("scripts")]


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
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    lines = ["# Canon Propagation Plan", "", f"Generated: {git_commit_iso()}", ""]

    for old, new in RULES:
        lines += [f"## {old} → {new}", ""]
        found = False
        for root in SCAN_ROOTS:
            if not root.exists():
                continue
            for path in root.rglob("*"):
                if not path.is_file():
                    continue
                if path.suffix.lower() not in {".md", ".swift", ".json", ".py", ".yml", ".yaml", ".sh"}:
                    continue
                text = path.read_text(encoding="utf-8", errors="replace")
                if old in text:
                    found = True
                    lines.append(f"- {path.as_posix()}")
        if not found:
            lines.append("- No remaining references detected")
        lines.append("")

    OUT.write_text("\n".join(lines) + "\n")
    print(f"wrote {OUT}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
