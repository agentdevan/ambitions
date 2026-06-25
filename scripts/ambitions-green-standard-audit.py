#!/usr/bin/env python3
"""Audit active source for root-level architecture-as-UI regressions."""

from __future__ import annotations

from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]

ACTIVE_SOURCE_ROOTS = [
    ROOT / "Native" / "Ambitions",
    ROOT / "Sources",
    ROOT / "Packages",
]

EXCLUDED_PATH_PARTS = {
    "Native/AmbitionsTests",
    "Native/AmbitionsUITests",
    "docs/quality",
    "docs/qa",
}

INSPECTION_ALLOWED_PARTS = {
    "Trust/",
    "Inspection",
    "WhyThis",
}

POLICY_DEFINITION_PARTS = {
    "ForbiddenTopLevelTerms.swift",
    "Language/",
}

DISALLOWED_ROOT_TERMS = {
    "Shell context crown": "describe the surface or object directly",
    "Motion Current": "Stage Motion behavior or the changed object",
    "Proof seam": "saved/history/review state",
    "route reveal": "placement preview",
    "route-reveal": "placement-preview",
    "Local source:": "Started from",
    "Open receipt": "History",
    "Re-enter thread": "Return",
}

PRIMARY_UI_FILES = (
    "Surface.swift",
    "ObjectView.swift",
    "AppShell",
    "StageMotion",
    "MotionCurrent",
    "Capture",
    "StageDock",
    "HeaderRail",
    "ContextCrown",
    "Flagship",
)


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT))


def is_excluded(path: Path) -> bool:
    relative = rel(path)
    return any(part in relative for part in EXCLUDED_PATH_PARTS)


def is_inspection_allowed(path: Path) -> bool:
    relative = rel(path)
    return any(part in relative for part in INSPECTION_ALLOWED_PARTS)


def is_policy_definition(path: Path) -> bool:
    relative = rel(path)
    return any(part in relative for part in POLICY_DEFINITION_PARTS)


def is_primary_ui_file(path: Path) -> bool:
    name = path.name
    relative = rel(path)
    return any(marker in name or marker in relative for marker in PRIMARY_UI_FILES)


def string_literals(line: str) -> list[str]:
    return re.findall(r'"([^"\\]*(?:\\.[^"\\]*)*)"', line)


def main() -> int:
    failures: list[str] = []
    for root in ACTIVE_SOURCE_ROOTS:
        if not root.exists():
            continue
        for path in sorted(root.rglob("*.swift")):
            if is_excluded(path):
                continue
            if is_policy_definition(path):
                continue
            if not is_primary_ui_file(path) and not is_inspection_allowed(path):
                continue
            text = path.read_text(encoding="utf-8")
            for line_number, line in enumerate(text.splitlines(), start=1):
                stripped = line.strip()
                if stripped.startswith("//"):
                    continue
                literals = " ".join(string_literals(line))
                if not literals:
                    continue
                for term, replacement in DISALLOWED_ROOT_TERMS.items():
                    if term.lower() not in literals.lower():
                        continue
                    if is_inspection_allowed(path) and term in {"Open receipt", "Local source:"}:
                        continue
                    failures.append(
                        f"{rel(path)}:{line_number}: `{term}` appears in active UI string; use {replacement}"
                    )

    print("# Ambitions Green Standard Audit")
    if failures:
        for failure in failures:
            print(f"RED: {failure}", file=sys.stderr)
        return 1

    print("GREEN: no disallowed architecture-as-UI strings found in active primary UI source")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
