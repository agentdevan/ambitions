#!/usr/bin/env python3
from __future__ import annotations

from ambitions_visual_100_common import p0_registry_entries, recipe_text_by_entry, section_text, write_json, REPORT_DIR


REPORT = REPORT_DIR / "visual-100-proof-source-receipt.json"
REQUIRED = [
    "Source / Trust Behavior",
    "Proof / Receipt Behavior",
    "Source Link Status",
    "Implementation Proof Boundary",
    "Acceptance Checklist",
]


def main() -> int:
    missing = []
    for entry in p0_registry_entries():
        text = recipe_text_by_entry(entry)
        surface_id = entry.get("surface_id")
        for marker in REQUIRED:
            if marker not in text:
                missing.append({"surface_id": surface_id, "marker": marker})
        source = section_text(text, "Source / Trust Behavior")
        proof = section_text(text, "Proof / Receipt Behavior")
        txn = section_text(text, "Transaction Behavior")
        proof_appendix = section_text(text, "P0 Proof Appendix")
        if not source or not proof or not txn:
            missing.append({"surface_id": surface_id, "marker": "proof_source_section_depth"})
        if "source" not in source.lower() or "trust" not in source.lower():
            missing.append({"surface_id": surface_id, "marker": "source behavior"})
        if "proof" not in proof.lower() or "receipt" not in proof.lower():
            missing.append({"surface_id": surface_id, "marker": "proof receipt behavior"})
        if not all(term in txn.lower() for term in ["preview", "commit", "receipt"]):
            missing.append({"surface_id": surface_id, "marker": "transaction anchors"})
        if "local-only" not in proof_appendix.lower() and "stale source" not in proof_appendix.lower():
            missing.append({"surface_id": surface_id, "marker": "source freshness states"})
        if "implementation proof boundary" not in proof_appendix.lower() or "acceptance checklist" not in proof_appendix.lower():
            missing.append({"surface_id": surface_id, "marker": "proof appendix anchors"})
    status = "green" if not missing else "red"
    write_json(REPORT, {"missing": missing, "status": status, "p0_count": len(p0_registry_entries())})
    print("PASS" if status == "green" else "FAIL")
    return 0 if status == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
