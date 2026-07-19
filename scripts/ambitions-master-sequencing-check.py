#!/usr/bin/env python3
"""Validate the active Master Build LifeShape fold-in sequence.

This guard is intentionally local and deterministic. Linear remains the control
plane, but the repo needs a small executable check that prevents AMB-1177 from
silently drifting back to stale Motion-root, Capture-tab, or proof-only Time
completion assumptions.
"""
from __future__ import annotations

from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]
LEDGER = ROOT / "docs" / "validation" / "master_lifeshape_foldin_ledger.md"
QUALITY_GATE = ROOT / "scripts" / "ambitions-quality-gate.py"

EXPECTED_SEQUENCE = [
    "AMB-1177",
    "AMB-1160",
    "AMB-1161",
    "AMB-1162",
    "AMB-1163",
    "AMB-1164",
    "AMB-1165",
    "AMB-1166",
    "AMB-1167",
    "AMB-1168",
    "AMB-1169",
    "AMB-1170",
    "AMB-1171",
    "AMB-1172",
    "AMB-1173",
    "AMB-1174",
    "AMB-1175",
    "AMB-1176",
    "AMB-1178",
    "AMB-1179",
]

REQUIRED_CANON_PHRASES = [
    "Persistent surfaces: Today / Goals / Time / You",
    "Capture is global composer, not a tab or root surface",
    "Motion is Stage/Motion behavior, not a root destination",
    "Source Atlas/R2 is public/reference/freshness only",
    "No current CloudKit/iCloud/private graph sync scope",
    "No hosted AI/cloud LLM core behavior",
    "Offline core must work with no account",
]

REQUIRED_GUARD_PHRASES = [
    "AMB-1177 is a parent/control bridge",
    "No implementation Green from documents, labels, screenshots, scanner success, or stale closeout text alone",
    "Root Time becomes one SwiftUI-first LifeShape Field",
    "UI cannot directly construct production LifeShapeBucket/LifeShapeProjection",
    "Time mutations update Today when affected",
    "Delete/isolate old Time action grids, root source/receipt panels, Week Shape reports, Reflow Preview, Continuity filler, and card components from release",
]


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace") if path.exists() else ""


def ordered_issue_errors(text: str) -> list[str]:
    errors: list[str] = []
    cursor = -1
    for issue in EXPECTED_SEQUENCE:
        position = text.find(issue, cursor + 1)
        if position == -1:
            errors.append(f"ledger missing ordered issue {issue}")
            continue
        if position <= cursor:
            errors.append(f"ledger issue {issue} appears out of order")
        cursor = position
    return errors


def main() -> int:
    errors: list[str] = []

    if not LEDGER.exists():
        errors.append(f"missing {LEDGER.relative_to(ROOT)}")
    ledger_text = read(LEDGER)

    for phrase in REQUIRED_CANON_PHRASES:
        if phrase not in ledger_text:
            errors.append(f"ledger missing canon phrase: {phrase}")

    for phrase in REQUIRED_GUARD_PHRASES:
        if phrase not in ledger_text:
            errors.append(f"ledger missing guard phrase: {phrase}")

    errors.extend(ordered_issue_errors(ledger_text))

    quality_text = read(QUALITY_GATE)
    if "ambitions-master-sequencing-check.py" not in quality_text:
        errors.append("ambitions-quality-gate.py does not require the master sequencing check")
    if "master_lifeshape_foldin_ledger.md" not in quality_text:
        errors.append("ambitions-quality-gate.py does not require the LifeShape fold-in ledger")

    print("ambitions-master-sequencing-check")
    if errors:
        print(f"RED {len(errors)} sequencing finding(s)")
        for error in errors:
            print(f"- {error}")
        return 1

    print("GREEN master LifeShape fold-in sequencing guard passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
