#!/usr/bin/env python3
"""Guard top-level Ambitions surfaces against reverting to generic card stacks."""

from __future__ import annotations

import argparse
from pathlib import Path
import re
import sys

DEFAULT_ROOT = Path(__file__).resolve().parents[1]
SURFACE_FILES = (
    "Native/Ambitions/Features/Today/TodayScreen.swift",
    "Native/Ambitions/Features/Today/TodayDayRailPanels.swift",
    "Native/Ambitions/Features/Goals/GoalsScreen.swift",
    "Native/Ambitions/Features/Goals/GoalComponents.swift",
    "Native/Ambitions/Features/Time/TimeScreen.swift",
    "Native/Ambitions/Features/Time/TimeLifeShapeField.swift",
    "Native/Ambitions/Features/Motion/MotionCurrentScreen.swift",
    "Native/Ambitions/Features/You/YouRootSurface.swift",
    "Native/Ambitions/Features/You/YouScreen.swift",
)
CARD_PATTERN = re.compile(r"\b(AppCard|WidgetCard|HeroCard|StateDrivenMaterialPanel)\b")


def main() -> int:
    parser = argparse.ArgumentParser(description="Detect generic card-stack dominance in top-level surfaces.")
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT)
    parser.add_argument("--max-per-file", type=int, default=8)
    args = parser.parse_args()
    root = args.root.resolve()

    failures: list[str] = []
    for rel in SURFACE_FILES:
        path = root / rel
        if not path.exists():
            continue
        text = path.read_text(encoding="utf-8")
        count = len(CARD_PATTERN.findall(text))
        if count > args.max_per_file:
            failures.append(
                f"{rel}: {count} generic surface primitives found; top-level screens must be object-stage led, not card-stack led."
            )

    if failures:
        print("First-viewport card lint failed:", file=sys.stderr)
        for failure in failures:
            print(f"- {failure}", file=sys.stderr)
        return 1
    print("First-viewport card lint passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
