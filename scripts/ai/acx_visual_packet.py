#!/usr/bin/env python3
"""ACX Visual Packet: generate visual QA packet template for Ambitions UI work."""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Sequence

ROOT = Path(__file__).resolve().parents[2]

SURFACE_OBJECTS = {
    "Today": "Start Here Surface / Reality Meridian / Action Closure Diamond",
    "Goals": "Goal Atlas / MissionControlTimeSpine / LifePath Thread / Proof Spine",
    "Capture": "Capture Atmosphere Composer / Placement Shelf / Correction Fold",
    "Plan": "LifeShape Contour Map / Reflow Decision Fold / Pressure Field",
    "You": "Personal System Center / Memory Lens / Appearance Studio",
}


def packet(surface: str, changed_files: list[str]) -> str:
    primary = SURFACE_OBJECTS.get(surface, "Unknown; select route owner before claiming visual proof")
    lines = [
        "# ACX Visual QA Packet",
        "",
        f"Surface: {surface}",
        f"Expected primary object: {primary}",
        "",
        "## Changed files",
    ]
    lines.extend(f"- {item}" for item in changed_files) if changed_files else lines.append("- Not supplied")
    lines.extend([
        "",
        "## Required proof fields",
        "- Screenshot/render path:",
        "- Proof freshness date:",
        "- Visual score:",
        "- Drift result:",
        "- Primary object visible:",
        "- Anti-card-stack / anti-dashboard note:",
        "- Accessibility/readability note:",
        "- Reduce Motion note:",
        "- Privacy/redaction rendering note:",
        "",
        "## Claims not made",
        "- Human visual approval unless explicitly supplied.",
        "- Public accessibility conformance.",
        "- Release/App Store/TestFlight readiness.",
    ])
    return "\n".join(lines) + "\n"


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Generate visual QA packet template.")
    parser.add_argument("surface", choices=sorted(SURFACE_OBJECTS))
    parser.add_argument("files", nargs="*")
    parser.add_argument("--write")
    args = parser.parse_args(argv)
    text = packet(args.surface, args.files)
    if args.write:
        target = (ROOT / args.write).resolve()
        try:
            target.relative_to(ROOT)
        except ValueError:
            print("Red: refusing to write outside repo root.")
            return 2
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(text, encoding="utf-8")
        print(f"Wrote {target.relative_to(ROOT)}")
    else:
        print(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
