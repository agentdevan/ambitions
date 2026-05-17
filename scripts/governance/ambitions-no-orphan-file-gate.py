#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import sys

WATCH_DIRS = [
    Path("docs/governance"),
    Path("docs/canon"),
    Path("prompts"),
]

REQUIRED_MARKERS = [
    "Status:",
    "Owner:",
    "Authority Tier:",
]

ALLOWED_SUFFIXES = {".md", ".json", ".yaml", ".yml"}


def main() -> int:
    failures = []

    for root in WATCH_DIRS:
        if not root.exists():
            continue
        for path in root.rglob("*"):
            if not path.is_file() or path.suffix not in ALLOWED_SUFFIXES:
                continue
            if "/generated/" in path.as_posix() or "/archive/" in path.as_posix():
                continue

            text = path.read_text(encoding="utf-8", errors="replace")[:3000]
            missing = [m for m in REQUIRED_MARKERS if m not in text]
            if missing:
                failures.append((path.as_posix(), missing))

    if failures:
        print("Orphan governance file failures:")
        for path, missing in failures:
            print(f"- {path}: missing {', '.join(missing)}")
        return 1

    print("No orphan governance files detected")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
