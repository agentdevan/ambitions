#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
REQUIRED_COLUMNS = {
    "Screenshot ID",
    "Surface",
    "Product object",
    "State",
    "Projection contract",
    "Fixture",
    "Device",
    "Orientation",
    "Dynamic Type size",
    "Color scheme",
    "Reduce Motion status",
    "VoiceOver semantic summary",
    "Privacy redaction status",
    "Source proof",
    "Validation command",
}

REGISTRY = ROOT / "docs" / "visual" / "AMB_SCREENSHOT_CANDIDATE_REGISTRY.md"
REPORT = ROOT / "build" / "reports" / "ios26-shell" / "screenshot-foundation.md"
REQUIRE_SURFACES = {
    "today": ["today", "start here", "today / reality meridian", "reality meridian"],
    "capture": ["capture"],
    "goals": ["goals"],
    "time": ["time"],
    "you": ["you"],
}


def parse_header_index(line: str):
    cols = [c.strip() for c in line.strip("|").split("|")]
    return cols


def main() -> int:
    if not REGISTRY.exists():
        print("RED")
        print(f"missing file: {REGISTRY}")
        return 1

    if not REPORT.exists():
        print("RED")
        print(f"missing file: {REPORT}")
        return 1

    lines = [line.strip() for line in REGISTRY.read_text(encoding="utf-8").splitlines() if line.strip()]
    if not lines:
        print("RED")
        print("empty visual registry")
        return 1

    header = parse_header_index(lines[1]) if len(lines) > 1 else []
    if len(header) < len(REQUIRED_COLUMNS):
        print("RED")
        print("invalid screenshot registry header")
        return 1

    colmap = [h.lower() for h in header]
    missing = [c.lower() for c in REQUIRED_COLUMNS if c.lower() not in colmap]
    if missing:
        print("RED")
        print(f"missing screenshot columns: {', '.join(missing)}")
        return 1

    rows = []
    issues = []
    for line in lines:
        if not line.startswith("|") or line.startswith("| ---") or line.startswith("| Screenshot"):
            continue
        row = parse_header_index(line)
        if len(row) != len(header):
            issues.append(f"screenshot registry row has {len(row)} columns, expected {len(header)}: {row[0] if row else '<empty>'}")
        rows.append(row)

    if issues:
        print("RED")
        print("\n".join(issues))
        return 1

    if len(rows) < 8:
        print("RED")
        print("insufficient screenshot scenarios")
        return 1

    flat_text = " ".join(lines).lower()
    for marker in ["today", "goals", "momentum", "capture", "time", "you", "proof trail", "replay", "privacy", "reduced motion", "voiceover"]:
        if marker not in flat_text:
            print("RED")
            print(f"missing required visual state marker: {marker}")
            return 1

    report_lines = [line.strip() for line in REPORT.read_text(encoding="utf-8").splitlines() if line.strip()]
    report_text = " ".join(report_lines).lower()
    report_markers = [
        "status: yellow",
        "batch: ios26-t02-b03",
        "current icon asset status",
        "validation routes",
        "no-claim boundaries",
        "accessibility proof classification",
        "privacy/local-first status",
        "claims not made",
        "visual quality unproven",
    ]
    for marker in report_markers:
        if marker not in report_text:
            print("RED")
            print(f"missing report marker: {marker}")
            return 1

    print("GREEN")
    return 0


if __name__ == "__main__":
    import sys
    sys.exit(main())
