#!/usr/bin/env python3
"""Fail production Swift that exposes inert buttons or empty action closures."""

from __future__ import annotations

import argparse
from pathlib import Path
import re
import sys

DEFAULT_ROOT = Path(__file__).resolve().parents[1]
EXCLUDED_PARTS = {".git", ".build", "DerivedData", "artifacts", "build", "__pycache__"}
EXCLUDED_PATH_FRAGMENTS = ("Preview", "Previews", "Tests", "UITests")
PATTERNS = (
    re.compile(r"Button\s*\(\s*action:\s*\{\s*\}\s*\)"),
    re.compile(r"Button\s*\{\s*\}\s*label\s*:", re.MULTILINE),
    re.compile(r"Button\s*\([^\)]*\)\s*\{\s*\}", re.MULTILINE),
)


def should_scan(path: Path, root: Path) -> bool:
    rel = path.relative_to(root).as_posix()
    if path.suffix != ".swift":
        return False
    if any(part in EXCLUDED_PARTS for part in path.parts):
        return False
    if any(fragment in rel for fragment in EXCLUDED_PATH_FRAGMENTS):
        return False
    return rel.startswith(("Native/Ambitions/", "Sources/", "AppUI/"))


def main() -> int:
    parser = argparse.ArgumentParser(description="Find inert production buttons in Ambitions Swift files.")
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT)
    args = parser.parse_args()
    root = args.root.resolve()

    failures: list[str] = []
    for path in sorted(root.rglob("*.swift")):
        if not should_scan(path, root):
            continue
        text = path.read_text(encoding="utf-8")
        rel = path.relative_to(root).as_posix()
        for pattern in PATTERNS:
            for match in pattern.finditer(text):
                line = text.count("\n", 0, match.start()) + 1
                failures.append(f"{rel}:{line}: empty production button action")

    if failures:
        print("Empty action lint failed:", file=sys.stderr)
        for failure in failures:
            print(f"- {failure}", file=sys.stderr)
        return 1
    print("Empty action lint passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
