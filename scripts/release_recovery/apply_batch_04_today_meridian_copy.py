#!/usr/bin/env python3
"""Batch 04: Today Reality Meridian copy cleanup."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TARGETS = (
    "Native/Ambitions/Features/Today/TodayScreen.swift",
    "Native/Ambitions/Features/Today/TodayDayRailPanels.swift",
    "Native/Ambitions/Features/Today/DayRailProjection.swift",
    "Native/Ambitions/Features/Today/DayRailViewState.swift",
    "Native/Ambitions/Features/Today/TodayActionClosureSheet.swift",
    "Native/Ambitions/Features/Today/TodayActionClosureSheetState.swift",
    "Native/Ambitions/Features/Today/TodayExecutionProjector.swift",
    "Native/Ambitions/Features/Today/TodayStartHereSurface.swift",
    "Native/Ambitions/Features/Today/TodayStepReplacementSheet.swift",
)
REPLACEMENTS = (
    ("Close Today", "Record outcome"),
    ("Review source", "Review context"),
    ("User choice stays open", "Choice stays open"),
    ("The next step appears here when it fits.", "Start here appears when this window can hold it."),
    ("This window is open", "This window can hold a step"),
    ("No silent changes", "Changes stay reviewable"),
    ("no silent changes", "changes stay reviewable"),
    ("receipt seam", "review history"),
    ("Receipt seam", "Review history"),
    ("replay trace", "review path"),
    ("Replay trace", "Review path"),
)


def main() -> int:
    changed = []
    for rel in TARGETS:
        path = ROOT / rel
        if not path.exists():
            continue
        text = path.read_text(encoding="utf-8")
        updated = text
        for old, new in REPLACEMENTS:
            updated = updated.replace(old, new)
        if updated != text:
            path.write_text(updated, encoding="utf-8")
            changed.append(rel)
    print("Applied Batch 04 Today copy cleanup.")
    for item in changed:
        print(f"- {item}")
    if not changed:
        print("- no source changes required")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
