#!/usr/bin/env python3
"""Validate active authority files against current Ambitions product law."""
from __future__ import annotations

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]

TARGET_FILES = [
    ROOT / "AGENTS.md",
    ROOT / ".codex" / "os" / "AMBITIONS_OPERATING_CONTEXT.md",
    ROOT / "docs" / "truth" / "PRODUCT_DESIGN_TRUTH.md",
    ROOT / "docs" / "truth" / "PRODUCT_MOAT_TRUTH.md",
    ROOT / "docs" / "truth" / "IMPLEMENTATION_TRUTH.md",
    ROOT / "docs" / "truth" / "CODEX_PROCESS_TRUTH.md",
    ROOT / "docs" / "codex" / "LOCAL_DATA_CLOUD_BOUNDARY_LAW.md",
]

ACTIVE_SURFACES = "Today / Goals / Time / You"
FORBIDDEN_ACTIVE_IA = (
    "Today / Goals / Time / Motion / You",
    "Today, Goals, Time, Motion, You",
    "Today, Goals, Time, Motion, and You",
    "Today / Goals / Capture / Time / You",
    "Today, Goals, Capture, Time, You",
)


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="ignore") if path.exists() else ""


def line_is_historical_or_negative(line: str) -> bool:
    lowered = line.lower()
    return any(
        marker in lowered
        for marker in (
            "historical",
            "legacy",
            "compatibility",
            "superseded",
            "forbidden",
            "must not",
            "not active",
            "not current",
            "do not",
            "stale",
            "migration debt",
            "red if",
        )
    )


def main() -> int:
    issues: list[str] = []

    for path in TARGET_FILES:
        if not path.exists():
            issues.append(f"missing file: {path.relative_to(ROOT)}")
            continue

        text = read(path)
        rel = path.relative_to(ROOT)

        if ACTIVE_SURFACES not in text:
            issues.append(f"{rel}: missing active four-surface law")

        for legacy in FORBIDDEN_ACTIVE_IA:
            for line_no, line in enumerate(text.splitlines(), start=1):
                if legacy in line and not line_is_historical_or_negative(line):
                    issues.append(f"{rel}:{line_no}: stale active IA appears without historical/negative context: {legacy}")

        if re.search(r"Motion\s+replaces\s+Pulse\s+as\s+the\s+approved\s+fifth\s+tab", text, re.I):
            issues.append(f"{rel}: stale Motion fifth-tab law remains")

        if re.search(r"Motion\s+is\s+.*approved\s+fifth\s+tab", text, re.I):
            issues.append(f"{rel}: stale Motion fifth-tab wording remains")

        if re.search(r"custom hosted account", text, re.I) and "Ambitions Account" not in text:
            issues.append(f"{rel}: custom account boundary is stale or underspecified")

        if "R2" in text and "not a user-data backend" not in text and "must never" not in text:
            issues.append(f"{rel}: R2 mentioned without private-data boundary")

    product_truth = read(ROOT / "docs" / "truth" / "PRODUCT_DESIGN_TRUTH.md")
    if "This is the canon." not in product_truth:
        issues.append("PRODUCT_DESIGN_TRUTH.md: final canon sentinel missing")
    if "Ambitions supports custom Ambitions Accounts at launch" not in product_truth:
        issues.append("PRODUCT_DESIGN_TRUTH.md: Ambitions Account launch law missing")
    if "Hosted AI services and cloud LLMs are not core architecture" not in product_truth:
        issues.append("PRODUCT_DESIGN_TRUTH.md: hosted AI/cloud LLM boundary missing")

    if issues:
        print("RED")
        print("\n".join(issues))
        return 1

    print("GREEN")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
