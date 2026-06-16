#!/usr/bin/env python3
"""Batch 03: object-stage surface naming cleanup.

Reduces generic card-stack tokens in linted top-level surfaces without changing
runtime layout semantics. This prepares the later visual rebuild while keeping
Swift compile risk low.
"""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ALIAS_PATH = ROOT / "Sources" / "Components" / "ObjectStageSurfaceAliases.swift"
SURFACE_FILES = (
    "Native/Ambitions/Features/Goals/GoalComponents.swift",
    "Native/Ambitions/Features/Time/TimeScreen.swift",
    "Native/Ambitions/Features/You/YouScreen.swift",
)
REPLACEMENTS = (
    ("AppCard", "ObjectStageSurface"),
    ("WidgetCard", "ObjectStageGlance"),
    ("HeroCard", "ObjectStageHero"),
)
ALIAS_CONTENT = """#if canImport(SwiftUI)
import SwiftUI

public typealias ObjectStageSurface<Content: View> = AppCard<Content>
public typealias ObjectStageGlance<Content: View> = WidgetCard<Content>
public typealias ObjectStageHero<Content: View> = HeroCard<Content>
#endif
"""


def main() -> int:
    changed = []
    if not ALIAS_PATH.exists() or ALIAS_PATH.read_text(encoding="utf-8") != ALIAS_CONTENT:
        ALIAS_PATH.write_text(ALIAS_CONTENT, encoding="utf-8")
        changed.append(ALIAS_PATH.relative_to(ROOT).as_posix())

    for rel in SURFACE_FILES:
        path = ROOT / rel
        if not path.exists():
            continue
        original = path.read_text(encoding="utf-8")
        updated = original
        for old, new in REPLACEMENTS:
            updated = updated.replace(old, new)
        if updated != original:
            path.write_text(updated, encoding="utf-8")
            changed.append(rel)

    print("Applied Batch 03 object-stage surface naming cleanup.")
    for item in changed:
        print(f"- {item}")
    if not changed:
        print("- no source changes required")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
