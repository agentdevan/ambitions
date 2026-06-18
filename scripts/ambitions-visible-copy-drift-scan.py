#!/usr/bin/env python3
"""Ambitions visible-copy drift scanner.

Scans likely user-visible Swift copy and active frontend canon for stale product
language while intentionally ignoring historical/archive material and internal
compatibility identifiers.

This script is a local validation aid. It does not prove app behavior, build
success, release readiness, or accessibility conformance.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT_DEFAULT = Path(__file__).resolve().parents[1]

IGNORED_PARTS = {
    ".git",
    ".build",
    ".swiftpm",
    "DerivedData",
    "docs/archive",
    "docs/audits",
    "docs/handoff",
    "build/reports",
    "prompts",
}

DEFAULT_SCAN_PATHS = (
    "Native/Ambitions/App",
    "Native/Ambitions/Features/Capture",
    "Native/Ambitions/Features/Goals",
    "Native/Ambitions/Features/Motion",
    "Native/Ambitions/Features/Time",
    "Native/Ambitions/Features/Today",
    "Native/Ambitions/Features/You",
    "Sources/Accessibility",
    "Sources/Components",
    "AGENTS.md",
    "README.md",
    "docs/README.md",
)

TEXT_EXTENSIONS = {
    ".swift",
    ".md",
    ".yml",
    ".yaml",
    ".json",
}

# Patterns intentionally target visible/canonical copy rather than internal type
# names. Internal compatibility names such as PlanViewModel, AppTab.plan, or a
# folder named Features/Plan are handled by implementation ledgers, not this
# scanner.
PATTERNS: list[tuple[str, re.Pattern[str], str]] = [
    (
        "visible-plan-label",
        re.compile(r'\b(?:Text|Label|Button|navigationTitle|accessibilityLabel|accessibilityHint|String\()\s*\(\s*"[^"]*\bPlan\b[^"]*"'),
        "Likely user-visible Plan copy; current top-level destination is Time.",
    ),
    (
        "visible-profile-label",
        re.compile(r'\b(?:Text|Label|Button|navigationTitle|accessibilityLabel|accessibilityHint|String\()\s*\(\s*"[^"]*\bProfile\b[^"]*"'),
        "Likely user-visible Profile copy; current destination is You.",
    ),
    (
        "visible-captures-label",
        re.compile(r'\b(?:Text|Label|Button|navigationTitle|accessibilityLabel|accessibilityHint|String\()\s*\(\s*"[^"]*\bCaptures\b[^"]*"'),
        "Likely user-visible Captures copy; current destination is Capture.",
    ),
    (
        "deprecated-start-focus",
        re.compile(r'\b(?:Text|Label|Button|navigationTitle|accessibilityLabel|accessibilityHint|String\()\s*\(\s*"[^"]*\b(?:Start Focus|Begin Focus|Focus Session)\b[^"]*"', re.IGNORECASE),
        "Deprecated focus CTA/language. Prefer Start now/Open step where user-facing.",
    ),
    (
        "deprecated-next-move",
        re.compile(r'\b(?:Text|Label|Button|navigationTitle|accessibilityLabel|accessibilityHint|String\()\s*\(\s*"[^"]*\b(?:best next move|next best move|Your best next move|Recommended next step)\b[^"]*"', re.IGNORECASE),
        "Deprecated next-move wording. Prefer Start here / Recommended step.",
    ),
    (
        "punitive-copy",
        re.compile(r'\b(?:Text|Label|Button|navigationTitle|accessibilityLabel|accessibilityHint|String\()\s*\(\s*"[^"]*\b(?:streak broken|failed|missed|overdue)\b[^"]*"', re.IGNORECASE),
        "Potential punitive state language; verify closure/recovery framing.",
    ),
]

FRONTEND_DOC_PATTERNS: list[tuple[str, re.Pattern[str], str]] = [
    (
        "frontend-plan-tab",
        re.compile(r'\bPlan\b.*\b(?:top-level|tab|destination)\b|\b(?:top-level|tab|destination)\b.*\bPlan\b', re.IGNORECASE),
        "Active frontend docs should not restore Plan as a top-level destination.",
    ),
    (
        "frontend-deprecated-hero-step-panel",
        re.compile(r'\bHero Step Panel\b'),
        "Hero Step Panel is implementation alias only; user-facing language is Start here.",
    ),
    (
        "frontend-deprecated-day-timeline-rail",
        re.compile(r'\bDayTimelineRail\b'),
        "DayTimelineRail should be legacy/internal alias unless explicitly mapped to Reality Meridian.",
    ),
]


def ignored(path: Path, root: Path) -> bool:
    rel = path.relative_to(root).as_posix()
    return any(rel == ignored_part or rel.startswith(ignored_part + "/") for ignored_part in IGNORED_PARTS)


def iter_files(root: Path, broad: bool):
    if broad:
        candidates = root.rglob("*")
    else:
        bounded_candidates: list[Path] = []
        for rel_path in DEFAULT_SCAN_PATHS:
            path = root / rel_path
            if path.is_file():
                bounded_candidates.append(path)
            elif path.is_dir():
                bounded_candidates.extend(path.rglob("*"))
        candidates = iter(bounded_candidates)

    seen: set[Path] = set()
    for path in candidates:
        if path in seen:
            continue
        seen.add(path)
        if not path.is_file():
            continue
        if ignored(path, root):
            continue
        if path.suffix not in TEXT_EXTENSIONS:
            continue
        yield path


def scan_file(path: Path, root: Path) -> list[str]:
    rel = path.relative_to(root).as_posix()
    try:
        text = path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return []

    patterns = PATTERNS[:]
    if rel.startswith("frontend/"):
        patterns.extend(FRONTEND_DOC_PATTERNS)

    findings: list[str] = []
    for lineno, line in enumerate(text.splitlines(), start=1):
        for code, pattern, reason in patterns:
            if pattern.search(line):
                if code == "visible-profile-label" and "User System Profile" in line:
                    continue
                snippet = line.strip()
                if len(snippet) > 180:
                    snippet = snippet[:177] + "..."
                findings.append(f"{rel}:{lineno}: {code}: {reason}\n    {snippet}")
    return findings


def main() -> int:
    parser = argparse.ArgumentParser(description="Scan Ambitions visible copy for stale language.")
    parser.add_argument("root", nargs="?", default=str(ROOT_DEFAULT), help="Repository root")
    parser.add_argument("--strict", action="store_true", help="Exit 1 when findings are present")
    parser.add_argument(
        "--broad",
        action="store_true",
        help="Scan every supported text file under the repo. Not part of the bounded Train 2 gate.",
    )
    args = parser.parse_args()

    root = Path(args.root).resolve()
    findings: list[str] = []
    scanned = 0
    for path in iter_files(root, broad=args.broad):
        scanned += 1
        findings.extend(scan_file(path, root))

    print("Ambitions visible-copy drift scan")
    print(f"Root: {root}")
    print(f"Mode: {'broad' if args.broad else 'bounded'}")
    print(f"Files scanned: {scanned}")
    print(f"Findings: {len(findings)}")
    if findings:
        print()
        print("\n".join(findings))
        return 1 if args.strict else 0
    return 0


if __name__ == "__main__":
    sys.exit(main())
