#!/usr/bin/env python3
"""Conservative scanner for unsupported Ambitions completion claims.

The scanner is intentionally advisory. It flags high-risk wording only when the
same file does not also contain explicit no-claim/deferred language.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_PATHS = [ROOT / "docs", ROOT / "prompts", ROOT / ".codex"]

CLAIM_PATTERNS = [
    re.compile(r"visual\s+(canon|moat).{0,40}(implemented|complete|installed)", re.I),
    re.compile(r"runtime\s+ui.{0,40}(complete|installed)", re.I),
    re.compile(r"global\s+(train|queue).{0,40}complete", re.I),
    re.compile(r"all\s+batches.{0,40}complete", re.I),
    re.compile(r"release.{0,20}ready", re.I),
    re.compile(r"store.{0,20}ready", re.I),
    re.compile(r"public\s+accessibility.{0,40}(verified|complete|compliant)", re.I),
]

ALLOW_PATTERNS = [
    re.compile(r"not\s+(implemented|complete|installed|claimed)", re.I),
    re.compile(r"no\s+claim", re.I),
    re.compile(r"claims\s+not\s+made", re.I),
    re.compile(r"do\s+not\s+claim", re.I),
    re.compile(r"does\s+not\s+claim", re.I),
    re.compile(r"deferred", re.I),
    re.compile(r"proof\s+required", re.I),
    re.compile(r"docs/control-plane\s+only", re.I),
]

EXTENSIONS = {".md", ".txt", ".json", ".yml", ".yaml"}


def iter_files(paths: list[Path]):
    for path in paths:
        if path.is_file() and path.suffix in EXTENSIONS:
            yield path
        elif path.is_dir():
            for child in path.rglob("*"):
                if child.is_file() and child.suffix in EXTENSIONS:
                    yield child


def main(argv: list[str]) -> int:
    paths = [ROOT / arg for arg in argv] if argv else DEFAULT_PATHS
    failures: list[str] = []

    for path in iter_files(paths):
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        if any(pattern.search(text) for pattern in CLAIM_PATTERNS) and not any(pattern.search(text) for pattern in ALLOW_PATTERNS):
            failures.append(str(path.relative_to(ROOT)))

    if failures:
        print("RED: possible unsupported completion/readiness claims")
        for failure in sorted(failures):
            print(f"- {failure}")
        return 1

    print("GREEN: unsupported completion/readiness claim scan passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
