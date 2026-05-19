#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
PATH = ROOT / "docs" / "trust" / "AMB_LOCAL_FIRST_TRUST_SPEC.md"
REQUIRED = [
    "core loop is local-first",
    "no required custom server dependency",
    "no required ambitions account",
    "no required cloud ai dependency",
    "no analytics sdk",
    "offline",
    "export",
    "delete/reset",
    "local memory controls",
    "privacy redaction",
    "network dependency",
    "third-party dependency",
]


def main() -> int:
    if not PATH.exists():
        print("RED")
        print(f"missing file: {PATH}")
        return 1

    text = PATH.read_text(encoding="utf-8").lower()
    missing = [r for r in REQUIRED if r not in text]
    if missing:
        print("RED")
        print(f"missing trust fields: {', '.join(missing)}")
        return 1

    print("GREEN")
    return 0


if __name__ == "__main__":
    import sys
    sys.exit(main())
