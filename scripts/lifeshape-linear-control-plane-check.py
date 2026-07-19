#!/usr/bin/env python3
"""Validate the local AMB-1160 LifeShape Linear control-plane ledger.

The live Linear project is the control plane. This script gives the repo an
executable local guard that records the verified project/doc/issue shape and
prevents the LifeShape chain from starting with missing or stale sequencing
authority.
"""
from __future__ import annotations

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LEDGER = ROOT / "docs" / "validation" / "lifeshape_control_plane_ledger.md"
QUALITY_GATE = ROOT / "scripts" / "ambitions-quality-gate.py"

EXPECTED_DOCUMENTS = [
    "00 - LifeShape Field Canon + Project Law",
    "01 - Runtime Data Contracts, Engines, Corrections",
    "02 - UX, Interaction, Copy, Visual, Accessibility",
    "03 - Audits, Scenario Matrix, Proof Requirements",
    "04 - Codex Execution Order + Train Closeout Template",
    "05 - Issue Map, Milestones, Dependencies, Labels",
]

EXPECTED_MILESTONES = [
    "T-1 Shell Blockers Before Time Rebuild",
    "T00 Anti-Fake Gates + Control Plane",
    "T01 Clock + Runtime Time Foundation",
    "T02 LifeShape Data Contract",
    "T03 Open + Protected Engines",
    "T04 TimeLens + Today Coupling",
    "T05 SwiftUI-First LifeShape Field",
    "T06 Mutations + Undo + Proof",
    "T07 Inspection Without Audit-Console Root",
    "T08 Pressure Hidden Engine",
    "T09 Pressure Visible",
    "T10 Buffer Hidden Engine",
    "T11 Buffer Visible",
    "T12 Visual Flagship Pass",
    "T13 Delete Old Time",
    "T14 Full Proof + Closeout",
]

EXPECTED_ISSUES = [
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
]

REQUIRED_PHRASES = [
    "Project verified: Ambitions Time / LifeShape Field Runtime Instrumentation",
    "Persistent canon: Today / Goals / Time / You only",
    "Capture is the global composer",
    "Motion is cross-surface behavior",
    "No hosted AI service or cloud LLM may become core architecture",
    "No train may start without clear scope, files/areas, gates, validation, and proof artifacts",
    "No issue may claim Green without evidence",
    "AMB-1160 is a control-plane issue",
]


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace") if path.exists() else ""


def ordered_errors(text: str, expected: list[str], label: str) -> list[str]:
    errors: list[str] = []
    cursor = -1
    for item in expected:
        position = text.find(item, cursor + 1)
        if position == -1:
            errors.append(f"ledger missing {label}: {item}")
            continue
        if position <= cursor:
            errors.append(f"ledger {label} appears out of order: {item}")
        cursor = position
    return errors


def main() -> int:
    errors: list[str] = []
    ledger_text = read(LEDGER)
    quality_text = read(QUALITY_GATE)

    if not LEDGER.exists():
        errors.append(f"missing {LEDGER.relative_to(ROOT)}")

    for phrase in REQUIRED_PHRASES:
        if phrase not in ledger_text:
            errors.append(f"ledger missing required phrase: {phrase}")

    errors.extend(ordered_errors(ledger_text, EXPECTED_DOCUMENTS, "document"))
    errors.extend(ordered_errors(ledger_text, EXPECTED_MILESTONES, "milestone"))
    errors.extend(ordered_errors(ledger_text, EXPECTED_ISSUES, "issue"))

    if "lifeshape-linear-control-plane-check.py" not in quality_text:
        errors.append("ambitions-quality-gate.py does not require the LifeShape control-plane check")
    if "lifeshape_control_plane_ledger.md" not in quality_text:
        errors.append("ambitions-quality-gate.py does not require the LifeShape control-plane ledger")

    print("lifeshape-linear-control-plane-check")
    if errors:
        print(f"RED {len(errors)} control-plane finding(s)")
        for error in errors:
            print(f"- {error}")
        return 1

    print("GREEN LifeShape Linear control-plane ledger passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
