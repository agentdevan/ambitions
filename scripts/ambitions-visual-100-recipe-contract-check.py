#!/usr/bin/env python3
from __future__ import annotations

from ambitions_visual_100_common import (
    p0_registry_entries,
    recipe_text_by_entry,
    section_has_depth,
    section_text,
    bullet_items,
    text_contains_all,
    text_contains_any,
    write_json,
    REPORT_DIR,
)


REPORT = REPORT_DIR / "visual-100-recipe-contract.json"

REQUIRED_TOP_LEVEL_SECTIONS = [
    "Purpose",
    "Surface Hierarchy",
    "Primary Object Dependency",
    "Label-Off Signature",
    "Canonical Anatomy",
    "Visible Regions",
    "Dominant Object",
    "Supporting Objects",
    "Primitive Usage",
    "Typography Roles",
    "Spacing Rules",
    "Material Rules",
    "Color / State Rules",
    "Iconography",
    "Chevron / Disclosure Rules",
    "Source / Trust Behavior",
    "Proof / Receipt Behavior",
    "Transaction Behavior",
    "Primary Action",
    "Secondary Correction Path",
    "Empty State",
    "Loading / Unknown State",
    "Error / Conflict State",
    "Recovery State",
    "VoiceOver Order",
    "Dynamic Type Behavior",
    "Reduce Motion Behavior",
    "Reduce Transparency Behavior",
    "Increase Contrast Behavior",
    "Differentiate Without Color Behavior",
    "ADHD Density Law",
    "Native iPhone Believability Requirements",
    "Train / Source-Family Influence",
    "Source Linkage",
    "Implementation Proof Boundary",
    "Unresolved Direction",
    "Anti-Generic Red Flags",
    "Forbidden Interpretations",
    "Acceptance Checklist",
]

REQUIRED_P0_APPENDIX_SECTIONS = [
    "P0 Proof Appendix",
    "P0 Canon Appendix",
]

SECTION_ALIASES = {
    "Label-Off Signature": ["Label-Off Signature", "Label-Off Visual Signature"],
}


def main() -> int:
    missing = []
    depth_failures = []
    for entry in p0_registry_entries():
        text = recipe_text_by_entry(entry)
        surface_id = entry.get("surface_id")
        for marker in REQUIRED_TOP_LEVEL_SECTIONS:
            aliases = SECTION_ALIASES.get(marker, [marker])
            present_heading = next((alias for alias in aliases if f"## {alias}" in text), None)
            if not present_heading:
                missing.append({"surface_id": surface_id, "marker": marker})
            elif not section_has_depth(text, present_heading, min_nonempty_lines=2, min_words=18):
                depth_failures.append({"surface_id": surface_id, "section": present_heading})
        for marker in REQUIRED_P0_APPENDIX_SECTIONS:
            if f"## {marker}" not in text:
                missing.append({"surface_id": surface_id, "marker": marker})
        if not section_has_depth(text, "P0 Proof Appendix", min_nonempty_lines=8, min_words=80):
            depth_failures.append({"surface_id": surface_id, "section": "P0 Proof Appendix"})
        if not section_has_depth(text, "P0 Canon Appendix", min_nonempty_lines=8, min_words=80):
            depth_failures.append({"surface_id": surface_id, "section": "P0 Canon Appendix"})
        proof_appendix = section_text(text, "P0 Proof Appendix")
        canon_appendix = section_text(text, "P0 Canon Appendix")
        if "Source Link Status" not in proof_appendix or "Implementation Proof Boundary" not in proof_appendix:
            missing.append({"surface_id": surface_id, "marker": "P0 Proof Appendix anchors"})
        if "Good / Bad Example" not in proof_appendix or "Acceptance Checklist" not in proof_appendix:
            missing.append({"surface_id": surface_id, "marker": "P0 Proof Appendix examples"})
        if len([item for item in bullet_items(proof_appendix) if item.lower().startswith(('-', '*'))]) < 2:
            depth_failures.append({"surface_id": surface_id, "section": "P0 Proof Appendix bullets"})
        if not text_contains_any(canon_appendix, ["VoiceOver", "Dynamic Type", "Reduce Motion", "Reduce Transparency", "Increase Contrast", "Differentiate Without Color"]):
            missing.append({"surface_id": entry.get("surface_id"), "marker": "accessibility"})
        if not text_contains_any(canon_appendix, ["Proof", "Receipt", "Source"]):
            missing.append({"surface_id": entry.get("surface_id"), "marker": "proof_source"})
        if not text_contains_any(canon_appendix, ["Primary Action", "Primary action", "One dominant action", "one dominant action"]):
            missing.append({"surface_id": entry.get("surface_id"), "marker": "primary_action"})
        if not text_contains_all(proof_appendix, ["source link status", "implementation proof boundary", "good / bad example", "acceptance checklist"]):
            depth_failures.append({"surface_id": surface_id, "section": "P0 Proof Appendix required anchors"})
    status = "green" if not missing and not depth_failures else "red"
    payload = {
        "p0_count": len(p0_registry_entries()),
        "missing_markers": missing,
        "depth_failures": depth_failures,
        "status": status,
    }
    write_json(REPORT, payload)
    print("PASS" if status == "green" else "FAIL")
    return 0 if status == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
