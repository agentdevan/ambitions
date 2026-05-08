#!/usr/bin/env python3
"""ACX Build Triage: classify saved build/test logs without claiming success."""

from __future__ import annotations

import argparse
import re
from pathlib import Path
from typing import Sequence

ROOT = Path(__file__).resolve().parents[2]
PATTERNS = {
    "swift_compile_error": [r"\.swift:\d+", r"\berror:"],
    "swift_warning": [r"\bwarning:"],
    "build_failed": [r"BUILD FAILED"],
    "test_failed": [r"TEST FAILED", r"XCTest", r"failed test"],
    "xcodegen_drift": [r"xcodegen", r"project.yml", r"generated project"],
    "simulator_destination": [r"destination", r"simulator", r"Unable to find a destination"],
    "dependency_resolution": [r"Package.resolved", r"dependency", r"resolve package"],
}


def safe_path(raw: str) -> Path | None:
    target = (ROOT / raw).resolve()
    try:
        target.relative_to(ROOT)
    except ValueError:
        return None
    return target


def classify(text: str) -> dict[str, list[str]]:
    out: dict[str, list[str]] = {}
    for name, patterns in PATTERNS.items():
        hits: list[str] = []
        for line in text.splitlines():
            if any(re.search(pattern, line, flags=re.IGNORECASE) for pattern in patterns):
                hits.append(line.strip())
        if hits:
            out[name] = hits[:30]
    return out


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Classify saved build/test logs without running build/test.")
    parser.add_argument("log", help="Path to saved log inside repo.")
    args = parser.parse_args(argv)
    path = safe_path(args.log)
    if path is None or not path.is_file():
        print("Red: log file unavailable or outside repo root.")
        return 2
    text = path.read_text(encoding="utf-8", errors="replace")
    findings = classify(text)
    print("# ACX Build Triage")
    print(f"- Source: `{path.relative_to(ROOT)}`")
    if not findings:
        print("- No configured build/test failure patterns found.")
        print("- This does not prove build or test success.")
        return 0
    for name, hits in findings.items():
        print(f"\n## {name}")
        for hit in hits:
            print(f"- {hit[:220]}")
    print("\nClaims not made: build pass, test pass, device proof, release readiness.")
    return 1 if any(name in findings for name in ["build_failed", "test_failed", "swift_compile_error"]) else 0


if __name__ == "__main__":
    raise SystemExit(main())
