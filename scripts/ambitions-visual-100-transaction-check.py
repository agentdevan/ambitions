#!/usr/bin/env python3
from __future__ import annotations

from ambitions_visual_100_common import p0_registry_entries, recipe_text_by_entry, section_text, write_json, REPORT_DIR


REPORT = REPORT_DIR / "visual-100-transaction.json"
REQUIRED = ["Transaction Behavior", "preview", "commit", "receipt", "undo", "recover", "intent"]


def main() -> int:
    missing = []
    for entry in p0_registry_entries():
        text = recipe_text_by_entry(entry).lower()
        txn = section_text(recipe_text_by_entry(entry), "Transaction Behavior")
        surface_id = entry.get("surface_id")
        for marker in REQUIRED:
            if marker.lower() not in text:
                missing.append({"surface_id": surface_id, "marker": marker})
        if not txn or not all(term in txn.lower() for term in ["preview", "commit", "receipt"]):
            missing.append({"surface_id": surface_id, "marker": "transaction section depth"})
        if "undo" not in txn.lower() and "recover" not in txn.lower():
            missing.append({"surface_id": surface_id, "marker": "undo recover path"})
    status = "green" if not missing else "red"
    write_json(REPORT, {"missing": missing, "status": status, "p0_count": len(p0_registry_entries())})
    print("PASS" if status == "green" else "FAIL")
    return 0 if status == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
