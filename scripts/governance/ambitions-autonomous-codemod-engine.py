#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

OUT = Path("docs/governance/generated/autonomous_codemod_plan.md")
RULES = [
    ("Plan", "Time"),
    ("Hero Step Panel", "Start Here"),
]
ROOTS = [Path("docs"), Path("prompts"), Path("Sources"), Path("Native")]


def main() -> int:
    lines = ["# Autonomous Codemod Plan", ""]

    for old, new in RULES:
        lines += [f"## {old} -> {new}", ""]
        for root in ROOTS:
            if not root.exists():
                continue
            for path in root.rglob("*"):
                if not path.is_file():
                    continue
                if path.suffix.lower() not in {".md", ".swift", ".json", ".py"}:
                    continue
                text = path.read_text(encoding="utf-8", errors="replace")
                if old in text:
                    lines.append(f"- rewrite candidate: {path.as_posix()}")
        lines.append("")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(lines) + "\n")
    print(f"wrote {OUT}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
