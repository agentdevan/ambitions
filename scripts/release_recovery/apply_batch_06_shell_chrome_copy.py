#!/usr/bin/env python3
"""Batch 06: shell chrome copy and IA cleanup."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TARGETS = (
    "Native/Ambitions/App/AmbitionsRootView.swift",
    "Native/Ambitions/App/AppShellView.swift",
    "Native/Ambitions/App/AppMeridianShell.swift",
    "Native/Ambitions/App/AppTab.swift",
)
REPLACEMENTS = (
    ('subtitle: "Execution"', 'subtitle: "Start here"'),
    ('subtitle: "Direction"', 'subtitle: "Constellation Atlas"'),
    ('subtitle: "Shape Time"', 'subtitle: "LifeShape Field"'),
    ('subtitle: "Time support route"', 'subtitle: "Open Field"'),
    ('subtitle: "Time-owned loop view"', 'subtitle: "LifeShape Field"'),
    ('subtitle: "Time shaping continuation"', 'subtitle: "LifeShape Field"'),
    ("Capture Anything", "Open Field"),
    ("Route reveal", "Suggested path"),
    ("route reveal", "suggested path"),
    ("Local receipt", "On-device record"),
    ("receipt seam", "review history"),
    ("Receipt seam", "Review history"),
    ("No cloud route", "No cloud handoff"),
    ("Direction Atlas", "Constellation Atlas"),
    ("Personal Runtime", "User System Profile"),
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
    print("Applied Batch 06 shell chrome copy cleanup.")
    for item in changed:
        print(f"- {item}")
    if not changed:
        print("- no source changes required")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
