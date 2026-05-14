#!/usr/bin/env python3
from __future__ import annotations

from ambitions_visual_100_common import (
    p0_registry_entries,
    recipe_text_by_entry,
    text_contains_all,
    text_contains_any,
    write_json,
    REPORT_DIR,
)


REPORT = REPORT_DIR / "visual-100-recipe-contract.json"

REQUIRED_MARKERS = [
    "## P0 Proof Appendix",
    "## P0 Canon Appendix",
    "Source Link Status",
    "Implementation Proof Boundary",
    "Good / Bad Example",
    "Acceptance Checklist",
]


def main() -> int:
    missing = []
    for entry in p0_registry_entries():
        text = recipe_text_by_entry(entry)
        for marker in REQUIRED_MARKERS:
            if marker not in text:
                missing.append({"surface_id": entry.get("surface_id"), "marker": marker})
        if not text_contains_any(text, ["VoiceOver", "Dynamic Type", "Reduce Motion", "Reduce Transparency", "Increase Contrast", "Differentiate Without Color"]):
            missing.append({"surface_id": entry.get("surface_id"), "marker": "accessibility"})
        if not text_contains_any(text, ["Proof", "Receipt", "Source"]):
            missing.append({"surface_id": entry.get("surface_id"), "marker": "proof_source"})
        if not text_contains_any(text, ["Primary Action", "Primary action", "One dominant action", "one dominant action"]):
            missing.append({"surface_id": entry.get("surface_id"), "marker": "primary_action"})
    status = "green" if not missing else "red"
    payload = {
        "p0_count": len(p0_registry_entries()),
        "missing_markers": missing,
        "status": status,
    }
    write_json(REPORT, payload)
    print("PASS" if status == "green" else "FAIL")
    return 0 if status == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
