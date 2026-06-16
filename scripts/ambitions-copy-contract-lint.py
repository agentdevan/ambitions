#!/usr/bin/env python3
"""First-viewport copy contract lint for Ambitions.

The top-level app surfaces may preserve inspectability, but they must not lead with
implementation nouns. This lint scans production Swift for release-red wording that
belongs only in inspection, tests, or proof artifacts.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path
import re
import sys

DEFAULT_ROOT = Path(__file__).resolve().parents[1]
SCAN_PREFIXES = ("Native/Ambitions/", "Sources/")
EXCLUDED_PARTS = {".git", ".build", "DerivedData", "artifacts", "build", "__pycache__"}

@dataclass(frozen=True)
class BannedCopy:
    label: str
    pattern: re.Pattern[str]
    allowed_when_path_contains: tuple[str, ...] = ()

BANNED_COPY = (
    BannedCopy("receipt seam", re.compile(r'"[^"]*receipt seam[^"]*"', re.IGNORECASE)),
    BannedCopy("route reveal", re.compile(r'"[^"]*route reveal[^"]*"', re.IGNORECASE)),
    BannedCopy("replay trace", re.compile(r'"[^"]*replay trace[^"]*"', re.IGNORECASE)),
    BannedCopy("runtime-backed", re.compile(r'"[^"]*runtime-backed[^"]*"', re.IGNORECASE)),
    BannedCopy("fixture-only", re.compile(r'"[^"]*fixture-only[^"]*"', re.IGNORECASE)),
    BannedCopy("blocked-pending-model", re.compile(r'"[^"]*blocked-pending-model[^"]*"', re.IGNORECASE)),
    BannedCopy("not root navigation", re.compile(r'"[^"]*not root navigation[^"]*"', re.IGNORECASE)),
    BannedCopy("no silent changes", re.compile(r'"[^"]*no silent changes[^"]*"', re.IGNORECASE)),
)


def should_scan(path: Path, root: Path) -> bool:
    rel = path.relative_to(root).as_posix()
    if path.suffix != ".swift":
        return False
    if any(part in EXCLUDED_PARTS for part in path.parts):
        return False
    return rel.startswith(SCAN_PREFIXES)


def main() -> int:
    parser = argparse.ArgumentParser(description="Lint Ambitions first-viewport product copy.")
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT)
    args = parser.parse_args()
    root = args.root.resolve()

    failures: list[str] = []
    for path in sorted(root.rglob("*.swift")):
        if not should_scan(path, root):
            continue
        rel = path.relative_to(root).as_posix()
        text = path.read_text(encoding="utf-8")
        for banned in BANNED_COPY:
            if any(fragment in rel for fragment in banned.allowed_when_path_contains):
                continue
            for match in banned.pattern.finditer(text):
                line = text.count("\n", 0, match.start()) + 1
                failures.append(f"{rel}:{line}: banned user-facing copy `{banned.label}`")

    if failures:
        print("Copy contract lint failed:", file=sys.stderr)
        for failure in failures:
            print(f"- {failure}", file=sys.stderr)
        return 1
    print("Copy contract lint passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
