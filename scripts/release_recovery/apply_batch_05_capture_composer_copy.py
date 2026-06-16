#!/usr/bin/env python3
"""Batch 05: Capture Atmosphere Composer copy cleanup."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TARGETS = (
    "Native/Ambitions/App/AppShellView.swift",
    "Native/Ambitions/Features/Capture/CaptureScreen.swift",
    "Native/Ambitions/Features/Capture/CaptureAtmosphereComposer.swift",
    "Sources/Components/CaptureRoutingPrimitiveFamily.swift",
)
REPLACEMENTS = (
    ("Capture Anything", "Open Field"),
    ("Capture anything", "Open field"),
    ("capture anything", "open field"),
    ("route reveal", "suggested path"),
    ("Route reveal", "Suggested path"),
    ("receipt before save", "review before save"),
    ("Receipt before save", "Review before save"),
    ("receipt seam", "review history"),
    ("Receipt seam", "Review history"),
    ("Local receipt", "On-device record"),
    ("No cloud route", "No cloud handoff"),
    ("Needs a Place", "Needs placement"),
    ("needs a place", "needs placement"),
    ("held for review", "kept for review"),
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
    print("Applied Batch 05 Capture composer copy cleanup.")
    for item in changed:
        print(f"- {item}")
    if not changed:
        print("- no source changes required")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
