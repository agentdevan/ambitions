#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import json
import sys


ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / "docs/canon/frontend"
REPORT = ROOT / "build/reports/visual-source-linkage.json"
ALLOWED_STATUSES = {"linked", "weak_link", "missing", "intended_only", "needs_direction"}
ALLOWED_PRIORITIES = {"linked", "weak_link"}


def load_json(path: Path):
    return json.loads(path.read_text())


def main() -> int:
    inventory = load_json(BASE / "SURFACE_RECIPE_INVENTORY.yaml")
    manifest = load_json(BASE / "VISUAL_SOURCE_LINKS.yaml")
    priority_ids = manifest.get("priority_recipe_ids", [])
    recipes = manifest.get("recipes", [])

    report = {
        "inventory_count": len(inventory) if isinstance(inventory, list) else 0,
        "priority_recipe_count": len(priority_ids),
        "manifest_recipe_count": len(recipes),
        "priority_recipe_ids": priority_ids,
        "linked_priority_count": 0,
        "weak_priority_count": 0,
        "missing_priority_ids": [],
        "duplicate_recipe_ids": [],
        "invalid_status_entries": [],
        "missing_recipe_files": [],
        "missing_source_files": [],
        "inventory_unlinked_count": 0,
        "status": "green",
    }

    inventory_ids = {item.get("surface_id") for item in inventory if isinstance(item, dict)}
    manifest_ids = {}
    for entry in recipes:
        recipe_id = entry.get("recipe_id")
        if recipe_id in manifest_ids:
            report["duplicate_recipe_ids"].append(recipe_id)
        manifest_ids[recipe_id] = entry

        status = entry.get("source_link_confidence")
        if status not in ALLOWED_STATUSES:
            report["invalid_status_entries"].append(
                {"recipe_id": recipe_id, "status": status}
            )

        recipe_path = ROOT / entry.get("recipe_path", "")
        if not recipe_path.exists():
            report["missing_recipe_files"].append(entry.get("recipe_path"))
            continue

        source_candidates = entry.get("source_file_candidates", [])
        if status in {"linked", "weak_link"}:
            for candidate in source_candidates:
                if not (ROOT / candidate).exists():
                    report["missing_source_files"].append(
                        {"recipe_id": recipe_id, "candidate": candidate, "status": status}
                    )

    for recipe_id in priority_ids:
        entry = manifest_ids.get(recipe_id)
        if not entry:
            report["missing_priority_ids"].append(recipe_id)
            continue
        status = entry.get("source_link_confidence")
        if status == "linked":
            report["linked_priority_count"] += 1
        elif status == "weak_link":
            report["weak_priority_count"] += 1
        else:
            report["missing_priority_ids"].append(recipe_id)

    linked_ids = set(manifest_ids)
    report["inventory_unlinked_count"] = sum(1 for surface_id in inventory_ids if surface_id not in linked_ids)

    if (
        report["missing_priority_ids"]
        or report["duplicate_recipe_ids"]
        or report["invalid_status_entries"]
        or report["missing_recipe_files"]
        or report["missing_source_files"]
    ):
        report["status"] = "red"
    elif report["weak_priority_count"] or report["inventory_unlinked_count"]:
        report["status"] = "yellow"

    REPORT.parent.mkdir(parents=True, exist_ok=True)
    REPORT.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n")

    if report["status"] == "red":
        print("FAIL: source linkage check failed")
        for key in ["missing_priority_ids", "duplicate_recipe_ids", "invalid_status_entries", "missing_recipe_files", "missing_source_files"]:
            if report[key]:
                print(f"{key}: {report[key]}")
        return 1

    print("PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
