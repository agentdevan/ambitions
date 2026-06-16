#!/usr/bin/env python3
from __future__ import annotations

from report_reconstruction_support import read, replace_all, require_markers, write, write_proof

GOALS = "Native/Ambitions/Features/Goals/GoalComponents.swift"
APP_TAB = "Native/Ambitions/App/AppTab.swift"


def main() -> int:
    app_tab = read(APP_TAB)
    if "primaryObjectTitle: \"Constellation Atlas\"" not in app_tab:
        raise RuntimeError("Goals AppTab contract must already own Constellation Atlas before Batch 25.")

    text = read(GOALS)
    text = replace_all(text, {
        "Full-bleed Constellation Atlas object stage with compact equal-weight life areas, Orbital Lens inspection, proof, source, receipt, and Today relationship lines.": "Full-bleed Constellation Atlas object stage with life-area nodes, Orbital Lens focus, Today connection, and progressive trust inspection.",
        "Life areas, proof, source, and Today connection stay in one direction object.": "Life areas and active threads stay connected to Today.",
        "Equal-weight areas": "Life areas",
        "Manual order, same size": "Choose the area to focus",
        "Equal-weight Life Areas": "Life Areas",
        "Areas use the same size and manual controls for visibility and order.": "Choose an area to inspect its active thread.",
        "source/proof/trust blocks": "progressive trust disclosures",
        "source, proof, receipt, and Today relationships": "life-area, thread, Today, and trust-disclosure relationships",
        "Source, proof, receipt": "Why this?",
        "source/proof/trust": "trust",
    })
    write(GOALS, text)
    require_markers(GOALS, ["Constellation Atlas", "Orbital Lens", "Life areas", "Choose the area to focus", "Why this?"])
    require_markers(APP_TAB, ["primaryObjectTitle: \"Constellation Atlas\""])
    write_proof(
        "REPORT_BATCH_25_GOALS_CONSTELLATION_ATLAS.md",
        """
# Batch 25 — Goals Constellation Atlas rewrite

Status: applied.

Scope:
- Confirmed AppTab contract already maps Goals to Constellation Atlas.
- Reframed Goals first-viewport language around life-area nodes and active threads.
- Preserved Orbital Lens as the inspection model.
- Moved Source / Proof / Receipt from loud first-viewport metadata framing toward progressive trust disclosure.
- Preserved the existing Goals `Why this?` affordance instead of forcing a longer label.

Atlas gates:
- Goals remains Constellation Atlas + Orbital Lens.
- Goals is not a generic goals dashboard or status document.
- Direction Atlas is not revived.
- Capture remains outside root IA.
""",
    )
    print("Applied Batch 25 Goals Constellation Atlas rewrite.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
