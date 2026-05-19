#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
PATH = ROOT / "docs" / "accessibility" / "AMB_ACCESSIBILITY_MOAT_MATRIX.md"
REQUIRED_SURFACES = [
    "Today",
    "Goals",
    "Capture",
    "Time",
    "You",
    "Start Here",
    "Reality Meridian",
    "LifeShape Field",
    "Constellation Atlas",
    "Atmosphere Composer",
    "Trust Console",
    "Proof Trail",
    "Receipt Drawer",
    "Not Chosen Reasons Inspector",
    "Decision Replay Viewer",
    "Memory Lens",
    "Local Control Knobs",
    "Privacy Redaction Mode",
    "Closure Ritual",
    "Continuity Conflict Review",
]
CHECKS = [
    "VoiceOver",
    "Dynamic Type",
    "Reduce Motion",
    "semantic",
    "hit target",
    "focus",
    "color-independent",
    "motion-independent",
    "privacy-safe",
]


def main() -> int:
    if not PATH.exists():
        print("RED")
        print(f"missing file: {PATH}")
        return 1
    text = PATH.read_text(encoding="utf-8").lower()

    for surface in REQUIRED_SURFACES:
        if surface.lower() not in text:
            print("RED")
            print(f"missing required surface: {surface}")
            return 1

    for check in CHECKS:
        if check.lower() not in text:
            print("RED")
            print(f"missing check keyword: {check}")
            return 1

    print("GREEN")
    return 0


if __name__ == "__main__":
    import sys
    sys.exit(main())
