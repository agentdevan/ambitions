#!/usr/bin/env python3
"""Extract historical sections from legacy registry into archive files."""
from __future__ import annotations

from pathlib import Path
import re

SOURCE = Path("docs/codex/BATCH_REGISTRY.md")
OUT = Path("docs/archive/generated")

HISTORICAL_PATTERNS = [
    re.compile(r"Ambitions 2\\.0", re.I),
    re.compile(r"historical", re.I),
    re.compile(r"superseded", re.I),
]


def main() -> int:
    if not SOURCE.exists():
        print("missing registry")
        return 1

    OUT.mkdir(parents=True, exist_ok=True)
    text = SOURCE.read_text(encoding="utf-8", errors="replace")

    extracted = []
    for line in text.splitlines():
        if any(p.search(line) for p in HISTORICAL_PATTERNS):
            extracted.append(line)

    out = OUT / "historical-registry-extract.md"
    out.write_text("# Extracted Historical Registry References\n\n" + "\n".join(extracted) + "\n")

    print(f"wrote {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
