#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

from ambitions_visual_100_common import BASE, ROOT, load_json_like, load_priority_registry, write_json, REPORT_DIR


REPORT = REPORT_DIR / "visual-100-source-debt.json"


def main() -> int:
    manifest = load_json_like(BASE / "VISUAL_SOURCE_LINKS.yaml")
    registry = load_priority_registry()
    recipes = manifest.get("recipes", [])
    distribution = {status: 0 for status in ["linked", "weak_link", "intended_only", "missing", "needs_direction", "obsolete", "historical_only"]}
    invalid = []
    missing_files = []
    for entry in recipes:
        status = entry.get("source_link_confidence")
        if status in distribution:
            distribution[status] += 1
        else:
            invalid.append({"recipe_id": entry.get("recipe_id"), "status": status})
        recipe_path = ROOT / str(entry.get("recipe_path", ""))
        if not recipe_path.exists():
            missing_files.append(str(entry.get("recipe_path")))
        if status in {"linked", "weak_link"}:
            for candidate in entry.get("source_file_candidates", []):
                if not (ROOT / candidate).exists():
                    missing_files.append(candidate)

    p0_visible = []
    for entry in registry.get("priority_recipes", []):
        status = entry.get("source_link_status")
        if status in {"intended_only", "weak_link", "missing", "needs_direction"}:
            p0_visible.append({"surface_id": entry.get("surface_id"), "status": status})

    visible_intended_only = [
        item for item in p0_visible if item.get("status") == "intended_only"
    ]
    hidden_intended_only = distribution.get("intended_only", 0) > 0 and not visible_intended_only

    status = "green"
    if invalid or missing_files:
        status = "red"
    elif hidden_intended_only:
        status = "red"

    payload = {
        "distribution": distribution,
        "invalid_entries": invalid,
        "missing_files": missing_files,
        "p0_visible_debt": p0_visible,
        "p0_visible_intended_only_count": len(visible_intended_only),
        "p0_hidden_intended_only": hidden_intended_only,
        "p0_intended_only_count": sum(1 for entry in registry.get("priority_recipes", []) if entry.get("tier") == "P0" and entry.get("source_link_status") == "intended_only"),
        "status": status,
    }
    write_json(REPORT, payload)
    print("PASS" if status == "green" else "WARN" if status == "yellow" else "FAIL")
    return 0 if status in {"green", "yellow"} else 1


if __name__ == "__main__":
    raise SystemExit(main())
