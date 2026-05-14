#!/usr/bin/env python3
from __future__ import annotations

from ambitions_visual_100_common import p0_registry_entries, recipe_text_by_entry, write_json, REPORT_DIR


REPORT = REPORT_DIR / "visual-100-accessibility-adhd.json"
REQUIRED = [
    "VoiceOver",
    "Dynamic Type",
    "Reduce Motion",
    "Reduce Transparency",
    "Increase Contrast",
    "Differentiate Without Color",
    "ADHD",
]


def main() -> int:
    missing = []
    for entry in p0_registry_entries():
        text = recipe_text_by_entry(entry)
        for marker in REQUIRED:
            if marker.lower() not in text.lower():
                missing.append({"surface_id": entry.get("surface_id"), "marker": marker})
    status = "green" if not missing else "red"
    write_json(REPORT, {"missing": missing, "status": status})
    print("PASS" if status == "green" else "FAIL")
    return 0 if status == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
