#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
PATH = ROOT / "docs" / "runtime" / "AMB_PRIVATE_LIFE_RUNTIME_SPEC.md"


def main() -> int:
    if not PATH.exists():
        print("RED")
        print(f"missing file: {PATH}")
        return 1

    text = PATH.read_text(encoding="utf-8").lower()
    required_phrases = [
        "private life runtime",
        "start here",
        "decision truth",
        "source freshness",
        "closure engine",
        "constraintfirewall",
        "runtimecritic",
    ]
    for phrase in required_phrases:
        if phrase not in text:
            print("RED")
            print(f"missing ownership phrase: {phrase}")
            return 1

    forbidden = [
        r"ui.*owns.*start here",
        r"frontend.*owns.*decision",
        r"frontend.*owns.*start here",
        r"ui.*computes.*ranking",
    ]
    for pattern in forbidden:
        if re.search(pattern, text):
            print("RED")
            print(f"forbidden ownership phrase: {pattern}")
            return 1

    print("GREEN")
    return 0


if __name__ == "__main__":
    import sys
    sys.exit(main())
