#!/usr/bin/env python3
"""Release-red regression guard for Ambitions.

This guard protects the 2026 release recovery train from re-shipping the defects
captured in the manual app testing report. It is intentionally conservative:
first-viewport production Swift should not expose implementation vocabulary,
hardcoded Today time, fake Up Next rows, empty Motion actions, or debug-state labels.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path
import re
import sys

DEFAULT_ROOT = Path(__file__).resolve().parents[1]

EXCLUDED_PARTS = {
    ".git",
    ".build",
    "DerivedData",
    "artifacts",
    "build",
    "__pycache__",
}

SWIFT_PATH_PREFIXES = (
    "Native/Ambitions/",
    "Sources/",
    "AppUI/",
)

@dataclass(frozen=True)
class Check:
    name: str
    pattern: re.Pattern[str]
    reason: str

CHECKS: tuple[Check, ...] = (
    Check(
        "hardcoded_today_now_time",
        re.compile(r'"10:05 AM"'),
        "Today must derive current time from runtime/device state, never hardcode 10:05 AM.",
    ),
    Check(
        "fake_today_up_next_support_queue",
        re.compile(r'"Support queue"|"Team sync"|"Review deck"'),
        "Today must not ship fake fallback Up Next rows.",
    ),
    Check(
        "empty_motion_button_action",
        re.compile(r"Button\s*\(\s*action:\s*\{\s*\}\s*\)|Button\s*\(\s*[^\)]*\)\s*\{\s*\}\s*label:", re.MULTILINE),
        "Production UI must not expose inert buttons.",
    ),
    Check(
        "internal_capture_route_reveal",
        re.compile(r'"Route reveal"|"receipt before save"|"Local receipt\. No cloud route\."'),
        "Capture first-viewport copy must be user-facing, not route/receipt internals.",
    ),
    Check(
        "internal_time_not_root_navigation",
        re.compile(r'"Not root navigation"'),
        "Time must not expose implementation/navigation policy language.",
    ),
    Check(
        "internal_runtime_debug_labels",
        re.compile(r'"fixture-only"|"blocked-pending-model"|"runtime-backed local inspection"', re.IGNORECASE),
        "You and settings surfaces must not show internal/debug labels to users.",
    ),
    Check(
        "today_source_unavailable_first_viewport",
        re.compile(r'"Source unavailable\. Manual planning still works\."'),
        "Today first viewport must not open with undefined source-error language.",
    ),
)


def should_scan(path: Path, root: Path) -> bool:
    rel = path.relative_to(root).as_posix()
    if any(part in EXCLUDED_PARTS for part in path.parts):
        return False
    if path.suffix != ".swift":
        return False
    return rel.startswith(SWIFT_PATH_PREFIXES)


def scan(root: Path) -> list[str]:
    failures: list[str] = []
    for path in sorted(root.rglob("*.swift")):
        if not should_scan(path, root):
            continue
        text = path.read_text(encoding="utf-8")
        rel = path.relative_to(root).as_posix()
        for check in CHECKS:
            for match in check.pattern.finditer(text):
                line = text.count("\n", 0, match.start()) + 1
                failures.append(f"{rel}:{line}: {check.name}: {check.reason}")
    return failures


def main() -> int:
    parser = argparse.ArgumentParser(description="Guard against release-red UI regressions.")
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT)
    args = parser.parse_args()

    root = args.root.resolve()
    failures = scan(root)
    if failures:
        print("Release-red guard failed:", file=sys.stderr)
        for failure in failures:
            print(f"- {failure}", file=sys.stderr)
        return 1

    print("Release-red guard passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
