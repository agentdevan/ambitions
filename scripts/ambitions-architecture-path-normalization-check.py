#!/usr/bin/env python3
"""Check active architecture packets for stale repo path authority."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_GLOBS = (
    "docs/linear/reconciliation/2026-07-05-*.md",
    "docs/linear/reconciliation/2026-07-05-*.json",
)

STALE_PROJECT_PATTERNS = [
    re.compile(pattern)
    for pattern in [
        r"\bNative/project\.yml\b",
        r"\bNative/Package\.swift\b",
        r"\bNative/Ambitions/project\.yml\b",
        r"\bNative/Ambitions/Package\.swift\b",
    ]
]

FEATURES_PATTERNS = [
    re.compile(r"\bNative/Ambitions/Features\b"),
    re.compile(r"`Features/`"),
    re.compile(r"\bFeatures/\b"),
]

FEATURES_ALLOWED_CONTEXT = (
    "legacy",
    "migration debt",
    "not a canonical owner",
    "absent",
    "scaffolding",
    "fail",
    "forbidden",
    "stale",
    "must not",
    "do not",
)

STALE_PROJECT_ALLOWED_CONTEXT = (
    "fail",
    "forbidden",
    "stale",
    "must not",
    "do not",
)


def default_paths() -> list[Path]:
    paths: list[Path] = []
    for pattern in DEFAULT_GLOBS:
        paths.extend(ROOT.glob(pattern))
    return sorted(path for path in paths if path.is_file())


def input_paths(raw_paths: list[str]) -> list[Path]:
    if not raw_paths:
        return default_paths()
    paths: list[Path] = []
    for raw in raw_paths:
        path = (ROOT / raw).resolve()
        if path.is_file():
            paths.append(path)
    return paths


def relative(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def features_context_allowed(line: str) -> bool:
    lower = line.lower()
    return any(marker in lower for marker in FEATURES_ALLOWED_CONTEXT)


def stale_project_context_allowed(line: str) -> bool:
    lower = line.lower()
    return any(marker in lower for marker in STALE_PROJECT_ALLOWED_CONTEXT)


def scan_file(path: Path) -> list[str]:
    findings: list[str] = []
    text = path.read_text(encoding="utf-8", errors="replace")
    for number, line in enumerate(text.splitlines(), start=1):
        for pattern in STALE_PROJECT_PATTERNS:
            if pattern.search(line):
                if stale_project_context_allowed(line):
                    continue
                findings.append(
                    f"{relative(path)}:{number}: stale project/package path `{pattern.pattern}`"
                )
        if any(pattern.search(line) for pattern in FEATURES_PATTERNS):
            if not features_context_allowed(line):
                findings.append(
                    f"{relative(path)}:{number}: generic Features path without legacy/debt context"
                )
    return findings


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(
        description="Check active architecture packets for current repo path authority."
    )
    parser.add_argument("paths", nargs="*", help="Optional packet paths to scan.")
    args = parser.parse_args(argv)

    paths = input_paths(args.paths)
    findings: list[str] = []
    for path in paths:
        findings.extend(scan_file(path))

    if findings:
        print("ambitions-architecture-path-normalization-check RED")
        for finding in findings:
            print(f"- {finding}")
        return 1

    print("ambitions-architecture-path-normalization-check GREEN")
    print(f"architecture_packets_checked={len(paths)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
