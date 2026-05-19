#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
PATH = ROOT / "docs" / "proof" / "AMB_PROOF_RECEIPT_SYSTEM_SPEC.md"
REQUIRED = [
    "why this",
    "why now",
    "source facts",
    "source freshness",
    "what changed",
    "what was not chosen",
    "replayability",
    "reversibility",
    "proof contract requirements",
]


def main() -> int:
    if not PATH.exists():
        print("RED")
        print(f"missing file: {PATH}")
        return 1
    text = PATH.read_text(encoding="utf-8").lower()
    missing = [key for key in REQUIRED if key not in text]
    if missing:
        print("RED")
        print(f"missing fields: {', '.join(missing)}")
        return 1

    for banned in ["raw model confidence", "fixture-only proof", "hidden mutation"]:
        if banned in text and "no" not in text:
            continue
    print("GREEN")
    return 0


if __name__ == "__main__":
    import sys
    sys.exit(main())
