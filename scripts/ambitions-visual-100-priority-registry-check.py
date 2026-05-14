#!/usr/bin/env python3
from __future__ import annotations

from ambitions_visual_100_common import load_priority_registry, write_json, REPORT_DIR


REPORT = REPORT_DIR / "visual-100-priority-registry.json"


def main() -> int:
    registry = load_priority_registry()
    entries = registry.get("priority_recipes", [])
    p0 = [entry for entry in entries if entry.get("tier") == "P0"]
    required_fields = [
        "surface_id",
        "surface_name",
        "destination",
        "primary_object",
        "recipe_path",
        "source_link_status",
        "implementation_proof_status",
        "required_gates",
        "current_status",
    ]
    missing = []
    for entry in p0:
        for field in required_fields:
            value = entry.get(field)
            if field not in entry or value in ("", None) or value == []:
                missing.append({"surface_id": entry.get("surface_id"), "field": field})
    status = "green"
    if not p0 or len(p0) < 10 or missing:
        status = "red"
    payload = {
        "generated_from_batch": registry.get("generated_from_batch"),
        "p0_count": len(p0),
        "p1_count": len([entry for entry in entries if entry.get("tier") == "P1"]),
        "p2_count": len([entry for entry in entries if entry.get("tier") == "P2"]),
        "missing_fields": missing,
        "status": status,
    }
    write_json(REPORT, payload)
    print("PASS" if status == "green" else "FAIL")
    return 0 if status == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
