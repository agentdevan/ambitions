#!/usr/bin/env python3
from __future__ import annotations

from ambitions_visual_100_common import p0_registry_entries, recipe_text_by_entry, section_text, write_json, REPORT_DIR


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
        surface_id = entry.get("surface_id")
        for marker in REQUIRED:
            if marker.lower() not in text.lower():
                missing.append({"surface_id": surface_id, "marker": marker})
        voiceover = section_text(text, "VoiceOver Order")
        dynamic = section_text(text, "Dynamic Type Behavior")
        motion = section_text(text, "Reduce Motion Behavior")
        transparency = section_text(text, "Reduce Transparency Behavior")
        contrast = section_text(text, "Increase Contrast Behavior")
        differentiate = section_text(text, "Differentiate Without Color Behavior")
        density = section_text(text, "ADHD Density Law")
        if not all([voiceover, dynamic, motion, transparency, contrast, differentiate, density]):
            missing.append({"surface_id": surface_id, "marker": "accessibility section depth"})
        if "object" not in voiceover.lower() or "action" not in voiceover.lower():
            missing.append({"surface_id": surface_id, "marker": "voiceover order"})
        if "large" not in dynamic.lower() or "primary action" not in dynamic.lower():
            missing.append({"surface_id": surface_id, "marker": "dynamic type"})
        if "static" not in motion.lower() and "before / after" not in motion.lower():
            missing.append({"surface_id": surface_id, "marker": "reduce motion"})
        if "opaque" not in transparency.lower() and "graphite" not in transparency.lower():
            missing.append({"surface_id": surface_id, "marker": "reduce transparency"})
        if "border" not in contrast.lower() and "stronger" not in contrast.lower():
            missing.append({"surface_id": surface_id, "marker": "increase contrast"})
        if "shape" not in differentiate.lower() and "text" not in differentiate.lower():
            missing.append({"surface_id": surface_id, "marker": "differentiate without color"})
        if "one dominant action" not in density.lower() or "recovery" not in density.lower():
            missing.append({"surface_id": surface_id, "marker": "adhd density"})
    status = "green" if not missing else "red"
    write_json(REPORT, {"missing": missing, "status": status, "p0_count": len(p0_registry_entries())})
    print("PASS" if status == "green" else "FAIL")
    return 0 if status == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
