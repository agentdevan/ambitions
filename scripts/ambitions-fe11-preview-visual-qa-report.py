#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]
REPORT = ROOT / "docs" / "audits" / "fe-11-preview-visual-qa-report.md"
MATRIX = ROOT / "frontend" / "visual-encyclopedia" / "trace" / "FE11_PREVIEW_VISUAL_QA_MATRIX.md"
SCREENSHOT_MATRIX = ROOT / "frontend" / "visual-encyclopedia" / "trace" / "SCREENSHOT_PROOF_MATRIX.md"
READINESS = ROOT / "frontend" / "visual-encyclopedia" / "gates" / "VISUAL_REGRESSION_READINESS.md"

EXPECTED_REPORT_MARKERS = [
    "Status: Yellow, fixture-backed and screenshot not captured",
    "21 deterministic SI16 preview fixtures",
    "5 surface coverage rows",
    "9 future LDI visual hook fixtures",
    "frontend/visual-encyclopedia/trace/FE11_PREVIEW_VISUAL_QA_MATRIX.md",
]

EXPECTED_MATRIX_MARKERS = [
    "Status: fixture-backed, screenshot not captured",
    "SI16 preview fixture catalog",
    "Surface Coverage",
    "No screenshot capture is claimed.",
]


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def render_checklist() -> str:
    lines = [
        "# FE-11 Preview Visual QA Report Check",
        "",
        "Status: Yellow, fixture-backed and screenshot not captured",
        "",
        "Validated artifacts:",
        f"- {REPORT.relative_to(ROOT)}",
        f"- {MATRIX.relative_to(ROOT)}",
        f"- {SCREENSHOT_MATRIX.relative_to(ROOT)}",
        f"- {READINESS.relative_to(ROOT)}",
    ]
    return "\n".join(lines) + "\n"


def validate() -> list[str]:
    issues: list[str] = []

    report_text = read_text(REPORT)
    matrix_text = read_text(MATRIX)
    screenshot_text = read_text(SCREENSHOT_MATRIX)
    readiness_text = read_text(READINESS)

    for marker in EXPECTED_REPORT_MARKERS:
        if marker not in report_text:
            issues.append(f"report missing marker: {marker}")

    for marker in EXPECTED_MATRIX_MARKERS:
        if marker not in matrix_text:
            issues.append(f"matrix missing marker: {marker}")

    for marker in [
        "Fixture IDs",
        "screenshot not captured",
        "accessibility checklist scaffolded",
        "not release or device proof",
    ]:
        if marker not in screenshot_text:
            issues.append(f"screenshot matrix missing marker: {marker}")

    for marker in [
        "Current FE-11 Artifacts",
        "frontend/visual-encyclopedia/trace/FE11_PREVIEW_VISUAL_QA_MATRIX.md",
        "docs/audits/fe-11-preview-visual-qa-report.md",
    ]:
        if marker not in readiness_text:
            issues.append(f"readiness missing marker: {marker}")

    return issues


def main() -> int:
    if "--print" in sys.argv:
        sys.stdout.write(render_checklist())
        return 0

    issues = validate()
    if issues:
        for issue in issues:
            print(issue, file=sys.stderr)
        return 1

    print(render_checklist(), end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
