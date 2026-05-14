#!/usr/bin/env python3
from __future__ import annotations

from collections import Counter

from visual_final_form_common import (
    FINAL_BATCH_ID,
    REPORT_DIR,
    SCENARIO_KEYS,
    TRACE_ROOT,
    coverage_source_basis,
    p0_entries,
    scenario_definition,
    surface_bible_path,
    surface_id,
    surface_label,
    surface_text,
    write_json,
    write_json_like_yaml,
)


REPORT_JSON = REPORT_DIR / "surface-scenario-coverage.json"
DOC_PATH = TRACE_ROOT / "SURFACE_SCENARIO_COVERAGE_MATRIX.yaml"


def main() -> int:
    surfaces: list[dict[str, object]] = []
    status_counts: Counter[str] = Counter()
    covered_surfaces = 0
    debt_surfaces = 0
    missing_surfaces = []

    for entry in p0_entries():
        text = surface_text(entry)
        bible = surface_bible_path(entry)
        if not text:
            missing_surfaces.append(surface_label(entry))
            continue
        scenario_map = {}
        for key in SCENARIO_KEYS:
            scenario_map[key] = scenario_definition(entry, key)
            status = str(scenario_map[key]["status"])
            status_counts[status] += 1
        surface_status = "covered" if all(item["status"] == "covered" for item in scenario_map.values()) else "debt"
        covered_surfaces += 1 if surface_status == "covered" else 0
        debt_surfaces += 1 if surface_status == "debt" else 0
        surfaces.append(
            {
                "surface_id": surface_id(entry),
                "surface_name": surface_label(entry),
                "recipe_path": str(entry.get("recipe_path", "")),
                "bible_path": str(bible.relative_to(REPORT_DIR.parents[1])) if bible else "",
                "source_link_status": str(entry.get("source_link_status", "unknown")),
                "implementation_proof_status": str(entry.get("implementation_proof_status", "unknown")),
                "coverage_source_basis": coverage_source_basis(entry),
                "status": surface_status,
                "scenarios": scenario_map,
            }
        )

    overall_status = "green" if not missing_surfaces and debt_surfaces == 0 else "yellow"
    if missing_surfaces:
        overall_status = "red"

    payload = {
        "batch": FINAL_BATCH_ID,
        "generated_from_batch": FINAL_BATCH_ID,
        "surface_count": len(surfaces),
        "covered_surface_count": covered_surfaces,
        "debt_surface_count": debt_surfaces,
        "missing_surfaces": missing_surfaces,
        "scenario_totals": dict(status_counts),
        "status": overall_status,
        "surfaces": surfaces,
    }
    write_json(REPORT_JSON, payload)
    write_json_like_yaml(DOC_PATH, payload)
    print("PASS" if overall_status != "red" else "FAIL")
    return 0 if overall_status != "red" else 1


if __name__ == "__main__":
    raise SystemExit(main())
