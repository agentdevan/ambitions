#!/usr/bin/env python3
from __future__ import annotations

from collections import Counter

from visual_final_form_common import (
    FINAL_BATCH_ID,
    REPORT_DIR,
    TRACE_ROOT,
    INTERACTION_KEYS,
    coverage_source_basis,
    interaction_definition,
    p0_entries,
    surface_bible_path,
    surface_id,
    surface_label,
    surface_text,
    write_json,
    write_json_like_yaml,
)


REPORT_JSON = REPORT_DIR / "native-iphone-interaction-grammar.json"
DOC_PATH = TRACE_ROOT / "NATIVE_IPHONE_INTERACTION_GRAMMAR_MATRIX.yaml"


def main() -> int:
    surfaces: list[dict[str, object]] = []
    status_counts: Counter[str] = Counter()
    complete_surfaces = 0
    debt_surfaces = 0
    missing_surfaces = []

    for entry in p0_entries():
        text = surface_text(entry)
        bible = surface_bible_path(entry)
        if not text:
            missing_surfaces.append(surface_label(entry))
            continue
        grammar_map = {}
        for key in INTERACTION_KEYS:
            grammar_map[key] = interaction_definition(entry, key)
            status = str(grammar_map[key]["status"])
            status_counts[status] += 1
        surface_status = "documented" if all(item["status"] == "documented" for item in grammar_map.values()) else "debt"
        complete_surfaces += 1 if surface_status == "documented" else 0
        debt_surfaces += 1 if surface_status == "debt" else 0
        surfaces.append(
            {
                "surface_id": surface_id(entry),
                "surface_name": surface_label(entry),
                "recipe_path": str(entry.get("recipe_path", "")),
                "bible_path": str(bible.relative_to(REPORT_DIR.parents[1])) if bible else "",
                "source_link_status": str(entry.get("source_link_status", "unknown")),
                "implementation_proof_status": str(entry.get("implementation_proof_status", "unknown")),
                "grammar_source_basis": coverage_source_basis(entry),
                "status": surface_status,
                "grammar": grammar_map,
            }
        )

    overall_status = "green" if not missing_surfaces and debt_surfaces == 0 else "yellow"
    if missing_surfaces:
        overall_status = "red"

    payload = {
        "batch": FINAL_BATCH_ID,
        "generated_from_batch": FINAL_BATCH_ID,
        "surface_count": len(surfaces),
        "documented_surface_count": complete_surfaces,
        "debt_surface_count": debt_surfaces,
        "missing_surfaces": missing_surfaces,
        "grammar_totals": dict(status_counts),
        "status": overall_status,
        "surfaces": surfaces,
    }
    write_json(REPORT_JSON, payload)
    write_json_like_yaml(DOC_PATH, payload)
    print("PASS" if overall_status != "red" else "FAIL")
    return 0 if overall_status != "red" else 1


if __name__ == "__main__":
    raise SystemExit(main())
