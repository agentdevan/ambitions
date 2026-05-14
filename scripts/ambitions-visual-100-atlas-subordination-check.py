#!/usr/bin/env python3
from __future__ import annotations

from ambitions_visual_100_common import BASE, ROOT, load_priority_registry, read_text, write_json, REPORT_DIR


REPORT = REPORT_DIR / "visual-100-atlas-subordination.json"


def main() -> int:
    docs = [
        BASE / "objects/PRIMARY_OBJECT_ANATOMY_CANON.md",
        BASE / "VISUAL_RECIPE_SCHEMA_CONTRACT.md",
        BASE / "trace/VISUAL_100_PRIORITY_RECIPE_REGISTRY.md",
        BASE / "gates/NORTH_STAR_100_MEASURABLE_GATE_MATRIX.yaml",
    ]
    missing = [str(path.relative_to(BASE)) for path in docs if not path.exists()]
    text = "\n".join(read_text(path) for path in docs if path.exists()).lower()
    required = [
        "primary object anatomy canon",
        "recipe schema contract",
        "priority recipe registry",
        "measurable gate matrix",
        "visual proof dashboard",
    ]
    for marker in required:
        if marker not in text:
            missing.append(marker)
    registry = load_priority_registry()
    if not any(entry.get("tier") == "P0" and entry.get("recipe_path") for entry in registry.get("priority_recipes", [])):
        missing.append("registry-p0-recipes")
    if "validator:" not in read_text(BASE / "gates/NORTH_STAR_100_MEASURABLE_GATE_MATRIX.yaml"):
        missing.append("gate-validator-chain")
    dashboard = ROOT / "scripts/ambitions-visual-100-proof-dashboard.py"
    if not dashboard.exists():
        missing.append("dashboard-script")
    status = "green" if not missing else "red"
    write_json(REPORT, {"missing": missing, "status": status, "p0_count": len([entry for entry in registry.get("priority_recipes", []) if entry.get("tier") == "P0"])})
    print("PASS" if status == "green" else "FAIL")
    return 0 if status == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
