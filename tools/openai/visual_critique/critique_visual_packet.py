#!/usr/bin/env python3
"""Local visual packet critique scaffold."""
from __future__ import annotations

import argparse
import json
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate visual review packet inputs")
    parser.add_argument("--rubric", required=True, help="Rubric JSON path")
    parser.add_argument("screenshots", nargs="*", default=[], help="Screenshot paths to validate")
    parser.add_argument("--dry-run", action="store_true", help="Local-only print mode")
    args = parser.parse_args()

    rubric_path = Path(args.rubric)
    if not rubric_path.exists():
        print(f"Missing rubric: {rubric_path}")
        return 1

    rubric = json.loads(rubric_path.read_text(encoding="utf-8"))
    dimensions = rubric.get("dimensions", [])

    missing = [str(Path(path)) for path in args.screenshots if not Path(path).exists()]
    missing_count = len(missing)

    result = {
        "rubric": str(rubric_path),
        "dimensions": dimensions,
        "screenshot_count": len(args.screenshots),
        "missing_screenshots": missing,
        "upload": False,
        "status": "yellow" if missing_count else "green",
    }

    print("Rubric dimensions:")
    for dimension in dimensions:
        print(f"- {dimension}")

    if args.screenshots:
        for path in args.screenshots:
            if Path(path) in (Path(p) for p in missing):
                print(f"MISSING_SCREENSHOT: {path}")
            elif args.dry_run:
                print(f"OK_SCREENSHOT: {path}")

    if missing_count:
        print("YELLOW: one or more screenshots missing")
        return 1

    print("PASS: local visual packet structure is valid")
    print(json.dumps(result, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
