#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

OUT = Path("docs/governance/generated/prompt_rewrite_plan.md")
ROOT = Path("prompts")
RULES = [
    ("Plan", "Time"),
    ("Hero Step Panel", "Start Here"),
]


def main() -> int:
    lines = ["# Prompt Rewrite Plan", ""]

    if ROOT.exists():
        for path in ROOT.rglob("*.md"):
            text = path.read_text(encoding="utf-8", errors="replace")
            rewrites = []
            for old, new in RULES:
                if old in text:
                    rewrites.append(f"{old} -> {new}")
            if rewrites:
                lines.append(f"- {path.as_posix()}: {', '.join(rewrites)}")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(lines) + "\n")
    print(f"wrote {OUT}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
