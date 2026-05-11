#!/usr/bin/env python3
"""Check required closeout-report sections for governance batches."""

from __future__ import annotations

import argparse
from pathlib import Path
import sys


REQUIRED_PHRASES = [
    "Status:",
    "Batch ID:",
    "Objective",
    "Files changed",
    "Queue evidence",
    "Remaining record count",
    "PK21",
    "Validation commands",
    "Defects found",
    "Defects repaired",
    "Defects deferred",
    "Claims not made",
    "Rollback",
    "Next eligible implementation batch",
]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("report")
    parser.add_argument("--strict", action="store_true")
    args = parser.parse_args()

    path = Path(args.report)
    if not path.exists():
        print(f"RED: missing report: {path}", file=sys.stderr)
        return 1

    text = path.read_text()
    missing = [phrase for phrase in REQUIRED_PHRASES if phrase not in text]
    print("# Final Report Gate")
    print(f"report: {path}")
    if missing:
        for phrase in missing:
            print(f"RED: missing required phrase: {phrase}", file=sys.stderr)
        return 1
    if args.strict and "Status: Red" in text:
        print("RED: strict report gate saw Red status", file=sys.stderr)
        return 1
    print("GREEN: final report contains required closeout fields")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
