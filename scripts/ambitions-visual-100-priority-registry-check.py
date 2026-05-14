#!/usr/bin/env python3
from __future__ import annotations

from ambitions_visual_100_common import ROOT, load_priority_registry, write_json, REPORT_DIR


REPORT = REPORT_DIR / "visual-100-priority-registry.json"

VALID_SOURCE_LINK_STATUSES = {
    "linked",
    "weak_link",
    "intended_only",
    "missing",
    "needs_direction",
    "obsolete",
    "historical_only",
}

KNOWN_GATES = {
    "ia",
    "object_depth",
    "label_off",
    "source_truth",
    "proof_source_receipt",
    "transaction",
    "anti_generic",
    "accessibility",
    "native_believability",
    "local_first_trust",
    "hidden_automation",
}


def main() -> int:
    registry = load_priority_registry()
    entries = registry.get("priority_recipes", [])
    p0 = [entry for entry in entries if entry.get("tier") == "P0"]
    duplicate_ids = []
    seen_ids = set()
    missing = []
    invalid_statuses = []
    gate_mismatches = []
    for entry in p0:
        surface_id = entry.get("surface_id")
        if surface_id in seen_ids:
            duplicate_ids.append(surface_id)
        seen_ids.add(surface_id)
        for field in [
            "surface_id",
            "surface_name",
            "destination",
            "primary_object",
            "recipe_path",
            "source_link_status",
            "implementation_proof_status",
            "required_gates",
            "current_status",
            "notes",
        ]:
            value = entry.get(field)
            if field not in entry or value in ("", None) or value == []:
                missing.append({"surface_id": surface_id, "field": field})
        recipe_path = ROOT / str(entry.get("recipe_path", ""))
        if not recipe_path.exists():
            missing.append({"surface_id": surface_id, "field": "recipe_path_exists"})
        if entry.get("source_link_status") not in VALID_SOURCE_LINK_STATUSES:
            invalid_statuses.append({"surface_id": surface_id, "field": "source_link_status", "value": entry.get("source_link_status")})
        required_gates = entry.get("required_gates") or []
        if not required_gates:
            gate_mismatches.append({"surface_id": surface_id, "missing_gates": ["required_gates_empty"]})
        unknown_gates = sorted(set(required_gates) - KNOWN_GATES)
        if unknown_gates:
            gate_mismatches.append({"surface_id": surface_id, "unknown_gates": unknown_gates})
    status = "green"
    if not p0 or len(p0) < 10 or missing or invalid_statuses or gate_mismatches or duplicate_ids:
        status = "red"
    payload = {
        "generated_from_batch": registry.get("generated_from_batch"),
        "p0_count": len(p0),
        "p1_count": len([entry for entry in entries if entry.get("tier") == "P1"]),
        "p2_count": len([entry for entry in entries if entry.get("tier") == "P2"]),
        "missing_fields": missing,
        "duplicate_surface_ids": duplicate_ids,
        "invalid_source_link_statuses": invalid_statuses,
        "gate_mismatches": gate_mismatches,
        "status": status,
    }
    write_json(REPORT, payload)
    print("PASS" if status == "green" else "FAIL")
    return 0 if status == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
