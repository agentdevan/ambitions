#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import json
import sys


ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / "frontend/visual-encyclopedia"
REPORT = ROOT / "build/reports/visual-surface-graph.json"

REQUIRED_ROOTS = [
    "Today Root / Reality Meridian",
    "Goals Root / Constellation Atlas",
    "Capture Root / Atmosphere Composer",
    "Time Root / LifeShape Field",
    "You Root / User System Profile",
]

REQUIRED_UNRESOLVED = [
    "Local Runtime Source Detail from Today",
    "Review Pressure Surface",
    "Month Detail",
    "Shape Month Flow",
    "Time Stale Source State",
]


def load_json(path: Path):
    return json.loads(path.read_text())


def main() -> int:
    inventory = load_json(BASE / "SURFACE_RECIPE_INVENTORY.yaml")
    names = {item.get("name"): item for item in inventory if isinstance(item, dict)}
    ids = {item.get("surface_id"): item for item in inventory if isinstance(item, dict)}
    allowed_parent_tokens = {item.get("destination") for item in inventory if isinstance(item, dict)}
    allowed_parent_tokens.update({"Cross-surface"})
    allowed_parent_tokens.update({f"{item.get('destination')} Root" for item in inventory if isinstance(item, dict) and item.get("destination")})
    allowed_parent_tokens.update({f"{item.get('destination')} Root / {item.get('primary_object')}" for item in inventory if isinstance(item, dict) and item.get("destination") and item.get("primary_object")})

    missing_roots = [name for name in REQUIRED_ROOTS if name not in names]
    missing_surface_files = []
    invalid_parent_links = []
    unresolved_missing = []

    for item in inventory:
        recipe_path = ROOT / item.get("recipe_file", "")
        if not recipe_path.exists():
            missing_surface_files.append(item.get("recipe_file"))
        parent = item.get("parent_surface")
        children = item.get("child_surfaces", [])
        if parent and parent not in names and parent not in allowed_parent_tokens and parent != item.get("name"):
            invalid_parent_links.append({"surface": item.get("name"), "parent": parent})
        for child in children:
            if child not in names and child not in allowed_parent_tokens:
                invalid_parent_links.append({"surface": item.get("name"), "child": child})

    gaps = (BASE / "trace/UNMAPPED_INTENDED_SURFACE_GAPS.md").read_text().lower()
    specificity_ledger = (BASE / "trace/SURFACE_RECIPE_SPECIFICITY_REVIEW_LEDGER.md").read_text().lower()
    for unresolved in REQUIRED_UNRESOLVED:
        needle = unresolved.lower()
        if needle not in gaps and needle not in specificity_ledger:
            unresolved_missing.append(unresolved)

    required_types = {"app_shell", "top_level_surface", "sheet", "tray", "state_surface", "drill_down", "onboarding"}
    seen_types = {item.get("surface_type") for item in inventory if isinstance(item, dict)}
    missing_types = sorted(required_types - seen_types)

    report = {
        "surface_count": len(inventory),
        "missing_roots": missing_roots,
        "missing_surface_files": missing_surface_files,
        "invalid_parent_links": invalid_parent_links,
        "missing_types": missing_types,
        "unresolved_missing": unresolved_missing,
        "status": "green",
    }

    if missing_roots or missing_surface_files or invalid_parent_links or missing_types or unresolved_missing:
        report["status"] = "red"

    REPORT.parent.mkdir(parents=True, exist_ok=True)
    REPORT.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n")

    if report["status"] == "red":
        print("FAIL: surface graph check failed")
        return 1

    print("PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
